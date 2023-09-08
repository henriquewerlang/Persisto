unit Persisto.Cursor.Mock;

interface

uses Data.DB, Persisto;

type
  TCursorMock = class(TInterfacedObject, IDatabaseCursor)
  private
    FCurrentRecord: Integer;
    FValues: TArray<TArray<Variant>>;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;

    procedure SetValues(const Value: TArray<TArray<Variant>>);
  public
    constructor Create; overload;
    constructor Create(const Values: TArray<TArray<Variant>>); overload;

    property CurrentRecord: Integer read FCurrentRecord;
    property Values: TArray<TArray<Variant>> read FValues write SetValues;
  end;

implementation

{ TCursorMock }

constructor TCursorMock.Create;
begin
  Create(nil);
end;

constructor TCursorMock.Create(const Values: TArray<TArray<Variant>>);
begin
  inherited Create;

  Self.Values := Values;
end;

function TCursorMock.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := FValues[FCurrentRecord][FieldIndex];
end;

function TCursorMock.Next: Boolean;
begin
  Inc(FCurrentRecord);

  Result := FCurrentRecord < Length(FValues);
end;

procedure TCursorMock.SetValues(const Value: TArray<TArray<Variant>>);
begin
  FCurrentRecord := -1;
  FValues := Value;
end;

end.

