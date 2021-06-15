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
  ESelfFieldDifferentObjectType = class(Exception);
  ESelfFieldNotAllowEmptyValue = class(Exception);
  ESelfFieldTypeWrong = class(Exception);
  TORMCalcFieldBuffer = {$IFDEF PAS2JS}TDataRecord{$ELSE}TRecBuf{$ENDIF};
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
    procedure Resync;
    procedure SetCurrentPosition(const Value: Cardinal);
    procedure SetObject(Index: Cardinal; const Value: TObject);
    procedure Swap(Left, Right: Cardinal);
    procedure UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);

    property CurrentPosition: Cardinal read GetCurrentPosition write SetCurrentPosition;
    property Objects[Index: Cardinal]: TObject read GetObject write SetObject; default;
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
    procedure Resync;
    procedure SetCurrentPosition(const Value: Cardinal);
    procedure SetObject(Index: Cardinal; const Value: TObject);
    procedure Swap(Left, Right: Cardinal);
    procedure UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);

    property CurrentPosition: Cardinal read GetCurrentPosition write SetCurrentPosition;
  public
    constructor Create(const Value: array of T); overload;
    constructor Create(const Value: TList<T>); overload;

    destructor Destroy; override;

    property Objects[Index: Cardinal]: TObject read GetObject write SetObject; default;
  end;

{$IFDEF DCC}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TORMDataSet = class(TDataSet)
  private
    FIterator: IORMObjectIterator;
    FIteratorData: IORMObjectIterator;
    FIteratorFilter: IORMObjectIterator;
    FContext: TRttiContext;
    FObjectType: TRttiInstanceType;
    FPropertyMappingList: TArray<TArray<TRttiProperty>>;
    FInsertingObject: TObject;
    FOldValueObject: TObject;
    FParentDataSet: TORMDataSet;
    FCalculatedFields: TDictionary<TField, Integer>;
    FIndexFieldNames: String;
    FFilterFunction: TFunc<TORMDataSet, Boolean>;

    function GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
    function GetFieldInfoFromTypeInfo(PropertyType: PTypeInfo; var Size: Integer): TFieldType;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectClass<T: class>: TClass;
    function GetObjectClassName: String;
    function GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
    function GetRecordInfoFromActiveBuffer: TORMRecordInfo;
    function GetRecordInfoFromBuffer(const Buffer: TORMRecordBuffer): TORMRecordInfo;
    function GetCurrentActiveBuffer: TORMRecordBuffer;
    function GetObjectAndPropertyFromParentDataSet(var Instance: TValue; var &Property: TRttiProperty): Boolean;
    function IsSelfField(Field: TField): Boolean;

    procedure CheckCalculatedFields;
    procedure CheckIterator;
    procedure CheckIteratorData(const NeedResync, GoFirstRecord: Boolean);
    procedure CheckObjectTypeLoaded;
    procedure CheckSelfFieldType;
    procedure GetPropertyValue(const &Property: TRttiProperty; var Instance: TValue);
    procedure GoToPosition(const Position: Cardinal; const CalculateFields: Boolean);
    procedure InternalCalculateFields(const Buffer: TORMRecordBuffer);
    procedure InternalFilter(const NeedResync: Boolean);
    procedure LoadDetailInfo;
    procedure LoadFieldDefsFromClass;
    procedure LoadObjectListFromParentDataSet;
    procedure LoadPropertiesFromFields;
    procedure OpenInternalIterator(ObjectClass: TClass; Iterator: IORMObjectIterator);
    procedure ReleaseOldValueObject;
    procedure ReleaseTheInsertingObject;
    procedure ResetFilter;
    procedure SetCurrentObject(const NewObject: TObject);
    procedure SetIndexFieldNames(const Value: String);
    procedure SetObjectClassName(const Value: String);
    procedure SetObjectType(const Value: TRttiInstanceType);
    procedure Sort;
    procedure UpdateArrayPosition(const Buffer: TORMRecordBuffer);
    procedure UpdateParentObject;

{$IFDEF PAS2JS}
    procedure GetLazyDisplayText(Sender: TField; var Text: String; DisplayText: Boolean);
    procedure LoadLazyGetTextFields;
{$ENDIF}
  protected
    function AllocRecordBuffer: TORMRecordBuffer; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    function GetInternalCurrentObject: TObject;
    function IsCursorOpen: Boolean; override;

    procedure ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMCalcFieldBuffer); override;
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

    procedure Filter(Func: TFunc<TORMDataSet, Boolean>);
    procedure OpenArray<T: class>(List: TArray<T>);
    procedure OpenClass<T: class>;
    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);
    procedure OpenObjectArray(ObjectClass: TClass; List: TArray<TObject>);
    procedure Resync(Mode: TResyncMode); override;

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
    property IndexFieldNames: String read FIndexFieldNames write SetIndexFieldNames;
    property ObjectClassName: String read GetObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

  TORMIndexField = record
  public
    Ascending: Boolean;
    Field: TField;
  end;

implementation

uses Delphi.ORM.Nullable, System.Math, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy, {$IFDEF PAS2JS}JS{$ELSE}System.SysConst{$ENDIF};

const
  SELF_FIELD_NAME = 'Self';

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

  Resync;
end;

procedure TORMListIterator<T>.ResetBegin;
begin
  FCurrentPosition := 0;
end;

procedure TORMListIterator<T>.ResetEnd;
begin
  FCurrentPosition := Succ(FList.Count);
end;

procedure TORMListIterator<T>.Resync;
begin
  FCurrentPosition := Min(FCurrentPosition, GetRecordCount);
end;

procedure TORMListIterator<T>.SetCurrentPosition(const Value: Cardinal);
begin
  FCurrentPosition := Value;
end;

procedure TORMListIterator<T>.SetObject(Index: Cardinal; const Value: TObject);
begin
  FList[Pred(Index)] := T(Value);
end;

procedure TORMListIterator<T>.Swap(Left, Right: Cardinal);
var
  Obj: TObject;

begin
  if Left <> Right then
  begin
    Obj := Objects[Left];

    Objects[Left] := Objects[Right];

    Objects[Right] := Obj;
  end;
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
  if not Assigned(FIteratorData) then
    FIteratorData := TORMListIterator<TObject>.Create([]);

  FIterator := FIteratorData;
end;

procedure TORMDataSet.CheckIteratorData(const NeedResync, GoFirstRecord: Boolean);
begin
  if Assigned(FFilterFunction) then
    InternalFilter(NeedResync);

  if not IndexFieldNames.IsEmpty then
    Sort;

  if GoFirstRecord and (Assigned(FFilterFunction) or not IndexFieldNames.IsEmpty) then
    First;
end;

procedure TORMDataSet.CheckObjectTypeLoaded;
begin
  if not Assigned(ObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;
end;

procedure TORMDataSet.CheckSelfFieldType;
var
  Field: TField;

begin
  Field := FindField(SELF_FIELD_NAME);

  if Assigned(Field) and (Field.DataType <> ftVariant) then
    raise ESelfFieldTypeWrong.Create('The Self field must be of the variant type!');
end;

procedure TORMDataSet.ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TORMCalcFieldBuffer);
var
  A: Integer;

  CalcBuffer: TArray<TValue>;

begin
  CalcBuffer := GetRecordInfoFromActiveBuffer.CalculedFieldBuffer;

  for A := Low(CalcBuffer) to High(CalcBuffer) do
    CalcBuffer[A] := TValue.Empty;
end;

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

  ReleaseTheInsertingObject;

  inherited;
end;

procedure TORMDataSet.DoAfterOpen;
var
  A: Integer;

  NestedDataSet: TORMDataSet;

begin
  CheckIteratorData(True, True);

  for A := 0 to Pred(NestedDataSets.Count) do
  begin
    NestedDataSet := TORMDataSet(NestedDataSets[A]);

    NestedDataSet.DataEvent(deParentScroll, 0);
  end;

  inherited;
end;

procedure TORMDataSet.Filter(Func: TFunc<TORMDataSet, Boolean>);
begin
  FFilterFunction := Func;

  ResetFilter;

  if Active then
    Resync([]);
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

function TORMDataSet.GetCurrentActiveBuffer: TORMRecordBuffer;
begin
  case State of
    // dsInsert:;
    // dsOldValue:;
    // dsInactive: ;
    // dsBrowse: ;
    // dsEdit: ;
    // dsSetKey: ;
     dsCalcFields: Result := TORMRecordBuffer(CalcBuffer);
    // dsFilter: ;
    // dsNewValue: ;
    // dsCurValue: ;
    // dsBlockRead: ;
    // dsInternalCalc: ;
    // dsOpening: ;
    else Result := TORMRecordBuffer(ActiveBuffer);
  end;
end;

function TORMDataSet.GetCurrentObject<T>: T;
begin
  Result := GetInternalCurrentObject as T;
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

  if IsSelfField(Field) then
    Value := TValue.From(GetInternalCurrentObject)
  else if Field.FieldKind = fkData then
  begin
    if GetPropertyAndObjectFromField(Field, Value, &Property) then
      GetPropertyValue(&Property, Value);
  end
  else if Field.FieldKind = fkCalculated then
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

function TORMDataSet.GetInternalCurrentObject: TObject;
begin
  Result := nil;

  case State of
    dsInsert: Result := FInsertingObject;
    dsOldValue: Result := FOldValueObject;
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
        Result := FIterator[GetRecordInfoFromActiveBuffer.ArrayPosition];
  end;
end;

procedure Filter(Func: TFunc<TORMDataSet, Boolean>);
begin

end;

function TORMDataSet.GetObjectAndPropertyFromParentDataSet(var Instance: TValue; var &Property: TRttiProperty): Boolean;
begin
  Result := Assigned(ParentDataSet) and not ParentDataSet.IsEmpty;

  if Result then
  begin
    Instance := TValue.From(ParentDataSet.GetInternalCurrentObject);

    Result := ParentDataSet.GetPropertyAndObjectFromField(DataSetField, Instance, &Property);
  end;
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
  Instance := TValue.From(GetInternalCurrentObject);
  PropertyList := FPropertyMappingList[Field.Index];
  Result := True;

  for A := Low(PropertyList) to High(PropertyList) do
  begin
    if A > 0 then
      GetPropertyValue(&Property, Instance);

    &Property := PropertyList[A];

    if Instance.IsEmpty then
      Exit(False);
  end;
end;

procedure TORMDataSet.GetPropertyValue(const &Property: TRttiProperty; var Instance: TValue);
begin
  Instance := &Property.GetValue(Instance.AsObject);

  if IsNullableType(&Property.PropertyType) then
    Instance := GetNullableAccess(Instance).GetValue
  else if IsLazyLoading(&Property.PropertyType) then
    Instance := GetLazyLoadingAccess(Instance).GetValue;
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
  begin
    UpdateArrayPosition(Buffer);

    InternalCalculateFields(Buffer);
  end;
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := FIterator.RecordCount;
end;

function TORMDataSet.GetRecordInfoFromActiveBuffer: TORMRecordInfo;
begin
  Result := GetRecordInfoFromBuffer(GetCurrentActiveBuffer);
end;

function TORMDataSet.GetRecordInfoFromBuffer(const Buffer: TORMRecordBuffer): TORMRecordInfo;
begin
  Result := TORMRecordInfo(Buffer{$IFDEF PAS2JS}.Data{$ENDIF});
end;

procedure TORMDataSet.InternalCalculateFields(const Buffer: TORMRecordBuffer);
var
  ORMBuffer: TORMCalcFieldBuffer absolute Buffer;

begin
  GetCalcFields(ORMBuffer);
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
    CurrentObject := GetInternalCurrentObject;

    for &Property in ObjectType.GetProperties do
      &Property.SetValue(CurrentObject, &Property.GetValue(FOldValueObject));

    ReleaseOldValueObject;
  end;

  ReleaseTheInsertingObject;
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

  CurrentObject := GetInternalCurrentObject;

  if not Assigned(FOldValueObject) then
    FOldValueObject := ObjectType.MetaclassType.Create;

  for &Property in ObjectType.GetProperties do
    &Property.SetValue(FOldValueObject, &Property.GetValue(CurrentObject));
end;

procedure TORMDataSet.InternalFilter(const NeedResync: Boolean);
begin
  if Active then
  begin
    ResetFilter;

    if Assigned(FFilterFunction) then
    begin
      FIteratorFilter := TORMListIterator<TObject>.Create([]);

      FIteratorData.ResetBegin;

      while FIteratorData.Next do
      begin
        GoToPosition(FIteratorData.CurrentPosition, True);

        if FFilterFunction(Self) then
          FIteratorFilter.Add(FIteratorData[FIteratorData.CurrentPosition]);
      end;

      FIterator := FIteratorFilter;
    end
    else
      FIteratorFilter := nil;

    if NeedResync then
      Resync([]);
  end;
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

  CheckSelfFieldType;

  LoadPropertiesFromFields;

{$IFDEF PAS2JS}
  LoadLazyGetTextFields;
{$ENDIF}

  BindFields(True);

  CheckCalculatedFields;

  LoadObjectListFromParentDataSet;
end;

procedure TORMDataSet.InternalPost;
begin
  inherited;

  if State = dsInsert then
  begin
    FIteratorData.Add(FInsertingObject);

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

function TORMDataSet.IsSelfField(Field: TField): Boolean;
begin
  Result := Field.FieldName = SELF_FIELD_NAME;
end;

procedure TORMDataSet.GoToPosition(const Position: Cardinal; const CalculateFields: Boolean);
begin
  FIterator.CurrentPosition := Position;

  UpdateArrayPosition(GetCurrentActiveBuffer);

  if CalculateFields then
    InternalCalculateFields(GetCurrentActiveBuffer);
end;

procedure TORMDataSet.LoadDetailInfo;
var
  Properties: TArray<TRttiProperty>;

begin
  if Assigned(ParentDataSet) then
  begin
    Properties := ParentDataSet.FPropertyMappingList[Pred(DataSetField.FieldNo)];

    ObjectType := (Properties[High(Properties)].PropertyType as TRttiDynamicArrayType).ElementType as TRttiInstanceType;
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

  FieldDefs.Add(SELF_FIELD_NAME, ftVariant, 0);
end;

procedure TORMDataSet.LoadObjectListFromParentDataSet;
var
  A: Integer;

  Value: TValue;

  &Property: TRttiProperty;

begin
  if GetObjectAndPropertyFromParentDataSet(Value, &Property) then
  begin
    FIterator.Clear;

    Value := &Property.GetValue(Value.AsObject);

    for A := 0 to Pred(Value.GetArrayLength) do
      FIterator.Add(Value.GetArrayElement(A).AsObject);

    FIterator.ResetBegin;
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

    if (Field.FieldKind = fkData) and not IsSelfField(Field) then
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
  FIteratorData := Iterator;
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

procedure TORMDataSet.ReleaseTheInsertingObject;
begin
  FreeAndNil(FInsertingObject);
end;

procedure TORMDataSet.ResetFilter;
begin
  FIterator := FIteratorData;
end;

procedure TORMDataSet.Resync(Mode: TResyncMode);
begin
  FIteratorData.Resync;

  CheckIteratorData(False, False);

  inherited;
end;

procedure TORMDataSet.SetCurrentObject(const NewObject: TObject);
begin
  if not Assigned(NewObject) then
    raise ESelfFieldNotAllowEmptyValue.Create('Empty value isn''t allowed in Self field!')
  else if NewObject.ClassType <> FObjectType.MetaclassType then
    raise ESelfFieldDifferentObjectType.Create('Can''t fill the Self field with an object with different type!');

  case State of
    dsInsert:
    begin
      ReleaseTheInsertingObject;

      FInsertingObject := NewObject;
    end;
    // dsOldValue: ;
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
      FIterator[GetRecordInfoFromActiveBuffer.ArrayPosition] := NewObject;
  end;
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

  Value: TValue;

begin
  if not (State in dsWriteModes) then
    raise EDataSetNotInEditingState.Create;

  Value := TValue.Empty;

  if Assigned(Buffer) then
    case Field.DataType of
{$IFDEF DCC}
      ftByte,
      ftWord,
{$ENDIF}
      ftInteger: Value := TValue.From({$IFDEF PAS2JS}Integer(Buffer){$ELSE}PInteger(Buffer)^{$ENDIF});
      ftString: Value := TValue.From({$IFDEF PAS2JS}String(Buffer){$ELSE}String(AnsiString(PAnsiChar(Buffer))){$ENDIF});
      ftBoolean: Value := TValue.From({$IFDEF PAS2JS}Boolean(Buffer){$ELSE}PWordBool(Buffer)^{$ENDIF});
      ftDate,
      ftDateTime,
      ftTime:
{$IFDEF PAS2JS}
        Value := TValue.From(TDateTime(Buffer));
{$ELSE}
      begin
        var DataTimeValue: TORMValueBuffer;

        SetLength(DataTimeValue, SizeOf(Double));

        DataConvert(Field, Buffer, DataTimeValue, False);

        Value := TValue.From(PDouble(DataTimeValue)^);
      end;
{$ENDIF}
{$IFDEF DCC}
      TFieldType.ftSingle: Value := TValue.From(PSingle(Buffer)^);

      TFieldType.ftExtended: Value := TValue.From(PExtended(Buffer)^);

      ftLongWord: Value := TValue.From(PCardinal(Buffer)^);

      ftWideString: Value := TValue.From(String(PWideChar(Buffer)));

      ftCurrency,
{$ENDIF}
      ftFloat: Value := TValue.From({$IFDEF PAS2JS}Double(Buffer){$ELSE}PDouble(Buffer)^{$ENDIF});

      ftLargeint: Value := TValue.From({$IFDEF PAS2JS}Int64(Buffer){$ELSE}PInt64(Buffer)^{$ENDIF});

      ftVariant: Value := TValue.From({$IFDEF PAS2JS}TObject(Buffer){$ELSE}TObject(PNativeInt(Buffer)^){$ENDIF});
    end;

  if IsSelfField(Field) then
    SetCurrentObject(Value.AsObject)
  else if Field.FieldKind = fkData then
  begin
    GetPropertyAndObjectFromField(Field, Instance, &Property);

{$IFDEF DCC}
    if &Property.PropertyType is TRttiEnumerationType then
      Value := TValue.FromOrdinal(&Property.PropertyType.Handle, Value.AsOrdinal);
{$ENDIF}

    if IsNullableType(&Property.PropertyType) then
      GetNullableAccess(&Property.GetValue(Instance.AsObject)).SetValue(Value)
    else if IsLazyLoading(&Property.PropertyType) then
      GetLazyLoadingAccess(&Property.GetValue(Instance.AsObject)).SetValue(Value)
    else
      &Property.SetValue(Instance.AsObject, Value);
  end
  else if Field.FieldKind = fkCalculated then
    GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]] := Value;

  if not (State in [dsCalcFields, dsInternalCalc, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, {$IFDEF DCC}IntPtr{$ENDIF}(Field));
end;

procedure TORMDataSet.SetIndexFieldNames(const Value: String);
begin
  if FIndexFieldNames <> Value then
  begin
    FIndexFieldNames := Value;

    if Active then
      Resync([]);
  end;
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

procedure TORMDataSet.Sort;
var
  A: Integer;

  IndexFields: TArray<TORMIndexField>;

  Pivot, Values: TArray<TValue>;

  FieldName: String;

  FieldNames: TArray<String>;

  NeedCalcFiels: Boolean;

  procedure GetValues(Position: Cardinal; var Values: TArray<TValue>);
  var
    A: Integer;

    Field: TField;

  begin
    GoToPosition(Position, NeedCalcFiels);

    for A := Low(IndexFields) to High(IndexFields) do
    begin
      Field := IndexFields[A].Field;

      if Field.IsNull then
        Values[A] := TValue.Empty
      else
        Values[A] := TValue.{$IFDEF PAS2JS}FromJSValue{$ELSE}FromVariant{$ENDIF}(Field.Value);
    end;
  end;

  function CompareValue(const Left, Right: TArray<TValue>): Boolean;
  var
    A: Integer;

    LeftValue, RightValue: TValue;

  begin
    Result := True;

    for A := Low(IndexFields) to High(IndexFields) do
    begin
      if IndexFields[A].Ascending then
      begin
        LeftValue := Left[A];
        RightValue := Right[A];
      end
      else
      begin
        LeftValue := Right[A];
        RightValue := Left[A];
      end;

      case Left[A].Kind of
{$IFDEF PAS2JS}
        tkBool,
{$ENDIF}
{$IFDEF DCC}
        tkInt64,
{$ENDIF}
        tkInteger,
        tkEnumeration:
          if RightValue.AsInteger < LeftValue.AsInteger then
            Exit(False);

{$IFDEF DCC}
        tkWChar,
        tkLString,
        tkWString,
        tkUString,
{$ENDIF}
        tkChar,
        tkString:
          if CompareStr(RightValue.AsString, LeftValue.AsString) < 0 then
            Exit(False);

        tkFloat:
          if RightValue.AsExtended < LeftValue.AsExtended then
            Exit(False);
      end;
    end;
  end;

  function Partition(Low, High: Cardinal): Cardinal;
  var
    A: Cardinal;

  begin
    Result := Pred(Low);

    GetValues(High, Pivot);

    for A := Low to Pred(High) do
    begin
      GetValues(A, Values);

      if CompareValue(Values, Pivot) then
      begin
        Inc(Result);

        FIterator.Swap(Result, A);
      end;
    end;

    Inc(Result);

    FIterator.Swap(Result, High);
  end;

  procedure QuickSort(Low, High: Cardinal);
  var
    Middle: Cardinal;

  begin
    if Low < High then
    begin
      Middle := Partition(Low, High);

      QuickSort(Low, Pred(Middle));

      QuickSort(Succ(Middle), High);
    end;
  end;

begin
  if not IndexFieldNames.IsEmpty then
  begin
    FieldNames := IndexFieldNames.Split([';']);
    NeedCalcFiels := False;

    SetLength(IndexFields, Length(FieldNames));

    for A := Low(FieldNames) to High(FieldNames) do
    begin
      FieldName := FieldNames[A];
      IndexFields[A].Ascending := FieldName[1] <> '-';

      if not IndexFields[A].Ascending then
        FieldName := FieldName.Substring(1);

      IndexFields[A].Field := FieldByName(FieldName);
      NeedCalcFiels := NeedCalcFiels or (IndexFields[A].Field.FieldKind = fkCalculated);
    end;

    SetLength(Pivot, Length(IndexFields));

    SetLength(Values, Length(IndexFields));

    QuickSort(1, FIterator.RecordCount);
  end;
end;

procedure TORMDataSet.UpdateArrayPosition(const Buffer: TORMRecordBuffer);
begin
  GetRecordInfoFromBuffer(Buffer).ArrayPosition := FIterator.CurrentPosition;
end;

procedure TORMDataSet.UpdateParentObject;
var
  Instance: TValue;

  &Property: TRttiProperty;

begin
  if Assigned(DataSetField) then
  begin
    GetObjectAndPropertyFromParentDataSet(Instance, &Property);

    FIterator.UpdateArrayProperty(&Property, Instance.AsObject);
  end;
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

type
  TFieldHack = class(TField)
  end;

procedure TORMDataSet.GetLazyDisplayText(Sender: TField; var Text: String; DisplayText: Boolean);
var
  &Property: TRttiProperty;

  Value: TValue;

  LazyAccess: TLazyAccessType;

  CurrentRecord: Integer;

begin
  if DisplayText then
  begin
    Value := TValue.From(GetInternalCurrentObject);

    for &Property in FPropertyMappingList[Sender.Index] do
      if Value.IsEmpty then
        Break
      else
      begin
        Value := &Property.GetValue(Value.AsObject);

        if IsLazyLoading(&Property.PropertyType) then
        begin
          LazyAccess := GetLazyLoadingAccess(Value);

          if LazyAccess.Loaded then
            Value := LazyAccess.GetValue
          else
          begin
            CurrentRecord := ActiveRecord;
            Text := 'Loading....';

            LazyAccess.GetValueAsync._then(
              function(Value: JSValue): JSValue
              begin
                DataEvent(deRecordChange, CurrentRecord);
              end);

            Exit;
          end;
        end;
      end;
  end;

  TFieldHack(Sender).GetText(Text, DisplayText);
end;

procedure TORMDataSet.LoadLazyGetTextFields;
var
  Field: TField;

  &Property: TRttiProperty;

begin
  for Field in Fields do
    for &Property in FPropertyMappingList[Field.Index] do
      if IsLazyLoading(&Property.PropertyType) then
      begin
        Field.OnGetText := GetLazyDisplayText;

        Break;
      end;
end;
{$ENDIF}

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

