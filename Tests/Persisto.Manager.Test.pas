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
    [Test]
    procedure WhenInsertAValueInManagerMustInsertTheValueInDatabaseAsExpected;
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

implementation

uses Persisto.SQLite, Persisto.Connection.Firedac, Persisto.Test.Entity;

{ TManagerTest }

procedure TManagerTest.PrepareDatabase;
begin
  FManager.Mapper.GetTable(TInsertTest);

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

procedure TManagerTest.WhenInsertAValueInManagerMustInsertTheValueInDatabaseAsExpected;
begin
  FManager.Insert(TInsertTest.Create);

  var Cursor := FManager.OpenCursor('select * from InsertTest');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual('123', String(Cursor.GetFieldValue(1)));
end;

{ TManagerDatabaseManipulationTest }

procedure TManagerDatabaseManipulationTest.Setup;
begin
  var Connection := TDatabaseConnectionFireDAC.Create;
  Connection.Connection.DriverName := 'SQLiteEx';
  Connection.Connection.Params.Database := ':memory:';

  FManager := TManager.Create(Connection, TDialectSQLite.Create);

  FManager.Mapper.GetTable(TMySQLiteTable);
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
      FManager.OpenCursor('select * from MySQLiteTable').Next;
    end);
end;

end.

