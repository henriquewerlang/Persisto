unit Delphi.ORM.Database.Connection.FireDAC;

interface

uses Delphi.ORM.Database.Connection, FireDAC.Comp.Client;

type
  TDatabaseCursorFireDAC = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TFDQuery;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(const Connection: TFDConnection; const SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseEmptyCursorFireDAC = class(TInterfacedObject, IDatabaseCursor)
  private
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
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

    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TFDConnection read FConnection;
  end;

implementation

uses System.SysUtils, System.Variants, Winapi.ActiveX, FireDAC.Stan.Def, FireDAC.Stan.Option, FireDAC.DApt, FireDAC.Stan.Async, Data.DB;

{ TDatabaseCursorFireDAC }

constructor TDatabaseCursorFireDAC.Create(const Connection: TFDConnection; const SQL: String);
begin
  inherited Create;

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;
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
  else
    FQuery.Open;
  Result := not FQuery.Eof;
end;

{ TDatabaseConnectionFireDAC }

constructor TDatabaseConnectionFireDAC.Create;
begin
  inherited;

  CoInitialize(nil);

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

function TDatabaseConnectionFireDAC.ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
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

    Result := TDatabaseEmptyCursorFireDAC.Create;
  end
  else
    Result := OpenCursor(SQL.Replace(')values(', Format(')output %s values(', [OutputSQL])));
end;

function TDatabaseConnectionFireDAC.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorFireDAC.Create(Connection, SQL);
end;

function TDatabaseConnectionFireDAC.StartTransaction: IDatabaseTransaction;
begin
  Result := TDatabaseTransactionFireDAC.Create(Connection);
end;

{ TDatabaseEmptyCursorFireDAC }

function TDatabaseEmptyCursorFireDAC.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := NULL;
end;

function TDatabaseEmptyCursorFireDAC.Next: Boolean;
begin
  Result := False;
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

