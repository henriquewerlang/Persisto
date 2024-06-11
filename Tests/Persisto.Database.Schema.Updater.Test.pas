unit Persisto.Database.Schema.Updater.Test;

interface

uses System.SysUtils, System.Generics.Collections, Data.DB, DUnitX.TestFramework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TDatabaseSchemaUpdaterTest = class
  private
    FManager: TManager;

    procedure LoadSchemaTables;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenCheckTheSchemaCantRaiseAnyError;
    [Test]
    procedure IfTheTableDontExistsInTheDatabaseMustCreateTheTable;
    [Test]
    procedure OnlyTheTableNoExistingTableMustCreatedInTheDatabase;
    [Test]
    procedure WhenCreateATableMustCreateAllFieldsOfTheTableToo;
    [Test]
    procedure TheTableWithManyValueAssociationFieldCantTryToCreateTheFieldMustBeIgnored;
    [Test]
    procedure WhenCreateAFieldMustLoadTheFieldInfoTypeFromTheManipulador;
    [Test]
    procedure WhenAFieldWithASizeMustCreateTheFieldWithTheSizeOfTheAttribute;
    [Test]
    procedure WhenAFieldWithAPrecisionMustCreateTheFieldWithThePrecisionOfTheAttribute;
    [TestCase('String', 'VarChar,tkString')]
    [TestCase('Integer', 'Integer,tkInteger')]
    [TestCase('Char', 'Char,tkChar')]
    [TestCase('Enumeration', 'Enumerator,tkEnumeration')]
    [TestCase('Float', 'Float,tkFloat')]
    [TestCase('Int64', 'Bigint,tkInt64')]
    procedure WhenCreateANormalFieldMustLoadTheFieldKindInfoAsExpected(const FieldName: String; const FieldKind: TTypeKind);
    [TestCase('Date', 'Date,stDate')]
    [TestCase('DateTime', 'DateTime,stDateTime')]
    [TestCase('Time', 'Time,stTime')]
    [TestCase('Text', 'Text,stText')]
    [TestCase('Unique Identifier', 'UniqueIdentifier,stUniqueIdentifier')]
    [TestCase('Boolean', 'Boolean,stBoolean')]
    procedure WhenCreateASpecialTypeFieldMustLoadTheSpecialTypeInfoAsExpected(const FieldName: String; const SpecialType: TDatabaseSpecialType);
    [Test]
    procedure WhenCreateARequiredFieldMustCreateTheFieldNotNull;
    [Test]
    procedure WhenCreateANotRequiredFieldMustCreateTheFieldNull;
    [Test]
    procedure WhenComparingNamesOfTablesMustBeCaseInsensitivityTheComparision;
    [Test]
    procedure WhenCreateATableMustCreateThePrimaryKeyToo;
    [Test]
    procedure IfTheTableExistsInTheDatabaseMustCreateTheFieldThatDontExists;
    [Test]
    procedure WhenAddAFieldToATableCantAddTheManyValueAssociationField;
    [Test]
    procedure IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
    [Test]
    procedure IfTheTableDoesntExistsMustCreateAllForeignKeysOfTheTable;
    [Test]
    procedure WhenTheTableIsntMappedMustDropTheTable;
    [Test]
    procedure WhenTheTableDoesntHaveAPrimaryMustCreateThePrimaryKeyFromTheTable;
    [Test]
    procedure WhenTheSequenceNotExistsInDatabaseMustBeCreated;
    [Test]
    procedure WhenTheSequenceNotExistsInTheMapperMustBeDroped;
    [Test]
    procedure IfTheForeignKeyExistsInDatabaseButNotExistsInTheMapperTheForeignKeyMustBeRemoved;
    [Test]
    procedure WhenTheIndexDontExistInDatabaseMustCreateIt;
    [Test]
    procedure WhenExistsMoreThenOneIndexMustCreateAll;
    [Test]
    procedure IfTheIndexDontExistsInTheMappingClassesMustBeDropped;
    [Test]
    procedure TheIndexCanBeCreatedOnlyIfNotExistsInDatabase;
    [Test]
    procedure WhenTheIndexExistsInDatabaseButTheFieldsAreDiffentMustRecreateTheIndex;
    [Test]
    procedure WhenTheFieldDontExistsInTheMappingMustBeDropedFromTheTable;
    [Test]
    procedure WhenTheFieldHasChangedMustCreateATempFieldForTransferTheFieldData;
    [Test]
    procedure AfterCreatingTheTempFieldMustTransferTheDataForTheTempField;
    [Test]
    procedure AfterTransferTheDataMustDropTheFieldFromDatabase;
    [Test]
    procedure AfterDropTheFieldMustCreateTheNewField;
    [Test]
    procedure AfterTransferTheDataMustDropTheTempField;
    [Test]
    procedure TheTempFieldMustHaveTheSamePropertiesOfTheOriginalFieldExceptByTheNameOfTheField;
    [Test]
    procedure IfTheFieldHaveASpecialTypeMustBeCopiedInTheTempField;
    [Test]
    procedure WhenTheFieldIsntChangedCantRecreateTheField;
    [Test]
    procedure WhenChangeTheTypeOfAFieldMustRecreateTheField;
    [Test]
    procedure WhenTheFieldIsAnEnumeratorAndTheDatabaseFieldTypeIsIntegerCantRecreateTheField;
    [Test]
    procedure WhenTheSizeOfTheFieldWasChangedMustRecreateTheField;
    [Test]
    procedure IfThePrecisionHasChangedMustRecreateTheField;
    [Test]
    procedure WhenTheSpecialTypeOfTheFieldHasChangedMustRecreateTheField;
    [Test]
    procedure WhenTheRequiredValueHasChangedMustRecreateTheField;
    [Test]
    procedure WhenTheDatabaseFieldDontHaveDefaultValueAndTheFieldDontHaveADefaultValueCantRecreateTheDefaultConstraint;
    [Test]
    procedure WhenTheDatabaseFieldHaveDefaultValueAndTheFieldHaveADefaultValueCantRecreateTheDefaultConstraint;
    [Test]
    procedure WhenTheDatabaseFieldHaveDefaultValueAndTheFieldDontHaveADefaultValueMustRecreateTheDefaultConstraint;
    [Test]
    procedure WhenTheDatabaseFieldDontHaveDefaultValueAndTheFieldHaveADefaultValueMustRecreateTheDefaultConstraint;
    [Test]
    procedure WhenTheDefaultConstraintNameHasChangedMustRecreateTheDefaultConstraint;
    [Test]
    procedure WhenTheDefaultValueHasChangedMustRecreateTheConstraint;
    [Test]
    procedure WhenDropAFieldMustDropTheIndexesBeforeDropTheField;
    [Test]
    procedure WhenDropAFieldMustDropTheForeignKeyWithThisFieldIsLinked;
    [Test]
    procedure WhenDropAFieldThatIsAReferenceOfAForeignKeyMustDropAllForeignKeyLinkedToThisField;
    [Test]
    procedure WhenDropAnIndexForFieldChangeMustCreateTheIndexAgain;
    [Test]
    procedure WhenDropAnForeignKeyForFieldChangeMustCreateTheForeignKeyAgain;
    [Test]
    procedure OnlyTheFieldThatTheSizeMatterMustBeRecreated;
    [Test]
    procedure OnlyTheFloatFieldMustCheckThePrecisionChange;
    [Test]
    procedure WhenRemoveTheDefualtConstraintOfAFieldCantTryToCreateTheDefualtConstraintAgain;
    [Test]
    procedure WhenTheFieldIsBooleanTypeCantBeRecreatedAllTheTime;
    [Test]
    procedure WhenTheFieldAddADefaultConstraintCantTryToDropTheConstraint;
    [Test]
    procedure WhenCreateATempFieldOfAForeignKeyMustLoadThePropertiesAsExpected;
    [Test]
    procedure IfTheFieldIsRecreatedTheDefaultConstraintDontNeedToBeCreated;
    [Test]
    procedure WhenThePrimaryKeyIndexAsChangedTheNameMustRecreateTheIndex;
    [Test]
    procedure WhenTheIndexWasDropedMustRemoveAllForeignKeysToTheTable;
    [Test]
    procedure WhenTheFieldNameDontHaveTheSameCaseNameMustRenameTheField;
    [Test]
    procedure AfterRenameTheFieldInDatabaseMustChangeTheInTheClass;
    [Test]
    procedure WhenDontFindThePrimaryKeyIndexMustCreateTheIndex;
    [Test]
    procedure BeforeDropATableMustDropAllForeignKeysThatReferencesThisTable;
    [Test]
    procedure WhenTheDefaultRecordsArentInTheTableMustBeAllInserted;
    [Test]
    procedure WhenTheRecordAlreadyInTheDatabaseMustUpdateTheRecord;
    [Test]
    procedure WhenAnIndexBecameUniqueMustRecreateTheIndex;
    [Test]
    procedure WhenCreateDatabaseTheDatabaseMustBeCreated;
    [Test]
    procedure WhenDropDatabaseTheDatabaseMustBeDropped;
  end;

  TDatabaseManiupulatorMock = class(TInterfacedObject, IDatabaseManipulator)
  private
    FFunctionDefaultValueCalled: Boolean;
    FFunctionFieldTypeCalled: Boolean;
    FFunctionSpecialTypeCalled: Boolean;
    FManipulador: IDatabaseManipulator;

    function CreateDatabase(const DatabaseName: String): String;
    function CreateSequence(const Sequence: TSequence): String;
    function DropDatabase(const DatabaseName: String): String;
    function DropSequence(const Sequence: TDatabaseSequence): String;
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
    function IsSQLite: Boolean;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
    function MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
  public
    constructor Create;
  end;

implementation

uses System.Rtti, Persisto.Test.Entity, Persisto.Test.Connection;

{ TDatabaseSchemaUpdaterTest }

procedure TDatabaseSchemaUpdaterTest.AfterCreatingTheTempFieldMustTransferTheDataForTheTempField;
begin
//  var Field := FMapper.GetTable(TMyClassWithAllFieldsType).Field['Integer'];
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      Assert.StartsWith('TempField', Params[2].AsType<TField>.DatabaseName);
//    end).When.UpdateField(It.IsEqualTo(Field), It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.UpdateField(It.IsEqualTo(Field), It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.AfterDropTheFieldMustCreateTheNewField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      Assert.AreEqual('Integer', Params[2].AsType<TField>.Name);
//    end).When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.AfterRenameTheFieldInDatabaseMustChangeTheInTheClass;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].Name := 'INTEGER';
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      Assert.AreEqual('Integer', FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].Name, False);
//    end).When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseSchemaUpdaterTest.AfterTransferTheDataMustDropTheFieldFromDatabase;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      Assert.AreEqual('Integer', Params[1].AsType<TDatabaseField>.Name);
//    end).When.DropField(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.DropField(It.IsAny<TDatabaseField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.AfterTransferTheDataMustDropTheTempField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      Assert.StartsWith('TempField', Params[1].AsType<TField>.DatabaseName);
//    end).When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.BeforeDropATableMustDropAllForeignKeysThatReferencesThisTable;
begin
//  var ExecutionCount := 0;
//
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyForeignKeyClass'].Name := 'AnotherName';
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure
//    begin
//      Inc(ExecutionCount);
//    end).When.DropForeignKey(It.IsAny<TDatabaseForeignKey>);
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure
//    begin
//      Assert.IsTrue(ExecutionCount > 0);
//    end).When.DropTable(It.IsAny<TDatabaseTable>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.AreEqual(2, ExecutionCount);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheFieldHaveASpecialTypeMustBeCopiedInTheTempField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['DateTime'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      var TempField := Params[1].AsType<TField>;
//
//      Assert.AreEqual(stDateTime, TempField.SpecialType);
//    end).When.CreateTempField(It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheFieldIsRecreatedTheDefaultConstraintDontNeedToBeCreated;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseField := FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['DefaultField'];
//      DatabaseField.FieldType := tkUnknown;
//
//      FreeAndNil(DatabaseField.DefaultConstraint);
//    end;
//
//  FMetadataManipulator.Expect.Never.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Never.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  Assert.WillNotRaise(
//    procedure
//    begin
//      FDatabaseMetadataUpdate.UpdateDatabase;
//    end);
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheForeignKeyExistsInDatabaseButNotExistsInTheMapperTheForeignKeyMustBeRemoved;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var ForeignKey := TDatabaseForeignKey.Create(FDatabaseSchema.Table['MyClass'], 'MyForeignKey', nil);
//
//      FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsEqualTo(ForeignKey));
//    end;
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
begin
  FManager.ExectDirect('create table InsertTestWithForeignKey (AnyField varchar(10))');

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var ForeignKeys := FManager.Select.All.From<TDatabaseForeignKey>.Where(Field('Table.Name') = 'InsertTestWithForeignKey').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(ForeignKeys));
end;

procedure TDatabaseSchemaUpdaterTest.IfTheIndexDontExistsInTheMappingClassesMustBeDropped;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseTable := FDatabaseSchema.Table['MyClass'];
//      var Index := TDatabaseIndex.Create(DatabaseTable, 'MyAnotherIndex');
//
//      FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));
//    end;
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.IfThePrecisionHasChangedMustRecreateTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Float'].Scale := 20;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheTableDoesntExistsMustCreateAllForeignKeysOfTheTable;
begin
  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var ForeignKeys := FManager.Select.All.From<TDatabaseForeignKey>.Where(Field('Table.Name') = 'InsertTestWithForeignKey').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(ForeignKeys));
end;

procedure TDatabaseSchemaUpdaterTest.IfTheTableDontExistsInTheDatabaseMustCreateTheTable;
begin
  FManager.UpdateDatabaseSchema;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.OpenCursor('select * from MyTestClass').Next;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheTableExistsInTheDatabaseMustCreateTheFieldThatDontExists;
begin
  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('alter table MyTestClass drop column Value');

  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select Value from MyTestClass');

  Assert.WillNotRaise(
    procedure
    begin
      Cursor.Next;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.LoadSchemaTables;
begin
  var Manipulator := CreateDatabaseManipulator;

  for var SQL in Manipulator.GetSchemaTablesScripts do
    FManager.ExectDirect(SQL);
end;

procedure TDatabaseSchemaUpdaterTest.OnlyTheFieldThatTheSizeMatterMustBeRecreated;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      for var Field in FDatabaseSchema.Table['MyClassWithAllFieldsType'].Fields do
//        Field.Size := 2000;
//
//      FMetadataManipulator.Expect.ExecutionCount(4).When.UpdateField(It.IsAny<TField>, It.IsAny<TField>);
//    end;
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.OnlyTheFloatFieldMustCheckThePrecisionChange;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      for var Field in FDatabaseSchema.Table['MyClassWithAllFieldsType'].Fields do
//        Field.Scale := 2000;
//
//      FMetadataManipulator.Expect.ExecutionCount(1).When.UpdateField(It.IsAny<TField>, It.IsAny<TField>);
//    end;
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.OnlyTheTableNoExistingTableMustCreatedInTheDatabase;
begin
  FManager.ExectDirect('create table MyTestClass (Id varchar(10))');

  Assert.WillNotRaise(
    procedure
    begin
     FManager.UpdateDatabaseSchema;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.Setup;
begin
  RebootDatabase;

  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  FManager.Mapper.LoadAll;
end;

procedure TDatabaseSchemaUpdaterTest.TearDown;
begin
  FManager.Free;

  DropDatabase;
end;

procedure TDatabaseSchemaUpdaterTest.TheIndexCanBeCreatedOnlyIfNotExistsInDatabase;
begin

end;

procedure TDatabaseSchemaUpdaterTest.TheTableWithManyValueAssociationFieldCantTryToCreateTheFieldMustBeIgnored;
begin
  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select * from ManyValueParentError');

  Cursor.Next;

  Assert.IsNull(Cursor.GetDataSet.FindField('Childs'));
end;

procedure TDatabaseSchemaUpdaterTest.TheTempFieldMustHaveTheSamePropertiesOfTheOriginalFieldExceptByTheNameOfTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Float'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      var TempField := Params[1].AsType<TField>;
//
//      Assert.StartsWith('TempField', TempField.DatabaseName);
//      Assert.StartsWith(TempField.DatabaseName, TempField.Name);
//
//      Assert.AreEqual(tkFloat, TempField.FieldType.TypeKind);
//      Assert.AreEqual(5, TempField.Scale);
//      Assert.AreEqual(10, TempField.Size);
//
//      Assert.IsNotNull(TempField.Table);
//
//      Assert.IsTrue(TempField.Required);
//
//      Assert.AreEqual('MyClassWithAllFieldsType', TempField.Table.Name);
//    end).When.CreateTempField(It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenAddAFieldToATableCantAddTheManyValueAssociationField;
begin
  FManager.ExectDirect('create table ManyValueParentError (Id int not null)');

  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select * from ManyValueParentError');

  Cursor.Next;

  Assert.IsNull(Cursor.GetDataSet.FindField('Childs'));
end;

procedure TDatabaseSchemaUpdaterTest.WhenAFieldWithAPrecisionMustCreateTheFieldWithThePrecisionOfTheAttribute;
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = 'Float')).Open.One;

  Assert.AreEqual(5, Field.Scale);
end;

procedure TDatabaseSchemaUpdaterTest.WhenAFieldWithASizeMustCreateTheFieldWithTheSizeOfTheAttribute;
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = 'DefaultField')).Open.One;

  Assert.AreEqual(30, Field.Size);
end;

procedure TDatabaseSchemaUpdaterTest.WhenAnIndexBecameUniqueMustRecreateTheIndex;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Index['UniqueKey'].Unique := False;
//    end;
//  var Table := FMapper.GetTable(TMyClass);
//
//  FMetadataManipulator.Expect.Once.When.DropIndex(It.IsAny<TDatabaseIndex>);
//
//  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[5]));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenChangeTheTypeOfAFieldMustRecreateTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCheckTheSchemaCantRaiseAnyError;
begin
  Assert.WillNotRaise(FManager.UpdateDatabaseSchema);
end;

procedure TDatabaseSchemaUpdaterTest.WhenComparingNamesOfTablesMustBeCaseInsensitivityTheComparision;
begin
  FManager.ExectDirect('create table manyvalueparenterror (id int not null)');

  Assert.WillNotRaise(
    procedure
    begin
      FManager.UpdateDatabaseSchema;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateAFieldMustLoadTheFieldInfoTypeFromTheManipulador;
begin
  var Manipulator := TDatabaseManiupulatorMock.Create;
  var Manager := TManager.Create(CreateConnection, Manipulator);

  Manager.Mapper.GetTable(TMyClassWithAllFieldsType);

  Manager.UpdateDatabaseSchema;

  Assert.IsTrue(Manipulator.FFunctionFieldTypeCalled, 'Field Type Isn''t Called');
  Assert.IsTrue(Manipulator.FFunctionSpecialTypeCalled, 'Special Field Type Isn''t Called');
  Assert.IsTrue(Manipulator.FFunctionDefaultValueCalled, 'Default Value Isn''t Called');

  Manager.Free;
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateANormalFieldMustLoadTheFieldKindInfoAsExpected(const FieldName: String; const FieldKind: TTypeKind);
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = FieldName)).Open.One;

  Assert.AreEqual(FieldKind, Field.FieldType);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateANotRequiredFieldMustCreateTheFieldNull;
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var NullableField := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = 'NullField')).Open.One;

  Assert.IsFalse(NullableField.Required);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateARequiredFieldMustCreateTheFieldNotNull;
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var RequiredField := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = 'Float')).Open.One;

  Assert.IsTrue(RequiredField.Required);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateASpecialTypeFieldMustLoadTheSpecialTypeInfoAsExpected(const FieldName: String; const SpecialType: TDatabaseSpecialType);
begin
  FManager.Mapper.GetTable(TMyClassWithAllFieldsType);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyClassWithAllFieldsType') and (Field('Name') = FieldName)).Open.One;

  Assert.AreEqual(SpecialType, Field.SpecialType);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateATableMustCreateAllFieldsOfTheTableToo;
begin
  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select Field, Name, Value from MyTestClass');

  Assert.WillNotRaise(
    procedure
    begin
      Cursor.Next;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateATableMustCreateThePrimaryKeyToo;
begin
  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into ClassWithPrimaryKey (Id, Value) values (10, 10)');

  Assert.WillRaise(
    procedure
    begin
      FManager.ExectDirect('insert into ClassWithPrimaryKey (Id, Value) values (10, 10)');
    end);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateATempFieldOfAForeignKeyMustLoadThePropertiesAsExpected;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Field['IdForeignKey'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure (const Params: TArray<TValue>)
//    begin
//      var TempField := Params[1].AsType<TField>;
//
//      Assert.IsTrue(TempField.IsForeignKey);
//
//      Assert.IsNotNull(TempField.ForeignKey);
//    end).When.CreateTempField(It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenCreateDatabaseTheDatabaseMustBeCreated;
begin
  var Manager := TManager.Create(CreateConnectionNamed('MyDatabase'), CreateDatabaseManipulator);

  Manager.CreateDatabase;

  Assert.WillNotRaise(
    procedure
    begin
      CreateConnectionNamed('MyDatabase').OpenCursor('select 1').Next;
    end);

  Manager.DropDatabase;
end;

procedure TDatabaseSchemaUpdaterTest.WhenDontFindThePrimaryKeyIndexMustCreateTheIndex;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseTable := FDatabaseSchema.Table['MyForeignKeyClass'];
//
////      DatabaseTable.Indexes.Remove(DatabaseTable.Index['PK_MyForeignKeyClass']);
//    end;
//  var Table := FMapper.GetTable(TMyForeignKeyClass);
//
//  FMetadataManipulator.Expect.Never.When.DropIndex(It.IsAny<TDatabaseIndex>);
//
//  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropAFieldMustDropTheForeignKeyWithThisFieldIsLinked;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Field['IdForeignKey'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropField(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsAny<TDatabaseForeignKey>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropAFieldMustDropTheIndexesBeforeDropTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Field['IdAnotherForeignKey'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropField(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.ExecutionCount(3).When.DropIndex(It.IsAny<TDatabaseIndex>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropAFieldThatIsAReferenceOfAForeignKeyMustDropAllForeignKeyLinkedToThisField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyForeignKeyClass'].Field['Id'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropField(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.ExecutionCount(2).When.DropForeignKey(It.IsAny<TDatabaseForeignKey>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropAnForeignKeyForFieldChangeMustCreateTheForeignKeyAgain;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Field['IdForeignKey'].FieldType := tkUnknown;
//      FDatabaseSchema.Table['MyForeignKeyClass'].Field['Id'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.ExecutionCount(2).When.CreateForeignKey(It.IsAny<TForeignKey>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropAnIndexForFieldChangeMustCreateTheIndexAgain;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClass'].Field['IdForeignKey'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.ExecutionCount(2).When.CreateIndex(It.IsAny<TIndex>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenDropDatabaseTheDatabaseMustBeDropped;
begin
  var Connection := CreateConnectionNamed('MyDatabase');
  var Manager := TManager.Create(Connection, CreateDatabaseManipulator);

  Manager.CreateDatabase;

  Connection.OpenCursor('select 1').Next;

  Manager.DropDatabase;

  Assert.WillRaise(
    procedure
    begin
      Connection.OpenCursor('select 1').Next;
    end);
end;

procedure TDatabaseSchemaUpdaterTest.WhenExistsMoreThenOneIndexMustCreateAll;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      RemoveIndex('MyClass', 'MyIndex');
//
//      RemoveIndex('MyClass', 'MyIndex2');
//
//      RemoveIndex('MyClass', 'MyIndex3');
//    end;
//
//  FMetadataManipulator.Expect.ExecutionCount(3).When.CreateIndex(It.IsAny<TIndex>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenRemoveTheDefualtConstraintOfAFieldCantTryToCreateTheDefualtConstraintAgain;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FreeAndNil(FMapper.GetTable(TMyClassWithAllFieldsType).Field['DefaultField'].DefaultConstraint);
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Never.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  Assert.WillNotRaise(
//    procedure
//    begin
//      FDatabaseMetadataUpdate.UpdateDatabase;
//    end);
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDatabaseFieldDontHaveDefaultValueAndTheFieldDontHaveADefaultValueCantRecreateTheDefaultConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FreeAndNil(FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Boolean'].DefaultConstraint);
//      FreeAndNil(FMapper.GetTable(TMyClassWithAllFieldsType).Field['Boolean'].DefaultConstraint);
//    end;
//
//  FMetadataManipulator.Expect.Never.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Never.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDatabaseFieldDontHaveDefaultValueAndTheFieldHaveADefaultValueMustRecreateTheDefaultConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var Field := FMapper.GetTable(TMyClassWithAllFieldsType).Field['DefaultField'];
//      Field.DefaultConstraint := TDefaultConstraint.Create;
//      Field.DefaultConstraint.AutoGeneratedType := agtCurrentDate;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDatabaseFieldHaveDefaultValueAndTheFieldDontHaveADefaultValueMustRecreateTheDefaultConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseField := FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['DefaultField'];
//      DatabaseField.DefaultConstraint := TDatabaseDefaultConstraint.Create(DatabaseField, 'My Default', 'My Value');
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDatabaseFieldHaveDefaultValueAndTheFieldHaveADefaultValueCantRecreateTheDefaultConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseField := FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Boolean'];
//      DatabaseField.DefaultConstraint := TDatabaseDefaultConstraint.Create(DatabaseField, 'Default', 'Sequence()');
//      var Field := FMapper.GetTable(TMyClassWithAllFieldsType).Field['Boolean'];
//
//      Field.DefaultConstraint := TDefaultConstraint.Create;
//      Field.DefaultConstraint.AutoGeneratedType := agtSequence;
//    end;
//
//  FMetadataManipulator.Expect.Never.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Never.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDefaultConstraintNameHasChangedMustRecreateTheDefaultConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].DefaultConstraint.Name := 'Another default constraint';
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDefaultRecordsArentInTheTableMustBeAllInserted;
begin
  var MyClass1 := TMyClass.Create;
  MyClass1.Name := 'A';
  MyClass1.Value := 1;
  var MyClass2 := TMyClass.Create;
  MyClass2.Name := 'B';
  MyClass2.Value := 2;
  var MyClass3 := TMyClass.Create;
  MyClass3.Name := 'C';
  MyClass3.Value := 3;

  FManager.Mapper.AddDefaultRecord(MyClass1);

  FManager.Mapper.AddDefaultRecord(MyClass2);

  FManager.Mapper.AddDefaultRecord(MyClass3);

  FManager.UpdateDatabaseSchema;

  var Records := FManager.Select.All.From<TMyClass>.Open.All;

  Assert.AreEqual<NativeInt>(3, Length(Records));
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheDefaultValueHasChangedMustRecreateTheConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].DefaultConstraint.Value := 'Another default value';
//    end;
//
//  FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldAddADefaultConstraintCantTryToDropTheConstraint;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FreeAndNil(FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['DefaultField'].DefaultConstraint);
//    end;
//
//  FMetadataManipulator.Expect.Never.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
//
//  FMetadataManipulator.Expect.Once.When.CreateDefaultConstraint(It.IsAny<TField>);
//
//  Assert.WillNotRaise(
//    procedure
//    begin
//      FDatabaseMetadataUpdate.UpdateDatabase;
//    end);
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldDontExistsInTheMappingMustBeDropedFromTheTable;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
//      var DatabaseField := TDatabaseField.Create(DatabaseTable, 'MyAnotherField');
//
//      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseField));
//    end;
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldHasChangedMustCreateATempFieldForTransferTheFieldData;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].FieldType := tkUnknown;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldIsAnEnumeratorAndTheDatabaseFieldTypeIsIntegerCantRecreateTheField;
begin
//  FMetadataManipulator.Expect.Never.When.CreateTempField(It.IsAny<TField>);
//
//  FMetadataManipulator.Expect.Never.When.CreateField(It.IsEqualTo(FMapper.GetTable(TMyClassWithAllFieldsType).Field['Enumerator']));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldIsBooleanTypeCantBeRecreatedAllTheTime;
begin
//  FMetadataManipulator.Expect.Never.When.UpdateField(It.IsAny<TField>, It.IsEqualTo(FMapper.GetTable(TMyClassWithAllFieldsType).Field['Boolean']));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldIsntChangedCantRecreateTheField;
begin
//  FMetadataManipulator.Expect.Never.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheFieldNameDontHaveTheSameCaseNameMustRenameTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].Name := 'INTEGER';
//    end;
//
//  FMetadataManipulator.Expect.Once.When.RenameField(It.IsAny<TField>, It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheIndexDontExistInDatabaseMustCreateIt;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      RemoveIndex('MyClass', 'MyIndex');
//    end;
//  var Table := FMapper.GetTable(TMyClass);
//
//  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[1]));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheIndexExistsInDatabaseButTheFieldsAreDiffentMustRecreateTheIndex;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      var DatabaseTable := FDatabaseSchema.Table['MyClass'];
//      var Index := DatabaseTable.Index['MyIndex'];
//      Index.Fields[0] := DatabaseTable.Field['IdForeignKey'];
//
//      FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));
//    end;
//  var Table := FMapper.GetTable(TMyClass);
//
//  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[1]));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheIndexWasDropedMustRemoveAllForeignKeysToTheTable;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyForeignKeyClass'].Index['PK_MyForeignKeyClass'].Name := 'AnotherName';
//    end;
//
//  FMetadataManipulator.Setup.WillExecute(
//    procedure
//    begin
//      Assert.IsNull(FDatabaseSchema.Table['MyClass'].ForeignKey['FK_MyClass_MyForeignKeyClass_IdForeignKey']);
//      Assert.IsNull(FDatabaseSchema.Table['MyClass'].ForeignKey['FK_MyClass_MyForeignKeyClass_IdForeignKey2']);
//    end).When.DropIndex(It.IsAny<TDatabaseIndex>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseSchemaUpdaterTest.WhenThePrimaryKeyIndexAsChangedTheNameMustRecreateTheIndex;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyForeignKeyClass'].Index['PK_MyForeignKeyClass'].Name := 'AnotherName';
//    end;
//  var Table := FMapper.GetTable(TMyForeignKeyClass);
//
//  FMetadataManipulator.Expect.Once.When.DropIndex(It.IsAny<TDatabaseIndex>);
//
//  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheRecordAlreadyInTheDatabaseMustUpdateTheRecord;
begin
  var MyClass1 := TMyClass.Create;
  MyClass1.Name := 'A';
  MyClass1.Value := 10;
  var MyClass2 := TMyClass.Create;
  MyClass2.Name := 'B';
  MyClass2.Value := 20;
  var MyClass3 := TMyClass.Create;
  MyClass3.Name := 'C';
  MyClass3.Value := 30;

  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into MyClass values (''A'', 1)');

  FManager.ExectDirect('insert into MyClass values (''B'', 2)');

  FManager.ExectDirect('insert into MyClass values (''C'', 3)');

  FManager.Mapper.AddDefaultRecord(MyClass1);

  FManager.Mapper.AddDefaultRecord(MyClass2);

  FManager.Mapper.AddDefaultRecord(MyClass3);

  FManager.UpdateDatabaseSchema;

  var Records := FManager.Select.All.From<TMyClass>.OrderBy.Field('Value').Open.All;

  Assert.AreEqual(10, Records[0].Value);
  Assert.AreEqual(20, Records[1].Value);
  Assert.AreEqual(30, Records[2].Value);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheRequiredValueHasChangedMustRecreateTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].Required := False;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheSequenceNotExistsInDatabaseMustBeCreated;
begin
  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Sequence := FManager.Select.All.From<TDatabaseSequence>.Where(Field('Name') = 'MySequence').Open.One;

  Assert.IsNotNull(Sequence);

  Assert.AreEqual('MySequence', Sequence.Name)
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheSequenceNotExistsInTheMapperMustBeDroped;
begin
  FManager.UpdateDatabaseSchema;

  var Sequence := TSequence.Create('AnySequence');

  FManager.ExectDirect(CreateDatabaseManipulator.CreateSequence(Sequence));

  Sequence.Free;

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var DatabaseSequence := FManager.Select.All.From<TDatabaseSequence>.Where(Field('Name') = 'AnySequence').Open.One;

  Assert.IsNull(DatabaseSequence);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheSizeOfTheFieldWasChangedMustRecreateTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['VarChar'].Size := 20;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheSpecialTypeOfTheFieldHasChangedMustRecreateTheField;
begin
//  FOnSchemaLoad :=
//    procedure
//    begin
//      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'].SpecialType := stDateTime;
//    end;
//
//  FMetadataManipulator.Expect.Once.When.CreateTempField(It.IsAny<TField>);
//
//  FDatabaseMetadataUpdate.UpdateDatabase;
//
//  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheTableDoesntHaveAPrimaryMustCreateThePrimaryKeyFromTheTable;
begin
  var TableName := TManyValueParentError.ClassName.Substring(1);

  FManager.ExectDirect(Format('create table %s (AnyField varchar(10))', [TableName]));

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Table := FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = TableName).Open.One;

  Assert.IsNotNull(Table.PrimaryKeyConstraint);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheTableIsntMappedMustDropTheTable;
begin
  FManager.ExectDirect('create table ATableDoesntExists (AnyField varchar(10))');

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Tables := FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = 'ATableDoesntExists').Open.All;

  Assert.AreEqual<NativeInt>(0, Length(Tables));
end;

{ TDatabaseManiupulatorMock }

constructor TDatabaseManiupulatorMock.Create;
begin
  inherited;

  FManipulador := CreateDatabaseManipulator;
end;

function TDatabaseManiupulatorMock.CreateDatabase(const DatabaseName: String): String;
begin
  Result := FManipulador.CreateDatabase(DatabaseName);
end;

function TDatabaseManiupulatorMock.CreateSequence(const Sequence: TSequence): String;
begin
  Result := FManipulador.CreateSequence(Sequence);
end;

function TDatabaseManiupulatorMock.DropDatabase(const DatabaseName: String): String;
begin
  Result := FManipulador.DropDatabase(DatabaseName);
end;

function TDatabaseManiupulatorMock.DropSequence(const Sequence: TDatabaseSequence): String;
begin
  Result := FManipulador.DropSequence(Sequence);
end;

function TDatabaseManiupulatorMock.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
begin
  FFunctionDefaultValueCalled := True;
  Result := FManipulador.GetDefaultValue(DefaultConstraint);
end;

function TDatabaseManiupulatorMock.GetFieldType(const Field: TField): String;
begin
  FFunctionFieldTypeCalled := True;
  Result := FManipulador.GetFieldType(Field);
end;

function TDatabaseManiupulatorMock.GetSchemaTablesScripts: TArray<String>;
begin
  Result := FManipulador.GetSchemaTablesScripts;
end;

function TDatabaseManiupulatorMock.GetSpecialFieldType(const Field: TField): String;
begin
  FFunctionSpecialTypeCalled := True;
  Result := FManipulador.GetSpecialFieldType(Field);
end;

function TDatabaseManiupulatorMock.IsSQLite: Boolean;
begin
  Result := False;
end;

function TDatabaseManiupulatorMock.MakeInsertStatement(const Table: TTable; const Params: TParams): String;
begin
  Result := FManipulador.MakeInsertStatement(Table, Params);
end;

function TDatabaseManiupulatorMock.MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
begin
  Result := FManipulador.MakeUpdateStatement(Table, Params);
end;

end.

