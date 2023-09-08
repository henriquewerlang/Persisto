unit Persisto.Connection.Firedac;

interface

uses Data.DB, FireDAC.Comp.Client, Persisto;

type
  TDatabaseCursorFireDAC = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TFDQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TFDConnection; const SQL: String); overload;
    constructor Create(const Connection: TFDConnection; const SQL: String; const Params: TParams); overload;

    destructor Destroy; override;
  end;

  TDatabaseTransactionFireDAC = class(TInterfacedObject, IDatabaseTransaction)
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

    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TFDConnection read FConnection;
  end;

implementation

uses FireDAC.Stan.Option, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.Intf;

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

function TDatabaseCursorFireDAC.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  var Field := FQuery.Fields[FieldIndex];

  if Field is TSQLTimeStampField then
    Result := Field.AsDateTime
  else
    Result := Field.AsVariant;
end;

function TDatabaseCursorFireDAC.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else if FQuery.Command.CommandKind in [skDelete, skInsert, skUpdate] then
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
  FConnection.FetchOptions.CursorKind := ckForwardOnly;
  FConnection.FetchOptions.Items := [];
  FConnection.FetchOptions.Mode := fmOnDemand;
  FConnection.FetchOptions.RowsetSize := 10;
  FConnection.FetchOptions.Unidirectional := True;
  FConnection.ResourceOptions.SilentMode := True;
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

function TDatabaseConnectionFireDAC.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL);
end;

function TDatabaseConnectionFireDAC.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL, Params);
end;

function TDatabaseConnectionFireDAC.StartTransaction: IDatabaseTransaction;
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

