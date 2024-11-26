unit Persisto.Entity.Generator.Test;

interface

uses Persisto, Test.Insight.Framework;

type
  [TestFixture]
  TGenerateUnitTeste = class
  private
    FManager: TManager;

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

  end.

  ''';
  FILE_ENTITY = '.\Entites.pas';

{ TGenerateUnitTeste }

procedure TGenerateUnitTeste.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  FManager.CreateDatabase;
end;

procedure TGenerateUnitTeste.TearDown;
begin
  if TFile.Exists(FILE_ENTITY) then
    TFile.Delete(FILE_ENTITY);

  FManager.DropDatabase;

  FManager.Free;
end;

procedure TGenerateUnitTeste.TheTypeOfTheDatabaseFieldMustReflectTheTypeOfThePropertyDeclaration;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" bigint, "Id" bigint)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenGenerateTheUnitMustLoadTheFileWithTheTableInTheDatabaseAsExpected;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" int, "Id" int)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheDatabaseHaveMoreThanOneTableMustLoadAllTablesInTheUnit;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" int, "Id" int);
      create table "MyTable2" ("Field" int, "Id" int);
      create table "MyTable3" ("Field" int, "Id" int);
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheTableHasMoreThenTwoFieldMustLoadThenAllInTheClass;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field1" int, "Field2" int, "Field3" int, "Id" int)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheTableHasAForeignKeyMustFillTheFieldTypeWithTheClassType;
begin
  var MyUnit :=
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
      create table "MyTable2" ("Id" int, primary key ("Id"));
      create table "MyTable" ("IdMyTable2" int, "Id" int);
      alter table "MyTable" add constraint "FK_MyTable_MyTable2" foreign key ("IdMyTable2") references "MyTable2" ("Id");
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenFillTheFunctionToFormatNamesMustLoadTheNamesAsExpected;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" int, "Id" int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function(Name: String): String
    begin
      Result := Name.ToUpper;
    end);

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.GenerateUnit;
begin
  FManager.GenerateUnit(FILE_ENTITY);
end;

procedure TGenerateUnitTeste.WhenTheNameOfTheFieldIsChangedInTheFormattingFunctionMustLoadTheFieldNameAttribute;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" int, "Id" int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      Result := Name;

      if Result = 'Field' then
        Result := 'AnotherName';
    end);

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheNameOfTheTableIsChangedInTheFormattingFunctionMustLoadTheTableNameAttribute;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" int, "Id" int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY,
    function (Name: String): String
    begin
      Result := Name;

      if Result = 'MyTable' then
        Result := 'AnotherName';
    end);

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheFieldIsASpecialTypeMustLoadTheFieldTypeAsExpected;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" date, "Id" int)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheFieldIsVarCharMustLoadTheSizeAttributeInTheField;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" varchar(150), "Id" int)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheFieldIsANumericTypeMustLoadThePrecisionAttributeInTheField;
begin
  var MyUnit :=
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
      create table "MyTable" ("Field" numeric(15, 4), "Id" int)
    ''');

  GenerateUnit;

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

end.

