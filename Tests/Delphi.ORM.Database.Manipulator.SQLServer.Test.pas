unit Delphi.ORM.Database.Manipulator.SQLServer.Test;

interface

uses System.Generics.Collections, DUnitX.TestFramework, Delphi.Mock.Intf, Delphi.ORM.Database.Connection, Delphi.ORM.Database.Metadata, Delphi.ORM.Attributes;

type
  [TestFixture]
  TManipulatorSQLServerTest = class
  private
    FConnection: IMock<IDatabaseConnection>;
    FForeignKeyCursor: IDatabaseCursor;
    FIndexCursor: IDatabaseCursor;
    FManipulator: IMetadataManipulator;
    FTableCursor: IDatabaseCursor;
    FTables: TDictionary<String, TDatabaseTable>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenCallLoadTablesMustLoadAllTablesFromTheDatabase;
    [Test]
    procedure MustLoadTheTableNameFromTheCursorAsExpected;
    [Test]
    procedure WhenLoadingTheTableCantRaiseDuplicationError;
    [Test]
    procedure WhenLoadTheTableMustLoadTheColumnsOfTheTable;
    [TestCase('Bigint', 'Table3,Bigint,bigint,8,19,0,0')]
    [TestCase('Boolean', 'Table4,Boolean,bit,1,1')]
    [TestCase('Char', 'Table1,Char,char,1,0,0,0,MyCollate')]
    [TestCase('Date', 'Table1,Date,date,3,10')]
    [TestCase('DateTime', 'Table2,DateTime,datetime, 8, 23, 3')]
    [TestCase('DefaultValue', 'Table3,DefaultValue,datetime,8,23,3,0,,getdate(),DF_Default_Value')]
    [TestCase('Int', 'Table3,Int,int,14')]
    [TestCase('Nullable', 'Table2,Nullable,datetime, 8, 23, 3, 1')]
    [TestCase('Numeric', 'Table3,Numeric,numeric, 9, 18, 8')]
    [TestCase('Smallint', 'Table2,Smallint,smallint, 2, 5')]
    [TestCase('Time', 'Table1,Time,time, 5, 16, 7')]
    [TestCase('Tinyint', 'Table2,Tinyint,tinyint, 1, 3')]
    [TestCase('Uniqueidentifier', 'Table1,Uniqueidentifier,uniqueidentifier, 16')]
    [TestCase('Varchar', 'Table3,Varchar,varchar, 50, 0, 0, 0,MyCollate')]
    procedure TheColumnInfoMustBeLoadedHasExpected(const TableName, ColumnName, TypeName: String; const Size, Precision, Scale, Nullable: Word; const Collation, DefaultValue, DefaultName: String);
    [Test]
    procedure MustLoadAllIndexesInTheTablesAsExpected;
    [Test]
    procedure TheIndexMustLoadTheNameHasExpected;
    [Test]
    procedure WhenLoadTheIndexMustLoadAllFieldOfTheIndexHasExpected;
    [Test]
    procedure WhenTheIndexIsPrimaryKeyMustMarkTheInfoInTheIndex;
    [Test]
    procedure WhenTheIndexIsUniqueMustLoadTheInfo;
    [TestCase('Date', 'Table1,Date,stDate')]
    [TestCase('DateTime', 'Table2,DateTime,stDateTime')]
    [TestCase('Time', 'Table1,Time,stTime')]
    [TestCase('Text', 'Table4,Text,stText')]
    [TestCase('Varchar(MAX)', 'Table4,VarcharMax,stText')]
    [TestCase('Uniqueidentifier', 'Table1,Uniqueidentifier,stUniqueIdentifier')]
    procedure WhenLoadTheFieldInfoMustLoadTheSpecialFieldInfo(const TableName, ColumnName: String; const SpecialType: TDatabaseSpecialType);
    [Test]
    procedure WhenLoadTheTableMustLoadTheForeignKeysOfTheTable;
    [Test]
    procedure TheNameOfForeignKeyMustBeLoaded;
    [Test]
    procedure TheFieldsOfTheForeignKeyMustBeLoadedHasExpected;
    [Test]
    procedure TheFieldsLoadedInForeignKeyMustLoadFieldFromTheTable;
    [Test]
    procedure TheReferenceTableOfForeignKeyMustBeLoaded;
    [Test]
    procedure MustLoadTheReferenceFieldsOfTheForeignKey;
    [Test]
    procedure TheReferenceFieldsMustBeLoadedWithTheReferenceFieldOfTheReferenceTable;
  end;

implementation

uses System.Rtti, System.Variants, Delphi.Mock, Delphi.ORM.Database.Manipulator.SQLServer, Delphi.ORM.Cursor.Mock;

{ TManipulatorSQLServerTest }

procedure TManipulatorSQLServerTest.MustLoadAllIndexesInTheTablesAsExpected;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(2, FTables['Table1'].Indexes.Count);

  Assert.AreEqual(1, FTables['Table2'].Indexes.Count);
end;

procedure TManipulatorSQLServerTest.MustLoadTheReferenceFieldsOfTheForeignKey;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual<NativeInt>(2, Length(FTables['Table1'].ForeignKeys['FK1'].FieldsReference));

  Assert.AreEqual<NativeInt>(1, Length(FTables['Table1'].ForeignKeys['FK2'].FieldsReference));

  Assert.AreEqual<NativeInt>(1, Length(FTables['Table2'].ForeignKeys['FK3'].FieldsReference));
end;

procedure TManipulatorSQLServerTest.MustLoadTheTableNameFromTheCursorAsExpected;
begin
  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables.ContainsKey('Table1'));

  Assert.IsNotNull(FTables['Table1']);

  Assert.AreEqual('Table1', FTables['Table1'].Name);
end;

procedure TManipulatorSQLServerTest.Setup;
begin
  FConnection := TMock.CreateInterface<IDatabaseConnection>;
  FForeignKeyCursor := TCursorMock.Create([
    ['Table1', 'FK1', 'Char', 'Table2', 'DateTime'],
    ['Table1', 'FK1', 'Date', 'Table2', 'Tinyint'],
    ['Table1', 'FK2', 'Date', 'Table2', 'DateTime'],
    ['Table2', 'FK3', 'Nullable', 'Table1', 'Date']]);
  FIndexCursor := TCursorMock.Create([
    ['Table1', 'Index1', 'Char', 0, 0],
    ['Table1', 'Index1', 'Date', 0, 0],
    ['Table2', 'Index2', 'DateTime', 0, 1],
    ['Table1', 'Index3', 'Time', 1, 0]]);
  FManipulator := TManipulatorSQLServer.Create(FConnection.Instance);
  FTableCursor := TCursorMock.Create([
    ['Table3', 'Bigint', 'bigint', 8, 19, 0, 0, NULL, NULL, NULL],
    ['Table4', 'Boolean', 'bit', 1, 1, 0, 0, NULL, NULL, NULL],
    ['Table1', 'Char', 'char', 1, 0, 0, 0, 'MyCollate', NULL, NULL],
    ['Table1', 'Date', 'date', 3, 10, 0, 0, NULL, NULL, NULL],
    ['Table2', 'DateTime', 'datetime', 8, 23, 3, 0, NULL, NULL, NULL],
    ['Table3', 'DefaultValue', 'datetime', 8, 23, 3, 0, NULL, 'DF_Default_Value', '(getdate())'],
    ['Table3', 'Int', 'int', 4, 10, 0, 0, NULL, NULL, NULL],
    ['Table2', 'Nullable', 'datetime', 8, 23, 3, 1, NULL, NULL, NULL],
    ['Table3', 'Numeric', 'numeric', 9, 18, 8, 0, NULL, NULL, NULL],
    ['Table2', 'Smallint', 'smallint', 2, 5, 0, 0, NULL, NULL, NULL],
    ['Table1', 'Time', 'time', 5, 16, 7, 0, NULL, NULL, NULL],
    ['Table2', 'Tinyint', 'tinyint', 1, 3, 0, 0, NULL, NULL, NULL],
    ['Table1', 'Uniqueidentifier', 'uniqueidentifier', 16, 0, 0, 0, NULL, NULL, NULL],
    ['Table3', 'Varchar', 'varchar', 50, 0, 0, 0, 'MyCollate', NULL, NULL],
    ['Table4', 'Text', 'text', 16, 0, 0, 0, 'MyCollate', NULL, NULL],
    ['Table4', 'VarcharMax', 'varchar', -1, 0, 0, 0, 'MyCollate', NULL, NULL]]);
  FTables := TObjectDictionary<String, TDatabaseTable>.Create([doOwnsValues]);

  FConnection.Setup.WillReturn(TValue.From(FForeignKeyCursor)).When.OpenCursor(It.IsEqualTo(FOREIGN_KEY_LOAD_SQL));

  FConnection.Setup.WillReturn(TValue.From(FIndexCursor)).When.OpenCursor(It.IsEqualTo(INDEX_LOAD_SQL));

  FConnection.Setup.WillReturn(TValue.From(FTableCursor)).When.OpenCursor(It.IsEqualTo(TABLE_LOAD_SQL));
end;

procedure TManipulatorSQLServerTest.TearDown;
begin
  FConnection := nil;
  FForeignKeyCursor := nil;
  FIndexCursor := nil;
  FManipulator := nil;
  FTableCursor := nil;

  FTables.Free;
end;

procedure TManipulatorSQLServerTest.TheColumnInfoMustBeLoadedHasExpected(const TableName, ColumnName, TypeName: String; const Size, Precision, Scale, Nullable: Word;
  const Collation, DefaultValue, DefaultName: String);
begin
  var FieldType := TDictionary<String, TTypeKind>.Create;

  FieldType.Add('bigint', tkInt64);
  FieldType.Add('bit', tkEnumeration);
  FieldType.Add('char', tkChar);
  FieldType.Add('date', tkFloat);
  FieldType.Add('datetime', tkFloat);
  FieldType.Add('int', tkInteger);
  FieldType.Add('numeric', tkFloat);
  FieldType.Add('smallint', tkInteger);
  FieldType.Add('time', tkFloat);
  FieldType.Add('tinyint', tkInteger);
  FieldType.Add('uniqueidentifier', tkUString);
  FieldType.Add('varchar', tkUString);

  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables[TableName].Fields.ContainsKey(ColumnName), ColumnName);

  var Field := FTables[TableName].Fields[ColumnName];

  Assert.AreEqual(ColumnName, Field.Name, 'Column name');
  Assert.AreEqual(FieldType[TypeName], Field.FieldType, 'Column type');
  Assert.AreEqual<Word>(Size + Precision, Field.Size, 'Column size');
  Assert.AreEqual(Scale, Field.Scale, 'Column scale');
  Assert.AreEqual(Nullable = 1, Field.Nullable, 'Nullable');
  Assert.AreEqual(Collation, Field.Collation, 'Collation');
  Assert.AreEqual(DefaultName, Field.DefaultName, 'Default name');
  Assert.AreEqual(DefaultValue, Field.DefaultValue, 'Default value');

  FieldType.Free;
end;

procedure TManipulatorSQLServerTest.TheFieldsLoadedInForeignKeyMustLoadFieldFromTheTable;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual('Char', FTables['Table1'].ForeignKeys['FK1'].Fields[0].Name);
  Assert.AreEqual('Date', FTables['Table1'].ForeignKeys['FK1'].Fields[1].Name);
  Assert.AreEqual('Date', FTables['Table1'].ForeignKeys['FK2'].Fields[0].Name);
  Assert.AreEqual('Nullable', FTables['Table2'].ForeignKeys['FK3'].Fields[0].Name);
end;

procedure TManipulatorSQLServerTest.TheFieldsOfTheForeignKeyMustBeLoadedHasExpected;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual<NativeInt>(2, Length(FTables['Table1'].ForeignKeys['FK1'].Fields));

  Assert.AreEqual<NativeInt>(1, Length(FTables['Table1'].ForeignKeys['FK2'].Fields));

  Assert.AreEqual<NativeInt>(1, Length(FTables['Table2'].ForeignKeys['FK3'].Fields));
end;

procedure TManipulatorSQLServerTest.TheIndexMustLoadTheNameHasExpected;
begin
  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables['Table1'].Indexes.ContainsKey('Index1'));

  Assert.IsNotNull(FTables['Table1'].Indexes['Index1']);

  Assert.AreEqual('Index1', FTables['Table1'].Indexes['Index1'].Name);
end;

procedure TManipulatorSQLServerTest.TheNameOfForeignKeyMustBeLoaded;
begin
  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables['Table1'].ForeignKeys.ContainsKey('FK1'));

  Assert.IsTrue(FTables['Table1'].ForeignKeys.ContainsKey('FK2'));

  Assert.IsTrue(FTables['Table2'].ForeignKeys.ContainsKey('FK3'));
end;

procedure TManipulatorSQLServerTest.TheReferenceFieldsMustBeLoadedWithTheReferenceFieldOfTheReferenceTable;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual('DateTime', FTables['Table1'].ForeignKeys['FK1'].FieldsReference[0].Name);

  Assert.AreEqual('Tinyint', FTables['Table1'].ForeignKeys['FK1'].FieldsReference[1].Name);

  Assert.AreEqual('DateTime', FTables['Table1'].ForeignKeys['FK2'].FieldsReference[0].Name);

  Assert.AreEqual('Date', FTables['Table2'].ForeignKeys['FK3'].FieldsReference[0].Name);
end;

procedure TManipulatorSQLServerTest.TheReferenceTableOfForeignKeyMustBeLoaded;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(FTables['Table2'], FTables['Table1'].ForeignKeys['FK1'].ReferenceTable);

  Assert.AreEqual(FTables['Table2'], FTables['Table1'].ForeignKeys['FK2'].ReferenceTable);

  Assert.AreEqual(FTables['Table1'], FTables['Table2'].ForeignKeys['FK3'].ReferenceTable);
end;

procedure TManipulatorSQLServerTest.WhenCallLoadTablesMustLoadAllTablesFromTheDatabase;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(4, FTables.Count);
end;

procedure TManipulatorSQLServerTest.WhenLoadingTheTableCantRaiseDuplicationError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManipulator.LoadTables(FTables);
    end);
end;

procedure TManipulatorSQLServerTest.WhenLoadTheFieldInfoMustLoadTheSpecialFieldInfo(const TableName, ColumnName: String; const SpecialType: TDatabaseSpecialType);
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(SpecialType, FTables[TableName].Fields[ColumnName].SpecialType);
end;

procedure TManipulatorSQLServerTest.WhenLoadTheIndexMustLoadAllFieldOfTheIndexHasExpected;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual<NativeInt>(2, Length(FTables['Table1'].Indexes['Index1'].Fields));

  Assert.IsNotNull(FTables['Table1'].Indexes['Index1'].Fields[0]);

  Assert.IsNotNull(FTables['Table1'].Indexes['Index1'].Fields[1]);

  Assert.AreEqual('Time', FTables['Table1'].Indexes['Index3'].Fields[0].Name);
end;

procedure TManipulatorSQLServerTest.WhenLoadTheTableMustLoadTheColumnsOfTheTable;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(4, FTables['Table1'].Fields.Count);

  Assert.AreEqual(4, FTables['Table2'].Fields.Count);

  Assert.AreEqual(5, FTables['Table3'].Fields.Count);

  Assert.AreEqual(3, FTables['Table4'].Fields.Count);
end;

procedure TManipulatorSQLServerTest.WhenLoadTheTableMustLoadTheForeignKeysOfTheTable;
begin
  FManipulator.LoadTables(FTables);

  Assert.AreEqual(2, FTables['Table1'].ForeignKeys.Count);

  Assert.AreEqual(1, FTables['Table2'].ForeignKeys.Count);
end;

procedure TManipulatorSQLServerTest.WhenTheIndexIsPrimaryKeyMustMarkTheInfoInTheIndex;
begin
  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables['Table1'].Indexes['Index3'].PrimaryKey);
end;

procedure TManipulatorSQLServerTest.WhenTheIndexIsUniqueMustLoadTheInfo;
begin
  FManipulator.LoadTables(FTables);

  Assert.IsTrue(FTables['Table2'].Indexes['Index2'].Unique);
end;

end.

