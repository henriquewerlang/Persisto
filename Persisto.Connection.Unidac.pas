unit Persisto.Connection.Unidac;

interface

uses Persisto, Uni, Data.DB;

type
  TDatabaseConnectionUnidac = class;

  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TUniQuery;

    function GetDataSet: TDataSet;
    function Next: Boolean;
  public
    constructor Create(const Connection: TUniConnection; const SQL: String); overload;
    constructor Create(const Connection: TUniConnection; const SQL: String; const Params: TParams); overload;

    destructor Destroy; override;
  end;

  TDatabaseTransactionUnidac = class(TDatabaseTransaction, IDatabaseTransaction)
  private
    FConnection: TDatabaseConnectionUnidac;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TDatabaseConnectionUnidac);
  end;

  TDatabaseConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

    function OpenCursor(const SQL: String): IDatabaseCursor;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function StartTransaction: TDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TUniConnection read FConnection;
  end;

implementation

uses System.SysUtils, System.Variants, Winapi.ActiveX, DBAccess, CRAccess;

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(const Connection: TUniConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
  FQuery.UniDirectional := True;
end;

constructor TDatabaseCursorUnidac.Create(const Connection: TUniConnection; const SQL: String; const Params: TParams);
begin
  Create(Connection, SQL);

  FQuery.Params.Assign(Params);

  FQuery.Prepare;
end;

destructor TDatabaseCursorUnidac.Destroy;
begin
  FQuery.Free;

  inherited;
end;

function TDatabaseCursorUnidac.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TDatabaseCursorUnidac.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else if TDBAccessUtils.GetICommand(FQuery).ParsedSQLType = qtInsert then
    FQuery.ExecSQL
  else
    FQuery.Open;

  Result := not FQuery.Eof;
end;

{ TDatabaseConnectionUnidac }

constructor TDatabaseConnectionUnidac.Create;
begin
  inherited;

  CoInitialize(nil);

  FConnection := TUniConnection.Create(nil);
  FConnection.Options.DisconnectedMode := True;
  FConnection.Pooling := True;
  FConnection.PoolingOptions.MaxPoolSize := 500;
end;

destructor TDatabaseConnectionUnidac.Destroy;
begin
  FConnection.Free;

  inherited;
end;

procedure TDatabaseConnectionUnidac.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

function TDatabaseConnectionUnidac.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL);
end;

function TDatabaseConnectionUnidac.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL, Params);
end;

function TDatabaseConnectionUnidac.StartTransaction: TDatabaseTransaction;
begin
  Result := TDatabaseTransactionUnidac.Create(Self);
end;

{ TDatabaseTransactionUnidac }

procedure TDatabaseTransactionUnidac.Commit;
begin
  FConnection.FConnection.Commit;
end;

constructor TDatabaseTransactionUnidac.Create(const Connection: TDatabaseConnectionUnidac);
begin
  inherited Create;

  FConnection := Connection;

  FConnection.FConnection.StartTransaction;
end;

procedure TDatabaseTransactionUnidac.Rollback;
begin
  FConnection.FConnection.Rollback;
end;

end.

