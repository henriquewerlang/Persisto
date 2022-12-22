unit Delphi.ORM.Database.Metadata.Test;

interface

uses System.SysUtils, System.Generics.Collections, DUnitX.TestFramework, Delphi.Mock.Intf, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Attributes,
  Delphi.ORM.Nullable;

type
  [TestFixture]
  TDatabaseMetadataUpdateTest = class
  private
    FDatabaseMetadataUpdate: TDatabaseMetadataUpdate;
    FDatabaseSchema: TDatabaseSchema;
    FMapper: TMapper;
    FMetadataManipulator: IMock<IMetadataManipulator>;
    FOnSchemaLoad: TProc;

    function LoadDatabaseTable(const Table: TTable): TDatabaseTable;

    procedure CleanUpDatabaseTables;
    procedure LoadDatabaseSchema(const Schema: TDatabaseSchema);
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
    [Test]
    procedure WhenCreateADatabaseTableMustAddItToTheSchema;
    [Test]
    procedure WhenTryToGetATableAndIsntInTheListMustReturnNil;
    [Test]
    procedure WhenTheTableIsInTheListMustReturnTheTable;
    [Test]
    procedure WhenFindAnObjectInTheListMustReturnTheObjectWhenFindByName;
    [Test]
    procedure TheComparisionOfNamesMustBeCaseInsensitive;
    [Test]
    procedure WhenFindAForeignKeyInATableMustReturnTheForeignKey;
    [Test]
    procedure WhenGetAFieldInDatabaseTableMustReturnTheFieldInTheList;
    [Test]
    procedure WhenGetAnIndexInDatabaseTableMustReturnTheIndexInTheList;
    [Test]
    procedure WhenTheFieldDoesntHaveADefaultValueAnIsRequiredMustLoadADefaultValueForTheField;
    [Test]
    procedure WhenTheFieldDoesntHaveADefaultValueAfterTheUpdateMustCleanupTheDefaultValue;
    [Test]
    procedure WhenCreatingARequiredFieldWithoutADefaultValueMustLoadADefaultValueForTheField;
    [Test]
    procedure AfterCreateTheRequiredFieldWithouDefaultValueMustCleanupTheDefaultValueUsed;
    [Test]
    procedure WhenTheFieldHasDefualtValueFilledMustCopyThisValueToTempFieldWhenRecreatingTheField;
    [Test]
    procedure WhenCreateADefaultConstraintMustLoadTheFieldPropertyWithThisValue;
    [Test]
    procedure WhenDropAnFieldMustRemoveTheDefaultConstraint;
    [Test]
    procedure WhenDropAFieldWithoutDefaultConstraintCantCallTheDropConstraintForThisField;
    [Test]
    procedure WhenCheckTheSchemaCantRaiseAnyError;
    [Test]
    procedure WhenCreateATempFieldWithDefaultConstraintMustAddThisConstraintToTheTemFieldInfo;
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

uses System.Rtti, Delphi.Mock;

const
  INTERNAL_FUNCTION: array[TDatabaseInternalFunction] of String = ('', 'Now()', 'NewUnique()', 'NewId()');

{ TDatabaseMetadataUpdateTest }

procedure TDatabaseMetadataUpdateTest.AfterCreateTheRequiredFieldWithouDefaultValueMustCleanupTheDefaultValueUsed;
begin
  var Field: TField;
  FOnSchemaLoad :=
    procedure
    begin
      RemoveField('MyClassWithAllFieldsType', 'Integer');
    end;
  var Table := FMapper.FindTable(TMyClassWithAllFieldsType);

  Table.FindField('Integer', Field);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.IsTrue(Field.DefaultValue.IsEmpty);
end;

procedure TDatabaseMetadataUpdateTest.CleanUpDatabaseTables;
begin
  for var Table in FMapper.Tables do
    RemoveTable(Table.DatabaseName);
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
  FOnSchemaLoad :=
    procedure
    begin
      var ForeignKey := TDatabaseForeignKey.Create(FDatabaseSchema.Table['MyClass'], 'MyForeignKey', nil);

      FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsEqualTo(ForeignKey));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheForeignKeyExistsInDatabaseButTheFieldHasADifferentNameMustRecreateTheForeignKey;
begin
  var ForeignKey: TDatabaseForeignKey;
  var Table := FMapper.FindTable(TMyClass);

  FOnSchemaLoad :=
    procedure
    begin
      ForeignKey := FDatabaseSchema.Table['MyClass'].ForeignKeys[0];
      ForeignKey.Fields[0].Name := 'AnotherField';

      FMetadataManipulator.Expect.Once.When.DropForeignKey(It.IsEqualTo(ForeignKey));
    end;

  FMetadataManipulator.Expect.Once.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheForeignKeyNotExistsInTheDatabaseMustBeCreated;
begin
  FOnSchemaLoad :=
    procedure
    begin
      RemoveForeignKey('MyClass', 'FK_MyClass_MyForeignKeyClass_IdForeignKey');
    end;
  var Table := FMapper.FindTable(TMyClass);

  FMetadataManipulator.Expect.Never.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[0]));

  FMetadataManipulator.Expect.Once.When.CreateForeignKey(It.IsEqualTo(Table.ForeignKeys[1]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheIndexDontExistsInTheMappingClassesMustBeDropped;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClass'];
      var Index := TDatabaseIndex.Create(DatabaseTable, 'MyAnotherIndex');

      FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheMapperIsntLoadedMustGetTheDefaultMapper;
begin
  FDatabaseMetadataUpdate.Mapper := nil;

  Assert.AreEqual(TMapper.Default, FDatabaseMetadataUpdate.Mapper);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableDontExistsInTheDatabaseMustCreateTheTable;
begin
  FMetadataManipulator.Expect.ExecutionCount(Length(FMapper.Tables)).When.CreateTable(It.IsAny<TTable>);

  FOnSchemaLoad := CleanUpDatabaseTables;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableDontExistsInTheMappingCantDropTheForeignKeyOfIt;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := TDatabaseTable.Create(FDatabaseSchema, 'MyAnotherTable');
      var ForeignKey := TDatabaseForeignKey.Create(DatabaseTable, 'MyForeignKey', nil);

      FMetadataManipulator.Expect.Never.When.DropForeignKey(It.IsEqualTo(ForeignKey));
    end;

  Assert.WillNotRaise(FDatabaseMetadataUpdate.UpdateDatabase);

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.IfTheTableExistsInTheDatabaseMustCreateTheFieldThatDontExists;
begin
  var Field: TField;
  FOnSchemaLoad :=
    procedure
    begin
      RemoveField('MyClass', 'IdForeignKey');

      RemoveForeignKey('MyClass', 'FK_MyClass_MyForeignKeyClass_IdForeignKey');
    end;
  var Table := FMapper.FindTable(TMyClass);

  Table.FindField('ForeignKey', Field);

  FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(Field));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.LoadDatabaseSchema(const Schema: TDatabaseSchema);
begin
  FDatabaseSchema := Schema;

  for var Table in FMapper.Tables do
    LoadDatabaseTable(Table);

  FOnSchemaLoad();
end;

function TDatabaseMetadataUpdateTest.LoadDatabaseTable(const Table: TTable): TDatabaseTable;
begin
  Result := TDatabaseTable.Create(FDatabaseSchema, Table.DatabaseName);

  for var Field in Table.Fields do
  begin
    var DatabaseField := TDatabaseField.Create(Result, Field.DatabaseName);

    DatabaseField.FieldType := Field.FieldType.TypeKind;
    DatabaseField.Required := Field.Required;
    DatabaseField.Size := Field.Size;
    DatabaseField.Scale := Field.Scale;
    DatabaseField.SpecialType := Field.SpecialType;

    case Field.FieldType.TypeKind of
      tkEnumeration: DatabaseField.FieldType := tkInteger;
      tkUString: DatabaseField.Collation := FMapper.DefaultCollation;
    end;

    if Field.DefaultInternalFunction <> difNotDefined then
      TDatabaseDefaultConstraint.Create(DatabaseField, 'Default', INTERNAL_FUNCTION[Field.DefaultInternalFunction])
    else if not Field.DefaultValue.IsEmpty then
      TDatabaseDefaultConstraint.Create(DatabaseField, 'Default', Field.DefaultValue.AsString);
  end;

  for var ForeignKey in Table.ForeignKeys do
  begin
    var DatabaseForeignKey := TDatabaseForeignKey.Create(Result, ForeignKey.DatabaseName, nil);
    DatabaseForeignKey.Fields := [Result.Field[ForeignKey.Field.DatabaseName]];
  end;

  for var Index in Table.Indexes do
  begin
    var DatabaseIndex := TDatabaseIndex.Create(Result, Index.DatabaseName);

    for var Field in Index.Fields do
      DatabaseIndex.Fields := DatabaseIndex.Fields + [Result.Field[Field.DatabaseName]];
  end;
end;

procedure TDatabaseMetadataUpdateTest.OnlyTheTableNoExistingTableMustCreatedInTheDataBase;
begin
  FMetadataManipulator.Expect.Never.When.CreateTable(It.IsEqualTo(FMapper.FindTable(TMyClass)));

  FMetadataManipulator.Expect.Once.When.CreateTable(It.IsEqualTo(FMapper.FindTable(TMyForeignKeyClass)));

  FOnSchemaLoad :=
    procedure
    begin
      RemoveTable('MyForeignKeyClass');
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.RemoveField(const TableDatabaseName, FieldName: String);
begin
  var Table := FDatabaseSchema.Table[TableDatabaseName];

  Table.Fields.Remove(Table.Field[FieldName]);
end;

procedure TDatabaseMetadataUpdateTest.RemoveForeignKey(const TableDatabaseName, ForeignKeyName: String);
begin
  var Table := FDatabaseSchema.Table[TableDatabaseName];

  Table.ForeignKeys.Remove(Table.ForeignKey[ForeignKeyName]);
end;

procedure TDatabaseMetadataUpdateTest.RemoveIndex(const TableDatabaseName, IndexName: String);
begin
  var Table := FDatabaseSchema.Table[TableDatabaseName];

  Table.Indexes.Remove(Table.Index[IndexName]);
end;

procedure TDatabaseMetadataUpdateTest.RemoveTable(const TableDatabaseName: String);
begin
  FDatabaseSchema.Tables.Remove(FDatabaseSchema.Table[TableDatabaseName]);
end;

procedure TDatabaseMetadataUpdateTest.Setup;
begin
  FDatabaseSchema := nil;
  FMapper := TMapper.Create;
  FMapper.DefaultCollation := 'MyCollation';
  FMetadataManipulator := TMock.CreateInterface<IMetadataManipulator>(True);

  FDatabaseMetadataUpdate := TDatabaseMetadataUpdate.Create(FMetadataManipulator.Instance);
  FDatabaseMetadataUpdate.Mapper := FMapper;

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      LoadDatabaseSchema(Params[1].AsType<TDatabaseSchema>);
    end).When.LoadSchema(It.IsAny<TDatabaseSchema>);

  FMetadataManipulator.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Result := INTERNAL_FUNCTION[Params[1].AsType<TField>.DefaultInternalFunction];
    end).When.GetInternalFunction(It.IsAny<TField>);

  FMetadataManipulator.Setup.WillReturn('Default').When.GetDefaultConstraintName(It.IsAny<TField>);

  FMapper.LoadClass(TMyClass);

  FMapper.LoadClass(TMyClassWithAllFieldsType);

  FOnSchemaLoad :=
    procedure
    begin
    end;
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

  FMapper.Free;
end;

procedure TDatabaseMetadataUpdateTest.TheComparisionOfNamesMustBeCaseInsensitive;
begin
  var MyList := TObjectList<TDatabaseNamedObject>.Create;

  MyList.Add(TDatabaseNamedObject.Create('A'));
  MyList.Add(TDatabaseNamedObject.Create('B'));
  MyList.Add(TDatabaseNamedObject.Create('C'));
  MyList.Add(TDatabaseNamedObject.Create('D'));

  var MyObject := TDatabaseNamedObject.FindObject<TDatabaseNamedObject>(MyList, 'c');

  Assert.IsNotNull(MyObject);

  Assert.AreEqual('C', MyObject.Name);

  MyList.Free;
end;

procedure TDatabaseMetadataUpdateTest.TheIndexCanBeCreatedOnlyIfNotExistsInDatabase;
begin
  FMetadataManipulator.Expect.Never.When.CreateIndex(It.IsAny<TIndex>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.TheTemporaryFieldCreatedMustBeAddedToTheDatabaseTableAndDropedFromTheTable;
begin
  var TempFieldDroped := False;

  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseField := DatabaseTable.Field['VarChar'];
      DatabaseField.Size := 450;
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
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.IsTrue(TempFieldDroped);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeAFieldMustExecuteTheChangeInTheCorrectOrder;
begin
  var Sequence := EmptyStr;

  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseField := DatabaseTable.Field['VarChar'];
      DatabaseField.Size := 450;

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
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.AreEqual(';CreateTempField;TransferFieldData;DropField;CreateField;TransferTempData', Sequence);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheDefaultInternalFunctionValueMustRecreateTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseNotDefaultField := DatabaseTable.Field['Bigint'];
      var DatabaseDefaultField := DatabaseTable.Field['DefaultInternalFunction'];
      var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
      var NotDefaultField := Table['Bigint'];
      var DefaultField := Table['DefaultInternalFunction'];

      TDatabaseDefaultConstraint.Create(DatabaseNotDefaultField, 'My Default', 'abc');

      DatabaseDefaultField.Default.Value := EmptyStr;

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotDefaultField));

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(DefaultField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseDefaultField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotDefaultField));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheDefaultValueMustRecreateTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseNotDefaultField := DatabaseTable.Field['Bigint'];
      var DatabaseDefaultField := DatabaseTable.Field['DefaultField'];
      var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
      var NotDefaultField := Table['Bigint'];
      var DefaultField := Table['DefaultField'];

      DatabaseDefaultField.Default.Value := EmptyStr;

      TDatabaseDefaultConstraint.Create(DatabaseNotDefaultField, 'My Default', 'abc');

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotDefaultField));

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(DefaultField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseDefaultField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotDefaultField));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenChangeTheNullablePropertyMustRecreateTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseNotNullField := DatabaseTable.Field['Bigint'];
      var DatabaseNullField := DatabaseTable.Field['NullField'];
      var Table := FMapper.FindTable(TMyClassWithAllFieldsType);
      var NotNullField := Table['Bigint'];
      var NullField := Table['NullField'];

      DatabaseNotNullField.Required := False;
      DatabaseNullField.Required := True;

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NotNullField));

      FMetadataManipulator.Expect.Once.When.CreateField(It.IsEqualTo(NullField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNullField));

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseNotNullField));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenCheckTheSchemaCantRaiseAnyError;
begin
  Assert.WillNotRaise(FDatabaseMetadataUpdate.UpdateDatabase);
end;

procedure TDatabaseMetadataUpdateTest.WhenCreateADatabaseTableMustAddItToTheSchema;
begin
  var Schema := TDatabaseSchema.Create;
  var Table := TDatabaseTable.Create(Schema, 'MyTable');

  Assert.AreEqual(Table, Schema.Tables.First);

  Schema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenCreateADefaultConstraintMustLoadTheFieldPropertyWithThisValue;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var Field := FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Integer'];

      TDatabaseDefaultConstraint.Create(Field, 'Name', 'Value');

      Assert.IsNotNull(Field.Default);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenCreateATempFieldWithDefaultConstraintMustAddThisConstraintToTheTemFieldInfo;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseField := DatabaseTable.Field['VarChar'];
      DatabaseField.Size := 450;

      FMetadataManipulator.Setup.WillExecute(
        procedure (const Params: TArray<TValue>)
        begin
          var Field := Params[2].AsType<TField>;

          if Field.DatabaseName.StartsWith('TempField') then
          begin
            Assert.IsNotNull(DatabaseTable.Field[Field.DatabaseName].Default);

            Assert.IsNotEmpty(DatabaseTable.Field[Field.DatabaseName].Default.Name);
          end;
        end).When.UpdateField(It.IsAny<TField>, It.IsAny<TField>);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenCreateTheTemporaryFieldMustLoadThePropertiesExactlySameHasTheField(const FieldName: String);
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseField := DatabaseTable.Field[FieldName];
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
            Assert.AreEqual(TableField.FieldType, ParamField.FieldType, Message);
            Assert.AreEqual(TableField.Name, ParamField.Name, Message);
            Assert.AreEqual(TableField.Required, ParamField.Required, Message);
            Assert.AreEqual(TableField.Scale, ParamField.Scale, Message);
            Assert.AreEqual(TableField.Size, ParamField.Size, Message);
            Assert.AreEqual(TableField.SpecialType, ParamField.SpecialType, Message);
            Assert.AreEqual(TableField.Table, ParamField.Table, Message);
          end
          else
            Assert.IsTrue(True);
        end).When.CreateField(It.IsAny<TField>);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenCreatingARequiredFieldWithoutADefaultValueMustLoadADefaultValueForTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      RemoveField('MyClassWithAllFieldsType', 'Integer');
    end;

  FMetadataManipulator.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      Assert.IsFalse(Params[1].AsType<TField>.DefaultValue.IsEmpty)
    end).When.CreateField(It.IsAny<TField>);

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenDropAFieldWithoutDefaultConstraintCantCallTheDropConstraintForThisField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];

      TDatabaseField.Create(DatabaseTable, 'AnotherField');

      FMetadataManipulator.Expect.Never.When.DropDefaultConstraint(It.IsAny<TDatabaseField>);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenDropAnFieldMustRemoveTheDefaultConstraint;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];

      var DatabaseField := TDatabaseField.Create(DatabaseTable, 'AnotherField');

      TDatabaseDefaultConstraint.Create(DatabaseField, 'MyConstraint', 'My Value');

      FMetadataManipulator.Expect.Once.When.DropDefaultConstraint(It.IsEqualTo(DatabaseField));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenExistsMoreThenOneIndexMustCreateAll;
begin
  FOnSchemaLoad :=
    procedure
    begin
      RemoveIndex('MyClass', 'MyIndex');
      RemoveIndex('MyClass', 'MyIndex2');
      RemoveIndex('MyClass', 'MyIndex3');
    end;

  FMetadataManipulator.Expect.ExecutionCount(3).When.CreateIndex(It.IsAny<TIndex>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenFindAForeignKeyInATableMustReturnTheForeignKey;
begin
  var MySchema := TDatabaseSchema.Create;
  var MyTable := TDatabaseTable.Create(MySchema, 'MyTable');

  var MyForeignKey := TDatabaseForeignKey.Create(MyTable, 'MyForeignKey', nil);

  Assert.IsNotNull(MyForeignKey);

  Assert.AreEqual(MyForeignKey, MyTable.ForeignKey[MyForeignKey.Name]);

  MySchema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenFindAnObjectInTheListMustReturnTheObjectWhenFindByName;
begin
  var MyList := TObjectList<TDatabaseNamedObject>.Create;

  MyList.Add(TDatabaseNamedObject.Create('A'));
  MyList.Add(TDatabaseNamedObject.Create('B'));
  MyList.Add(TDatabaseNamedObject.Create('C'));
  MyList.Add(TDatabaseNamedObject.Create('D'));

  var MyObject := TDatabaseNamedObject.FindObject<TDatabaseNamedObject>(MyList, 'C');

  Assert.IsNotNull(MyObject);

  Assert.AreEqual('C', MyObject.Name);

  MyList.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenGetAFieldInDatabaseTableMustReturnTheFieldInTheList;
begin
  var MySchema := TDatabaseSchema.Create;
  var MyTable := TDatabaseTable.Create(MySchema, 'MyTable');

  var MyField := TDatabaseField.Create(MyTable, 'MyField');

  Assert.IsNotNull(MyField);

  Assert.AreEqual(MyField, MyTable.Field[MyField.Name]);

  MySchema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenGetAnIndexInDatabaseTableMustReturnTheIndexInTheList;
begin
  var MySchema := TDatabaseSchema.Create;
  var MyTable := TDatabaseTable.Create(MySchema, 'MyTable');

  var MyIndex := TDatabaseIndex.Create(MyTable, 'MyIndex');

  Assert.IsNotNull(MyIndex);

  Assert.AreEqual(MyIndex, MyTable.Index[MyIndex.Name]);

  MySchema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldChangeIsNotValidForTheTypeCantRecreateTheField(const FieldName: String; const ChangeSize, ChangeScale,
  ChangeSpecialType: Boolean);
begin
  FOnSchemaLoad :=
  procedure
  begin
    var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
    var DatabaseField := DatabaseTable.Field[FieldName];

    if ChangeSize then
      DatabaseField.Size := 450;

    if ChangeScale then
      DatabaseField.Scale := 18;

    if ChangeSpecialType then
      DatabaseField.SpecialType := stNotDefined;

    FMetadataManipulator.Expect.Never.When.CreateField(It.IsAny<TField>);

    FMetadataManipulator.Expect.Never.When.DropField(It.IsEqualTo(DatabaseField));
  end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldDoesntHaveADefaultValueAfterTheUpdateMustCleanupTheDefaultValue;
begin
  FOnSchemaLoad :=
    procedure
    begin
      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['Bigint'].FieldType := tkUnknown;
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.IsTrue(FMapper.FindTable(TMyClassWithAllFieldsType).Field['Bigint'].DefaultValue.IsEmpty);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldDoesntHaveADefaultValueAnIsRequiredMustLoadADefaultValueForTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      for var Field in FDatabaseSchema.Table['MyClassWithAllFieldsType'].Fields do
        Field.FieldType := tkUnknown;

      FMetadataManipulator.Setup.WillExecute(
        procedure (const Params: TArray<TValue>)
        begin
          var Field := Params[1].AsType<TField>;

          if Field.DatabaseName.StartsWith('TempField') then
            if Field.Required then
              Assert.IsFalse(Field.DefaultValue.IsEmpty, Field.DatabaseName)
            else
              Assert.IsTrue(Field.DefaultValue.IsEmpty, Field.DatabaseName);
        end).When.CreateField(It.IsAny<TField>);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldDontExistsInTheMappingMustBeDropedFromTheTable;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
      var DatabaseField := TDatabaseField.Create(DatabaseTable, 'MyAnotherField');

      FMetadataManipulator.Expect.Once.When.DropField(It.IsEqualTo(DatabaseField));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldHasChangedMustRecreateTheField(const FieldName: String; const ChangeType, ChangeSize, ChangeScale, ChangeSpecialType: Boolean);
begin
  FOnSchemaLoad :=
  procedure
  begin
    var DatabaseTable := FDatabaseSchema.Table['MyClassWithAllFieldsType'];
    var Table := FMapper.FindTable(TMyClassWithAllFieldsType);

    var DatabaseField := DatabaseTable.Field[FieldName];
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
  end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheFieldHasDefualtValueFilledMustCopyThisValueToTempFieldWhenRecreatingTheField;
begin
  FOnSchemaLoad :=
    procedure
    begin
      FDatabaseSchema.Table['MyClassWithAllFieldsType'].Field['DefaultField'].FieldType := tkUnknown;
      var Table := FMapper.FindTable(TMyClassWithAllFieldsType);

      FMetadataManipulator.Setup.WillExecute(
        procedure (const Params: TArray<TValue>)
        begin
          var TempField := Params[1].AsType<TField>;

          if TempField.DatabaseName.StartsWith('TempField') then
            Assert.AreEqual(Table.Field['DefaultField'].DefaultValue.AsString, TempField.DefaultValue.AsString);
        end).When.CreateField(It.IsAny<TField>);
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;
end;

procedure TDatabaseMetadataUpdateTest.WhenTheIndexDontExistInDatabaseMustCreateIt;
begin
  FOnSchemaLoad :=
    procedure
    begin
      RemoveIndex('MyClass', 'MyIndex');
    end;
  var Table := FMapper.FindTable(TMyClass);

  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheIndexExistsInDatabaseButTheFieldsAreDiffentMustRecreateTheIndex;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := FDatabaseSchema.Table['MyClass'];
      var Index := DatabaseTable.Indexes[0];
      Index.Fields[0].Name := 'AnotherField';

      FMetadataManipulator.Expect.Once.When.DropIndex(It.IsEqualTo(Index));
    end;
  var Table := FMapper.FindTable(TMyClass);

  FMetadataManipulator.Expect.Once.When.CreateIndex(It.IsEqualTo(Table.Indexes[0]));

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTheTableIsInTheListMustReturnTheTable;
begin
  var MySchema := TDatabaseSchema.Create;
  var MyTable := TDatabaseTable.Create(MySchema, 'MyTable');

  Assert.AreEqual('MyTable', MyTable.Name);

  MySchema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenTheTableIsntMappedMustDropTheTable;
begin
  FOnSchemaLoad :=
    procedure
    begin
      var DatabaseTable := TDatabaseTable.Create(FDatabaseSchema, 'NotExistsTable');

      FMetadataManipulator.Expect.Once.When.DropTable(It.IsEqualTo(DatabaseTable));
    end;

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

procedure TDatabaseMetadataUpdateTest.WhenTryToGetATableAndIsntInTheListMustReturnNil;
begin
  var MySchema := TDatabaseSchema.Create;

  TDatabaseTable.Create(MySchema, 'MyTable');

  Assert.IsNull(MySchema.Table['Any Table Name']);

  MySchema.Free;
end;

procedure TDatabaseMetadataUpdateTest.WhenUpdataDeDatabaseMustLoadAllTablesFromTheDataBase;
begin
  FMetadataManipulator.Expect.Once.When.LoadSchema(It.IsAny<TDatabaseSchema>);

  FDatabaseMetadataUpdate.UpdateDatabase;

  Assert.CheckExpectation(FMetadataManipulator.CheckExpectations);
end;

end.

