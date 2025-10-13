﻿unit Persisto.Test.Connection;

interface

uses System.SysUtils, System.Classes, Persisto;

function CreateConnection(const Owner: TComponent): IDatabaseConnection;
function CreateConnectionNamed(const Owner: TComponent; const DatabaseName: String): IDatabaseConnection;
function CreateDatabaseManipulator(const Owner: TComponent): IDatabaseManipulator;

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
  System.Types,
  System.IOUtils,
  FireDAC.Comp.Client,
  FireDAC.UI.Intf,
{$IFDEF POSTGRESQL}
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  Persisto.PostgreSQL,
{$ELSEIF DEFINED(SQLSERVER)}
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  Persisto.SQLServer,
{$ELSEIF DEFINED(INTERBASE)}
  FireDAC.Phys.IB,
  FireDAC.Phys.IBLiteDef,
  FireDAC.Phys.IBWrapper,
  Persisto.Interbase,
{$ELSE}
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  Persisto.SQLite,
  Persisto.SQLite.Firedac.Functions,
{$ENDIF}
  FireDAC.Stan.Consts,
  Persisto.Connection.Firedac;

const
  DATABASE_NAME = 'PersistoDatabaseTest';

procedure RaiseConfigurationSelectionError;
begin
  raise Exception.Create('Must select one database type in the subconfiguration!');
end;

function FormatDatabaseName(const DatabaseName: String): String;
begin
{$IF DEFINED(POSTGRESQL) or DEFINED(SQLSERVER)}
  Result := DatabaseName;
{$ELSEIF DEFINED(INTERBASE)}
  Result := Format('.\%s.ib', [DatabaseName]);
{$ELSEIF DEFINED(SQLITE)}
  Result := Format('.\%s.sqlite3', [DatabaseName]);
{$ELSE}
  RaiseConfigurationSelectionError;
{$ENDIF}
end;

function GetDeployName: String;
begin
{$IFDEF MSWINDOWS}
  {$IF DEFINED(CPUX64) or DEFINED(CPUARM64)}
  Result := S_FD_Win64;
  {$ELSE}
  Result := S_FD_Win32;
  {$ENDIF}
{$ENDIF}
{$IFDEF MACOS}
  {$IF DEFINED(CPUX64) or DEFINED(CPUARM64)}
  Result := S_FD_OSX64;
  {$ELSE}
  Result := S_FD_OSX32;
  {$ENDIF}
{$ENDIF}
{$IFDEF LINUX}
  {$IF DEFINED(CPUX64) or DEFINED(CPUARM64)}
  Result := S_FD_UIX64;
  {$ELSE}
  Result := S_FD_UIX32;
  {$ENDIF}
{$ENDIF}
{$IFDEF ANDROID}
  Result := S_FD_ANDROID;
{$ENDIF}
end;

function CreateFiredacConnection(const Owner: TComponent; const DatabaseName: String): TFDConnection;
begin
  FFDGUIxSilentMode := True;
  Result := TFDConnection.Create(Owner);
  Result.FetchOptions.Items := [];
  Result.FetchOptions.Unidirectional := True;
  Result.FormatOptions.StrsEmpty2Null := True;
  Result.ResourceOptions.SilentMode := True;

{$IFDEF POSTGRESQL}
  var Driver := TFDPhysPgDriverLink.Create(Result);
  Driver.VendorLib := GetEnvironmentVariable('POSTGRESQL_LIB_PATH');

  Result.DriverName := 'PG';

  var Configuration := Result.Params as TFDPhysPGConnectionDefParams;
  Configuration.Database := DatabaseName;
  Configuration.Password := GetEnvironmentVariable('POSTGRESQL_PASSWORD');
  Configuration.UserName := GetEnvironmentVariable('POSTGRESQL_USERNAME');
  Configuration.GUIDEndian := TEndian.Big;

  if Driver.VendorLib.IsEmpty or Result.Params.UserName.IsEmpty and Result.Params.Password.IsEmpty then
    raise EPostgreSQLConfigurationError.Create;
{$ELSEIF DEFINED(SQLSERVER)}
  Result.DriverName := 'MSSQL';

  var Configuration := Result.Params as TFDPhysMSSQLConnectionDefParams;
  Configuration.Database := DatabaseName;
  Configuration.Encrypt := False;
  Configuration.OSAuthent := GetEnvironmentVariable('SQLSERVER_OSAUTHENTICATION').ToUpper = 'YES';
  Configuration.Password := GetEnvironmentVariable('SQLSERVER_PASSWORD');
  Configuration.Server := GetEnvironmentVariable('SQLSERVER_HOST');
  Configuration.UserName := GetEnvironmentVariable('SQLSERVER_USERNAME');

  if Configuration.Server.IsEmpty or Configuration.UserName.IsEmpty and Configuration.Password.IsEmpty and not Configuration.OSAuthent then
    raise ESQLServerConfigurationError.Create;
{$ELSEIF DEFINED(INTERBASE)}
  Result.DriverName := 'IBLite';

  var Configuration := Result.Params as TFDPhysIBLiteConnectionDefParams;
  Configuration.Database := DatabaseName;
  Configuration.DropDatabase := True;
  Configuration.OpenMode := omOpenOrCreate;
  Configuration.Password := 'masterkey';
  Configuration.UserName := 'sysdba';

  if not TFile.Exists('.\ibtogo.dll') then
    TDirectory.Copy(Format('%s\%s_togo', [GetEnvironmentVariable('IBREDISTDIR'), GetDeployName]), '.\');
{$ELSEIF DEFINED(SQLITE)}
  Result.DriverName := 'SQLite';
  Result.UpdateOptions.CountUpdatedRecords := False;

  var Configuration := Result.Params as TFDPhysSQLiteConnectionDefParams;
  Configuration.Database := DatabaseName;
  Configuration.ForeignKeys := fkOn;

  if not TFile.Exists('.\sqlite3.dll') then
    TDirectory.Copy(Format('..\..\SQLite\%s', [GetDeployName]), '.\');
{$ELSE}
  RaiseConfigurationSelectionError;
{$ENDIF}
end;

function CreateConnectionNamed(const Owner: TComponent; const DatabaseName: String): IDatabaseConnection;
begin
  var Connection := TPersistoConnectionFireDAC.Create(Owner);
  Connection.Connection := CreateFiredacConnection(Owner, FormatDatabaseName(DatabaseName));

  Result := Connection;
end;

function CreateConnection(const Owner: TComponent): IDatabaseConnection;
begin
  Result := CreateConnectionNamed(Owner, DATABASE_NAME);
end;

function CreateDatabaseManipulator(const Owner: TComponent): IDatabaseManipulator;
begin
{$IFDEF POSTGRESQL}
  Result := TPersistoManipulatorPostgreSQL.Create(Owner);
{$ELSEIF DEFINED(SQLSERVER)}
  Result := TPersistoManipulatorSQLServer.Create(Owner);
{$ELSEIF DEFINED(INTERBASE)}
  Result := TPersistoManipulatorInterbase.Create(Owner);
{$ELSEIF DEFINED(SQLITE)}
  Result := TPersistoManipulatorSQLite.Create(Owner);
{$ELSE}
  RaiseConfigurationSelectionError;
{$ENDIF}
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

