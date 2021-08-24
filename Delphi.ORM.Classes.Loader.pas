unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder, Delphi.ORM.Cache;

type
  TClassLoader = class
  private
    FLoadedObjects: ICache;
    FCursor: IDatabaseCursor;
    FFrom: TQueryBuilderFrom;
    FCache: ICache;

    function CreateObject(Table: TTable; const FieldIndexStart: Integer; var NewObject: Boolean): TObject;
    function GetFieldValueVariant(const Index: Integer): Variant;
    function GetPrimaryKeyFromTable(Table: TTable; const FieldIndexStart: Integer): TValue;
    function LoadClass(var NewObject: Boolean): TObject;

    procedure LoadObject(Obj: TObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);
  public
    constructor Create(Cursor: IDatabaseCursor; From: TQueryBuilderFrom);

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;

    property Cache: ICache read FCache write FCache;
  end;

implementation

uses System.Variants, System.TypInfo, System.SysConst, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy;

{ TClassLoader }

constructor TClassLoader.Create(Cursor: IDatabaseCursor; From: TQueryBuilderFrom);
begin
  inherited Create;

  FCache := TCache.Instance;
  FCursor := Cursor;
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
      Result := TValue.FromVariantNull(FieldValue);
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
  Result := CreateObject(FFrom.Join.Table, FieldIndex, NewObject);

  LoadObject(Result, FFrom.Join, FieldIndex, NewObject);
end;

procedure TClassLoader.LoadObject(Obj: TObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);

  procedure AddItemToParentArray(const ParentObject: TObject; ParentField: TField; const Item: TObject);
  begin
    var ArrayValue := ParentField.GetValue(ParentObject);

    var ArrayLength := ArrayValue.ArrayLength;

    ArrayValue.ArrayLength := Succ(ArrayLength);

    ArrayValue.ArrayElement[ArrayLength] := Item;

    ParentField.SetValue(ParentObject, ArrayValue);
  end;

begin
  for var Field in Join.Table.Fields do
    if not Field.IsJoinLink or Field.IsLazy then
    begin
      if NewObject and Assigned(Obj) then
      begin
        var FieldValue := GetFieldValueVariant(FieldIndexStart);

        if Field.IsLazy then
          GetLazyLoadingAccess(Field.TypeInfo.GetValue(Obj)).Key := TValue.FromVariantNull(FieldValue)
        else
          Field.SetValue(Obj, FieldValue);
      end;

      Inc(FieldIndexStart);
    end
    else if NewObject and Field.IsManyValueAssociation then
    begin
      var ArrayValue: TValue;

      TValue.Make(nil, Field.TypeInfo.PropertyType.Handle, ArrayValue);

      Field.SetValue(Obj, ArrayValue);
    end;

  for var Link in Join.Links do
  begin
    var NewChildObject: Boolean;

    var ForeignKeyObject := CreateObject(Link.Table, FieldIndexStart, NewChildObject);

    LoadObject(ForeignKeyObject, Link, FieldIndexStart, NewChildObject);

    if Assigned(ForeignKeyObject) then
      if NewObject and Link.Field.IsForeignKey then
      begin
        Link.Field.SetValue(Obj, ForeignKeyObject);

        if Assigned(Link.Field.ForeignKey.ManyValueAssociation) then
          AddItemToParentArray(ForeignKeyObject, Link.Field.ForeignKey.ManyValueAssociation.Field, Obj);
      end
      else if NewChildObject and Link.Field.IsManyValueAssociation then
      begin
        Link.RightField.SetValue(ForeignKeyObject, Obj);

        AddItemToParentArray(Obj, Link.Field, ForeignKeyObject);
      end;
  end;
end;

end.

