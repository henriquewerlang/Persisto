unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper;

type
  TQueryBuilder = class;
  TQueryBuilderFrom = class;
  TQueryBuilderJoin = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class> = class;

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
    function GetJoin: TQueryBuilderJoin;
    function MakeJoinSQL(Join: TQueryBuilderJoin): String;

    procedure BuildJoin;
    procedure MakeJoin(Join: TQueryBuilderJoin; var TableIndex: Integer; RecursionControl: TDictionary<TTable, Word>; const ManyValueAssociationToIgnore: TManyValueAssociation);
  public
    constructor Create(Select: TQueryBuilderSelect; RecursivityLevel: Word);

    destructor Destroy; override;

    function From<T: class>: TQueryBuilderWhere<T>;
    function GetSQL: String;

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
    FCursor: IDatabaseCursor;
    FFrom: TQueryBuilderFrom;
  public
    constructor Create(From: TQueryBuilderFrom);

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

  TQueryBuilderOperator = (qboEqual, qboNotEqual, qboGreaterThan, qboGreaterThanOrEqual, qboLessThan, qboLessThanOrEqual, qboAnd, qboOr);

  TQueryBuilderCondition = record
  private
    class function GenerateCondition(const Condition: TQueryBuilderCondition; const Operator: TQueryBuilderOperator; const Value: String): String; static;
  public
    Condition: String;

    class operator BitwiseAnd(const Left, Right: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator BitwiseOr(const Left, Right: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: TValue): TQueryBuilderCondition;
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: Variant): TQueryBuilderCondition;
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: TObject): TQueryBuilderCondition;
    class operator Equal(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator GreaterThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator GreaterThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator GreaterThan(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator GreaterThanOrEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator LessThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator LessThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator LessThan(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator LessThanOrEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: Variant): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: TValue): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: TObject): TQueryBuilderCondition;
    class operator NotEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
  end;

  TQueryBuilderWhere<T: class> = class(TQueryBuilderCommand)
  private
    FFilter: String;
    FFrom: TQueryBuilderFrom;
    FOpen: TObject;
  public
    constructor Create(From: TQueryBuilderFrom);

    destructor Destroy; override;

    function GetSQL: String; override;
    function Open: TQueryBuilderOpen<T>;
    function Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
  end;

function Field(const Name: String): TQueryBuilderCondition;

const
  OPERATOR_CHAR: array[TQueryBuilderOperator] of String = ('=', '<>', '>', '>=', '<', '<=', ' and ', ' or ');

implementation

uses System.TypInfo, System.Variants, Delphi.ORM.Attributes, Delphi.ORM.Rtti.Helper, Delphi.ORM.Classes.Loader;

function Field(const Name: String): TQueryBuilderCondition;
begin
  Result.Condition := Name;
end;

{ TQueryBuilder }

constructor TQueryBuilder.Create(Connection: IDatabaseConnection);
begin
  inherited Create;

  FConnection := Connection;
end;

procedure TQueryBuilder.Delete<T>(const AObject: T);
begin
  var Condition: TQueryBuilderCondition;
  var Table := TMapper.Default.FindTable(AObject.ClassType);
  var Where := TQueryBuilderWhere<T>.Create(nil);

  if Assigned(Table.PrimaryKey) then
    Condition := Field(Table.PrimaryKey.DatabaseName) = Table.PrimaryKey.GetValue(TObject(AObject));

  FConnection.ExecuteDirect(Format('delete from %s%s', [Table.DatabaseName, Where.Where(Condition).GetSQL]));

  Where.Free;
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
  var Condition: TQueryBuilderCondition;
  var SQL := EmptyStr;
  var Table := TMapper.Default.FindTable(AObject.ClassType);
  var Where := TQueryBuilderWhere<T>.Create(nil);

  for var TableField in Table.Fields do
    if TableField.InPrimaryKey then
    begin
      var Comparision := Field(TableField.DatabaseName) = TableField.GetValue(TObject(AObject));

      if Condition.Condition.IsEmpty then
        Condition := Comparision
      else
        Condition := Condition and Comparision;
    end
    else if not TableField.IsManyValueAssociation then
    begin
      if not SQL.IsEmpty then
        SQL := SQL + ',';

      SQL := SQL + Format('%s=%s', [TableField.DatabaseName, TableField.GetAsString(TObject(AObject))]);
    end;

  SQL := Format('update %s set %s', [Table.DatabaseName, SQL]) + Where.Where(Condition).GetSQL;

  FConnection.ExecuteDirect(SQL);

  Where.Free;
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

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  FJoin := TQueryBuilderJoin.Create(TMapper.Default.FindTable(T));
  Result := TQueryBuilderWhere<T>.Create(Self);

  FWhere := Result;

  BuildJoin;
end;

function TQueryBuilderFrom.GetBuilder: TQueryBuilder;
begin
  Result := FSelect.GetBuilder;
end;

function TQueryBuilderFrom.GetFields: TArray<TFieldAlias>;
begin
  Result := FSelect.GetFields;
end;

function TQueryBuilderFrom.GetJoin: TQueryBuilderJoin;
begin
  Result := FJoin;
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
    if not Assigned(ManyValueAssociationToIgnore) or (ForeignKey <> ManyValueAssociationToIgnore.ForeignKey) then
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

constructor TQueryBuilderWhere<T>.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;
end;

destructor TQueryBuilderWhere<T>.Destroy;
begin
  FOpen.Free;

  inherited;
end;

function TQueryBuilderWhere<T>.GetSQL: String;
begin
  Result := EmptyStr;

  if not FFilter.IsEmpty then
    Result := ' where ' + FFilter;
end;

function TQueryBuilderWhere<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FFrom);

  FOpen := Result;
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
begin
  FFilter := Condition.Condition;
  Result := Self;
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  var Loader := TClassLoader.Create(FCursor, FFrom.GetJoin, FFrom.GetFields);

  Result := Loader.LoadAll<T>;

  Loader.Free;
end;

constructor TQueryBuilderOpen<T>.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;

  FCursor := FFrom.GetBuilder.GetConnection.OpenCursor(FFrom.GetBuilder.GetSQL);
end;

function TQueryBuilderOpen<T>.One: T;
begin
  var Loader := TClassLoader.Create(FCursor, FFrom.GetJoin, FFrom.GetFields);

  Result := Loader.Load<T>;

  Loader.Free;
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

  if Assigned(Join.Table.PrimaryKey) then
    Result := Result + [TFieldAlias.Create(Join.Alias, Join.Table.PrimaryKey)];

  for var Field in Join.Table.Fields do
    if not Field.InPrimaryKey and not Field.IsJoinLink then
      Result := Result + [TFieldAlias.Create(Join.Alias, Field)];

  for var Link in Join.Links do
    Result := Result + GetAllFields(Link);
end;

function TQueryBuilderAllFields.GetFields: TArray<TFieldAlias>;
begin
  Result := GetAllFields(FFrom.GetJoin);
end;

{ TQueryBuilderCondition }

class operator TQueryBuilderCondition.Equal(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboEqual, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.BitwiseAnd(const Left, Right: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Left, qboAnd, Right.Condition);
end;

class operator TQueryBuilderCondition.BitwiseOr(const Left, Right: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := Format('(%s)', [GenerateCondition(Left, qboOr, Right.Condition)]);
end;

class operator TQueryBuilderCondition.Equal(const Condition: TQueryBuilderCondition; const Value: TValue): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboEqual, Value.ToString);
end;

class function TQueryBuilderCondition.GenerateCondition(const Condition: TQueryBuilderCondition; const &Operator: TQueryBuilderOperator; const Value: String): String;
begin
  Result := Format('%s%s%s', [Condition.Condition, OPERATOR_CHAR[&Operator], Value]);
end;

class operator TQueryBuilderCondition.GreaterThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThan, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.GreaterThan(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThan, Value.Condition);
end;

class operator TQueryBuilderCondition.GreaterThanOrEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThanOrEqual, Value.Condition);
end;

class operator TQueryBuilderCondition.GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThanOrEqual, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.LessThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThan, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.LessThan(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThan, Value.Condition);
end;

class operator TQueryBuilderCondition.LessThanOrEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThanOrEqual, Value.Condition);
end;

class operator TQueryBuilderCondition.LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThanOrEqual, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.NotEqual(const Condition: TQueryBuilderCondition; const Value: TValue): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboNotEqual, Value.ToString);
end;

class operator TQueryBuilderCondition.NotEqual(const Condition: TQueryBuilderCondition; const Value: Variant): TQueryBuilderCondition;
begin
  if Value = NULL then
    Result.Condition := Condition.Condition + ' is not null'
  else
    Result := Condition <> TValue.FromVariant(Value);
end;

class operator TQueryBuilderCondition.NotEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboNotEqual, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.Equal(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboEqual, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.GreaterThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThan, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThanOrEqual, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.LessThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThan, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThanOrEqual, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.NotEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboNotEqual, FloatToStr(Value, TFormatSettings.Invariant));
end;

class operator TQueryBuilderCondition.Equal(const Condition: TQueryBuilderCondition; const Value: Variant): TQueryBuilderCondition;
begin
  if Value = NULL then
    Result.Condition := Condition.Condition + ' is null'
  else
    Result := Condition = TValue.FromVariant(Value);
end;

class operator TQueryBuilderCondition.Equal(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboEqual, Value.Condition);
end;

class operator TQueryBuilderCondition.NotEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboNotEqual, Value.Condition);
end;

class operator TQueryBuilderCondition.NotEqual(const Condition: TQueryBuilderCondition; const Value: TObject): TQueryBuilderCondition;
begin
  var Table := TMapper.Default.FindTable(Value.ClassType);

  Result.Condition := GenerateCondition(Condition, qboNotEqual, Table.PrimaryKey.GetAsString(Value));
end;

class operator TQueryBuilderCondition.Equal(const Condition: TQueryBuilderCondition; const Value: TObject): TQueryBuilderCondition;
begin
  var Table := TMapper.Default.FindTable(Value.ClassType);

  Result.Condition := GenerateCondition(Condition, qboEqual, Table.PrimaryKey.GetAsString(Value));
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

end.

