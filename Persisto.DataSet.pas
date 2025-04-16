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

  EObjectTypeNotFound = class(Exception)
  end;

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

    function GetActivePersistoBuffer: TPersistoBuffer;
    function GetActiveObject: TObject;
    function GetObjects: TArray<TObject>;

    procedure CheckObjectTypeLoaded;
    procedure SetIndexFieldNames(const Value: String);
    procedure SetObjectClassName(const Value: String);
    procedure SetObjectClass(const Value: TClass);
    procedure SetObjects(const Value: TArray<TObject>);
    procedure SetObjectType(const Value: TRttiInstanceType);
    procedure LoadCursor;
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

procedure TPersistoDataSet.CheckObjectTypeLoaded;
begin
  if not Assigned(FObjectType) then
    raise EDataSetWithoutObjectDefinition.Create;
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
var
  FieldName: String;
  &Property: TRttiProperty;
  Value: TValue;

begin
  Result := {$IFDEF PAS2JS}NULL{$ELSE}False{$ENDIF};

  if Field.FieldKind = fkData then
  begin
    &Property := nil;
    Value := CurrentObject;

    for FieldName in Field.FieldName.Split(['.']) do
    begin
      if Assigned(&Property) then
        &Property := &Property.PropertyType.AsInstance.GetProperty(FieldName)
      else
        &Property := ObjectType.GetProperty(FieldName);

      Value := &Property.GetValue(Value.AsObject);
    end;
  end;
//  else if Field.FieldKind = fkCalculated then
//    Value := GetRecordInfoFromActiveBuffer.CalculedFieldBuffer[FCalculatedFields[Field]];

  if not Value.IsEmpty then
  begin
{$IFDEF PAS2JS}
    Result := Value.AsJSValue;

    if Field is TDateTimeField then
      Result := TJSDate.New(FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss"', Double(Result)));
{$ELSE}
    Result := True;

    if Assigned(Buffer) then
      if Field is TWideStringField then
      begin
        var StringValue := Value.AsString;

        StrLCopy(PChar(@Buffer[0]), @StringValue[1], StringValue.Length)
      end
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
      else
        Value.ExtractRawData(@Buffer[0]);
{$ENDIF}
  end;
end;

function TPersistoDataSet.GetObjects: TArray<TObject>;
begin
  Result := FObjectList.ToArray;
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
    gmCurrent: Result := grOk;
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
        else if FieldType in [ftString, ftWideString] then
          Result := Succ(dsMaxStringSize) * SizeOf(Char);
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
            tkWString,
{$ENDIF}
            tkChar,
            tkString: FieldType := ftWideString;

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
  if FieldCount = 0 then
  begin
    LoadedClasses := TList<TRttiInstanceType>.Create;

    FieldDefs.Clear;

    LoadFieldDefs(ObjectType, EmptyStr);

    LoadedClasses.Free;
  end
  else
    InitFieldDefsFromFields;
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
//
//
//  if FieldCount = 0 then
//    CreateFields;
//
//  CheckSelfFieldType;
//
//  LoadPropertiesFromFields;
//
  BindFields(True);

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

procedure TPersistoDataSet.Resync(Mode: TResyncMode);
begin
//  FIteratorData.Resync;
//
//  CheckIteratorData(False, False);

  inherited;
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
  FObjectList.Clear;

  if Assigned(Value) then
  begin
    FObjectList.AddRange(Value);

    ObjectClass := FObjectList.First.ClassType
  end;
end;

procedure TPersistoDataSet.SetObjectType(const Value: TRttiInstanceType);
begin
  CheckInactive;

  FieldDefs.Updated := False;
  FObjectType := Value;

  CheckObjectTypeLoaded;
end;

{ TPersistoObjectField }

constructor TPersistoObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftObject);

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

