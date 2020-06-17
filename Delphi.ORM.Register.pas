unit Delphi.ORM.Register;

interface

procedure Register;

implementation

uses System.Classes, Delphi.ORM.DataSet;

procedure Register;
begin
  RegisterComponents('Delphi ORM', [TORMDataSet]);
end;

end.
