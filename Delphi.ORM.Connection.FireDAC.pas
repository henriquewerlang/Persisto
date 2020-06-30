unit Delphi.ORM.Connection.FireDAC;

interface

uses Delphi.ORM.Connection, FireDAC.Comp.Client;

type
  TDelphiORMConnectionFireDAC = class(TInterfacedObject, IDelphiORMConnection)
  public
    constructor Create(Connection: TFDConnection);
  end;

implementation

{ TDelphiORMConnectionFiredac }

constructor TDelphiORMConnectionFireDAC.Create(Connection: TFDConnection);
begin

end;

end.
