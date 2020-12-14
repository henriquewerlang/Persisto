unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder;

type
  TClassLoader = class
  private
    FContext: TRttiContext;
    FCursor: IDatabaseCursor;
    FFields: TArray<TFieldAlias>;
    FJoin: TQueryBuilderJoin;

    function GetFieldValue(Field: TField; const Index: Integer): TValue;
    function LoadClass: TObject;
    function LoadClassJoin(Join: TQueryBuilderJoin): TObject;
    function LoadClassLink(Join: TQueryBuilderJoin; var FieldIndexStart: Integer): TObject;
  public
    constructor Create(Cursor: IDatabaseCursor; Join: TQueryBuilderJoin; const Fields: TArray<TFieldAlias>);

    function Load<T: class>: T;
    function LoadAll<T: class>: TArray<T>;
  end;

implementation

uses System.SysUtils, System.Variants;

{ TClassLoader }

constructor TClassLoader.Create(Cursor: IDatabaseCursor; Join: TQueryBuilderJoin; const Fields: TArray<TFieldAlias>);
begin
  inherited Create;

  FContext := TRttiContext.Create;
  FCursor := Cursor;
  FFields := Fields;
  FJoin := Join;
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

function TClassLoader.Load<T>: T;
begin
  if FCursor.Next then
    Result := LoadClass as T
  else
    Result := nil;
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
  Result := Join.Table.TypeInfo.MetaclassType.Create;

  for var A := Low(Join.Table.Fields) to High(Join.Table.Fields) do
    if not TMapper.IsJoinLink(Join.Table.Fields[A]) then
    begin
      FFields[FieldIndexStart].Field.TypeInfo.SetValue(Result, GetFieldValue(FFields[FieldIndexStart].Field, FieldIndexStart));

      Inc(FieldIndexStart);
    end;

  for var Link in Join.Links do
    Link.Field.TypeInfo.SetValue(Result, LoadClassLink(Link, FieldIndexStart));
end;

end.

