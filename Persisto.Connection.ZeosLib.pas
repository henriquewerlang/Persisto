unit Persisto.Connection.ZeosLib;

interface

uses Data.DB, Persisto, ZAbstractConnection, ZConnection, ZAbstractRODataset, ZAbstractDataset, ZDataset;

type
  TDatabaseCursorZeosLib = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TZReadOnlyQuery;

    function GetDataSet: TDataSet;
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TZConnection; const SQL: String); overload;
    constructor Create(const Connection: TZConnection; const SQL: String; const Params: TParams); overload;

    destructor Destroy; override;
  end;

  TDatabaseTransactionZeosLib = class(TInterfacedObject, IDatabaseTransaction)
  private
    FConnection: TZConnection;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TZConnection);
  end;

  TDatabaseConnectionZeosLib = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TZConnection;

    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TZConnection read FConnection;
  end;

implementation

uses System.SysUtils, System.Variants;

{ TDatabaseConnectionZeosLib }

constructor TDatabaseConnectionZeosLib.Create;
begin
  inherited;

  FConnection := TZConnection.Create(nil);
end;

destructor TDatabaseConnectionZeosLib.Destroy;
begin
  FConnection.Free;

  inherited;
end;

procedure TDatabaseConnectionZeosLib.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecuteDirect(SQL);
end;

function TDatabaseConnectionZeosLib.ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
begin
  Result := nil;
end;

function TDatabaseConnectionZeosLib.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorZeosLib.Create(Connection, SQL);
end;

function TDatabaseConnectionZeosLib.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := TDatabaseCursorZeosLib.Create(Connection, SQL, Params);
end;

function TDatabaseConnectionZeosLib.StartTransaction: IDatabaseTransaction;
begin
  Result := TDatabaseTransactionZeosLib.Create(Connection);
end;

{ TDatabaseCursorZeosLib }

constructor TDatabaseCursorZeosLib.Create(const Connection: TZConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TZReadOnlyQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.Options := FQuery.Options + [doSmartOpen];
  FQuery.SQL.Text := SQL;
end;

constructor TDatabaseCursorZeosLib.Create(const Connection: TZConnection; const SQL: String; const Params: TParams);
begin
  Create(Connection, SQL);

  FQuery.Params.Assign(Params);

  FQuery.Prepare;
end;

destructor TDatabaseCursorZeosLib.Destroy;
begin
  FQuery.Free;

  inherited;
end;

function TDatabaseCursorZeosLib.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TDatabaseCursorZeosLib.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := FQuery.Fields[FieldIndex].Value;
end;

function TDatabaseCursorZeosLib.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else
    FQuery.Open;

  Result := not FQuery.Eof;
end;

{ TDatabaseTransactionZeosLib }

procedure TDatabaseTransactionZeosLib.Commit;
begin
  FConnection.Commit;
end;

constructor TDatabaseTransactionZeosLib.Create(const Connection: TZConnection);
begin
  FConnection := Connection;

  FConnection.StartTransaction;
end;

procedure TDatabaseTransactionZeosLib.Rollback;
begin
  FConnection.Rollback;
end;

end.

