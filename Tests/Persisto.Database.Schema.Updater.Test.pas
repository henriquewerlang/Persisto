unit Persisto.Database.Schema.Updater.Test;

interface

uses System.SysUtils, System.Generics.Collections, Data.DB, Test.Insight.Framework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TDatabaseSchemaUpdaterTest = class
  private
    FManager: TManager;

    function LoadForeignKeys(const TableName: String): TArray<TDatabaseForeignKey>;
    function LoadIndexes(const TableName: String): TArray<TDatabaseIndex>;
    function LoadTable(const Name: String): TDatabaseTable;

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
//    [TestCase('String', 'VarChar,tkString')]
//    [TestCase('Integer', 'Integer,tkInteger')]
//    [TestCase('Char', 'Char,tkChar')]
//    [TestCase('Enumeration', 'Enumerator,tkEnumeration')]
//    [TestCase('Float', 'Float,tkFloat')]
//    [TestCase('Int64', 'Bigint,tkInt64')]
    procedure WhenCreateANormalFieldMustLoadTheFieldKindInfoAsExpected(const FieldName: String; const FieldKind: TTypeKind);
//    [TestCase('Date', 'Date,stDate')]
//    [TestCase('DateTime', 'DateTime,stDateTime')]
//    [TestCase('Time', 'Time,stTime')]
//    [TestCase('Text', 'Text,stText')]
//    [TestCase('Unique Identifier', 'UniqueIdentifier,stUniqueIdentifier')]
//    [TestCase('Boolean', 'Boolean,stBoolean')]
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
    procedure WhenTheDefaultRecordsArentInTheTableMustBeAllInserted;
    [Test]
    procedure WhenTheRecordAlreadyInTheDatabaseMustUpdateTheRecord;
    [Test]
    procedure WhenCreateDatabaseTheDatabaseMustBeCreated;
    [Test]
    procedure WhenDropDatabaseTheDatabaseMustBeDropped;
    [Test]
    procedure WhenDropATableMustDropTheForeignKeyFirst;
    [Test]
    procedure WhenAFieldIsAddedToATableAndIsRequiredButDontHaveADefaultValueMustBeCreatedWithAFakeDefaultValue;
    [Test]
    procedure WhenAFieldIsAddedToATableAndIsNotRequiredCantCreatedWithAFakeDefaultValue;
    [Test]
    procedure WhenTheRequiredFieldIsAnUniqueIdentifierTheFakeDefaultValueMustBeAGUIDEmpty;
    [Test]
    procedure TheFakeDefaultConstraintMustBeCleanedUpFromTheField;
    [Test]
    procedure CanOnlyCreateTableWithEntityAttribute;
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
    function GetDefaultDatabaseName: String;
    function GetDefaultValue(const Field: TField): String;
    function GetFieldType(const FieldType: TTypeKind): String;
    function GetMaxNameSize: Integer;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const SpecialType: TDatabaseSpecialType): String;
    function IsSQLite: Boolean;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
    function MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
  public
    constructor Create;
  end;

implementation

uses System.Rtti, Persisto.Test.Entity, Persisto.Test.Connection;

{ TDatabaseSchemaUpdaterTest }

procedure TDatabaseSchemaUpdaterTest.CanOnlyCreateTableWithEntityAttribute;
begin
  FManager.Mapper.GetTable(TClassWithoutEntityAttribute);

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Table := FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = 'ClassWithoutEntityAttribute').Open.One;

  Assert.IsNil(Table);
end;

procedure TDatabaseSchemaUpdaterTest.IfTheForeignKeyExistsInDatabaseButNotExistsInTheMapperTheForeignKeyMustBeRemoved;
begin
  FManager.ExectDirect('create table ClassWithForeignKey (Id int not null, constraint PK primary key (Id))');
  FManager.ExectDirect('create table ClassWithPrimaryKey (Id int not null)');

  FManager.ExectDirect('alter table ClassWithPrimaryKey add constraint MyFK foreign key (Id) references ClassWithForeignKey(Id)');

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var ForeignKeys := LoadForeignKeys('ClassWithPrimaryKey');

  Assert.AreEqual(0, Length(ForeignKeys));
end;

procedure TDatabaseSchemaUpdaterTest.IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
begin
  FManager.ExectDirect('create table InsertTestWithForeignKey (AnyField varchar(10))');

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var ForeignKeys := LoadForeignKeys('InsertTestWithForeignKey');

  Assert.AreEqual(2, Length(ForeignKeys));
end;

procedure TDatabaseSchemaUpdaterTest.IfTheTableDoesntExistsMustCreateAllForeignKeysOfTheTable;
begin
  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var ForeignKeys := LoadForeignKeys('InsertTestWithForeignKey');

  Assert.AreEqual(2, Length(ForeignKeys));
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

function TDatabaseSchemaUpdaterTest.LoadForeignKeys(const TableName: String): TArray<TDatabaseForeignKey>;
begin
  Result := FManager.Select.All.From<TDatabaseForeignKey>.Where(Field('IdTable') = LoadTable(TableName).Id).Open.All;
end;

function TDatabaseSchemaUpdaterTest.LoadIndexes(const TableName: String): TArray<TDatabaseIndex>;
begin
  Result := FManager.Select.All.From<TDatabaseIndex>.Where(Field('IdTable') = FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = TableName).Open.One.Id).Open.All;
end;

procedure TDatabaseSchemaUpdaterTest.LoadSchemaTables;
begin
  var Manipulator := CreateDatabaseManipulator;

  for var SQL in Manipulator.GetSchemaTablesScripts do
    FManager.ExectDirect(SQL);
end;

function TDatabaseSchemaUpdaterTest.LoadTable(const Name: String): TDatabaseTable;
begin
  Result := FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = Name).Open.One;
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
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  FManager.Mapper.LoadAll;

  FManager.CreateDatabase;
end;

procedure TDatabaseSchemaUpdaterTest.TearDown;
begin
  FManager.DropDatabase;

  FManager.Free;
end;

procedure TDatabaseSchemaUpdaterTest.TheFakeDefaultConstraintMustBeCleanedUpFromTheField;
begin
  FManager.ExectDirect('create table MyRequiredField (Id int not null)');

  FManager.UpdateDatabaseSchema;

  var Field := FManager.Mapper.GetTable(TMyRequiredField).Field['Required'];

  Assert.IsNil(Field.DefaultConstraint);
end;

procedure TDatabaseSchemaUpdaterTest.TheTableWithManyValueAssociationFieldCantTryToCreateTheFieldMustBeIgnored;
begin
  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select * from ManyValueParentError');

  Cursor.Next;

  Assert.IsNil(Cursor.GetDataSet.FindField('Childs'));
end;

procedure TDatabaseSchemaUpdaterTest.WhenAddAFieldToATableCantAddTheManyValueAssociationField;
begin
  FManager.ExectDirect('create table ManyValueParentError (Id int not null)');

  FManager.UpdateDatabaseSchema;

  var Cursor := FManager.OpenCursor('select * from ManyValueParentError');

  Cursor.Next;

  Assert.IsNil(Cursor.GetDataSet.FindField('Childs'));
end;

procedure TDatabaseSchemaUpdaterTest.WhenAFieldIsAddedToATableAndIsNotRequiredCantCreatedWithAFakeDefaultValue;
begin
  FManager.ExectDirect('create table MyRequiredField (Id int not null)');

  FManager.UpdateDatabaseSchema;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyRequiredField') and (Field('Name') = 'NotRequired')).Open.One;

  Assert.IsNil(Field.DefaultConstraint);
end;

procedure TDatabaseSchemaUpdaterTest.WhenAFieldIsAddedToATableAndIsRequiredButDontHaveADefaultValueMustBeCreatedWithAFakeDefaultValue;
begin
  FManager.ExectDirect('create table MyRequiredField (Id int not null)');

  FManager.UpdateDatabaseSchema;

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyRequiredField') and (Field('Name') = 'Required')).Open.One;

  Assert.IsNotNil(Field.DefaultConstraint);
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
    end, Exception);
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

procedure TDatabaseSchemaUpdaterTest.WhenDropATableMustDropTheForeignKeyFirst;
begin
  FManager.ExectDirect('create table ClassWithForeignKey2 (Id int not null, constraint PK1 primary key (Id))');
  FManager.ExectDirect('create table ClassWithPrimaryKey2 (Id int not null, constraint PK2 primary key (Id))');

  FManager.ExectDirect('alter table ClassWithPrimaryKey2 add constraint MyFK1 foreign key (Id) references ClassWithForeignKey2(Id)');

  FManager.ExectDirect('alter table ClassWithForeignKey2 add constraint MyFK2 foreign key (Id) references ClassWithPrimaryKey2(Id)');

  Assert.WillNotRaise(
    procedure
    begin
      FManager.UpdateDatabaseSchema;
    end);

  var DatabaseTable := LoadTable('ClassWithForeignKey2');

  Assert.IsNil(DatabaseTable);
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
    end, Exception);
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

  Assert.AreEqual(3, Length(Records));
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

procedure TDatabaseSchemaUpdaterTest.WhenTheRequiredFieldIsAnUniqueIdentifierTheFakeDefaultValueMustBeAGUIDEmpty;
begin
  FManager.ExectDirect('create table MyRequiredField (Id int not null)');

  Assert.WillNotRaise(FManager.UpdateDatabaseSchema);

  var Field := FManager.Select.All.From<TDatabaseField>.Where((Field('Table.Name') = 'MyRequiredField') and (Field('Name') = 'MyUnique')).Open.One;

  Assert.StartWith('''00000000-0000-0000-0000-000000000000''', Field.DefaultConstraint.Value);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheSequenceNotExistsInDatabaseMustBeCreated;
begin
  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Sequence := FManager.Select.All.From<TDatabaseSequence>.Where(Field('Name') = 'MySequence').Open.One;

  Assert.IsNotNil(Sequence);

  Assert.AreEqual('MySequence'.ToLower, Sequence.Name.ToLower);
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

  Assert.IsNil(DatabaseSequence);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheTableDoesntHaveAPrimaryMustCreateThePrimaryKeyFromTheTable;
begin
  var TableName := TManyValueParentError.ClassName.Substring(1);

  FManager.ExectDirect(Format('create table %s (AnyField varchar(10))', [TableName]));

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Indexes := LoadIndexes(TableName);

  Assert.AreEqual(1, Length(Indexes));
  Assert.IsTrue(Indexes[0].IsPrimaryKey);
end;

procedure TDatabaseSchemaUpdaterTest.WhenTheTableIsntMappedMustDropTheTable;
begin
  FManager.ExectDirect('create table ATableDoesntExists (AnyField varchar(10))');

  FManager.UpdateDatabaseSchema;

  LoadSchemaTables;

  var Tables := FManager.Select.All.From<TDatabaseTable>.Where(Field('Name') = 'ATableDoesntExists').Open.All;

  Assert.AreEqual(0, Length(Tables));
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

function TDatabaseManiupulatorMock.GetDefaultDatabaseName: String;
begin
  Result := 'Default';
end;

function TDatabaseManiupulatorMock.GetDefaultValue(const Field: TField): String;
begin
  FFunctionDefaultValueCalled := True;
  Result := FManipulador.GetDefaultValue(Field);
end;

function TDatabaseManiupulatorMock.GetFieldType(const FieldType: TTypeKind): String;
begin
  FFunctionFieldTypeCalled := True;
  Result := FManipulador.GetFieldType(FieldType);
end;

function TDatabaseManiupulatorMock.GetMaxNameSize: Integer;
begin
  Result := 30;
end;

function TDatabaseManiupulatorMock.GetSchemaTablesScripts: TArray<String>;
begin
  Result := FManipulador.GetSchemaTablesScripts;
end;

function TDatabaseManiupulatorMock.GetSpecialFieldType(const SpecialType: TDatabaseSpecialType): String;
begin
  FFunctionSpecialTypeCalled := True;
  Result := FManipulador.GetSpecialFieldType(SpecialType);
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

