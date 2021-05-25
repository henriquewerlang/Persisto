unit Delphi.ORM.Lazy.Loader;

interface

uses System.Rtti, Delphi.ORM.Mapper, Delphi.ORM.Lazy, Delphi.ORM.Database.Connection;

type
  TLazyLoaderImpl = class(TLazyLoader)
  private
    FConnection: IDatabaseConnection;
    FTable: TTable;
  protected
    function LoadValue: TValue; override;
  public
    constructor Create(const Connection: IDatabaseConnection; const Table: TTable; const Key: TValue);
  end;

implementation

uses Delphi.ORM.Query.Builder;

{ TLazyLoaderImpl }

constructor TLazyLoaderImpl.Create(const Connection: IDatabaseConnection; const Table: TTable; const Key: TValue);
begin
  inherited Create(Table.TypeInfo, Key);

  FConnection := Connection;
  FTable := Table;
end;

function TLazyLoaderImpl.LoadValue: TValue;
begin
  var Builder := TQueryBuilder.Create(FConnection);
  Result := Builder.Select.All.From<TObject>(FTable).Where(Field(FTable.PrimaryKey.TypeInfo.Name) = Key).Open.One;

  Builder.Free;
end;

end.

