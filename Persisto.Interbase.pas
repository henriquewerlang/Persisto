unit Persisto.Interbase;

interface

uses Persisto;

type
  TDatabaseManipulatorInterbase = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    function CreateDatabase(const DatabaseName: String): String;
    function DropDatabase(const DatabaseName: String): String;
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetMaxNameSize: Integer;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
  end;

implementation

uses System.SysUtils;

{ TDatabaseManipulatorInterbase }

function TDatabaseManipulatorInterbase.CreateDatabase(const DatabaseName: String): String;
begin
  Result := EmptyStr;
end;

function TDatabaseManipulatorInterbase.DropDatabase(const DatabaseName: String): String;
begin
  Result := 'drop database';
end;

function TDatabaseManipulatorInterbase.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
begin
  Result := EmptyStr;
end;

function TDatabaseManipulatorInterbase.GetFieldType(const Field: TField): String;
begin
  Result := EmptyStr;
end;

function TDatabaseManipulatorInterbase.GetMaxNameSize: Integer;
begin
  Result := 31;
end;

function TDatabaseManipulatorInterbase.GetSchemaTablesScripts: TArray<String>;
begin
  Result := nil;
end;

function TDatabaseManipulatorInterbase.GetSpecialFieldType(const Field: TField): String;
begin
  Result := EmptyStr;
end;

end.
