unit Delphi.ORM.Classes.Loader.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder;

type

  [TestFixture]
  TClassLoaderTest = class
  private
    FFrom: TQueryBuilderFrom;

    function CreateFieldList<T: class>: TArray<TFieldAlias>;
    function CreateLoader<T: class>(CursorValues: TArray<TArray<Variant>>): TClassLoader;
    function CreateLoaderCursor<T: class>(Cursor: IDatabaseCursor): TClassLoader;
  public
    [TearDown]
    procedure TearDown;
    [SetupFixture]
    procedure SetupFixture;
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
    [Test]
    procedure TheClassWithASingleJoinMustCreateTheForeignKeyClass;
    [Test]
    procedure TheClassWithASingleJoinMustLoadTheForeignKeyMapped;
    [Test]
    procedure WhenAClassIsLoadedAndMustUseTheSameInstanceIfThePrimaryKeyRepeats;
    [Test]
    procedure WhenTheAClassAsAManyValueAssociationMustLoadThePropertyArrayOfTheClass;
    [Test]
    procedure EvenIfTheCursorReturnsMoreThanOneRecordTheLoadClassHasToReturnOnlyOneClass;
    [Test]
    procedure TheChildFieldInManyValueAssociationMustBeLoadedWithTheReferenceOfTheParentClass;
  end;

  [Entity]
  [PrimaryKey('Name')]
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

uses System.Generics.Collections, System.SysUtils, System.Variants, Delphi.Mock, Delphi.ORM.Query.Builder.Test.Entity;

{ TClassLoaderTest }

function TClassLoaderTest.CreateFieldList<T>: TArray<TFieldAlias>;
begin
  var AllFields := TQueryBuilderAllFields.Create(FFrom);
  Result := AllFields.GetFields;

  AllFields.Free;
end;

function TClassLoaderTest.CreateLoader<T>(CursorValues: TArray<TArray<Variant>>): TClassLoader;
begin
  Result := CreateLoaderCursor<T>(TCursorMock.Create(CursorValues));
end;

function TClassLoaderTest.CreateLoaderCursor<T>(Cursor: IDatabaseCursor): TClassLoader;
begin
  FFrom := TQueryBuilderFrom.Create(nil, 1);

  FFrom.From<T>;

  Result := TClassLoader.Create(Cursor, FFrom.Join, CreateFieldList<T>);
end;

procedure TClassLoaderTest.EvenIfTheCursorReturnsMoreThanOneRecordTheLoadClassHasToReturnOnlyOneClass;
begin
  var Cursor := TCursorMock.Create([['aaa', 111], ['aaa', 222], ['aaa', 222]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor);
  var Result := Loader.Load<TMyClass>;

  Assert.AreEqual(3, Cursor.FCurrentRecord);

  Loader.Free;

  Result.Free;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfAllRecords;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 111], ['bbb', 222]]);
  var Result := Loader.LoadAll<TMyClass>;

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
  var Loader := CreateLoader<TMyClass>([['abc', 123]]);
  var MyClass := Loader.Load<TMyClass>;

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.TearDown;
begin
  FFrom.Free;
end;

procedure TClassLoaderTest.TheChildFieldInManyValueAssociationMustBeLoadedWithTheReferenceOfTheParentClass;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, 222], [111, 333], [111, 444]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual(Result, Result.ManyValueAssociationList[0].ManyValueAssociation);

  for var Obj in Result.ManyValueAssociationList do
    Obj.Free;

  Result.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustCreateTheForeignKeyClass;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.IsNotNull(Result.AnotherClass);

  Result.AnotherClass.Free;

  Result.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustLoadTheForeignKeyMapped;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.AreEqual(456, Result.AnotherClass.Id);
  Assert.AreEqual(789, Result.AnotherClass.Value);

  Result.AnotherClass.Free;

  Result.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.SetupFixture;
begin
  TMapper.Default.LoadAll;
end;

procedure TClassLoaderTest.WhenAClassIsLoadedAndMustUseTheSameInstanceIfThePrimaryKeyRepeats;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[111, 222, 333], [222, 222, 333]]);
  var Result := Loader.LoadAll<TClassWithForeignKey>;

  Assert.AreEqual(Result[0].AnotherClass, Result[1].AnotherClass);

  Result[0].AnotherClass.Free;

  for var Obj in Result do
    Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 123], ['bbb', 123]]);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual<Integer>(2, Length(Result));

  for var Obj in Result do
    Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheAClassAsAManyValueAssociationMustLoadThePropertyArrayOfTheClass;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, 222], [111, 333], [111, 444]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(3, Length(Result.ManyValueAssociationList));

  for var Obj in Result.ManyValueAssociationList do
    Obj.Free;

  Result.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassAsSpecialFieldsMustLoadTheFieldsAsExpected;
begin
  var MyGuid := TGUID.Create('{EFBF3977-8A0E-4508-B913-E1F8FA2B2D6C}');

  var Loader := CreateLoader<TMyClassWithSpecialTypes>([[Ord(Enum2), MyGuid.ToString]]);
  var MyClass := Loader.Load<TMyClassWithSpecialTypes>;

  Assert.AreEqual(Enum2, MyClass.Enumerator);

  Assert.AreEqual(MyGuid.ToString, MyClass.Guid.ToString);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoExistingRecordInCursorMustReturnNilToClassReference;
begin
  var Loader := CreateLoader<TMyClass>(nil);
  var MyClass := Loader.Load<TMyClass>;

  Assert.IsNull(MyClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThereIsNoRecordsMustReturnAEmptyArray;
begin
  var Loader := CreateLoader<TMyClass>(nil);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual<TArray<TMyClass>>(nil, Result);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheValueOfTheFieldIsNullCantRaiseAnError;
begin
  var Loader := CreateLoader<TMyClassWithSpecialTypes>([[NULL, NULL]]);

  Assert.WillNotRaise(
    procedure
    begin
      var MyClass := Loader.Load<TMyClassWithSpecialTypes>;

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
