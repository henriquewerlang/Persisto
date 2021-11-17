unit Delphi.ORM.Classes.Loader.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes, Delphi.ORM.Mapper, Delphi.ORM.Query.Builder;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FBuilderInterface: TObject;

    function CreateCursor(const CursorValues: TArray<TArray<Variant>>): IDatabaseCursor;
    function CreateLoader<T: class>(const CursorValues: TArray<TArray<Variant>>): TClassLoader;
    function CreateLoaderConnection<T: class>(Connection: IDatabaseConnection): TClassLoader;
    function CreateLoaderCursor<T: class>(Cursor: IDatabaseCursor): TClassLoader;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
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
    [Test]
    procedure WhenTheFieldIsLazyLoadingMustCallTheLazyFactoryToLoadTheValue;
    [Test]
    procedure WhenTheManyValueAssociationReturnTheValuesOutOfOrderMustGroupAllValuesInTheSingleObjectReference;
    [Test]
    procedure WhenThePrimaryKeyDontChangeCantReloadTheFieldPropertiesOfTheClassBeingLoaded;
    [Test]
    procedure WhenTheClassDontHaveAPrimaryKeyTheLoaderMustReturnTheLoadedClass;
    [Test]
    procedure WhenThePrimaryKeyDontChangeCantReloadTheForeignKeysOfTheClass;
    [Test]
    procedure WhenTheObjectAlreadyInCacheMustGetThisInstanceToLoadTheData;
    [Test]
    procedure WhenTheLoaderCreateANewObjectMustAddItToTheCacheControl;
    [Test]
    procedure WhenCallLoadOfTheLazyFactoryMustCallWithTheForeignKeyRttiType;
    [Test]
    procedure WhenTheManyValueAssociationFieldHasRepetedKeyMustLoadJustOnceThenProperty;
    [Test]
    procedure WhenTheManyValueAssociationHasAValueInAForeignKeyAndInsideTheManyValueMustLoadTheManyValueAssociationWithAllValues;
    [Test]
    procedure WhenLoadAnObjectMoreThenOnceAndHaveAManyValueAssociationMustResetTheFieldBeforeLoadTheValues;
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.Variants, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Cursor.Mock, Delphi.ORM.Cache, Delphi.ORM.Lazy;

{ TClassLoaderTest }

function TClassLoaderTest.CreateCursor(const CursorValues: TArray<TArray<Variant>>): IDatabaseCursor;
begin
  Result := TCursorMock.Create(CursorValues);
end;

function TClassLoaderTest.CreateLoader<T>(const CursorValues: TArray<TArray<Variant>>): TClassLoader;
begin
  Result := CreateLoaderCursor<T>(CreateCursor(CursorValues));
end;

function TClassLoaderTest.CreateLoaderCursor<T>(Cursor: IDatabaseCursor): TClassLoader;
begin
  var Connection := TMock.CreateInterface<IDatabaseConnection>;

  Connection.Setup.WillReturn(TValue.From(Cursor)).When.OpenCursor(It.IsAny<String>);

  Result := CreateLoaderConnection<T>(Connection.Instance);
end;

function TClassLoaderTest.CreateLoaderConnection<T>(Connection: IDatabaseConnection): TClassLoader;
begin
  var Builder := TQueryBuilder.Create(Connection);
  var From := Builder.Select.All;

  From.From<T>;

  Result := TClassLoader.Create(Connection.OpenCursor(Builder.GetSQL), From);
  Result.Cache := TCache.Create;

  FreeAndNil(FBuilderInterface);

  FBuilderInterface := Builder;
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
  FreeAndNil(FBuilderInterface);
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

procedure TClassLoaderTest.Setup;
begin
  CreateLoader<TMyClass>(nil).Free;
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

procedure TClassLoaderTest.WhenCallLoadOfTheLazyFactoryMustCallWithTheForeignKeyRttiType;
begin
  var Connection := TMock.CreateInterface<IDatabaseConnection>;
  var Context := TRttiContext.Create;
  var LazyFactory := TMock.CreateInterface<ILazyFactory>(True);
  TLazyAccess.GlobalFactory := LazyFactory.Instance;
  Connection.Setup.WillReturn(TValue.From(CreateCursor([[1, 222]]))).When.OpenCursor(It.IsEqualTo('select T1.Id F1,T1.IdLazy F2 from LazyClass T1'));

  var Loader := CreateLoaderConnection<TLazyClass>(Connection.Instance);
  var MyLazy := Loader.Load<TLazyClass>;

  LazyFactory.Expect.Once.When.Load(It(0).IsEqualTo<TRttiType>(Context.GetType(TMyEntity)), It(1).IsAny<TValue>);

  MyLazy.Lazy.Value;

  Assert.AreEqual(EmptyStr, LazyFactory.CheckExpectations);

  MyLazy.Lazy.Value.Free;

  MyLazy.Free;

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

procedure TClassLoaderTest.WhenLoadAnObjectMoreThenOnceAndHaveAManyValueAssociationMustResetTheFieldBeforeLoadTheValues;
begin
  var Cache: ICache := TCache.Create;
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11]]);
  Loader.Cache := Cache;

  Loader.Load<TMyEntityWithManyValueAssociation>;

  Loader.Free;

  Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11]]);
  Loader.Cache := Cache;

  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(1, Length(Result.ManyValueAssociationList));

  for var Obj in Result.ManyValueAssociationList do
    Obj.Free;

  Result.Free;

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

procedure TClassLoaderTest.WhenTheClassDontHaveAPrimaryKeyTheLoaderMustReturnTheLoadedClass;
begin
  var Loader := CreateLoader<TMyEntityWithoutPrimaryKey>([['Value']]);

  var MyClass := Loader.Load<TMyEntityWithoutPrimaryKey>;

  Assert.IsNotNull(MyClass);

  MyClass.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheFieldIsLazyLoadingMustCallTheLazyFactoryToLoadTheValue;
begin
  var Connection := TMock.CreateInterface<IDatabaseConnection>;
  var LazyFactory := TMock.CreateInterface<ILazyFactory>(True);
  TLazyAccess.GlobalFactory := LazyFactory.Instance;
  Connection.Setup.WillReturn(TValue.From(CreateCursor([[1, 222]]))).When.OpenCursor(It.IsEqualTo('select T1.Id F1,T1.IdLazy F2 from LazyClass T1'));

  var Loader := CreateLoaderConnection<TLazyClass>(Connection.Instance);
  var MyLazy := Loader.Load<TLazyClass>;

  LazyFactory.Expect.Once.When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  MyLazy.Lazy.Value;

  Assert.AreEqual(EmptyStr, LazyFactory.CheckExpectations);

  MyLazy.Lazy.Value.Free;

  MyLazy.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheLoaderCreateANewObjectMustAddItToTheCacheControl;
begin
  var Cache := TCache.Create;
  var Context := TRttiContext.Create;
  var Cursor := TCursorMock.Create([['aaa', 333]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor);
  Loader.Cache := Cache;

  var MyClass := Loader.Load<TMyClass>;

  Assert.AreEqual(1, Cache.Values.Count);

  Loader.Free;

  MyClass.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationFieldHasRepetedKeyMustLoadJustOnceThenProperty;
begin
  var Cache: ICache := TCache.Create;
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]]);
  Loader.Cache := Cache;
  var Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Loader.Free;

  Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]]);
  Loader.Cache := Cache;

  Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result[0].ManyValueAssociationList) + Length(Result[1].ManyValueAssociationList));

  for var ParentObj in Result do
  begin
    for var Obj in ParentObj.ManyValueAssociationList do
      Obj.Free;

    ParentObj.Free;
  end;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationHasAValueInAForeignKeyAndInsideTheManyValueMustLoadTheManyValueAssociationWithAllValues;
begin
  var Loader := CreateLoader<TManyValueParent>([[1, 2, 1, 2, 1], [1, 2, 1, 3, 1], [1, 2, 1, 4, 1], [1, 2, 1, 4, 1]]);
  var Obj := Loader.Load<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));

  for var Value in Obj.Childs do
    Value.Free;

  Obj.Free;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationReturnTheValuesOutOfOrderMustGroupAllValuesInTheSingleObjectReference;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, 222], [111, 333], [222, 444], [222, 333], [111, 444]]);
  var Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result));

  for var ParentObj in Result do
  begin
    for var Obj in ParentObj.ManyValueAssociationList do
      Obj.Free;

    ParentObj.Free;
  end;

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheObjectAlreadyInCacheMustGetThisInstanceToLoadTheData;
begin
  var Context := TRttiContext.Create;
  var Cursor := TCursorMock.Create([['aaa', 333]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor);
  var MyClass := TMyClass.Create;
  MyClass.Name := 'aaa';
  MyClass.Value := 111;

  Loader.Cache := TCache.Create;

  Loader.Cache.Add(Context.GetType(TMyClass), 'aaa', MyClass);

  Loader.Load<TMyClass>;

  Assert.AreEqual(333, MyClass.Value);

  Loader.Free;

  MyClass.Free;
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

procedure TClassLoaderTest.WhenThePrimaryKeyDontChangeCantReloadTheFieldPropertiesOfTheClassBeingLoaded;
begin
  var Cursor := TCursorMock.Create([['aaa', 111], ['aaa', 222], ['aaa', 333]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor);
  var Result := Loader.Load<TMyClass>;

  Assert.AreEqual(111, Result.Value);

  Loader.Free;

  Result.Free;
end;

procedure TClassLoaderTest.WhenThePrimaryKeyDontChangeCantReloadTheForeignKeysOfTheClass;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[111, 222, 333], [111, 333, 444]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.AreEqual(222, Result.AnotherClass.Id);

  Result.AnotherClass.Free;

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

