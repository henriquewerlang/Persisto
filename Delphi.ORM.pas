unit Delphi.ORM;

interface

uses System.Rtti, Delphi.ORM.Database.Connection, Delphi.ORM.Query.Builder;

type
  TDelphiORM = class
  public
    constructor Create(Connection: IDatabaseConnection);

    function FindOne<T: class, constructor>(Id: TValue): T;
  end;

implementation

{ TDelphiORM }

constructor TDelphiORM.Create(Connection: IDatabaseConnection);
begin
  inherited Create;

end;

function TDelphiORM.FindOne<T>(Id: TValue): T;
begin
end;

end.

