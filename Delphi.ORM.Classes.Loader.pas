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

    function CreateObject(Join: TQueryBuilderJoin; const FieldIndexStart: Integer): TObject;
    function FieldValueToString(Field: TField; const FieldValue: Variant): String;
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

uses System.Variants, Delphi.ORM.Rtti.Helper;

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

function TClassLoader.CreateObject(Join: TQueryBuilderJoin; const FieldIndexStart: Integer): TObject;
begin
  Result := nil;
  var TableKey := Join.Table.DatabaseName;

  if Assigned(Join.Table.PrimaryKey) then
  begin
    var Field := FFields[FieldIndexStart].Field;
    var FieldValue := GetFieldValueVariant(FieldIndexStart);

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

  for var A := Low(Join.Table.Fields) to High(Join.Table.Fields) do
    if not Join.Table.Fields[A].IsJoinLink then
    begin
      if Assigned(Result) then
        FFields[FieldIndexStart].Field.SetValue(Result, GetFieldValueVariant(FieldIndexStart));

      Inc(FieldIndexStart);
    end;

  for var Link in Join.Links do
  begin
    var Value: TValue;

    if Link.Field.IsForeignKey then
      Value := LoadClassLink(Link, FieldIndexStart)
    else
    begin
      var ChildObject := LoadClassLink(Link, FieldIndexStart);

      if Assigned(ChildObject) then
      begin
        Value := Link.Field.GetValue(Result);

        var ArrayLength := Value.ArrayLength;

        Value.ArrayLength := Succ(ArrayLength);

        Value.ArrayElement[ArrayLength] := ChildObject;

        Link.RightField.SetValue(ChildObject, Result);
      end;
    end;

    if Assigned(Result) then
      Link.Field.SetValue(Result, Value);
  end;
end;

end.

