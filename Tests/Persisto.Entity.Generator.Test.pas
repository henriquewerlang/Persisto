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
  end;

implementation

uses System.IOUtils, Persisto.Test.Connection;

const
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

procedure TGenerateUnitTeste.WhenGenerateTheUnitMustLoadTheFileWithTheTableInTheDatabaseAsExpected;
begin
  FManager.ExectDirect(
    '''
      create table MyTable (Id int, Field int)
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

  Assert.AreEqual(
    '''
    unit Entites;

    uses Persisto.Mapping;

    type
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

    implementation

    end.

    ''',
    TFile.ReadAllText(FILE_ENTITY));
end;

procedure TGenerateUnitTeste.WhenTheDatabaseHaveMoreThanOneTableMustLoadAllTablesInTheUnit;
begin
  FManager.ExectDirect(
    '''
      create table MyTable (Id int, Field int);
      create table MyTable2 (Id int, Field int);
      create table MyTable3 (Id int, Field int);
    ''');

  FManager.GenerateUnit(FILE_ENTITY);

  Assert.AreEqual(
    '''
    unit Entites;

    uses Persisto.Mapping;

    type
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

    implementation

    end.

    ''',
    TFile.ReadAllText(FILE_ENTITY));
end;

end.

