unit Persisto.Register;

interface

procedure Register;

implementation

uses DesignIntf, Data.DB, System.Classes, Persisto.DataSet, Persisto.Editors;

procedure Register;
begin
  RegisterComponents('Persisto', [TPersistoDataSet]);

  RegisterPropertyEditor(TypeInfo(String), TPersistoDataSet, 'ObjectClassName', TObjectClassNameProperty);

  RegisterFields([TPersistoObjectField]);
end;

end.

