unit Delphi.ORM.Register;

interface

procedure Register;

implementation

uses DesignIntf, Data.DB, System.Classes, Delphi.ORM.DataSet, Delphi.ORM.Editors;

procedure Register;
begin
  RegisterComponents('Delphi ORM', [TORMDataSet]);

  RegisterPropertyEditor(TypeInfo(String), TORMDataSet, 'ObjectClassName', TObjectClassNameProperty);

  RegisterFields([TORMObjectField]);
end;

end.
