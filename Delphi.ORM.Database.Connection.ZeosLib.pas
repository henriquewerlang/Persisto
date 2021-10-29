unit Delphi.ORM.Database.Connection.ZeosLib;

interface

uses Delphi.ORM.Database.Connection, ZAbstractConnection, ZConnection, ZAbstractRODataset, ZAbstractDataset, ZDataset;

type
  TDatabaseCursorZeosLib = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TZQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TZConnection; const SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseInsertCursorZeosLib = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  TDatabaseConnectionZeosLib = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TZConnection;

    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;

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

    Result := TDatabaseInsertCursorZeosLib.Create;
  end
  else
    Result := OpenCursor(SQL.Replace(')values(', Format(')output %s values(', [OutputSQL])));
end;

function TDatabaseConnectionZeosLib.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorZeosLib.Create(Connection, SQL);
end;

{ TDatabaseInsertCursorZeosLib }

function TDatabaseInsertCursorZeosLib.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := NULL;
end;

function TDatabaseInsertCursorZeosLib.Next: Boolean;
begin
  Result := False;
end;

{ TDatabaseCursorZeosLib }

constructor TDatabaseCursorZeosLib.Create(const Connection: TZConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TZQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
end;

destructor TDatabaseCursorZeosLib.Destroy;
begin
  FQuery.Free;

  inherited;
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

end.
