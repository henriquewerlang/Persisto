unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper;

type
  TClassLoader = class
  private
    function LoadClass<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): T;
  public
    function Load<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): T;
    function LoadAll<T: class, constructor>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): TArray<T>;
  end;

implementation

{ TClassLoader }

function TClassLoader.Load<T>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): T;
begin
  if Cursor.Next then
    Result := LoadClass<T>(Cursor, Fields)
  else
    Result := nil;
end;

function TClassLoader.LoadAll<T>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): TArray<T>;
begin
  Result := nil;

  while Cursor.Next do
    Result := Result + [LoadClass<T>(Cursor, Fields)];
end;

function TClassLoader.LoadClass<T>(Cursor: IDatabaseCursor; const Fields: TArray<TField>): T;
begin
  Result := T.Create;

  for var A := Low(Fields) to High(Fields) do
    Fields[A].TypeInfo.SetValue(TObject(Result), Cursor.GetFieldValue(A));
end;

end.
