unit Delphi.ORM.Attributes;

interface

type
  EntityAttribute = class(TCustomAttribute);

  PrimaryKeyAttribute = class(TCustomAttribute)
  private
    FFields: TArray<String>;
  public
    constructor Create(const Fields: String);

    property Fields: TArray<String> read FFields write FFields;
  end;

implementation

uses System.SysUtils;

{ PrimaryKeyAttribute }

constructor PrimaryKeyAttribute.Create(const Fields: String);
var
  A: Integer;

begin
  inherited Create;

  FFields := Fields.Split([',']);

  for A := Low(FFields) to High(FFields) do
    FFields[A] := FFields[A].Trim;
end;

end.
