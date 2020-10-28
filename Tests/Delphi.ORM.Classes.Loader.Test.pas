unit Delphi.ORM.Classes.Loader.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    function CreateMapper: IFieldXPropertyMapping;
  public
    [Test]
    procedure MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
    [Test]
    procedure WhenThereIsNoExistingRecordInCursorMustReturnNilToClassReference;
    [Test]
    procedure WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
    [Test]
    procedure MustLoadThePropertiesOfAllRecords;
    [Test]
    procedure WhenThereIsNoRecordsMustReturnAEmptyArray;
  end;

  TMyClass = class
  private
    FName: String;
    FValue: Integer;
  published
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  TCursorMock = class(TInterfacedObject, IDatabaseCursor)
  private
    FCurrentRecord: Integer;
    FFieldNames: TArray<String>;
    FValues: TArray<TArray<TValue>>;

    function GetFieldValue(const FieldName: String): TValue;
    function Next: Boolean;
  public
    constructor Create(FieldNames: TArray<String>; Values: TArray<TArray<TValue>>);
  end;

implementation

uses System.Generics.Collections, Delphi.Mock;

{ TClassLoaderTest }

function TClassLoaderTest.CreateMapper: IFieldXPropertyMapping;
begin
  var Mapper := TMock.CreateInterface<IFieldXPropertyMapping>;
  var MyClassType := TRttiContext.Create.GetType(TMyClass);

  Mapper.Setup.WillReturn(TValue.FromArray(TypeInfo(TArray<TFieldMapPair>),
    [TValue.From(TFieldMapPair.Create(MyClassType.GetProperty('Name'), 'Name')),
      TValue.From(TFieldMapPair.Create(MyClassType.GetProperty('Value'), 'Value'))])).When.GetProperties;

  Result := Mapper.Instance;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfAllRecords;
begin
  var Cursor := TCursorMock.Create(['Name', 'Value'], [['aaa', 111], ['bbb', 222]]);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateMapper);

  Assert.AreEqual('aaa', Result[0].Name);

  Assert.AreEqual('bbb', Result[1].Name);

  Assert.AreEqual<Integer>(111, Result[0].Value);

  Assert.AreEqual<Integer>(222, Result[1].Value);

  for var Obj in Result do
    Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
begin
  var Cursor := TCursorMock.Create(['Name', 'Value'], [['abc', 123]]);
  var Loader := TClassLoader.Create;
  var MyClass := Loader.Load<TMyClass>(Cursor, CreateMapper);

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
begin
  var Cursor := TCursorMock.Create(['Name', 'Value'], [['abc', 123], ['abc', 123]]);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateMapper);

  Assert.AreEqual<Integer>(2, Length(Result));

  for var Obj in Result do
    Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoExistingRecordInCursorMustReturnNilToClassReference;
begin
  var Cursor := TCursorMock.Create(['Name', 'Value'], nil);
  var Loader := TClassLoader.Create;
  var MyClass := Loader.Load<TMyClass>(Cursor, CreateMapper);

  Assert.IsNull(MyClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoRecordsMustReturnAEmptyArray;
begin
  var Cursor := TCursorMock.Create(['Name', 'Value'], nil);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateMapper);

  Assert.AreEqual<TArray<TMyClass>>(nil, Result);

  Loader.Free;
end;

{ TCursorMock }

constructor TCursorMock.Create(FieldNames: TArray<String>; Values: TArray<TArray<TValue>>);
begin
  inherited Create;

  FCurrentRecord := -1;
  FFieldNames := FieldNames;
  FValues := Values;
end;

function TCursorMock.GetFieldValue(const FieldName: String): TValue;
var
  Index: Integer;

begin
  Index := 0;

  for var A := Low(FFieldNames) to High(FFieldNames) do
    if FFieldNames[A] = FieldName then
      Index := A;

  Result := FValues[FCurrentRecord][Index];
end;

function TCursorMock.Next: Boolean;
begin
  Inc(FCurrentRecord);

  Result := FCurrentRecord < Length(FValues);
end;

initialization
  // Avoid leak reporting
  TRttiContext.Create.GetType(TMyClass).GetProperties;
  TMock.CreateInterface<IDatabaseCursor>;
  TMock.CreateInterface<IFieldXPropertyMapping>;

end.

