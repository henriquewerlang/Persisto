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

  TCustomNameAttribute = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(Name: String);

    property Name: String read FName write FName;
  end;

  FieldNameAttribute = class(TCustomNameAttribute);
  TableNameAttribute = class(TCustomNameAttribute);

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

{ TCustomNameAttribute }

constructor TCustomNameAttribute.Create(Name: String);
begin
  inherited Create;

  FName := Name;
end;

end.
