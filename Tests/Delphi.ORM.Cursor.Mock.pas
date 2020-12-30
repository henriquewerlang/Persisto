unit Delphi.ORM.Cursor.Mock;

interface

uses Delphi.ORM.Database.Connection;

type
  TCursorMock = class(TInterfacedObject, IDatabaseCursor)
  private
    FCurrentRecord: Integer;
    FValues: TArray<TArray<Variant>>;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(Values: TArray<TArray<Variant>>);

    property CurrentRecord: Integer read FCurrentRecord;
  end;

implementation

{ TCursorMock }

constructor TCursorMock.Create(Values: TArray<TArray<Variant>>);
begin
  inherited Create;

  FCurrentRecord := -1;
  FValues := Values;
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

end.
