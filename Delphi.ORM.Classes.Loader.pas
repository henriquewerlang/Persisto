unit Delphi.ORM.Classes.Loader;

interface

uses System.Generics.Collections, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder, Delphi.ORM.Cache, Delphi.ORM.Database.Connection;

type
  TClassLoader = class
  private
    FAccess: IQueryBuilderAccess;
    FCacheKey: TDictionary<TObject, String>;
    FCursor: IDatabaseCursor;
    FLoadedObjects: TDictionary<String, TObject>;
    FMainLoadedObject: TDictionary<TObject, Boolean>;

    function CreateObject(const Table: TTable; const FieldIndexStart: Integer; var AObject: TObject): Boolean;
    function GetFieldValueFromCursor(const Index: Integer): Variant;
    function LoadClass(var StateObject: TObject): Boolean;

    procedure LoadObject(const StateObject: TObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);
  public
    constructor Create(const Access: IQueryBuilderAccess);

    destructor Destroy; override;

    class function GenerateInternalCacheKey(const CacheKey: String): String;

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;
  end;

implementation

uses System.Rtti, System.Variants, System.TypInfo, System.SysUtils, System.SysConst, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy, Delphi.ORM.Lazy.Factory, Delphi.ORM.Obj.Helper;

{ TClassLoader }

constructor TClassLoader.Create(const Access: IQueryBuilderAccess);
begin
  inherited Create;

  FAccess := Access;
  FCacheKey := TDictionary<TObject, String>.Create;
  FLoadedObjects := TDictionary<String, TObject>.Create;
  FMainLoadedObject := TDictionary<TObject, Boolean>.Create;
end;

function TClassLoader.CreateObject(const Table: TTable; const FieldIndexStart: Integer; var AObject: TObject): Boolean;
begin
  var PrimaryKeyValue := GetFieldValueFromCursor(FieldIndexStart);

  var CacheKey := Table.GetCacheKey(PrimaryKeyValue);

  Result := (not Assigned(Table.PrimaryKey) or not VarIsNull(PrimaryKeyValue)) and not FLoadedObjects.TryGetValue(CacheKey, AObject);

  if Result then
  begin
    if not FAccess.Cache.Get(CacheKey, AObject) then
    begin
      AObject := Table.ClassTypeInfo.MetaclassType.Create;

      FAccess.Cache.Add(CacheKey, AObject);
    end;

    FLoadedObjects.Add(CacheKey, AObject);

    FCacheKey.Add(AObject, CacheKey);
  end;
end;

destructor TClassLoader.Destroy;
begin
  FCacheKey.Free;

  FMainLoadedObject.Free;

  FLoadedObjects.Free;

  inherited;
end;

class function TClassLoader.GenerateInternalCacheKey(const CacheKey: String): String;
begin
  Result := Format('Internal-%s', [CacheKey]);
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
  FCursor := FAccess.OpenCursor;
  Result := nil;
  var TheObject: TObject;

  FMainLoadedObject.Clear;

  FLoadedObjects.Clear;

  FCacheKey.Clear;

  while FCursor.Next do
  begin
    TheObject := nil;

    if LoadClass(TheObject) then
      Result := Result + [TheObject as T];
  end;

  for TheObject in Result do
    TObjectHelper.Copy(TheObject,
      function (const Source: TObject): TObject
      begin
        var CacheKey := GenerateInternalCacheKey(FCacheKey[Source]);

        if not FAccess.Cache.Get(CacheKey, Result) then
        begin
          Result := Source.ClassType.Create;

          FAccess.Cache.Add(CacheKey, Result);
        end;
      end);
end;

function TClassLoader.LoadClass(var StateObject: TObject): Boolean;
begin
  var FieldIndex := 0;

  CreateObject(FAccess.Table, FieldIndex, StateObject);

  Result := not FMainLoadedObject.ContainsKey(StateObject);

  if Result then
    FMainLoadedObject.Add(StateObject, False);

  LoadObject(StateObject, FAccess.Join, FieldIndex, Result);
end;

procedure TClassLoader.LoadObject(const StateObject: TObject; Join: TQueryBuilderJoin; var FieldIndexStart: Integer; const NewObject: Boolean);

  procedure AddItemToParentArray(const ParentObject: TObject; ParentField: TField; const Item: TObject);
  begin
    var ArrayValue := ParentField.GetValue(ParentObject);

    var ArrayLength := ArrayValue.ArrayLength;

    ArrayValue.ArrayLength := Succ(ArrayLength);

    ArrayValue.ArrayElement[ArrayLength] := Item;

    ParentField.SetValue(ParentObject, ArrayValue);
  end;

  procedure UpdateForeignKey(const Field: TField; const AObject, AForeignKeyObject: TObject);
  begin
    if Assigned(AForeignKeyObject) then
      Field.SetValue(AObject, AForeignKeyObject)
    else
      Field.SetValue(AObject, nil);
  end;

begin
  for var Field in Join.Table.Fields do
    if not Field.IsJoinLink or Field.IsLazy then
    begin
      if Assigned(StateObject) then
      begin
        var FieldValue := Field.ConvertVariant(GetFieldValueFromCursor(FieldIndexStart));

        Field.SetValue(StateObject, FieldValue);

        if Field.IsLazy then
          Field.GetLazyAccess(StateObject).Factory := TLazyFactory.Create(FAccess.Connection, FAccess.Cache);
      end;

      Inc(FieldIndexStart);
    end
    else if NewObject and Field.IsManyValueAssociation then
    begin
      var ArrayValue: TValue;

      TValue.Make(nil, Field.PropertyInfo.PropertyType.Handle, ArrayValue);

      Field.SetValue(StateObject, ArrayValue);
    end;

  for var Link in Join.Links do
  begin
    var ForeignKeyObject: TObject := nil;
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
        AddItemToParentArray(ForeignKeyObject, Link.Field.ForeignKey.ManyValueAssociation.Field, StateObject);
    end
    else if NewChildObject and Link.Field.IsManyValueAssociation then
    begin
      Link.RightField.SetValue(ForeignKeyObject, StateObject);

      AddItemToParentArray(StateObject, Link.Field, ForeignKeyObject);
    end;
  end;
end;

end.

