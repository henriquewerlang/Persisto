unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder;

type
  TClassLoader = class
  private
    FCache: TDictionary<String, TObject>;
    FContext: TRttiContext;
    FCursor: IDatabaseCursor;
    FFields: TArray<TFieldAlias>;
    FJoin: TQueryBuilderJoin;

    function CreateObject(Join: TQueryBuilderJoin; FieldIndexStart: Integer): TObject;
    function FieldValueToString(Field: TField; const FieldValue: Variant): String;
    function GetFieldValue(Field: TField; const Index: Integer): TValue;
    function GetFieldValueVariant(const Index: Integer): Variant;
    function GetObjectFromCache(const Key: String; CreateFunction: TFunc<TObject>): TObject;
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

uses System.Variants;

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

function TClassLoader.CreateObject(Join: TQueryBuilderJoin; FieldIndexStart: Integer): TObject;
begin
  Result := nil;
  var TableKey := Join.Table.TypeInfo.Name;

  for var A := FieldIndexStart to FieldIndexStart + High(Join.Table.PrimaryKey) do
  begin
    var Field := FFields[A].Field;
    var FieldValue := GetFieldValueVariant(A);

    if VarIsNull(FieldValue) then
      Exit
    else
      TableKey := TableKey + '.' + FieldValueToString(Field, FieldValue);
  end;

  Result := GetObjectFromCache(TableKey,
    function: TObject
    begin
      Result := Join.Table.TypeInfo.MetaclassType.Create;
    end);
end;

destructor TClassLoader.Destroy;
begin
  FCache.Free;

  inherited;
end;

function TClassLoader.GetFieldValue(Field: TField; const Index: Integer): TValue;
begin
  var FieldValue := GetFieldValueVariant(Index);

  if VarIsNull(FieldValue) then
    Result := TValue.Empty
  else if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
    Result := TValue.From(StringToGuid(FieldValue))
  else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
    Result := TValue.FromOrdinal(Field.TypeInfo.PropertyType.Handle, FieldValue)
  else
    Result := TValue.FromVariant(FieldValue);
end;

function TClassLoader.GetFieldValueVariant(const Index: Integer): Variant;
begin
  Result := FCursor.GetFieldValue(Index);
end;

function TClassLoader.FieldValueToString(Field: TField; const FieldValue: Variant): String;
begin
  if VarIsNull(FieldValue) then
    Result := EmptyStr
  else if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
    Result := FieldValue
  else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
    Result := TRttiEnumerationType.GetName(FieldValue)
  else
    Result := FieldValue;
end;

function TClassLoader.GetObjectFromCache(const Key: String; CreateFunction: TFunc<TObject>): TObject;
begin
  if not FCache.ContainsKey(Key) then
    FCache.Add(Key, CreateFunction);

  Result := FCache[Key];
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
  Result := CreateObject(Join, FieldIndexStart);

  if Assigned(Result) then
  begin
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

        if Assigned(ChildObject) then
        begin
          Value := Link.Field.TypeInfo.GetValue(Result);

          var NewArrayLength: NativeInt := Succ(Value.GetArrayLength);

          DynArraySetLength(PPointer(Value.GetReferenceToRawData)^, Link.Field.TypeInfo.PropertyType.Handle, 1, @NewArrayLength);

          Value.SetArrayElement(Pred(Value.GetArrayLength), ChildObject);

          Link.RightField.TypeInfo.SetValue(ChildObject, Result);
        end;
      end;

      Link.Field.TypeInfo.SetValue(Result, Value);
    end;
  end;
end;

end.

