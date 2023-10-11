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

  TNextSequenceValueFunction = class(TSQLiteFunction)
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

{ TNextSequenceValueFunction }

constructor TNextSequenceValueFunction.Create(ALib: TSQLiteLib);
begin
  inherited;

  Args := 1;
  Name := 'next_value_for';
end;

procedure TNextSequenceValueFunction.DoCalculate(AData: TSQLiteFunctionInstance);
begin
  var SQL := TSQLiteStatement.Create(AData.Database);

  SQL.Prepare(Format('update sqlite_sequence set seq = seq + 1 where name = ''%s'' returning seq', ['PersistoDatabaseSequence', AData.Inputs[0].AsString]));

  TSQLiteColumn.Create(SQL.Columns);

  SQL.Execute;

  SQL.Fetch;

  AData.Output.AsInteger := SQL.Columns[0].AsInteger;

  SQL.Free;
end;

initialization
  FDExtensionManager.AddExtension([TNextSequenceValueFunction, TUUIDFunction]);

end.

