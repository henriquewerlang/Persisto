unit Delphi.ORM.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Connection;

type
  [TestFixture]
  TDelphiORMTest = class
  private
    function CreateConnection: IDelphiORMConnection;
  public
    [Test]
    procedure WhenFindOneValueMustReturnTheClassLoaded;
  end;

  TMyTestClass = class
  private
    FId: Integer;
    FName: String;
  published
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
  end;

implementation

uses Delphi.ORM;

{ TDelphiORMTest }

function TDelphiORMTest.CreateConnection: IDelphiORMConnection;
begin

end;

procedure TDelphiORMTest.WhenFindOneValueMustReturnTheClassLoaded;
begin
  var ORM := TDelphiORM.Create(CreateConnection);
  var Value := ORM.FindOne<TMyTestClass>(1);

  Assert.AreEqual(1, Value.Id);
  Assert.AreEqual('Name', Value.Name);

  Value.Free;
end;

end.

