unit Delphi.ORM.Database.Metadata.Test;

interface

uses System.Generics.Collections, DUnitX.TestFramework, Delphi.Mock.Intf, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Attributes, Delphi.ORM.Nullable;

type
  [TestFixture]
  TDatabaseMetadataUpdateTest = class
  private
    FDatabaseMetadataUpdate: TDatabaseMetadataUpdate;
    FDatabaseTables: TDictionary<String, TDatabaseTable>;
    FMapper: TMapper;
    FMetadataManipulator: IMock<IMetadataManipulator>;

    function LoadDatabaseTable(const Table: TTable): TDatabaseTable;

    procedure CleanUpDatabaseTables;
    procedure RemoveField(const TableDatabaseName, FieldName: String);
    procedure RemoveForeignKey(const TableDatabaseName, ForeignKeyName: String);
    procedure RemoveIndex(const TableDatabaseName, IndexName: String);
    procedure RemoveTable(const TableDatabaseName: String);
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenUpdataDeDatabaseMustLoadAllTablesFromTheDataBase;
    [Test]
    procedure IfTheMapperIsntLoadedMustGetTheDefaultMapper;
    [Test]
    procedure IfTheTableDontExistsInTheDatabaseMustCreateTheTable;
    [Test]
    procedure OnlyTheTableNoExistingTableMustCreatedInTheDataBase;
    [Test]
    procedure IfTheTableExistsInTheDatabaseMustCreateTheFieldThatDontExists;
    [Test]
    procedure IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
    [Test]
    procedure IfTheForeignKeyExistsInDatabaseButTheFieldHasADifferentNameMustRecreateTheForeignKey;
    [Test]
    procedure IfTheForeignKeyExistsInDatabaseButNotExistsInTheMapperTheForeignKeyMustBeRemoved;
    [Test]
    procedure IfTheTableDontExistsInTheMappingCantDropTheForeignKeyOfIt;
    [Test]
    procedure WhenTheTableIsntMappedMustDropTheTable;
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
    procedure IfTheFieldHasntAnyChangeCantRecreateTheField;
    [TestCase('Boolean', 'Boolean,true,true,true,false')]
    [TestCase('Bigint', 'Bigint,true,true,true,false')]
    [TestCase('Byte', 'Byte,true,true,true,false')]
    [TestCase('Char', 'Char,true,true,true,false')]
    [TestCase('Date', 'Date,true,true,true,false')]
    [TestCase('DateTime', 'DateTime,true,true,true,false')]
    [TestCase('Enumerator', 'Enumerator,true,true,true,false')]
    [TestCase('Float', 'Float,false,true,true,false')]
    [TestCase('Integer', 'Integer,true,true,true,false')]
    [TestCase('Smallint', 'Smallint,true,true,true,false')]
    [TestCase('Text', 'Text,false,true,true,true')]
    [TestCase('Time', 'Time,true,true,true,false')]
    [TestCase('UniqueIdentifier', 'UniqueIdentifier,false,true,true,true')]
    [TestCase('VarChar', 'VarChar,false,true,true,false')]
    procedure WhenTheFieldHasChangedMustRecreateTheField(const FieldName: String; const ChangeType, ChangeSize, ChangeScale, ChangeSpecialType: Boolean);
    [TestCase('Boolean', 'Boolean,true,true,false')]
    [TestCase('Bigint', 'Bigint,true,true,false')]
    [TestCase('Byte', 'Byte,true,true,false')]
    [TestCase('Char', 'Char,true,true,false')]
    [TestCase('Date', 'Date,true,true,false')]
    [TestCase('DateTime', 'DateTime,true,true,false')]
    [TestCase('Enumerator', 'Enumerator,true,true,false')]
    [TestCase('Float', 'Float,false,false,false')]
    [TestCase('Integer', 'Integer,true,true,false')]
    [TestCase('Smallint', 'Smallint,true,true,false')]
    [TestCase('Text', 'Text,true,true,false')]
    [TestCase('Time', 'Time,true,true,false')]
    [TestCase('UniqueIdentifier', 'UniqueIdentifier,true,true,false')]
    [TestCase('VarChar', 'VarChar,false,true,false')]
    procedure WhenTheFieldChangeIsNotValidForTheTypeCantRecreateTheField(const FieldName: String; const ChangeSize, ChangeScale, ChangeSpecialType: Boolean);
    [Test]
    procedure WhenChangeAFieldMustExecuteTheChangeInTheCorrectOrder;
    [Test]
    procedure TheTemporaryFieldCreatedMustBeAddedToTheDatabaseTableAndDropedFromTheTable;
    [Test]
    procedure WhenTheFieldDontExistsInTheMappingMustBeDropedFromTheTable;
    [Test]
    procedure WhenChangeTheNullablePropertyMustRecreateTheField;
    [Test]
    procedure WhenChangeTheDefaultValueMustRecreateTheField;
    [Test]
    procedure WhenChangeTheDefaultInternalFunctionValueMustRecreateTheField;
    [TestCase('Boolean', 'Boolean')]
    [TestCase('Bigint', 'Bigint')]
    [TestCase('Byte', 'Byte')]
    [TestCase('Char', 'Char')]
    [TestCase('Date', 'Date')]
    [TestCase('DateTime', 'DateTime')]
    [TestCase('DefaultField', 'DefaultField')]
    [TestCase('DefaultInternalFunction', 'DefaultInternalFunction')]
    [TestCase('Enumerator', 'Enumerator')]
    [TestCase('Float', 'Float')]
    [TestCase('Integer', 'Integer')]
    [TestCase('NullField', 'NullField')]
    [TestCase('Smallint', 'Smallint')]
    [TestCase('Text', 'Text')]
    [TestCase('Time', 'Time')]
    [TestCase('UniqueIdentifier', 'UniqueIdentifier')]
    [TestCase('VarChar', 'VarChar')]
    procedure WhenCreateTheTemporaryFieldMustLoadThePropertiesExactlySameHasTheField(const FieldName: String);
  end;

  TMyForeignKeyClass = class;
  TMyAnotherForeignKeyClass = class;

  [Index('MyIndex', 'AnotherForeignKey')]
  [Index('MyIndex2', 'AnotherForeignKey')]
  [Index('MyIndex3', 'AnotherForeignKey')]
  TMyClass = class
  private
    FAnotherForeignKey: TMyAnotherForeignKeyClass;
    FForeignKey: TMyForeignKeyClass;
    FId: String;
  published
    property AnotherForeignKey: TMyAnotherForeignKeyClass read FAnotherForeignKey write FAnotherForeignKey;
    property Id: String read FId write FId;
    property ForeignKey: TMyForeignKeyClass read FForeignKey write FForeignKey;
  end;

  TMyForeignKeyClass = class
  private
    FId: String;
  published
    property Id: String read FId write FId;
  end;

  TMyAnotherForeignKeyClass = class
  private
    FId: Integer;
  published
    property Id: Integer read FId write FId;
  end;

  TMyEnumerator = (meOne, meTwo, meThree);

  TMyClassWithAllFieldsType = class
  private
    FBigint: Int64;
    FBoolean: Boolean;
    FByte: Byte;
    FChar: Char;
    FDate: TDate;
    FDateTime: TDateTime;
    FDefaultField: String;
    FEnumerator: TMyEnumerator;
    FFloat: Double;
    FInteger: Integer;
    FSmallint: Word;
    FText: String;
    FTime: TTime;
    FUniqueIdentifier: String;
    FVarChar: String;
    FNullField: Nullable<Integer>;
    FDefaultInternalFunction: String;
  published
    property Boolean: Boolean read FBoolean write FBoolean;
    property Bigint: Int64 read FBigint write FBigint;
    property Byte: Byte read FByte write FByte;
    property Char: Char read FChar write FChar;
    property Date: TDate read FDate write FDate;
    property DateTime: TDateTime read FDateTime write FDateTime;
    [DefaultValue('abc')]
    property DefaultField: String read FDefaultField write FDefaultField;
    [DefaultValue(difNewUniqueIdentifier)]
    property DefaultInternalFunction: String read FDefaultInternalFunction write FDefaultInternalFunction;
    property Enumerator: TMyEnumerator read FEnumerator write FEnumerator;
    [FieldInfo(10, 5)]
    property Float: Double read FFloat write FFloat;
    property Integer: Integer read FInteger write FInteger;
    property NullField: Nullable<Integer> read FNullField write FNullField;
    property Smallint: Word read FSmallint write FSmallint;
    [FieldInfo(stText)]
    property Text: String read FText write FText;
    property Time: TTime read FTime write FTime;
    [FieldInfo(stUniqueIdentifier)]
    property UniqueIdentifier: String read FUniqueIdentifier write FUniqueIdentifier;
    [FieldInfo(150)]
    property VarChar: String read FVarChar write FVarChar;
  end;

implementation

uses System.Rtti, System.SysUtils, Delphi.Mock;

const
  INTERNAL_FUNCTION: array[TDatabaseInternalFunction] of String = ('', 'Now()', 'NewUnique()', 'NewId()');

{ TDatabaseMetadataUpdateTest }

procedure TDatabaseMetadataUpdateTest.CleanUpDatabaseTables;
begin
  for var Table in FDatabaseTables.Values do
    Table.Free;

  FDatabaseTables.Clear;
end;

procedure TDatabaseMetadataUpdateTest.IfTheFieldHasntAnyChangeCantRecreateTheField;
begin
  FMetadataManipulator.Expect.Never.When.DropField(It.IsAny<TDatabaseField>);

  FMetadataManipulator.Expect.Never.When.CreateField(It.IsAny<TField>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheForeignKeyExistsInDatabaseButNotExistsInTheMapperTheForeignKeyMustBeRemoved;
begin
  var DatabaseTable := FDatabaseTables['MyClass'];
  var ForeignKey := TDatabaseForeignKey.Create(DatabaseTable, 'MyForeignKey', nil);

  FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsEqualTo(ForeignKey));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheForeignKeyExistsInDatabaseButTheFieldHasADifferentNameMustRecreateTheForeignKey;
begin
  var Table := FMapper.FindTable(TMyClass);
  var DatabaseTable := FDatabaseTables['MyClass'];
  var ForeignKey := DatabaseTable.ForeignKeys.Values.ToArray[1];
  ForeignKey.Fields[0].Name := 'AnotherField';

  FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsEqualTo(ForeignKey));

  FMetadataManipulator.Expect.Once.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
begin
  var Table := FMapper.FindTable(TMyClass);

  FMetadataManipulator.Expect.Never.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[0]));

  FMetadataManipulator.Expect.Once.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[1]));

  RemoveForeignKey('MyClass', 'FK_MyClass_MyForeignKeyClass_IdForeignKey');

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheIndexDontExistsInTheMappingClassesMustBeDropped;
begin
  var DatabaseTable := FDatabaseTables['MyClass'];
  var Index := TDatabaseIndex.Create(DatabaseTable, 'MyAnotherIndex');

  FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheMapperIsntLoadedMustGetTheDefaultMapper;
begin
  FDatabaseMetadataUpdate.Mapper := nil;

  CleanUpDatabaseTables;

  Assert.AreEqual(TMapper.Default, FDatabaseMetadataUpdate.Mapper);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableDontExistsInTheDatabaseMustCreateTheTable;
begin
  FMetadataManipulator.Expect.ExecutionCount(FDatabaseTables.Count).When.CreateTable(It.IsAny<TTable>);

  CleanUpDatabaseTables;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableDontExistsInTheMappingCantDropTheForeignKeyOfIt;
begin
  var DatabaseTable := TDatabaseTable.Create('MyAnotherTable');
  var ForeignKey := TDatabaseForeignKey.Create(DatabaseTable, 'MyForeignKey', nil);

  FDatabaseTables.Add(DatabaseTable.Name, DatabaseTable);

  FMetadataManipulator.Expect.Never.When.DropForeignKey(It.IsEqualTo(ForeignKey));

  Assert.WillNotRaise(FDatabaseMetadataUpdate.UpdateDatabase);

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableExistsInTheDatabaseMustCreateTheFieldThatDontExists;
begin
  var Field: TField;
  var Table := FMapper.FindTable(TMyClass);

  Table.FindField('ForeignKey', Field);

  RemoveField('MyClass', 'IdForeignKey');

  RemoveForeignKey('MyClass', 'FK_MyClass_MyForeignKeyClass_IdForeignKey');

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(Field));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

function TDatabaseMetadataUpdateTest.LoadDatabaseTable(const Table: TTable): TDatabaseTable;
begin
  Result := TDatabaseTable.Create(Table.DatabaseName);

  for var Field in Table.Fields do
  begin
    var DatabaseField := TDatabaseField.Create(Result, Field.DatabaseName);

    DatabaseField.FieldType := Field.FieldType.TypeKind;
    DatabaseField.Nullable := Field.IsNullable;
    DatabaseField.Size := Field.Size;
    DatabaseField.Scale := Field.Scale;
    DatabaseField.SpecialType := Field.SpecialType;

    case Field.FieldType.TypeKind of
      tkEnumeration: DatabaseField.FieldType := tkInteger;
      tkUString: DatabaseField.Collation := FMapper.DefaultCollation;
    end;

    if Field.DefaultInternalFunction = difNotDefined then
      DatabaseField.DefaultValue := Field.DefaultValue.AsString
    else
      DatabaseField.DefaultValue := INTERNAL_FUNCTION[Field.DefaultInternalFunction];
  end;

  for var ForeignKey in Table.ForeignKeys do
  begin
    var DatabaseForeignKey := TDatabaseForeignKey.Create(Result, ForeignKey.DatabaseName, nil);
    DatabaseForeignKey.Fields := [Result.Fields[ForeignKey.Field.DatabaseName]];
  end;

  for var Index in Table.Indexes do
  begin
    var DatabaseIndex := TDatabaseIndex.Create(Result, Index.DatabaseName);

    for var Field in Index.Fields do
      DatabaseIndex.Fields := DatabaseIndex.Fields + [Result.Fields[Field.DatabaseName]];
  end;
end;

procedure TDatabaseMetadataUpdateTest.OnlyTheTableNoExistingTableMustCreatedInTheDataBase;
begin
  FMetadataManipulator.Expect.Never.When.CreateTable(It.IsEqualTo(FMapper.FindTable(TMyClass)));

  FMetadataManipulator.Expect.Once.When.CreateTable(It.IsEqualTo(FMapper.FindTable(TMyForeignKeyClass)));

  RemoveTable('MyForeignKeyClass');

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.RemoveField(const TableDatabaseName, FieldName: String);
begin
  var Table := FDatabaseTables[TableDatabaseName];

  Table.Fields.Remove(FieldName);
end;

procedure TDatabaseMetadataUpdateTest.RemoveForeignKey(const TableDatabaseName, ForeignKeyName: String);
begin
  var Table := FDatabaseTables[TableDatabaseName];

  Table.ForeignKeys.Remove(ForeignKeyName);
end;

procedure TDatabaseMetadataUpdateTest.RemoveIndex(const TableDatabaseName, IndexName: String);
begin
  var Table := FDatabaseTables[TableDatabaseName];

  Table.Indexes.Remove(IndexName);
end;

procedure TDatabaseMetadataUpdateTest.RemoveTable(const TableDatabaseName: String);
begin
  FDatabaseTables[TableDatabaseName].Free;

  FDatabaseTables.Remove(TableDatabaseName);
end;

procedure TDatabaseMetadataUpdateTest.Setup;
begin
  FDatabaseTables := TDictionary<String, TDatabaseTable>.Create;
  FMapper := TMapper.Create;
  FMapper.DefaultCollation := 'MyCollation';
  FMetadataManipulator := TMock.CreateInterface<IMetadataManipulator>(True);

  FDatabaseMetadataUpdate := TDatabaseMetadataUpdate.Create(FMetadataManipulator.Instance);
  FDatabaseMetadataUpdate.Mapper := FMapper;

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var Tables := Params[1].AsType<TDictionary<String, TDatabaseTable>>;

      for var Table in FDatabaseTables.Values do
        Tables.Add(Table.Name, Table);
    end).When.LoadTables(It.IsAny<TDictionary<String, TDatabaseTable>>);

  FMetadataManipulator.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Result := INTERNAL_FUNCTION[Params[1].AsType<TField>.DefaultInternalFunction];
    end).When.GetInternalFunction(It.IsAny<TField>);

  FMapper.LoadClass(TMyClass);

  FMapper.LoadClass(TMyClassWithAllFieldsType);

  for var Table in FMapper.Tables do
    FDatabaseTables.Add(Table.DatabaseName, LoadDatabaseTable(Table));
end;

procedure TDatabaseMetadataUpdateTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TDatabaseMetadataUpdateTest.TearDown;
begin
  FMetadataManipulator := nil;

  FDatabaseMetadataUpdate.Free;

  FDatabaseTables.Free;

  FMapper.Free;
end;

procedure TDatabaseMetadataUpdateTest.TheIndexCanBeCreatedOnlyIfNotExistsInDatabase;
begin
  FMetadataManipulator.Expect.Never.When.CreateIndex(It.IsAny<TIndex>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.TheTemporaryFieldCreatedMustBeAddedToTheDatabaseTableAndDropedFromTheTable;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseField := DatabaseTable.Fields['VarChar'];
  DatabaseField.Size := 450;
  var TempFieldDroped := False;
  var TempFieldName := EmptyStr;

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var Field := Params[1].AsType<TField>;

      if Field.DatabaseName.StartsWith('TempField') then
        TempFieldName := Field.DatabaseName;
    end).When.CreateField(It.IsAny<TField>);

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var DatabaseField := Params[1].AsType<TDatabaseField>;

      TempFieldDroped := TempFieldDroped or (DatabaseField.Name = TempFieldName);
    end).When.DropField(It.IsAny<TDatabaseField>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.IsTrue(TempFieldDroped);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeAFieldMustExecuteTheChangeInTheCorrectOrder;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseField := DatabaseTable.Fields['VarChar'];
  DatabaseField.Size := 450;
  var Sequence := EmptyStr;

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var Field := Params[1].AsType<TField>;

      if Field.DatabaseName.StartsWith('TempField') then
        Sequence := Sequence + ';CreateTempField';

      if Field.DatabaseName = 'VarChar' then
        Sequence := Sequence + ';CreateField';
    end).When.CreateField(It.IsAny<TField>);

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var DatabaseField := Params[1].AsType<TDatabaseField>;

      if DatabaseField.Name = 'VarChar' then
        Sequence := Sequence + ';DropField';
    end).When.DropField(It.IsAny<TDatabaseField>);

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var SourceField := Params[1].AsType<TField>;
      var DestinyField := Params[2].AsType<TField>;

      if (SourceField.DatabaseName.StartsWith('TempField')) and (DestinyField.Name = 'VarChar') then
        Sequence := Sequence + ';TransferTempData';

      if (SourceField.Name = 'VarChar') and (DestinyField.DatabaseName.StartsWith('TempField')) then
        Sequence := Sequence + ';TransferFieldData';
    end).When.UpdateField(It.IsAny<TField>, It.IsAny<TField>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.AreEqual(';CreateTempField;TransferFieldData;DropField;CreateField;TransferTempData', Sequence);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheDefaultInternalFunctionValueMustRecreateTheField;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseNotDefaultField := DatabaseTable.Fields['Bigint'];
  var DatabaseDefaultField := DatabaseTable.Fields['DefaultInternalFunction'];
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
  var NotDefaultField := Table['Bigint'];
  var DefaultField := Table['DefaultInternalFunction'];

  DatabaseNotDefaultField.DefaultValue := 'abc';
  DatabaseDefaultField.DefaultValue := EmptyStr;

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotDefaultField));

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(DefaultField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseDefaultField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotDefaultField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheDefaultValueMustRecreateTheField;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseNotDefaultField := DatabaseTable.Fields['Bigint'];
  var DatabaseDefaultField := DatabaseTable.Fields['DefaultField'];
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
  var NotDefaultField := Table['Bigint'];
  var DefaultField := Table['DefaultField'];

  DatabaseNotDefaultField.DefaultValue := 'abc';
  DatabaseDefaultField.DefaultValue := EmptyStr;

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotDefaultField));

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(DefaultField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseDefaultField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotDefaultField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheNullablePropertyMustRecreateTheField;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseNotNullField := DatabaseTable.Fields['Bigint'];
  var DatabaseNullField := DatabaseTable.Fields['NullField'];
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
  var NotNullField := Table['Bigint'];
  var NullField := Table['NullField'];

  DatabaseNotNullField.Nullable := True;
  DatabaseNullField.Nullable := False;

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotNullField));

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NullField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNullField));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotNullField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenCreateTheTemporaryFieldMustLoadThePropertiesExactlySameHasTheField(const FieldName: String);
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseField := DatabaseTable.Fields[FieldName];
  DatabaseField.FieldType := tkUnknown;
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      var ParamField := Params[1].AsType<TField>;

      if ParamField.DatabaseName.StartsWith('TempField') then
      begin
        var Message := ParamField.Name;
        var TableField := Table[ParamField.Name];

        Assert.AreEqual(TableField.DefaultInternalFunction, ParamField.DefaultInternalFunction, Message);
        Assert.AreEqual(TableField.DefaultValue.AsVariant, ParamField.DefaultValue.AsVariant, Message);
        Assert.AreEqual(TableField.FieldType, ParamField.FieldType, Message);
        Assert.AreEqual(TableField.IsNullable, ParamField.IsNullable, Message);
        Assert.AreEqual(TableField.Name, ParamField.Name, Message);
        Assert.AreEqual(TableField.Scale, ParamField.Scale, Message);
        Assert.AreEqual(TableField.Size, ParamField.Size, Message);
        Assert.AreEqual(TableField.SpecialType, ParamField.SpecialType, Message);
      end
      else
        Assert.IsTrue(True);
    end).When.CreateField(It.IsAny<TField>);

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenExistsMoreThenOneIndexMustCreateAll;
begin
  RemoveIndex('MyClass', 'MyIndex');
  RemoveIndex('MyClass', 'MyIndex2');
  RemoveIndex('MyClass', 'MyIndex3');

  FMetadataManipulator.Expect.ExecutionCount(3).When.CreateIndex(It.IsAny<TIndex>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldChangeIsNotValidForTheTypeCantRecreateTheField(const FieldName: String; const ChangeSize, ChangeScale,
  ChangeSpecialType: Boolean);
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseField := DatabaseTable.Fields[FieldName];

  if ChangeSize then
    DatabaseField.Size := 450;

  if ChangeScale then
    DatabaseField.Scale := 18;

  if ChangeSpecialType then
    DatabaseField.SpecialType := stNotDefined;

  FMetadataManipulator.Expect.Never.When.CreateField(It.IsAny<TField>);

  FMetadataManipulator.Expect.Never.When.DropField(It.IsEqualTo(DatabaseField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldDontExistsInTheMappingMustBeDropedFromTheTable;
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var DatabaseField := TDatabaseField.Create(DatabaseTable, 'MyAnotherField');

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldHasChangedMustRecreateTheField(const FieldName: String; const ChangeType, ChangeSize, ChangeScale, ChangeSpecialType: Boolean);
begin
  var DatabaseTable := FDatabaseTables['MyClassWithAllFieldsType'];
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);

  var DatabaseField := DatabaseTable.Fields[FieldName];
  var Field := Table[FieldName];

  if ChangeType then
    DatabaseField.FieldType := tkUnknown;

  if ChangeSize then
    DatabaseField.Size := 450;

  if ChangeScale then
    DatabaseField.Scale := 18;

  if ChangeSpecialType then
    DatabaseField.SpecialType := stNotDefined;

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(Field));

  FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseField));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheIndexDontExistInDatabaseMustCreateIt;
begin
  var Table := FMapper.FindTable(TMyClass);

  RemoveIndex('MyClass', 'MyIndex');

  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheIndexExistsInDatabaseButTheFieldsAreDiffentMustRecreateTheIndex;
begin
  var DatabaseTable := FDatabaseTables['MyClass'];
  var Index := DatabaseTable.Indexes.Values.ToArray[0];
  Index.Fields[0].Name := 'AnotherField';
  var Table := FMapper.FindTable(TMyClass);

  FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));

  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheTableIsntMappedMustDropTheTable;
begin
  var DatabaseTable := TDatabaseTable.Create('NotExistsTable');

  FDatabaseTables.Add(DatabaseTable.Name, DatabaseTable);

  FMetadataManipulator.Expect.Once.When.DropTable(It.IsEqualTo(DatabaseTable));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenUpdataDeDatabaseMustLoadAllTablesFromTheDataBase;
begin
  FMetadataManipulator.Expect.Once.When.LoadTables(It.IsAny<TDictionary<String, TDatabaseTable>>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

end.

