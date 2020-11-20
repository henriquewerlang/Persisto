unit Delphi.ORM.Query.Builder;

interface

uses System.Rtti, System.Classes, Delphi.ORM.Database.Connection, Delphi.ORM.Classes.Loader;

type
  TQueryBuilder = class;
  TQueryBuilderFrom = class;
  TQueryBuilderSelect = class;
  TQueryBuilderWhere<T: class, constructor> = class;

  TFilterOperation = (Equal);

  IQueryBuilderCommand = interface
    function GetSQL: String;
  end;

  IQueryBuilderCommandManipulation = interface(IQueryBuilderCommand)
    function GetProperties: IFieldXPropertyMapping;
  end;

  IQueryBuilderOpen<T: class, constructor> = interface
    function All: TArray<T>;
    function One: T;
  end;

  TQueryBuilder = class
  private
    FConnection: IDatabaseConnection;
    FCommand: IQueryBuilderCommandManipulation;

    function GetValueString(const Value: TValue): String;
  public
    constructor Create(Connection: IDatabaseConnection);

    function Build: String;
    function Select: TQueryBuilderSelect;

    procedure Delete<T: class, constructor>(const AObject: T);
    procedure Insert<T: class>(const AObject: T);
    procedure Update<T: class, constructor>(const AObject: T);
  end;

  TQueryBuilderFrom = class
  private
    FBuilder: TQueryBuilder;
    FConnection: IDatabaseConnection;
    FFromType: TRttiStructuredType;
    FWhere: IQueryBuilderCommand;

    function GetSQL: String;
  public
    constructor Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);

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

  TQueryBuilderAllFields = class(TInterfacedObject, IFieldXPropertyMapping)
  private
    FFrom: TQueryBuilderFrom;

    function GetProperties: TArray<TFieldMapPair>;
  public
    constructor Create(From: TQueryBuilderFrom);
  end;

  TQueryBuilderSelect = class(TInterfacedObject, IQueryBuilderCommandManipulation)
  private
    FConnection: IDatabaseConnection;
    FBuilder: TQueryBuilder;
    FFrom: TQueryBuilderFrom;
    FFields: IFieldXPropertyMapping;

    function GetAllFields: String;
    function GetProperties: IFieldXPropertyMapping;
    function GetSQL: String;
  public
    constructor Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);

    destructor Destroy; override;

    function All: TQueryBuilderFrom;
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
    class operator GreaterThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator GreaterThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator LessThan(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator LessThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator LessThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: Extended): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: Variant): TQueryBuilderCondition;
    class operator NotEqual(const Condition: TQueryBuilderCondition; const Value: TValue): TQueryBuilderCondition;
  end;

  TQueryBuilderWhere<T: class, constructor> = class(TInterfacedObject, IQueryBuilderCommand)
  private
    FConnection: IDatabaseConnection;
    FBuilder: TQueryBuilder;
    FFilter: String;

    function GetSQL: String;
  public
    constructor Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);

    function Open: IQueryBuilderOpen<T>;
    function Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
  end;

function Field(const Name: String): TQueryBuilderCondition;

const
  OPERATOR_CHAR: array[TQueryBuilderOperator] of String = ('=', '<>', '>', '>=', '<', '<=', ' and ', ' or ');

implementation

uses System.SysUtils, System.TypInfo, System.Variants, Delphi.ORM.Attributes, Delphi.ORM.Mapper;

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
  var Where := TQueryBuilderWhere<T>.Create(nil, nil);

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
  var Where := TQueryBuilderWhere<T>.Create(nil, nil);

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

constructor TQueryBuilderFrom.Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FConnection := Connection;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  var Context := TRttiContext.Create;
  FFromType := Context.GetType(TypeInfo(T)) as TRttiStructuredType;
  Result := TQueryBuilderWhere<T>.Create(FConnection, FBuilder);

  FWhere := Result;
end;

function TQueryBuilderFrom.GetSQL: String;
begin
  Result := Format(' from %s', [FFromType.Name.Substring(1)]);

  if Assigned(FWhere) then
    Result := Result + FWhere.GetSQL;
end;

{ TQueryBuilderSelect }

function TQueryBuilderSelect.All: TQueryBuilderFrom;
begin
  FFrom := TQueryBuilderFrom.Create(FConnection, FBuilder);
  Result := FFrom;

  FFields := TQueryBuilderAllFields.Create(FFrom);
end;

constructor TQueryBuilderSelect.Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FConnection := Connection;
end;

destructor TQueryBuilderSelect.Destroy;
begin
  FFrom.Free;

  inherited;
end;

function TQueryBuilderSelect.GetAllFields: String;
begin
  Result := EmptyStr;

  for var Pair in FFields.GetProperties do
  begin
    if not Result.IsEmpty then
      Result := Result + ',';

    Result := Result + Format('%s %s', [Pair.Key.Name, Pair.Value]);
  end;
end;

function TQueryBuilderSelect.GetProperties: IFieldXPropertyMapping;
begin
  Result := FFields;
end;

function TQueryBuilderSelect.GetSQL: String;
begin
  Result := 'select ';

  if Assigned(FFrom) then
    Result := Result + GetAllFields + FFrom.GetSQL;
end;

{ TQueryBuilderWhere<T> }

constructor TQueryBuilderWhere<T>.Create(Connection: IDatabaseConnection; Builder: TQueryBuilder);
begin
  inherited Create;

  FBuilder := Builder;
  FConnection := Connection;
end;

function TQueryBuilderWhere<T>.GetSQL: String;
begin
  Result := EmptyStr;

  if not FFilter.IsEmpty then
    Result := ' where ' + FFilter;
end;

function TQueryBuilderWhere<T>.Open: IQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FConnection.OpenCursor(FBuilder.Build), FBuilder);
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderCondition): TQueryBuilderWhere<T>;
begin
  FFilter := Condition.Condition;
  Result := Self;
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := Loader.LoadAll<T>(FCursor, FBuilder.FCommand.GetProperties);
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
  Result := Loader.Load<T>(FCursor, FBuilder.FCommand.GetProperties);
end;

{ TQueryBuilderAllFields }

constructor TQueryBuilderAllFields.Create(From: TQueryBuilderFrom);
begin
  inherited Create;

  FFrom := From;
end;

function TQueryBuilderAllFields.GetProperties: TArray<TFieldMapPair>;
var
  A: Cardinal;

begin
  A := 1;
  Result := nil;

  for var &Property in FFrom.FFromType.GetProperties do
    if &Property.Visibility = mvPublished then
    begin
      Result := Result + [TFieldMapPair.Create(&Property, Format('F%d', [A]))];

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

class operator TQueryBuilderCondition.GreaterThanOrEqual(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboGreaterThanOrEqual, QuotedStr(Value));
end;

class operator TQueryBuilderCondition.LessThan(const Condition: TQueryBuilderCondition; const Value: String): TQueryBuilderCondition;
begin
  Result.Condition := GenerateCondition(Condition, qboLessThan, QuotedStr(Value));
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

end.

