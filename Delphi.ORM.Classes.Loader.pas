unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder, Delphi.ORM.Cache;

type
  TClassLoader = class
  private
    FLoadedObjects: ICache;
    FConnection: IDatabaseConnection;
    FCursor: IDatabaseCursor;
    FFrom: TQueryBuilderFrom;
    FCache: ICache;

    function CreateObject(Table: TTable; const FieldIndexStart: Integer; var NewObject: Boolean): TObject;
    function GetFieldValueVariant(const Index: Integer): Variant;
    function GetPrimaryKeyFromTable(Table: TTable; const FieldIndexStart: Integer): TValue;
    function LoadClass(var NewObject: Boolean): TObject;
    function LoadClassJoin(Join: TQueryBuilderJoin; var FieldIndexStart: Integer; var NewObject: Boolean): TObject;
  public
    constructor Create(Connection: IDatabaseConnection; From: TQueryBuilderFrom);

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;

    property Cache: ICache read FCache write FCache;
  end;

implementation

uses System.Variants, System.TypInfo, System.SysConst, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy, Delphi.ORM.Lazy.Loader;

{ TClassLoader }

constructor TClassLoader.Create(Connection: IDatabaseConnection; From: TQueryBuilderFrom);
begin
  inherited Create;

  FCache := TCache.Instance;
  FConnection := Connection;
  FCursor := Connection.OpenCursor(From.Builder.GetSQL);
  FFrom := From;
  FLoadedObjects := TCache.Create;
end;

function TClassLoader.CreateObject(Table: TTable; const FieldIndexStart: Integer; var NewObject: Boolean): TObject;
begin
  var CacheValue := TValue.Empty;
  var PrimaryKeyValue := GetPrimaryKeyFromTable(Table, FieldIndexStart);

  NewObject := not PrimaryKeyValue.IsEmpty and not FLoadedObjects.Get(Table.TypeInfo, PrimaryKeyValue, CacheValue);

  if NewObject then
  begin
    if not Cache.Get(Table.TypeInfo, PrimaryKeyValue, CacheValue) then
    begin
      CacheValue := Table.TypeInfo.MetaclassType.Create;

      Cache.Add(Table.TypeInfo, PrimaryKeyValue, CacheValue);
    end;

    FLoadedObjects.Add(Table.TypeInfo, PrimaryKeyValue, CacheValue);
  end;

  Result := CacheValue.AsObject;
end;

function TClassLoader.GetFieldValueVariant(const Index: Integer): Variant;
begin
  Result := FCursor.GetFieldValue(Index);
end;

function TClassLoader.GetPrimaryKeyFromTable(Table: TTable; const FieldIndexStart: Integer): TValue;
begin
  if Assigned(Table.PrimaryKey) then
  begin
    var FieldValue := GetFieldValueVariant(FieldIndexStart);

    if not VarIsNull(FieldValue) then
      Result := TValue.FromVariant(FieldValue);
  end
  else
    Result := 'E';
end;

function TClassLoader.Load<T>: T;
begin
  var All := LoadAll<T>;
  Result := nil;

  if Assigned(All) then
    Result := All[0];
end;

function TClassLoader.LoadAll<T>: TArray<T>;
begin
  var NewObject: Boolean;
  var ObjectLoaded: TObject := nil;
  Result := nil;

  while FCursor.Next do
  begin
    ObjectLoaded := LoadClass(NewObject);

    if NewObject then
      Result := Result + [ObjectLoaded as T];
  end;
end;

function TClassLoader.LoadClass(var NewObject: Boolean): TObject;
begin
  var FieldIndex := 0;
  Result := LoadClassJoin(FFrom.Join, FieldIndex, NewObject);
end;

function TClassLoader.LoadClassJoin(Join: TQueryBuilderJoin; var FieldIndexStart: Integer; var NewObject: Boolean): TObject;
begin
  var NewChildObject: Boolean;
  Result := CreateObject(Join.Table, FieldIndexStart, NewObject);

  for var Field in Join.Table.Fields do
    if not Field.IsJoinLink or Field.IsLazy then
    begin
      if NewObject and Assigned(Result) then
      begin
        var FieldValue := GetFieldValueVariant(FieldIndexStart);

        if Field.IsLazy then
          GetLazyLoadingAccess(Field.TypeInfo.GetValue(Result)).SetLazyLoader(TLazyLoader.Create(FConnection, Field.ForeignKey.ParentTable, TValue.FromVariant(FieldValue)))
        else
          Field.SetValue(Result, FieldValue);
      end;

      Inc(FieldIndexStart);
    end;

  for var Link in Join.Links do
  begin
    var ChildPrimaryKey := EmptyStr;
    var Value: TValue;

    if Link.Field.IsForeignKey then
    begin
      Value := LoadClassJoin(Link, FieldIndexStart, NewChildObject);

      NewChildObject := NewObject;
    end
    else
    begin
      var ChildObject := LoadClassJoin(Link, FieldIndexStart, NewChildObject);

      if not NewChildObject then
        Continue
      else if Assigned(ChildObject) then
      begin
        Value := Link.Field.GetValue(Result);

        var ArrayLength := Value.ArrayLength;

        Value.ArrayLength := Succ(ArrayLength);

        Value.ArrayElement[ArrayLength] := ChildObject;

        Link.RightField.SetValue(ChildObject, Result);
      end;
    end;

    if NewChildObject and Assigned(Result) then
      Link.Field.SetValue(Result, Value);
  end;
end;

end.

