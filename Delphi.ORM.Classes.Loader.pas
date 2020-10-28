unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection;

type
  TFieldMapPair = TPair<TRttiProperty, String>;

  IFieldXPropertyMapping = interface
    ['{56BAD454-B3FF-4165-9C65-72D05499607E}']
    function GetProperties: TArray<TFieldMapPair>;
  end;

  TClassLoader = class
  private
    function LoadClass<T: class, constructor>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): T;
  public
    function Load<T: class, constructor>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): T;
    function LoadAll<T: class, constructor>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): TArray<T>;
  end;

implementation

{ TClassLoader }

function TClassLoader.Load<T>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): T;
begin
  if Cursor.Next then
    Result := LoadClass<T>(Cursor, Mapper)
  else
    Result := nil;
end;

function TClassLoader.LoadAll<T>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): TArray<T>;
begin
  Result := nil;

  while Cursor.Next do
    Result := Result + [LoadClass<T>(Cursor, Mapper)];
end;

function TClassLoader.LoadClass<T>(Cursor: IDatabaseCursor; const Mapper: IFieldXPropertyMapping): T;
begin
  Result := T.Create;

  for var Map in Mapper.GetProperties do
    Map.Key.SetValue(TObject(Result), Cursor.GetFieldValue(Map.Value));
end;

end.
