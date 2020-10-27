unit Delphi.ORM.Database.Connection.Unidac;

interface

uses System.Rtti, Delphi.ORM.Database.Connection, Uni;

type
  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TUniQuery;

    function GetFieldValue(const FieldName: String): TValue;
  public
    constructor Create(Connection: TUniConnection; SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseConnectionUnidac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

    function OpenCursor(SQL: String): IDatabaseCursor;
  public
    constructor Create;

    destructor Destroy; override;

    property Connection: TUniConnection read FConnection;
  end;

implementation

uses SQLServerUniProvider;

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(Connection: TUniConnection; SQL: String);
begin
  inherited Create;

  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := Connection;
  FQuery.SQL.Text := SQL;

  FQuery.Open;
end;

destructor TDatabaseCursorUnidac.Destroy;
begin
  FQuery.Free;

  inherited;
end;

function TDatabaseCursorUnidac.GetFieldValue(const FieldName: String): TValue;
begin
  Result := TValue.FromVariant(FQuery.FieldByName(FieldName).AsVariant);
end;

{ TDatabaseConnectionUnidac }

constructor TDatabaseConnectionUnidac.Create;
begin
  inherited;

  FConnection := TUniConnection.Create(nil);
end;

destructor TDatabaseConnectionUnidac.Destroy;
begin
  FConnection.Free;

  inherited;
end;

function TDatabaseConnectionUnidac.OpenCursor(SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(Connection, SQL);
end;

end.

