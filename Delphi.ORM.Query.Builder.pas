unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Classes.Loader, Delphi.ORM.Mapper;

type
  TQueryBuilder = class;
  TQueryBuilderFrom = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class, constructor> = class;

  TFilterOperation = (Equal);

  IQueryBuilderCommand = interface
    function GetSQL: String;
  end;

  IQueryBuilderFieldList = interface
    function GetFields: TArray<TFieldAlias>;
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
    FBuilder: TQueryBuilder;
    FTable: TTable;
    FWhere: IQueryBuilderCommand;
    FRecursivityLevel: Word;

    function BuildJoin: String;
    function GetSQL: String;
    function MakeJoin(ParentTable: TTable; var TableIndex: Integer; RecursionControl: TDictionary<TField, Word>): String;
  public
    constructor Create(Builder: TQueryBuilder; RecursivityLevel: Word);

    function From<T: class, constructor>: TQueryBuilderWhere<T>;
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

    function GetFields: TArray<TFieldAlias>;
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

function MakeTableAlias(TableIndex: Integer): String;
begin
  Result := Format('T%d', [TableIndex]);
end;

function TableDeclaration(Table: TTable; TableIndex: Integer): String;
begin
  Result := Format('%s %s', [Table.DatabaseName, MakeTableAlias(TableIndex)]);
end;

function FieldDeclaration(Field: TField; TableIndex: Integer): String;
begin
  Result := Format('T%d.%s', [TableIndex, Field.DatabaseName]);
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

function TQueryBuilderFrom.BuildJoin: String;
begin
  var RecursionControl := TDictionary<TField, Word>.Create;
  var TableIndex := 1;

  Result := TableDeclaration(FTable, TableIndex) + MakeJoin(FTable, TableIndex, RecursionControl);

  RecursionControl.Free;
end;

constructor TQueryBuilderFrom.Create(Builder: TQueryBuilder; RecursivityLevel: Word);
begin
  inherited Create;

  FBuilder := Builder;
  FRecursivityLevel := RecursivityLevel;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  FTable := TMapper.Default.FindTable(T);
  Result := TQueryBuilderWhere<T>.Create(FBuilder);

  FWhere := Result;
end;

function TQueryBuilderFrom.GetSQL: String;
begin
  Result := Format(' from %s', [BuildJoin]);

  if Assigned(FWhere) then
    Result := Result + FWhere.GetSQL;
end;

function TQueryBuilderFrom.MakeJoin(ParentTable: TTable; var TableIndex: Integer; RecursionControl: TDictionary<TField, Word>): String;
begin
  var ParentIndex := TableIndex;
  Result := EmptyStr;

  for var ForeignKey in ParentTable.ForeignKeys do
  begin
    var CurrentField := ForeignKey.Field;

    Inc(TableIndex);

    Result := Result + Format(' left join %s on %s', [TableDeclaration(ForeignKey.ParentTable, TableIndex),
      (Field(FieldDeclaration(CurrentField, ParentIndex)) = Field(FieldDeclaration(ForeignKey.ParentTable.PrimaryKey[0], TableIndex))).Condition]);

    if not RecursionControl.ContainsKey(CurrentField) then
      RecursionControl.Add(CurrentField, 0);

    if RecursionControl[CurrentField] < FRecursivityLevel then
    begin
      RecursionControl[CurrentField] := RecursionControl[CurrentField] + 1;

      Result := Result + MakeJoin(ForeignKey.ParentTable, TableIndex, RecursionControl);
    end;
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
  Result := EmptyStr;

  for var Field in FBuilder.FFieldList.GetFields do
  begin
    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + Format('%s.%s %s', ['T1', Field.Field.DatabaseName, Field.Alias]);
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

function TQueryBuilderAllFields.GetFields: TArray<TFieldAlias>;
var
  A: Cardinal;

begin
  A := 1;
  Result := nil;

  for var Field in FFrom.FTable.Fields do
  begin
    Result := Result + [TFieldAlias.Create(Field, Format('F%d', [A]))];

    Inc(A);
  end;
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

end.

