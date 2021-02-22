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
    [Test]
    procedure WhenThePrimaryKeyOfAForeignKeyIsNullCantLoadTheEntireObject;
    [Test]
    procedure WhenThePrimaryKeyOfAManyValueAssociationIsNullCantLoadTheEntireObject;
    [Test]
    procedure WhenTheClassAsMoreThenOneForeignKeyAndOneOfThenIsNullMustJumpTheFieldsOfNullForeignKey;
    [Test]
    procedure WhenTheClassAsForeignKeyWithAnotherForignKeyAndIsNullTheValuesMustJumpTheFieldsOfAllForeignKeys;
    [Test]
    procedure WhenLoadAllIsCallWithTheSamePrimaryKeyValueMustReturnASingleObject;
    [Test]
    procedure WhenAClassHasManyValueAssociationsInChildClassesMustGroupTheValuesByThePrimaryKey;
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.Variants, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Cursor.Mock;

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

  Assert.AreEqual(3, Cursor.CurrentRecord);

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

procedure TClassLoaderTest.WhenAClassHasManyValueAssociationsInChildClassesMustGroupTheValuesByThePrimaryKey;
begin
  var Loader := CreateLoader<TMyClassParent>([[1, 10, 'Value', 100, 'Another Value'], [1, 10, 'Value', 200, 'Another Value'], [1, 20, 'Value', 300, 'Another Value'], [2, 30, 'Value', 400, 'Another Value']]);
  var Result := Loader.LoadAll<TMyClassParent>;

  Assert.AreEqual<Integer>(2, Length(Result), 'Main object');

  Assert.AreEqual<Integer>(2, Length(Result[0].Child), 'Key 1');

  Assert.AreEqual<Integer>(2, Length(Result[0].Child[0].Child), 'Key 1, 10');

  Assert.AreEqual<Integer>(1, Length(Result[0].Child[1].Child), 'Key 1, 20');

  Assert.AreEqual<Integer>(1, Length(Result[1].Child), 'Key 2');

  Assert.AreEqual<Integer>(1, Length(Result[1].Child[0].Child), 'Key 2, 30');

  Loader.Free;

  Result[1].Child[0].Child[0].Free;

  Result[1].Child[0].Free;

  Result[1].Free;

  Result[0].Child[1].Child[0].Free;

  Result[0].Child[1].Free;

  Result[0].Child[0].Child[1].Free;

  Result[0].Child[0].Child[0].Free;

  Result[0].Child[0].Free;

  Result[0].Free;
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

procedure TClassLoaderTest.WhenLoadAllIsCallWithTheSamePrimaryKeyValueMustReturnASingleObject;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 222], ['aaa', 222], ['aaa', 222]]);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual<Integer>(1, Length(Result));

  Result[0].Free;

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

procedure TClassLoaderTest.WhenTheClassAsForeignKeyWithAnotherForignKeyAndIsNullTheValuesMustJumpTheFieldsOfAllForeignKeys;
begin
  var Loader := CreateLoader<TClassWithSubForeignKey>([[123, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 111, NULL, NULL, NULL, NULL, NULL, NULL, 555, 'My Field', 222.333]]);
  var MyClass := Loader.Load<TClassWithSubForeignKey>;

  Assert.IsTrue(Assigned(MyClass.ForeignKey2));

  Assert.IsTrue(Assigned(MyClass.ForeignKey2.ForeignKey3));

  Assert.AreEqual(555, MyClass.ForeignKey2.ForeignKey3.Id);

  MyClass.ForeignKey2.ForeignKey3.Free;

  MyClass.ForeignKey2.Free;

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassAsMoreThenOneForeignKeyAndOneOfThenIsNullMustJumpTheFieldsOfNullForeignKey;
begin
  var Loader := CreateLoader<TClassWithThreeForeignKey>([[111, NULL, NULL, NULL, NULL, NULL, NULL, 555, 'My Field', 222.333]]);
  var MyClass := Loader.Load<TClassWithThreeForeignKey>;

  Assert.IsTrue(Assigned(MyClass.ForeignKey3));

  Assert.AreEqual(555, MyClass.ForeignKey3.Id);
  Assert.AreEqual('My Field', MyClass.ForeignKey3.Field1);
  Assert.AreEqual<Double>(222.333, MyClass.ForeignKey3.Field2);

  MyClass.ForeignKey3.Free;

  MyClass.Free;

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

procedure TClassLoaderTest.WhenThePrimaryKeyOfAForeignKeyIsNullCantLoadTheEntireObject;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociationChild>([[111, NULL, NULL]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociationChild>;

  Assert.IsNull(Result.ManyValueAssociation);

  Result.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThePrimaryKeyOfAManyValueAssociationIsNullCantLoadTheEntireObject;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, NULL]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(0, Length(Result.ManyValueAssociationList));

  Result.Free;

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

end.

