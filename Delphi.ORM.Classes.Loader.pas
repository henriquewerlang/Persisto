unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder;

type
  TClassLoader = class
  private
    FCache: TDictionary<String, TObject>;
    FContext: TRttiContext;
    FCursor: IDatabaseCursor;
    FFields: TArray<TFieldAlias>;
    FJoin: TQueryBuilderJoin;

    function GetFieldValue(Field: TField; const Index: Integer): TValue;
    function GetFieldValueAsString(Field: TField; const Index: Integer): String;
    function GetObjectFromCache(Join: TQueryBuilderJoin; FieldIndexStart: Integer): TObject;
    function LoadClass: TObject;
    function LoadClassJoin(Join: TQueryBuilderJoin): TObject;
    function LoadClassLink(Join: TQueryBuilderJoin; var FieldIndexStart: Integer): TObject;
  public
    constructor Create(Cursor: IDatabaseCursor; Join: TQueryBuilderJoin; const Fields: TArray<TFieldAlias>);

    destructor Destroy; override;

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;
  end;

implementation

uses System.SysUtils, System.Variants;

{ TClassLoader }

constructor TClassLoader.Create(Cursor: IDatabaseCursor; Join: TQueryBuilderJoin; const Fields: TArray<TFieldAlias>);
begin
  inherited Create;

  FCache := TDictionary<String, TObject>.Create;
  FContext := TRttiContext.Create;
  FCursor := Cursor;
  FFields := Fields;
  FJoin := Join;
end;

destructor TClassLoader.Destroy;
begin
  FCache.Free;

  inherited;
end;

function TClassLoader.GetFieldValue(Field: TField; const Index: Integer): TValue;
begin
  var FieldValue := FCursor.GetFieldValue(Index);

  if VarIsNull(FieldValue) then
    Result := TValue.Empty
  else if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
    Result := TValue.From(StringToGuid(FieldValue))
  else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
    Result := TValue.FromOrdinal(Field.TypeInfo.PropertyType.Handle, FieldValue)
  else
    Result := TValue.FromVariant(FieldValue);
end;

function TClassLoader.GetFieldValueAsString(Field: TField; const Index: Integer): String;
begin
  var FieldValue := FCursor.GetFieldValue(Index);

  if VarIsNull(FieldValue) then
    Result := EmptyStr
  else if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
    Result := FieldValue
  else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
    Result := TRttiEnumerationType.GetName(FieldValue)
  else
    Result := FieldValue;
end;

function TClassLoader.GetObjectFromCache(Join: TQueryBuilderJoin; FieldIndexStart: Integer): TObject;
begin
  var TableKey := Join.Table.TypeInfo.Name;

  for var A := FieldIndexStart to FieldIndexStart + High(Join.Table.PrimaryKey) do
    TableKey := TableKey + '.' + GetFieldValueAsString(FFields[A].Field, A);

  if not FCache.ContainsKey(TableKey) then
    FCache.Add(TableKey, Join.Table.TypeInfo.MetaclassType.Create);

  Result := FCache[TableKey];
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
  Result := nil;

  while FCursor.Next do
    Result := Result + [LoadClass as T];
end;

function TClassLoader.LoadClass: TObject;
begin
  Result := LoadClassJoin(FJoin);
end;

function TClassLoader.LoadClassJoin(Join: TQueryBuilderJoin): TObject;
begin
  var FieldIndex := Low(Join.Table.Fields);
  Result := LoadClassLink(FJoin, FieldIndex);
end;

function TClassLoader.LoadClassLink(Join: TQueryBuilderJoin; var FieldIndexStart: Integer): TObject;
begin
  Result := GetObjectFromCache(Join, FieldIndexStart);

  for var A := Low(Join.Table.Fields) to High(Join.Table.Fields) do
    if not TMapper.IsJoinLink(Join.Table.Fields[A]) then
    begin
      FFields[FieldIndexStart].Field.TypeInfo.SetValue(Result, GetFieldValue(FFields[FieldIndexStart].Field, FieldIndexStart));

      Inc(FieldIndexStart);
    end;

  for var Link in Join.Links do
  begin
    var Value: TValue;

    if TMapper.IsForeignKey(Link.Field) then
      Value := LoadClassLink(Link, FieldIndexStart)
    else
    begin
      var ChildObject := LoadClassLink(Link, FieldIndexStart);
      Value := Link.Field.TypeInfo.GetValue(Result);

      var NewArrayLength: NativeInt := Succ(Value.GetArrayLength);

      DynArraySetLength(PPointer(Value.GetReferenceToRawData)^, Link.Field.TypeInfo.PropertyType.Handle, 1, @NewArrayLength);

      Value.SetArrayElement(Pred(Value.GetArrayLength), ChildObject);

      Link.RightField.TypeInfo.SetValue(ChildObject, Result);
    end;

    Link.Field.TypeInfo.SetValue(Result, Value);
  end;
end;

end.

