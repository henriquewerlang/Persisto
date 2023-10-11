unit Persisto.Test.Connection;

interface

uses System.SysUtils, Persisto;

function CreateConnection: IDatabaseConnection;
function CreateDatabaseManipulator: IDatabaseManipulator;

procedure CreateDatabase;
procedure DropDatabase;
procedure RebootDatabase;

{$IFDEF POSTGRESQL}
type
  EPostgreSQLConfigurationError = class(Exception)
  public
    constructor Create;
  end;
{$ELSEIF DEFINED(SQLSERVER)}
type
  ESQLServerConfigurationError = class(Exception)
  public
    constructor Create;
  end;
{$ENDIF}

implementation

uses
  System.IOUtils,
{$IFDEF POSTGRESQL}
  FireDAC.Phys.PG,
  Persisto.PostgreSQL,
{$ELSEIF DEFINED(SQLSERVER)}
  FireDAC.Phys.MSSQL,
  FireDAC.Stan.Consts,
  Persisto.SQLServer,
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
{$ELSEIF DEFINED(SQLSERVER)}
  Connection.Connection.DriverName := 'MSSQL';
  Connection.Connection.Params.Database := DatabaseName;
  Connection.Connection.Params.Password := GetEnvironmentVariable('SQLSERVER_PASSWORD');
  Connection.Connection.Params.UserName := GetEnvironmentVariable('SQLSERVER_USERNAME');

  Connection.Connection.Params.AddPair(S_FD_ConnParam_Common_Server, GetEnvironmentVariable('SQLSERVER_HOST'));
  Connection.Connection.Params.AddPair(S_FD_ConnParam_Common_OSAuthent, GetEnvironmentVariable('SQLSERVER_OSAUTHENTICATION'));

  if Connection.Connection.Params.UserName.IsEmpty and Connection.Connection.Params.Password.IsEmpty then
    raise ESQLServerConfigurationError.Create;
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
{$ELSEIF DEFINED(SQLSERVER)}
  Result := TDatabaseManipulatorSQLServer.Create;
{$ELSE}
  Result := TDatabaseManipulatorSQLite.Create;
{$ENDIF}
end;

procedure CreateDatabaseNamed(const DatabaseName: String);
begin
{$IFDEF POSTGRESQL}
  var Connection := CreateConnectionNamed('postgres');

  Connection.ExecuteDirect(Format('create database %s', [DatabaseName]));
{$ELSEIF DEFINED(SQLSERVER)}
  var Connection := CreateConnectionNamed('master');

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
{$ELSEIF DEFINED(SQLSERVER)}
  var Connection := CreateConnectionNamed('master');

  Connection.ExecuteDirect(Format('drop database if exists %s', [DatabaseName]));
{$ELSE}
  if TFile.Exists(FormatSQLiteDatabaseName(DatabaseName)) then
    TFile.Delete(FormatSQLiteDatabaseName(DatabaseName));
{$ENDIF}
end;

procedure DropDatabase;
begin
  try
    DropDatabaseNamed(DATABASE_NAME);
  except
  end;
end;

procedure RebootDatabase;
begin
  DropDatabase;

  CreateDatabase;
end;

{$IFDEF POSTGRESQL}
{ EPostgreSQLConfigurationError }

constructor EPostgreSQLConfigurationError.Create;
begin
  inherited Create('To the PostgreSQL connection work, you must install de ODBC driver for the version you are compiling.'#13#10'Create the environment POSTGRESQL_LIB_PATH and ' +
    'fill with the complet path of libpq.dll.'#13#10'Create the environment POSTGRESQL_USERNAME and POSTGRESQL_PASSWORD and fill with login information!');
end;
{$ELSEIF DEFINED(SQLSERVER)}
{ ESQLServerConfigurationError }

constructor ESQLServerConfigurationError.Create;
begin
  inherited Create('To the SQL Server connection work, you must create a environment SQLSERVER_HOST, SQLSERVER_USERNAME, SQLSERVER_PASSWORD and SQLSERVER_OSAUTHENTICATION and fill with login information!');
end;
{$ENDIF}

end.

