unit Delphi.ORM.Database.Connection.Firedac;

interface

uses Delphi.ORM.Database.Connection, Firedac.Comp.Client;

type
  TDatabaseCursorFiredac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TFDQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TFDConnection; const SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseInsertCursorFiredac = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  TDatabaseConnectionFiredac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TFDConnection;

    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TFDConnection read FConnection;
  end;

implementation

uses System.SysUtils, System.Variants, Winapi.ActiveX, Firedac.Stan.Def, Firedac.Stan.Option, Firedac.DApt, Firedac.Stan.Async, Data.DB;

{ TDatabaseCursorFiredac }

constructor TDatabaseCursorFiredac.Create(const Connection: TFDConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
end;

destructor TDatabaseCursorFiredac.Destroy;
begin
  FQuery.Free;

  inherited;
end;

function TDatabaseCursorFiredac.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  var Field := FQuery.Fields[FieldIndex];

  if Field is TSQLTimeStampField then
    Result := Field.AsDateTime
  else
    Result := Field.AsVariant;
end;

function TDatabaseCursorFiredac.Next: Boolean;
begin
  if FQuery.Active then
    FQuery.Next
  else
    FQuery.Open;
  Result := not FQuery.Eof;
end;

{ TDatabaseConnectionFiredac }

constructor TDatabaseConnectionFiredac.Create;
begin
  inherited;

  CoInitialize(nil);

  FConnection := TFDConnection.Create(nil);
  FConnection.FetchOptions.CursorKind := ckForwardOnly;
  FConnection.FetchOptions.Items := [];
  FConnection.FetchOptions.Mode := fmOnDemand;
  FConnection.FetchOptions.RowsetSize := 1000;
  FConnection.FetchOptions.Unidirectional := True;
  FConnection.ResourceOptions.SilentMode := True;
end;

destructor TDatabaseConnectionFiredac.Destroy;
begin
  FConnection.Free;
  inherited;
end;

procedure TDatabaseConnectionFiredac.ExecuteDirect(const SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

function TDatabaseConnectionFiredac.ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
begin
  var
  OutputSQL := EmptyStr;

  for var Field in OutputFields do
  begin
    if not OutputSQL.IsEmpty then
      OutputSQL := ',';

    OutputSQL := OutputSQL + Format('Inserted.%s', [Field]);
  end;

  if OutputSQL.IsEmpty then
  begin
    ExecuteDirect(SQL);

    Result := TDatabaseInsertCursorFiredac.Create;
  end
  else
    Result := OpenCursor(SQL.Replace(')values(', Format(')output %s values(', [OutputSQL])));
end;

function TDatabaseConnectionFiredac.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFiredac.Create(Connection, SQL);
end;

{ TDatabaseInsertCursorFiredac }

function TDatabaseInsertCursorFiredac.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := NULL;
end;

function TDatabaseInsertCursorFiredac.Next: Boolean;
begin
  Result := False;
end;

end.
