unit Delphi.ORM.Database.Connection.Firedac;

interface

uses System.Rtti, Delphi.ORM.Database.Connection, FireDAC.Comp.Client;

type
  TDatabaseCursorFiredac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TFDQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(Connection: TFDConnection; SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseConnectionFiredac = class(TCustomDatabaseConnection, IDatabaseConnection)
  private
    FConnection: TFDConnection;

    procedure ExecuteDirect(SQL: String);
  protected
    function OpenCursor(SQL: String): IDatabaseCursor; override;
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TFDConnection read FConnection;
  end;

implementation

uses Winapi.ActiveX, FireDAC.Stan.Def, FireDAC.Stan.Option, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.DApt, FireDAC.Stan.Async, Data.DB;

{ TDatabaseCursorFiredac }

constructor TDatabaseCursorFiredac.Create(Connection: TFDConnection; SQL: String);
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

procedure TDatabaseConnectionFiredac.ExecuteDirect(SQL: String);
begin
  FConnection.ExecSQL(SQL);
end;

function TDatabaseConnectionFiredac.OpenCursor(SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFiredac.Create(Connection, SQL);
end;

end.

