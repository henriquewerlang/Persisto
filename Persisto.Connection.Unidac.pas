unit Persisto.Connection.Unidac;

interface

uses Persisto, Uni, Data.DB;

type
  TPersistoConnectionUnidac = class;

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
    FConnection: TPersistoConnectionUnidac;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TPersistoConnectionUnidac);
  end;

  TPersistoConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

    function OpenCursor(const SQL: String): IDatabaseCursor;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function StartTransaction: TDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  published
    property Connection: TUniConnection read FConnection write FConnection;
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

{ TPersistoConnectionUnidac }

procedure TPersistoConnectionUnidac.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

function TPersistoConnectionUnidac.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL);
end;

function TPersistoConnectionUnidac.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL, Params);
end;

function TPersistoConnectionUnidac.StartTransaction: TDatabaseTransaction;
begin
  Result := TDatabaseTransactionUnidac.Create(Self);
end;

{ TDatabaseTransactionUnidac }

procedure TDatabaseTransactionUnidac.Commit;
begin
  FConnection.FConnection.Commit;
end;

constructor TDatabaseTransactionUnidac.Create(const Connection: TPersistoConnectionUnidac);
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

