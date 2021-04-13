unit Delphi.ORM.DataSet;

interface

uses System.Classes, Data.DB, System.Rtti, System.Generics.Collections, System.SysUtils, System.TypInfo;

type
  EDataSetNotInEditingState = class(Exception)
  public
    constructor Create;
  end;

  EDataSetWithoutObjectDefinition = class(Exception)
  public
    constructor Create;
  end;

  EPropertyNameDoesNotExist = class(Exception);
  EPropertyWithDifferentType = class(Exception);
  TORMFieldBuffer = {$IFDEF PAS2JS}TDataRecord{$ELSE}TValueBuffer{$ENDIF};
  TORMRecordBuffer = {$IFDEF PAS2JS}TDataRecord{$ELSE}TRecordBuffer{$ENDIF};
  TORMValueBuffer = {$IFDEF PAS2JS}JSValue{$ELSE}TValueBuffer{$ENDIF};

  TORMRecordInfo = class
  public
    ArrayPosition: Cardinal;
    CalculedFieldBuffer: TArray<TValue>;
  end;

  TORMObjectField = class(TField)
  private
{$IFDEF DCC}
    FBuffer: TORMValueBuffer;
{$ENDIF}
    function GetAsObject: TObject;

    procedure SetAsObject(const Value: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    property AsObject: TObject read GetAsObject write SetAsObject;
  end;

  IORMObjectIterator = interface
    function GetCurrentPosition: Cardinal;
    function GetObject(Index: Cardinal): TObject;
    function GetRecordCount: Integer;
    function Next: Boolean;
    function Prior: Boolean;

    procedure Add(Obj: TObject);
    procedure Clear;
    procedure Remove;
    procedure ResetBegin;
    procedure ResetEnd;
    procedure SetCurrentPosition(const Value: Cardinal);
    procedure UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);

    property CurrentPosition: Cardinal read GetCurrentPosition write SetCurrentPosition;
    property Objects[Index: Cardinal]: TObject read GetObject; default;
    property RecordCount: Integer read GetRecordCount;
  end;

  TORMListIterator<T: class> = class(TInterfacedObject, IORMObjectIterator)
  private
    FCurrentPosition: Cardinal;
    FInternalList: TList<T>;
    FList: TList<T>;

    function GetCurrentPosition: Cardinal;
    function GetObject(Index: Cardinal): TObject;
    function GetRecordCount: Integer;
    function Next: Boolean;
    function Prior: Boolean;

    procedure Add(Obj: TObject);
    procedure Clear;
    procedure Remove;
    procedure ResetBegin;
    procedure ResetEnd;
    procedure SetCurrentPosition(const Value: Cardinal);
    procedure UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);

    property CurrentPosition: Cardinal read GetCurrentPosition write SetCurrentPosition;
  public
    constructor Create(const Value: array of T); overload;
    constructor Create(const Value: TList<T>); overload;

    destructor Destroy; override;
  end;

{$IFDEF DCC}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TORMDataSet = class(TDataSet)
  private
    FIterator: IORMObjectIterator;
    FContext: TRttiContext;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiProperty>>;
    FInsertingObject: TObject;
    FOldValueObject: TObject;
    FParentDataSet: TORMDataSet;
    FDataSetFieldProperty: TRttiProperty;
    FCalculatedFields: TDictionary<TField, Integer>;

    function GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
    function GetFieldInfoFromTypeInfo(PropertyType: PTypeInfo; var Size: Integer): TFieldType;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectClass<T: class>: TClass;
    function GetObjectClassName: String;
    function GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
    function GetRecordInfoFromActiveBuffer: TORMRecordInfo;
    function GetRecordInfoFromBuffer(const Buffer: TORMRecordBuffer): TORMRecordInfo;

    procedure CheckCalculatedFields;
    procedure CheckIterator;
    procedure CheckObjectTypeLoaded;
    procedure GetPropertyValue(const &Property: TRttiProperty; const Instance: TValue; var Value: TValue);
    procedure LoadDetailInfo;
    procedure LoadFieldDefsFromClass;
    procedure LoadObjectListFromParentDataSet;
    procedure LoadPropertiesFromFields;
    procedure OpenInternalIterator(ObjectClass: TClass; Iterator: IORMObjectIterator);
    procedure ReleaseOldValueObject;
    procedure ReleaseThenInsertingObject;
    procedure SetObjectClassName(const Value: String);
    procedure SetObjectType(const Value: TRttiInstanceType);
    procedure UpdateParentObject;
  protected
    function AllocRecordBuffer: TORMRecordBuffer; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure DataEvent(Event: TDataEvent; Info: {$IFDEF PAS2JS}JSValue{$ELSE}NativeInt{$ENDIF}); override;
    procedure DoAfterOpen; override;
    procedure GetBookmarkData(Buffer: TORMRecordBuffer; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark); override;
    procedure FreeRecordBuffer(var Buffer: TORMRecordBuffer); override;
    procedure InternalCancel; override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalEdit; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    procedure InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF}; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMRecordBuffer); override;
    procedure InternalInsert; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalSetToRecord(Buffer: TORMRecordBuffer); override;
    procedure SetFieldData(Field: TField; Buffer: TORMValueBuffer); override;
    procedure SetDataSetField(const DataSetField: TDataSetField); override;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

{$IFDEF PAS2JS}
    function ConvertDateTimeToNative(Field: TField; Value: TDateTime): JSValue; override;
    function ConvertToDateTime(Field: TField; Value: JSValue; ARaiseException: Boolean): TDateTime; override;
{$ENDIF}
    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; {$IFDEF DCC}var {$ENDIF}Buffer: TORMFieldBuffer): {$IFDEF PAS2JS}JSValue{$ELSE}Boolean{$ENDIF}; override;

    procedure OpenArray<T: class>(List: TArray<T>);
    procedure OpenClass<T: class>;
    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);
    procedure OpenObjectArray(ObjectClass: TClass; List: TArray<TObject>);

    property ObjectType: TRttiInstanceType read FObjectType write SetObjectType;
    property ParentDataSet: TORMDataSet read FParentDataSet;
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
    property DataSetField;
    property ObjectClassName: String read GetObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

uses {$IFDEF PAS2JS}JS{$ELSE}System.SysConst{$ENDIF}, Delphi.ORM.Nullable, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy;

{ TORMListIterator<T> }

procedure TORMListIterator<T>.Add(Obj: TObject);
begin
  FCurrentPosition := Succ(FList.Add(T(Obj)));
end;

procedure TORMListIterator<T>.Clear;
begin
  FCurrentPosition := 0;

  FList.Clear;
end;

constructor TORMListIterator<T>.Create(const Value: TList<T>);
begin
  inherited Create;

  FList := Value;
end;

constructor TORMListIterator<T>.Create(const Value: array of T);
begin
  FInternalList := TList<T>.Create;

  FInternalList.AddRange(Value);

  Create(FInternalList);
end;

destructor TORMListIterator<T>.Destroy;
begin
  FInternalList.Free;

  inherited;
end;

function TORMListIterator<T>.GetCurrentPosition: Cardinal;
begin
  Result := FCurrentPosition;
end;

function TORMListIterator<T>.GetObject(Index: Cardinal): TObject;
begin
  Result := FList[Pred(Index)];
end;

function TORMListIterator<T>.GetRecordCount: Integer;
begin
  Result := FList.Count;
end;

function TORMListIterator<T>.Next: Boolean;
begin
  Result := FCurrentPosition < Cardinal(FList.Count);

  if Result then
    Inc(FCurrentPosition);
end;

function TORMListIterator<T>.Prior: Boolean;
begin
  Result := FCurrentPosition > 1;

  if Result then
    Dec(FCurrentPosition);
end;

procedure TORMListIterator<T>.Remove;
begin
  FList.Delete(Pred(CurrentPosition));
end;

procedure TORMListIterator<T>.ResetBegin;
begin
  FCurrentPosition := 0;
end;

procedure TORMListIterator<T>.ResetEnd;
begin
  FCurrentPosition := Succ(FList.Count);
end;

procedure TORMListIterator<T>.SetCurrentPosition(const Value: Cardinal);
begin
  FCurrentPosition := Value;
end;

procedure TORMListIterator<T>.UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);
var
  A: Integer;

  ValueArray: TValue;

begin
  ValueArray := &Property.GetValue(Instance);
  ValueArray.ArrayLength := FList.Count;

  for A := 0 to Pred(FList.Count) do
    ValueArray.ArrayElement[A] := TValue.From<T>(FList[A]);

  &Property.SetValue(Instance, ValueArray);
end;

{ TORMDataSet }

function TORMDataSet.AllocRecordBuffer: TORMRecordBuffer;
var
  NewRecordInfo: TORMRecordInfo;

begin
  NewRecordInfo := TORMRecordInfo.Create;
{$IFDEF PAS2JS}
  Result := inherited;
  Result.Data := NewRecordInfo;
{$ELSE}
  Result := TORMRecordBuffer(NewRecordInfo);
{$ENDIF}

  InternalInitRecord(Result);
end;

procedure TORMDataSet.CheckCalculatedFields;
var
  A: Integer;

begin
  FCalculatedFields.Clear;

  for A := 0 to Pred(Fields.Count) do
    if Fields[A].FieldKind = fkCalculated then
      FCalculatedFields.Add(Fields[A], FCalculatedFields.Count);
end;

procedure TORMDataSet.CheckIterator;
begin
  if not Assigned(FIterator) then
    FIterator := TORMListIterator<TObject>.Create([]);
end;

procedure TORMDataSet.CheckObjectTypeLoaded;
begin
  if not Assigned(ObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;
end;

{$IFDEF PAS2JS}
function TORMDataSet.ConvertDateTimeToNative(Field: TField; Value: TDateTime): JSValue;
begin
  Result := Value;
end;

function TORMDataSet.ConvertToDateTime(Field: TField; Value: JSValue; ARaiseException: Boolean): TDateTime;
begin
  Result := TDateTime(Value);
end;
{$ENDIF}

constructor TORMDataSet.Create(AOwner: TComponent);
begin
  inherited;

{$IFDEF DCC}
  BookmarkSize := SizeOf(TORMRecordInfo);
  ObjectView := True;
{$ENDIF}

  FCalculatedFields := TDictionary<TField, Integer>.Create;
  FContext := TRttiContext.Create;
end;

procedure TORMDataSet.DataEvent(Event: TDataEvent; Info: {$IFDEF PAS2JS}JSValue{$ELSE}NativeInt{$ENDIF});
begin
  inherited;

  if Event = deParentScroll then
  begin
    LoadObjectListFromParentDataSet;

    Resync([]);
  end;
end;

destructor TORMDataSet.Destroy;
begin
  FCalculatedFields.Free;

  ReleaseThenInsertingObject;

  inherited;
end;

procedure TORMDataSet.DoAfterOpen;
var
  A: Integer;

  NestedDataSet: TORMDataSet;

begin
  for A := 0 to Pred(NestedDataSets.Count) do
  begin
    NestedDataSet := TORMDataSet(NestedDataSets[A]);

    NestedDataSet.DataEvent(deParentScroll, 0);
  end;

  inherited;
end;

procedure TORMDataSet.FreeRecordBuffer(var Buffer: TORMRecordBuffer);
var
  RecordInfo: TORMRecordInfo;

begin
  RecordInfo := GetRecordInfoFromBuffer(Buffer);

  RecordInfo.Free;
end;

procedure TORMDataSet.GetBookmarkData(Buffer: TORMRecordBuffer; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark);
var
  RecordInfo: TORMRecordInfo;

begin
  RecordInfo := GetRecordInfoFromBuffer(Buffer);

{$IFDEF PAS2JS}Data.Data{$ELSE}PInteger(Data)^{$ENDIF} := RecordInfo.ArrayPosition;
end;

function TORMDataSet.GetCurrentObject<T>: T;
begin
  Result := nil;

  case State of
    dsInsert: Result := FInsertingObject as T;
    dsOldValue: Result := FOldValueObject as T;
    // dsInactive: ;
    // dsBrowse: ;
    // dsEdit: ;
    // dsSetKey: ;
    // dsCalcFields: ;
    // dsFilter: ;
    // dsNewValue: ;
    // dsCurValue: ;
    // dsBlockRead: ;
    // dsInternalCalc: ;
    // dsOpening: ;
    else
      if FIterator.RecordCount > 0 then
        Result := FIterator[GetRecordInfoFromActiveBuffer.ArrayPosition] as T;
  end;
end;

function TORMDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  if FieldType = ftVariant then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldType);
end;

function TORMDataSet.GetFieldData(Field: TField; {$IFDEF DCC}var {$ENDIF}Buffer: TORMFieldBuffer): {$IFDEF PAS2JS}JSValue{$ELSE}Boolean{$ENDIF};
var
  &Property: TRttiProperty;

  Value: TValue;

begin
  Result := {$IFDEF PAS2JS}NULL{$ELSE}False{$ENDIF};

  if Field.FieldKind = fkData then
  begin
    if GetPropertyAndObjectFromField(Field, Value, &Property) then
      GetPropertyValue(&Property, Value, Value);
  end
  else if not IsEmpty and (Field.FieldKind = fkCalculated) then
    Value := GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]];

  if not Value.IsEmpty then
  begin
{$IFDEF PAS2JS}
    Result := Value.AsJSValue;
{$ELSE}
    Result := True;

    if Assigned(Buffer) then
      if Field is TStringField then
      begin
        var StringData := Value.AsType<AnsiString>;
        var StringSize := Length(StringData);

        if StringSize > 0 then
          Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);

        Buffer[StringSize] := 0;
      end
      else if Field is TDateTimeField then
      begin
        var DataTimeValue: TORMValueBuffer;

        SetLength(DataTimeValue, SizeOf(Double));

        Value.ExtractRawData(@DataTimeValue[0]);

        DataConvert(Field, DataTimeValue, Buffer, True);
      end
      else
        Value.ExtractRawData(@Buffer[0]);
{$ENDIF}
  end;
end;

function TORMDataSet.GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
begin
  if IsNullableType(&Property.PropertyType) then
    Result := GetFieldInfoFromTypeInfo(GetNullableRttiType(&Property.PropertyType).Handle, Size)
  else if IsLazyLoading(&Property.PropertyType) then
    Result := GetFieldInfoFromTypeInfo(GetLazyLoadingRttiType(&Property.PropertyType).Handle, Size)
  else
    Result := GetFieldInfoFromTypeInfo(&Property.PropertyType.Handle, Size);
end;

function TORMDataSet.GetFieldInfoFromTypeInfo(PropertyType: PTypeInfo; var Size: Integer): TFieldType;
var
  PropertyKind: TTypeKind;

begin
  PropertyKind := {$IFDEF PAS2JS}TTypeInfo{$ENDIF}(PropertyType).Kind;
  Result := ftUnknown;
  Size := 0;

  case PropertyKind of
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
      if PropertyType = TypeInfo(Boolean) then
        Result := ftBoolean
      else
        Result := ftInteger;
    tkFloat:
      if PropertyType = TypeInfo(TDate) then
        Result := ftDate
      else if PropertyType = TypeInfo(TDateTime) then
        Result := ftDateTime
      else if PropertyType = TypeInfo(TTime) then
        Result := ftTime
      else
{$IFDEF DCC}
        case PropertyType.TypeData.FloatType of
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
      case PropertyType.TypeData.OrdType of
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
    tkDynArray: Result := ftDataSet;
  end;

  case PropertyKind of
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

function TORMDataSet.GetObjectClass<T>: TClass;
begin
  Result := {$IFDEF PAS2JS}(FContext.GetType(TypeInfo(T)) as TRttiInstanceType).MetaclassType{$ELSE}T{$ENDIF};
end;

function TORMDataSet.GetObjectClassName: String;
begin
  Result := EmptyStr;

  if Assigned(ObjectType) then
    Result := ObjectType.Name;
end;

function TORMDataSet.GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
var
  A: Integer;

  PropertyList: TArray<TRttiProperty>;

begin
  Instance := TValue.From(GetCurrentObject<TObject>);
  PropertyList := FPropertyMappingList[Field.Index];
  Result := True;

  for A := Low(PropertyList) to High(PropertyList) do
  begin
    if A > 0 then
      GetPropertyValue(&Property, Instance, Instance);

    &Property := PropertyList[A];

    if Instance.IsEmpty then
      Exit(False);
  end;
end;

procedure TORMDataSet.GetPropertyValue(const &Property: TRttiProperty; const Instance: TValue; var Value: TValue);
begin
  Value := &Property.GetValue(Instance.AsObject);

  if IsNullableType(&Property.PropertyType) then
    Value := GetNullableValue(&Property.PropertyType, Instance)
  else if IsLazyLoading(&Property.PropertyType) then
    Value := GetLazyLoadingAccess(Instance).GetValue;
end;

function TORMDataSet.GetRecNo: Integer;
begin
  Result := GetRecordInfoFromActiveBuffer.ArrayPosition
end;

function TORMDataSet.GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  Result := grOK;

  case GetMode of
    gmCurrent:
      if FIterator.CurrentPosition = 0 then
        Result := grError;
    gmNext:
      if not FIterator.Next then
        Result := grEOF;
    gmPrior:
      if not FIterator.Prior then
        Result := grBOF;
  end;

  if Result = grOK then
    GetRecordInfoFromBuffer(Buffer).ArrayPosition := FIterator.CurrentPosition;
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := FIterator.RecordCount;
end;

function TORMDataSet.GetRecordInfoFromActiveBuffer: TORMRecordInfo;
begin
  Result := GetRecordInfoFromBuffer(TORMRecordBuffer(ActiveBuffer));
end;

function TORMDataSet.GetRecordInfoFromBuffer(const Buffer: TORMRecordBuffer): TORMRecordInfo;
begin
  Result := TORMRecordInfo(Buffer{$IFDEF PAS2JS}.Data{$ENDIF});
end;

procedure TORMDataSet.InternalInitRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMRecordBuffer);
var
  RecordInfo: TORMRecordInfo;

begin
  RecordInfo := GetRecordInfoFromBuffer(Buffer);

  SetLength(RecordInfo.CalculedFieldBuffer, FCalculatedFields.Count);
end;

procedure TORMDataSet.InternalInsert;
begin
  inherited;

  if not Assigned(FInsertingObject) then
    FInsertingObject := ObjectType.MetaclassType.Create;
end;

procedure TORMDataSet.InternalCancel;
var
  &Property: TRttiProperty;

  CurrentObject: TObject;

begin
  if Assigned(FOldValueObject) then
  begin
    CurrentObject := GetCurrentObject<TObject>;

    for &Property in ObjectType.GetProperties do
      &Property.SetValue(CurrentObject, &Property.GetValue(FOldValueObject));

    ReleaseOldValueObject;
  end;

  ReleaseThenInsertingObject;
end;

procedure TORMDataSet.InternalClose;
begin
  FIterator := nil;

  BindFields(False);
end;

procedure TORMDataSet.InternalDelete;
begin
  FIterator.Remove;

  UpdateParentObject;
end;

procedure TORMDataSet.InternalEdit;
var
  &Property: TRttiProperty;

  CurrentObject: TObject;

begin
  inherited;

  CurrentObject := GetCurrentObject<TObject>;

  if not Assigned(FOldValueObject) then
    FOldValueObject := ObjectType.MetaclassType.Create;

  for &Property in ObjectType.GetProperties do
    &Property.SetValue(FOldValueObject, &Property.GetValue(CurrentObject));
end;

procedure TORMDataSet.InternalFirst;
begin
  FIterator.ResetBegin;
end;

procedure TORMDataSet.InternalGotoBookmark(Bookmark: TBookmark);
{$IFDEF DCC}
var
  RecordIndex: PInteger absolute Bookmark;

{$ENDIF}
begin
{$IFDEF PAS2JS}
  raise Exception.Create('Not implemented the bookmark control!');
{$ELSE}
  FIterator.CurrentPosition := RecordIndex^;
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
  FIterator.ResetEnd;
end;

procedure TORMDataSet.InternalOpen;
begin
  CheckIterator;

  LoadDetailInfo;

  if FieldDefs.Count = 0 then
    if FieldCount = 0 then
      LoadFieldDefsFromClass
    else
      InitFieldDefsFromFields;

  if FieldCount = 0 then
    CreateFields;

  LoadPropertiesFromFields;

  BindFields(True);

  CheckCalculatedFields;

  LoadObjectListFromParentDataSet;
end;

procedure TORMDataSet.InternalPost;
begin
  inherited;

  if State = dsInsert then
  begin
    FIterator.Add(FInsertingObject);

    UpdateParentObject;
  end;

  FInsertingObject := nil;

  ReleaseOldValueObject;
end;

procedure TORMDataSet.InternalSetToRecord(Buffer: TORMRecordBuffer);
begin
  FIterator.CurrentPosition := GetRecordInfoFromBuffer(Buffer).ArrayPosition;
end;

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FIterator);
end;

procedure TORMDataSet.LoadDetailInfo;
var
  Properties: TArray<TRttiProperty>;

begin
  if Assigned(ParentDataSet) then
  begin
    Properties := ParentDataSet.FPropertyMappingList[Pred(DataSetField.FieldNo)];

    FDataSetFieldProperty := Properties[High(Properties)];
    ObjectType := (FDataSetFieldProperty.PropertyType as TRttiDynamicArrayType).ElementType as TRttiInstanceType;
  end;
end;

procedure TORMDataSet.LoadFieldDefsFromClass;
var
  &Property: TRttiProperty;

  FieldType: TFieldType;

  Size: Integer;

begin
  CheckObjectTypeLoaded;

  for &Property in ObjectType.GetProperties do
    if &Property.Visibility = mvPublished then
    begin
      FieldType := GetFieldInfoFromProperty(&Property, Size);

      FieldDefs.Add(&Property.Name, FieldType, Size);
    end;
end;

procedure TORMDataSet.LoadObjectListFromParentDataSet;
var
  A: Integer;

  Value: TValue;

  &Property: TRttiProperty;

begin
  if Assigned(ParentDataSet) and not ParentDataSet.IsEmpty then
  begin
    Value := TValue.From(ParentDataSet.GetCurrentObject<TObject>);

    FIterator.Clear;

    if ParentDataSet.GetPropertyAndObjectFromField(DataSetField, Value, &Property) then
    begin
      Value := &Property.GetValue(Value.AsObject);

      for A := 0 to Pred(Value.GetArrayLength) do
        FIterator.Add(Value.GetArrayElement(A).AsObject);

      FIterator.ResetBegin;
    end;
  end;
end;

procedure TORMDataSet.LoadPropertiesFromFields;
var
  A: Integer;

  Field: TField;

  CurrentObjectType: TRttiInstanceType;

  &Property: TRttiProperty;

  PropertyList: TArray<TRttiProperty>;

  PropertyName: String;

begin
  CheckObjectTypeLoaded;

  SetLength(FPropertyMappingList, Fields.Count);

  for A := 0 to Pred(Fields.Count) do
  begin
    Field := Fields[A];

    if Field.FieldKind = fkData then
    begin
      CurrentObjectType := ObjectType;
      &Property := nil;
      PropertyList := nil;
      PropertyName := EmptyStr;

      for PropertyName in Field.FieldName.Split(['.']) do
      begin
        &Property := CurrentObjectType.GetProperty(PropertyName);

        if not Assigned(&Property) then
          raise EPropertyNameDoesNotExist.CreateFmt('The property %s not found in the current object!', [PropertyName]);

        PropertyList := PropertyList + [&Property];

        if &Property.PropertyType.IsInstance then
          CurrentObjectType := &Property.PropertyType as TRttiInstanceType
        else if IsLazyLoading(&Property.PropertyType) then
          CurrentObjectType := GetLazyLoadingRttiType(&Property.PropertyType) as TRttiInstanceType;
      end;

{$IFDEF DCC}
      if GetFieldTypeFromProperty(&Property) <> Field.DataType then
        raise EPropertyWithDifferentType.CreateFmt('The field %s as type %s and the expected field type is %s!', [Field.FieldName, TRttiEnumerationType.GetName(Field.DataType),
          TRttiEnumerationType.GetName(GetFieldTypeFromProperty(&Property))]);
{$ENDIF}

      FPropertyMappingList[Field.Index] := PropertyList;
    end;
  end;
end;

procedure TORMDataSet.OpenArray<T>(List: TArray<T>);
begin
  OpenInternalIterator(GetObjectClass<T>, TORMListIterator<T>.Create(List));
end;

procedure TORMDataSet.OpenClass<T>;
begin
  OpenArray<T>(nil);
end;

procedure TORMDataSet.OpenInternalIterator(ObjectClass: TClass; Iterator: IORMObjectIterator);
begin
  FIterator := Iterator;
  ObjectType := FContext.GetType(ObjectClass) as TRttiInstanceType;

  Open;
end;

procedure TORMDataSet.OpenList<T>(List: TList<T>);
begin
  OpenInternalIterator(GetObjectClass<T>, TORMListIterator<T>.Create(List));
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  OpenArray<T>([&Object]);
end;

procedure TORMDataSet.OpenObjectArray(ObjectClass: TClass; List: TArray<TObject>);
begin
  OpenInternalIterator(ObjectClass, TORMListIterator<TObject>.Create(List));
end;

procedure TORMDataSet.ReleaseOldValueObject;
begin
  FreeAndNil(FOldValueObject);
end;

procedure TORMDataSet.ReleaseThenInsertingObject;
begin
  FreeAndNil(FInsertingObject);
end;

procedure TORMDataSet.SetDataSetField(const DataSetField: TDataSetField);
begin
  if Assigned(DataSetField) then
    FParentDataSet := DataSetField.DataSet as TORMDataSet
  else
    FParentDataSet := nil;

  inherited;
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TORMValueBuffer);
var
  Instance: TValue;

  &Property: TRttiProperty;

{$IFDEF DCC}
  Value: TValue;
{$ELSE}
  Value: JSValue absolute Buffer;
{$ENDIF}
begin
  if not (State in dsWriteModes) then
    raise EDataSetNotInEditingState.Create;

{$IFDEF DCC}
  Value := TValue.Empty;

  if Assigned(Buffer) then
    case Field.DataType of
      ftByte,
      ftInteger,
      ftWord: Value := TValue.From(PInteger(Buffer)^);
      ftString: Value := TValue.From(String(AnsiString(PAnsiChar(Buffer))));
      ftBoolean: Value := TValue.From(PWordBool(Buffer)^);
      ftDate,
      ftDateTime,
      ftTime:
      begin
        var DataTimeValue: TORMValueBuffer;

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
      ftVariant: Value := TValue.From(TObject(PNativeInt(Buffer)^));
    end;
{$ENDIF}

  if Field.FieldKind = fkData then
  begin
    GetPropertyAndObjectFromField(Field, Instance, &Property);

{$IFDEF DCC}
    if &Property.PropertyType is TRttiEnumerationType then
      Value := TValue.FromOrdinal(&Property.PropertyType.Handle, Value.AsOrdinal);
{$ENDIF}

    if IsNullableType(&Property.PropertyType) then
      SetNullableValue(&Property.PropertyType, &Property.GetValue(Instance.AsObject), Value)
    else if IsLazyLoading(&Property.PropertyType) then
      GetLazyLoadingAccess(&Property.GetValue(Instance.AsObject)).SetValue({$IFDEF PAS2JS}TValue.FromJSValue{$ENDIF}(Value))
    else
      &Property.SetValue(Instance.AsObject, Value);
  end
  else if Field.FieldKind = fkCalculated then
    GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]] := {$IFDEF PAS2JS}TValue.FromJSValue{$ENDIF}(Value);

  DataEvent(deFieldChange, {$IFDEF DCC}IntPtr{$ENDIF}(Field));
end;

procedure TORMDataSet.SetObjectClassName(const Value: String);
begin
  ObjectType := nil;

{$IFDEF DCC}
  for var &Type in FContext.GetTypes do
    if (&Type.Name = Value) or (&Type.QualifiedName = Value) then
      ObjectType := &Type as TRttiInstanceType;
{$ENDIF}
end;

procedure TORMDataSet.SetObjectType(const Value: TRttiInstanceType);
begin
  CheckInactive;

  FObjectType := Value;
end;

procedure TORMDataSet.UpdateParentObject;
begin
  if Assigned(DataSetField) then
    FIterator.UpdateArrayProperty(FDataSetFieldProperty, ParentDataSet.GetCurrentObject<TObject>);
end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftVariant);

{$IFDEF DCC}
  SetLength(FBuffer, SizeOf(TObject));
{$ENDIF}
end;

function TORMObjectField.GetAsObject: TObject;
begin
{$IFDEF DCC}
  if GetData(FBuffer, True) then
    Result := TObject(PNativeInt(FBuffer)^)
  else
    Result := nil;
{$ELSE}
  Result := TObject(GetData);
{$ENDIF}
end;

procedure TORMObjectField.SetAsObject(const Value: TObject);
begin
{$IFDEF DCC}
  Move(NativeInt(Value), FBuffer[0], SizeOf(Value));

  SetData(FBuffer);
{$ELSE}
  SetData(Value);
{$ENDIF}
end;

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('To open the DataSet, you must use the especialized procedures ou fill de ObjectClassName property!');
end;

{ EDataSetNotInEditingState }

constructor EDataSetNotInEditingState.Create;
begin
  inherited Create('Dataset not in edit or insert mode');
end;

end.

