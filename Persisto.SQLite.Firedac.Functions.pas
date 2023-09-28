unit Persisto.SQLite.Firedac.Functions;

interface

uses System.Classes, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteWrapper;

type
  TUUIDFunction = class(TSQLiteFunction)
  protected
    procedure DoCalculate(AData: TSQLiteFunctionInstance); override;
  public
    constructor Create(ALib: TSQLiteLib); override;
  end;

implementation

uses System.SysUtils;

{ TUUIDFunction }

constructor TUUIDFunction.Create(ALib: TSQLiteLib);
begin
  inherited;

  Name := 'uuid';
end;

procedure TUUIDFunction.DoCalculate(AData: TSQLiteFunctionInstance);
begin
  AData.Output.AsString := TGUID.NewGuid.ToString;
end;

initialization
  FDExtensionManager.AddExtension([TUUIDFunction]);

end.

