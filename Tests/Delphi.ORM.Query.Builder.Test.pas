unit Delphi.ORM.Query.Builder.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Query.Builder, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes, Delphi.ORM.Query.Builder.Test.Entity;

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
    procedure WhenCallInsertProcedureMustBuildTheSQLWithAllFieldsAndValuesFromTheClassParameter;
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
    [Test]
    procedure WhenTheClassDontHaveAnyPrimaryKeyTheDeleteMustBuildTheSQLWithoutWhereCondition;
    [Test]
    procedure TheClassBeingSelectedMustHaveTheAliasDefined;
    [Test]
    procedure TheFieldsHaveToBeGeneratedWithTheAliasOfTheRespectiveTables;
    [Test]
    procedure WhenClassHasOtherClassesLinkedToItYouHaveToGenerateTheJoinBetweenThem;
    [Test]
    procedure AllTheDirectForeignKeyMustBeGeneratedInTheResultingSQL;
    [Test]
    procedure TheForeignKeyMustBeLoadedRecursive;
    [Test]
    procedure WhenTheClassHaveForeignKeysThatsLoadsRecursivelyCantRaiseAnError;
    [Test]
    procedure MustGenerateTheSQLFollowingTheHierarchyAsSpected;
    [Test]
    procedure WhenConfiguredTheRecursivityLevelTheJoinsMustFollowTheConfiguration;
    [Test]
    procedure WhenTheClassRecursivelyItselfMoreThenOneTimeMustBuildTheSQLAsEspected;
    [Test]
    procedure WhenTheClassHaveManyValueAssociationMustLoadTheJoinBetweenTheParentAndChildTable;
    [Test]
    procedure TheManyValueAssociationMustAvoidRecursivilyLoadTheParentClassWhenLoadingTheChildClass;
    [Test]
    procedure WhenIsLoadedAJoinMustLoadTheFieldThatIsTheLinkBetweenTheClasses;
    [Test]
    procedure TheManyValueAssociationMustLoadTheLinkingFieldBetweenTheClasses;
  end;

  [TestFixture]
  TQueryBuilderSelectTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenIsNotDefinedTheRecursivityLevelMustBeOneTheDefaultValue;
    [Test]
    procedure WhenTheClassHaveForeignKeyMustBuildTheSQLWithTheAliasOfTheJoinMapped;
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
    [TestCase('Equal.Condition', 'qboEqual')]
    [TestCase('Not Equal.Condition', 'qboNotEqual')]
    [TestCase('Greater Than.Condition', 'qboGreaterThan')]
    [TestCase('Greater Than Or Equal.Condition', 'qboGreaterThanOrEqual')]
    [TestCase('Less Than.Condition', 'qboLessThan')]
    [TestCase('Less Than Or Equal.Condition', 'qboLessThanOrEqual')]
    procedure WhenCompareTheFieldWithAnotherConditionMustBuildTheConditionAsExpected(Operation: TQueryBuilderOperator);
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

  [TestFixture]
  TQueryBuilderAllFieldsTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure InASingleClassMustLoadAllFieldsFromThatClass;
    [Test]
    procedure WhenTheClassHaveForeignKeyMustLoadAllFieldsOfAllClassesInvolved;
    [Test]
    procedure FieldsOfAnObjectCantBeLoadedInTheListOfFields;
    [Test]
    procedure TheFieldsMustBeLoadedRecursivelyInAllForeignKeys;
    [Test]
    procedure WhenTheClassIsRecursiveItselfCantRaiseAnErrorInTheExecution;
    [Test]
    procedure TheRecursivelyMustBeRespectedAndLoadAllFieldFromTheClasses;
    [Test]
    procedure WhenThePropertyIsAnArrayCantLoadTheFieldInTheList;
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

procedure TDelphiORMQueryBuilderTest.AllTheDirectForeignKeyMustBeGeneratedInTheResultingSQL;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TClassWithTwoForeignKey>;

  Assert.AreEqual(' from ClassWithTwoForeignKey T1 left join ClassWithPrimaryKey T2 on T1.IdAnotherClass=T2.Id left join ClassWithPrimaryKey T3 on T1.IdAnotherClass2=T3.Id', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNoCommandCalledTheSQLMustReturnEmpty;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.AreEqual(EmptyStr, Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNoCommandIsCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      Query.GetSQL
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNotExistsAFilterInWhereMustReturnTheQueryWithoutWhereCommand;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Open;

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfTheAllFieldNoCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.WillNotRaise(
    procedure
    begin
      Query.GetSQL;
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.MustGenerateTheSQLFollowingTheHierarchyAsSpected;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TClassHierarchy1>;

  Assert.AreEqual(
        ' from ClassHierarchy1 T1 ' +
    'left join ClassHierarchy2 T2 ' +
           'on T1.IdClass1=T2.Id ' +
    'left join ClassHierarchy1 T3 ' +
           'on T2.IdClass3=T3.Id ' +
    'left join ClassHierarchy3 T4 ' +
           'on T3.IdClass2=T4.Id ' +
    'left join ClassHierarchy1 T5 ' +
           'on T2.IdClass4=T5.Id ' +
    'left join ClassHierarchy3 T6 ' +
           'on T5.IdClass2=T6.Id ' +
    'left join ClassHierarchy3 T7 ' +
           'on T1.IdClass2=T7.Id', Query.GetSQL);

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
  TMock.CreateInterface<IDatabaseCursor>;

  TMapper.Default.LoadAll;
end;

procedure TDelphiORMQueryBuilderTest.TheClassBeingSelectedMustHaveTheAliasDefined;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TMyTestClass>;

  Assert.AreEqual(' from MyTestClass T1', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.TheFieldsHaveToBeGeneratedWithTheAliasOfTheRespectiveTables;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.TheForeignKeyMustBeLoadedRecursive;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TClassWithForeignKeyRecursive>;

  Assert.AreEqual(' from ClassWithForeignKeyRecursive T1 left join ClassWithForeignKey T2 on T1.IdAnotherClass=T2.Id left join ClassWithPrimaryKey T3 on T2.IdAnotherClass=T3.Id', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.TheKeyFieldCantBeUpdatedInTheUpdateProcedure;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);
  var SQL := 'update ClassWithPrimaryKeyAttribute set Value=222';

  var MyClass := TClassWithPrimaryKeyAttribute.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;
  MyClass.Value := 222;

  Query.Update(MyClass);

  Assert.AreEqual(SQL, Database.SQL.Substring(0, SQL.Length));

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.TheManyValueAssociationMustAvoidRecursivilyLoadTheParentClassWhenLoadingTheChildClass;
begin
  var From := TQueryBuilderFrom.Create(nil, 5);

  From.From<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual(
        ' from MyEntityWithManyValueAssociation T1 ' +
    'left join MyEntityWithManyValueAssociationChild T2 ' +
           'on T1.Id=T2.IdManyValueAssociation',
    From.GetSQL);

  From.Free;
end;

procedure TDelphiORMQueryBuilderTest.TheManyValueAssociationMustLoadTheLinkingFieldBetweenTheClasses;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  From.From<TMyEntityWithManyValueAssociation>;

  Assert.IsNotNull(From.Join.Links[0].Field);

  From.Free;
end;

procedure TDelphiORMQueryBuilderTest.OnlyPublishedPropertiesCanAppearInSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenAFilterConditionMustBuildTheSQLAsExpected;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Where(Field('MyField') = 1234).Open;

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1 where MyField=1234', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallInsertProcedureMustBuildTheSQLWithAllFieldsAndValuesFromTheClassParameter;
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

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1', Database.SQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallSelectCommandTheSQLMustReturnTheWordSelect;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.AreEqual('select ', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallTheDeleteProcedureMustBuildTheSQLWithTheValuesOfKeysOfClass;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TClassWithPrimaryKeyAttribute.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;

  Query.Delete(MyClass);

  Assert.AreEqual('delete from ClassWithPrimaryKeyAttribute where Id=123 and Id2=456', Database.SQL);

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

procedure TDelphiORMQueryBuilderTest.WhenClassHasOtherClassesLinkedToItYouHaveToGenerateTheJoinBetweenThem;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TClassWithForeignKey>;

  Assert.AreEqual(' from ClassWithForeignKey T1 left join ClassWithPrimaryKey T2 on T1.IdAnotherClass=T2.Id', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenConfiguredTheRecursivityLevelTheJoinsMustFollowTheConfiguration;
begin
  var Query := TQueryBuilder.Create(nil);

  var From := Query.Select.RecursivityLevel(3).All;

  From.From<TClassRecursiveFirst>;

  Assert.AreEqual(
            ' from ClassRecursiveFirst T1 ' +
        'left join ClassRecursiveThrid T2 ' +
               'on T1.IdRecursive=T2.Id ' +
        'left join ClassRecursiveSecond T3 ' +
               'on T2.IdRecursive=T3.Id ' +
        'left join ClassRecursiveFirst T4 ' +
               'on T3.IdRecursive=T4.Id ' +
        'left join ClassRecursiveThrid T5 ' +
               'on T4.IdRecursive=T5.Id ' +
        'left join ClassRecursiveSecond T6 ' +
               'on T5.IdRecursive=T6.Id ' +
        'left join ClassRecursiveFirst T7 ' +
               'on T6.IdRecursive=T7.Id ' +
        'left join ClassRecursiveThrid T8 ' +
               'on T7.IdRecursive=T8.Id ' +
        'left join ClassRecursiveSecond T9 ' +
               'on T8.IdRecursive=T9.Id ' +
        'left join ClassRecursiveFirst T10 ' +
               'on T9.IdRecursive=T10.Id',
    From.GetSQL);

  Query.GetSQL;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenIsLoadedAJoinMustLoadTheFieldThatIsTheLinkBetweenTheClasses;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Query.From<TClassWithForeignKey>;

  Assert.IsNotNull(Query.Join.Links[0].Field);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenOpenOneMustFillTheClassWithTheValuesOfCursor;
begin
  var Cursor := TMock.CreateInterface<IDatabaseCursor>;
  var Database := TDatabase.Create(Cursor.Instance);
  var Query := TQueryBuilder.Create(Database);

  Cursor.Setup.WillReturn(123).When.GetFieldValue(It.IsEqualTo(0));

  Cursor.Setup.WillReturn('My name').When.GetFieldValue(It.IsEqualTo(1));

  Cursor.Setup.WillReturn(123.456).When.GetFieldValue(It.IsEqualTo(2));

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

  Assert.AreEqual('select T1.Field F1,T1.Name F2,T1.Value F3 from MyTestClass T1', Query.GetSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassDontHaveAnyPrimaryKeyTheDeleteMustBuildTheSQLWithoutWhereCondition;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TMyTestClass.Create;

  Query.Delete(MyClass);

  Assert.AreEqual('delete from MyTestClass', Database.SQL);

  MyClass.Free;

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

procedure TDelphiORMQueryBuilderTest.WhenTheClassHaveForeignKeysThatsLoadsRecursivelyCantRaiseAnError;
begin
  var Query := TQueryBuilderFrom.Create(nil, 1);

  Assert.WillNotRaise(
    procedure
    begin
      Query.From<TClassRecursiveFirst>;

      Query.GetSQL;
    end);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassHaveManyValueAssociationMustLoadTheJoinBetweenTheParentAndChildTable;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  From.From<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual(
        ' from MyEntityWithManyValueAssociation T1 ' +
    'left join MyEntityWithManyValueAssociationChild T2 ' +
           'on T1.Id=T2.IdManyValueAssociation',
    From.GetSQL);

  From.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassHaveThePrimaryKeyAttributeMustBuildTheWhereWithTheValuesOfFieldInTheKeyList;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  var MyClass := TClassWithPrimaryKeyAttribute.Create;
  MyClass.Id := 123;
  MyClass.Id2 := 456;
  MyClass.Value := 222;

  Query.Update(MyClass);

  Assert.AreEqual('update ClassWithPrimaryKeyAttribute set Value=222 where Id=123 and Id2=456', Database.SQL);

  MyClass.Free;

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenTheClassRecursivelyItselfMoreThenOneTimeMustBuildTheSQLAsEspected;
begin
  var From := TQueryBuilderFrom.Create(nil, 2);

  From.From<TClassRecursiveItself>;

  Assert.AreEqual(
        ' from ClassRecursiveItself T1 ' +
    'left join ClassRecursiveItself T2 ' +
           'on T1.IdRecursive1=T2.Id ' +
    'left join ClassRecursiveItself T3 ' +
           'on T2.IdRecursive1=T3.Id ' +
    'left join ClassRecursiveItself T4 ' +
           'on T2.IdRecursive2=T4.Id ' +
    'left join ClassRecursiveItself T5 ' +
           'on T1.IdRecursive2=T5.Id ' +
    'left join ClassRecursiveItself T6 ' +
           'on T5.IdRecursive1=T6.Id ' +
    'left join ClassRecursiveItself T7 ' +
           'on T5.IdRecursive2=T7.Id',
    From.GetSQL);

  From.Free;
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

procedure TDelphiORMQueryBuilderConditionTest.WhenCompareTheFieldWithAnotherConditionMustBuildTheConditionAsExpected(Operation: TQueryBuilderOperator);
begin
  var Condition: TQueryBuilderCondition;

  case Operation of
    qboEqual: Condition := Field('MyField') = Field('AnotherField');
    qboNotEqual: Condition := Field('MyField') <> Field('AnotherField');
    qboGreaterThan: Condition := Field('MyField') > Field('AnotherField');
    qboGreaterThanOrEqual: Condition := Field('MyField') >= Field('AnotherField');
    qboLessThan: Condition := Field('MyField') < Field('AnotherField');
    qboLessThanOrEqual: Condition := Field('MyField') <= Field('AnotherField');
  end;

  Assert.AreEqual(Format('MyField%sAnotherField', [OPERATOR_CHAR[Operation]]), Condition.Condition);
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

{ TQueryBuilderAllFieldsTest }

procedure TQueryBuilderAllFieldsTest.FieldsOfAnObjectCantBeLoadedInTheListOfFields;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TClassWithTwoForeignKey>;

  for var Field in FieldList.GetFields do
    Assert.IsFalse(Field.Field.TypeInfo.PropertyType.InheritsFrom(TRttiStructuredType));

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.InASingleClassMustLoadAllFieldsFromThatClass;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TMyTestClass>;

  Assert.AreEqual<Integer>(3, Length(FieldList.GetFields));

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.Setup;
begin
  TMapper.Default.LoadAll;
end;

procedure TQueryBuilderAllFieldsTest.TheFieldsMustBeLoadedRecursivelyInAllForeignKeys;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TClassWithForeignKeyRecursive>;

  Assert.AreEqual<Integer>(4, Length(FieldList.GetFields));

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.TheRecursivelyMustBeRespectedAndLoadAllFieldFromTheClasses;
begin
  var From := TQueryBuilderFrom.Create(nil, 3);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TClassRecursiveFirst>;

  Assert.AreEqual<Integer>(10, Length(FieldList.GetFields));

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.WhenTheClassHaveForeignKeyMustLoadAllFieldsOfAllClassesInvolved;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TClassWithTwoForeignKey>;

  Assert.AreEqual<Integer>(5, Length(FieldList.GetFields));

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.WhenTheClassIsRecursiveItselfCantRaiseAnErrorInTheExecution;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TClassRecursiveFirst>;

  Assert.WillNotRaise(
    procedure
    begin
      FieldList.GetFields;
    end);

  From.Free;

  FieldList.Free;
end;

procedure TQueryBuilderAllFieldsTest.WhenThePropertyIsAnArrayCantLoadTheFieldInTheList;
begin
  var From := TQueryBuilderFrom.Create(nil, 1);

  var FieldList := TQueryBuilderAllFields.Create(From);

  From.From<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(FieldList.GetFields));

  From.Free;

  FieldList.Free;
end;

{ TQueryBuilderSelectTest }

procedure TQueryBuilderSelectTest.Setup;
begin
  TMapper.Default.LoadAll;
end;

procedure TQueryBuilderSelectTest.WhenIsNotDefinedTheRecursivityLevelMustBeOneTheDefaultValue;
begin
  var Select := TQueryBuilderSelect.Create(nil);

  Assert.AreEqual(1, Select.RecursivityLevelValue);

  Select.Free;
end;

procedure TQueryBuilderSelectTest.WhenTheClassHaveForeignKeyMustBuildTheSQLWithTheAliasOfTheJoinMapped;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TClassWithForeignKey>.Open;

  Assert.AreEqual('select T1.Id F1,T2.Id F2,T2.Value F3 from ClassWithForeignKey T1 left join ClassWithPrimaryKey T2 on T1.IdAnotherClass=T2.Id', Database.SQL);

  Query.Free;
end;

end.

