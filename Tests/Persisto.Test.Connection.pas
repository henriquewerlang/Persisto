unit Persisto.Test.Connection;

interface

uses System.SysUtils, Persisto;

function CreateConnection: IDatabaseConnection;
function CreateDatabaseManipulator: IDatabaseManipulator;

procedure CreateDatabase;
procedure DropDatabase;
procedure RebootDatabase;

type
  EPostgreSQLConfigurationError = class(Exception)
  public
    constructor Create;
  end;

implementation

uses
  System.IOUtils,
{$IFDEF POSTGRESQL}
  FireDAC.Phys.PG,
  Persisto.PostgreSQL,
{$ELSE}
  Persisto.SQLite,
  Persisto.SQLite.Firedac.Drive,
  Persisto.SQLite.Firedac.Functions,
{$ENDIF}
  Persisto.Connection.Firedac;

const
  DATABASE_NAME = 'PersistoDatabaseTest';

function FormatSQLiteDatabaseName(const DatabaseName: String): String;
begin
  Result := Format('.\%s.sqlite3', [DatabaseName]);
end;

procedure ConfigureConnection(const Connection: TDatabaseConnectionFireDAC; const DatabaseName: String);
begin
{$IFDEF POSTGRESQL}
  var Driver := TFDPhysPgDriverLink.Create(Connection.Connection);
  Driver.VendorLib := GetEnvironmentVariable('POSTGRESQL_LIB_PATH');

  Connection.Connection.DriverName := 'PG';
  Connection.Connection.Params.Database := DatabaseName.ToLower;
  Connection.Connection.Params.Password := GetEnvironmentVariable('POSTGRESQL_PASSWORD');
  Connection.Connection.Params.UserName := GetEnvironmentVariable('POSTGRESQL_USERNAME');

  if Driver.VendorLib.IsEmpty or Connection.Connection.Params.UserName.IsEmpty and Connection.Connection.Params.Password.IsEmpty then
    raise EPostgreSQLConfigurationError.Create;
{$ELSE}
  Connection.Connection.DriverName := 'SQLite';
  Connection.Connection.Params.Database := FormatSQLiteDatabaseName(DatabaseName);
{$ENDIF}
end;

function CreateConnectionNamed(const DatabaseName: String): IDatabaseConnection;
begin
  var Connection := TDatabaseConnectionFireDAC.Create;

  ConfigureConnection(Connection, DatabaseName);

  Result := Connection;
end;

function CreateConnection: IDatabaseConnection;
begin
  Result := CreateConnectionNamed(DATABASE_NAME);
end;

function CreateDatabaseManipulator: IDatabaseManipulator;
begin
{$IFDEF POSTGRESQL}
  Result := TDatabaseManipulatorPostgreSQL.Create;
{$ELSE}
  Result := TDatabaseManipulatorSQLite.Create;
{$ENDIF}
end;

procedure CreateDatabaseNamed(const DatabaseName: String);
begin
{$IFDEF POSTGRESQL}
  var Connection := CreateConnectionNamed('postgres');

  Connection.ExecuteDirect(Format('create database %s', [DatabaseName]));
{$ENDIF}
end;

procedure CreateDatabase;
begin
  CreateDatabaseNamed(DATABASE_NAME);
end;

procedure DropDatabaseNamed(const DatabaseName: String);
begin
{$IFDEF POSTGRESQL}
  var Connection := CreateConnectionNamed('postgres');

  Connection.ExecuteDirect(Format('drop database if exists %s with (force)', [DatabaseName]));
{$ELSE}
  if TFile.Exists(FormatSQLiteDatabaseName(DatabaseName)) then
    TFile.Delete(FormatSQLiteDatabaseName(DatabaseName));
{$ENDIF}
end;

procedure DropDatabase;
begin
  DropDatabaseNamed(DATABASE_NAME);
end;

procedure RebootDatabase;
begin
  DropDatabase;

  CreateDatabase;
end;

{ EPostgreSQLConfigurationError }

constructor EPostgreSQLConfigurationError.Create;
begin
  inherited Create('To the PostgreSQL connection work, you must install de ODBC driver for the version you are compiling.'#13#10'Create the environment POSTGRESQL_LIB_PATH and ' +
    'fill with the complet path of libpq.dll.'#13#10'Create the environment POSTGRESQL_USERNAME and POSTGRESQL_PASSWORD and fill with login information!');
end;

end.

