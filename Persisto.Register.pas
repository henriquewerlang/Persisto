unit Persisto.Register;

interface

procedure Register;

implementation

uses DesignIntf, Data.DB, System.Classes, Persisto.DataSet, Persisto.Editors, Persisto, Persisto.PostgreSQL, Persisto.SQLite, Persisto.SQLServer, Persisto.Interbase;

procedure Register;
begin
  RegisterComponents('Persisto', [TPersistoDataSet, TPersistoManager, TPersistoManipulatorSQLServer, TPersistoManipulatorPostgreSQL, TPersistoManipulatorSQLite, TPersistoManipulatorInterbase]);

  RegisterPropertyEditor(TypeInfo(String), TPersistoDataSet, 'ObjectClassName', TObjectClassNameProperty);

  RegisterFields([TPersistoObjectField]);
end;

end.

