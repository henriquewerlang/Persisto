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

  TPersistoBuffer = class
  public
    CurrentObject: TObject;
  end;

  TPersistoObjectField = class(TField)
  private
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

  TPersistoFieldList = class(TFieldList)
  protected
    function FindItem(const Name: string; MustExist: Boolean): TObject; override;
  end;

{$IFDEF DCC}
  [ComponentPlatformsAttribute(pidAllPlatforms)]
{$ENDIF}
  TPersistoDataSet = class(TDataSet)
  private
    FCursor: IPersistoCursor;
    FIndexFieldNames: String;
    FInsertingObject: TObject;
    FIOBuffer: TValueBuffer;
    FManager: TPersistoManager;
    FObjectClass: TClass;
    FObjectClassName: String;
    FObjectList: TList<TObject>;
    FObjectTable: TTable;

    function GetActivePersistoBuffer: TPersistoBuffer;
    function GetActiveObject: TObject;
    function GetObjects: TArray<TObject>;

    procedure CheckManagerLoaded;
    procedure CheckObjectTypeLoaded;
    procedure LoadCursor;
    procedure LoadObjectTable;
    procedure SetIndexFieldNames(const Value: String);
    procedure SetObjects(const Value: TArray<TObject>);
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; overload; override;
    function GetFieldListClass: TFieldListClass; override;
    function GetRecNo: Integer; override;
    function GetRecord({$IFDEF PAS2JS}var {$ENDIF}Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure CheckInactive; override;
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
    property IndexFieldNames: String read FIndexFieldNames write SetIndexFieldNames;
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

uses System.Math, Persisto.Mapping, {$IFDEF PAS2JS}JS{$ELSE}System.SysConst{$ENDIF};

{ TPersistoDataSet }

function TPersistoDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := TRecordBuffer(TPersistoBuffer.Create);
end;

procedure TPersistoDataSet.CheckInactive;
begin
  if not TPersistoFieldList(FieldList).Locked then
    inherited;
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

constructor TPersistoDataSet.Create(AOwner: TComponent);
begin
  inherited;

  FObjectList := TList<TObject>.Create;
{$IFDEF DCC}
  ObjectView := True;
{$ENDIF}
end;

procedure TPersistoDataSet.DataEvent(Event: TDataEvent; Info: {$IFDEF PAS2JS}JSValue{$ELSE}NativeInt{$ENDIF});
begin
  inherited;

end;

destructor TPersistoDataSet.Destroy;
begin
  FObjectList.Free;

  inherited;
end;

procedure TPersistoDataSet.DoAfterOpen;
begin

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
  CheckManagerLoaded;

  if not ObjectClassName.IsEmpty then
    FObjectTable := Manager.Mapper.GetTable(ObjectClassName)
  else if Assigned(ObjectClass) then
    FObjectTable := Manager.Mapper.GetTable(ObjectClass);

  CheckObjectTypeLoaded;
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
begin

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
  Value: TValue;

  procedure CheckBufferSize;
  begin
    var BufferSize := Length(FIOBuffer);

    if BufferSize < Field.DataSize then
      SetLength(FIOBuffer, Field.DataSize);

    Buffer := FIOBuffer;
  end;

begin
  Result := Field.FieldKind <> fkCalculated;

  if Result then
  begin
    var CurrentField: Persisto.TField;
    var CurrentInstance := CurrentObject;
    var CurrentTable := FObjectTable;
    var ObjectFieldNames := Field.FieldName.Split(['.']);
    Result := False;

    var FieldValueName := ObjectFieldNames[High(ObjectFieldNames)];

    SetLength(ObjectFieldNames, High(ObjectFieldNames));

    for var FieldName in ObjectFieldNames do
    begin
      CurrentField := CurrentTable.Field[FieldName];
      CurrentTable := CurrentField.ForeignKey.ParentTable;

      if Assigned(CurrentInstance) then
        if CurrentField.HasValue(CurrentInstance, Value) then
          CurrentInstance := Value.AsObject
        else
        begin
          CurrentInstance := nil;

          Break;
        end;
    end;

    if Assigned(CurrentInstance) then
    begin
      Result := CurrentTable.Field[FieldValueName].HasValue(CurrentInstance, Value);

      if Result then
      begin
        CheckBufferSize;

        if Field is TWideStringField then
        begin
          var StringValue := Value.AsString;

          StrLCopy(PWideChar(@Buffer[0]), @StringValue[1], StringValue.Length)
        end
        else
          Value.ExtractRawData(@Buffer[0]);
      end;
    end;
  end;
end;

function TPersistoDataSet.GetFieldListClass: TFieldListClass;
begin
  Result := TPersistoFieldList;
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

  FInsertingObject := FObjectTable.ClassTypeInfo.MetaclassType.Create;

  ActivePersistoBuffer.CurrentObject := FInsertingObject;
end;

procedure TPersistoDataSet.InternalCancel;
begin
  inherited;

end;

procedure TPersistoDataSet.InternalClose;
begin
  FCursor := nil;
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
begin

end;

procedure TPersistoDataSet.InternalHandleException{$IFDEF PAS2JS}(E: Exception){$ENDIF};
begin

end;

procedure TPersistoDataSet.InternalInitFieldDefs;
begin
  if not (csDesigning in ComponentState) then
    LoadObjectTable;
end;

procedure TPersistoDataSet.InternalLast;
begin
  FCursor.Last;
end;

procedure TPersistoDataSet.InternalOpen;
begin
  if csDesigning in ComponentState then
    Exit;

  if not FieldDefs.Updated then
    FieldDefs.Update;

  LoadCursor;

  InitFieldDefsFromFields;

  BindFields(True);
end;

procedure TPersistoDataSet.InternalPost;
begin
  inherited;

  FObjectList.Add(nil);
end;

procedure TPersistoDataSet.InternalSetToRecord(Buffer: TRecBuf);
begin

end;

function TPersistoDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FCursor);
end;

procedure TPersistoDataSet.Resync(Mode: TResyncMode);
begin

  inherited;
end;

procedure TPersistoDataSet.SetDataSetField(const DataSetField: TDataSetField);
begin

  inherited;
end;

procedure TPersistoDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin

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

  SetDataType(ftObject);
end;

function TPersistoObjectField.GetAsObject: TObject;
begin
  Result := nil;
end;

procedure TPersistoObjectField.SetAsObject(const Value: TObject);
begin
end;

{ EDataSetWithoutObjectDefinition }

constructor EDataSetWithoutObjectDefinition.Create;
begin
  inherited Create('Must load a object information property like ObjectClass or ObjectClassName!');
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

{ TPersistoFieldList }

function TPersistoFieldList.FindItem(const Name: string; MustExist: Boolean): TObject;

  function GetFieldSize(const Field: Persisto.TField): Integer;
  begin
    case Field.DatabaseType of
      ftGUID: Result := dsGuidStringLength;
      ftString, ftWideString: Result := Max(Field.Size, 1);
      else Result := 0;
    end;
  end;

begin
  Result := inherited FindItem(Name, False);

  if not Assigned(Result) then
  begin
    var Field := TPersistoDataSet(DataSet).FObjectTable.Field[Name];
    var FieldDef := TFieldDef.Create(DataSet.FieldDefs, Name, Field.DatabaseType, GetFieldSize(Field), False, DataSet.FieldDefs.Count);

    Locked := True;

    var DataSetField := FieldDef.CreateField(DataSet);
    DataSetField.DataSet := DataSet;

    Locked := False;
    Result := DataSetField;
  end;
end;

{ EDataSetWithoutManager }

constructor EDataSetWithoutManager.Create;
begin
  inherited Create('Must load the Manager property with a valid value!');
end;

end.

