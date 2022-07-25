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

uses System.TypInfo, Delphi.ORM.Query.Builder, Delphi.ORM.Mapper, Delphi.ORM.Rtti.Helper;

{ TLazyFactory }

constructor TLazyFactory.Create(const Connection: IDatabaseConnection; const Cache: ICache);
begin
  inherited Create;

  FCache := Cache;
  FConnection := Connection;
end;

function TLazyFactory.Load(const RttiType: TRttiType; const FieldName: String; const Key: TValue): TValue;
var
  ElementType: TRttiType;

  Query: TQueryBuilder;

  function OpenCursor: TQueryBuilderOpen<TObject>;
  begin
    Query := TQueryBuilder.Create(FConnection, FCache);

    Result := Query.Select.All.From<TObject>(TMapper.Default.FindTable(ElementType.Handle)).Where(Field(FieldName) = Key).Open;
  end;

begin
  ElementType := RttiType;
  Query := nil;

  try
    if ElementType.IsArray then
      ElementType := ElementType.AsArray.ElementType;

    if RttiType.IsArray then
      Result := TValue.From(OpenCursor.All)
    else
    begin
      var Value: TObject := nil;

      if FCache.Get(TCache.GenerateKey(RttiType, Key), Value) then
        Result := Value
      else
        Result := OpenCursor.One;
    end;
  finally
    Query.Free;
  end;
end;

end.

