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

{$IFDEF PAS2JS}
  TRecBuf = TDataRecord;
  TRecordBuffer = TDataRecord;
  TValueBuffer = JSValue;
{$ENDIF}

  TORMObjectField = class(TField)
  protected
{$IFDEF PAS2JS}
    function GetAsJSValue: JSValue; override;
{$ENDIF}
{$IFDEF DCC}
    function GetAsVariant: Variant; override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TORMDataSet = class(TDataSet)
  private
    FObjectList: TArray<TObject>;
    FContext: TRttiContext;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiProperty>>;
    FRecordNumber: Integer;
    FInsertingObject: TObject;
    FOldValueObject: TObject;

    function GetActiveRecordNumber: Integer;
    function GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectClassName: String;
    function GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;

    procedure LoadFieldDefsFromClass;
    procedure LoadPropertiesFromFields;
    procedure ResetCurrentRecord;
    procedure ReleaseOldValueObject;
    procedure SetObjectClassName(const Value: String);
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure GetBookmarkData(Buffer: TRecBuf; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark); override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalCancel; override;
    procedure InternalClose; override;
    procedure InternalEdit; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    procedure InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF}; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf); override;
    procedure InternalInsert; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField;
        {$IFDEF PAS2JS}
          Buffer: TDatarecord): JSValue;
        {$ELSE}
          var Buffer: TValueBuffer): Boolean;
        {$ENDIF} override;

    procedure OpenArray<T: class>(List: TArray<T>);
    procedure OpenClass<T: class>;
    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);

    property ObjectList: TArray<TObject> read FObjectList;
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
    property ObjectClassName: String read GetObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

uses System.TypInfo{$IFDEF DCC}, System.Variants{$ENDIF};

{ TORMDataSet }

function TORMDataSet.AllocRecordBuffer: TRecordBuffer;
begin
{$IFDEF DCC}
  Result := GetMemory(SizeOf(Integer));
{$ENDIF}
end;

constructor TORMDataSet.Create(AOwner: TComponent);
begin
  inherited;

{$IFDEF DCC}
  BookmarkSize := SizeOf(Integer);
{$ENDIF}

  FContext := TRttiContext.Create;

  ResetCurrentRecord;
end;

destructor TORMDataSet.Destroy;
begin
  FInsertingObject.Free;

  inherited;
end;

procedure TORMDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
{$IFDEF DCC}
  FreeMem(Buffer);
{$ENDIF}
end;

function TORMDataSet.GetActiveRecordNumber: Integer;
begin
{$IFDEF DCC}
  Result := PInteger(ActiveBuffer)^;
{$ELSE}
  Result := Integer(ActiveBuffer.Data);
{$ENDIF}
end;

procedure TORMDataSet.GetBookmarkData(Buffer: TRecBuf; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark);
begin
{$IFDEF DCC}
  PInteger(Data)^ := FRecordNumber;
{$ENDIF}
end;

function TORMDataSet.GetCurrentObject<T>: T;
var
  ActiveRecord: Integer;

begin
  Result := nil;

  case State of
    dsInsert: Result := FInsertingObject as T;
    dsOldValue: Result := FOldValueObject as T;
//    dsInactive: ;
//    dsBrowse: ;
//    dsEdit: ;
//    dsSetKey: ;
//    dsCalcFields: ;
//    dsFilter: ;
//    dsNewValue: ;
//    dsCurValue: ;
//    dsBlockRead: ;
//    dsInternalCalc: ;
//    dsOpening: ;
    else
    begin
      ActiveRecord := GetActiveRecordNumber;

      if ActiveRecord > -1 then
        Result := ObjectList[ActiveRecord] as T;
    end;
  end;
end;

function TORMDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  if FieldType = ftVariant then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldType);
end;

{$IFDEF PAS2JS}
function TORMDataSet.GetFieldData(Field: TField; Buffer: TDatarecord): JSValue;
{$ELSE}
function TORMDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
{$ENDIF}
var
  &Property: TRttiProperty;

  Value: TValue;

begin
  Result := GetPropertyAndObjectFromField(Field, Value, &Property);

  if Result then
  begin
    Value := &Property.GetValue(Value.AsObject);

    Result := not Value.IsEmpty;

    if Result then
{$IFDEF PAS2JS}
      Result := Value.AsJSValue;
{$ELSE}
      if Assigned(Buffer) then
        if Field is TStringField then
        begin
          var StringData := Value.AsType<AnsiString>;
          var StringSize := Length(StringData);

          if StringSize > 0 then
            Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);

          Buffer[StringSize] := 0;
        end
        else
          Value.ExtractRawData(@Buffer[0])
{$ENDIF}
  end;
end;

function TORMDataSet.GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
begin
  Result := ftUnknown;
  Size := 0;

  case &Property.PropertyType.TypeKind of
{$IFDEF DCC}
    tkLString,
    tkUString,
    tkWChar,
{$ENDIF}
    tkChar,
    tkString: Result := ftString;
{$IFDEF PAS2JS}
    tkBool,
{$ENDIF}
    tkEnumeration:
      if &Property.PropertyType.Handle = TypeInfo(Boolean) then
        Result := ftBoolean
      else
        Result := ftInteger;
    tkFloat:
      if &Property.PropertyType.Handle = TypeInfo(TDate) then
        Result := ftDate
      else if &Property.PropertyType.Handle = TypeInfo(TDateTime) then
        Result := ftDateTime
      else if &Property.PropertyType.Handle = TypeInfo(TTime) then
        Result := ftTime
      else
{$IFDEF DCC}
        case TRttiInstanceProperty(&Property).PropInfo.PropType^.TypeData.FloatType of
          ftCurr: Result := TFieldType.ftCurrency;
          ftDouble: Result := TFieldType.ftFloat;
          ftExtended: Result := TFieldType.ftExtended;
          ftSingle: Result := TFieldType.ftSingle;
        end;
{$ELSE}
        Result := TFieldType.ftFloat;
{$ENDIF}
    tkInteger:
{$IFDEF DCC}
      case &Property.PropertyType.AsOrdinal.OrdType of
        otSByte,
        otUByte: Result := ftByte;
        otSWord: Result := ftInteger;
        otUWord: Result := ftWord;
        otSLong: Result := ftInteger;
        otULong: Result := ftLongWord;
      end;
{$ELSE}
      Result := ftInteger;
{$ENDIF}
    tkClass: Result := ftVariant;
{$IFDEF DCC}
    tkInt64: Result := ftLargeint;
    tkWString: Result := ftWideString;
{$ENDIF}
  end;

  case &Property.PropertyType.TypeKind of
{$IFDEF DCC}
    tkLString,
    tkUString,
    tkWString,
{$ENDIF}
    tkString: Size := 50;

{$IFDEF DCC}
    tkWChar,
{$ENDIF}
    tkChar: Size := 1;
  end;
end;

function TORMDataSet.GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
var
  Size: Integer;

begin
  Size := 0;

  Result := GetFieldInfoFromProperty(&Property, Size);
end;

function TORMDataSet.GetObjectClassName: String;
begin
  Result := EmptyStr;

  if Assigned(FObjectType) then
    Result := FObjectType.Name;
end;

function TORMDataSet.GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
var
  A: Integer;

  PropertyList: TArray<TRttiProperty>;

begin
  Instance := TValue.From(GetCurrentObject<TObject>);
  PropertyList := FPropertyMappingList[Pred(Field.FieldNo)];
  Result := True;

  for A := Low(PropertyList) to High(PropertyList) do
  begin
    if A > 0 then
      Instance := &Property.GetValue(Instance.AsObject);

    &Property := PropertyList[A];

    if Instance.IsEmpty then
      Exit(False);
  end;
end;

function TORMDataSet.GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
{$IFDEF DCC}
var
  ObjectBuffer: PInteger absolute Buffer;
{$ENDIF}

begin
  Result := grOK;
  case GetMode of
    gmCurrent:
      if (FRecordNumber >= RecordCount) or (FRecordNumber < 0) then
        Result := grError;
    gmNext:
      if FRecordNumber < Pred(RecordCount) then
        Inc(FRecordNumber)
      else
        Result := grEOF;
    gmPrior:
      if FRecordNumber > 0 then
        Dec(FRecordNumber)
      else
        Result := grBOF;
  end;

{$IFDEF PAS2JS}
  Buffer.Data := FRecordNumber;
{$ELSE}
  ObjectBuffer^ := FRecordNumber;
{$ENDIF}
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := Length(ObjectList);
end;

procedure TORMDataSet.InternalInitRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf);
{$IFDEF DCC}
var
  ObjectBuffer: PInteger absolute Buffer;

{$ENDIF}
begin
{$IFDEF DCC}
  ObjectBuffer^ := -1;
{$ENDIF}
end;

procedure TORMDataSet.InternalInsert;
begin
  inherited;

  if not Assigned(FInsertingObject) then
    FInsertingObject := FObjectType.MetaclassType.Create;
end;

procedure TORMDataSet.InternalCancel;
var
  &Property: TRttiProperty;

  CurrentObject: TObject;

begin
  if Assigned(FOldValueObject) then
  begin
    CurrentObject := GetCurrentObject<TObject>;

    for &Property in FObjectType.GetProperties do
      &Property.SetValue(CurrentObject, &Property.GetValue(FOldValueObject));

    ReleaseOldValueObject;
  end;
end;

procedure TORMDataSet.InternalClose;
begin

end;

procedure TORMDataSet.InternalEdit;
var
  &Property: TRttiProperty;

  CurrentObject: TObject;

begin
  inherited;

  CurrentObject := GetCurrentObject<TObject>;

  if not Assigned(FOldValueObject) then
    FOldValueObject := FObjectType.MetaclassType.Create;

  for &Property in FObjectType.GetProperties do
    &Property.SetValue(FOldValueObject, &Property.GetValue(CurrentObject));
end;

procedure TORMDataSet.InternalFirst;
begin
  ResetCurrentRecord;
end;

procedure TORMDataSet.InternalGotoBookmark(Bookmark: TBookmark);
{$IFDEF DCC}
var
  RecordIndex: PInteger absolute Bookmark;
{$ENDIF}

begin
{$IFDEF DCC}
  FRecordNumber := RecordIndex^;
{$ENDIF}
end;

procedure TORMDataSet.InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF};
begin
end;

procedure TORMDataSet.InternalInitFieldDefs;
begin
  FieldDefs.Clear;

  LoadFieldDefsFromClass;
end;

procedure TORMDataSet.InternalLast;
begin
  FRecordNumber := RecordCount;
end;

procedure TORMDataSet.InternalOpen;
begin
  if not Assigned(FObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;

  if FieldDefs.Count = 0 then
    if FieldCount = 0 then
      LoadFieldDefsFromClass
    else
      InitFieldDefsFromFields;

{$IFDEF PAS2JS}
  if FieldCount = 0 then
{$ENDIF}
    CreateFields;

  BindFields(True);

  LoadPropertiesFromFields;

  InternalFirst;
end;

procedure TORMDataSet.InternalPost;
begin
  inherited;

  if State = dsInsert then
    FObjectList := FObjectList + [FInsertingObject];

  FInsertingObject := nil;

  ReleaseOldValueObject;
end;

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FObjectType);
end;

procedure TORMDataSet.LoadFieldDefsFromClass;
var
  &Property: TRttiProperty;

  FieldType: TFieldType;

  Size: Integer;

begin
  FPropertyMappingList := nil;

  for &Property in FObjectType.GetProperties do
    if &Property.Visibility = mvPublished then
    begin
      FieldType := GetFieldInfoFromProperty(&Property, Size);

      FieldDefs.Add(&Property.Name, FieldType, Size);

      FPropertyMappingList := FPropertyMappingList + [[&Property]];
    end;
end;

procedure TORMDataSet.LoadPropertiesFromFields;
var
  A: Integer;

  Field: TField;

  ObjectType: TRttiInstanceType;

  &Property: TRttiProperty;

  PropertyList: TArray<TRttiProperty>;

  PropertyName: String;

begin
  FPropertyMappingList := nil;

  for A := 0 to Pred(Fields.Count) do
  begin
    Field := Fields[A];
    ObjectType := FObjectType;
    PropertyName := EmptyStr;
    &Property := nil;
    PropertyList := nil;

    for PropertyName in Field.FieldName.Split(['.']) do
    begin
      &Property := ObjectType.GetProperty(PropertyName);

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

procedure TORMDataSet.OpenArray<T>(List: TArray<T>);
begin
{$IFDEF PAS2JS}
asm
  this.FObjectList = List;
end;
{$ELSE}
  FObjectList := TArray<TObject>(List);
{$ENDIF}
  FObjectType := FContext.GetType(TypeInfo(T)) as TRttiInstanceType;

  SetUniDirectional(True);

  Open;

  SetUniDirectional(False);
end;

procedure TORMDataSet.OpenClass<T>;
begin
  OpenArray<T>(nil);
end;

procedure TORMDataSet.OpenList<T>(List: TList<T>);
begin
  OpenArray<T>(List.ToArray);
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  OpenArray<T>([&Object]);
end;

procedure TORMDataSet.ReleaseOldValueObject;
begin
  FreeAndNil(FOldValueObject);
end;

procedure TORMDataSet.ResetCurrentRecord;
begin
  FRecordNumber := -1;
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
var
  IntValue: Integer;

  &Property: TRttiProperty;

  Instance, Value: TValue;

begin
  Value := TValue.Empty;

  GetPropertyAndObjectFromField(Field, Instance, &Property);

{$IFDEF DCC}
  case Field.DataType of
    ftByte,
    ftInteger,
    ftWord:
    begin
      IntValue := PInteger(Buffer)^;

      if &Property.PropertyType is TRttiEnumerationType then
        Value := TValue.FromOrdinal(&Property.PropertyType.Handle, IntValue)
      else
        Value := TValue.From(IntValue);
    end;
    ftString: Value := TValue.From(String(AnsiString(PAnsiChar(Buffer))));
    ftBoolean: Value := TValue.From(PWordBool(Buffer)^);
    ftDate,
    ftDateTime,
    ftTime:
    begin
      var DataTimeValue: TValueBuffer;

      SetLength(DataTimeValue, SizeOf(Double));

      DataConvert(Field, Buffer, DataTimeValue, False);

      Value := TValue.From(PDouble(DataTimeValue)^);
    end;
    ftCurrency,
    ftFloat: Value := TValue.From(PDouble(Buffer)^);
    TFieldType.ftSingle: Value := TValue.From(PSingle(Buffer)^);

    TFieldType.ftExtended: Value := TValue.From(PExtended(Buffer)^);

    ftLongWord: Value := TValue.From(PCardinal(Buffer)^);

    ftLargeint: Value := TValue.From(PInt64(Buffer)^);
    ftWideString: Value := TValue.From(String(PWideChar(Buffer)));
  end;
{$ENDIF}

  &Property.SetValue(Instance.AsObject, Value);
end;

procedure TORMDataSet.SetObjectClassName(const Value: String);
{$IFDEF DCC}
var
  &Type: TRttiType;

{$ENDIF}
begin
{$IFDEF DCC}
  for &Type in FContext.GetTypes do
    if (&Type.Name = Value) or (&Type.QualifiedName = Value) then
      FObjectType := &Type as TRttiInstanceType;
{$ENDIF}
end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftVariant);
end;

{$IFDEF PAS2JS}
function TORMObjectField.GetAsJSValue: JSValue;
begin

end;
{$ENDIF}

{$IFDEF DCC}
function TORMObjectField.GetAsVariant: Variant;
begin
  Result := NULL;
end;
{$ENDIF}

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('To open the DataSet, you must use the especialized procedures ou fill de ObjectClassName property!');
end;

end.

