unit Persisto.Manager.Test;

interface

uses DUnitX.TestFramework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TManagerTest = class
  private
    FManager: TManager;

    procedure PrepareDatabase;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

  [TestFixture]
  TManagerDatabaseManipulationTest = class
  private
    FManager: TManager;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenUpdateTheDatabaseCantRaiseAnyError;
    [Test]
    procedure WhenUpdateTheDatabaseMustCreateTheTablesAfterTheProcessEnd;
  end;

  [Entity]
  TMySQLiteTable = class
  private
    FId: String;
  published
    property Id: String read FId write FId;
  end;

implementation

uses Persisto.SQLite, Persisto.Connection.Firedac;

{ TManagerTest }

procedure TManagerTest.PrepareDatabase;
begin
  FManager.UpdateDatabaseSchema;
end;

procedure TManagerTest.Setup;
begin
  var Connection := TDatabaseConnectionFireDAC.Create;
  Connection.Connection.DriverName := 'SQLite';
  Connection.Connection.Params.Database := ':memory:';
  FManager := TManager.Create(Connection, TDialectSQLite.Create);

  PrepareDatabase;
end;

procedure TManagerTest.TearDown;
begin
  FManager.Free;
end;

{ TManagerDatabaseManipulationTest }

procedure TManagerDatabaseManipulationTest.Setup;
begin
  var Connection := TDatabaseConnectionFireDAC.Create;
  Connection.Connection.DriverName := 'SQLite';
  Connection.Connection.Params.Database := ':memory:';

  FManager := TManager.Create(Connection, TDialectSQLite.Create);
end;

procedure TManagerDatabaseManipulationTest.TearDown;
begin
  FManager.Free;
end;

procedure TManagerDatabaseManipulationTest.WhenUpdateTheDatabaseCantRaiseAnyError;
begin
  Assert.WillNotRaise(FManager.UpdateDatabaseSchema);
end;

procedure TManagerDatabaseManipulationTest.WhenUpdateTheDatabaseMustCreateTheTablesAfterTheProcessEnd;
begin
  FManager.UpdateDatabaseSchema;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TMySQLiteTable>.Open.All;
    end);
end;

end.

