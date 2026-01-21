unit Persisto.DataSet;

interface

uses System.Classes, System.Rtti, System.Generics.Collections, System.SysUtils, System.TypInfo, Persisto, Data.DB;

type
  TPersistoDataSet = class;

  EDataSetWithoutManager = class(Exception)
  public
    constructor Create;
  end;

  EDataSetWithoutObjectDefinition = class(Exception)
  public
    constructor Create;
  end;

  EDataSetWithoutClassDefinitionLoaded = class(Exception)
  public
    constructor Create;
  end;

  TPersistoBuffer = class
  public
    BookmarkFlag: TBookmarkFlag;
    CurrentObject: TObject;
    Position: NativeInt;
  end;

  TPersistoObjectField = class(TField)
  private
    FIOBuffer: TValueBuffer;

    function GetAsNativeInt: NativeInt;
    function GetAsObject: TObject;

    procedure SetAsObject(const Value: TObject);
    procedure SetAsNativeInt(const Value: NativeInt);
  protected
    function GetAsVariant: Variant; override;

    procedure SetVarValue(const Value: Variant); override;
  public
    constructor Create(AOwner: TComponent); override;

    property AsObject: TObject read GetAsObject write SetAsObject;
  end;

  TPersistoCursor = class
  private
    FCurrentPosition: NativeInt;
    FDataSet: TPersistoDataSet;

    function GetCurrentObject: TObject;
    function GetObjectCount: NativeInt;
    function Next: Boolean;
    function Prior: Boolean;
    function GetValidPosition: Boolean;

    procedure First;
    procedure Last;
    procedure SetCurrentObject(const Value: TObject);

    property CurrentObject: TObject read GetCurrentObject write SetCurrentObject;
    property CurrentPosition: NativeInt read FCurrentPosition write FCurrentPosition;
    property ObjectCount: NativeInt read GetObjectCount;
    property ValidPosition: Boolean read GetValidPosition;
  public
    constructor Create(const DataSet: TPersistoDataSet);
  end;

{$IFDEF DCC}
  [ComponentPlatformsAttribute(pidAllPlatforms)]
{$ENDIF}
  TPersistoDataSet = class(TDataSet)
  private
    FCursor: TPersistoCursor;
    FInsertingObject: TObject;
    FManager: TPersistoManager;
    FObjectClass: TClass;
    FObjectClassName: String;
    FObjectList: TList<TObject>;
    FObjectTable: TTable;

    function GetActivePersistoBuffer: TPersistoBuffer;
    function GetActiveObject: TObject;
    function GetFieldAndInstance(const Field: TField; var Instance: TObject; var PersistoField: Persisto.TField): Boolean;
    function GetParentDataSetField(var Instance: TObject; var PersistoField: Persisto.TField): Boolean;
    function GetParentDataSetFieldValue(var Value: TValue): Boolean;
    function GetObjects: TArray<TObject>;
    function HasValue(const PersistoField: Persisto.TField; const Instance: TObject; var Value: TValue): Boolean;

    procedure CheckManagerLoaded;
    procedure CheckObjectTypeLoaded;
    procedure LoadCursor;
    procedure LoadObjectTable;
    procedure SetActiveObject(const Value: TObject);
    procedure SetObjects(const Value: TArray<TObject>);
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; overload; override;
    function GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf); override;
    procedure DataConvert(Field: TField; Source: TValueBuffer; var Dest: TValueBuffer; ToNative: Boolean); override;
    procedure DataEvent(Event: TDataEvent; Info: NativeInt); override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
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
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;

    property ActivePersistoBuffer: TPersistoBuffer read GetActivePersistoBuffer;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;

    procedure Filter(Func: TFunc<TPersistoDataSet, Boolean>);

    property CurrentObject: TObject read GetActiveObject write SetActiveObject;
    property ObjectClass: TClass read FObjectClass write FObjectClass;
    property Objects: TArray<TObject> read GetObjects write SetObjects;
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
    property Manager: TPersistoManager read FManager write FManager;
    property ObjectClassName: String read FObjectClassName write FObjectClassName;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

implementation

uses System.Math, System.Variants, Persisto.Mapping, Data.DBConsts, {$IFDEF PAS2JS}JS{$ELSE}System.SysConst{$ENDIF};

type
  TFieldHelper = class helper for TField
  public
    function GetBufferSize: Integer;
  end;

{ TPersistoDataSet }

function TPersistoDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := TRecordBuffer(TPersistoBuffer.Create);
end;

function TPersistoDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  Result := True;
end;

procedure TPersistoDataSet.CheckManagerLoaded;
begin
  if not Assigned(FManager) then
    raise EDataSetWithoutManager.Create;
end;

procedure TPersistoDataSet.CheckObjectTypeLoaded;
begin
  if not Assigned(FObjectTable) then
    raise EDataSetWithoutObjectDefinition.Create;
end;

procedure TPersistoDataSet.ClearCalcFields({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf);
begin

end;

function TPersistoDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
const
  RetCodes: array[Boolean, Boolean] of ShortInt = ((2, -1),(1, 0));

var
  BookmarkData1: PNativeInt absolute Bookmark1;
  BookmarkData2: PNativeInt absolute Bookmark2;

begin
  Result := RetCodes[Bookmark1 = nil, Bookmark2 = nil];

  if Result = 2 then
    Result := BookmarkData1^ - BookmarkData2^;
end;

constructor TPersistoDataSet.Create(AOwner: TComponent);
begin
  inherited;

  BookmarkSize := SizeOf(NativeInt);
  FObjectList := TList<TObject>.Create;
{$IFDEF DCC}
  ObjectView := True;
{$ENDIF}
end;

procedure TPersistoDataSet.DataConvert(Field: TField; Source: TValueBuffer; var Dest: TValueBuffer; ToNative: Boolean);
begin
  Move(Source[0], Dest[0], Field.GetBufferSize);
end;

procedure TPersistoDataSet.DataEvent(Event: TDataEvent; Info: NativeInt);

  procedure LoadDetailObjects;
  begin
    var FieldValue: TValue;

    FObjectList.Clear;

    if GetParentDataSetFieldValue(FieldValue) then
      for var A := 0 to Pred(FieldValue.ArrayLength) do
        FObjectList.Add(FieldValue.GetReferenceToRawArrayElement(A));

    DataEvent(deDataSetChange, 0);
  end;

  procedure NotifyNestedDataSets;
  begin
    if not NestedDataSets.IsEmpty then
      DataEvent(deDataSetScroll, 0);
  end;

begin
  inherited;

  case Event of
    deParentScroll: LoadDetailObjects;
    deUpdateState: NotifyNestedDataSets;
  end;
end;

destructor TPersistoDataSet.Destroy;
begin
  FObjectList.Free;

  inherited;
end;

procedure TPersistoDataSet.Filter(Func: TFunc<TPersistoDataSet, Boolean>);
begin

end;

procedure TPersistoDataSet.LoadCursor;
begin
  FCursor := TPersistoCursor.Create(Self);
end;

procedure TPersistoDataSet.LoadObjectTable;
begin
  if Assigned(DataSetField) then
    FObjectTable := (DataSetField.DataSet as TPersistoDataSet).FObjectTable.Field[DataSetField.FieldName].ManyValueAssociation.ChildTable
  else
  begin
    CheckManagerLoaded;

    if not ObjectClassName.IsEmpty then
      FObjectTable := Manager.Mapper.GetTable(ObjectClassName)
    else if Assigned(ObjectClass) then
      FObjectTable := Manager.Mapper.GetTable(ObjectClass)
    else
      raise EDataSetWithoutClassDefinitionLoaded.Create;

    CheckObjectTypeLoaded;
  end;
end;

procedure TPersistoDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  PersistoBuffer.Free;
end;

function TPersistoDataSet.GetActiveObject: TObject;
begin
  CheckActive;

  Result := ActivePersistoBuffer.CurrentObject;
end;

function TPersistoDataSet.GetActivePersistoBuffer: TPersistoBuffer;
begin
  Result := TPersistoBuffer(ActiveBuffer);
end;

procedure TPersistoDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
var
  BookmarkData: PNativeInt absolute Data;
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  BookmarkData^ := PersistoBuffer.Position;
end;

function TPersistoDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  Result := PersistoBuffer.BookmarkFlag;
end;

function TPersistoDataSet.GetCurrentObject<T>: T;
begin
  Result := CurrentObject as T;
end;

function TPersistoDataSet.GetFieldAndInstance(const Field: TField; var Instance: TObject; var PersistoField: Persisto.TField): Boolean;
begin
  Result := Field.FieldKind <> fkCalculated;

  if Result then
  begin
    var CurrentTable := FObjectTable;
    Instance := CurrentObject;
    var ObjectFieldNames := Field.FieldName.Split(['.']);
    PersistoField := nil;
    var Value: TValue;

    var FieldValueName := ObjectFieldNames[High(ObjectFieldNames)];

    SetLength(ObjectFieldNames, High(ObjectFieldNames));

    for var FieldName in ObjectFieldNames do
    begin
      PersistoField := CurrentTable.Field[FieldName];
      CurrentTable := PersistoField.ForeignKey.ParentTable;

      if Assigned(Instance) then
        if HasValue(PersistoField, Instance, Value) then
          Instance := Value.AsObject
        else
          Instance := nil;
    end;

    Result := Assigned(Instance);

    if Result then
      PersistoField := CurrentTable.Field[FieldValueName];
  end;
end;

function TPersistoDataSet.GetFieldClass(FieldDef: TFieldDef): TFieldClass;
begin
  case FieldDef.DataType of
    ftObject: Result := TPersistoObjectField;
    else Result := inherited GetFieldClass(FieldDef);
  end;
end;

function TPersistoDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  var CurrentField: Persisto.TField := nil;
  var CurrentInstance: TObject := nil;
  Result := GetFieldAndInstance(Field, CurrentInstance, CurrentField);

  if Result then
  begin
    var Value: TValue;

    Result := HasValue(CurrentField, CurrentInstance, Value);

    if Result and (Buffer <> nil) then
      if Field is TWideStringField then
      begin
        var StringValue := Value.AsString + #0;

        StrLCopy(PWideChar(@Buffer[0]), @StringValue[1], StringValue.Length)
      end
      else
        Value.ExtractRawData(@Buffer[0]);
  end;
end;

function TPersistoDataSet.GetObjects: TArray<TObject>;
begin
  Result := FObjectList.ToArray;
end;

function TPersistoDataSet.GetParentDataSetField(var Instance: TObject; var PersistoField: Persisto.TField): Boolean;
begin
  Result := Assigned(DataSetField);

  if Result then
    Result := DataSetField.DataSet.Active and (DataSetField.DataSet as TPersistoDataSet).GetFieldAndInstance(DataSetField, Instance, PersistoField);
end;

function TPersistoDataSet.GetParentDataSetFieldValue(var Value: TValue): Boolean;
begin
  var Instance: TObject := nil;
  var PersistoField: Persisto.TField := nil;
  Result := GetParentDataSetField(Instance, PersistoField) and HasValue(PersistoField, Instance, Value);
end;

function TPersistoDataSet.GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

  procedure UpdateBuffer(const Update: Boolean; const ResultValue: TGetResult);
  begin
    if Update and (Objects <> nil) then
    begin
      PersistoBuffer.BookmarkFlag := bfCurrent;

      if FCursor.ValidPosition then
      begin
        PersistoBuffer.CurrentObject := FCursor.CurrentObject;
        PersistoBuffer.Position := FCursor.CurrentPosition;
        Result := grOk;
      end
      else
        Result := grError;
    end
    else
      Result := ResultValue;
  end;

begin
  case GetMode of
    gmNext: UpdateBuffer(FCursor.Next, grEOF);
    gmPrior: UpdateBuffer(FCursor.Prior, grBOF);
    else UpdateBuffer(GetMode = gmCurrent, grError);
  end;
end;

function TPersistoDataSet.GetRecordCount: Integer;
begin
  CheckActive;

  Result := FCursor.ObjectCount;
end;

function TPersistoDataSet.HasValue(const PersistoField: Persisto.TField; const Instance: TObject; var Value: TValue): Boolean;
begin
  Result := PersistoField.HasValue(Instance, Value);

  if PersistoField.IsLazy then
    Value := PersistoField.LazyValue[Instance].Value;
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

  FInsertingObject := FObjectTable.ClassTypeInfo.MetaclassType.Create;

  ActivePersistoBuffer.CurrentObject := FInsertingObject;
end;

procedure TPersistoDataSet.InternalCancel;
begin
  inherited;

end;

procedure TPersistoDataSet.InternalClose;
begin
  FreeAndNil(FCursor);
end;

procedure TPersistoDataSet.InternalDelete;
begin

end;

procedure TPersistoDataSet.InternalEdit;
begin
  inherited;

end;

procedure TPersistoDataSet.InternalFirst;
begin
  FCursor.First;
end;

procedure TPersistoDataSet.InternalGotoBookmark(Bookmark: TBookmark);
var
  BookmarkData: PNativeInt absolute Bookmark;

begin
  FCursor.CurrentPosition := BookmarkData^;
end;

procedure TPersistoDataSet.InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF};
begin

end;

procedure TPersistoDataSet.InternalInitFieldDefs;

  function GetFieldSize(const Field: Persisto.TField): Integer;
  begin
    case Field.DatabaseType of
      ftGUID: Result := dsGuidStringLength;
      ftString, ftWideString: Result := Max(Field.Size, 1);
      else Result := 0;
    end;
  end;

begin
  LoadObjectTable;

  for var Field in FObjectTable.Fields do
    TFieldDef.Create(FieldDefs, Field.Name, Field.DatabaseType, GetFieldSize(Field), False, FieldDefs.Count);
end;

procedure TPersistoDataSet.InternalLast;
begin
  FCursor.Last;
end;

procedure TPersistoDataSet.InternalOpen;
begin
  FieldDefs.Updated := False;

  InitFieldDefsFromFields;

  FieldDefs.Update;

  CreateFields;

  BindFields(True);

  LoadCursor;
end;

procedure TPersistoDataSet.InternalPost;

  procedure UpdateParentRecord;
  begin
    var Instance: TObject;
    var PersistoField: Persisto.TField;

    if GetParentDataSetField(Instance, PersistoField) then
    begin
      var FieldValue := PersistoField.Value[Instance];
      FieldValue.ArrayLength := FObjectList.Count;

      for var A := 0 to Pred(FObjectList.Count) do
        FieldValue.SetArrayElement(A, FObjectList[A]);

      PersistoField.Value[Instance] := FieldValue;
    end;
  end;

begin
  inherited;

  if Assigned(FInsertingObject) then
  begin
    if GetBookmarkFlag(ActiveBuffer) <> bfCurrent then
      FCursor.CurrentPosition := FObjectList.Add(FInsertingObject)
    else
      FObjectList.Insert(FCursor.CurrentPosition, FInsertingObject);

    UpdateParentRecord;
  end;
end;

function TPersistoDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FCursor);
end;

procedure TPersistoDataSet.SetActiveObject(const Value: TObject);
begin
  ActivePersistoBuffer.CurrentObject := Value;
  FCursor.CurrentObject := Value;

  DataEvent(deRecordChange, 0);
end;

procedure TPersistoDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark);
var
  BookmarkData: PNativeInt absolute Data;
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  PersistoBuffer.BookmarkFlag := bfCurrent;
  PersistoBuffer.Position := BookmarkData^;
end;

procedure TPersistoDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
var
  PersistoBuffer: TPersistoBuffer absolute Buffer;

begin
  PersistoBuffer.BookmarkFlag := Value;
end;

procedure TPersistoDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin
  if not (State in dsWriteModes) then
    DatabaseError(SNotEditing, Self);

  var CurrentField: Persisto.TField := nil;
  var CurrentInstance: TObject := nil;
  var Value: TValue;

  if GetFieldAndInstance(Field, CurrentInstance, CurrentField) then
  begin
    if Field is TWideStringField then
      Value := TValue.From(String(PWideChar(Buffer)))
    else
      Value := TValue.From(CurrentField.PropertyInfo.PropertyType.Handle, Buffer[0]);

    CurrentField.Value[CurrentInstance] := Value;

    DataEvent(deFieldChange, IntPtr(Field));
  end;
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

{ TPersistoObjectField }

constructor TPersistoObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetLength(FIOBuffer, SizeOf(NativeInt));

  SetDataType(ftObject);
end;

function TPersistoObjectField.GetAsNativeInt: NativeInt;
begin
  GetData(FIOBuffer, True);

  Result := PNativeInt(@FIOBuffer[0])^;
end;

function TPersistoObjectField.GetAsObject: TObject;
begin
  Result := TObject(GetAsNativeInt);
end;

function TPersistoObjectField.GetAsVariant: Variant;
begin
  Result := GetAsNativeInt;
end;

procedure TPersistoObjectField.SetAsNativeInt(const Value: NativeInt);
begin
  Move(Value, FIOBuffer[0], SizeOf(Value));

  SetData(FIOBuffer, True);
end;

procedure TPersistoObjectField.SetAsObject(const Value: TObject);
begin
  SetAsNativeInt(NativeInt(Value));
end;

procedure TPersistoObjectField.SetVarValue(const Value: Variant);
begin
  SetAsNativeInt(Value);
end;

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('The class definition wasn''t found!');
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
  CurrentPosition := -1;
end;

function TPersistoCursor.GetCurrentObject: TObject;
begin
  Result := FDataSet.Objects[CurrentPosition];
end;

function TPersistoCursor.GetObjectCount: NativeInt;
begin
  Result := Length(FDataSet.Objects);
end;

function TPersistoCursor.GetValidPosition: Boolean;
begin
  Result := (CurrentPosition > -1) and (CurrentPosition < ObjectCount);
end;

procedure TPersistoCursor.Last;
begin
  CurrentPosition := ObjectCount;
end;

function TPersistoCursor.Next: Boolean;
begin
  Inc(FCurrentPosition);

  Result := CurrentPosition < ObjectCount;

  if not Result then
    CurrentPosition := Pred(ObjectCount);
end;

function TPersistoCursor.Prior: Boolean;
begin
  Dec(FCurrentPosition);

  Result := CurrentPosition > -1;

  if not Result then
    CurrentPosition := 0;
end;

procedure TPersistoCursor.SetCurrentObject(const Value: TObject);
begin
  FDataSet.FObjectList[CurrentPosition] := Value;
end;

{ EDataSetWithoutManager }

constructor EDataSetWithoutManager.Create;
begin
  inherited Create('Must load the Manager property with a valid value!');
end;

{ TFieldHelper }

function TFieldHelper.GetBufferSize: Integer;
begin
  Result := GetIOSize;
end;

{ EDataSetWithoutClassDefinitionLoaded }

constructor EDataSetWithoutClassDefinitionLoaded.Create;
begin
  inherited Create('Must load a object information property like ObjectClass or ObjectClassName!');
end;

end.

