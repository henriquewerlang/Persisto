unit Delphi.ORM.Classes.Loader;

interface

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper;

type
  TClassLoader = class
  private
    FContext: TRttiContext;
    FCursor: IDatabaseCursor;
    FFields: TArray<TFieldAlias>;

    function GetFieldValue(Field: TField; const Index: Integer): TValue;
    function LoadClass<T: class, constructor>: T;
  public
    constructor Create(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>);

    function Load<T: class, constructor>: T;
    function LoadAll<T: class, constructor>: TArray<T>;
  end;

implementation

uses System.SysUtils, System.Variants;

{ TClassLoader }

constructor TClassLoader.Create(Cursor: IDatabaseCursor; const Fields: TArray<TFieldAlias>);
begin
  inherited Create;

  FContext := TRttiContext.Create;
  FCursor := Cursor;
  FFields := Fields;
end;

function TClassLoader.GetFieldValue(Field: TField; const Index: Integer): TValue;
begin
  var FieldValue := FCursor.GetFieldValue(Index);

  if VarIsNull(FieldValue) then
    Result := TValue.Empty
  else
  begin
    if Field.TypeInfo.PropertyType = FContext.GetType(TypeInfo(TGUID)) then
      Result := TValue.From(StringToGuid(FieldValue))
    else if Field.TypeInfo.PropertyType is TRttiEnumerationType then
      Result := TValue.FromOrdinal(Field.TypeInfo.PropertyType.Handle, FieldValue)
    else
      Result := TValue.FromVariant(FieldValue);
  end;
end;

function TClassLoader.Load<T>: T;
begin
  if FCursor.Next then
    Result := LoadClass<T>
  else
    Result := nil;
end;

function TClassLoader.LoadAll<T>: TArray<T>;
begin
  Result := nil;

  while FCursor.Next do
    Result := Result + [LoadClass<T>];
end;

function TClassLoader.LoadClass<T>: T;
begin
  Result := T.Create;

  for var A := Low(FFields) to High(FFields) do
    FFields[A].Field.TypeInfo.SetValue(TObject(Result), GetFieldValue(FFields[A].Field, A));
end;

end.

