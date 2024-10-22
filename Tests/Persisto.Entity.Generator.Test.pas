unit Persisto.Entity.Generator.Test;

interface

uses Persisto, Test.Insight.Framework;

type
  [TestFixture]
  TGenerateUnitTeste = class
  private
    FManager: TManager;
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
  end;

implementation

uses System.SysUtils, System.IOUtils, Persisto.Test.Connection;

const
  BASE_UNIT =
  '''
  unit Entites;

  uses Persisto.Mapping;

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
end;

procedure TGenerateUnitTeste.TearDown;
begin
  FManager.Free;

  RebootDatabase;
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
      create table MyTable (Field bigint, Id bigint)
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

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
      create table MyTable (Field int, Id int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

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
      create table MyTable (Field int, Id int);
      create table MyTable2 (Field int, Id int);
      create table MyTable3 (Field int, Id int);
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

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
      create table MyTable (Field1 int, Field2 int, Field3 int, Id int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

  Assert.AreEqual(Format(BASE_UNIT, [MyUnit]), TFile.ReadAllText(FILE_ENTITY));
end;

end.

