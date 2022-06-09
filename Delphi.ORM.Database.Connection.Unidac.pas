unit Delphi.ORM.Database.Connection.Unidac;

interface

uses System.SysUtils, System.SyncObjs, Delphi.ORM.Database.Connection, Uni;

type
  TDatabaseConnectionUnidac = class;

  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FConnection: TDatabaseConnectionUnidac;
    FQuery: TUniQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TDatabaseConnectionUnidac; const SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseEmptyCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  TDatabaseTransactionUnidac = class(TInterfacedObject, IDatabaseTransaction)
  private
    FConnection: TDatabaseConnectionUnidac;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TDatabaseConnectionUnidac);

    destructor Destroy; override;
  end;

  TDatabaseConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;
    FReadWriteControl: IReadWriteSync;

    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TUniConnection read FConnection;
  end;

implementation

uses System.Variants, Winapi.ActiveX;

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(const Connection: TDatabaseConnectionUnidac; const SQL: String);
begin
  inherited Create;

  FConnection := Connection;
  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FQuery.SQL.Text := SQL;
  FQuery.FetchRows := 65000;
  FQuery.UniDirectional := True;
end;

destructor TDatabaseCursorUnidac.Destroy;
begin
  try
    FQuery.Free;
  finally
    FConnection.FReadWriteControl.EndWrite;
  end;

  inherited;
end;

function TDatabaseCursorUnidac.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := FQuery.Fields[FieldIndex].AsVariant;
end;

function TDatabaseCursorUnidac.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else
  begin
    FConnection.FReadWriteControl.BeginWrite;

    FQuery.Open;
  end;

  Result := not FQuery.Eof;
end;

{ TDatabaseConnectionUnidac }

constructor TDatabaseConnectionUnidac.Create;
begin
  inherited;

  CoInitialize(nil);

  FConnection := TUniConnection.Create(nil);
  FReadWriteControl := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TDatabaseConnectionUnidac.Destroy;
begin
  FConnection.Free;

  inherited;
end;

procedure TDatabaseConnectionUnidac.ExecuteDirect(const SQL: String);
begin
  FReadWriteControl.BeginWrite;

  try
    FConnection.ExecSQL(SQL);
  finally
    FReadWriteControl.EndWrite;
  end;
end;

function TDatabaseConnectionUnidac.ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
begin
  var OutputSQL := EmptyStr;

  for var Field in OutputFields do
  begin
    if not OutputSQL.IsEmpty then
      OutputSQL := OutputSQL + ',';

    OutputSQL := OutputSQL + Format('Inserted.%s', [Field]);
  end;

  if OutputSQL.IsEmpty then
  begin
    ExecuteDirect(SQL);

    Result := TDatabaseEmptyCursorUnidac.Create;
  end
  else
    Result := OpenCursor(SQL.Replace(')values(', Format(')output %s values(', [OutputSQL])));
end;

function TDatabaseConnectionUnidac.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Self, SQL);
end;

function TDatabaseConnectionUnidac.StartTransaction: IDatabaseTransaction;
begin
  Result := TDatabaseTransactionUnidac.Create(Self);
end;

{ TDatabaseEmptyCursorUnidac }

function TDatabaseEmptyCursorUnidac.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := NULL;
end;

function TDatabaseEmptyCursorUnidac.Next: Boolean;
begin
  Result := False;
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

  FConnection.FReadWriteControl.BeginWrite;

  FConnection.FConnection.StartTransaction;
end;

destructor TDatabaseTransactionUnidac.Destroy;
begin
  FConnection.FReadWriteControl.EndWrite;

  inherited;
end;

procedure TDatabaseTransactionUnidac.Rollback;
begin
  FConnection.FConnection.Rollback;
end;

end.

