unit Delphi.ORM.Database.Connection.Unidac;

interface

uses System.Rtti, Delphi.ORM.Database.Connection, Uni;

type
  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TUniQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(Connection: TUniConnection; SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseInsertCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  TDatabaseConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

    function ExecuteInsert(SQL: String; OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(SQL: String): IDatabaseCursor;

    procedure ExecuteDirect(SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TUniConnection read FConnection;
  end;

implementation

uses System.SysUtils, System.Variants, Winapi.ActiveX, SQLServerUniProvider;

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(Connection: TUniConnection; SQL: String);
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

procedure TDatabaseConnectionUnidac.ExecuteDirect(SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

function TDatabaseConnectionUnidac.ExecuteInsert(SQL: String; OutputFields: TArray<String>): IDatabaseCursor;
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

    Result := TDatabaseInsertCursorUnidac.Create;
  end
  else
  begin
    SQL := SQL.Replace(')values(', Format(')output %s values(', [OutputSQL]));

    Result := OpenCursor(SQL);
  end;
end;

function TDatabaseConnectionUnidac.OpenCursor(SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL);
end;

{ TDatabaseInsertCursorUnidac }

function TDatabaseInsertCursorUnidac.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := NULL;
end;

function TDatabaseInsertCursorUnidac.Next: Boolean;
begin
  Result := False;
end;

end.

