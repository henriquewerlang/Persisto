unit Delphi.ORM.Change.Manager;

interface

uses System.Generics.Collections, Delphi.ORM.Mapper;

type
  TChange = class;

  IChangeManager = interface
    function GetChanges(const Instance: TObject): TChange;

    procedure AddInstance(Table: TTable; const Instance: TObject);

    property Changes[const Instance: TObject]: TChange read GetChanges;
  end;

  TChange = class
  private
    FChange: TDictionary<TField, String>;

    function GetChange(const Field: TField): String;
    function GetChangeCount: Integer;

    procedure SetChange(const Field: TField; const Value: String);
  public
    constructor Create;

    destructor Destroy; override;

    property Change[const Field: TField]: String read GetChange write SetChange; default;
    property ChangeCount: Integer read GetChangeCount;
  end;

  TChangeManager = class(TInterfacedObject, IChangeManager)
  private
    FChanges: TDictionary<TObject, TChange>;

    function GetChanges(const Instance: TObject): TChange;

    procedure AddInstance(Table: TTable; const Instance: TObject);

    property Changes[const Instance: TObject]: TChange read GetChanges;
  public
    constructor Create;

    destructor Destroy; override;
  end;

implementation

{ TChangeManager }

procedure TChangeManager.AddInstance(Table: TTable; const Instance: TObject);
begin
  var Changes := Changes[Instance];

  repeat
    for var Field in Table.Fields do
      if not Field.IsManyValueAssociation then
        Changes[Field] := Field.GetAsString(Instance);

    Table := Table.BaseTable;
  until not Assigned(Table);
end;

constructor TChangeManager.Create;
begin
  FChanges := TObjectDictionary<TObject, TChange>.Create([doOwnsValues]);
end;

destructor TChangeManager.Destroy;
begin
  FChanges.Free;

  inherited;
end;

function TChangeManager.GetChanges(const Instance: TObject): TChange;
begin
  if not FChanges.TryGetValue(Instance, Result) then
  begin
    Result := TChange.Create;

    FChanges.Add(Instance, Result);
  end;
end;

{ TChange }

constructor TChange.Create;
begin
  FChange := TDictionary<TField, String>.Create;
end;

destructor TChange.Destroy;
begin
  FChange.Free;

  inherited;
end;

function TChange.GetChange(const Field: TField): String;
begin
  Result := FChange[Field];
end;

function TChange.GetChangeCount: Integer;
begin
  Result := FChange.Count;
end;

procedure TChange.SetChange(const Field: TField; const Value: String);
begin
  FChange.AddOrSetValue(Field, Value);
end;

end.

