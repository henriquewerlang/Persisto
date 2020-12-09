unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper;

type
  TClassLoader = class
  private
    FContext: TRttiContext;

    function GetFieldValue(Cursor: IDatabaseCursor; Field: TField; const Index: Integer): TValue;
    function LoadClass<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
  public
    constructor Create;

    function Load<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
    function LoadAll<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): TArray<T>;
  end;

implementation

uses System.SysUtils;

{ TClassLoader }

constructor TClassLoader.Create;
begin
  FContext := TRttiContext.Create;
end;

function TClassLoader.GetFieldValue(Cursor: IDatabaseCursor; Field: TField; const Index: Integer): TValue;
begin
  if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
    Result := TValue.From(StringToGuid(Cursor.GetFieldValue(Index).AsString))
  else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
    Result := TValue.FromOrdinal(Field.TypeInfo.PropertyType.Handle, Cursor.GetFieldValue(Index).AsInt64)
  else
    Result := Cursor.GetFieldValue(Index);
end;

function TClassLoader.Load<T>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
begin
  if Cursor.Next then
    Result := LoadClass<T>(Cursor, Fields)
  else
    Result := nil;
end;

function TClassLoader.LoadAll<T>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): TArray<T>;
begin
  Result := nil;

  while Cursor.Next do
    Result := Result + [LoadClass<T>(Cursor, Fields)];
end;

function TClassLoader.LoadClass<T>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
begin
  Result := T.Create;

  for var A := Low(Fields) to High(Fields) do
    Fields[A].Field.TypeInfo.SetValue(TObject(Result), GetFieldValue(Cursor, Fields[A].Field, A));
end;

end.

