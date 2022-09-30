unit Delphi.ORM.Lazy.Factory;

interface

uses System.Rtti, Delphi.ORM.Lazy, Delphi.ORM.Mapper, Delphi.ORM.Cache, Delphi.ORM.Database.Connection, Delphi.ORM.Query.Builder;

type
  TLazyFactory = class(TInterfacedObject)
  private
    FCache: ICache;
    FConnection: IDatabaseConnection;
    FKeyValue: TValue;
    FLazyField: TField;

    function CreateQueryBuilder: TQueryBuilder;
    function GetKey: TValue;
  public
    constructor Create(const Connection: IDatabaseConnection; const Cache: ICache; const LazyField: TField; const KeyValue: TValue);
  end;

  TLazySingleClassFactory = class(TLazyFactory, ILazyLoader)
  private
    function LoadValue: TValue;
  end;

  TLazyManyValueClassFactory = class(TLazyFactory, ILazyLoader)
  private
    function LoadValue: TValue;
  end;

function CreateLoader(const Connection: IDatabaseConnection; const Cache: ICache; const LazyField: TField; const KeyValue: TValue): ILazyLoader;

implementation

uses System.TypInfo, Delphi.ORM.Rtti.Helper;

function CreateLoader(const Connection: IDatabaseConnection; const Cache: ICache; const LazyField: TField; const KeyValue: TValue): ILazyLoader;
begin
  if KeyValue.IsEmpty then
    Result := nil
  else if LazyField.IsManyValueAssociation then
    Result := TLazyManyValueClassFactory.Create(Connection, Cache, LazyField, KeyValue)
  else
    Result := TLazySingleClassFactory.Create(Connection, Cache, LazyField, KeyValue);
end;

{ TLazySingleClassFactory }

function TLazySingleClassFactory.LoadValue: TValue;
begin
  var AnObject: TObject := nil;
  var Table := FLazyField.ForeignKey.ParentTable;

  if FCache.Get(Table.GetCacheKey(FKeyValue.AsVariant), AnObject) then
    Result := AnObject
  else
  begin
    var Query := CreateQueryBuilder;

    try
      Result := Query.Select.All.From<TObject>(Table).Where(Field(Table.PrimaryKey.Name) = FKeyValue).Open.One;
    finally
      Query.Free;
    end;
  end;
end;

{ TLazyManyValueClassFactory }

function TLazyManyValueClassFactory.LoadValue: TValue;
begin
  var ManyValue := FLazyField.ManyValueAssociation;
  var Query := CreateQueryBuilder;

  try
    var Value := Query.Select.All.From<TObject>(ManyValue.ChildTable).Where(Field(ManyValue.ForeignKey.Field.Name) = FKeyValue).Open.All;

    TValue.Make(@Value, FLazyField.FieldType.Handle, Result);
  finally
    Query.Free;
  end;
end;

{ TLazyFactory }

constructor TLazyFactory.Create(const Connection: IDatabaseConnection; const Cache: ICache; const LazyField: TField; const KeyValue: TValue);
begin
  inherited Create;

  FCache := Cache;
  FConnection := Connection;
  FKeyValue := KeyValue;
  FLazyField := LazyField;
end;

function TLazyFactory.CreateQueryBuilder: TQueryBuilder;
begin
  Result := TQueryBuilder.Create(FConnection, FCache);

{$IF DEFINED(DEBUG) and not DEFINED(TESTINSIGHT)}
  Result.Options := [boBeautifyQuery, boJoinMapping];
{$IFEND}
end;

function TLazyFactory.GetKey: TValue;
begin
  Result := FKeyValue;
end;

end.

