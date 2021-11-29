unit Delphi.ORM.Database.Connection.Unidac;

interface

uses Delphi.ORM.Database.Connection, Uni;

type
  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TUniQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TUniConnection; const SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseEmptyCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  TDatabaseTransactionUnidac = class(TInterfacedObject, IDatabaseTransaction)
  private
    FConnection: TUniConnection;

    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const Connection: TUniConnection);
  end;

  TDatabaseConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

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

uses System.SysUtils, System.Variants, Winapi.ActiveX;

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(const Connection: TUniConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
  FQuery.UniDirectional := True;
end;

destructor TDatabaseCursorUnidac.Destroy;
begin
  FQuery.Free;

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
    FQuery.Open;

  Result := not FQuery.Eof;
end;

{ TDatabaseConnectionUnidac }

constructor TDatabaseConnectionUnidac.Create;
begin
  inherited;

  CoInitialize(nil);

  FConnection := TUniConnection.Create(nil);
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

function TDatabaseConnectionUnidac.ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
begin
  var OutputSQL := EmptyStr;

  for var Field in OutputFields do
  begin
    if not OutputSQL.IsEmpty then
      OutputSQL := ',';

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
  Result := TDatabaseCursorUnidac.Create(Connection, SQL);
end;

function TDatabaseConnectionUnidac.StartTransaction: IDatabaseTransaction;
begin
  Result := TDatabaseTransactionUnidac.Create(Connection);
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
  FConnection.Commit;
end;

constructor TDatabaseTransactionUnidac.Create(const Connection: TUniConnection);
begin
  inherited Create;

  FConnection := Connection;

  FConnection.StartTransaction;
end;

procedure TDatabaseTransactionUnidac.Rollback;
begin
  FConnection.Rollback;
end;

end.

