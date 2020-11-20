unit Delphi.ORM.Query.Builder.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Query.Builder, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes;

type
  [TestFixture]
  TDelphiORMQueryBuilderTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure IfNoCommandCalledTheSQLMustReturnEmpty;
    [Test]
    procedure WhenCallSelectCommandTheSQLMustReturnTheWordSelect;
    [Test]
    procedure IfNoCommandIsCalledCantRaiseAnExceptionOfAccessViolation;
    [Test]
    procedure WhenSelectAllFieldsFromAClassMustPutAllThenInTheResultingSQL;
    [Test]
    procedure IfTheAllFieldNoCalledCantRaiseAnExceptionOfAccessViolation;
    [Test]
    procedure OnlyPublishedPropertiesCanAppearInSQL;
    [Test]
    procedure WhenCallOpenProcedureMustOpenTheDatabaseCursor;
    [Test]
    procedure WhenOpenOneMustFillTheClassWithTheValuesOfCursor;
    [Test]
    procedure WhenAFilterConditionMustBuildTheSQLAsExpected;
    [Test]
    procedure IfNotExistsAFilterInWhereMustReturnTheQueryWithoutWhereCommand;
    [Test]
    procedure WhenCallInsertProcedureMustBuildTheSQLWithAllFieldsAndValuesFromTheClassParamter;
    [Test]
    procedure OnlyPublishedPropertiesMustAppearInInsertSQL;
    [Test]
    procedure OnlyPublishedPropertiesMustAppearInUpdateSQL;
    [Test]
    procedure WhenCallUpdateMustBuildTheSQLWithAllPropertiesInTheObjectParameter;
    [Test]
    procedure WhenTheClassHaveThePrimaryKeyAttributeMustBuildTheWhereWithTheValuesOfFieldInTheKeyList;
    [Test]
    procedure TheKeyFieldCantBeUpdatedInTheUpdateProcedure;
    [Test]
    procedure WhenTheClassDontHaveThePrimaryKeyAttributeCantRaiseAException;
    [Test]
    procedure WhenCallTheDeleteProcedureMustBuildTheSQLWithTheValuesOfKeysOfClass;
  end;

  [TestFixture]
  TDelphiORMQueryBuilderConditionTest = class
  public
    [TestCase('Equal.String', 'qboEqual')]
    [TestCase('Not Equal.String', 'qboNotEqual')]
    [TestCase('Greater Than.String', 'qboGreaterThan')]
    [TestCase('Greater Than Or Equal.String', 'qboGreaterThanOrEqual')]
    [TestCase('Less Than.String', 'qboLessThan')]
    [TestCase('Less Than Or Equal.String', 'qboLessThanOrEqual')]
    procedure WhenCompareTheFieldWithAValueMustBuildTheConditionStringAsExpected(Operation: TQueryBuilderOperator);
    [TestCase('Equal.Integer', 'qboEqual')]
    [TestCase('Not Equal.Integer', 'qboNotEqual')]
    [TestCase('Greater Than.Integer', 'qboGreaterThan')]
    [TestCase('Greater Than Or Equal.Integer', 'qboGreaterThanOrEqual')]
    [TestCase('Less Than.Integer', 'qboLessThan')]
    [TestCase('Less Than Or Equal.Integer', 'qboLessThanOrEqual')]
    procedure WhenCompareTheFieldWithAValueMustBuildTheConditionIntegerAsExpected(Operation: TQueryBuilderOperator);
    [TestCase('Equal.Float', 'qboEqual')]
    [TestCase('Not Equal.Float', 'qboNotEqual')]
    [TestCase('Greater Than.Float', 'qboGreaterThan')]
    [TestCase('Greater Than Or Equal.Float', 'qboGreaterThanOrEqual')]
    [TestCase('Less Than.Float', 'qboLessThan')]
    [TestCase('Less Than Or Equal.Float', 'qboLessThanOrEqual')]
    procedure WhenCompareTheFieldWithAValueMustBuildTheConditionFloatAsExpected(Operation: TQueryBuilderOperator);
    [Test]
    procedure WhenUseTheAndOperatorMustBuildTheExpressionAsExpected;
    [Test]
    procedure WhenUseTheOrOperatorMustBuildTheExpressionAsExpected;
    [Test]
    procedure NullComparingMustBuildTheExpressionAsExpected;
    [Test]
    procedure NotNullComparingMustBuildTheExpressionAsExpected;
    [Test]
    procedure WhenTheComparisonIsWithAVariantVariableAndIsNotNullMustBuildWithTheValueOfVariable;
    [Test]
    procedure TheNotEqualComparisonWithAVariantVariableMustBuildWithTheValueOfVariable;
    [Test]
    procedure WhenComparingEqualityWithTValueMustBuildTheConditionAsExpected;
    [Test]
    procedure WhenComparingNotEqualWithTValueMustBuildTheConditionAsExpected;
  end;

  [Entity]
  TMyTestClass = class
  private
    FField: Integer;
    FName: String;
    FValue: Double;
    FPublicField: String;
  public
    property PublicField: String read FPublicField write FPublicField;
  published
    property Field: Integer read FField write FField;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TClassOnlyPublic = class
  private
    FName: String;
    FValue: Integer;
  public
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  [PrimaryKey('Id,Id2')]
  TClassWithPrimaryKey = class
  private
    FId: Integer;
    FId2: Integer;
    FValue: Integer;
  published
    property Id: Integer read FId write FId;
    property Id2: Integer read FId2 write FId2;
    property Value: Integer read FValue write FValue;
  end;

  TDatabase = class(TInterfacedObject, IDatabaseConnection)
  private
    FCursor: IDatabaseCursor;
    FSQL: String;

    function OpenCursor(SQL: String): IDatabaseCursor;

    procedure ExecuteDirect(SQL: String);
  public
    constructor Create(Cursor: IDatabaseCursor);

    property SQL: String read FSQL write FSQL;
  end;

implementation

uses System.SysUtils, System.Variants, Delphi.Mock, Delphi.ORM.Mapper;

{ TDelphiORMQueryBuilderTest }

procedure TDelphiORMQueryBuilderTest.IfNoCommandCalledTheSQLMustReturnEmpty;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.AreEqual(EmptyStr, Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNoCommandIsCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      Query.Build
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNotExistsAFilterInWhereMustReturnTheQueryWithoutWhereCommand;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Open;

  Assert.AreEqual('select Field F1,Name F2,Value F3 from MyTestClass', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfTheAllFieldNoCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.WillNotRaise(
    procedure
    begin
      Query.Build;
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.OnlyPublishedPropertiesMustAppearInInsertSQL;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TClassOnlyPublic.Create;
  MyClass.Name := 'My name';
  MyClass.Value := 222;

  Query.Insert(MyClass);

  Assert.AreEqual('insert into ClassOnlyPublic()values()', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.OnlyPublishedPropertiesMustAppearInUpdateSQL;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);
  var SQL := 'update ClassOnlyPublic set ';

  var MyClass := TClassOnlyPublic.Create;
  MyClass.Name := 'My name';
  MyClass.Value := 222;

  Query.Update(MyClass);

  Assert.AreEqual(SQL, Database.SQL.Substring(0, SQL.Length));

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.Setup;
begin
  TMapper.Default.LoadAll;
end;

procedure TDelphiORMQueryBuilderTest.TheKeyFieldCantBeUpdatedInTheUpdateProcedure;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);
  var SQL := 'update ClassWithPrimaryKey set Value=222';

  var MyClass := TClassWithPrimaryKey.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;
  MyClass.Value := 222;

  Query.Update(MyClass);

  Assert.AreEqual(SQL, Database.SQL.Substring(0, SQL.Length));

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.OnlyPublishedPropertiesCanAppearInSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select Field F1,Name F2,Value F3 from MyTestClass', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenAFilterConditionMustBuildTheSQLAsExpected;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Where(Field('MyField') = 1234).Open;

  Assert.AreEqual('select Field F1,Name F2,Value F3 from MyTestClass where MyField=1234', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallInsertProcedureMustBuildTheSQLWithAllFieldsAndValuesFromTheClassParamter;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TMyTestClass.Create;
  MyClass.Field := 123;
  MyClass.Name := 'My name';
  MyClass.Value := 222.333;

  Query.Insert(MyClass);

  Assert.AreEqual('insert into MyTestClass(Field,Name,Value)values(123,''My name'',222.333)', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallOpenProcedureMustOpenTheDatabaseCursor;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Open;

  Assert.AreEqual('select Field F1,Name F2,Value F3 from MyTestClass', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallSelectCommandTheSQLMustReturnTheWordSelect;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.AreEqual('select ', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallTheDeleteProcedureMustBuildTheSQLWithTheValuesOfKeysOfClass;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TClassWithPrimaryKey.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;

  Query.Delete(MyClass);

  Assert.AreEqual('delete from ClassWithPrimaryKey where Id=123 and Id2=456', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallUpdateMustBuildTheSQLWithAllPropertiesInTheObjectParameter;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TMyTestClass.Create;
  MyClass.Field := 123;
  MyClass.Name := 'My name';
  MyClass.Value := 222.333;

  Query.Update(MyClass);

  Assert.AreEqual('update MyTestClass set Field=123,Name=''My name'',Value=222.333', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenOpenOneMustFillTheClassWithTheValuesOfCursor;
begin
  var Cursor := TMock.CreateInterface<IDatabaseCursor>;
  var Database := TDatabase.Create(Cursor.Instance);
  var Query := TQueryBuilder.Create(Database);

  Cursor.Setup.WillReturn(123).When.GetFieldValue(It.IsEqualTo('F1'));

  Cursor.Setup.WillReturn('My name').When.GetFieldValue(It.IsEqualTo('F2'));

  Cursor.Setup.WillReturn(123.456).When.GetFieldValue(It.IsEqualTo('F3'));

  Cursor.Setup.WillReturn(True).When.Next;

  var Result := Query.Select.All.From<TMyTestClass>.Open.One;

  Assert.AreEqual(123, Result.Field);

  Assert.AreEqual('My name', Result.Name);

  Assert.AreEqual(123.456, Result.Value);

  Query.Free;

  Result.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenSelectAllFieldsFromAClassMustPutAllThenInTheResultingSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select Field F1,Name F2,Value F3 from MyTestClass', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassDontHaveThePrimaryKeyAttributeCantRaiseAException;
begin
  var Database := TDatabase.Create(nil);
  var MyClass := TClassOnlyPublic.Create;
  var Query := TQueryBuilder.Create(Database);

  Assert.WillNotRaise(
    procedure
    begin
      Query.Update(MyClass);
    end, EAccessViolation);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassHaveThePrimaryKeyAttributeMustBuildTheWhereWithTheValuesOfFieldInTheKeyList;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TClassWithPrimaryKey.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;
  MyClass.Value := 222;

  Query.Update(MyClass);

  Assert.AreEqual('update ClassWithPrimaryKey set Value=222 where Id=123 and Id2=456', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

{ TDatabase }

constructor TDatabase.Create(Cursor: IDatabaseCursor);
begin
  inherited Create;

  FCursor := Cursor;
end;

procedure TDatabase.ExecuteDirect(SQL: String);
begin
  FSQL := SQL;
end;

function TDatabase.OpenCursor(SQL: String): IDatabaseCursor;
begin
  FSQL := SQL;
  Result := FCursor;
end;

{ TDelphiORMQueryBuilderConditionTest }

procedure TDelphiORMQueryBuilderConditionTest.NotNullComparingMustBuildTheExpressionAsExpected;
begin
  var Condition := Field('MyField') <> NULL;

  Assert.AreEqual('MyField is not null', Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.NullComparingMustBuildTheExpressionAsExpected;
begin
  var Condition := Field('MyField') = NULL;

  Assert.AreEqual('MyField is null', Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.TheNotEqualComparisonWithAVariantVariableMustBuildWithTheValueOfVariable;
begin
  var Condition := Field('MyField') <> Variant(123);

  Assert.AreEqual('MyField<>123', Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenCompareTheFieldWithAValueMustBuildTheConditionFloatAsExpected(Operation: TQueryBuilderOperator);
begin
  var Condition: TQueryBuilderCondition;

  case Operation of
    qboEqual: Condition := Field('MyField') = 123.456;
    qboNotEqual: Condition := Field('MyField') <> 123.456;
    qboGreaterThan: Condition := Field('MyField') > 123.456;
    qboGreaterThanOrEqual: Condition := Field('MyField') >= 123.456;
    qboLessThan: Condition := Field('MyField') < 123.456;
    qboLessThanOrEqual: Condition := Field('MyField') <= 123.456;
  end;

  Assert.AreEqual(Format('MyField%s123.456', [OPERATOR_CHAR[Operation]]), Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenCompareTheFieldWithAValueMustBuildTheConditionIntegerAsExpected(Operation: TQueryBuilderOperator);
begin
  var Condition: TQueryBuilderCondition;

  case Operation of
    qboEqual: Condition := Field('MyField') = 123;
    qboNotEqual: Condition := Field('MyField') <> 123;
    qboGreaterThan: Condition := Field('MyField') > 123;
    qboGreaterThanOrEqual: Condition := Field('MyField') >= 123;
    qboLessThan: Condition := Field('MyField') < 123;
    qboLessThanOrEqual: Condition := Field('MyField') <= 123;
  end;

  Assert.AreEqual(Format('MyField%s123', [OPERATOR_CHAR[Operation]]), Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenCompareTheFieldWithAValueMustBuildTheConditionStringAsExpected(Operation: TQueryBuilderOperator);
begin
  var Condition: TQueryBuilderCondition;

  case Operation of
    qboEqual: Condition := Field('MyField') = 'abc';
    qboNotEqual: Condition := Field('MyField') <> 'abc';
    qboGreaterThan: Condition := Field('MyField') > 'abc';
    qboGreaterThanOrEqual: Condition := Field('MyField') >= 'abc';
    qboLessThan: Condition := Field('MyField') < 'abc';
    qboLessThanOrEqual: Condition := Field('MyField') <= 'abc';
  end;

  Assert.AreEqual(Format('MyField%s''abc''', [OPERATOR_CHAR[Operation]]), Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenComparingEqualityWithTValueMustBuildTheConditionAsExpected;
begin
  var Condition := Field('MyField') = TValue.From(123.456);

  Assert.AreEqual('MyField=' + TValue.From(123.456).ToString, Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenComparingNotEqualWithTValueMustBuildTheConditionAsExpected;
begin
  var Condition := Field('MyField') <> TValue.From(123.456);

  Assert.AreEqual('MyField<>' + TValue.From(123.456).ToString, Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenTheComparisonIsWithAVariantVariableAndIsNotNullMustBuildWithTheValueOfVariable;
begin
  var Condition := Field('MyField') = Variant(123);

  Assert.AreEqual('MyField=123', Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenUseTheAndOperatorMustBuildTheExpressionAsExpected;
begin
  var Condition := (Field('abc') = 123) and (Field('abc') = 123);

  Assert.AreEqual('abc=123 and abc=123', Condition.Condition);
end;

procedure TDelphiORMQueryBuilderConditionTest.WhenUseTheOrOperatorMustBuildTheExpressionAsExpected;
begin
  var Condition := (Field('abc') = 123) or (Field('abc') = 123);

  Assert.AreEqual('(abc=123 or abc=123)', Condition.Condition);
end;

end.

