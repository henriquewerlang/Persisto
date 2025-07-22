unit Persisto.Connection.Firedac;

interface

uses Data.DB, FireDAC.Comp.Client, Persisto;

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
    FConnection: TFDConnection;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TFDConnection);
  end;

  TDatabaseConnectionFireDAC = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TFDConnection;

    function GetDatabaseName: String;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: TDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
    procedure ExecuteScript(const Script: String);
    procedure SetDatabaseName(const Value: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TFDConnection read FConnection;
  end;

implementation

uses System.SysUtils, FireDAC.Stan.Option, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.Intf, FireDAC.Stan.Intf, FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands, FireDAC.UI.Intf;

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

{ TDatabaseConnectionFireDAC }

constructor TDatabaseConnectionFireDAC.Create;
begin
  inherited;

  FConnection := TFDConnection.Create(nil);
  FConnection.FormatOptions.StrsEmpty2Null := True;
  FConnection.FetchOptions.Items := [];
  FConnection.FetchOptions.Unidirectional := True;
  FConnection.ResourceOptions.SilentMode := True;
  FFDGUIxSilentMode := True;
end;

destructor TDatabaseConnectionFireDAC.Destroy;
begin
  FConnection.Free;

  inherited;
end;

procedure TDatabaseConnectionFireDAC.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

procedure TDatabaseConnectionFireDAC.ExecuteScript(const Script: String);
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

function TDatabaseConnectionFireDAC.GetDatabaseName: String;
begin
  Result := FConnection.Params.Database;
end;

function TDatabaseConnectionFireDAC.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL);
end;

function TDatabaseConnectionFireDAC.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL, Params);
end;

procedure TDatabaseConnectionFireDAC.SetDatabaseName(const Value: String);
begin
  FConnection.Params.Database := Value;
end;

function TDatabaseConnectionFireDAC.StartTransaction: TDatabaseTransaction;
begin
  Result := TDatabaseTransactionFireDAC.Create(Connection);
end;

{ TDatabaseTransactionFireDAC }

procedure TDatabaseTransactionFireDAC.Commit;
begin
  FConnection.Commit;
end;

constructor TDatabaseTransactionFireDAC.Create(const Connection: TFDConnection);
begin
  inherited Create;

  FConnection := Connection;

  FConnection.StartTransaction;
end;

procedure TDatabaseTransactionFireDAC.Rollback;
begin
  FConnection.Rollback;
end;

end.

