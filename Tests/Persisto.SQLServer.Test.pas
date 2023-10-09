unit Persisto.SQLServer.Test;

interface

uses DUnitX.TestFramework, Persisto;

type
  [TestFixture]
  TDatabaseManipulatorSQLServerTest = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

implementation

{ TDatabaseManipulatorSQLServerTest }

procedure TDatabaseManipulatorSQLServerTest.Setup;
begin

end;

procedure TDatabaseManipulatorSQLServerTest.TearDown;
begin

end;

end.

