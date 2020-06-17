unit Delphi.ORM.DataSet;

interface

uses System.Classes, Data.DB, System.Rtti, System.Generics.Collections, System.SysUtils;

type
  EPropertyNameDoesNotExist = class(Exception);
  EPropertyWithDifferentType = class(Exception);

  TORMObjectField = class(TField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TORMDataSet = class(TDataSet)
  private
    FInternalList: TList<TObject>;
    FObjectList: TList<TObject>;
    FRecordIndex: Integer;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiInstanceProperty>>;

    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetInternalList: TList<TObject>;
    function GetPropertyValueFromCurrentObject(Field: TField): TValue;

    procedure LoadFieldDefsFromClass<T: class>;
    procedure LoadObjectType<T: class>;

    property InternalList: TList<TObject> read GetInternalList;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; override;
    function GetNextRecord: Boolean; override;
    function GetPriorRecord: Boolean; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure LoadPropertiesFromFieldDefs;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
  public
    destructor Destroy; override;

    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;

    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);
  end;

implementation

uses System.TypInfo, System.Variants;

{ TORMDataSet }

function TORMDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := TRecordBuffer(1);
end;

destructor TORMDataSet.Destroy;
begin
  FInternalList.Free;

  inherited;
end;

procedure TORMDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  Buffer := nil;
end;

function TORMDataSet.GetCurrentObject<T>: T;
begin
  Result := FObjectList[FRecordIndex] as T;
end;

function TORMDataSet.GetFieldClass(FieldDef: TFieldDef): TFieldClass;
begin
  if FieldDef.DataType = ftObject then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldDef);
end;

function TORMDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  var Value := GetPropertyValueFromCurrentObject(Field);

  if Field is TStringField then
  begin
    var StringData := Value.AsType<AnsiString>;
    var StringSize := Length(StringData);

    Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);

    Buffer[StringSize] := 0;
  end
  else
    Value.ExtractRawData(@Buffer[0]);

  Result := True;
end;

function TORMDataSet.GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
begin
  Result := ftUnknown;

  case &Property.PropertyType.TypeKind of
    tkChar,
    tkString,
    tkLString,
    tkUString,
    tkWChar: Result := ftString;
    tkClass: Result := ftObject;
    tkEnumeration:
      if &Property.PropertyType.Handle = TypeInfo(Boolean) then
        Result := ftBoolean;
    tkFloat:
      if &Property.PropertyType.Handle = TypeInfo(TDate) then
        Result := ftDate
      else if &Property.PropertyType.Handle = TypeInfo(TDateTime) then
        Result := ftDateTime
      else if &Property.PropertyType.Handle = TypeInfo(TTime) then
        Result := ftTime
      else
        case TRttiInstanceProperty(&Property).PropInfo.PropType^.TypeData.FloatType of
          ftCurr: Result := TFieldType.ftCurrency;
          ftDouble: Result := TFieldType.ftFloat;
          ftExtended: Result := TFieldType.ftExtended;
          ftSingle: Result := TFieldType.ftSingle;
        end;
    tkInteger:
      case &Property.PropertyType.AsOrdinal.OrdType of
        otSByte,
        otUByte: Result := ftByte;
        otSWord: Result := ftInteger;
        otUWord: Result := ftWord;
        otSLong: Result := ftInteger;
        otULong: Result := ftLongWord;
      end;
    tkInt64: Result := ftLargeint;
    tkWString: Result := ftWideString;
  end;
end;

function TORMDataSet.GetInternalList: TList<TObject>;
begin
  if not Assigned(FInternalList) then
    FInternalList := TList<TObject>.Create;

  Result := FInternalList;
end;

function TORMDataSet.GetNextRecord: Boolean;
begin
  Inc(FRecordIndex);

  Result := inherited GetNextRecord;
end;

function TORMDataSet.GetPriorRecord: Boolean;
begin
  Dec(FRecordIndex);

  Result := inherited GetPriorRecord;
end;

function TORMDataSet.GetPropertyValueFromCurrentObject(Field: TField): TValue;
begin
  var &Object := GetCurrentObject<TObject>;

  for var &Property in FPropertyMappingList[Pred(Field.FieldNo)] do
  begin
    Result := &Property.GetValue(&Object);

    if &Property.PropertyType.IsInstance then
      &Object := &Property.GetValue(&Object).AsObject;
  end;
end;

function TORMDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  if FRecordIndex < 0 then
    Result := grBOF
  else if FRecordIndex < RecordCount then
    Result := grOK
  else
    Result := grEOF;
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := FObjectList.Count;
end;

procedure TORMDataSet.InternalClose;
begin
  inherited;

end;

procedure TORMDataSet.InternalHandleException;
begin
  inherited;

end;

procedure TORMDataSet.InternalInitFieldDefs;
begin
  inherited;

end;

procedure TORMDataSet.InternalLast;
begin
  FRecordIndex := FObjectList.Count;
end;

procedure TORMDataSet.InternalOpen;
begin
  FRecordIndex := -1;

  CreateFields;

  BindFields(True);
end;

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FObjectList) and (FObjectList.Count > 0);
end;

procedure TORMDataSet.LoadFieldDefsFromClass<T>;
begin
  FPropertyMappingList := nil;

  for var &Property in FObjectType.GetProperties do
    if &Property.Visibility = mvPublished then
    begin
      FieldDefs.Add(&Property.Name, GetFieldTypeFromProperty(&Property));

      FPropertyMappingList := FPropertyMappingList + [[&Property as TRttiInstanceProperty]];
    end;
end;

procedure TORMDataSet.LoadObjectType<T>;
begin
  var Context := TRttiContext.Create;

  FObjectType := Context.GetType(T) as TRttiInstanceType;
end;

procedure TORMDataSet.LoadPropertiesFromFieldDefs;
begin
  FPropertyMappingList := nil;

  for var A := 0 to Pred(FieldDefs.Count) do
  begin
    var FieldDef := FieldDefs[A];
    var ObjectType := FObjectType;
    var &Property: TRttiInstanceProperty := nil;
    var PropertyList: TArray<TRttiInstanceProperty> := nil;
    var PropertyName := EmptyStr;

    for PropertyName in FieldDef.Name.Split(['.']) do
    begin
      &Property := ObjectType.GetProperty(PropertyName) as TRttiInstanceProperty;

      if not Assigned(&Property) then
        raise EPropertyNameDoesNotExist.CreateFmt('The property %s not found in the current object!', [PropertyName]);

      PropertyList := PropertyList + [&Property];

      if &Property.PropertyType.IsInstance then
        ObjectType := &Property.PropertyType as TRttiInstanceType;
    end;

    if GetFieldTypeFromProperty(&Property) <> FieldDef.DataType then
      raise EPropertyWithDifferentType.CreateFmt('The property type is not equal to the type of the added field, expected value %s found %s',
        [TRttiEnumerationType.GetName(GetFieldTypeFromProperty(&Property)), TRttiEnumerationType.GetName(FieldDef.DataType)]);

    FPropertyMappingList := FPropertyMappingList + [PropertyList];
  end;
end;

procedure TORMDataSet.OpenList<T>(List: TList<T>);
begin
  FObjectList := TList<TObject>(List);

  LoadObjectType<T>;

  if FieldDefs.Count = 0 then
    LoadFieldDefsFromClass<T>
  else
    LoadPropertiesFromFieldDefs;

  Open;
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  FObjectList := InternalList;

  InternalList.Add(&Object);

  OpenList<T>(TList<T>(InternalList));
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin

end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftObject);
end;

end.

