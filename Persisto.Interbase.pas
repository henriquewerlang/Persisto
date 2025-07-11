﻿unit Persisto.Interbase;

interface

uses Persisto, Persisto.Mapping;

type
  TDatabaseManipulatorInterbase = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    function CreateDatabase(const DatabaseName: String): String;
    function DropDatabase(const DatabaseName: String): String;
    function GetDefaultDatabaseName: String;
    function GetDefaultValue(const Field: TField): String;
    function GetFieldType(const FieldType: TTypeKind): String;
    function GetMaxNameSize: Integer;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const SpecialType: TDatabaseSpecialType): String;
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

function TDatabaseManipulatorInterbase.GetDefaultDatabaseName: String;
begin
  Result := EmptyStr;
end;

function TDatabaseManipulatorInterbase.GetDefaultValue(const Field: TField): String;
begin
  Result := EmptyStr;
end;

function TDatabaseManipulatorInterbase.GetFieldType(const FieldType: TTypeKind): String;
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

function TDatabaseManipulatorInterbase.GetSpecialFieldType(const SpecialType: TDatabaseSpecialType): String;
begin
  Result := EmptyStr;
end;

end.
