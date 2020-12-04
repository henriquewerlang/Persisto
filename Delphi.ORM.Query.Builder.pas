unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Classes.Loader, Delphi.ORM.Mapper;

type
  TQueryBuilder = class;
  TQueryBuilderFrom = class;
  TQueryBuilderJoin = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class, constructor> = class;

  TFilterOperation = (Equal);

  IQueryBuilderCommand = interface
    function GetSQL: String;
  end;

  IQueryBuilderFieldList = interface
    function GetFields: TArray<TField>;
  end;

  IQueryBuilderOpen<T: class, constructor> = interface
    function All: TArray<T>;
    function One: T;
  end;

  TQueryBuilder = class
  private
    FConnection: IDatabaseConnection;
    FCommand: IQueryBuilderCommand;
    FFieldList: IQueryBuilderFieldList;

    function GetValueString(const Value: TValue): String;
  public
    constructor Create(Connection: IDatabaseConnection);

    function Build: String;
    function Select: TQueryBuilderSelect;

    procedure Delete<T: class, constructor>(const AObject: T);
    procedure Insert<T: class>(const AObject: T);
    procedure Update<T: class, constructor>(const AObject: T);

    property Connection: IDatabaseConnection read FConnection;
  end;

  TQueryBuilderFrom = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FJoin: TQueryBuilderJoin;
    FBuilder: TQueryBuilder;
    FWhere: IQueryBuilderCommand;
    FRecursivityLevel: Word;

    function BuildJoinSQL: String;
    function MakeJoinSQL(Join: TQueryBuilderJoin): String;
    function GetSQL: String;

    procedure BuildJoin;
    procedure MakeJoin(Join: TQueryBuilderJoin; var TableIndex: Integer; RecursionControl: TDictionary<TTable, Word>);
  public
    constructor Create(Builder: TQueryBuilder; RecursivityLevel: Word);

    destructor Destroy; override;

    function From<T: class, constructor>: TQueryBuilderWhere<T>;
  end;

  TQueryBuilderJoin = class
  private
    FAlias: String;
    FLink: TDictionary<TField, TQueryBuilderJoin>;
    FTable: TTable;
  public
    constructor Create(Table: TTable);

    destructor Destroy; override;

    property Alias: String read FAlias write FAlias;
    property Link: TDictionary<TField, TQueryBuilderJoin> read FLink write FLink;
    property Table: TTable read FTable write FTable;
  end;

  TQueryBuilderOpen<T: class, constructor> = class(TInterfacedObject, IQueryBuilderOpen<T>)
  private
    FCursor: IDatabaseCursor;
    FBuilder: TQueryBuilder;
    FLoader: TClassLoader;

    function All: TArray<T>;
    function One: T;
    function GetLoader: TClassLoader;

    property Loader: TClassLoader read GetLoader;
  public
    constructor Create(Cursor: IDatabaseCursor; Builder: TQueryBuilder);

    destructor Destroy; override;
  end;

  TQueryBuilderAllFields = class(TInterfacedObject, IQueryBuilderFieldList)
  private
    FFrom: TQueryBuilderFrom;

    function GetAllFields(Join: TQueryBuilderJoin): TArray<TField>;
    function GetFields: TArray<TField>;
  public
    constructor Create(From: TQueryBuilderFrom);
  end;

  TQueryBuilderSelect = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FConnection: IDatabaseConnection;
    FBuilder: TQueryBuilder;
    FFrom: IQueryBuilderCommand;
    FRecursivityLevel: Word;

    function GetFields: String;
    function GetSQL: String;
  public
    constructor Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);

    function All: TQueryBuilderFrom;
    function RecursivityLevel(const Level: Word): TQueryBuilderSelect;
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
    class operator Equal(const Condition: TQueryBuilderCondition; const Value: TQueryBuilderCondition): TQueryBuilderCondition;
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
    class operator NotEqual(const Condition, Value: TQueryBuilderCondition): TQueryBuilderCondition;
  end;

  TQueryBuilderWhere<T: class, constructor> = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FBuilder: TQueryBuilder;
    FFilter: String;

    function GetSQL: String;
  public
    constructor Create(Builder: TQueryBuilder);

    function Open: IQueryBuilderOpen<T>;
    function Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
  end;

function Field(const Name: String): TQueryBuilderCondition;

const
  OPERATOR_CHAR: array[TQueryBuilderOperator] of String = ('=', '<>', '>', '>=', '<', '<=', ' and ', ' or ');

implementation

uses System.SysUtils, System.TypInfo, System.Variants, Delphi.ORM.Attributes;

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

  for var TableField in Table.PrimaryKey do
  begin
    var Comparision := Field(TableField.DatabaseName) = TableField.TypeInfo.GetValue(TObject(AObject));

    if Condition.Condition.IsEmpty then
      Condition := Comparision
    else
      Condition := Condition and Comparision;
  end;

  FConnection.ExecuteDirect(Format('delete from %s%s', [Table.DatabaseName, Where.Where(Condition).GetSQL]));

  Where.Free;
end;

function TQueryBuilder.GetValueString(const Value: TValue): String;
begin
  case Value.Kind of
    tkEnumeration,
    tkInteger,
    tkInt64: Result := Value.ToString;

    tkFloat: Result := FloatToStr(Value.AsExtended, TFormatSettings.Invariant);

    tkChar,
    tkString,
    tkWChar,
    tkLString,
    tkWString,
    tkUString: Result := QuotedStr(Value.AsString);

    tkUnknown,
    tkSet,
    tkClass,
    tkMethod,
    tkVariant,
    tkArray,
    tkRecord,
    tkInterface,
    tkDynArray,
    tkClassRef,
    tkPointer,
    tkProcedure,
    tkMRecord: raise Exception.Create('Invalid value!');
  end;
end;

procedure TQueryBuilder.Insert<T>(const AObject: T);
begin
  var Table := TMapper.Default.FindTable(AObject.ClassType);

  var SQL := '(%s)values(%s)';

  for var Field in Table.Fields do
    SQL := Format(SQL, [Field.DatabaseName + '%2:s%0:s', GetValueString(Field.TypeInfo.GetValue(TObject(AObject))) + '%2:s%1:s', ',']);

  SQL := 'insert into ' + Table.DatabaseName + Format(SQL, ['', '', '', '']);

  FConnection.ExecuteDirect(SQL);
end;

function TQueryBuilder.Build: String;
begin
  if Assigned(FCommand) then
    Result := FCommand.GetSQL
  else
    Result := EmptyStr;
end;

function TQueryBuilder.Select: TQueryBuilderSelect;
begin
  Result := TQueryBuilderSelect.Create(FConnection, Self);

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
      var Comparision := Field(TableField.DatabaseName) = TableField.TypeInfo.GetValue(TObject(AObject));

      if Condition.Condition.IsEmpty then
        Condition := Comparision
      else
        Condition := Condition and Comparision;
    end
    else
    begin
      if not SQL.IsEmpty then
        SQL := SQL + ',';

      SQL := SQL + Format('%s=%s', [TableField.DatabaseName, GetValueString(TableField.TypeInfo.GetValue(TObject(AObject)))]);
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

  MakeJoin(FJoin, TableIndex, RecursionControl);

  RecursionControl.Free;
end;

function TQueryBuilderFrom.BuildJoinSQL: String;
begin
  Result := Format('%s %s', [FJoin.Table.DatabaseName, FJoin.Alias]) + MakeJoinSQL(FJoin);
end;

constructor TQueryBuilderFrom.Create(Builder: TQueryBuilder; RecursivityLevel: Word);
begin
  inherited Create;

  FBuilder := Builder;
  FRecursivityLevel := RecursivityLevel;
end;

destructor TQueryBuilderFrom.Destroy;
begin
  FJoin.Free;

  inherited;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  FJoin := TQueryBuilderJoin.Create(TMapper.Default.FindTable(T));
  Result := TQueryBuilderWhere<T>.Create(FBuilder);

  FWhere := Result;

  BuildJoin;
end;

function TQueryBuilderFrom.GetSQL: String;
begin
  Result := Format(' from %s', [BuildJoinSQL]);

  if Assigned(FWhere) then
    Result := Result + FWhere.GetSQL;
end;

procedure TQueryBuilderFrom.MakeJoin(Join: TQueryBuilderJoin; var TableIndex: Integer; RecursionControl: TDictionary<TTable, Word>);
begin
  Join.Alias := 'T' + TableIndex.ToString;

  Inc(TableIndex);

  for var ForeignKey in Join.Table.ForeignKeys do
  begin
    if not RecursionControl.ContainsKey(ForeignKey.ParentTable) then
      RecursionControl.Add(ForeignKey.ParentTable, 0);

    if RecursionControl[ForeignKey.ParentTable] < FRecursivityLevel then
    begin
      var NewJoin := TQueryBuilderJoin.Create(ForeignKey.ParentTable);
      RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] + 1;

      Join.Link.Add(ForeignKey.Field, NewJoin);

      MakeJoin(NewJoin, TableIndex, RecursionControl);

      RecursionControl[ForeignKey.ParentTable] := RecursionControl[ForeignKey.ParentTable] - 1;
    end;
  end;
end;

function TQueryBuilderFrom.MakeJoinSQL(Join: TQueryBuilderJoin): String;
begin
  Result := EmptyStr;

  for var Link in Join.Link do
  begin
    Result := Result + Format(' left join %s %s on %s.%s=%s.%s', [Link.Value.Table.DatabaseName, Link.Value.Alias, Join.Alias, Link.Key.DatabaseName, Link.Value.Alias, Link.Value.Table.PrimaryKey[0].DatabaseName])
      + MakeJoinSQL(Link.Value);
  end;
end;

{ TQueryBuilderSelect }

function TQueryBuilderSelect.All: TQueryBuilderFrom;
begin
  Result := TQueryBuilderFrom.Create(FBuilder, FRecursivityLevel);

  FBuilder.FFieldList := TQueryBuilderAllFields.Create(Result);
  FFrom := Result;
end;

constructor TQueryBuilderSelect.Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FConnection := Connection;
end;

function TQueryBuilderSelect.GetFields: String;
begin
  var FieldList := FBuilder.FFieldList.GetFields;
  Result := EmptyStr;

  for var A := Low(FieldList) to High(FieldList) do
  begin
    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + Format('%s.%s F%d', ['T1', FieldList[A].DatabaseName, Succ(A)]);
  end;
end;

function TQueryBuilderSelect.GetSQL: String;
begin
  Result := 'select ';

  if Assigned(FFrom) then
    Result := Result + GetFields + FFrom.GetSQL;
end;

function TQueryBuilderSelect.RecursivityLevel(const Level: Word): TQueryBuilderSelect;
begin
  FRecursivityLevel := Level;
  Result := Self;
end;

{ TQueryBuilderWhere<T> }

constructor TQueryBuilderWhere<T>.Create(Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
end;

function TQueryBuilderWhere<T>.GetSQL: String;
begin
  Result := EmptyStr;

  if not FFilter.IsEmpty then
    Result := ' where ' + FFilter;
end;

function TQueryBuilderWhere<T>.Open: IQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FBuilder.Connection.OpenCursor(FBuilder.Build), FBuilder);
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
begin
  FFilter := Condition.Condition;
  Result := Self;
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := Loader.LoadAll<T>(FCursor, FBuilder.FFieldList.GetFields);
end;

constructor TQueryBuilderOpen<T>.Create(Cursor: IDatabaseCursor; Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FCursor := Cursor;
end;

destructor TQueryBuilderOpen<T>.Destroy;
begin
  FLoader.Free;

  inherited;
end;

function TQueryBuilderOpen<T>.GetLoader: TClassLoader;
begin
  if not Assigned(FLoader) then
    FLoader := TClassLoader.Create;

  Result := FLoader;
end;

function TQueryBuilderOpen<T>.One: T;
begin
  Result := Loader.Load<T>(FCursor, FBuilder.FFieldList.GetFields);
end;

{ TQueryBuilderAllFields }

constructor TQueryBuilderAllFields.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;
end;

function TQueryBuilderAllFields.GetAllFields(Join: TQueryBuilderJoin): TArray<TField>;
begin
  Result := nil;

  for var Field in Join.Table.Fields do
    if not Field.TypeInfo.PropertyType.IsInstance then
      Result := Result + [Field];

  for var Link in Join.Link do
    Result := Result + GetAllFields(Link.Value);
end;

function TQueryBuilderAllFields.GetFields: TArray<TField>;
begin
  Result := GetAllFields(FFrom.FJoin);
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

{ TQueryBuilderJoin }

constructor TQueryBuilderJoin.Create(Table: TTable);
begin
  inherited Create;

  FLink := TObjectDictionary<TField, TQueryBuilderJoin>.Create([doOwnsValues]);
  FTable := Table;
end;

destructor TQueryBuilderJoin.Destroy;
begin
  FLink.Free;

  inherited;
end;

end.

