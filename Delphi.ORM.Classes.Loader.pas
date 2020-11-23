unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper;

type
  TClassLoader = class
  private
    function LoadClass<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
  public
    function Load<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): T;
    function LoadAll<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>): TArray<T>;
  end;

implementation

{ TClassLoader }

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

  for var Field in Fields do
    Field.Field.TypeInfo.SetValue(TObject(Result), Cursor.GetFieldValue(Field.Alias));
end;

end.
