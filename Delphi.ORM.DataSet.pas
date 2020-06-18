unit Delphi.ORM.DataSet;

interface

uses System.Classes, Data.DB, System.Rtti, System.Generics.Collections, System.SysUtils;

type
  EDataSetWithoutObjectDefinition = class(Exception)
  public
    constructor Create;
  end;
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
    FContext: TRttiContext;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiInstanceProperty>>;
    FObjectClassName: String;

    function GetInternalList: TList<TObject>;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectList: TList<TObject>;
    function GetPropertyValueFromCurrentObject(Field: TField): TValue;

    procedure LoadFieldDefsFromClass;
    procedure LoadObjectType<T: class>;
    procedure SetObjectClassName(const Value: String);

    property ObjectList: TList<TObject> read GetObjectList;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
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
    procedure LoadPropertiesFromFields;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;

    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);
  published
    property Active;
    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterRefresh;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeRefresh;
    property BeforeScroll;
    property ObjectClassName: String read FObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

uses System.TypInfo, System.Variants;

{ TORMDataSet }

function TORMDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := TRecordBuffer(1);
end;

constructor TORMDataSet.Create(AOwner: TComponent);
begin
  inherited;

  FContext := TRttiContext.Create;
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
  Result := ObjectList[FRecordIndex] as T;
end;

function TORMDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  if FieldType = ftObject then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldType);
end;

function TORMDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  var Value := GetPropertyValueFromCurrentObject(Field);

  Result := not Value.IsEmpty;

  if Result and Assigned(Buffer) then
    if Field is TStringField then
    begin
      var StringData := Value.AsType<AnsiString>;
      var StringSize := Length(StringData);

      Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);

      Buffer[StringSize] := 0;
    end
    else
      Value.ExtractRawData(@Buffer[0])
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

function TORMDataSet.GetObjectList: TList<TObject>;
begin
  if not Assigned(FObjectList) then
    FObjectList := GetInternalList;

  Result := FObjectList;
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
  Result := ObjectList.Count;
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

  FieldDefs.Clear;

  LoadFieldDefsFromClass;
end;

procedure TORMDataSet.InternalLast;
begin
  FRecordIndex := ObjectList.Count;
end;

procedure TORMDataSet.InternalOpen;
begin
  FRecordIndex := -1;

  if not Assigned(FObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;

  if FieldDefs.Count = 0 then
    LoadFieldDefsFromClass;

  CreateFields;

  LoadPropertiesFromFields;

  BindFields(True);
end;

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FObjectList) and (ObjectList.Count > 0);
end;

procedure TORMDataSet.LoadFieldDefsFromClass;
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
  FObjectType := FContext.GetType(T) as TRttiInstanceType;
end;

procedure TORMDataSet.LoadPropertiesFromFields;
begin
  FPropertyMappingList := nil;

  for var A := 0 to Pred(Fields.Count) do
  begin
    var Field := Fields[A];
    var ObjectType := FObjectType;
    var &Property: TRttiInstanceProperty := nil;
    var PropertyList: TArray<TRttiInstanceProperty> := nil;
    var PropertyName := EmptyStr;

    for PropertyName in Field.FieldName.Split(['.']) do
    begin
      &Property := ObjectType.GetProperty(PropertyName) as TRttiInstanceProperty;

      if not Assigned(&Property) then
        raise EPropertyNameDoesNotExist.CreateFmt('The property %s not found in the current object!', [PropertyName]);

      PropertyList := PropertyList + [&Property];

      if &Property.PropertyType.IsInstance then
        ObjectType := &Property.PropertyType as TRttiInstanceType;
    end;

    if GetFieldTypeFromProperty(&Property) <> Field.DataType then
      raise EPropertyWithDifferentType.CreateFmt('The property type is not equal to the type of the added field, expected value %s found %s',
        [TRttiEnumerationType.GetName(GetFieldTypeFromProperty(&Property)), TRttiEnumerationType.GetName(Field.DataType)]);

    FPropertyMappingList := FPropertyMappingList + [PropertyList];
  end;
end;

procedure TORMDataSet.OpenList<T>(List: TList<T>);
begin
  FObjectList := TList<TObject>(List);

  LoadObjectType<T>;

  Open;
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  ObjectList.Add(&Object);

  OpenList<T>(TList<T>(ObjectList));
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin

end;

procedure TORMDataSet.SetObjectClassName(const Value: String);
begin
  FObjectClassName := Value;

  for var &Type in FContext.GetTypes do
    if (&Type.Name = Value) or (&Type.QualifiedName = Value) then
      FObjectType := &Type as TRttiInstanceType;
end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftObject);
end;

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('To open the DataSet, you must use the especialized procedures ou fill de ObjectClassName property!');
end;

end.

