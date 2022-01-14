unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Nullable, Delphi.ORM.Cache;

type
  TQueryBuilder = class;
  TQueryBuilderComparison = class;
  TQueryBuilderFrom = class;
  TQueryBuilderJoin = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class> = class;

  EFieldNotFoundInTable = class(Exception)
  public
    constructor Create(FieldName: String);
  end;

  TQueryBuilderCommand = class
    function GetSQL: String; virtual; abstract;
  end;

  TQueryBuilderFieldList = class
    function GetFields: TArray<TFieldAlias>; virtual; abstract;
  end;

  TQueryBuilder = class
  private
    FConnection: IDatabaseConnection;
    FCommand: TQueryBuilderCommand;
    FCache: ICache;

    function BuildPrimaryKeyFilter(const Table: TTable; const AObject: TObject): String;
    function GetConnection: IDatabaseConnection;

    procedure ExecuteInTrasaction(const Proc: TProc);
    procedure InsertObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
    procedure SaveForeignKeys(const Table: TTable; const AObject: TValue; const ForeignKeyToIgnore: TForeignKey);
    procedure SaveManyValueAssociations(const Table: TTable; const AObject: TValue; const Recursive: Boolean);
    procedure SaveObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
    procedure UpdateObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
  public
    constructor Create(Connection: IDatabaseConnection);

    destructor Destroy; override;

    function GetSQL: String;
    function Select: TQueryBuilderSelect;

    procedure Delete<T: class>(const AObject: T);
    procedure Insert<T: class>(const AObject: T);
    procedure InsertNonRecursive<T: class>(const AObject: T);
    procedure Save<T: class>(const AObject: T);
    procedure SaveNonRecursive<T: class>(const AObject: T);
    procedure Update<T: class>(const AObject: T);
    procedure UpdateNonRecursive<T: class>(const AObject: T);

    property Cache: ICache read FCache write FCache;
    property Connection: IDatabaseConnection read FConnection;
  end;

  TQueryBuilderFrom = class
  private
    FJoin: TQueryBuilderJoin;
    FWhere: TQueryBuilderCommand;
    FRecursivityLevel: Word;
    FSelect: TQueryBuilderSelect;
    FTable: TTable;

    function BuildJoinSQL: String;
    function GetBuilder: TQueryBuilder;
    function GetFields: TArray<TFieldAlias>;
    function MakeJoinSQL(Join: TQueryBuilderJoin): String;

    procedure BuildJoin;
    procedure MakeJoin(Join: TQueryBuilderJoin; var TableIndex: Integer; RecursionControl: TDictionary<TTable, Word>; const ManyValueAssociationToIgnore: TManyValueAssociation);
  public
    constructor Create(Select: TQueryBuilderSelect; RecursivityLevel: Word);

    destructor Destroy; override;

    function From<T: class>: TQueryBuilderWhere<T>; overload;
    function From<T: class>(Table: TTable): TQueryBuilderWhere<T>; overload;
    function GetSQL: String;

    property Builder: TQueryBuilder read GetBuilder;
    property Fields: TArray<TFieldAlias> read GetFields;
    property Join: TQueryBuilderJoin read FJoin;
    property Table: TTable read FTable write FTable;
  end;

  TQueryBuilderJoin = class
  private
    FAlias: String;
    FLinks: TArray<TQueryBuilderJoin>;
    FTable: TTable;
    FLeftField: TField;
    FRightField: TField;
    FField: TField;
    FIsInheritedLink: Boolean;
  public
    constructor Create(const Table: TTable); overload;
    constructor Create(const Table: TTable; const Field, LeftField, RightField: TField; const IsInheritedLink: Boolean); overload;

    destructor Destroy; override;

    property Alias: String read FAlias write FAlias;
    property Field: TField read FField write FField;
    property IsInheritedLink: Boolean read FIsInheritedLink write FIsInheritedLink;
    property LeftField: TField read FLeftField write FLeftField;
    property Links: TArray<TQueryBuilderJoin> read FLinks write FLinks;
    property RightField: TField read FRightField write FRightField;
    property Table: TTable read FTable write FTable;
  end;

  TQueryBuilderOpen<T: class> = class
  private
    FLoader: TObject;
  public
    constructor Create(From: TQueryBuilderFrom);

    destructor Destroy; override;

    function All: TArray<T>;
    function One: T;
  end;

  TQueryBuilderAllFields = class(TQueryBuilderFieldList)
  private
    FFrom: TQueryBuilderFrom;

    function GetAllFields(Join: TQueryBuilderJoin): TArray<TFieldAlias>;
  public
    constructor Create(From: TQueryBuilderFrom);

    function GetFields: TArray<TFieldAlias>; override;
  end;

  TQueryBuilderSelect = class(TQueryBuilderCommand)
  private
    FBuilder: TQueryBuilder;
    FFieldList: TQueryBuilderFieldList;
    FFirstRecords: Cardinal;
    FFrom: TQueryBuilderFrom;
    FRecursivityLevel: Word;

    function GetBuilder: TQueryBuilder;
    function GetFields: TArray<TFieldAlias>;
    function GetFieldsWithAlias: String;
  public
    constructor Create(Builder: TQueryBuilder);

    destructor Destroy; override;

    function All: TQueryBuilderFrom;
    function GetSQL: String; override;
    function RecursivityLevel(const Level: Word): TQueryBuilderSelect;
    function First(Total: Cardinal): TQueryBuilderSelect;

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
    function Like(const Value: String): TQueryBuilderComparisonHelper;

    class procedure InitComparison(var Result: TQueryBuilderComparisonHelper); static;

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

  TQueryBuilderOrderBy<T: class> = class(TQueryBuilderCommand)
  private
    FFields: TArray<TQueryBuilderOrderByField>;
    FWhere: TQueryBuilderWhere<T>;

    constructor Create(const Where: TQueryBuilderWhere<T>);
  public
    destructor Destroy; override;

    function Field(const FieldName: String; const Ascending: Boolean = True): TQueryBuilderOrderBy<T>;
    function GetSQL: String; override;
    function Open: TQueryBuilderOpen<T>;

    property Fields: TArray<TQueryBuilderOrderByField> read FFields;
  end;

  TQueryBuilderWhere<T: class> = class(TQueryBuilderCommand)
  private
    FFilter: String;
    FFrom: TQueryBuilderFrom;
    FOpen: TQueryBuilderOpen<T>;
    FOrderBy: TQueryBuilderOrderBy<T>;
    FTable: TTable;

    constructor Create(const Table: TTable); overload;

    function GetField(const QueryField: TQueryBuilderFieldAlias): String; overload;
    function GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String; overload;
    function GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function MakeComparison(const Comparison: TQueryBuilderComparison): String;
    function MakeFilter(const Value: TQueryBuilderComparison): String;
    function MakeLogical(const Logical: TQueryBuilderComparison): String;

    procedure BuildFilter(const Value: TQueryBuilderComparisonHelper);
  public
    constructor Create(const From: TQueryBuilderFrom); overload;

    destructor Destroy; override;

    function GetSQL: String; override;
    function Open: TQueryBuilderOpen<T>;
    function OrderBy: TQueryBuilderOrderBy<T>;
    function Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
  end;

function Field(const Name: String): TQueryBuilderComparisonHelper;

implementation

uses System.TypInfo, Delphi.ORM.Attributes, Delphi.ORM.Rtti.Helper, Delphi.ORM.Classes.Loader;

function Field(const Name: String): TQueryBuilderComparisonHelper;
begin
  Result.Comparison := TQueryBuilderComparison.Create;
  Result.Comparison.Field := TQueryBuilderFieldAlias.Create(Name);
end;

{ TQueryBuilder }

function TQueryBuilder.BuildPrimaryKeyFilter(const Table: TTable; const AObject: TObject): String;
begin
  Result := EmptyStr;

  if Assigned(Table.PrimaryKey) then
  begin
    var Condition := Field(Table.PrimaryKey.DatabaseName) = Table.PrimaryKey.GetValue(AObject);
    var Where := TQueryBuilderWhere<TObject>.Create(Table);

    Result := Where.Where(Condition).GetSQL;

    Where.Free;
  end;
end;

constructor TQueryBuilder.Create(Connection: IDatabaseConnection);
begin
  inherited Create;

  FConnection := Connection;
end;

procedure TQueryBuilder.Delete<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      var Table := TMapper.Default.FindTable(AObject.ClassType);

      FConnection.ExecuteDirect(Format('delete from %s%s', [Table.DatabaseName, BuildPrimaryKeyFilter(Table, AObject)]));
    end);
end;

destructor TQueryBuilder.Destroy;
begin
  FCommand.Free;

  inherited;
end;

procedure TQueryBuilder.ExecuteInTrasaction(const Proc: TProc);
begin
  var Transaction := Connection.StartTransaction;

  try
    Proc();

    Transaction.Commit;
  except
    Transaction.Rollback;

    raise;
  end;
end;

procedure TQueryBuilder.InsertObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
begin
  var OutputFieldList: TArray<TField> := nil;
  var OutputFieldNameList: TArray<String> := nil;
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);

  var SQL := '(%s)values(%s)';

  if Recursive then
    SaveForeignKeys(Table, AObject, ForeignKeyToIgnore);

  for var Field in Table.Fields do
  begin
    var FieldValue := Field.GetValue(AObject.AsObject);

    if Field.AutoGenerated and (FieldValue.AsVariant = Field.DefaultValue.AsVariant) then
    begin
      OutputFieldList := OutputFieldList + [Field];
      OutputFieldNameList := OutputFieldNameList + [Field.DatabaseName];
    end
    else if not Field.IsManyValueAssociation then
      SQL := Format(SQL, [Field.DatabaseName + '%2:s%0:s', Field.GetAsString(FieldValue) + '%2:s%1:s', ',']);
  end;

  SQL := 'insert into ' + Table.DatabaseName + Format(SQL, ['', '', '', '']);

  var Cursor := FConnection.ExecuteInsert(SQL, OutputFieldNameList);

  if Cursor.Next then
    for var A := Low(OutputFieldList) to High(OutputFieldList) do
      OutputFieldList[A].SetValue(AObject.AsObject, Cursor.GetFieldValue(A));

  SaveManyValueAssociations(Table, AObject, Recursive);
end;

procedure TQueryBuilder.Insert<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      InsertObject(AObject, nil, True);
    end);
end;

procedure TQueryBuilder.InsertNonRecursive<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      InsertObject(AObject, nil, False);
    end);
end;

function TQueryBuilder.GetConnection: IDatabaseConnection;
begin
  Result := FConnection;
end;

function TQueryBuilder.GetSQL: String;
begin
  if Assigned(FCommand) then
    Result := FCommand.GetSQL
  else
    Result := EmptyStr;
end;

procedure TQueryBuilder.Save<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      SaveObject(AObject, nil, True);
    end)
end;

procedure TQueryBuilder.SaveForeignKeys(const Table: TTable; const AObject: TValue; const ForeignKeyToIgnore: TForeignKey);
begin
  for var ForeignKey in Table.ForeignKeys do
    if ForeignKey <> ForeignKeyToIgnore then
    begin
      var FieldValue := ForeignKey.Field.GetValue(AObject.AsObject);

      if not FieldValue.IsEmpty then
        SaveObject(FieldValue, ForeignKey, True);
    end;
end;

procedure TQueryBuilder.SaveManyValueAssociations(const Table: TTable; const AObject: TValue; const Recursive: Boolean);
begin
  for var ManyValue in Table.ManyValueAssociations do
  begin
    var FieldValue := ManyValue.Field.GetValue(AObject.AsObject);

    for var A := 0 to Pred(FieldValue.GetArrayLength) do
    begin
      var ChildFieldValue := FieldValue.GetArrayElement(A);

      ManyValue.ForeignKey.Field.SetValue(ChildFieldValue.AsObject, AObject);

      SaveObject(ChildFieldValue, ManyValue.ForeignKey, Recursive);
    end;
  end;
end;

procedure TQueryBuilder.SaveNonRecursive<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      SaveObject(AObject, nil, False);
    end)
end;

procedure TQueryBuilder.SaveObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
begin
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);

  if Assigned(Table.PrimaryKey) and (Table.PrimaryKey.GetValue(AObject.AsObject).AsVariant = Table.PrimaryKey.DefaultValue.AsVariant) then
    InsertObject(AObject, ForeignKeyToIgnore, Recursive)
  else
    UpdateObject(AObject, ForeignKeyToIgnore, Recursive);
end;

function TQueryBuilder.Select: TQueryBuilderSelect;
begin
  Result := TQueryBuilderSelect.Create(Self);

  FCommand := Result;
end;

procedure TQueryBuilder.Update<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      UpdateObject(AObject, nil, True);
    end);
end;

procedure TQueryBuilder.UpdateNonRecursive<T>(const AObject: T);
begin
  ExecuteInTrasaction(
    procedure
    begin
      UpdateObject(AObject, nil, False);
    end);
end;

procedure TQueryBuilder.UpdateObject(const AObject: TValue; const ForeignKeyToIgnore: TForeignKey; const Recursive: Boolean);
begin
  var SQL := EmptyStr;
  var Table := TMapper.Default.FindTable(AObject.TypeInfo);

  if Recursive then
    SaveForeignKeys(Table, AObject, ForeignKeyToIgnore);

  for var TableField in Table.Fields do
    if not TableField.InPrimaryKey and not TableField.IsManyValueAssociation then
    begin
      if not SQL.IsEmpty then
        SQL := SQL + ',';

      SQL := SQL + Format('%s=%s', [TableField.DatabaseName, TableField.GetAsString(AObject.AsObject)]);
    end;

  SQL := Format('update %s set %s%s', [Table.DatabaseName, SQL, BuildPrimaryKeyFilter(Table, AObject.AsObject)]);

  FConnection.ExecuteDirect(SQL);

  SaveManyValueAssociations(Table, AObject, Recursive);
end;

{ TQueryBuilderFrom }

procedure TQueryBuilderFrom.BuildJoin;
begin
  var RecursionControl := TDictionary<TTable, Word>.Create;
  var TableIndex := 1;

  MakeJoin(FJoin, TableIndex, RecursionControl, nil);

  RecursionControl.Free;
end;

function TQueryBuilderFrom.BuildJoinSQL: String;
begin
  Result := Format('%s %s', [FJoin.Table.DatabaseName, FJoin.Alias]) + MakeJoinSQL(FJoin);
end;

constructor TQueryBuilderFrom.Create(Select: TQueryBuilderSelect; RecursivityLevel: Word);
begin
  inherited Create;

  FSelect := Select;
  FRecursivityLevel := RecursivityLevel;
end;

destructor TQueryBuilderFrom.Destroy;
begin
  FWhere.Free;

  FJoin.Free;

  inherited;
end;

function TQueryBuilderFrom.From<T>(Table: TTable): TQueryBuilderWhere<T>;
begin
  FJoin := TQueryBuilderJoin.Create(Table);
  FTable := Table;
  Result := TQueryBuilderWhere<T>.Create(Self);

  FWhere := Result;

  BuildJoin;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  Result := From<T>(TMapper.Default.FindTable(T));
end;

function TQueryBuilderFrom.GetBuilder: TQueryBuilder;
begin
  Result := FSelect.GetBuilder;
end;

function TQueryBuilderFrom.GetFields: TArray<TFieldAlias>;
begin
  Result := FSelect.GetFields;
end;

function TQueryBuilderFrom.GetSQL: String;
begin
  Result := Format(' from %s', [BuildJoinSQL]);

  if Assigned(FWhere) then
    Result := Result + FWhere.GetSQL;
end;

procedure TQueryBuilderFrom.MakeJoin(Join: TQueryBuilderJoin; var TableIndex: Integer; RecursionControl: TDictionary<TTable, Word>; const ManyValueAssociationToIgnore: TManyValueAssociation);
begin
  Join.Alias := 'T' + TableIndex.ToString;

  Inc(TableIndex);

  for var ForeignKey in Join.Table.ForeignKeys do
    if not ForeignKey.Field.IsLazy and (not Assigned(ManyValueAssociationToIgnore) or (ForeignKey <> ManyValueAssociationToIgnore.ForeignKey)) then
    begin
      if not RecursionControl.ContainsKey(ForeignKey.ParentTable) then
        RecursionControl.Add(ForeignKey.ParentTable, 0);

      if RecursionControl[ForeignKey.ParentTable] < FRecursivityLevel then
      begin
        var NewJoin := TQueryBuilderJoin.Create(ForeignKey.ParentTable, ForeignKey.Field, ForeignKey.Field, Join.Table.PrimaryKey, ForeignKey.IsInheritedLink);
        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] + 1;

        Join.Links := Join.Links + [NewJoin];

        MakeJoin(NewJoin, TableIndex, RecursionControl, ManyValueAssociationToIgnore);

        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] - 1;
      end;
    end;

  for var ManyValueAssociation in Join.Table.ManyValueAssociations do
    if not Assigned(ManyValueAssociationToIgnore) or (ManyValueAssociation <> ManyValueAssociationToIgnore) then
    begin
      var NewJoin := TQueryBuilderJoin.Create(ManyValueAssociation.ChildTable, ManyValueAssociation.Field, Join.Table.PrimaryKey, ManyValueAssociation.ForeignKey.Field, False);

      Join.Links := Join.Links + [NewJoin];

      MakeJoin(NewJoin, TableIndex, RecursionControl, ManyValueAssociation);
    end;
end;

function TQueryBuilderFrom.MakeJoinSQL(Join: TQueryBuilderJoin): String;
begin
  Result := EmptyStr;

  for var Link in Join.Links do
    Result := Result + Format(' left join %s %s on %s.%s=%s.%s', [Link.Table.DatabaseName, Link.Alias, Join.Alias, Link.LeftField.DatabaseName, Link.Alias,
      Link.RightField.DatabaseName]) + MakeJoinSQL(Link);
end;

{ TQueryBuilderSelect }

function TQueryBuilderSelect.All: TQueryBuilderFrom;
begin
  Result := TQueryBuilderFrom.Create(Self, FRecursivityLevel);

  FFieldList := TQueryBuilderAllFields.Create(Result);
  FFrom := Result;
end;

constructor TQueryBuilderSelect.Create(Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FRecursivityLevel := 1;
end;

destructor TQueryBuilderSelect.Destroy;
begin
  FFrom.Free;

  FFieldList.Free;

  inherited;
end;

function TQueryBuilderSelect.First(Total: Cardinal): TQueryBuilderSelect;
begin
  FFirstRecords := Total;
  Result := Self;
end;

function TQueryBuilderSelect.GetFieldsWithAlias: String;
begin
  var FieldAlias: TFieldAlias;
  var FieldList := FFrom.GetFields;
  Result := EmptyStr;

  for var A := Low(FieldList) to High(FieldList) do
  begin
    FieldAlias := FieldList[A];

    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + Format('%s.%s F%d', [FieldAlias.TableAlias, FieldAlias.Field.DatabaseName, Succ(A)]);
  end;
end;

function TQueryBuilderSelect.GetFields: TArray<TFieldAlias>;
begin
  Result := FFieldList.GetFields;
end;

function TQueryBuilderSelect.GetSQL: String;
begin
  Result := 'select ';

  if FirstRecords > 0 then
    Result := Result + Format('top %d ', [FirstRecords]);

  if Assigned(FFrom) then
    Result := Result + GetFieldsWithAlias + FFrom.GetSQL;
end;

function TQueryBuilderSelect.RecursivityLevel(const Level: Word): TQueryBuilderSelect;
begin
  FRecursivityLevel := Level;
  Result := Self;
end;

function TQueryBuilderSelect.GetBuilder: TQueryBuilder;
begin
  Result := FBuilder;
end;

{ TQueryBuilderWhere<T> }

procedure TQueryBuilderWhere<T>.BuildFilter(const Value: TQueryBuilderComparisonHelper);
begin
  try
    FFilter := ' where ' + MakeFilter(Value.Comparison);
  finally
    Value.Comparison.Free;
  end;
end;

function TQueryBuilderWhere<T>.GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String;
begin
  var Table := FTable;

  if Assigned(FFrom) then
  begin
    var CurrentJoin := FFrom.Join;
    Field := nil;
    var FieldCount := High(QueryField.FieldNames);

    if FieldCount = 0 then
    begin
      while Assigned(Table) and not CurrentJoin.Table.FindField(QueryField.FieldName, Field) do
      begin
        Table := Table.BaseTable;

        for var Join in CurrentJoin.Links do
          if Join.Table = Table then
          begin
            CurrentJoin := Join;

            Break;
          end;
      end;
    end
    else
    begin
      for var A := Low(QueryField.FieldNames) to Pred(FieldCount) do
      begin
        var FieldName := QueryField.FieldNames[A];

        for var Join in CurrentJoin.Links do
          if Join.Field.Name = FieldName then
          begin
            CurrentJoin := Join;

            Break;
          end;
      end;

      CurrentJoin.Table.FindField(QueryField.FieldNames[FieldCount], Field);
    end;

    if Assigned(Field) then
      Exit(Format('%s.%s', [CurrentJoin.Alias, Field.DatabaseName]));
  end
  else if Table.FindField(QueryField.FieldName, Field) then
    Exit(Field.DatabaseName);

  raise EFieldNotFoundInTable.Create(QueryField.FieldName);
end;

function TQueryBuilderWhere<T>.GetField(const QueryField: TQueryBuilderFieldAlias): String;
var
  Field: TField;

begin
  Result := GetField(QueryField, Field);
end;

function TQueryBuilderWhere<T>.GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  case Comparison.Comparison of
    qbcoBetween: Result := Format(' between %s and %s', [Field.GetAsString(Comparison.Right.Value.GetArrayElement(0).AsType<TValue>), Field.GetAsString(Comparison.Right.Value.GetArrayElement(1).AsType<TValue>)]);
    qbcoLike: Result := Format(' like ''%s''', [Comparison.Right.Value.AsString]);
    qbcoNull: Result := ' is null';
    qbcoNotNull: Result := ' is not null';
    else Result := Field.GetAsString(Comparison.Right.Value);
  end;
end;

function TQueryBuilderWhere<T>.GetSQL: String;
begin
  Result := FFilter + FOrderBy.GetSQL;
end;

function TQueryBuilderWhere<T>.GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  if Assigned(Comparison.Right) and Assigned(Comparison.Right.Field) then
    Result := GetField(Comparison.Right.Field)
  else
    Result := GetFieldValue(Comparison, Field);
end;

function TQueryBuilderWhere<T>.MakeComparison(const Comparison: TQueryBuilderComparison): String;
const
  COMPARISON_OPERATOR: array[TQueryBuilderComparisonOperator] of String = ('', '=', '<>', '>', '>=', '<', '<=', '', '', '', '');

begin
  var Field: TField;
  var FieldName := GetField(Comparison.Left.Field, Field);

  Result := Format('%s%s%s', [FieldName, COMPARISON_OPERATOR[Comparison.Comparison], GetValueToCompare(Comparison, Field)]);
end;

function TQueryBuilderWhere<T>.MakeFilter(const Value: TQueryBuilderComparison): String;
begin
  if Value.Comparison <> qbcoNone then
    Result := MakeComparison(Value)
  else if Value.Logical <> qloNone then
    Result := MakeLogical(Value);
end;

function TQueryBuilderWhere<T>.MakeLogical(const Logical: TQueryBuilderComparison): String;
const
  LOGICAL_OPERATOR: array[TQueryBuilderLogicalOperator] of String = ('', 'and', 'or');

begin
  Result := Format('(%s %s %s)', [MakeFilter(Logical.Left), LOGICAL_OPERATOR[Logical.Logical], MakeFilter(Logical.Right)]);
end;

constructor TQueryBuilderWhere<T>.Create(const From: TQueryBuilderFrom);
begin
  FFrom := From;

  Create(From.Table);
end;

constructor TQueryBuilderWhere<T>.Create(const Table: TTable);
begin
  inherited Create;

  FOrderBy := TQueryBuilderOrderBy<T>.Create(Self);
  FTable := Table;
end;

destructor TQueryBuilderWhere<T>.Destroy;
begin
  FOpen.Free;

  FOrderBy.Free;

  inherited;
end;

function TQueryBuilderWhere<T>.Open: TQueryBuilderOpen<T>;
begin
  FOpen := TQueryBuilderOpen<T>.Create(FFrom);
  Result := FOpen;
end;

function TQueryBuilderWhere<T>.OrderBy: TQueryBuilderOrderBy<T>;
begin
  Result := FOrderBy;
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
begin
  Result := Self;

  BuildFilter(Condition);
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := TClassLoader(FLoader).LoadAll<T>;
end;

constructor TQueryBuilderOpen<T>.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FLoader := TClassLoader.Create(From.GetBuilder.GetConnection.OpenCursor(From.Builder.GetSQL), From);
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

constructor TQueryBuilderAllFields.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;
end;

function TQueryBuilderAllFields.GetAllFields(Join: TQueryBuilderJoin): TArray<TFieldAlias>;
begin
  Result := nil;

  for var Field in Join.Table.Fields do
    if not Field.IsJoinLink or Field.IsLazy then
      Result := Result + [TFieldAlias.Create(Join.Alias, Field)];

  for var Link in Join.Links do
    Result := Result + GetAllFields(Link);
end;

function TQueryBuilderAllFields.GetFields: TArray<TFieldAlias>;
begin
  Result := GetAllFields(FFrom.Join);
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
  for var Link in Links do
    Link.Free;

  inherited;
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
  InitComparison(Result);

  Result.Comparison.Left := Self.Comparison;
  Result.Comparison.Comparison := qbcoBetween;
  Result.Comparison.Right.Value := TValue.From<TArray<T>>([ValueStart, ValueEnd]);
end;

class operator TQueryBuilderComparisonHelper.BitwiseAnd(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  InitComparison(Result);

  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Logical := qloAnd;
  Result.Comparison.Right := Right.Comparison;
end;

class operator TQueryBuilderComparisonHelper.BitwiseOr(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  InitComparison(Result);

  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Logical := qloOr;
  Result.Comparison.Right := Right.Comparison;
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

class procedure TQueryBuilderComparisonHelper.InitComparison(var Result: TQueryBuilderComparisonHelper);
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.Comparison := TQueryBuilderComparison.Create;
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
  InitComparison(Result);

  Result.Comparison.Left := Self.Comparison;
  Result.Comparison.Comparison := qbcoLike;
  Result.Comparison.Right.Value := Value;
end;

class procedure TQueryBuilderComparisonHelper.MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left: TQueryBuilderComparisonHelper; const Right: TValue;
  var Result: TQueryBuilderComparisonHelper);
begin
  InitComparison(Result);

  Result.Comparison.Left := Left.Comparison;
  Result.Comparison.Comparison := Comparison;
  Result.Comparison.Right.Value := Right;
end;

class procedure TQueryBuilderComparisonHelper.MakeComparison(const Comparison: TQueryBuilderComparisonOperator; const Left, Right: TQueryBuilderComparisonHelper;
  var Result: TQueryBuilderComparisonHelper);
begin
  InitComparison(Result);

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

{ TQueryBuilderOrderBy<T> }

constructor TQueryBuilderOrderBy<T>.Create(const Where: TQueryBuilderWhere<T>);
begin
  inherited Create;

  FWhere := Where;
end;

destructor TQueryBuilderOrderBy<T>.Destroy;
begin
  for var Field in FFields do
    Field.Free;

  inherited;
end;

function TQueryBuilderOrderBy<T>.Field(const FieldName: String; const Ascending: Boolean): TQueryBuilderOrderBy<T>;
begin
  FFields := FFields + [TQueryBuilderOrderByField.Create(FieldName, Ascending)];
  Result := Self;
end;

function TQueryBuilderOrderBy<T>.GetSQL: String;
begin
  Result := EmptyStr;

  for var Field in Fields do
  begin
    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + FWhere.GetField(Field);

    if not Field.Ascending then
      Result := Result + ' desc';
  end;

  if not Result.IsEmpty then
    Result := ' order by ' + Result;
end;

function TQueryBuilderOrderBy<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := FWhere.Open;
end;

{ TQueryBuilderOrderByField }

constructor TQueryBuilderOrderByField.Create(const FieldName: String; const Ascending: Boolean);
begin
  inherited Create(FieldName);

  FAscending := Ascending;
end;

end.

