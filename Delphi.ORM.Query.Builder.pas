unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Nullable, Delphi.ORM.Cache,
  Delphi.ORM.Attributes;

type
  TQueryBuilder = class;
  TQueryBuilderAllFields = class;
  TQueryBuilderComparison = class;
  TQueryBuilderFieldAlias = class;
  TQueryBuilderFrom = class;
  TQueryBuilderJoin = class;
  TQueryBuilderOpen = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere = class;
  TQueryBuilderWhere<T: class> = class;

  ECantFilterManyValueAssociation = class(Exception)
  public
    constructor Create(Field: TField);
  end;

  EFieldNotFoundInTable = class(Exception)
  public
    constructor Create(FieldName: String);
  end;

  EObjectReferenceWasNotFound = class(Exception)
  public
    constructor Create;
  end;

  ECommandWithoutFromClause = class(Exception)
  public
    constructor Create;
  end;

  TBuilderOptions = set of (boBeautifyQuery, boJoinMapping, boDestroyForeignObjects);

  IQueryBuilderCommand = interface
    function GetSQL: String;
  end;

  IQueryBuilderAccess = interface
    ['{33A7B162-42DF-4BC6-BDA4-AB35D00050F0}']
    function GetBuilder: TQueryBuilder;
    function GetCache: ICache;
    function GetConnection: IDatabaseConnection;
    function GetField(const QueryField: TQueryBuilderFieldAlias): String; overload;
    function GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String; overload;
    function GetFields: TArray<TFieldAlias>;
    function GetIdention(Count: Integer; const MinimalIdention: Boolean = True): String;
    function GetJoin: TQueryBuilderJoin;
    function GetLineBreak: String;
    function GetTable: TTable;
    function OpenCursor: IDatabaseCursor;

    property Builder: TQueryBuilder read GetBuilder;
    property Cache: ICache read GetCache;
    property Connection: IDatabaseConnection read GetConnection;
    property Fields: TArray<TFieldAlias> read GetFields;
    property Join: TQueryBuilderJoin read GetJoin;
    property LineBreak: String read GetLineBreak;
    property Table: TTable read GetTable;
  end;

  TQueryBuilder = class(TNoRefCountObject, IQueryBuilderAccess)
  private
    FCache: ICache;
    FConnection: IDatabaseConnection;
    FDestroyObjects: TDictionary<TObject, Boolean>;
    FFieldList: TQueryBuilderAllFields;
    FFrom: TQueryBuilderFrom;
    FOpen: TQueryBuilderOpen;
    FOptions: TBuilderOptions;
    FProcessedObjects: TDictionary<TObject, TObject>;
    FSelect: IQueryBuilderCommand;
    FTable: TTable;
    FUpdateObject: TList<TObject>;
    FWhere: IQueryBuilderCommand;

    function BuildPrimaryKeyFilter(const Table: TTable; const AObject: TObject): String;
    function ExecuteInTrasaction(const Func: TFunc<TObject>): TObject;
    function FindJoinInheritedLink(const Join: TQueryBuilderJoin): TQueryBuilderJoin;
    function FindJoinLink(const Join: TQueryBuilderJoin; const FieldName: String): TQueryBuilderJoin;
    function GetBuilder: TQueryBuilder;
    function GetCache: ICache;
    function GetConnection: IDatabaseConnection;
    function GetField(const QueryField: TQueryBuilderFieldAlias): String; overload;
    function GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String; overload;
    function GetFields: TArray<TFieldAlias>;
    function GetIdention(Count: Integer; const MinimalIdention: Boolean = True): String;
    function GetJoin: TQueryBuilderJoin;
    function GetLineBreak: String;
    function GetTable: TTable;
    function InsertObject(const AObject: TValue): TObject;
    function OpenCursor: IDatabaseCursor;
    function SaveObject(const AObject: TValue): TObject;
    function UpdateObject(const AObject: TValue): TObject;

    procedure AddObjectToDestruction(const CurrentObject, ForeignObject: TObject);
    procedure SaveForeignKeys(const Table: TTable; const ForeignObject: TObject);
    procedure SaveManyValueAssociations(const Table: TTable; const CurrentObject, ForeignObject: TObject);
  public
    constructor Create(const Connection: IDatabaseConnection; const Cache: ICache);

    destructor Destroy; override;

    function GetSQL: String;
    function Insert<T: class>(const AObject: T): T;
    function Save<T: class>(const AObject: T): T;
    function Select: TQueryBuilderSelect;
    function Update<T: class>(const AObject: T): T;

    procedure Delete<T: class>(const AObject: T);

    property Connection: IDatabaseConnection read FConnection;
    property Options: TBuilderOptions read FOptions write FOptions;
  end;

  TQueryBuilderFrom = class
  private
    FAccess: IQueryBuilderAccess;
    FJoin: TQueryBuilderJoin;
    FRecursivityLevel: Word;
    FTableIndexJoin: Integer;

    function BuildJoinSQL: String;
    function CreateJoin(const CurrentJoin: TQueryBuilderJoin; const Table: TTable; const Field, LeftField, RightField: TField; const IsInheritedLink, MakeLink: Boolean): TQueryBuilderJoin;
    function CreateJoinForeignKey(const CurrentJoin: TQueryBuilderJoin; const ForeignKey: TForeignKey; const MakeLink: Boolean): TQueryBuilderJoin;
    function CreateJoinManyValueAssociation(const CurrentJoin: TQueryBuilderJoin; const ManyValueAssociation: TManyValueAssociation; const MakeLink: Boolean): TQueryBuilderJoin;
    function CreateJoinTable(const Table: TTable): TQueryBuilderJoin;
    function MakeJoinSQL(const Join: TQueryBuilderJoin; const JoinInfo: String): String;

    procedure BuildJoin;
    procedure MakeJoin(const Join: TQueryBuilderJoin; RecursionControl: TDictionary<TTable, Word>; const ManyValueAssociationToIgnore: TManyValueAssociation);
  public
    constructor Create(const Access: IQueryBuilderAccess; const RecursivityLevel: Word);

    destructor Destroy; override;

    function From<T: class>: TQueryBuilderWhere<T>; overload;
    function From<T: class>(Table: TTable): TQueryBuilderWhere<T>; overload;
    function GetSQL: String;

    property Join: TQueryBuilderJoin read FJoin;
  end;

  TQueryBuilderJoin = class
  private
    FAlias: String;
    FField: TField;
    FFilterLinks: TArray<TQueryBuilderJoin>;
    FIsInheritedLink: Boolean;
    FLeftField: TField;
    FLinks: TArray<TQueryBuilderJoin>;
    FRightField: TField;
    FTable: TTable;

    function GetAllLinks: TArray<TQueryBuilderJoin>;
  public
    constructor Create(const Table: TTable); overload;
    constructor Create(const Table: TTable; const Field, LeftField, RightField: TField; const IsInheritedLink: Boolean); overload;

    destructor Destroy; override;

    property Alias: String read FAlias write FAlias;
    property AllLinks: TArray<TQueryBuilderJoin> read GetAllLinks;
    property Field: TField read FField write FField;
    property FilterLinks: TArray<TQueryBuilderJoin> read FFilterLinks write FFilterLinks;
    property IsInheritedLink: Boolean read FIsInheritedLink write FIsInheritedLink;
    property LeftField: TField read FLeftField write FLeftField;
    property Links: TArray<TQueryBuilderJoin> read FLinks write FLinks;
    property RightField: TField read FRightField write FRightField;
    property Table: TTable read FTable write FTable;
  end;

  TQueryBuilderOpen = class

  end;

  TQueryBuilderOpen<T: class> = class(TQueryBuilderOpen)
  private
    FLoader: TObject;
  public
    constructor Create(const Access: IQueryBuilderAccess);

    destructor Destroy; override;

    function All: TArray<T>;
    function One: T;
  end;

  TQueryBuilderAllFields = class
  private
    FAccess: IQueryBuilderAccess;

    function GetAllFields(const Join: TQueryBuilderJoin): TArray<TFieldAlias>;
    function GetFields: TArray<TFieldAlias>;
  public
    constructor Create(const Access: IQueryBuilderAccess);
  end;

  TQueryBuilderSelect = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FAccess: IQueryBuilderAccess;
    FFirstRecords: Cardinal;
    FRecursivityLevel: Word;

    function GetFieldsWithAlias: String;
  public
    constructor Create(const Access: IQueryBuilderAccess);

    destructor Destroy; override;

    function All: TQueryBuilderFrom;
    function GetSQL: String;
    function RecursivityLevel(const Level: Word): TQueryBuilderSelect;
    function First(const Total: Cardinal): TQueryBuilderSelect;

    property FirstRecords: Cardinal read FFirstRecords;
    property RecursivityLevelValue: Word read FRecursivityLevel;
  end;

  TQueryBuilderFieldAlias = class
  private
    FFieldNames: TArray<String>;
    FFieldName: String;
  public
    constructor Create(const FieldName: String);

    property FieldName: String read FFieldName;
    property FieldNames: TArray<String> read FFieldNames;
  end;

  TQueryBuilderOrderByField = class(TQueryBuilderFieldAlias)
  private
    FAscending: Boolean;
  public
    constructor Create(const FieldName: String; const Ascending: Boolean);

    property Ascending: Boolean read FAscending;
  end;

  TQueryBuilderComparisonOperator = (qbcoNone, qbcoEqual, qbcoNotEqual, qbcoGreaterThan, qbcoGreaterThanOrEqual, qbcoLessThan, qbcoLessThanOrEqual, qbcoNull, qbcoNotNull,
    qbcoBetween, qbcoLike);

  TQueryBuilderLogicalOperator = (qloNone, qloAnd, qloOr);

  TQueryBuilderComparison = class
  private
    FComparison: TQueryBuilderComparisonOperator;
    FField: TQueryBuilderFieldAlias;
    FLeft: TQueryBuilderComparison;
    FLogical: TQueryBuilderLogicalOperator;
    FRight: TQueryBuilderComparison;
    FValue: TValue;

    function GetLeft: TQueryBuilderComparison;
    function GetRight: TQueryBuilderComparison;
  public
    destructor Destroy; override;

    property Comparison: TQueryBuilderComparisonOperator read FComparison write FComparison;
    property Field: TQueryBuilderFieldAlias read FField write FField;
    property Left: TQueryBuilderComparison read GetLeft write FLeft;
    property Logical: TQueryBuilderLogicalOperator read FLogical write FLogical;
    property Right: TQueryBuilderComparison read GetRight write FRight;
    property Value: TValue read FValue write FValue;
  end;

  TQueryBuilderComparisonHelper = record
  private
    class procedure MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left, Right: TQueryBuilderComparisonHelper; var Result: TQueryBuilderComparisonHelper); overload; static;
    class procedure MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left: TQueryBuilderComparisonHelper; const Right: TValue; var Result: TQueryBuilderComparisonHelper); overload; static;
  public
    Comparison: TQueryBuilderComparison;

    function Between<T>(const ValueStart, ValueEnd: T): TQueryBuilderComparisonHelper;
    function IsLoaded: Boolean;
    function Like(const Value: String): TQueryBuilderComparisonHelper;

    class function Create: TQueryBuilderComparisonHelper; static;

    class operator BitwiseAnd(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator BitwiseOr(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator Equal(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator Equal(const Left: TQueryBuilderComparisonHelper; const Value: TNullEnumerator): TQueryBuilderComparisonHelper;
    class operator Equal(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator Equal(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
    class operator GreaterThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator GreaterThan(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator GreaterThan(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
    class operator GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator GreaterThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator GreaterThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
    class operator LessThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator LessThan(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator LessThan(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
    class operator LessThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator LessThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator LessThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
    class operator NotEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: TNullEnumerator): TQueryBuilderComparisonHelper;
    class operator NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
    class operator NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
  end;

  TQueryBuilderOrderBy = class
  private
    FAccess: IQueryBuilderAccess;
    FFields: TArray<TQueryBuilderOrderByField>;

    constructor Create(const Access: IQueryBuilderAccess);
  public
    destructor Destroy; override;

    function Field(const FieldName: String; const Ascending: Boolean = True): TQueryBuilderOrderBy;
    function GetSQL: String;

    property Fields: TArray<TQueryBuilderOrderByField> read FFields;
  end;

  TQueryBuilderOrderBy<T: class> = class(TQueryBuilderOrderBy)
  public
    function Field(const FieldName: String; const Ascending: Boolean = True): TQueryBuilderOrderBy<T>;
    function Open: TQueryBuilderOpen<T>;
  end;

  TQueryBuilderWhere = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FAccess: IQueryBuilderAccess;
    FFilter: String;
    FOrderBy: TQueryBuilderOrderBy;

    function GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function MakeComparison(const Comparison: TQueryBuilderComparison): String;
    function MakeFilter(const Value: TQueryBuilderComparison): String;
    function MakeLogical(const Logical: TQueryBuilderComparison): String;

    procedure BuildFilter(const Value: TQueryBuilderComparisonHelper);
  public
    constructor Create(const Access: IQueryBuilderAccess);

    destructor Destroy; override;

    function GetSQL: String;
    function Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere;
  end;

  TQueryBuilderWhere<T: class> = class(TQueryBuilderWhere)
  public
    function Open: TQueryBuilderOpen<T>;
    function OrderBy: TQueryBuilderOrderBy<T>;
    function Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
  end;

function Field(const Name: String): TQueryBuilderComparisonHelper;

implementation

uses System.TypInfo, System.SysConst, Delphi.ORM.Rtti.Helper, Delphi.ORM.Classes.Loader;

function Field(const Name: String): TQueryBuilderComparisonHelper;
begin
  Result.Comparison := TQueryBuilderComparison.Create;
  Result.Comparison.Field := TQueryBuilderFieldAlias.Create(Name);
end;

{ TQueryBuilder }

procedure TQueryBuilder.AddObjectToDestruction(const CurrentObject, ForeignObject: TObject);
begin
  if (boDestroyForeignObjects in Options) and (CurrentObject <> ForeignObject) then
    FDestroyObjects.AddOrSetValue(ForeignObject, False);
end;

function TQueryBuilder.BuildPrimaryKeyFilter(const Table: TTable; const AObject: TObject): String;
begin
  FSelect := nil;
  FTable := Table;
  Result := EmptyStr;

  if Assigned(Table.PrimaryKey) then
  begin
    var Condition := Field(Table.PrimaryKey.DatabaseName) = Table.PrimaryKey.GetValue(AObject);
    var Where := TQueryBuilderWhere.Create(Self);

    Result := Where.Where(Condition).GetSQL;
  end;
end;

constructor TQueryBuilder.Create(const Connection: IDatabaseConnection; const Cache: ICache);
begin
  inherited Create;

  FCache := Cache;
  FConnection := Connection;
  FDestroyObjects := TObjectDictionary<TObject, Boolean>.Create([doOwnsKeys]);
  FProcessedObjects := TDictionary<TObject, TObject>.Create;
  FUpdateObject := TList<TObject>.Create;
end;

procedure TQueryBuilder.Delete<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    function: TObject
    begin
      var Table := TMapper.Default.FindTable(AObject.ClassType);

      FConnection.ExecuteDirect(Format('delete from %s%s', [Table.DatabaseName, BuildPrimaryKeyFilter(Table, AObject)]));
    end);
end;

destructor TQueryBuilder.Destroy;
begin
  FDestroyObjects.Free;

  FProcessedObjects.Free;

  FUpdateObject.Free;

  inherited;
end;

function TQueryBuilder.ExecuteInTrasaction(const Func: TFunc<TObject>): TObject;
begin
  var Transaction := Connection.StartTransaction;

  try
    Result := Func;

    while FUpdateObject.Count > 0 do
      SaveObject(FUpdateObject.ExtractAt(0));

    Transaction.Commit;

    FDestroyObjects.Clear;

    FProcessedObjects.Clear;
  except
    Transaction.Rollback;

    raise;
  end;
end;

function TQueryBuilder.FindJoinInheritedLink(const Join: TQueryBuilderJoin): TQueryBuilderJoin;
begin
  Result := nil;

  for var Link in Join.Links do
    if Link.IsInheritedLink then
      Exit(Link);
end;

function TQueryBuilder.FindJoinLink(const Join: TQueryBuilderJoin; const FieldName: String): TQueryBuilderJoin;
begin
  Result := nil;

  if Assigned(Join) then
  begin
    var Field: TField;

    for var Link in Join.AllLinks do
      if Link.Field.Name = FieldName then
        Exit(Link);

    if Join.Table.FindField(FieldName, Field) then
      if Field.IsManyValueAssociation then
        raise ECantFilterManyValueAssociation.Create(Field)
      else
        Exit(FFrom.CreateJoinForeignKey(Join, Field.ForeignKey, False));

    Result := FindJoinLink(FindJoinInheritedLink(Join), FieldName);
  end;
end;

function TQueryBuilder.InsertObject(const AObject: TValue): TObject;
begin
  var FieldValue: TValue;
  var FieldStringValue: String;
  var HasValue: Boolean;
  var OutputFieldList: TArray<TField> := nil;
  var OutputFieldNameList: TArray<String> := nil;
  Result := AObject.AsObject;
  var SQL := '(%s)values(%s)';
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);

  var Changes := FCache.ChangeManager.Changes[Result];

  FProcessedObjects.TryAdd(Result, nil);

  SaveForeignKeys(Table, Result);

  for var Field in Table.Fields do
  begin
    HasValue := Field.HasValue(Result, FieldValue);

    if Field.AutoGenerated and not HasValue then
    begin
      OutputFieldList := OutputFieldList + [Field];
      OutputFieldNameList := OutputFieldNameList + [Field.DatabaseName];
    end
    else if not HasValue then
      Changes[Field] := 'null'
    else if not Field.IsManyValueAssociation and not Field.IsReadOnly then
    begin
      if Field.IsForeignKey and FieldValue.IsObject then
      begin
        var ForeignKeyObject := FProcessedObjects[FieldValue.AsObject];

        if not Assigned(ForeignKeyObject) then
        begin
          Changes[Field] := 'null';

          FUpdateObject.Add(Result);

          Continue;
        end
        else
        begin
          FieldValue := ForeignKeyObject;

          Field.SetValue(Result, FieldValue);
        end;
      end;

      if not Field.IsForeignKey or not FieldValue.IsObject or Field.ForeignKey.ParentTable.PrimaryKey.HasValue(FieldValue.AsObject, FieldValue) then
      begin
        FieldStringValue := Field.GetAsString(FieldValue);

        Changes[Field] := FieldStringValue;
        SQL := Format(SQL, [Field.DatabaseName + '%2:s%0:s', FieldStringValue + '%2:s%1:s', ',']);
      end;
    end;
  end;

  var Cursor := FConnection.ExecuteInsert(Format('insert into %s%s', [Table.DatabaseName, Format(SQL, ['', '', '', ''])]), OutputFieldNameList);

  if Cursor.Next then
    for var A := Low(OutputFieldList) to High(OutputFieldList) do
    begin
      OutputFieldList[A].SetValue(Result, Cursor.GetFieldValue(A));

      Changes[OutputFieldList[A]] := OutputFieldList[A].GetAsString(Result);
    end;

  if Table.ClassTypeInfo.MetaclassType = Result.ClassType then
    FCache.Add(Table.GetCacheKey(Result), Result);

  FProcessedObjects[Result] := Result;

  SaveManyValueAssociations(Table, Result, Result);
end;

function TQueryBuilder.OpenCursor: IDatabaseCursor;
begin
  Result := FConnection.OpenCursor(GetSQL);
end;

function TQueryBuilder.Insert<T>(const AObject: T): T;
begin
  Result := ExecuteInTrasaction(
    function: TObject
    begin
      Result := InsertObject(AObject);
    end) as T;
end;

function TQueryBuilder.GetBuilder: TQueryBuilder;
begin
  Result := Self;
end;

function TQueryBuilder.GetCache: ICache;
begin
  Result := FCache;
end;

function TQueryBuilder.GetConnection: IDatabaseConnection;
begin
  Result := FConnection;
end;

function TQueryBuilder.GetField(const QueryField: TQueryBuilderFieldAlias): String;
var
  Field: TField;

begin
  Result := GetField(QueryField, Field);
end;

function TQueryBuilder.GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String;
begin
  var CurrentJoin := GetJoin;
  Field := nil;
  var FieldName := QueryField.FieldNames[High(QueryField.FieldNames)];
  var FieldNames := QueryField.FieldNames;
  Result := EmptyStr;

  SetLength(FieldNames, High(QueryField.FieldNames));

  if Assigned(CurrentJoin) then
  begin
    for var LinkName in FieldNames do
    begin
      CurrentJoin := FindJoinLink(CurrentJoin, LinkName);

      if not Assigned(CurrentJoin) then
        raise EFieldNotFoundInTable.Create(LinkName);
    end;

    while Assigned(CurrentJoin) and not CurrentJoin.Table.FindField(FieldName, Field) do
      CurrentJoin := FindJoinInheritedLink(CurrentJoin);

    if Assigned(Field) then
      Exit(Format('%s.%s', [CurrentJoin.Alias, Field.DatabaseName]));
  end
  else if FTable.FindField(FieldName, Field) then
    Exit(Field.DatabaseName);

  raise EFieldNotFoundInTable.Create(FieldName);
end;

function TQueryBuilder.GetFields: TArray<TFieldAlias>;
begin
  Result := FFieldList.GetFields;
end;

function TQueryBuilder.GetIdention(Count: Integer; const MinimalIdention: Boolean): String;
begin
  if not (boBeautifyQuery in Options) then
    if MinimalIdention then
      Count := 1
    else
      Count := 0;

  Result := StringOfChar(' ', Count)
end;

function TQueryBuilder.GetJoin: TQueryBuilderJoin;
begin
  if Assigned(FFrom) then
    Result := FFrom.FJoin
  else
    Result := nil;
end;

function TQueryBuilder.GetLineBreak: String;
begin
  if boBeautifyQuery in Options then
    Result := #13#10
  else
    Result := EmptyStr;
end;

function TQueryBuilder.GetSQL: String;
begin
  if Assigned(FSelect) then
    if Assigned(FFrom) then
      Result := GetIdention(3, False) + 'select ' + FSelect.GetSQL + GetIdention(5) + 'from ' + FFrom.GetSQL
    else
      raise ECommandWithoutFromClause.Create
  else
    Result := EmptyStr;
end;

function TQueryBuilder.GetTable: TTable;
begin
  Result := FTable;
end;

function TQueryBuilder.Save<T>(const AObject: T): T;
begin
  Result := ExecuteInTrasaction(
    function: TObject
    begin
      Result := SaveObject(AObject);
    end) as T;
end;

procedure TQueryBuilder.SaveForeignKeys(const Table: TTable; const ForeignObject: TObject);
begin
  var FieldValue: TValue;

  for var ForeignKey in Table.ForeignKeys do
    if ForeignKey.IsInheritedLink then
      SaveObject(TValue.From(ForeignObject).Cast(ForeignObject.ClassParent.ClassInfo, False))
    else if ForeignKey.Field.HasValue(ForeignObject, FieldValue) and FieldValue.IsObject and not FProcessedObjects.ContainsKey(FieldValue.AsObject) then
      SaveObject(FieldValue);
end;

procedure TQueryBuilder.SaveManyValueAssociations(const Table: TTable; const CurrentObject, ForeignObject: TObject);
begin
  var CurrentArray, ForeignArrayValue: TValue;

  for var ManyValue in Table.ManyValueAssociations do
    if ManyValue.Field.HasValue(ForeignObject, ForeignArrayValue) and ForeignArrayValue.IsArray then
    begin
      CurrentArray := ForeignArrayValue;

      for var A := 0 to Pred(ForeignArrayValue.ArrayLength) do
      begin
        var ForeignArrayItem := ForeignArrayValue.ArrayElement[A];

        ManyValue.ForeignKey.Field.SetValue(ForeignArrayItem.AsObject, ForeignObject);

        var SavedObject := SaveObject(ForeignArrayItem);

        ManyValue.ForeignKey.Field.SetValue(SavedObject, CurrentObject);

        CurrentArray.SetArrayElement(A, SavedObject);
      end;

      ManyValue.Field.SetValue(CurrentObject, CurrentArray);
    end;
end;

function TQueryBuilder.SaveObject(const AObject: TValue): TObject;
begin
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);
  var Value: TValue;

  if Assigned(Table.PrimaryKey) and not Table.PrimaryKey.HasValue(AObject.AsObject, Value) then
    Result := InsertObject(AObject)
  else
    Result := UpdateObject(AObject);
end;

function TQueryBuilder.Select: TQueryBuilderSelect;
begin
  Result := TQueryBuilderSelect.Create(Self);

  FSelect := Result;
end;

function TQueryBuilder.Update<T>(const AObject: T): T;
begin
  Result := ExecuteInTrasaction(
    function: TObject
    begin
      Result := UpdateObject(AObject);
    end) as T;
end;

function TQueryBuilder.UpdateObject(const AObject: TValue): TObject;
begin
  var ForeignFieldStringValue: String;
  var ForeignFieldValue: TValue;
  var ForeignObject := AObject.AsObject;
  var SQL := EmptyStr;
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);

  var CacheKey := Table.GetCacheKey(ForeignObject);

  if FCache.Get(CacheKey, Result) then
  begin
    var Changes := FCache.ChangeManager.Changes[Result];

    FProcessedObjects.AddOrSetValue(ForeignObject, Result);

    SaveForeignKeys(Table, ForeignObject);

    for var Field in Table.Fields do
      if not Field.InPrimaryKey and not Field.IsManyValueAssociation and not Field.IsReadOnly then
      begin
        if Field.HasValue(ForeignObject, ForeignFieldValue) and Field.IsForeignKey then
          if ForeignFieldValue.IsObject then
            ForeignFieldValue := FProcessedObjects[ForeignFieldValue.AsObject]
          else
            Continue;

        ForeignFieldStringValue := Field.GetAsString(ForeignFieldValue);

        if ForeignFieldStringValue <> Changes[Field] then
        begin
          Changes[Field] := ForeignFieldStringValue;

          if not SQL.IsEmpty then
            SQL := SQL + ',';

          SQL := SQL + Format('%s=%s', [Field.DatabaseName, ForeignFieldStringValue]);

          Field.SetValue(Result, ForeignFieldValue);
        end;
      end;

    if not SQL.IsEmpty then
      FConnection.ExecuteDirect(Format('update %s set %s%s', [Table.DatabaseName, SQL, BuildPrimaryKeyFilter(Table, ForeignObject)]));

    SaveManyValueAssociations(Table, Result, ForeignObject);

    AddObjectToDestruction(Result, ForeignObject);
  end
  else
    raise EObjectReferenceWasNotFound.Create;
end;

{ TQueryBuilderFrom }

procedure TQueryBuilderFrom.BuildJoin;
begin
  FTableIndexJoin := 1;
  var RecursionControl := TDictionary<TTable, Word>.Create;

  MakeJoin(FJoin, RecursionControl, nil);

  RecursionControl.Free;
end;

function TQueryBuilderFrom.BuildJoinSQL: String;
begin
  Result := Format('%s %s', [FJoin.Table.DatabaseName, FJoin.Alias]) + MakeJoinSQL(FJoin, FJoin.Table.Name);
end;

constructor TQueryBuilderFrom.Create(const Access: IQueryBuilderAccess; const RecursivityLevel: Word);
begin
  inherited Create;

  FAccess := Access;
  FAccess.Builder.FFrom := Self;
  FRecursivityLevel := RecursivityLevel;
end;

function TQueryBuilderFrom.CreateJoin(const CurrentJoin: TQueryBuilderJoin; const Table: TTable; const Field, LeftField, RightField: TField;
  const IsInheritedLink, MakeLink: Boolean): TQueryBuilderJoin;
begin
  Result := TQueryBuilderJoin.Create(Table, Field, LeftField, RightField, IsInheritedLink);

  Inc(FTableIndexJoin);

  Result.Alias := 'T' + FTableIndexJoin.ToString;

  if Assigned(CurrentJoin) then
    if MakeLink then
      CurrentJoin.Links := CurrentJoin.Links + [Result]
    else
      CurrentJoin.FilterLinks := CurrentJoin.FilterLinks + [Result];
end;

function TQueryBuilderFrom.CreateJoinForeignKey(const CurrentJoin: TQueryBuilderJoin; const ForeignKey: TForeignKey; const MakeLink: Boolean): TQueryBuilderJoin;
begin
  Result := CreateJoin(CurrentJoin, ForeignKey.ParentTable, ForeignKey.Field, ForeignKey.Field, ForeignKey.ParentTable.PrimaryKey, ForeignKey.IsInheritedLink, MakeLink);
end;

function TQueryBuilderFrom.CreateJoinManyValueAssociation(const CurrentJoin: TQueryBuilderJoin; const ManyValueAssociation: TManyValueAssociation;
  const MakeLink: Boolean): TQueryBuilderJoin;
begin
  Result := CreateJoin(CurrentJoin, ManyValueAssociation.ChildTable, ManyValueAssociation.Field, Join.Table.PrimaryKey, ManyValueAssociation.ForeignKey.Field, False, MakeLink);
end;

function TQueryBuilderFrom.CreateJoinTable(const Table: TTable): TQueryBuilderJoin;
begin
  Result := CreateJoin(nil, Table, nil, nil, nil, False, False);
end;

destructor TQueryBuilderFrom.Destroy;
begin
  FJoin.Free;

  inherited;
end;

function TQueryBuilderFrom.From<T>(Table: TTable): TQueryBuilderWhere<T>;
begin
  FAccess.Builder.FTable := Table;
  FJoin := CreateJoinTable(Table);
  Result := TQueryBuilderWhere<T>.Create(FAccess);

  FAccess.Builder.FWhere := Result;

  BuildJoin;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  Result := From<T>(TMapper.Default.FindTable(T));
end;

function TQueryBuilderFrom.GetSQL: String;
begin
  Result := BuildJoinSQL;

  if Assigned(FAccess.Builder.FWhere) then
    Result := Result + FAccess.Builder.FWhere.GetSQL;
end;

procedure TQueryBuilderFrom.MakeJoin(const Join: TQueryBuilderJoin; RecursionControl: TDictionary<TTable, Word>; const ManyValueAssociationToIgnore: TManyValueAssociation);
begin
  for var ForeignKey in Join.Table.ForeignKeys do
    if not ForeignKey.Field.IsLazy and (not Assigned(ManyValueAssociationToIgnore) or (ForeignKey <> ManyValueAssociationToIgnore.ForeignKey)) then
    begin
      if not RecursionControl.ContainsKey(ForeignKey.ParentTable) then
        RecursionControl.Add(ForeignKey.ParentTable, 0);

      if RecursionControl[ForeignKey.ParentTable] < FRecursivityLevel then
      begin
        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] + 1;

        MakeJoin(CreateJoinForeignKey(Join, ForeignKey, True), RecursionControl, ManyValueAssociationToIgnore);

        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] - 1;
      end;
    end;

  for var ManyValueAssociation in Join.Table.ManyValueAssociations do
    if not ManyValueAssociation.Field.IsLazy and (not Assigned(ManyValueAssociationToIgnore) or (ManyValueAssociation <> ManyValueAssociationToIgnore)) then
      MakeJoin(CreateJoinManyValueAssociation(Join, ManyValueAssociation, True), RecursionControl, ManyValueAssociation);
end;

function TQueryBuilderFrom.MakeJoinSQL(const Join: TQueryBuilderJoin; const JoinInfo: String): String;

  function MakeJoinInfo(const Link: TQueryBuilderJoin): String;
  begin
    if boJoinMapping in FAccess.Builder.Options then
      Result := Format(FAccess.GetIdention(7, False) + '/* %s -> %s (%s) */' + FAccess.LineBreak, [JoinInfo, Link.Table.Name, Link.LeftField.Name])
    else
      Result := FAccess.GetIdention(0);
  end;

begin
  Result := FAccess.LineBreak;

  for var Link in Join.AllLinks do
    Result := Result + Format('%sleft join %s %s%son %s.%s=%s.%s', [MakeJoinInfo(Link), Link.Table.DatabaseName, Link.Alias, FAccess.LineBreak + FAccess.GetIdention(7),
      Join.Alias, Link.LeftField.DatabaseName, Link.Alias, Link.RightField.DatabaseName]) + MakeJoinSQL(Link, JoinInfo + ' -> ' + Link.Table.Name);
end;

{ TQueryBuilderSelect }

function TQueryBuilderSelect.All: TQueryBuilderFrom;
begin
  FAccess.Builder.FFieldList := TQueryBuilderAllFields.Create(FAccess);
  Result := TQueryBuilderFrom.Create(FAccess, FRecursivityLevel);
end;

constructor TQueryBuilderSelect.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FAccess := Access;
  FRecursivityLevel := 1;
end;

destructor TQueryBuilderSelect.Destroy;
begin
  FAccess.Builder.FTable := nil;

  FreeAndNil(FAccess.Builder.FFrom);

  FreeAndNil(FAccess.Builder.FFieldList);

  FreeAndNil(FAccess.Builder.FOpen);

  inherited;
end;

function TQueryBuilderSelect.First(const Total: Cardinal): TQueryBuilderSelect;
begin
  FFirstRecords := Total;
  Result := Self;
end;

function TQueryBuilderSelect.GetFieldsWithAlias: String;
begin
  var FieldAlias: TFieldAlias;
  var FieldList := FAccess.GetFields;
  Result := EmptyStr;

  for var A := Low(FieldList) to High(FieldList) do
  begin
    FieldAlias := FieldList[A];

    if not Result.IsEmpty then
      Result := Result + ',' + FAccess.LineBreak + FAccess.GetIdention(10, False);

    Result := Result + Format('%s.%s F%d', [FieldAlias.TableAlias, FieldAlias.Field.DatabaseName, Succ(A)]);
  end;

  Result := Result + FAccess.LineBreak;
end;

function TQueryBuilderSelect.GetSQL: String;
begin
  Result := EmptyStr;

  if FirstRecords > 0 then
    Result := Result + Format('top %d ', [FirstRecords]);

  Result := Result + GetFieldsWithAlias;
end;

function TQueryBuilderSelect.RecursivityLevel(const Level: Word): TQueryBuilderSelect;
begin
  FRecursivityLevel := Level;
  Result := Self;
end;

{ TQueryBuilderWhere }

procedure TQueryBuilderWhere.BuildFilter(const Value: TQueryBuilderComparisonHelper);
begin
  try
    FFilter := FAccess.GetIdention(4) + 'where ' + MakeFilter(Value.Comparison) + FAccess.LineBreak;
  finally
    Value.Comparison.Free;
  end;
end;

function TQueryBuilderWhere.GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  case Comparison.Comparison of
    qbcoBetween: Result := Format(' between %s and %s', [Field.GetAsString(Comparison.Right.Value.GetArrayElement(0).AsType<TValue>), Field.GetAsString(Comparison.Right.Value.GetArrayElement(1).AsType<TValue>)]);
    qbcoLike: Result := Format(' like ''%s''', [Comparison.Right.Value.AsString]);
    qbcoNull: Result := ' is null';
    qbcoNotNull: Result := ' is not null';
    else Result := Field.GetAsString(Comparison.Right.Value);
  end;
end;

function TQueryBuilderWhere.GetSQL: String;
begin
  Result := FFilter;

  if Assigned(FOrderBy) then
    Result := Result + FOrderBy.GetSQL;
end;

function TQueryBuilderWhere.GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  if Assigned(Comparison.Right) and Assigned(Comparison.Right.Field) then
    Result := FAccess.GetField(Comparison.Right.Field)
  else
    Result := GetFieldValue(Comparison, Field);
end;

function TQueryBuilderWhere.MakeComparison(const Comparison: TQueryBuilderComparison): String;
const
  COMPARISON_OPERATOR: array[TQueryBuilderComparisonOperator] of String = ('', '=', '<>', '>', '>=', '<', '<=', '', '', '', '');

begin
  var Field: TField;
  var FieldName := FAccess.GetField(Comparison.Left.Field, Field);

  Result := Format('%s%s%s', [FieldName, COMPARISON_OPERATOR[Comparison.Comparison], GetValueToCompare(Comparison, Field)]);
end;

function TQueryBuilderWhere.MakeFilter(const Value: TQueryBuilderComparison): String;
begin
  if Value.Comparison <> qbcoNone then
    Result := MakeComparison(Value)
  else if Value.Logical <> qloNone then
    Result := MakeLogical(Value);
end;

function TQueryBuilderWhere.MakeLogical(const Logical: TQueryBuilderComparison): String;
const
  LOGICAL_OPERATOR: array[TQueryBuilderLogicalOperator] of String = ('', 'and', 'or');

begin
  Result := Format('(%s%s%s %s)', [MakeFilter(Logical.Left), FAccess.LineBreak + FAccess.GetIdention(6), LOGICAL_OPERATOR[Logical.Logical], MakeFilter(Logical.Right)]);
end;

constructor TQueryBuilderWhere.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FAccess := Access;
  FAccess.Builder.FWhere := Self;
end;

destructor TQueryBuilderWhere.Destroy;
begin
  FOrderBy.Free;

  inherited;
end;

function TQueryBuilderWhere.Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere;
begin
  Result := Self;

  BuildFilter(Condition);
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := TClassLoader(FLoader).LoadAll<T>;
end;

constructor TQueryBuilderOpen<T>.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FLoader := TClassLoader.Create(Access);
end;

destructor TQueryBuilderOpen<T>.Destroy;
begin
  FLoader.Free;

  inherited;
end;

function TQueryBuilderOpen<T>.One: T;
begin
  Result := TClassLoader(FLoader).Load<T>;
end;

{ TQueryBuilderAllFields }

constructor TQueryBuilderAllFields.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FAccess := Access;
end;

function TQueryBuilderAllFields.GetAllFields(const Join: TQueryBuilderJoin): TArray<TFieldAlias>;
begin
  Result := nil;

  for var Field in Join.Table.Fields do
    if not Field.IsManyValueAssociation and (not Field.IsForeignKey or Field.IsLazy) then
      Result := Result + [TFieldAlias.Create(Join.Alias, Field)];

  for var Link in Join.Links do
    Result := Result + GetAllFields(Link);
end;

function TQueryBuilderAllFields.GetFields: TArray<TFieldAlias>;
begin
  Result := GetAllFields(FAccess.Join);
end;

{ TQueryBuilderJoin }

constructor TQueryBuilderJoin.Create(const Table: TTable; const Field, LeftField, RightField: TField; const IsInheritedLink: Boolean);
begin
  Create(Table);

  FField := Field;
  FIsInheritedLink := IsInheritedLink;
  FLeftField := LeftField;
  FRightField := RightField;
end;

constructor TQueryBuilderJoin.Create(const Table: TTable);
begin
  inherited Create;

  FTable := Table;
end;

destructor TQueryBuilderJoin.Destroy;
begin
  for var Link in AllLinks do
    Link.Free;

  inherited;
end;

function TQueryBuilderJoin.GetAllLinks: TArray<TQueryBuilderJoin>;
begin
  Result := Links + FilterLinks;
end;

{ TQueryBuilderFieldAlias }

constructor TQueryBuilderFieldAlias.Create(const FieldName: String);
begin
  inherited Create;

  FFieldName := FieldName;
  FFieldNames := FieldName.Split(['.']);
end;

{ TQueryBuilderComparison }

destructor TQueryBuilderComparison.Destroy;
begin
  FLeft.Free;

  FRight.Free;

  FField.Free;

  inherited;
end;

function TQueryBuilderComparison.GetLeft: TQueryBuilderComparison;
begin
  if not Assigned(FLeft) then
    FLeft := TQueryBuilderComparison.Create;

  Result := FLeft;
end;

function TQueryBuilderComparison.GetRight: TQueryBuilderComparison;
begin
  if not Assigned(FRight) then
    FRight := TQueryBuilderComparison.Create;

  Result := FRight;
end;

{ EFieldNotFoundInTable }

constructor EFieldNotFoundInTable.Create(FieldName: String);
begin
  inherited CreateFmt('Field "%s" not found in current table!', [FieldName]);
end;

{ TQueryBuilderComparisonHelper }

function TQueryBuilderComparisonHelper.Between<T>(const ValueStart, ValueEnd: T): TQueryBuilderComparisonHelper;
begin
  Result := Create;
  Result.Comparison.Left := Self.Comparison;
  Result.Comparison.Comparison := qbcoBetween;
  Result.Comparison.Right.Value := TValue.From<TArray<T>>([ValueStart, ValueEnd]);
end;

class operator TQueryBuilderComparisonHelper.BitwiseAnd(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create;
  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Logical := qloAnd;
  Result.Comparison.Right := Right.Comparison;
end;

class operator TQueryBuilderComparisonHelper.BitwiseOr(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create;
  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Logical := qloOr;
  Result.Comparison.Right := Right.Comparison;
end;

class function TQueryBuilderComparisonHelper.Create: TQueryBuilderComparisonHelper;
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.Comparison := TQueryBuilderComparison.Create;
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoEqual, Left, TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoEqual, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonHelper; const Value: TNullEnumerator): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoNull, Left, TValue.From(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoEqual, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThan, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThan, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThan, Left, TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThanOrEqual, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThanOrEqual, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoGreaterThanOrEqual, Left, TValue.FromVariant(Value), Result);
end;

function TQueryBuilderComparisonHelper.IsLoaded: Boolean;
begin
  Result := (Comparison.Logical <> qloNone) or (Comparison.Comparison <> qbcoNone);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThan, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThan, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThan, Left, TValue.FromVariant(Value), Result);
end;

function TQueryBuilderComparisonHelper.Like(const Value: String): TQueryBuilderComparisonHelper;
begin
  Result := Create;
  Result.Comparison.Left := Self.Comparison;
  Result.Comparison.Comparison := qbcoLike;
  Result.Comparison.Right.Value := Value;
end;

class procedure TQueryBuilderComparisonHelper.MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left: TQueryBuilderComparisonHelper; const Right: TValue;
  var Result: TQueryBuilderComparisonHelper);
begin
  Result := Create;
  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Comparison := Comparison;
  Result.Comparison.Right.Value := Right;
end;

class procedure TQueryBuilderComparisonHelper.MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left, Right: TQueryBuilderComparisonHelper;
  var Result: TQueryBuilderComparisonHelper);
begin
  Result := Create;
  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Comparison := Comparison;
  Result.Comparison.Right := Right.Comparison;
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThanOrEqual, Left, TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThanOrEqual, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoLessThanOrEqual, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoNotEqual, Left, Right, Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: Variant): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoNotEqual, Left, TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: TValue): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoNotEqual, Left, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonHelper; const Value: TNullEnumerator): TQueryBuilderComparisonHelper;
begin
  MakeComparison(qbcoNotNull, Left, TValue.From(Value), Result);
end;

{ TQueryBuilderOrderBy }

constructor TQueryBuilderOrderBy.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FAccess := Access;
end;

destructor TQueryBuilderOrderBy.Destroy;
begin
  for var Field in FFields do
    Field.Free;

  inherited;
end;

function TQueryBuilderOrderBy.Field(const FieldName: String; const Ascending: Boolean): TQueryBuilderOrderBy;
begin
  FFields := FFields + [TQueryBuilderOrderByField.Create(FieldName, Ascending)];
  Result := Self;
end;

function TQueryBuilderOrderBy.GetSQL: String;
begin
  Result := EmptyStr;

  for var Field in Fields do
  begin
    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + FAccess.GetField(Field);

    if not Field.Ascending then
      Result := Result + ' desc';
  end;

  if not Result.IsEmpty then
    Result := FAccess.GetIdention(1) + 'order by ' + Result + FAccess.LineBreak;
end;

{ TQueryBuilderOrderByField }

constructor TQueryBuilderOrderByField.Create(const FieldName: String; const Ascending: Boolean);
begin
  inherited Create(FieldName);

  FAscending := Ascending;
end;

{ EObjectReferenceWasNotFound }

constructor EObjectReferenceWasNotFound.Create;
begin
  inherited Create('The object reference was not found, reload the data and try again!');
end;

{ ECantFilterManyValueAssociation }

constructor ECantFilterManyValueAssociation.Create(Field: TField);
begin
  inherited CreateFmt('Can''t create a filter of many value association field %s from class %s!', [Field.Name, Field.Table.Name]);
end;

{ ECommandWithoutFromClause }

constructor ECommandWithoutFromClause.Create;
begin
  inherited Create('Command whitout from clause, check the implementation!');
end;

{ TQueryBuilderWhere<T> }

function TQueryBuilderWhere<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FAccess);

  FAccess.Builder.FOpen := Result;
end;

function TQueryBuilderWhere<T>.OrderBy: TQueryBuilderOrderBy<T>;
begin
  Result := TQueryBuilderOrderBy<T>.Create(FAccess);

  FOrderBy := Result;
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
begin
  inherited Where(Condition);

  Result := Self;
end;

{ TQueryBuilderOrderBy<T> }

function TQueryBuilderOrderBy<T>.Field(const FieldName: String; const Ascending: Boolean): TQueryBuilderOrderBy<T>;
begin
  inherited Field(FieldName, Ascending);

  Result := Self;
end;

function TQueryBuilderOrderBy<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FAccess);

  FAccess.Builder.FOpen := Result;
end;

end.

