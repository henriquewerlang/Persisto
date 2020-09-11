unit Delphi.ORM.DataSet;

interface

uses System.Classes, Data.DB, System.Rtti, System.Generics.Collections, System.SysUtils, System.TypInfo;

type
  EDataSetWithoutObjectDefinition = class(Exception)
  public
    constructor Create;
  end;
  EPropertyNameDoesNotExist = class(Exception);
  EPropertyWithDifferentType = class(Exception);

{$IFDEF PAS2JS}
  TRecordBuffer = TDataRecord;
  TValueBuffer = JSValue;
{$ENDIF}

  TORMObjectField = class(TField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TORMDataSet = class(TDataSet)
  private
    FInternalList: TList<TObject>;
    FObjectList: TList<TObject>;
    FContext: TRttiContext;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiProperty>>;
    FRecordNumber: Integer;

    function GetCurrentRecordFromBuffer(const Buffer: TRecordBuffer): Integer;
    function GetActiveCurrentRecord: Integer;
    function GetInternalList: TList<TObject>;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectClassName: String;
    function GetObjectList: TList<TObject>;
    function GetPropertyValueFromCurrentObject(Field: TField): TValue;

    procedure LoadFieldDefsFromClass;
    procedure ResetCurrentRecord;
    procedure SetObjectClassName(const Value: String);
    procedure SetObjectType(TypeInfo: PTypeInfo);

    property ObjectList: TList<TObject> read GetObjectList;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    {$IFDEF PAS2JS}
    procedure GetBookmarkData(Buffer: TDataRecord; var Data: TBookmark); override;
    {$ELSE}
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
    {$ENDIF}
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalClose; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    procedure InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF}; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure LoadPropertiesFromFields;
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

    procedure OpenClass<T: class>; 
    procedure OpenList<T: class>(List: {$IFDEF PAS2JS}TObject{$ELSE}TList<T>{$ENDIF});
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
    property ObjectClassName: String read GetObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

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
  FInternalList.Free;

  inherited;
end;

procedure TORMDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
{$IFDEF DCC}
  FreeMem(Buffer);
{$ENDIF}
end;

{$IFDEF PAS2JS}
procedure TORMDataSet.GetBookmarkData(Buffer: TDataRecord; var Data: TBookmark);
begin
end;
{$ELSE}
procedure TORMDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
  PInteger(Data)^ := GetCurrentRecordFromBuffer(TRecordBuffer(Buffer));
end;
{$ENDIF}

function TORMDataSet.GetActiveCurrentRecord: Integer;
begin
  Result := GetCurrentRecordFromBuffer(TRecordBuffer(ActiveBuffer));
end;

function TORMDataSet.GetCurrentObject<T>: T;
begin
  Result := ObjectList[GetActiveCurrentRecord] as T;
end;

function TORMDataSet.GetCurrentRecordFromBuffer(const Buffer: TRecordBuffer): Integer;
{$IFDEF DCC}
var
  RecordIndex: PInteger absolute Buffer;
{$ENDIF}

begin
{$IFDEF PAS2JS}
  Result := Integer(Buffer.Data);
{$ELSE}
  Result := RecordIndex^;
{$ENDIF}
end;

function TORMDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  if FieldType = {$IFDEF PAS2JS}ftVariant{$ELSE}ftObject{$ENDIF} then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldType);
end;

{$IFDEF PAS2JS}
function TORMDataSet.GetFieldData(Field: TField; Buffer: TDatarecord): JSValue;
begin
  Result := GetPropertyValueFromCurrentObject(Field).AsJSValue;
end;
{$ELSE}
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
{$ENDIF}

function TORMDataSet.GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
begin
  Result := ftUnknown;

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
        Result := ftBoolean;
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
    tkClass: Result := {$IFDEF DCC}ftObject{$ELSE}ftVariant{$ENDIF};
{$IFDEF DCC}
    tkInt64: Result := ftLargeint;
    tkWString: Result := ftWideString;
{$ENDIF}
  end;
end;

function TORMDataSet.GetInternalList: TList<TObject>;
begin
  if not Assigned(FInternalList) then
    FInternalList := TList<TObject>.Create;

  Result := FInternalList;
end;

function TORMDataSet.GetObjectClassName: String;
begin
  Result := EmptyStr;

  if Assigned(FObjectType) then
    Result := FObjectType.Name;
end;

function TORMDataSet.GetObjectList: TList<TObject>;
begin
  if not Assigned(FObjectList) then
    FObjectList := GetInternalList;

  Result := FObjectList;
end;

function TORMDataSet.GetPropertyValueFromCurrentObject(Field: TField): TValue;
var
  &Object: TObject;

  &Property: TRttiProperty;

begin
  &Object := GetCurrentObject<TObject>;

  for &Property in FPropertyMappingList[Pred(Field.FieldNo)] do
  begin
    Result := &Property.GetValue(&Object);

    if &Property.PropertyType.IsInstance then
      &Object := &Property.GetValue(&Object).AsObject;
  end;
end;

function TORMDataSet.GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
{$IFDEF DCC}
  RecordIndex: PInteger absolute Buffer;
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

  if Result = grOK then
{$IFDEF PAS2JS}
    Buffer.Data := FRecordNumber;
{$ELSE}
    RecordIndex^ := FRecordNumber;
{$ENDIF}
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := ObjectList.Count;
end;

procedure TORMDataSet.InternalClose;
begin
end;

procedure TORMDataSet.InternalFirst;
begin
  ResetCurrentRecord;
end;

procedure TORMDataSet.InternalGotoBookmark(Bookmark: TBookmark);
begin
{$IFDEF DCC}
  FRecordNumber := GetCurrentRecordFromBuffer(TRecordBuffer(Bookmark));
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

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FObjectList) and (ObjectList.Count > 0);
end;

procedure TORMDataSet.LoadFieldDefsFromClass;
var
  &Property: TRttiProperty;

begin
  FPropertyMappingList := nil;

  for &Property in FObjectType.GetDeclaredProperties do
    if &Property.Visibility = mvPublished then
    begin
      FieldDefs.Add(&Property.Name, GetFieldTypeFromProperty(&Property));

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

procedure TORMDataSet.OpenClass<T>;
begin
  SetObjectType(TypeInfo(T));

  Open;
end;

procedure TORMDataSet.OpenList<T>(List: {$IFDEF PAS2JS}TObject{$ELSE}TList<T>{$ENDIF});
begin
  {$IFDEF PAS2JS}
  // It's necessary, to optimazer don't remove the "GetItem" of the param list!
  if False then
    TList<T>(List).First;
  {$ENDIF}

  FObjectList := TList<TObject>(List);

  SetObjectType(TypeInfo(T));

  SetUniDirectional(True);

  Open;

  SetUniDirectional(False);
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  ObjectList.Add(&Object);

  OpenList<T>(TList<T>(ObjectList));
end;

procedure TORMDataSet.ResetCurrentRecord;
begin
  FRecordNumber := -1;
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin

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

procedure TORMDataSet.SetObjectType(TypeInfo: PTypeInfo);
begin
  FObjectType := FContext.GetType(TypeInfo) as TRttiInstanceType;
end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType({$IFDEF PAS2JS}ftVariant{$ELSE}ftObject{$ENDIF});
end;

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('To open the DataSet, you must use the especialized procedures ou fill de ObjectClassName property!');
end;

end.

