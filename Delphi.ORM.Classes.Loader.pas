unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder, Delphi.ORM.Cache,
  Delphi.ORM.Shared.Obj;

type
  TClassLoader = class
  private
    FCache: ICache;
    FCursor: IDatabaseCursor;
    FFrom: TQueryBuilderFrom;
    FLoadedObjects: ICache;
    FMainLoadedObject: TDictionary<IStateObject, Boolean>;

    function CreateObject(Table: TTable; const FieldIndexStart: Integer; var StateObject: IStateObject): Boolean;
    function GetFieldValueFromCursor(const Index: Integer): Variant;
    function LoadClass(var StateObject: IStateObject): Boolean;

    procedure LoadObject(const StateObject: IStateObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);
  public
    constructor Create(const Cursor: IDatabaseCursor; const From: TQueryBuilderFrom; const Cache: ICache);

    destructor Destroy; override;

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;
  end;

implementation

uses System.Variants, System.TypInfo, System.SysConst, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy;

{ TClassLoader }

constructor TClassLoader.Create(const Cursor: IDatabaseCursor; const From: TQueryBuilderFrom; const Cache: ICache);
begin
  inherited Create;

  FCache := Cache;
  FCursor := Cursor;
  FFrom := From;
  FLoadedObjects := TCache.Create;
  FMainLoadedObject := TDictionary<IStateObject, Boolean>.Create;
end;

function TClassLoader.CreateObject(Table: TTable; const FieldIndexStart: Integer; var StateObject: IStateObject): Boolean;
var
  SharedObject: ISharedObject absolute StateObject;

begin
  var PrimaryKeyValue := GetFieldValueFromCursor(FieldIndexStart);

  var CacheKey := Table.GetCacheKey(PrimaryKeyValue);

  Result := (not Assigned(Table.PrimaryKey) or not VarIsNull(PrimaryKeyValue)) and not FLoadedObjects.Get(CacheKey, SharedObject);

  if Result then
  begin
    if not FCache.Get(CacheKey, SharedObject) then
    begin
      SharedObject := TStateObject.Create(Table.ClassTypeInfo.MetaclassType.Create, False);

      FCache.Add(CacheKey, SharedObject);
    end;

    FLoadedObjects.Add(CacheKey, SharedObject);
  end;
end;

destructor TClassLoader.Destroy;
begin
  FMainLoadedObject.Free;

  inherited;
end;

function TClassLoader.GetFieldValueFromCursor(const Index: Integer): Variant;
begin
  Result := FCursor.GetFieldValue(Index);
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
  var StateObject: IStateObject := nil;
  Result := nil;

  while FCursor.Next do
  begin
    StateObject := nil;

    if LoadClass(StateObject) then
      Result := Result + [(StateObject as ISharedObject).&Object as T];
  end;
end;

function TClassLoader.LoadClass(var StateObject: IStateObject): Boolean;
begin
  var FieldIndex := 0;

  CreateObject(FFrom.Join.Table, FieldIndex, StateObject);

  Result := not FMainLoadedObject.ContainsKey(StateObject);

  if Result then
    FMainLoadedObject.Add(StateObject, False);

  LoadObject(StateObject, FFrom.Join, FieldIndex, Result);
end;

procedure TClassLoader.LoadObject(const StateObject: IStateObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);

  procedure AddItemToParentArray(const ParentObject: TObject; ParentField: TField; const Item: TObject);
  begin
    var ArrayValue := ParentField.GetValue(ParentObject);

    var ArrayLength := ArrayValue.ArrayLength;

    ArrayValue.ArrayLength := Succ(ArrayLength);

    ArrayValue.ArrayElement[ArrayLength] := Item;

    ParentField.SetValue(ParentObject, ArrayValue);
  end;

  procedure UpdateForeignKey(const Field: TField; const AObject, AForeignKeyObject: IStateObject);
  begin
    if Assigned(AForeignKeyObject) then
    begin
      Field.SetValue(AObject.&Object, AForeignKeyObject.&Object);

      Field.SetValue(AObject.OldObject, AForeignKeyObject.OldObject);
    end
    else
    begin
      Field.SetValue(AObject.&Object, nil);

      Field.SetValue(AObject.OldObject, nil);
    end;
  end;

begin
  for var Field in Join.Table.Fields do
    if not Field.IsJoinLink or Field.IsLazy then
    begin
      if Assigned(StateObject) then
      begin
        var FieldValue := Field.ConvertVariant(GetFieldValueFromCursor(FieldIndexStart));

        if not Field.IsReference then
          Field.SetValue(StateObject, FieldValue);
      end;

      Inc(FieldIndexStart);
    end
    else if NewObject and Field.IsManyValueAssociation then
    begin
      var ArrayValue: TValue;

      TValue.Make(nil, Field.PropertyInfo.PropertyType.Handle, ArrayValue);

      Field.SetValue(StateObject.&Object, ArrayValue);
    end;

  for var Link in Join.Links do
  begin
    var ForeignKeyObject: IStateObject := nil;
    var NewChildObject: Boolean;

    if Link.IsInheritedLink then
    begin
      ForeignKeyObject := StateObject;
      NewChildObject := NewObject;
    end
    else
      NewChildObject := CreateObject(Link.Table, FieldIndexStart, ForeignKeyObject);

    LoadObject(ForeignKeyObject, Link, FieldIndexStart, NewChildObject);

    if NewObject and Link.Field.IsForeignKey then
    begin
      UpdateForeignKey(Link.Field, StateObject, ForeignKeyObject);

      if Assigned(ForeignKeyObject) and Assigned(Link.Field.ForeignKey.ManyValueAssociation) then
        AddItemToParentArray(ForeignKeyObject.&Object, Link.Field.ForeignKey.ManyValueAssociation.Field, StateObject.&Object);
    end
    else if NewChildObject and Link.Field.IsManyValueAssociation then
    begin
      Link.RightField.SetValue(ForeignKeyObject.&Object, StateObject.&Object);

      AddItemToParentArray(StateObject.&Object, Link.Field, ForeignKeyObject.&Object);
    end;
  end;
end;

end.

