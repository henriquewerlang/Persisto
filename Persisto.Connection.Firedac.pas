unit Persisto.Connection.Firedac;

interface

uses System.Classes, System.SysUtils, Data.DB, FireDAC.Comp.Client, Persisto;

type
  TDatabaseCursorFireDAC = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TFDQuery;

    function GetDataSet: TDataSet;
    function Next: Boolean;
  public
    constructor Create(const Connection: TFDConnection; const SQL: String); overload;
    constructor Create(const Connection: TFDConnection; const SQL: String; const Params: TParams); overload;

    destructor Destroy; override;
  end;

  TDatabaseTransactionFireDAC = class(TDatabaseTransaction, IDatabaseTransaction)
  private
    FTransaction: TFDTransaction;

    procedure FinishTransaction(const Proc: TProc);
    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TFDConnection);
  end;

  TPersistoConnectionFireDAC = class(TComponent, IDatabaseConnection)
  private
    FConnection: TFDConnection;

    function GetDatabaseName: String;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: TDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
    procedure ExecuteScript(const Script: String);
    procedure SetDatabaseName(const Value: String);
  published
    property Connection: TFDConnection read FConnection write FConnection;
  end;

implementation

uses FireDAC.Stan.Option, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.Intf, FireDAC.Stan.Intf, FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands, FireDAC.UI.Intf;

{ TDatabaseCursorFireDAC }

constructor TDatabaseCursorFireDAC.Create(const Connection: TFDConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
end;

constructor TDatabaseCursorFireDAC.Create(const Connection: TFDConnection; const SQL: String; const Params: TParams);
begin
  Create(Connection, SQL);

  FQuery.Params.Assign(Params);

  FQuery.Prepare;
end;

destructor TDatabaseCursorFireDAC.Destroy;
begin
  FQuery.Free;

  inherited;
end;

function TDatabaseCursorFireDAC.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TDatabaseCursorFireDAC.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else if (FQuery.Command.CommandKind in [skDelete, skInsert, skUpdate]) then
    if FQuery.SQL.Text.Contains(' output ') or FQuery.SQL.Text.Contains('returning ') then
    begin
      FQuery.Command.CommandKind := skSelectForLock;

      FQuery.Open;
    end
    else
      FQuery.ExecSQL
  else
    FQuery.Open;

  Result := not FQuery.Eof;
end;

{ TPersistoConnectionFireDAC }

procedure TPersistoConnectionFireDAC.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

procedure TPersistoConnectionFireDAC.ExecuteScript(const Script: String);
begin
  var DatabaseName := GetDatabaseName;
  var Executor := TFDScript.Create(nil);
  Executor.Connection := FConnection;
  Executor.ScriptOptions.BreakOnError := True;
  Executor.SQLScripts.Add.SQL.Text := Script;
  FConnection.Params.Database := EmptyStr;

  Executor.ExecuteAll;

  Executor.Free;

  FConnection.Params.Database := DatabaseName;
end;

function TPersistoConnectionFireDAC.GetDatabaseName: String;
begin
  Result := FConnection.Params.Database;
end;

function TPersistoConnectionFireDAC.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL);
end;

function TPersistoConnectionFireDAC.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL, Params);
end;

procedure TPersistoConnectionFireDAC.SetDatabaseName(const Value: String);
begin
  FConnection.Params.Database := Value;
end;

function TPersistoConnectionFireDAC.StartTransaction: TDatabaseTransaction;
begin
  Result := TDatabaseTransactionFireDAC.Create(Connection);
end;

{ TDatabaseTransactionFireDAC }

procedure TDatabaseTransactionFireDAC.Commit;
begin
  FinishTransaction(FTransaction.Commit);
end;

constructor TDatabaseTransactionFireDAC.Create(const Connection: TFDConnection);
begin
  inherited Create;

  FTransaction := TFDTransaction.Create(Connection);
  FTransaction.Connection := Connection;

  FTransaction.StartTransaction;
end;

procedure TDatabaseTransactionFireDAC.FinishTransaction(const Proc: TProc);
begin
  if Assigned(FTransaction) then
    try
      Proc();
    finally
      FreeAndNil(FTransaction);
    end;
end;

procedure TDatabaseTransactionFireDAC.Rollback;
begin
  FinishTransaction(FTransaction.Rollback);
end;

end.

