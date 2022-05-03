unit Delphi.ORM.Lazy.Factory;

interface

uses System.Rtti, Delphi.ORM.Lazy, Delphi.ORM.Cache, Delphi.ORM.Database.Connection;

type
  TLazyFactory = class(TInterfacedObject, ILazyFactory)
  private
    FCache: ICache;
    FConnection: IDatabaseConnection;

    function Load(const RttiType: TRttiType; const FieldName: String; const Key: TValue): TValue;
  public
    constructor Create(const Connection: IDatabaseConnection; const Cache: ICache);
  end;

implementation

uses Delphi.ORM.Query.Builder, Delphi.ORM.Mapper, Delphi.ORM.Rtti.Helper;

{ TLazyFactory }

constructor TLazyFactory.Create(const Connection: IDatabaseConnection; const Cache: ICache);
begin
  inherited Create;

  FCache := Cache;
  FConnection := Connection;
end;

function TLazyFactory.Load(const RttiType: TRttiType; const FieldName: String; const Key: TValue): TValue;
begin
  var ElementType := RttiType;
  var Query := TQueryBuilder.Create(FConnection, FCache);

  try
    if ElementType.IsArray then
      ElementType := ElementType.AsArray.ElementType;

    var Cursor := Query.Select.All.From<TObject>(TMapper.Default.FindTable(ElementType.Handle)).Where(Field(FieldName) = Key).Open;

    if RttiType.IsArray then
      Result := TValue.From(Cursor.All)
    else
      Result := Cursor.One;
  finally
    Query.Free;
  end;
end;

end.

