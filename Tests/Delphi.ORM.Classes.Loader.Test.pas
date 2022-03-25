unit Delphi.ORM.Classes.Loader.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection, Delphi.ORM.Attributes, Delphi.ORM.Mapper, Delphi.ORM.Cache,
  Delphi.ORM.Query.Builder;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FBuilderInterface: TObject;

    function CreateCursor(const CursorValues: TArray<TArray<Variant>>): IDatabaseCursor;
    function CreateLoader<T: class>(const CursorValues: TArray<TArray<Variant>>; const Cache: ICache = nil): TClassLoader;
    function CreateLoaderConnection<T: class>(Connection: IDatabaseConnection; Cache: ICache = nil): TClassLoader;
    function CreateLoaderCursor<T: class>(Cursor: IDatabaseCursor; const Cache: ICache = nil): TClassLoader;
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
    [Test]
    procedure WhenLoadingAClassWithAReadOnlyFieldCantRaiseAnyError;
    [Test]
    procedure WhenTheClassBeenLoadedIsInheritedFromAnotherClassMustLoadAllFieldsAsExpected;
    [Test]
    procedure WhenTheManyValueRepeatTheKeyCantDuplicateTheValueInTheList;
    [Test]
    procedure WhenTheParentClassAsAForeignKeyToTheChildWithManyValueAssociationAndTheValueOfTheForeignKeyIsInTheManyValueAssociationTheValueMustBeAddedToTheList;
    [Test]
    procedure WhenTheManyValueAssociationHasInheritedClassMustLoadTheValuesAsExpected;
    [Test]
    procedure AfterLoadTheObjectMustLoadTheOldValuesFromStateObject;
    [Test]
    procedure WhenLoadAManyValueAssociationThatTheObjectInTheManyValueIsInTheMainObjectListMustBeLoaded;
    [Test]
    procedure WhenLoadTheForeignKeyOfAClassMustLoadTheValueOfOldObjectToo;
    [Test]
    procedure WhenLoadTheForeignKeyOfTheOldValueMustLoadTheOldObjectReference;
    [Test]
    procedure WhenAForeignKeyIsChangedInTheDatabaseTheReferenceMustBeUpdatedToo;
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.Variants, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Cursor.Mock, Delphi.ORM.Lazy,
  Delphi.ORM.Shared.Obj;

{ TClassLoaderTest }

procedure TClassLoaderTest.AfterLoadTheObjectMustLoadTheOldValuesFromStateObject;
begin
  var Cache := TCache.Create as ICache;
  var Loader := CreateLoader<TMyClass>([['abc', 123]], Cache);
  var SharedObject: ISharedObject;

  Loader.Load<TMyClass>;

  Cache.Get('Delphi.ORM.Test.Entity.TMyClass.abc', SharedObject);

  var OldObject := (SharedObject as IStateObject).OldObject as TMyClass;

  Assert.AreEqual('abc', OldObject.Name);
  Assert.AreEqual(123, OldObject.Value);

  Loader.Free;
end;

function TClassLoaderTest.CreateCursor(const CursorValues: TArray<TArray<Variant>>): IDatabaseCursor;
begin
  Result := TCursorMock.Create(CursorValues);
end;

function TClassLoaderTest.CreateLoader<T>(const CursorValues: TArray<TArray<Variant>>; const Cache: ICache): TClassLoader;
begin
  Result := CreateLoaderCursor<T>(CreateCursor(CursorValues), Cache);
end;

function TClassLoaderTest.CreateLoaderCursor<T>(Cursor: IDatabaseCursor; const Cache: ICache): TClassLoader;
begin
  var Connection := TMock.CreateInterface<IDatabaseConnection>;

  Connection.Setup.WillReturn(TValue.From(Cursor)).When.OpenCursor(It.IsAny<String>);

  Result := CreateLoaderConnection<T>(Connection.Instance, Cache);
end;

function TClassLoaderTest.CreateLoaderConnection<T>(Connection: IDatabaseConnection; Cache: ICache): TClassLoader;
begin
  var Builder := TQueryBuilder.Create(Connection, TCache.Create);
  var From := Builder.Select.All;

  From.From<T>;

  if not Assigned(Cache) then
    Cache := TCache.Create;

  Result := TClassLoader.Create(Connection.OpenCursor(Builder.GetSQL), From, Cache);

  FreeAndNil(FBuilderInterface);

  FBuilderInterface := Builder;
end;

procedure TClassLoaderTest.EvenIfTheCursorReturnsMoreThanOneRecordTheLoadClassHasToReturnOnlyOneClass;
begin
  var Cursor := TCursorMock.Create([['aaa', 111], ['aaa', 222], ['aaa', 222]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor);

  Loader.Load<TMyClass>;

  Assert.AreEqual(3, Cursor.CurrentRecord);

  Loader.Free;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfAllRecords;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 111], ['bbb', 222]]);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual('aaa', Result[0].Name);

  Assert.AreEqual('bbb', Result[1].Name);

  Assert.AreEqual<Integer>(111, Result[0].Value);

  Assert.AreEqual<Integer>(222, Result[1].Value);

  Loader.Free;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
begin
  var Loader := CreateLoader<TMyClass>([['abc', 123]]);
  var MyClass := Loader.Load<TMyClass>;

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);

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

  Loader.Free;
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustCreateTheForeignKeyClass;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.IsNotNull(Result.AnotherClass);

  Loader.Free;
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustLoadTheForeignKeyMapped;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.AreEqual(456, Result.AnotherClass.Id);
  Assert.AreEqual(789, Result.AnotherClass.Value);

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
end;

procedure TClassLoaderTest.WhenAClassIsLoadedAndMustUseTheSameInstanceIfThePrimaryKeyRepeats;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[111, 222, 333], [222, 222, 333]]);
  var Result := Loader.LoadAll<TClassWithForeignKey>;

  Assert.AreEqual(Result[0].AnotherClass, Result[1].AnotherClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenAForeignKeyIsChangedInTheDatabaseTheReferenceMustBeUpdatedToo;
begin
  var Cache := TCache.Create as ICache;
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]], Cache);
  var SharedObject: ISharedObject;

  Loader.Load<TClassWithForeignKey>;

  Loader.Free;

  Loader := CreateLoader<TClassWithForeignKey>([[123, NULL, NULL]], Cache);

  var MyClass := Loader.Load<TClassWithForeignKey>;

  Cache.Get('Delphi.ORM.Test.Entity.TClassWithForeignKey.123', SharedObject);

  Assert.IsNull(MyClass.AnotherClass);

  Assert.IsNull(TClassWithForeignKey((SharedObject as IStateObject).OldObject).AnotherClass);

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

  Loader.Free;
end;

procedure TClassLoaderTest.WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 123], ['bbb', 123]]);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual<Integer>(2, Length(Result));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadAllIsCallWithTheSamePrimaryKeyValueMustReturnASingleObject;
begin
  var Loader := CreateLoader<TMyClass>([['aaa', 222], ['aaa', 222], ['aaa', 222]]);
  var Result := Loader.LoadAll<TMyClass>;

  Assert.AreEqual<Integer>(1, Length(Result));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadAManyValueAssociationThatTheObjectInTheManyValueIsInTheMainObjectListMustBeLoaded;
begin
  var Loader := CreateLoader<TManyValueParentSelfReference>([[111, 111, 222], [222, NULL, NULL]]);
  var Obj := Loader.LoadAll<TManyValueParentSelfReference>;

  Assert.AreEqual<Integer>(2, Length(Obj));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadAnObjectMoreThenOnceAndHaveAManyValueAssociationMustResetTheFieldBeforeLoadTheValues;
begin
  var Cache: ICache := TCache.Create;
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11]], Cache);

  Loader.Load<TMyEntityWithManyValueAssociation>;

  Loader.Free;

  Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11]], Cache);

  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(1, Length(Result.ManyValueAssociationList));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadingAClassWithAReadOnlyFieldCantRaiseAnyError;
begin
  var Loader := CreateLoader<TMyEntityInheritedFromSimpleClass>([[111, 222, 111, 'aaa', 'bbb']]);

  Assert.WillNotRaise(
    procedure
    begin
      Loader.LoadAll<TMyEntityInheritedFromSimpleClass>;
    end);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadTheForeignKeyOfAClassMustLoadTheValueOfOldObjectToo;
begin
  var Cache := TCache.Create as ICache;
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]], Cache);
  var SharedObject: ISharedObject;

  Loader.Load<TClassWithForeignKey>;

  Cache.Get('Delphi.ORM.Test.Entity.TClassWithForeignKey.123', SharedObject);

  var MyOldClass := (SharedObject as IStateObject).OldObject as TClassWithForeignKey;

  Assert.IsNotNull(MyOldClass.AnotherClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenLoadTheForeignKeyOfTheOldValueMustLoadTheOldObjectReference;
begin
  var Cache := TCache.Create as ICache;
  var Loader := CreateLoader<TClassWithForeignKey>([[123, 456, 789]], Cache);
  var SharedObject: ISharedObject;

  Loader.Load<TClassWithForeignKey>;

  Cache.Get('Delphi.ORM.Test.Entity.TClassWithForeignKey.123', SharedObject);

  var MyOldClass := (SharedObject as IStateObject).OldObject as TClassWithForeignKey;

  Cache.Get('Delphi.ORM.Test.Entity.TClassWithPrimaryKey.456', SharedObject);

  var MyOldAnotherClass := (SharedObject as IStateObject).OldObject as TClassWithPrimaryKey;

  Assert.AreEqual(MyOldAnotherClass, MyOldClass.AnotherClass);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheAClassAsAManyValueAssociationMustLoadThePropertyArrayOfTheClass;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, 222], [111, 333], [111, 444]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(3, Length(Result.ManyValueAssociationList));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassAsForeignKeyWithAnotherForignKeyAndIsNullTheValuesMustJumpTheFieldsOfAllForeignKeys;
begin
  var Loader := CreateLoader<TClassWithSubForeignKey>([[123, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 111, NULL, NULL, NULL, NULL, NULL, NULL, 555, 'My Field', 222.333]]);
  var MyClass := Loader.Load<TClassWithSubForeignKey>;

  Assert.IsTrue(Assigned(MyClass.ForeignKey2));

  Assert.IsTrue(Assigned(MyClass.ForeignKey2.ForeignKey3));

  Assert.AreEqual(555, MyClass.ForeignKey2.ForeignKey3.Id);

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

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassAsSpecialFieldsMustLoadTheFieldsAsExpected;
begin
  var MyGuid := TGUID.Create('{EFBF3977-8A0E-4508-B913-E1F8FA2B2D6C}');

  var Loader := CreateLoader<TMyClassWithSpecialTypes>([[Ord(Enum2), MyGuid.ToString]]);
  var MyClass := Loader.Load<TMyClassWithSpecialTypes>;

  Assert.AreEqual(Enum2, MyClass.Enumerator);

  Assert.AreEqual(MyGuid.ToString, MyClass.Guid.ToString);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassBeenLoadedIsInheritedFromAnotherClassMustLoadAllFieldsAsExpected;
begin
  var Loader := CreateLoader<TMyEntityInheritedFromSimpleClass>([[111, 222, 111, 'aaa', 'bbb']]);
  var Result := Loader.LoadAll<TMyEntityInheritedFromSimpleClass>;

  Assert.AreEqual(222, Result[0].SimpleProperty);
  Assert.AreEqual('aaa', Result[0].AnotherProperty);
  Assert.AreEqual('bbb', Result[0].BaseProperty);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheClassDontHaveAPrimaryKeyTheLoaderMustReturnTheLoadedClass;
begin
  var Loader := CreateLoader<TMyEntityWithoutPrimaryKey>([['Value']]);

  var MyClass := Loader.Load<TMyEntityWithoutPrimaryKey>;

  Assert.IsNotNull(MyClass);

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

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheLoaderCreateANewObjectMustAddItToTheCacheControl;
begin
  var Cache := TCache.Create as ICache;
  var Cursor := TCursorMock.Create([['aaa', 333]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor, Cache);
  var SharedObject: ISharedObject;

  Loader.Load<TMyClass>;

  Assert.IsTrue(Cache.Get('Delphi.ORM.Test.Entity.TMyClass.aaa', SharedObject));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationFieldHasRepetedKeyMustLoadJustOnceThenProperty;
begin
  var Cache: ICache := TCache.Create;
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]], Cache);
  var Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Loader.Free;

  Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]], Cache);

  Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result[0].ManyValueAssociationList) + Length(Result[1].ManyValueAssociationList));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationHasAValueInAForeignKeyAndInsideTheManyValueMustLoadTheManyValueAssociationWithAllValues;
begin
  var Loader := CreateLoader<TManyValueParent>([[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]]);
  var Obj := Loader.Load<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationHasInheritedClassMustLoadTheValuesAsExpected;
begin
  var Loader := CreateLoader<TManyValueParentInherited>([[1, 2, 2, 3, 1234]]);
  var Result := Loader.Load<TManyValueParentInherited>;

  Assert.AreEqual<Integer>(1234, Result.Childs[0].Value.Value);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationReturnTheValuesOutOfOrderMustGroupAllValuesInTheSingleObjectReference;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, 222], [111, 333], [222, 444], [222, 333], [111, 444]]);
  var Result := Loader.LoadAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheManyValueRepeatTheKeyCantDuplicateTheValueInTheList;
begin
  var Loader := CreateLoader<TManyValueParent>([[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555], [11, 222, 11, 222, 222],
    [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]]);
  var Obj := Loader.Load<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheObjectAlreadyInCacheMustGetThisInstanceToLoadTheData;
begin
  var Cache := TCache.Create as ICache;
  var Cursor := TCursorMock.Create([['aaa', 333]]);
  var Loader := CreateLoaderCursor<TMyClass>(Cursor, Cache);
  var MyClass := TMyClass.Create;
  MyClass.Name := 'aaa';
  MyClass.Value := 111;
  var Table := TMapper.Default.FindTable(TMyClass);

  Cache.Add(Table.GetCacheKey(MyClass), TStateObject.Create(MyClass, False) as ISharedObject);

  Loader.Load<TMyClass>;

  Assert.AreEqual(333, MyClass.Value);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThePrimaryKeyOfAForeignKeyIsNullCantLoadTheEntireObject;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociationChild>([[111, NULL, NULL]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociationChild>;

  Assert.IsNull(Result.ManyValueAssociation);

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThePrimaryKeyOfAManyValueAssociationIsNullCantLoadTheEntireObject;
begin
  var Loader := CreateLoader<TMyEntityWithManyValueAssociation>([[111, NULL]]);
  var Result := Loader.Load<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(0, Length(Result.ManyValueAssociationList));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenTheParentClassAsAForeignKeyToTheChildWithManyValueAssociationAndTheValueOfTheForeignKeyIsInTheManyValueAssociationTheValueMustBeAddedToTheList;
begin
  var Loader := CreateLoader<TManyValueParent>([[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]]);
  var Obj := Loader.Load<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));

  Loader.Free;
end;

procedure TClassLoaderTest.WhenThePrimaryKeyDontChangeCantReloadTheForeignKeysOfTheClass;
begin
  var Loader := CreateLoader<TClassWithForeignKey>([[111, 222, 333], [111, 333, 444]]);
  var Result := Loader.Load<TClassWithForeignKey>;

  Assert.AreEqual(222, Result.AnotherClass.Id);

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
      Loader.Load<TMyClassWithSpecialTypes>;
    end);

  Loader.Free;
end;

end.

