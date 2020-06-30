unit Delphi.ORM;

interface

uses System.Rtti, Delphi.ORM.Connection;

type
  TDelphiORM = class
  private
    FConnection: IDelphiORMConnection;
  public
    constructor Create(Connection: IDelphiORMConnection);

    function FindOne<T: class, constructor>(Id: TValue): T;
  end;

implementation

{ TDelphiORM }

constructor TDelphiORM.Create(Connection: IDelphiORMConnection);
begin
  inherited Create;

  FConnection := Connection;
end;

function TDelphiORM.FindOne<T>(Id: TValue): T;
begin
  Result := T.Create;
end;

end.
