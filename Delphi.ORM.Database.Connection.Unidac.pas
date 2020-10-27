unit Delphi.ORM.Database.Connection.Unidac;

interface

uses System.Rtti, Delphi.ORM.Database.Connection, Uni;

type
  TDatabaseCursorUnidac = class(TInterfacedObject, IDatabaseCursor)
  private
    FQuery: TUniQuery;

    function GetFieldValue(const FieldName: String): TValue;
  public
    constructor Create(SQL: String);

    destructor Destroy; override;
  end;

  TDatabaseConnectionFiredac = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TUniConnection;

    function OpenCursor(SQL: String): IDatabaseCursor;
  public
    destructor Destroy; override;
  end;

implementation

{ TDatabaseCursorUnidac }

constructor TDatabaseCursorUnidac.Create(SQL: String);
begin
  inherited Create;

  FQuery := TUniQuery.Create(nil);
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

{ TDatabaseConnectionFiredac }

destructor TDatabaseConnectionFiredac.Destroy;
begin
  FConnection.Free;

  inherited;
end;

function TDatabaseConnectionFiredac.OpenCursor(SQL: String): IDatabaseCursor;
begin
  Result := TDatabaseCursorUnidac.Create(SQL);
end;

end.

