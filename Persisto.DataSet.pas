unit Persisto.DataSet;

interface

uses System.Classes, System.Rtti, System.Generics.Collections, System.SysUtils, System.TypInfo, Data.DB;

type
  TPersistoDataSet = class;

  EDataSetNotInEditingState = class(Exception)
  public
    constructor Create;
  end;

  EDataSetWithoutObjectDefinition = class(Exception)
  public
    constructor Create;
  end;

  EObjectArrayCantBeEmpty = class(Exception)
  public
    constructor Create;
  end;

  EObjectTypeNotFound = class(Exception)
  end;

  EPropertyNameDoesNotExist = class(Exception);
  EPropertyWithDifferentType = class(Exception);
  ESelfFieldDifferentObjectType = class(Exception);
  ESelfFieldNotAllowEmptyValue = class(Exception);
  ESelfFieldTypeWrong = class(Exception);

  TPersistoBuffer = class
  public
    CurrentObject: TObject;
  end;

  TPersistoObjectField = class(TField)
  private
    FBuffer: TValueBuffer;

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

  TPersistoListIterator = class(TInterfacedObject, IORMObjectIterator)
  private
    FCurrentPosition: Cardinal;
    FInternalList: TList<TObject>;
    FList: TList<TObject>;

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
    constructor Create(const Value: TArray<TObject>); overload;
    constructor Create(const Value: TList<TObject>); overload;

    destructor Destroy; override;

    property Objects[Index: Cardinal]: TObject read GetObject write SetObject; default;
  end;

  IPersistoCursor = interface
    function GetCurrentObject: TObject;
    function GetObjectCount: Integer;
    function Next: Boolean;
    function Prior: Boolean;

    procedure First;
    procedure Last;

    property CurrentObject: TObject read GetCurrentObject;
    property ObjectCount: Integer read GetObjectCount;
  end;

  TPersistoCursor = class(TInterfacedObject, IPersistoCursor)
  private
    FCurrentPosition: Integer;
    FDataSet: TPersistoDataSet;

    function GetCurrentObject: TObject;
    function GetObjectCount: Integer;
    function Next: Boolean;
    function Prior: Boolean;

    procedure First;
    procedure Last;

    property CurrentObject: TObject read GetCurrentObject;
    property ObjectCount: Integer read GetObjectCount;
  public
    constructor Create(const DataSet: TPersistoDataSet);
  end;

{$IFDEF DCC}
  [ComponentPlatformsAttribute(pidAllPlatforms)]
{$ENDIF}
  TPersistoDataSet = class(TDataSet)
  private
    FContext: TRttiContext;
    FCursor: IPersistoCursor;
    FIndexFieldNames: String;
    FObjectClass: TClass;
    FObjectClassName: String;
    FObjectList: TList<TObject>;
    FObjectType: TRttiInstanceType;
    FInsertingObject: TObject;

//    FCalculatedFields: TDictionary<TField, Integer>;
//    FFilterFunction: TFunc<TPersistoDataSet, Boolean>;
//    FIterator: IORMObjectIterator;
//    FIteratorData: IORMObjectIterator;
//    FIteratorFilter: IORMObjectIterator;
//    FOldValueObject: TObject;
//    FParentDataSet: TPersistoDataSet;
//    FPropertyMappingList: TArray<TArray<TRttiProperty>>;

    function GetActivePersistoBuffer: TPersistoBuffer;
    function GetActiveObject: TObject;
    function GetCurrentActiveBuffer: TRecBuf;
    function GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
    function GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
    function GetObjectAndPropertyFromParentDataSet(var Instance: TValue; var &Property: TRttiProperty): Boolean;
    function GetObjects: TArray<TObject>;
    function GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
    function GetRecordInfoFromActiveBuffer: TPersistoBuffer;
    function GetRecordInfoFromBuffer(const Buffer: TRecBuf): TPersistoBuffer;
    function IsSelfField(Field: TField): Boolean;

    procedure CheckCalculatedFields;
    procedure CheckIterator;
    procedure CheckIteratorData(const NeedResync, GoFirstRecord: Boolean);
    procedure CheckObjectTypeLoaded;
    procedure CheckSelfFieldType;
    procedure GetPropertyValue(const &Property: TRttiProperty; var Instance: TValue);
    procedure GoToPosition(const Position: Cardinal; const CalculateFields: Boolean);
    procedure InternalCalculateFields(const Buffer: TRecBuf);
    procedure InternalFilter(const NeedResync: Boolean);
    procedure LoadDetailInfo;
    procedure LoadObjectListFromParentDataSet;
    procedure LoadPropertiesFromFields;
    procedure OpenInternalIterator(ObjectClass: TClass; Iterator: IORMObjectIterator);
    procedure ReleaseOldValueObject;
    procedure ReleaseTheInsertingObject;
    procedure ResetFilter;
    procedure SetCurrentObject(const NewObject: TObject);
    procedure SetIndexFieldNames(const Value: String);
    procedure Sort;
    procedure UpdateArrayPosition(const Buffer: TRecBuf);
    procedure UpdateParentObject;
    procedure SetObjectClassName(const Value: String);
    procedure SetObjectClass(const Value: TClass);
    procedure SetObjects(const Value: TArray<TObject>);
    procedure SetObjectType(const Value: TRttiInstanceType);
    procedure LoadCursor;

{$IFDEF PAS2JS}
    procedure GetLazyDisplayText(Sender: TField; var Text: String; DisplayText: Boolean);
    procedure LoadLazyGetTextFields;
{$ENDIF}
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; overload; override;
    function GetRecNo: Integer; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf); override;
    procedure DataEvent(Event: TDataEvent; Info: {$IFDEF PAS2JS}JSValue{$ELSE}NativeInt{$ENDIF}); override;
    procedure DoAfterOpen; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecBuf; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark); override;
    procedure InternalCancel; override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
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
    procedure InternalSetToRecord(Buffer: TRecBuf); override;
    procedure SetDataSetField(const DataSetField: TDataSetField); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;

    property ActivePersistoBuffer: TPersistoBuffer read GetActivePersistoBuffer;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; {$IFDEF DCC}var {$ENDIF}Buffer: TValueBuffer): {$IFDEF PAS2JS}JSValue{$ELSE}Boolean{$ENDIF}; override;

    procedure Filter(Func: TFunc<TPersistoDataSet, Boolean>);
    procedure Resync(Mode: TResyncMode); override;

    property CurrentObject: TObject read GetActiveObject;
    property ObjectClass: TClass read FObjectClass write SetObjectClass;
    property Objects: TArray<TObject> read GetObjects write SetObjects;
    property ObjectType: TRttiInstanceType read FObjectType write SetObjectType;
//    property ParentDataSet: TPersistoDataSet read FParentDataSet;
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
    property FieldOptions;
    property IndexFieldNames: String read FIndexFieldNames write SetIndexFieldNames;
    property ObjectClassName: String read FObjectClassName write SetObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

  TPersistoIndexField = record
  public
    Ascending: Boolean;
    Field: TField;
  end;

implementation

uses System.Math, Persisto.Mapping, {$IFDEF PAS2JS}JS{$ELSE}System.SysConst{$ENDIF};

{ TPersistoListIterator }

procedure TPersistoListIterator.Add(Obj: TObject);
begin
  FCurrentPosition := Succ(FList.Add(Obj));
end;

procedure TPersistoListIterator.Clear;
begin
  FCurrentPosition := 0;

  FList.Clear;
end;

constructor TPersistoListIterator.Create(const Value: TList<TObject>);
begin
  inherited Create;

  FList := Value;
end;

constructor TPersistoListIterator.Create(const Value: TArray<TObject>);
begin
  FInternalList := TList<TObject>.Create;

  FInternalList.AddRange(Value);

  Create(FInternalList);
end;

destructor TPersistoListIterator.Destroy;
begin
  FInternalList.Free;

  inherited;
end;

function TPersistoListIterator.GetCurrentPosition: Cardinal;
begin
  Result := FCurrentPosition;
end;

function TPersistoListIterator.GetObject(Index: Cardinal): TObject;
begin
  Result := FList[Pred(Index)];
end;

function TPersistoListIterator.GetRecordCount: Integer;
begin
  Result := FList.Count;
end;

function TPersistoListIterator.Next: Boolean;
begin
  Result := FCurrentPosition < Cardinal(FList.Count);

  if Result then
    Inc(FCurrentPosition);
end;

function TPersistoListIterator.Prior: Boolean;
begin
  Result := FCurrentPosition > 1;

  if Result then
    Dec(FCurrentPosition);
end;

procedure TPersistoListIterator.Remove;
begin
  FList.Delete(Pred(CurrentPosition));

  Resync;
end;

procedure TPersistoListIterator.ResetBegin;
begin
  FCurrentPosition := 0;
end;

procedure TPersistoListIterator.ResetEnd;
begin
  FCurrentPosition := Succ(FList.Count);
end;

procedure TPersistoListIterator.Resync;
begin
  FCurrentPosition := Min(FCurrentPosition, GetRecordCount);
end;

procedure TPersistoListIterator.SetCurrentPosition(const Value: Cardinal);
begin
  FCurrentPosition := Value;
end;

procedure TPersistoListIterator.SetObject(Index: Cardinal; const Value: TObject);
begin
  FList[Pred(Index)] := Value;
end;

procedure TPersistoListIterator.Swap(Left, Right: Cardinal);
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

procedure TPersistoListIterator.UpdateArrayProperty(&Property: TRttiProperty; Instance: TObject);
var
  A: Integer;

  ValueArray: TValue;

begin
  ValueArray := &Property.GetValue(Instance);
  ValueArray.ArrayLength := FList.Count;

  for A := 0 to Pred(FList.Count) do
    ValueArray.ArrayElement[A] := TValue.From(FList[A]);

  &Property.SetValue(Instance, ValueArray);
end;

{ TPersistoDataSet }

function TPersistoDataSet.AllocRecordBuffer: TRecordBuffer;
//var
//  NewRecordInfo: TPersistoRecordInfo;

begin
  Result := TRecordBuffer(TPersistoBuffer.Create);
//  NewRecordInfo := TPersistoRecordInfo.Create;
//{$IFDEF PAS2JS}
//  Result := inherited;
//  Result.Data := NewRecordInfo;
//{$ELSE}
//  Result := TRecBuf(NewRecordInfo);
//{$ENDIF}
//
//  InternalInitRecord(Result);
end;

procedure TPersistoDataSet.CheckCalculatedFields;
//var
//  A: Integer;

begin
//  FCalculatedFields.Clear;
//
//  for A := 0 to Pred(Fields.Count) do
//    if Fields[A].FieldKind = fkCalculated then
//      FCalculatedFields.Add(Fields[A], FCalculatedFields.Count);
end;

procedure TPersistoDataSet.CheckIterator;
begin
//  if not Assigned(FIteratorData) then
//    FIteratorData := TPersistoListIterator.Create([]);
//
//  FIterator := FIteratorData;
end;

procedure TPersistoDataSet.CheckIteratorData(const NeedResync, GoFirstRecord: Boolean);
begin
//  if Assigned(FFilterFunction) then
//    InternalFilter(NeedResync);
//
//  if not IndexFieldNames.IsEmpty then
//    Sort;
//
//  if GoFirstRecord and (Assigned(FFilterFunction) or not IndexFieldNames.IsEmpty) then
//    First;
end;

procedure TPersistoDataSet.CheckObjectTypeLoaded;
begin
  if not Assigned(FObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;
end;

procedure TPersistoDataSet.CheckSelfFieldType;
//var
//  Field: TField;
//
begin
//  Field := FindField(SELF_FIELD_NAME);
//
//  if Assigned(Field) and (Field.DataType <> ftVariant) then
//    raise ESelfFieldTypeWrong.Create('The Self field must be of the variant type!');
end;

procedure TPersistoDataSet.ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf);
//var
//  A: Integer;
//
//  CalcBuffer: TArray<TValue>;

begin
//  CalcBuffer := GetRecordInfoFromActiveBuffer.CalculedFieldBuffer;
//
//  for A := Low(CalcBuffer) to High(CalcBuffer) do
//    CalcBuffer[A] := TValue.Empty;
end;

constructor TPersistoDataSet.Create(AOwner: TComponent);
begin
  inherited;

{$IFDEF DCC}
//  BookmarkSize := SizeOf(TPersistoRecordInfo);
  ObjectView := True;
{$ENDIF}

//  FCalculatedFields := TDictionary<TField, Integer>.Create;
  FContext := TRttiContext.Create;
  FObjectList := TList<TObject>.Create;
end;

procedure TPersistoDataSet.DataEvent(Event: TDataEvent; Info: {$IFDEF PAS2JS}JSValue{$ELSE}NativeInt{$ENDIF});
begin
  inherited;

//  if Event = deParentScroll then
//  begin
//    LoadObjectListFromParentDataSet;
//
//    Resync([]);
//  end;
end;

destructor TPersistoDataSet.Destroy;
begin
  FContext.Free;

  FObjectList.Free;
//  FCalculatedFields.Free;
//
//  ReleaseTheInsertingObject;

  inherited;
end;

procedure TPersistoDataSet.DoAfterOpen;
//var
//  A: Integer;
//
//  NestedDataSet: TPersistoDataSet;

begin
//  CheckIteratorData(True, True);
//
//  for A := 0 to Pred(NestedDataSets.Count) do
//  begin
//    NestedDataSet := TPersistoDataSet(NestedDataSets[A]);
//
//    NestedDataSet.DataEvent(deParentScroll, 0);
//  end;

  inherited;
end;

procedure TPersistoDataSet.Filter(Func: TFunc<TPersistoDataSet, Boolean>);
begin
//  FFilterFunction := Func;
//
//  ResetFilter;
//
//  if Active then
//    Resync([]);
end;

procedure TPersistoDataSet.LoadCursor;
begin
  FCursor := TPersistoCursor.Create(Self);
end;

procedure TPersistoDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  PersistoBuffer.Free;
end;

function TPersistoDataSet.GetActiveObject: TObject;
begin
  Result := ActivePersistoBuffer.CurrentObject;
end;

function TPersistoDataSet.GetActivePersistoBuffer: TPersistoBuffer;
begin
  Result := TPersistoBuffer(ActiveBuffer);
end;

procedure TPersistoDataSet.GetBookmarkData(Buffer: TRecBuf; {$IFDEF PAS2JS}var {$ENDIF}Data: TBookmark);
//var
//  RecordInfo: TPersistoRecordInfo;

begin
//  RecordInfo := GetRecordInfoFromBuffer(Buffer);
//
//{$IFDEF PAS2JS}Data.Data{$ELSE}PInteger(Data)^{$ENDIF} := RecordInfo.ArrayPosition;
end;

function TPersistoDataSet.GetCurrentActiveBuffer: TRecBuf;
begin
  case State of
    // dsInsert:;
    // dsOldValue:;
    // dsInactive: ;
    // dsBrowse: ;
    // dsEdit: ;
    // dsSetKey: ;
     dsCalcFields: Result := TRecBuf(CalcBuffer);
    // dsFilter: ;
    // dsNewValue: ;
    // dsCurValue: ;
    // dsBlockRead: ;
    // dsInternalCalc: ;
    // dsOpening: ;
    else Result := TRecBuf(ActiveBuffer);
  end;
end;

function TPersistoDataSet.GetCurrentObject<T>: T;
begin
  Result := CurrentObject as T;
end;

function TPersistoDataSet.GetFieldClass(FieldDef: TFieldDef): TFieldClass;
begin
  if FieldDef.DataType = ftObject then
    Result := TPersistoObjectField
  else
    Result := inherited GetFieldClass(FieldDef);
end;

function TPersistoDataSet.GetFieldData(Field: TField; {$IFDEF DCC}var {$ENDIF}Buffer: TValueBuffer): {$IFDEF PAS2JS}JSValue{$ELSE}Boolean{$ENDIF};
//var
//  &Property: TRttiProperty;
//
//  Value: TValue;

begin
  Exit(False);
//  Result := {$IFDEF PAS2JS}NULL{$ELSE}False{$ENDIF};
//
//  if IsSelfField(Field) then
//    Value := TValue.From(GetInternalCurrentObject)
//  else if Field.FieldKind = fkData then
//  begin
//    if GetPropertyAndObjectFromField(Field, Value, &Property) then
//      GetPropertyValue(&Property, Value);
//  end
//  else if Field.FieldKind = fkCalculated then
//    Value := GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]];
//
//  if not Value.IsEmpty then
//  begin
//{$IFDEF PAS2JS}
//    Result := Value.AsJSValue;
//
//    if Field is TDateTimeField then
//      Result := TJSDate.New(FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss"', Double(Result)));
//{$ELSE}
//    Result := True;
//
//    if Assigned(Buffer) then
//      if Field is TStringField then
//      begin
//        var StringData := Value.AsType<AnsiString>;
//        var StringSize := Length(StringData);
//
//        if StringSize > 0 then
//          Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);
//
//        Buffer[StringSize] := 0;
//      end
//      else if Field is TDateTimeField then
//      begin
//        var DataTimeValue: TValueBuffer;
//
//        SetLength(DataTimeValue, SizeOf(Double));
//
//        Value.ExtractRawData(@DataTimeValue[0]);
//
//        DataConvert(Field, DataTimeValue, Buffer, True);
//      end
//      else
//        Value.ExtractRawData(@Buffer[0]);
//{$ENDIF}
//  end;
end;

function TPersistoDataSet.GetFieldInfoFromProperty(&Property: TRttiProperty; var Size: Integer): TFieldType;
var
  PropertyType: TRttiType;

begin
//  if TNullableManipulator.IsNullable(&Property) then
//    PropertyType := TNullableManipulator.GetNullableType(&Property)
//  else if TLazyManipulator.IsLazyLoading(&Property) then
//    PropertyType := TLazyManipulator.GetLazyLoadingType(&Property)
//  else
    PropertyType := &Property.PropertyType;

//  Result := PropertyType.FieldType;
  Result := ftUnknown;

  case PropertyType.TypeKind of
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
    else Size := 0;
  end;
end;

function TPersistoDataSet.GetFieldTypeFromProperty(&Property: TRttiProperty): TFieldType;
var
  Size: Integer;

begin
  Size := 0;

  Result := GetFieldInfoFromProperty(&Property, Size);
end;

procedure Filter(Func: TFunc<TPersistoDataSet, Boolean>);
begin

end;

function TPersistoDataSet.GetObjectAndPropertyFromParentDataSet(var Instance: TValue; var &Property: TRttiProperty): Boolean;
begin
//  Result := Assigned(ParentDataSet) and not ParentDataSet.IsEmpty;
//
//  if Result then
//    Result := ParentDataSet.GetPropertyAndObjectFromField(DataSetField, Instance, &Property);
end;

function TPersistoDataSet.GetObjects: TArray<TObject>;
begin
  Result := FObjectList.ToArray;
end;

function TPersistoDataSet.GetPropertyAndObjectFromField(Field: TField; var Instance: TValue; var &Property: TRttiProperty): Boolean;
//var
//  A: Integer;
//
//  PropertyList: TArray<TRttiProperty>;

begin
//  Result := Active;
//
//  if Result then
//  begin
//    Instance := TValue.From(GetInternalCurrentObject);
//    PropertyList := FPropertyMappingList[Field.Index];
//
//    for A := Low(PropertyList) to High(PropertyList) do
//    begin
//      if A > 0 then
//        GetPropertyValue(&Property, Instance);
//
//      &Property := PropertyList[A];
//
//      if Instance.IsEmpty then
//        Exit(False);
//    end;
//  end;
end;

procedure TPersistoDataSet.GetPropertyValue(const &Property: TRttiProperty; var Instance: TValue);
begin
//  if TLazyManipulator.IsLazyLoading(&Property) then
//    Instance := TLazyManipulator.GetManipulator(Instance.AsObject, &Property).Value
//  else if TNullableManipulator.IsNullable(&Property) then
//    Instance := TNullableManipulator.GetManipulator(Instance.AsObject, &Property).Value
//  else
    Instance := &Property.GetValue(Instance.AsObject);
end;

function TPersistoDataSet.GetRecNo: Integer;
begin
  Result := 0;
end;

function TPersistoDataSet.GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  case GetMode of
    gmCurrent:;
//      if FIterator.CurrentPosition = 0 then
//        Result := grError;
    gmNext:
      if FCursor.Next then
      begin
        Result := grOK;

        PersistoBuffer.CurrentObject := FCursor.CurrentObject;
      end
      else
        Result := grEOF;
    gmPrior:
      if FCursor.Prior then
      begin
        Result := grOK;

        PersistoBuffer.CurrentObject := FCursor.CurrentObject;
      end
      else
        Result := grBOF;
    else
      Result := grError;
  end;
end;

function TPersistoDataSet.GetRecordCount: Integer;
begin
  CheckActive;

  Result := FCursor.ObjectCount;
end;

function TPersistoDataSet.GetRecordInfoFromActiveBuffer: TPersistoBuffer;
begin
  Result := GetRecordInfoFromBuffer(GetCurrentActiveBuffer);
end;

function TPersistoDataSet.GetRecordInfoFromBuffer(const Buffer: TRecBuf): TPersistoBuffer;
begin
  Result := TPersistoBuffer(Buffer{$IFDEF PAS2JS}.Data{$ENDIF});
end;

procedure TPersistoDataSet.InternalCalculateFields(const Buffer: TRecBuf);
var
  ORMBuffer: TRecBuf absolute Buffer;

begin
  GetCalcFields(ORMBuffer);
end;

procedure TPersistoDataSet.InternalInitRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf);
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  PersistoBuffer.CurrentObject := nil;
end;

procedure TPersistoDataSet.InternalInsert;
begin
  inherited;

  FInsertingObject := ObjectType.MetaclassType.Create;

  ActivePersistoBuffer.CurrentObject := FInsertingObject;
end;

procedure TPersistoDataSet.InternalCancel;
//var
//  &Property: TRttiProperty;
//
//  CurrentObject: TObject;

begin
  inherited;
//  if Assigned(FOldValueObject) then
//  begin
//    CurrentObject := GetInternalCurrentObject;
//
//    for &Property in ObjectType.GetProperties do
//      &Property.SetValue(CurrentObject, &Property.GetValue(FOldValueObject));
//
//    ReleaseOldValueObject;
//  end;
//
//  ReleaseTheInsertingObject;
end;

procedure TPersistoDataSet.InternalClose;
begin
  FCursor := nil;
//  FIterator := nil;
//  FIteratorData := nil;
//  FIteratorFilter := nil;
//
//  BindFields(False);
end;

procedure TPersistoDataSet.InternalDelete;
begin
//  FIterator.Remove;
//
//  UpdateParentObject;
end;

procedure TPersistoDataSet.InternalEdit;
//var
//  &Property: TRttiProperty;
//
//  CurrentObject: TObject;

begin
  inherited;

//  CurrentObject := GetInternalCurrentObject;
//
//  if not Assigned(FOldValueObject) then
//    FOldValueObject := ObjectType.MetaclassType.Create;
//
//  for &Property in ObjectType.GetProperties do
//    &Property.SetValue(FOldValueObject, &Property.GetValue(CurrentObject));
end;

procedure TPersistoDataSet.InternalFilter(const NeedResync: Boolean);
begin
//  if Active then
//  begin
//    ResetFilter;
//
//    if Assigned(FFilterFunction) then
//    begin
//      FIteratorFilter := TPersistoListIterator.Create([]);
//
//      FIteratorData.ResetBegin;
//
//      while FIteratorData.Next do
//      begin
//        GoToPosition(FIteratorData.CurrentPosition, True);
//
//        if FFilterFunction(Self) then
//          FIteratorFilter.Add(FIteratorData[FIteratorData.CurrentPosition]);
//      end;
//
//      FIterator := FIteratorFilter;
//    end
//    else
//      FIteratorFilter := nil;
//
//    if NeedResync then
//      Resync([]);
//  end;
end;

procedure TPersistoDataSet.InternalFirst;
begin
  FCursor.First;
end;

procedure TPersistoDataSet.InternalGotoBookmark(Bookmark: TBookmark);
//{$IFDEF DCC}
//var
//  RecordIndex: PInteger absolute Bookmark;
//
//{$ENDIF}
begin
//{$IFDEF PAS2JS}
//  raise Exception.Create('Not implemented the bookmark control!');
//{$ELSE}
//  FIterator.CurrentPosition := RecordIndex^;
//{$ENDIF}
end;

procedure TPersistoDataSet.InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF};
begin
end;

procedure TPersistoDataSet.InternalInitFieldDefs;
var
  LoadedClasses: TList<TRttiInstanceType>;

  procedure LoadFieldDefs(const InstanceType: TRttiInstanceType; const ParentFieldName: String);
  var
    FieldType: TFieldType;
    Property_: TRttiProperty;
    PropertyType: TRttiType;

    function GetFieldSize: Integer;
    var
      Size: SizeAttribute;

    begin
      Result := 0;
      if PropertyType.TypeKind in [{$IFDEF DCC}tkWChar, {$ENDIF}tkChar] then
        Result := 1
      else
      begin
        Size := Property_.GetAttribute<SizeAttribute>;

        if Assigned(Size) then
          Result := Size.Size
        else
          Result := 0;
      end;
    end;

    function GetFieldName: String;
    begin
      Result := ParentFieldName + Property_.Name;
    end;

  begin
    if LoadedClasses.IndexOf(InstanceType) = -1 then
    begin
      LoadedClasses.Add(InstanceType);

      for Property_ in InstanceType.GetProperties do
        if FieldDefs.IndexOf(GetFieldName) < 0 then
        begin
          PropertyType := Property_.PropertyType;

          case PropertyType.TypeKind of
{$IFDEF DCC}
            tkLString,
            tkUString,
            tkWChar,
{$ENDIF}
            tkChar,
            tkString: FieldType := ftString;

{$IFDEF PAS2JS}
            tkBool,
{$ENDIF}
            tkEnumeration:
              if PropertyType.Handle = TypeInfo(Boolean) then
                FieldType := ftBoolean
              else
                FieldType := ftInteger;

            tkFloat:
              if PropertyType.Handle = TypeInfo(TDate) then
                FieldType := ftDate
              else if PropertyType.Handle = TypeInfo(TDateTime) then
                FieldType := ftDateTime
              else if PropertyType.Handle = TypeInfo(TTime) then
                FieldType := ftTime
              else
                case PropertyType.Handle.TypeData.FloatType of
{$IFDEF DCC}
                  TFloatType.ftCurr: FieldType := TFieldType.ftCurrency;
                  TFloatType.ftExtended: FieldType := TFieldType.ftExtended;
                  TFloatType.ftSingle: FieldType := TFieldType.ftSingle;
{$ENDIF}
                  else FieldType := TFieldType.ftFloat;
                end;

            tkInteger:
              case PropertyType.Handle.TypeData.OrdType of
{$IFDEF DCC}
                otSByte,
                otUByte: FieldType := ftByte;
                otUWord: FieldType := ftWord;
                otULong: FieldType := ftLongWord;
{$ENDIF}
                else FieldType := ftInteger;
              end;

            tkClass: FieldType := ftObject;

{$IFDEF DCC}
            tkInt64: FieldType := ftLargeint;

            tkWString: FieldType := ftWideString;
{$ENDIF}

            tkDynArray: FieldType := ftDataSet;
          end;

          TFieldDef.Create(FieldDefs, GetFieldName, FieldType, GetFieldSize, False, FieldDefs.Count);

          if PropertyType.TypeKind = tkClass then
            LoadFieldDefs(Property_.PropertyType.AsInstance, GetFieldName + '.');
        end;
    end;
  end;

begin
  LoadedClasses := TList<TRttiInstanceType>.Create;

  FieldDefs.Clear;

  LoadFieldDefs(ObjectType, EmptyStr);

  LoadedClasses.Free;
end;

procedure TPersistoDataSet.InternalLast;
begin
  FCursor.Last;
end;

procedure TPersistoDataSet.InternalOpen;
begin
  CheckObjectTypeLoaded;

  if not FieldDefs.Updated then
    FieldDefs.Update;

  CreateFields;

  LoadCursor;

//  LoadDetailInfo;
//
//  if FieldDefs.Count = 0 then
//    if FieldCount = 0 then
//      LoadFieldDefsFromClass
//    else
//      InitFieldDefsFromFields;
//
//  if FieldCount = 0 then
//    CreateFields;
//
//  CheckSelfFieldType;
//
//  LoadPropertiesFromFields;
//
//  BindFields(True);
//
//  CheckCalculatedFields;
//
//  LoadObjectListFromParentDataSet;
end;

procedure TPersistoDataSet.InternalPost;
begin
  inherited;

  FObjectList.Add(nil);
//  if State = dsInsert then
//  begin
//    FIteratorData.Add(FInsertingObject);
//
//    UpdateParentObject;
//  end;
//
//  FInsertingObject := nil;
//
//  ReleaseOldValueObject;
end;

procedure TPersistoDataSet.InternalSetToRecord(Buffer: TRecBuf);
begin
//  FIterator.CurrentPosition := GetRecordInfoFromBuffer(Buffer).ArrayPosition;
end;

function TPersistoDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FCursor);
end;

function TPersistoDataSet.IsSelfField(Field: TField): Boolean;
begin
//  Result := Field.FieldName = SELF_FIELD_NAME;
  Result := False;
end;

procedure TPersistoDataSet.GoToPosition(const Position: Cardinal; const CalculateFields: Boolean);
begin
//  FIterator.CurrentPosition := Position;
//
//  UpdateArrayPosition(GetCurrentActiveBuffer);
//
//  if CalculateFields then
//    InternalCalculateFields(GetCurrentActiveBuffer);
end;

procedure TPersistoDataSet.LoadDetailInfo;
//var
//  Properties: TArray<TRttiProperty>;

begin
//  if Assigned(ParentDataSet) then
//  begin
//    Properties := ParentDataSet.FPropertyMappingList[Pred(DataSetField.FieldNo)];
//
//    FObjectType := (Properties[High(Properties)].PropertyType as TRttiDynamicArrayType).ElementType as TRttiInstanceType;
//  end;
end;

procedure TPersistoDataSet.LoadObjectListFromParentDataSet;
//var
//  A: Integer;
//
//  Value: TValue;
//
//  &Property: TRttiProperty;

begin
//  if Assigned(ParentDataSet) then
//  begin
//    FIteratorData.Clear;
//
//    if GetObjectAndPropertyFromParentDataSet(Value, &Property) then
//    begin
//      Value := &Property.GetValue(Value.AsObject);
//
//      for A := 0 to Pred(Value.GetArrayLength) do
//        FIteratorData.Add(Value.GetArrayElement(A).AsObject);
//    end;
//
//    FIteratorData.ResetBegin;
//  end;
end;

procedure TPersistoDataSet.LoadPropertiesFromFields;
//var
//  A: Integer;
//
//  Field: TField;
//
//  CurrentObjectType: TRttiInstanceType;
//
//  &Property: TRttiProperty;
//
//  PropertyList: TArray<TRttiProperty>;
//
//  PropertyName: String;

begin
//  SetLength(FPropertyMappingList, Fields.Count);
//
//  for A := 0 to Pred(Fields.Count) do
//  begin
//    Field := Fields[A];
//
//    if (Field.FieldKind = fkData) and not IsSelfField(Field) then
//    begin
//      CurrentObjectType := ObjectType;
//      &Property := nil;
//      PropertyList := nil;
//      PropertyName := EmptyStr;
//
//      for PropertyName in Field.FieldName.Split(['.']) do
//      begin
//        &Property := CurrentObjectType.GetProperty(PropertyName);
//
//        if not Assigned(&Property) then
//          raise EPropertyNameDoesNotExist.CreateFmt('The property %s not found in the current object!', [PropertyName]);
//
//        PropertyList := PropertyList + [&Property];
//
//        if &Property.PropertyType.IsInstance then
//          CurrentObjectType := &Property.PropertyType as TRttiInstanceType
////        else if TLazyManipulator.IsLazyLoading(&Property) then
////          CurrentObjectType := TLazyManipulator.GetLazyLoadingType(&Property).AsInstance;
//      end;
//
//{$IFDEF DCC}
//      if GetFieldTypeFromProperty(&Property) <> Field.DataType then
//        raise EPropertyWithDifferentType.CreateFmt('The field %s as type %s and the expected field type is %s!', [Field.FieldName, TRttiEnumerationType.GetName(Field.DataType),
//          TRttiEnumerationType.GetName(GetFieldTypeFromProperty(&Property))]);
//{$ENDIF}
//
//      FPropertyMappingList[Field.Index] := PropertyList;
//    end;
//  end;
end;

procedure TPersistoDataSet.OpenInternalIterator(ObjectClass: TClass; Iterator: IORMObjectIterator);
begin
//  FIteratorData := Iterator;
//  ObjectType := FContext.GetType(ObjectClass) as TRttiInstanceType;

  Open;
end;

procedure TPersistoDataSet.ReleaseOldValueObject;
begin
//  FreeAndNil(FOldValueObject);
end;

procedure TPersistoDataSet.ReleaseTheInsertingObject;
begin
//  FreeAndNil(FInsertingObject);
end;

procedure TPersistoDataSet.ResetFilter;
begin
//  FIterator := FIteratorData;
end;

procedure TPersistoDataSet.Resync(Mode: TResyncMode);
begin
//  FIteratorData.Resync;
//
//  CheckIteratorData(False, False);

  inherited;
end;

procedure TPersistoDataSet.SetCurrentObject(const NewObject: TObject);
begin
//  if not Assigned(NewObject) then
//    raise ESelfFieldNotAllowEmptyValue.Create('Empty value isn''t allowed in Self field!')
//  else if NewObject.ClassType <> FObjectType.MetaclassType then
//    raise ESelfFieldDifferentObjectType.Create('Can''t fill the Self field with an object with different type!');
//
//  case State of
//    dsInsert:
//    begin
//      ReleaseTheInsertingObject;
//
//      FInsertingObject := NewObject;
//    end;
//    // dsOldValue: ;
//    // dsInactive: ;
//    // dsBrowse: ;
//    // dsEdit: ;
//    // dsSetKey: ;
//    // dsCalcFields: ;
//    // dsFilter: ;
//    // dsNewValue: ;
//    // dsCurValue: ;
//    // dsBlockRead: ;
//    // dsInternalCalc: ;
//    // dsOpening: ;
//    else
//      FIterator[GetRecordInfoFromActiveBuffer.ArrayPosition] := NewObject;
//  end;
end;

procedure TPersistoDataSet.SetDataSetField(const DataSetField: TDataSetField);
begin
//  if Assigned(DataSetField) then
//    FParentDataSet := DataSetField.DataSet as TPersistoDataSet
//  else
//    FParentDataSet := nil;

  inherited;
end;

procedure TPersistoDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
//var
//  Instance: TValue;
//
//  &Property: TRttiProperty;
//
//  Value: TValue;

begin
//  if not (State in dsWriteModes) then
//    raise EDataSetNotInEditingState.Create;
//
//  Value := TValue.Empty;
//
//  if Assigned(Buffer) then
//    case Field.DataType of
//{$IFDEF DCC}
//      ftByte,
//      ftWord,
//{$ENDIF}
//      ftInteger: Value := TValue.From({$IFDEF PAS2JS}Integer(Buffer){$ELSE}PInteger(Buffer)^{$ENDIF});
//
//      ftString: Value := TValue.From({$IFDEF PAS2JS}String(Buffer){$ELSE}String(AnsiString(PAnsiChar(Buffer))){$ENDIF});
//
//      ftBoolean: Value := TValue.From({$IFDEF PAS2JS}Boolean(Buffer){$ELSE}PWordBool(Buffer)^{$ENDIF});
//
//      ftDate,
//      ftDateTime,
//      ftTime:
//{$IFDEF PAS2JS}
//        Value := TValue.From(ConvertToDateTime(Field, Buffer, True));
//{$ELSE}
//      begin
//        var DataTimeValue: TValueBuffer;
//
//        SetLength(DataTimeValue, SizeOf(Double));
//
//        DataConvert(Field, Buffer, DataTimeValue, False);
//
//        Value := TValue.From(PDouble(DataTimeValue)^);
//      end;
//{$ENDIF}
//{$IFDEF DCC}
//      TFieldType.ftSingle: Value := TValue.From(PSingle(Buffer)^);
//
//      TFieldType.ftExtended: Value := TValue.From(PExtended(Buffer)^);
//
//      ftLongWord: Value := TValue.From(PCardinal(Buffer)^);
//
//      ftWideString: Value := TValue.From(String(PWideChar(Buffer)));
//
//      ftCurrency,
//{$ENDIF}
//      ftFloat: Value := TValue.From({$IFDEF PAS2JS}Double(Buffer){$ELSE}PDouble(Buffer)^{$ENDIF});
//
//      ftLargeint: Value := TValue.From({$IFDEF PAS2JS}Int64(Buffer){$ELSE}PInt64(Buffer)^{$ENDIF});
//
//      ftVariant: Value := TValue.From({$IFDEF PAS2JS}TObject(Buffer){$ELSE}TObject(PNativeInt(Buffer)^){$ENDIF});
//    end;
//
//  if IsSelfField(Field) then
//    SetCurrentObject(Value.AsObject)
//  else if Field.FieldKind = fkData then
//  begin
//    GetPropertyAndObjectFromField(Field, Instance, &Property);
//
//    if &Property.PropertyType is TRttiEnumerationType then
//      Value := TValue.FromOrdinal(&Property.PropertyType.Handle, Value.AsOrdinal);
//
//    if TNullableManipulator.IsNullable(&Property) then
//      TNullableManipulator.GetManipulator(Instance.AsObject, &Property).Value := Value
//    else if TLazyManipulator.IsLazyLoading(&Property) then
//      TLazyManipulator.GetManipulator(Instance.AsObject, &Property).Value := Value
//    else
//      &Property.SetValue(Instance.AsObject, Value);
//  end
//  else if Field.FieldKind = fkCalculated then
//    GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]] := Value;
//
//  if not (State in [dsCalcFields, dsInternalCalc, dsFilter, dsNewValue]) then
//    DataEvent(deFieldChange, {$IFDEF DCC}IntPtr{$ENDIF}(Field));
end;

procedure TPersistoDataSet.SetIndexFieldNames(const Value: String);
begin
  if FIndexFieldNames <> Value then
  begin
    FIndexFieldNames := Value;

    if Active then
      Resync([]);
  end;
end;

procedure TPersistoDataSet.SetObjectClass(const Value: TClass);
begin
  FObjectClass := Value;
  ObjectType := FContext.GetType(FObjectClass).AsInstance;
end;

procedure TPersistoDataSet.SetObjectClassName(const Value: String);
var
  RTTIType: TRttiType;

begin
  FObjectClassName := Value;
  RTTIType := FContext.FindType(ObjectClassName);

  if Assigned(RTTIType) then
    ObjectType := RttiType.AsInstance
  else if not Value.IsEmpty then
    raise EObjectTypeNotFound.CreateFmt('Type not found %s!', [Value]);
end;

procedure TPersistoDataSet.SetObjects(const Value: TArray<TObject>);
begin
  if Assigned(Value) then
  begin
    FObjectList.AddRange(Value);

    ObjectClass := FObjectList.First.ClassType
  end
  else
    raise EObjectArrayCantBeEmpty.Create;
end;

procedure TPersistoDataSet.SetObjectType(const Value: TRttiInstanceType);
begin
  CheckInactive;

  FieldDefs.Updated := False;
  FObjectType := Value;

  CheckObjectTypeLoaded;
end;

procedure TPersistoDataSet.Sort;
//var
//  A: Integer;
//
//  IndexFields: TArray<TPersistoIndexField>;
//
//  Pivot, Values: TArray<TValue>;
//
//  FieldName: String;
//
//  FieldNames: TArray<String>;
//
//  NeedCalcFiels: Boolean;
//
//  procedure GetValues(Position: Cardinal; var Values: TArray<TValue>);
//  var
//    A: Integer;
//
//    Field: TField;
//
//  begin
//    GoToPosition(Position, NeedCalcFiels);
//
//    for A := Low(IndexFields) to High(IndexFields) do
//    begin
//      Field := IndexFields[A].Field;
//
//      if Field.IsNull then
//        Values[A] := TValue.Empty
//{$IFDEF PAS2JS}
//      else if Field is TDateTimeField then
//        Values[A] := TValue.From(Field.AsFloat)
//{$ENDIF}
//      else
//        Values[A] := TValue.{$IFDEF PAS2JS}FromJSValue{$ELSE}FromVariant{$ENDIF}(Field.Value);
//    end;
//  end;
//
//  function CompareValue(const Left, Right: TArray<TValue>): Boolean;
//  var
//    A: Integer;
//
//    LeftValue, RightValue: TValue;
//
//    ComparedValue: Double;
//
//  begin
//    ComparedValue := 0;
//
//    for A := Low(IndexFields) to High(IndexFields) do
//    begin
//      if IndexFields[A].Ascending then
//      begin
//        LeftValue := Left[A];
//        RightValue := Right[A];
//      end
//      else
//      begin
//        LeftValue := Right[A];
//        RightValue := Left[A];
//      end;
//
//      if LeftValue.IsEmpty and RightValue.IsEmpty then
//        Continue
//      else if not LeftValue.IsEmpty and RightValue.IsEmpty then
//        ComparedValue := 1
//      else if LeftValue.IsEmpty and not RightValue.IsEmpty then
//        ComparedValue := -1
//      else
//        case LeftValue.Kind of
//{$IFDEF PAS2JS}
//          tkBool,
//{$ENDIF}
//{$IFDEF DCC}
//          tkInt64,
//{$ENDIF}
//          tkInteger,
//          tkEnumeration:
//            ComparedValue := LeftValue.AsInteger - RightValue.AsInteger;
//
//{$IFDEF DCC}
//          tkWChar,
//          tkLString,
//          tkWString,
//          tkUString,
//{$ENDIF}
//          tkChar,
//          tkString:
//            ComparedValue := CompareStr(LeftValue.AsString, RightValue.AsString);
//
//          tkFloat:
//            ComparedValue := LeftValue.AsExtended - RightValue.AsExtended;
//        end;
//
//      if ComparedValue <> 0 then
//        Break;
//    end;
//
//    Result := ComparedValue < 0;
//  end;
//
//  function Partition(Low, High: Cardinal): Cardinal;
//  var
//    A: Cardinal;
//
//  begin
//    Result := Pred(Low);
//
//    GetValues(High, Pivot);
//
//    for A := Low to Pred(High) do
//    begin
//      GetValues(A, Values);
//
//      if CompareValue(Values, Pivot) then
//      begin
//        Inc(Result);
//
//        FIterator.Swap(Result, A);
//      end;
//    end;
//
//    Inc(Result);
//
//    FIterator.Swap(Result, High);
//  end;
//
//  procedure QuickSort(Low, High: Cardinal);
//  var
//    Middle: Cardinal;
//
//  begin
//    if Low < High then
//    begin
//      Middle := Partition(Low, High);
//
//      QuickSort(Low, Pred(Middle));
//
//      QuickSort(Succ(Middle), High);
//    end;
//  end;

begin
//  if not IndexFieldNames.IsEmpty then
//  begin
//    FieldNames := IndexFieldNames.Split([';']);
//    NeedCalcFiels := False;
//
//    SetLength(IndexFields, Length(FieldNames));
//
//    for A := Low(FieldNames) to High(FieldNames) do
//    begin
//      FieldName := FieldNames[A];
//      IndexFields[A].Ascending := FieldName[1] <> '-';
//
//      if not IndexFields[A].Ascending then
//        FieldName := FieldName.Substring(1);
//
//      IndexFields[A].Field := FieldByName(FieldName);
//      NeedCalcFiels := NeedCalcFiels or (IndexFields[A].Field.FieldKind = fkCalculated);
//    end;
//
//    SetLength(Pivot, Length(IndexFields));
//
//    SetLength(Values, Length(IndexFields));
//
//    QuickSort(1, FIterator.RecordCount);
//  end;
end;

procedure TPersistoDataSet.UpdateArrayPosition(const Buffer: TRecBuf);
begin
//  GetRecordInfoFromBuffer(Buffer).ArrayPosition := FIterator.CurrentPosition;
end;

procedure TPersistoDataSet.UpdateParentObject;
//var
//  Instance: TValue;
//
//  &Property: TRttiProperty;

begin
//  if Assigned(DataSetField) then
//  begin
//    GetObjectAndPropertyFromParentDataSet(Instance, &Property);
//
//    FIteratorData.UpdateArrayProperty(&Property, Instance.AsObject);
//  end;
end;

{$IFDEF PAS2JS}
type
  TFieldHack = class(TField)
  end;

procedure TPersistoDataSet.GetLazyDisplayText(Sender: TField; var Text: String; DisplayText: Boolean);
//var
//  &Property: TRttiProperty;
//
//  Value: TValue;
//
//  LazyAccess: TLazyAccessType;
//
//  CurrentRecord: Integer;
//
begin
//  if DisplayText then
//  begin
//    Value := TValue.From(GetInternalCurrentObject);
//
//    for &Property in FPropertyMappingList[Sender.Index] do
//      if Value.IsEmpty then
//        Break
//      else
//      begin
//        Value := &Property.GetValue(Value.AsObject);
//
//        if IsLazyLoading(&Property) then
//        begin
//          LazyAccess := GetLazyLoadingAccess(Value);
//
//          if LazyAccess.HasValue then
//            Value := LazyAccess.Value
//          else
//          begin
//            CurrentRecord := ActiveRecord;
//            Text := 'Loading....';
//
//            LazyAccess.GetValueAsync.&then(
//              procedure
//              begin
//                DataEvent(deRecordChange, CurrentRecord);
//              end);
//
//            Exit;
//          end;
//        end;
//      end;
//  end;
//
  TFieldHack(Sender).GetText(Text, DisplayText);
end;

procedure TPersistoDataSet.LoadLazyGetTextFields;
//var
//  Field: TField;
//
//  &Property: TRttiProperty;
//
begin
//  for Field in Fields do
//    for &Property in FPropertyMappingList[Field.Index] do
//      if IsLazyLoading(&Property) then
//      begin
//        Field.OnGetText := GetLazyDisplayText;
//
//        Break;
//      end;
end;
{$ENDIF}

{ TPersistoObjectField }

constructor TPersistoObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftVariant);

{$IFDEF DCC}
  SetLength(FBuffer, SizeOf(TObject));
{$ENDIF}
end;

function TPersistoObjectField.GetAsObject: TObject;
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

procedure TPersistoObjectField.SetAsObject(const Value: TObject);
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
  inherited Create('Must load a object information property like ObjectClass or ObjectClassName!');
end;

{ EDataSetNotInEditingState }

constructor EDataSetNotInEditingState.Create;
begin
  inherited Create('Dataset not in edit or insert mode');
end;

{ EObjectArrayCantBeEmpty }

constructor EObjectArrayCantBeEmpty.Create;
begin
  inherited Create('The object list can''t be emtpy!');
end;

{ TPersistoCursor }

constructor TPersistoCursor.Create(const DataSet: TPersistoDataSet);
begin
  inherited Create;

  FDataSet := DataSet;

  First;
end;

procedure TPersistoCursor.First;
begin
  FCurrentPosition := -1;
end;

function TPersistoCursor.GetCurrentObject: TObject;
begin
  Result := FDataSet.FObjectList[FCurrentPosition];
end;

function TPersistoCursor.GetObjectCount: Integer;
begin
  Result := FDataSet.FObjectList.Count;
end;

procedure TPersistoCursor.Last;
begin
  FCurrentPosition := ObjectCount;
end;

function TPersistoCursor.Next: Boolean;
begin
  Inc(FCurrentPosition);

  Result := FCurrentPosition < ObjectCount;
end;

function TPersistoCursor.Prior: Boolean;
begin
  Dec(FCurrentPosition);

  Result := FCurrentPosition > -1;
end;

end.

