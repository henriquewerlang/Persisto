unit Persisto.Interbase;

interface

uses Persisto;

type
  TDatabaseManipulatorInterbase = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
  end;

implementation

{ TDatabaseManipulatorInterbase }

function TDatabaseManipulatorInterbase.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
begin

end;

function TDatabaseManipulatorInterbase.GetFieldType(const Field: TField): String;
begin

end;

function TDatabaseManipulatorInterbase.GetSchemaTablesScripts: TArray<String>;
begin

end;

function TDatabaseManipulatorInterbase.GetSpecialFieldType(const Field: TField): String;
begin

end;

end.
