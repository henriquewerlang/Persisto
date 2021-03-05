unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Nullable;

type
  TQueryBuilder = class;
  TQueryBuilderComparison = class;
  TQueryBuilderComparisonValue = class;
  TQueryBuilderFrom = class;
  TQueryBuilderJoin = class;
  TQueryBuilderLogicalOperation = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class> = class;

  ECantUseComposeFieldName = class(Exception)
  public
    constructor Create;
  end;

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

    function BuildFilter<T: class>(const Table: TTable; const AObject: T): String;
    function GetConnection: IDatabaseConnection;
  public
    constructor Create(Connection: IDatabaseConnection);

    destructor Destroy; override;

    function GetSQL: String;
    function Select: TQueryBuilderSelect;

    procedure Delete<T: class>(const AObject: T);
    procedure Insert<T: class>(const AObject: T);
    procedure Update<T: class>(const AObject: T);

    property Connection: IDatabaseConnection read FConnection;
  end;

  TQueryBuilderFrom = class
  private
    FJoin: TQueryBuilderJoin;
    FWhere: TQueryBuilderCommand;
    FRecursivityLevel: Word;
    FSelect: TQueryBuilderSelect;

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
  end;

  TQueryBuilderJoin = class
  private
    FAlias: String;
    FLinks: TArray<TQueryBuilderJoin>;
    FTable: TTable;
    FLeftField: TField;
    FRightField: TField;
    FField: TField;
  public
    constructor Create(Table: TTable); overload;
    constructor Create(Table: TTable; Field, LeftField, RightField: TField); overload;

    destructor Destroy; override;

    property Alias: String read FAlias write FAlias;
    property Field: TField read FField write FField;
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

    property RecursivityLevelValue: Word read FRecursivityLevel write FRecursivityLevel;
  end;

  TQueryBuilderFieldAlias = class
  private
    FFieldNames: TArray<String>;
  public
    constructor Create(const FieldName: String);

    property FieldNames: TArray<String> read FFieldNames;
  end;

  TQueryBuilderComparisonValueType = (cvtComparison, cvtFieldAlias, cvtValue);

  TQueryBuilderComparisonValue = class
  private
    FField: TQueryBuilderFieldAlias;
    FComparison: TQueryBuilderComparison;
    FValue: TValue;
    FLogical: TQueryBuilderLogicalOperation;
  public
    constructor Create(const Comparison: TQueryBuilderComparison); overload;
    constructor Create(const Field: TQueryBuilderFieldAlias); overload;
    constructor Create(const Logical: TQueryBuilderLogicalOperation); overload;
    constructor Create(const Value: TValue); overload;

    destructor Destroy; override;

    property Comparison: TQueryBuilderComparison read FComparison write FComparison;
    property Field: TQueryBuilderFieldAlias read FField;
    property Logical: TQueryBuilderLogicalOperation read FLogical write FLogical;
    property Value: TValue read FValue write FValue;
  end;

  TQueryBuilderComparisonOperator = (qbcoNone, qbcoEqual, qbcoNotEqual, qbcoGreaterThan, qbcoGreaterThanOrEqual, qbcoLessThan, qbcoLessThanOrEqual, qbcoNull, qbcoNotNull, 
    qbcoBetween, qbcoLike);

  TQueryBuilderComparison = class
  private
    FLeft: TQueryBuilderFieldAlias;
    FRight: TQueryBuilderComparisonValue;
    FOperation: TQueryBuilderComparisonOperator;
  public
    destructor Destroy; override;

    property Left: TQueryBuilderFieldAlias read FLeft write FLeft;
    property Operation: TQueryBuilderComparisonOperator read FOperation write FOperation;
    property Right: TQueryBuilderComparisonValue read FRight write FRight;
  end;

  TQueryBuilderLogicalOperator = (qloAnd, qloOr);

  TQueryBuilderLogicalOperation = class
  private
    FLeft: TQueryBuilderComparisonValue;
    FOperation: TQueryBuilderLogicalOperator;
    FRight: TQueryBuilderComparisonValue;
  public
    destructor Destroy; override;

    property Left: TQueryBuilderComparisonValue read FLeft write FLeft;
    property Operation: TQueryBuilderLogicalOperator read FOperation write FOperation;
    property Right: TQueryBuilderComparisonValue read FRight write FRight;
  end;

  TQueryBuilderComparisonRecord = record
  public
    Value: TQueryBuilderComparisonValue;
  end;

  TQueryBuilderLogicalOperationHelper = record
  private
    class procedure MakeOperation(const Left, Right: TQueryBuilderComparisonValue; const Operation: TQueryBuilderLogicalOperator; out Result: TQueryBuilderLogicalOperationHelper); static;
  public
    Value: TQueryBuilderComparisonValue;

    class operator BitwiseAnd(const Left, Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseAnd(const Left: TQueryBuilderComparisonRecord; const Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseAnd(const Left: TQueryBuilderLogicalOperationHelper; const Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseOr(const Left, Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseOr(const Left: TQueryBuilderComparisonRecord; const Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseOr(const Left: TQueryBuilderLogicalOperationHelper; const Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
  end;

  TQueryBuilderComparisonHelper = record helper for TQueryBuilderComparisonRecord
  private
    class function MakeFieldValue(const Value: TQueryBuilderComparisonRecord): TQueryBuilderComparisonValue; static;

    procedure MakeCompareOperation(const Operation: TQueryBuilderComparisonOperator; const CompareValue: TQueryBuilderComparisonValue; out Result: TQueryBuilderComparisonRecord); overload;
    procedure MakeCompareOperation(const Operation: TQueryBuilderComparisonOperator; const ValueOp: TValue; out Result: TQueryBuilderComparisonRecord); overload;
    procedure MakeEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
    procedure MakeGreaterThan(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
    procedure MakeGreaterThanOrEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
    procedure MakeLessThan(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
    procedure MakeLessThanOrEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
    procedure MakeNotEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);

    class procedure MakeLogicalOperation(const Left, Right: TQueryBuilderComparisonRecord; const Operation: TQueryBuilderLogicalOperator; out Result: TQueryBuilderLogicalOperationHelper); static;
  public
    function Between<T>(const ValueStart, ValueEnd: T): TQueryBuilderComparisonRecord;
    function Like(const Condition: String): TQueryBuilderComparisonRecord;

    class operator BitwiseAnd(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
    class operator BitwiseOr(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
    class operator Equal(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator Equal(const Left: TQueryBuilderComparisonRecord; const Value: TNullEnumerator): TQueryBuilderComparisonRecord;
    class operator Equal(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator Equal(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
    class operator GreaterThan(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator GreaterThan(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator GreaterThan(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
    class operator GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator GreaterThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator GreaterThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
    class operator LessThan(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator LessThan(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator LessThan(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
    class operator LessThanOrEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator LessThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator LessThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
    class operator NotEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
    class operator NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: TNullEnumerator): TQueryBuilderComparisonRecord;
    class operator NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
    class operator NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
  end;

  TQueryBuilderWhere<T: class> = class(TQueryBuilderCommand)
  private
    FFilter: String;
    FFrom: TQueryBuilderFrom;
    FOpen: TQueryBuilderOpen<T>;
    FAllFields: TQueryBuilderAllFields;

    function GetField(const QueryField: TQueryBuilderFieldAlias): String; overload;
    function GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String; overload;
    function GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
    function MakeComparison(const Comparison: TQueryBuilderComparison): String;
    function MakeFilter(const Value: TQueryBuilderComparisonValue): String;
    function MakeLogical(const Logical: TQueryBuilderLogicalOperation): String;

    procedure BuildFilter(const Value: TQueryBuilderComparisonValue);
  public
    constructor Create(From: TQueryBuilderFrom);

    destructor Destroy; override;

    function GetSQL: String; override;
    function Open: TQueryBuilderOpen<T>;
    function Where(const Condition: TQueryBuilderComparisonRecord): TQueryBuilderWhere<T>; overload;
    function Where(const Condition: TQueryBuilderLogicalOperationHelper): TQueryBuilderWhere<T>; overload;
  end;

function Field(const Name: String): TQueryBuilderComparisonRecord;

implementation

uses System.TypInfo, Delphi.ORM.Attributes, Delphi.ORM.Rtti.Helper, Delphi.ORM.Classes.Loader;

function Field(const Name: String): TQueryBuilderComparisonRecord;
begin
  Result.Value := TQueryBuilderComparisonValue.Create(TQueryBuilderComparison.Create);
  Result.Value.Comparison.Left := TQueryBuilderFieldAlias.Create(Name);
end;

{ TQueryBuilder }

function TQueryBuilder.BuildFilter<T>(const Table: TTable; const AObject: T): String;
begin
  Result := EmptyStr;

  if Assigned(Table.PrimaryKey) then
  begin
    var Condition := Field(Table.PrimaryKey.TypeInfo.Name) = Table.PrimaryKey.GetValue(AObject);
    var Where := TQueryBuilderWhere<T>.Create(nil);

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
  var Table := TMapper.Default.FindTable(AObject.ClassType);

  FConnection.ExecuteDirect(Format('delete from %s%s', [Table.DatabaseName, BuildFilter(Table, AObject)]));
end;

destructor TQueryBuilder.Destroy;
begin
  FCommand.Free;

  inherited;
end;

procedure TQueryBuilder.Insert<T>(const AObject: T);
begin
  var OutputFieldList: TArray<TField> := nil;
  var OutputFieldNameList: TArray<String> := nil;
  var Table := TMapper.Default.FindTable(AObject.ClassType);

  var SQL := '(%s)values(%s)';

  for var Field in Table.Fields do
    if Field.AutoGenerated then
    begin
      OutputFieldList := OutputFieldList + [Field];
      OutputFieldNameList := OutputFieldNameList + [Field.DatabaseName];
    end
    else if not Field.IsManyValueAssociation then
      SQL := Format(SQL, [Field.DatabaseName + '%2:s%0:s', Field.GetAsString(TObject(AObject)) + '%2:s%1:s', ',']);

  var Cursor := FConnection.ExecuteInsert('insert into ' + Table.DatabaseName + Format(SQL, ['', '', '', '']), OutputFieldNameList);

  if Cursor.Next then
    for var A := Low(OutputFieldList) to High(OutputFieldList) do
      OutputFieldList[A].SetValue(TObject(AObject), Cursor.GetFieldValue(A));
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

function TQueryBuilder.Select: TQueryBuilderSelect;
begin
  Result := TQueryBuilderSelect.Create(Self);

  FCommand := Result;
end;

procedure TQueryBuilder.Update<T>(const AObject: T);
begin
  var SQL := EmptyStr;
  var Table := TMapper.Default.FindTable(AObject.ClassType);

  for var TableField in Table.Fields do
    if not TableField.InPrimaryKey and not TableField.IsManyValueAssociation then
    begin
      if not SQL.IsEmpty then
        SQL := SQL + ',';

      SQL := SQL + Format('%s=%s', [TableField.DatabaseName, TableField.GetAsString(TObject(AObject))]);
    end;

  SQL := Format('update %s set %s%s', [Table.DatabaseName, SQL, BuildFilter<T>(Table, AObject)]);

  FConnection.ExecuteDirect(SQL);
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
        var NewJoin := TQueryBuilderJoin.Create(ForeignKey.ParentTable, ForeignKey.Field, ForeignKey.Field, Join.Table.PrimaryKey);
        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] + 1;

        Join.Links := Join.Links + [NewJoin];

        MakeJoin(NewJoin, TableIndex, RecursionControl, ManyValueAssociationToIgnore);

        RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] - 1;
      end;
    end;

  for var ManyValueAssociation in Join.Table.ManyValueAssociations do
    if not Assigned(ManyValueAssociationToIgnore) or (ManyValueAssociation <> ManyValueAssociationToIgnore) then
    begin
      var NewJoin := TQueryBuilderJoin.Create(ManyValueAssociation.ChildTable, ManyValueAssociation.Field, Join.Table.PrimaryKey, ManyValueAssociation.ForeignKey.Field);

      Join.Links := Join.Links + [NewJoin];

      MakeJoin(NewJoin, TableIndex, RecursionControl, ManyValueAssociation);
    end;
end;

function TQueryBuilderFrom.MakeJoinSQL(Join: TQueryBuilderJoin): String;
begin
  Result := EmptyStr;

  for var Link in Join.Links do
    Result := Result + Format(' left join %s %s on %s.%s=%s.%s', [Link.Table.DatabaseName, Link.Alias, Join.Alias, Link.LeftField.DatabaseName, Link.Alias, Link.RightField.DatabaseName])
      + MakeJoinSQL(Link);
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

procedure TQueryBuilderWhere<T>.BuildFilter(const Value: TQueryBuilderComparisonValue);
begin
  try
    FFilter := ' where ' + MakeFilter(Value);
  finally
    Value.Free;
  end;
end;

constructor TQueryBuilderWhere<T>.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;
end;

destructor TQueryBuilderWhere<T>.Destroy;
begin
  FOpen.Free;

  FAllFields.Free;

  inherited;
end;

function TQueryBuilderWhere<T>.GetField(const QueryField: TQueryBuilderFieldAlias; var Field: TField): String;
begin
  var CurrentJoin: TQueryBuilderJoin := nil;
  var FieldNameToFind := QueryField.FieldNames[High(QueryField.FieldNames)];
  var Table := TMapper.Default.FindTable(T);

  if Assigned(FFrom) then
  begin
    CurrentJoin := FFrom.Join;

    for var A := Low(QueryField.FieldNames) to Pred(High(QueryField.FieldNames)) do
    begin
      var FieldName := QueryField.FieldNames[A];

      for var Join in CurrentJoin.Links do
        if Join.Field.TypeInfo.Name = FieldName then
        begin
          CurrentJoin := Join;

          Break;
        end;
    end;

    Table := CurrentJoin.Table;
  end
  else if Length(QueryField.FieldNames) <> 1 then
    raise ECantUseComposeFieldName.Create;

  for var FieldVar in Table.Fields do
    if FieldVar.TypeInfo.Name = FieldNameToFind then
    begin
      Field := FieldVar;
      Result := Field.DatabaseName;

      if Assigned(CurrentJoin) then
        Result := Format('%s.%s', [CurrentJoin.Alias, Result]);

      Exit;
    end;

  raise EFieldNotFoundInTable.Create(FieldNameToFind);
end;

function TQueryBuilderWhere<T>.GetField(const QueryField: TQueryBuilderFieldAlias): String;
var
  Field: TField;

begin
  Result := GetField(QueryField, Field);
end;

function TQueryBuilderWhere<T>.GetFieldValue(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  case Comparison.Operation of
    qbcoBetween: Result := Format(' between %s and %s', [Field.GetAsString(Comparison.Right.Value.GetArrayElement(0).AsType<TValue>), Field.GetAsString(Comparison.Right.Value.GetArrayElement(1).AsType<TValue>)]);
    qbcoLike: Result := Format(' like ''%s''', [Comparison.Right.Value.AsString]);
    qbcoNull: Result := ' is null';
    qbcoNotNull: Result := ' is not null';
    else Result := Field.GetAsString(Comparison.Right.Value);
  end;
end;

function TQueryBuilderWhere<T>.GetSQL: String;
begin
  Result := FFilter;
end;

function TQueryBuilderWhere<T>.GetValueToCompare(const Comparison: TQueryBuilderComparison; const Field: TField): String;
begin
  if Assigned(Comparison.Right) and  Assigned(Comparison.Right.Field) then
    Result := GetField(Comparison.Right.Field)
  else
    Result := GetFieldValue(Comparison, Field);
end;

function TQueryBuilderWhere<T>.MakeComparison(const Comparison: TQueryBuilderComparison): String;
const
  COMPARISON_OPERATOR: array[TQueryBuilderComparisonOperator] of String = ('', '=', '<>', '>', '>=', '<', '<=', '', '', '', '');

begin
  var Field: TField;
  var FieldName := GetField(Comparison.Left, Field);

  Result := Format('%s%s%s', [FieldName, COMPARISON_OPERATOR[Comparison.Operation], GetValueToCompare(Comparison, Field)]);
end;

function TQueryBuilderWhere<T>.MakeFilter(const Value: TQueryBuilderComparisonValue): String;
begin
  if Assigned(Value.Comparison) then
    Result := MakeComparison(Value.Comparison)
  else if Assigned(Value.Logical) then
    Result := MakeLogical(Value.Logical);
end;

function TQueryBuilderWhere<T>.MakeLogical(const Logical: TQueryBuilderLogicalOperation): String;
const
  LOGICAL_OPERATOR: array[TQueryBuilderLogicalOperator] of String = ('and', 'or');

begin
  Result := Format('(%s %s %s)', [MakeFilter(Logical.Left), LOGICAL_OPERATOR[Logical.Operation], MakeFilter(Logical.Right)]);
end;

function TQueryBuilderWhere<T>.Open: TQueryBuilderOpen<T>;
begin
  FOpen := TQueryBuilderOpen<T>.Create(FFrom);
  Result := FOpen;
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderComparisonRecord): TQueryBuilderWhere<T>;
begin
  Result := Self;

  BuildFilter(Condition.Value);
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderLogicalOperationHelper): TQueryBuilderWhere<T>;
begin
  Result := Self;

  BuildFilter(Condition.Value);
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := TClassLoader(FLoader).LoadAll<T>;
end;

constructor TQueryBuilderOpen<T>.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FLoader := TClassLoader.Create(From.GetBuilder.GetConnection, From);
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

constructor TQueryBuilderJoin.Create(Table: TTable; Field, LeftField, RightField: TField);
begin
  Create(Table);

  FField := Field;
  FLeftField := LeftField;
  FRightField := RightField;
end;

constructor TQueryBuilderJoin.Create(Table: TTable);
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
  FFieldNames := FieldName.Split(['.']);
end;

{ TQueryBuilderComparisonHelper }

function TQueryBuilderComparisonHelper.Between<T>(const ValueStart, ValueEnd: T): TQueryBuilderComparisonRecord;
begin
  MakeCompareOperation(qbcoBetween, TValue.From<TArray<TValue>>([TValue.From(ValueStart), TValue.From(ValueEnd)]), Result);
end;

class operator TQueryBuilderComparisonHelper.BitwiseAnd(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
begin
  MakeLogicalOperation(Left, Right, qloAnd, Result);
end;

class operator TQueryBuilderComparisonHelper.BitwiseOr(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
begin
  MakeLogicalOperation(Left, Right, qloOr, Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonRecord; const Value: TNullEnumerator): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoNull, nil, Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoEqual, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeEqual(Value, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeGreaterThan(Value, Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoGreaterThanOrEqual, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoGreaterThan, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeGreaterThan(TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeGreaterThanOrEqual(TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeGreaterThanOrEqual(Value, Result);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeLessThan(Value, Result);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoLessThanOrEqual, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoLessThan, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeLessThanOrEqual(Value, Result);
end;

procedure TQueryBuilderComparisonHelper.MakeCompareOperation(const Operation: TQueryBuilderComparisonOperator; const CompareValue: TQueryBuilderComparisonValue; out Result: TQueryBuilderComparisonRecord);
begin
  Result.Value := Value;
  Result.Value.Comparison.Operation := Operation;
  Result.Value.Comparison.Right := CompareValue;
end;

procedure TQueryBuilderComparisonHelper.MakeEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoEqual, Value, Result);
end;

class function TQueryBuilderComparisonHelper.MakeFieldValue(const Value: TQueryBuilderComparisonRecord): TQueryBuilderComparisonValue;
begin
  Result := TQueryBuilderComparisonValue.Create(Value.Value.Comparison.Left);

  Value.Value.Comparison.Left := nil;

  Value.Value.Free;
end;

procedure TQueryBuilderComparisonHelper.MakeGreaterThan(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoGreaterThan, Value, Result);
end;

procedure TQueryBuilderComparisonHelper.MakeGreaterThanOrEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoGreaterThanOrEqual, Value, Result);
end;

procedure TQueryBuilderComparisonHelper.MakeLessThan(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoLessThan, Value, Result);
end;

procedure TQueryBuilderComparisonHelper.MakeLessThanOrEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoLessThanOrEqual, Value, Result);
end;

class procedure TQueryBuilderComparisonHelper.MakeLogicalOperation(const Left, Right: TQueryBuilderComparisonRecord; const Operation: TQueryBuilderLogicalOperator;
  out Result: TQueryBuilderLogicalOperationHelper);
begin
  Result.Value := TQueryBuilderComparisonValue.Create(TQueryBuilderLogicalOperation.Create);
  Result.Value.Logical.Left := Left.Value;
  Result.Value.Logical.Operation := Operation;
  Result.Value.Logical.Right := Right.Value;
end;

procedure TQueryBuilderComparisonHelper.MakeNotEqual(const Value: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(qbcoNotEqual, Value, Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeNotEqual(TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left, Right: TQueryBuilderComparisonRecord): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoNotEqual, MakeFieldValue(Right), Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: TNullEnumerator): TQueryBuilderComparisonRecord;
begin
  Left.MakeCompareOperation(qbcoNotNull, nil, Result);
end;

procedure TQueryBuilderComparisonHelper.MakeCompareOperation(const Operation: TQueryBuilderComparisonOperator; const ValueOp: TValue; out Result: TQueryBuilderComparisonRecord);
begin
  MakeCompareOperation(Operation, TQueryBuilderComparisonValue.Create(ValueOp), Result);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left: TQueryBuilderComparisonRecord; const Value: TValue): TQueryBuilderComparisonRecord;
begin
  Left.MakeNotEqual(Value, Result);
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeEqual(TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeLessThan(TValue.FromVariant(Value), Result);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left: TQueryBuilderComparisonRecord; const Value: Variant): TQueryBuilderComparisonRecord;
begin
  Left.MakeLessThanOrEqual(TValue.FromVariant(Value), Result);
end;

function TQueryBuilderComparisonHelper.Like(const Condition: String): TQueryBuilderComparisonRecord;
begin
  MakeCompareOperation(qbcoLike, Condition, Result);
end;

{ TQueryBuilderLogicalOperationHelper }

class operator TQueryBuilderLogicalOperationHelper.BitwiseAnd(const Left, Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloAnd, Result);
end;

class operator TQueryBuilderLogicalOperationHelper.BitwiseAnd(const Left: TQueryBuilderComparisonRecord; const Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloAnd, Result);
end;

class operator TQueryBuilderLogicalOperationHelper.BitwiseAnd(const Left: TQueryBuilderLogicalOperationHelper; const Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloAnd, Result);
end;

class operator TQueryBuilderLogicalOperationHelper.BitwiseOr(const Left: TQueryBuilderLogicalOperationHelper; const Right: TQueryBuilderComparisonRecord): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloOr, Result);
end;

class operator TQueryBuilderLogicalOperationHelper.BitwiseOr(const Left: TQueryBuilderComparisonRecord; const Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloOr, Result);
end;

class operator TQueryBuilderLogicalOperationHelper.BitwiseOr(const Left, Right: TQueryBuilderLogicalOperationHelper): TQueryBuilderLogicalOperationHelper;
begin
  MakeOperation(Left.Value, Right.Value, qloOr, Result);
end;

class procedure TQueryBuilderLogicalOperationHelper.MakeOperation(const Left, Right: TQueryBuilderComparisonValue; const Operation: TQueryBuilderLogicalOperator; out Result: TQueryBuilderLogicalOperationHelper);
begin
  Result.Value := TQueryBuilderComparisonValue.Create(TQueryBuilderLogicalOperation.Create);
  Result.Value.Logical.Left := Left;
  Result.Value.Logical.Operation := Operation;
  Result.Value.Logical.Right := Right;
end;

{ TQueryBuilderComparisonValue }

constructor TQueryBuilderComparisonValue.Create(const Comparison: TQueryBuilderComparison);
begin
  FComparison := Comparison;
end;

constructor TQueryBuilderComparisonValue.Create(const Field: TQueryBuilderFieldAlias);
begin
  FField := Field;
end;

constructor TQueryBuilderComparisonValue.Create(const Value: TValue);
begin
  FValue := Value;
end;

constructor TQueryBuilderComparisonValue.Create(const Logical: TQueryBuilderLogicalOperation);
begin
  FLogical := Logical;
end;

destructor TQueryBuilderComparisonValue.Destroy;
begin
  Field.Free;

  Comparison.Free;

  Logical.Free;

  inherited;
end;

{ TQueryBuilderComparison }

destructor TQueryBuilderComparison.Destroy;
begin
  Left.Free;

  Right.Free;

  inherited;
end;

{ TQueryBuilderLogicalOperation }

destructor TQueryBuilderLogicalOperation.Destroy;
begin
  Left.Free;

  Right.Free;

  inherited;
end;

{ EFieldNotFoundInTable }

constructor EFieldNotFoundInTable.Create(FieldName: String);
begin
  inherited CreateFmt('Field "%s" not found in current table!', [FieldName]);
end;

{ ECantUseComposeFieldName }

constructor ECantUseComposeFieldName.Create;
begin
  inherited Create('Can''t use compose field name in this operation!');
end;

end.

