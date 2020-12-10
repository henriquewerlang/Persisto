unit Delphi.ORM.Classes.Loader.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes, Delphi.ORM.Mapper;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    function CreateFieldList<T: class>: TArray<TFieldAlias>;
  public
    [SetupFixture]
    procedure Setup;
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
    [Test]
    procedure WhenTheClassAsSpecialFieldsMustLoadTheFieldsAsExpected;
    [Test]
    procedure WhenTheValueOfTheFieldIsNullCantRaiseAnError;
  end;

  [Entity]
  TMyClass = class
  private
    FName: String;
    FValue: Integer;
  published
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  TMyEnumerator = (Enum1, Enum2, Enum3, Enum4);

  [Entity]
  TMyClassWithSpecialTypes = class
  private
    FGuid: TGUID;
    FEnumerator: TMyEnumerator;
  published
    property Enumerator: TMyEnumerator read FEnumerator write FEnumerator;
    property Guid: TGUID read FGuid write FGuid;
  end;

  TCursorMock = class(TInterfacedObject, IDatabaseCursor)
  private
    FCurrentRecord: Integer;
    FValues: TArray<TArray<Variant>>;

    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  public
    constructor Create(Values: TArray<TArray<Variant>>);
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.Variants, Delphi.Mock;

{ TClassLoaderTest }

function TClassLoaderTest.CreateFieldList<T>: TArray<TFieldAlias>;
begin
  Result := nil;
  var Table := TMapper.Default.FindTable(T);

  for var Field in Table.Fields do
    Result := Result + [TFieldAlias.Create('T', Field)];
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfAllRecords;
begin
  var Cursor := TCursorMock.Create([['aaa', 111], ['bbb', 222]]);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateFieldList<TMyClass>);

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
  var Cursor := TCursorMock.Create([['abc', 123]]);
  var Loader := TClassLoader.Create;
  var MyClass := Loader.Load<TMyClass>(Cursor, CreateFieldList<TMyClass>);

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.Setup;
begin
  TMapper.Default.LoadAll;
end;

procedure TClassLoaderTest.WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
begin
  var Cursor := TCursorMock.Create([['abc', 123], ['abc', 123]]);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateFieldList<TMyClass>);

  Assert.AreEqual<Integer>(2, Length(Result));

  for var Obj in Result do
    Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassAsSpecialFieldsMustLoadTheFieldsAsExpected;
begin
  var Loader := TClassLoader.Create;
  var MyGuid := TGUID.Create('{EFBF3977-8A0E-4508-B913-E1F8FA2B2D6C}');

  var Cursor := TCursorMock.Create([[Ord(Enum2), MyGuid.ToString]]);
  var MyClass := Loader.Load<TMyClassWithSpecialTypes>(Cursor, CreateFieldList<TMyClassWithSpecialTypes>);

  Assert.AreEqual(Enum2, MyClass.Enumerator);

  Assert.AreEqual(MyGuid.ToString, MyClass.Guid.ToString);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoExistingRecordInCursorMustReturnNilToClassReference;
begin
  var Cursor := TCursorMock.Create(nil);
  var Loader := TClassLoader.Create;
  var MyClass := Loader.Load<TMyClass>(Cursor, CreateFieldList<TMyClass>);

  Assert.IsNull(MyClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoRecordsMustReturnAEmptyArray;
begin
  var Cursor := TCursorMock.Create(nil);
  var Loader := TClassLoader.Create;
  var Result := Loader.LoadAll<TMyClass>(Cursor, CreateFieldList<TMyClass>);

  Assert.AreEqual<TArray<TMyClass>>(nil, Result);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheValueOfTheFieldIsNullCantRaiseAnError;
begin
  var Cursor := TCursorMock.Create([[NULL, NULL]]);
  var Loader := TClassLoader.Create;

  Assert.WillNotRaise(
    procedure
    begin
      var MyClass := Loader.Load<TMyClassWithSpecialTypes>(Cursor, CreateFieldList<TMyClassWithSpecialTypes>);

      MyClass.Free;
    end);

  Loader.Free;
end;

{ TCursorMock }

constructor TCursorMock.Create(Values: TArray<TArray<Variant>>);
begin
  inherited Create;

  FCurrentRecord := -1;
  FValues := Values;
end;

function TCursorMock.GetFieldValue(const FieldIndex: Integer): Variant;
begin
  Result := FValues[FCurrentRecord][FieldIndex];
end;

function TCursorMock.Next: Boolean;
begin
  Inc(FCurrentRecord);

  Result := FCurrentRecord < Length(FValues);
end;

end.

