unit Delphi.ORM.Lazy.Loader;

interface

uses System.Rtti, Delphi.ORM.Mapper, Delphi.ORM.Lazy, Delphi.ORM.Database.Connection;

type
  TLazyLoader = class(TInterfacedObject, ILazyLoader)
  private
    FConnection: IDatabaseConnection;
    FKey: TValue;
    FTable: TTable;

    function GetKey: TValue;
    function GetValue: TValue;
  public
    constructor Create(const Connection: IDatabaseConnection; const Table: TTable; const Key: TValue);
  end;

implementation

uses Delphi.ORM.Query.Builder;

{ TLazyLoader }

constructor TLazyLoader.Create(const Connection: IDatabaseConnection; const Table: TTable; const Key: TValue);
begin
  inherited Create;

  FConnection := Connection;
  FKey := Key;
  FTable := Table;
end;

function TLazyLoader.GetKey: TValue;
begin
  Result := FKey;
end;

function TLazyLoader.GetValue: TValue;
begin
  if FKey.IsEmpty then
    Result := TValue.Empty
  else
  begin
    var Builder := TQueryBuilder.Create(FConnection);
    Result := Builder.Select.All.From<TObject>(FTable).Where(Field(FTable.PrimaryKey.TypeInfo.Name) = FKey).Open.One;

    Builder.Free;
  end;
end;

end.

