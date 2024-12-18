unit Persisto.Entity.Generator.Test;

interface

uses Persisto, Persisto.Mapping, Test.Insight.Framework;

type
  [TestFixture]
  TGenerateUnitTeste = class
  private
    FManipulator: IDatabaseManipulator;
    FManager: TManager;

    procedure CompareUnitInterface(const UnitInterface: String);
    procedure CompareUnitImplementation(const UnitInterface: String; UnitImplementation: String);
    procedure GenerateUnit;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenGenerateTheUnitMustLoadTheFileWithTheTableInTheDatabaseAsExpected;
    [Test]
    procedure WhenTheDatabaseHaveMoreThanOneTableMustLoadAllTablesInTheUnit;
    [Test]
    procedure WhenTheTableHasMoreThenTwoFieldMustLoadThenAllInTheClass;
    [Test]
    procedure TheTypeOfTheDatabaseFieldMustReflectTheTypeOfThePropertyDeclaration;
    [Test]
    procedure WhenTheTableHasAForeignKeyMustFillTheFieldTypeWithTheClassType;
    [Test]
    procedure WhenFillTheFunctionToFormatNamesMustLoadTheNamesAsExpected;
    [Test]
    procedure WhenTheNameOfTheFieldIsChangedInTheFormattingFunctionMustLoadTheFieldNameAttribute;
    [Test]
    procedure WhenTheNameOfTheTableIsChangedInTheFormattingFunctionMustLoadTheTableNameAttribute;
    [Test]
    procedure WhenTheFieldIsASpecialTypeMustLoadTheFieldTypeAsExpected;
    [Test]
    procedure WhenTheFieldIsVarCharMustLoadTheSizeAttributeInTheField;
    [Test]
    procedure WhenTheFieldIsANumericTypeMustLoadThePrecisionAttributeInTheField;
    [Test]
    procedure WhenTheFieldIsAnUniqueIdentifierMustCreateTheUniqueIdentifierAttributeInTheProperty;
    [Test]
    procedure WhenTheFieldIsTextMustAddTheTextAttributeInThePropertyAndTheTypeMustBeALazyString;
    [Test]
    procedure WhenTheFieldIsBinaryMustAddTheBinaryAttributeInThePropertyAndTheTypeMustBeALazyByteArray;
    [Test]
    procedure WhenATableHasIndexesMustLoadTheIndexAttributeInTheClassWithTheNameAndFieldNames;
    [Test]
    procedure WhenTheIndexHasMoreThanOneFieldMustLoadAllFieldsInTheAttribute;
    [Test]
    procedure TheFieldOrderInTheIndexAttributeMustBeKeeped;
    [Test]
    procedure WhenCreateTheIndexAttributeMustLoadAnAttributeForEveryIndexInTheTable;
    [Test]
    procedure WhenTheIndexIsThePrimaryKeyDontNeedToCreateTheIndexAttribute;
    [Test]
    procedure WhenTheIndexIsUniqueMustCreateTheUniqueIndexAttribute;
    [Test]
    procedure WhenThePrimaryKeyFieldNameIsntIdMustLoadThePrimaryKeyAttributeInTheClass;
    [Test]
    procedure WhenComparingTheFieldNameToGenerateThePrimaryKeyAttributeMustBeCaseInsensitivity;
    [Test]
    procedure WhenTheForeignKeyIsNotNullThePropertyMustHaveTheRequiredAttribute;
    [Test]
    procedure WhenAFieldIsNullMustCreateTheStoredFunctionForTheFieldProperty;
    [Test]
    procedure WhenTheFieldIsOfStringTypeDontHaveToCreateTheStoredFunction;
    [Test]
    procedure WhenTheFieldIsOfBinaryTypeDontHaveToCreateTheStoredFunction;
    [Test]
    procedure WhenTheFieldIsOfTextTypeDontHaveToCreateTheStoredFunction;
    [Test]
    procedure WhenTheFieldTypeIfCharAnAllowNullValueMustCompareTheStoredValueWithTheNullChar;
    [Test]
    procedure WhenTheFieldTypeIfBooleanAnAllowNullValueMustCompareTheStoredValueWithTheFalse;
    [Test]
    procedure WhenGenerateTheIndexAttributeMustFormatTheIndexName;
    [Test]
    procedure WhenGenerateTheIndexAttributeMustFormatTheFieldIndexName;
  end;

implementation

uses System.SysUtils, System.IOUtils, Persisto.Test.Connection;

const
  BASE_UNIT =
  '''
  unit Entites;

  interface

  uses Persisto.Mapping;

  {$M+}

  type
  %s

  implementation
  %s
  end.

  ''';
  FILE_ENTITY = '.\Entites.pas';

{ TGenerateUnitTeste }

procedure TGenerateUnitTeste.Setup;
begin
  FManipulator := CreateDatabaseManipulator;
  FManager := TManager.Create(CreateConnection, FManipulator);

  FManager.CreateDatabase;
end;

procedure TGenerateUnitTeste.TearDown;
begin
  if TFile.Exists(FILE_ENTITY) then
    TFile.Delete(FILE_ENTITY);

  FManager.DropDatabase;

  FManager.Free;
end;

procedure TGenerateUnitTeste.TheFieldOrderInTheIndexAttributeMustBeKeeped;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('MyIndex', 'Field1;Field3;Field2')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex" on "MyTable" ("Field1", "Field3", "Field2");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.TheTypeOfTheDatabaseFieldMustReflectTheTypeOfThePropertyDeclaration;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Int64;
        FId: Int64;
      published
        property Field: Int64 read FField write FField;
        property Id: Int64 read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" bigint not null, "Id" bigint not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenGenerateTheIndexAttributeMustFormatTheFieldIndexName;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('MyIndex', 'ChangeName')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FChangeName: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        [FieldName('Field1')]
        property ChangeName: Integer read FChangeName write FChangeName;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex" on "MyTable" ("Field1");
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      if Name = 'Field1' then
        Result := 'ChangeName'
      else
        Result := Name;
    end);

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenGenerateTheIndexAttributeMustFormatTheIndexName;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('ChangeName', 'Field1')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex" on "MyTable" ("Field1");
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      if Name = 'MyIndex' then
        Result := 'ChangeName'
      else
        Result := Name;
    end);

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenGenerateTheUnitMustLoadTheFileWithTheTableInTheDatabaseAsExpected;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Integer;
        FId: Integer;
      published
        property Field: Integer read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int not null, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheDatabaseHaveMoreThanOneTableMustLoadAllTablesInTheUnit;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;
      TMyTable2 = class;
      TMyTable3 = class;

      [Entity]
      TMyTable = class
      private
        FField: Integer;
        FId: Integer;
      published
        property Field: Integer read FField write FField;
        property Id: Integer read FId write FId;
      end;

      [Entity]
      TMyTable2 = class
      private
        FField: Integer;
        FId: Integer;
      published
        property Field: Integer read FField write FField;
        property Id: Integer read FId write FId;
      end;

      [Entity]
      TMyTable3 = class
      private
        FField: Integer;
        FId: Integer;
      published
        property Field: Integer read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int not null, "Id" int not null);
      create table "MyTable2" ("Field" int not null, "Id" int not null);
      create table "MyTable3" ("Field" int not null, "Id" int not null);
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheTableHasMoreThenTwoFieldMustLoadThenAllInTheClass;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
        FId: Integer;
      published
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field1" int not null, "Field2" int not null, "Field3" int not null, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheTableHasAForeignKeyMustFillTheFieldTypeWithTheClassType;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;
      TMyTable2 = class;

      [Entity]
      TMyTable = class
      private
        FMyTable2: TMyTable2;
        FId: Integer;
      published
        property MyTable2: TMyTable2 read FMyTable2 write FMyTable2;
        property Id: Integer read FId write FId;
      end;

      [Entity]
      TMyTable2 = class
      private
        FId: Integer;
      published
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable2" ("Id" int not null, primary key ("Id"));
      create table "MyTable" ("IdMyTable2" int, "Id" int not null);
      alter table "MyTable" add constraint "FK_MyTable_MyTable2" foreign key ("IdMyTable2") references "MyTable2" ("Id");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenAFieldIsNullMustCreateTheStoredFunctionForTheFieldProperty;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Integer;
        FId: Integer;
        function GetFieldStored: Boolean;
      published
        property Field: Integer read FField write FField stored GetFieldStored;
        property Id: Integer read FId write FId;
      end;
    ''';

  var MyUnitImplementation :=
    '''
    function TMyTable.GetFieldStored: Boolean;
    begin
      Result := FField <> 0;
    end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitImplementation(MyUnitInterface, MyUnitImplementation);
end;

procedure TGenerateUnitTeste.WhenATableHasIndexesMustLoadTheIndexAttributeInTheClassWithTheNameAndFieldNames;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('MyIndex', 'Field1')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex" on "MyTable" ("Field1");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenComparingTheFieldNameToGenerateThePrimaryKeyAttributeMustBeCaseInsensitivity;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        Fid: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property id: Integer read Fid write Fid;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null, primary key ("id"));
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenCreateTheIndexAttributeMustLoadAnAttributeForEveryIndexInTheTable;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('MyIndex1', 'Field1')]
      [Index('MyIndex2', 'Field1')]
      [Index('MyIndex3', 'Field1')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex1" on "MyTable" ("Field1");
      create index "MyIndex2" on "MyTable" ("Field1");
      create index "MyIndex3" on "MyTable" ("Field1");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenFillTheFunctionToFormatNamesMustLoadTheNamesAsExpected;
begin
  var MyUnitInterface :=
    '''
      TMYTABLE = class;

      [Entity]
      TMYTABLE = class
      private
        FFIELD: Integer;
        FID: Integer;
      published
        property FIELD: Integer read FFIELD write FFIELD;
        property ID: Integer read FID write FID;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int not null, "Id" int not null)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function(Name: String): String
    begin
      Result := Name.ToUpper;
    end);

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.CompareUnitImplementation(const UnitInterface: String; UnitImplementation: String);
begin
  if not UnitImplementation.IsEmpty then
    UnitImplementation := #13#10 + UnitImplementation + #13#10;

  Assert.AreEqual(Format(BASE_UNIT, [UnitInterface, UnitImplementation]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.CompareUnitInterface(const UnitInterface: String);
begin
  CompareUnitImplementation(UnitInterface, EmptyStr);
end;

procedure TGenerateUnitTeste.GenerateUnit;
begin
  FManager.GenerateUnit(FILE_ENTITY);
end;

procedure TGenerateUnitTeste.WhenTheNameOfTheFieldIsChangedInTheFormattingFunctionMustLoadTheFieldNameAttribute;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FAnotherName: Integer;
        FId: Integer;
      published
        [FieldName('Field')]
        property AnotherName: Integer read FAnotherName write FAnotherName;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int not null, "Id" int not null)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      Result := Name;

      if Result = 'Field' then
        Result := 'AnotherName';
    end);

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheNameOfTheTableIsChangedInTheFormattingFunctionMustLoadTheTableNameAttribute;
begin
  var MyUnitInterface :=
    '''
      TAnotherName = class;

      [Entity]
      [TableName('MyTable')]
      TAnotherName = class
      private
        FField: Integer;
        FId: Integer;
      published
        property Field: Integer read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" int not null, "Id" int not null)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      Result := Name;

      if Result = 'MyTable' then
        Result := 'AnotherName';
    end);

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenThePrimaryKeyFieldNameIsntIdMustLoadThePrimaryKeyAttributeInTheClass;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [PrimaryKey('Field1')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null, primary key ("Field1"));
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsASpecialTypeMustLoadTheFieldTypeAsExpected;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: TDate;
        FId: Integer;
      published
        property Field: TDate read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" date not null, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsBinaryMustAddTheBinaryAttributeInThePropertyAndTheTypeMustBeALazyByteArray;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: Lazy<TArray<Byte>>;
      published
        [Binary]
        property Id: Lazy<TArray<Byte>> read FId write FId;
      end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Id" %s not null)
    ''',
    [FManipulator.GetSpecialFieldType(stBinary)]));

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsOfBinaryTypeDontHaveToCreateTheStoredFunction;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: Lazy<TArray<Byte>>;
      published
        [Binary]
        property Id: Lazy<TArray<Byte>> read FId write FId;
      end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Id" %s)
    ''',
    [FManipulator.GetSpecialFieldType(stBinary)]));

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsOfStringTypeDontHaveToCreateTheStoredFunction;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: String;
        FId: Integer;
      published
        [Size(150)]
        property Field: String read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" varchar(150), "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsOfTextTypeDontHaveToCreateTheStoredFunction;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: Lazy<String>;
      published
        [Text]
        property Id: Lazy<String> read FId write FId;
      end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Id" %s)
    ''',
    [FManipulator.GetSpecialFieldType(stText)]));

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsTextMustAddTheTextAttributeInThePropertyAndTheTypeMustBeALazyString;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: Lazy<String>;
      published
        [Text]
        property Id: Lazy<String> read FId write FId;
      end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Id" %s not null)
    ''',
    [FManipulator.GetSpecialFieldType(stText)]));

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsVarCharMustLoadTheSizeAttributeInTheField;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: String;
        FId: Integer;
      published
        [Size(150)]
        property Field: String read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" varchar(150) not null, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldTypeIfBooleanAnAllowNullValueMustCompareTheStoredValueWithTheFalse;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Boolean;
        FId: Integer;
        function GetFieldStored: Boolean;
      published
        property Field: Boolean read FField write FField stored GetFieldStored;
        property Id: Integer read FId write FId;
      end;
    ''';

  var MyUnitImplementation :=
    '''
    function TMyTable.GetFieldStored: Boolean;
    begin
      Result := FField <> False;
    end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Field" %s, "Id" int not null)
    ''', [FManipulator.GetSpecialFieldType(stBoolean)]));

  GenerateUnit;

  CompareUnitImplementation(MyUnitInterface, MyUnitImplementation);
end;

procedure TGenerateUnitTeste.WhenTheFieldTypeIfCharAnAllowNullValueMustCompareTheStoredValueWithTheNullChar;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Char;
        FId: Integer;
        function GetFieldStored: Boolean;
      published
        property Field: Char read FField write FField stored GetFieldStored;
        property Id: Integer read FId write FId;
      end;
    ''';

  var MyUnitImplementation :=
    '''
    function TMyTable.GetFieldStored: Boolean;
    begin
      Result := FField <> #0;
    end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" char(1), "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitImplementation(MyUnitInterface, MyUnitImplementation);
end;

procedure TGenerateUnitTeste.WhenTheForeignKeyIsNotNullThePropertyMustHaveTheRequiredAttribute;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;
      TMyTable2 = class;

      [Entity]
      TMyTable = class
      private
        FMyTable2: TMyTable2;
        FId: Integer;
      published
        [Required]
        property MyTable2: TMyTable2 read FMyTable2 write FMyTable2;
        property Id: Integer read FId write FId;
      end;

      [Entity]
      TMyTable2 = class
      private
        FId: Integer;
      published
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable2" ("Id" int not null, primary key ("Id"));
      create table "MyTable" ("IdMyTable2" int not null, "Id" int not null);
      alter table "MyTable" add constraint "FK_MyTable_MyTable2" foreign key ("IdMyTable2") references "MyTable2" ("Id");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheIndexHasMoreThanOneFieldMustLoadAllFieldsInTheAttribute;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Index('MyIndex', 'Field1;Field2')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create index "MyIndex" on "MyTable" ("Field1", "Field2");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheIndexIsThePrimaryKeyDontNeedToCreateTheIndexAttribute;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null, primary key ("Id"));
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheIndexIsUniqueMustCreateTheUniqueIndexAttribute;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [UniqueIndex('MyIndex', 'Field1')]
      [Entity]
      TMyTable = class
      private
        FId: Integer;
        FField1: Integer;
        FField2: Integer;
        FField3: Integer;
      published
        property Id: Integer read FId write FId;
        property Field1: Integer read FField1 write FField1;
        property Field2: Integer read FField2 write FField2;
        property Field3: Integer read FField3 write FField3;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Id" int not null, "Field1" int not null, "Field2" int not null, "Field3" int not null);
      create unique index "MyIndex" on "MyTable" ("Field1");
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsANumericTypeMustLoadThePrecisionAttributeInTheField;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FField: Double;
        FId: Integer;
      published
        [Precision(15, 4)]
        property Field: Double read FField write FField;
        property Id: Integer read FId write FId;
      end;
    ''';

  FManager.ExectDirect(
    '''
      create table "MyTable" ("Field" numeric(15, 4) not null, "Id" int not null)
    ''');

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

procedure TGenerateUnitTeste.WhenTheFieldIsAnUniqueIdentifierMustCreateTheUniqueIdentifierAttributeInTheProperty;
begin
  var MyUnitInterface :=
    '''
      TMyTable = class;

      [Entity]
      TMyTable = class
      private
        FId: String;
      published
        [UniqueIdentifier]
        property Id: String read FId write FId;
      end;
    ''';

  FManager.ExectDirect(Format(
    '''
      create table "MyTable" ("Id" %s not null)
    ''',
    [FManipulator.GetSpecialFieldType(stUniqueIdentifier)]));

  GenerateUnit;

  CompareUnitInterface(MyUnitInterface);
end;

end.

