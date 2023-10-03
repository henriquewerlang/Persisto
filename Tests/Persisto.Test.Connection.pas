unit Persisto.Test.Connection;

interface

uses System.SysUtils, Persisto;

function CreateConnection: IDatabaseConnection;
function CreateDatabaseManipulator: IDatabaseManipulator;

procedure CreateDatabase;
procedure DropDatabase;

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

function GetSQLiteDatabaseName: String;
begin
  Result := Format('.\%s.sqlite3', [DATABASE_NAME]);
end;

procedure ConfigureSQLite(const Connection: TDatabaseConnectionFireDAC);
begin
  Connection.Connection.DriverName := 'SQLite';
  Connection.Connection.Params.Database := GetSQLiteDatabaseName;
end;

procedure ConfigurePostgreSQL(const Connection: TDatabaseConnectionFireDAC; const DatabaseName: String);
begin
{$IFDEF POSTGRESQL}
  var Driver := TFDPhysPgDriverLink.Create(nil);
  Driver.VendorLib := GetEnvironmentVariable('POSTGRESQL_LIB_PATH');

  Connection.Connection.DriverName := 'PG';
  Connection.Connection.Params.Database := DatabaseName.ToLower;
  Connection.Connection.Params.Password := GetEnvironmentVariable('POSTGRESQL_PASSWORD');
  Connection.Connection.Params.UserName := GetEnvironmentVariable('POSTGRESQL_USERNAME');

  if Driver.VendorLib.IsEmpty or Connection.Connection.Params.UserName.IsEmpty and Connection.Connection.Params.Password.IsEmpty then
    raise EPostgreSQLConfigurationError.Create;
{$ENDIF}
end;

function CreateConnectionNamed(const DatabaseName: String): IDatabaseConnection;
begin
  var Connection := TDatabaseConnectionFireDAC.Create;

{$IFDEF POSTGRESQL}
  ConfigurePostgreSQL(Connection, DatabaseName);
{$ELSE}
  ConfigureSQLite(Connection);
{$ENDIF}

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

procedure CreateDatabase;
begin
{$IFDEF POSTGRESQL}
  var Connection := CreateConnectionNamed('postgres');

  Connection.ExecuteDirect('create database ' + DATABASE_NAME);
{$ENDIF}
end;

procedure DropDatabase;
begin
{$IFDEF POSTGRESQL}
  var Connection := CreateConnectionNamed('postgres');

  Connection.ExecuteDirect(Format('drop database if exists %s with (force)', [DATABASE_NAME]));
{$ELSE}
  if TFile.Exists(GetSQLiteDatabaseName) then
    TFile.Delete(GetSQLiteDatabaseName);
{$ENDIF}
end;

{ EPostgreSQLConfigurationError }

constructor EPostgreSQLConfigurationError.Create;
begin
  inherited Create('To the PostgreSQL connection work, you must install de ODBC driver for the version you are compiling.'#13#10'Create the environment POSTGRESQL_LIB_PATH and ' +
    'fill with the complet path of libpq.dll.'#13#10'Create the environment POSTGRESQL_USERNAME and POSTGRESQL_PASSWORD and fill with login information!');
end;

end.

