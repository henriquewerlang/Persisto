unit Persisto.Register.Firedac;

interface

procedure Register;

implementation

uses System.Classes, Persisto.Connection.Firedac;

procedure Register;
begin
  RegisterComponents('Persisto', [TPersistoConnectionFireDAC]);
end;

end.
