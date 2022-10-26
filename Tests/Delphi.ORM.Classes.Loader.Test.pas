unit Delphi.ORM.Classes.Loader.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Classes.Loader, Delphi.ORM.Database.Connection, Delphi.ORM.Cache, Delphi.ORM.Query.Builder, Delphi.Mock.Intf, Delphi.ORM.Cursor.Mock,
  Delphi.ORM.Change.Manager;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FAccess: IMock<IQueryBuilderAccess>;
    FBuilder: TQueryBuilder;
    FCache: ICache;
    FChangeManager: IMock<IChangeManager>;
    FClassLoader: TClassLoader;
    FCursorMock: IDatabaseCursor;
    FCursorMockClass: TCursorMock;

    function LoadClass<T: class>: T;
    function LoadClassAll<T: class>: TArray<T>;
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
    procedure WhenTheClassAsForeignKeyWithAnotherForeignKeyAndIsNullTheValuesMustJumpTheFieldsOfAllForeignKeys;
    [Test]
    procedure WhenLoadAllIsCallWithTheSamePrimaryKeyValueMustReturnASingleObject;
    [Test]
    procedure WhenAClassHasManyValueAssociationsInChildClassesMustGroupTheValuesByThePrimaryKey;
    [Test]
    procedure WhenTheManyValueAssociationReturnTheValuesOutOfOrderMustGroupAllValuesInTheSingleObjectReference;
    [Test]
    procedure WhenTheClassDontHaveAPrimaryKeyTheLoaderMustReturnTheLoadedClass;
    [Test]
    procedure WhenThePrimaryKeyDontChangeCantReloadTheForeignKeysOfTheClass;
    [Test]
    procedure WhenTheLoaderCreateANewObjectMustAddItToTheCacheControl;
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
    procedure WhenLoadAManyValueAssociationThatTheObjectInTheManyValueIsInTheMainObjectListMustBeLoaded;
    [Test]
    procedure WhenLoadMoreThenOneTimeTheClassWithTheSameLoaderMustLoadTheClassPropertyHasExpected;
    [Test]
    procedure WhenTheClassHasAnLazyFieldMustLoadTheLoaderOfThatField;
    [Test]
    procedure ThenTheClassHasALazyArrayFieldMustLoadTheKeyOfTheLazyLoaderWithThePrimaryKeyFromParentClass;
    [Test]
    procedure WhenLoadAClassWithALazyArrayClassMustLoadAllValuesAsExpected;
    [Test]
    procedure AfterLoadAnObjectMustCallTheAddInInstanceOfChangeManager;
    [Test]
    procedure WhenCallTheAddInstanceTheParamsMustBeTheValuesExpected;
    [Test]
    procedure TheAddInstanceMustBeCalledJustOncePerInstance;
    [Test]
    procedure WhenTheLazyFieldAlreadyLoadedAndTheInternalKeyValueHasChangedMustReloadTheLazyControl;
  end;

implementation

uses System.SysUtils, System.Variants, System.Rtti, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Mapper, Delphi.ORM.Lazy.Manipulator;

{ TClassLoaderTest }

procedure TClassLoaderTest.AfterLoadAnObjectMustCallTheAddInInstanceOfChangeManager;
begin
  FChangeManager.Expect.Once.When.AddInstance(It(0).IsAny<TTable>, It(1).IsAny<TObject>);

  FCursorMockClass.Values := [['aaa', 111]];

  LoadClass<TMyClass>;

  Assert.CheckExpectation(FChangeManager.CheckExpectations);
end;

procedure TClassLoaderTest.EvenIfTheCursorReturnsMoreThanOneRecordTheLoadClassHasToReturnOnlyOneClass;
begin
  FCursorMockClass.Values := [['aaa', 111], ['aaa', 222], ['aaa', 222]];

  LoadClass<TMyClass>;

  Assert.AreEqual(3, FCursorMockClass.CurrentRecord);
end;

function TClassLoaderTest.LoadClass<T>: T;
begin
  var Value := LoadClassAll<T>;

  if Value = nil then
    Result := nil
  else
    Result := Value[0];
end;

function TClassLoaderTest.LoadClassAll<T>: TArray<T>;
begin
  FBuilder.Select.All.From<T>;

  Result := FClassLoader.LoadAll<T>;
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfAllRecords;
begin
  FCursorMockClass.Values := [['aaa', 111], ['bbb', 222]];
  var Result := LoadClassAll<TMyClass>;

  Assert.AreEqual('aaa', Result[0].Name);

  Assert.AreEqual('bbb', Result[1].Name);

  Assert.AreEqual<Integer>(111, Result[0].Value);

  Assert.AreEqual<Integer>(222, Result[1].Value);
end;

procedure TClassLoaderTest.MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
begin
  FCursorMockClass.Values := [['abc', 123]];
  var MyClass := LoadClass<TMyClass>;

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);
end;

procedure TClassLoaderTest.TearDown;
begin
  FAccess := nil;
  FCache := nil;
  FChangeManager := nil;
  FCursorMock := nil;

  FClassLoader.Free;

  FBuilder.Free;
end;

procedure TClassLoaderTest.TheAddInstanceMustBeCalledJustOncePerInstance;
begin
  FChangeManager.Expect.Once.When.AddInstance(It(0).IsAny<TTable>, It(1).IsAny<TObject>);

  FCursorMockClass.Values := [['aaa', 111], ['aaa', 111], ['aaa', 111]];

  LoadClass<TMyClass>;

  Assert.CheckExpectation(FChangeManager.CheckExpectations);
end;

procedure TClassLoaderTest.TheChildFieldInManyValueAssociationMustBeLoadedWithTheReferenceOfTheParentClass;
begin
  FCursorMockClass.Values := [[111, 222], [111, 333], [111, 444]];
  var Result := LoadClass<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual(Result, Result.ManyValueAssociationList[0].ManyValueAssociation);
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustCreateTheForeignKeyClass;
begin
  FCursorMockClass.Values := [[123, 456, 789]];
  var Result := LoadClass<TClassWithForeignKey>;

  Assert.IsNotNull(Result.AnotherClass);
end;

procedure TClassLoaderTest.TheClassWithASingleJoinMustLoadTheForeignKeyMapped;
begin
  FCursorMockClass.Values := [[123, 456, 789]];
  var Result := LoadClass<TClassWithForeignKey>;

  Assert.AreEqual(456, Result.AnotherClass.Id);
  Assert.AreEqual(789, Result.AnotherClass.Value);
end;

procedure TClassLoaderTest.ThenTheClassHasALazyArrayFieldMustLoadTheKeyOfTheLazyLoaderWithThePrimaryKeyFromParentClass;
begin
  FCursorMockClass.Values := [[111, 222]];
  var MyObject := LoadClass<TLazyArrayClass>;

  Assert.AreEqual(111, TLazyManipulator.GetManipulator(MyObject.LazyArray).Loader.GetKey.AsInteger);
end;

procedure TClassLoaderTest.Setup;
begin
  FAccess := TMock.CreateInterface<IQueryBuilderAccess>(True);
  FChangeManager := TMock.CreateInterface<IChangeManager>(True);
  FCursorMockClass := TCursorMock.Create;

  FBuilder := TQueryBuilder.Create(nil, FCache);
  FCache := TCache.Create(FChangeManager.Instance);
  FCursorMock := FCursorMockClass;

  FAccess.Setup.WillReturn(TValue.From(FCursorMock)).When.OpenCursor;

  FAccess.Setup.WillReturn(TValue.From(FCache)).When.GetCache;

  FAccess.Setup.WillExecute(
    function: TValue
    begin
      Result := (FBuilder as IQueryBuilderAccess).Table;
    end).When.GetTable;

  FAccess.Setup.WillExecute(
    function: TValue
    begin
      Result := (FBuilder as IQueryBuilderAccess).Join;
    end).When.GetJoin;

  FClassLoader := TClassLoader.Create(FAccess.Instance);
end;

procedure TClassLoaderTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TClassLoaderTest.WhenAClassHasManyValueAssociationsInChildClassesMustGroupTheValuesByThePrimaryKey;
begin
  FCursorMockClass.Values := [[1, 10, 'Value', 100, 'Another Value'], [1, 10, 'Value', 200, 'Another Value'], [1, 20, 'Value', 300, 'Another Value'],
    [2, 30, 'Value', 400, 'Another Value']];
  var Result := LoadClassAll<TMyClassParent>;

  Assert.AreEqual<Integer>(2, Length(Result), 'Main object');

  Assert.AreEqual<Integer>(2, Length(Result[0].Child), 'Key 1');

  Assert.AreEqual<Integer>(2, Length(Result[0].Child[0].Child), 'Key 1, 10');

  Assert.AreEqual<Integer>(1, Length(Result[0].Child[1].Child), 'Key 1, 20');

  Assert.AreEqual<Integer>(1, Length(Result[1].Child), 'Key 2');

  Assert.AreEqual<Integer>(1, Length(Result[1].Child[0].Child), 'Key 2, 30');
end;

procedure TClassLoaderTest.WhenAClassIsLoadedAndMustUseTheSameInstanceIfThePrimaryKeyRepeats;
begin
  FCursorMockClass.Values := [[111, 222, 333], [222, 222, 333]];
  var Result := LoadClassAll<TClassWithForeignKey>;

  Assert.AreEqual(Result[0].AnotherClass, Result[1].AnotherClass);
end;

procedure TClassLoaderTest.WhenCallTheAddInstanceTheParamsMustBeTheValuesExpected;
begin
  var Table := TMapper.Default.FindTable(TMyClass);

  FChangeManager.Expect.Once.When.AddInstance(It(0).IsEqualTo(Table), It(1).IsNotEqualTo<TObject>(nil));

  FCursorMockClass.Values := [['aaa', 111]];

  LoadClass<TMyClass>;

  Assert.CheckExpectation(FChangeManager.CheckExpectations);
end;

procedure TClassLoaderTest.WhenHaveMoreThenOneRecordMustLoadAllThenWhenRequested;
begin
  FCursorMockClass.Values := [['aaa', 123], ['bbb', 123]];
  var Result := LoadClassAll<TMyClass>;

  Assert.AreEqual<Integer>(2, Length(Result));
end;

procedure TClassLoaderTest.WhenLoadAClassWithALazyArrayClassMustLoadAllValuesAsExpected;
begin
  FCursorMockClass.Values := [[111, 222, 333, 444, 555]];
  var MyObject := LoadClass<TClassWithLazyArrayClass>;

  Assert.AreEqual(333, TLazyManipulator.GetManipulator(MyObject.Value1.Lazy).Loader.GetKey.AsInteger);

  Assert.AreEqual(555, TLazyManipulator.GetManipulator(MyObject.Value2.Lazy).Loader.GetKey.AsInteger);
end;

procedure TClassLoaderTest.WhenLoadAllIsCallWithTheSamePrimaryKeyValueMustReturnASingleObject;
begin
  FCursorMockClass.Values := [['aaa', 222], ['aaa', 222], ['aaa', 222]];
  var Result := LoadClassAll<TMyClass>;

  Assert.AreEqual<Integer>(1, Length(Result));
end;

procedure TClassLoaderTest.WhenLoadAManyValueAssociationThatTheObjectInTheManyValueIsInTheMainObjectListMustBeLoaded;
begin
  FCursorMockClass.Values := [[111, 111, 222], [222, NULL, NULL]];
  var Obj := LoadClassAll<TManyValueParentSelfReference>;

  Assert.AreEqual<Integer>(2, Length(Obj));
end;

procedure TClassLoaderTest.WhenLoadAnObjectMoreThenOnceAndHaveAManyValueAssociationMustResetTheFieldBeforeLoadTheValues;
begin
  FCursorMockClass.Values := [[1, 11]];

  LoadClass<TMyEntityWithManyValueAssociation>;

  FCursorMockClass.Values := [[1, 11]];

  var Result := LoadClass<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(1, Length(Result.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenLoadingAClassWithAReadOnlyFieldCantRaiseAnyError;
begin
  FCursorMockClass.Values := [[111, 222, 111, 'aaa', 'bbb']];

  Assert.WillNotRaise(
    procedure
    begin
      LoadClassAll<TMyEntityInheritedFromSimpleClass>;
    end);
end;

procedure TClassLoaderTest.WhenLoadMoreThenOneTimeTheClassWithTheSameLoaderMustLoadTheClassPropertyHasExpected;
begin
  FCursorMockClass.Values := [[111, 111]];

  LoadClass<TClassWithPrimaryKey>;

  FCursorMockClass.Values := [[111, 222]];

  var MyClass := LoadClass<TClassWithPrimaryKey>;

  Assert.IsNotNull(MyClass);

  Assert.AreEqual(222, MyClass.Value);
end;

procedure TClassLoaderTest.WhenTheAClassAsAManyValueAssociationMustLoadThePropertyArrayOfTheClass;
begin
  FCursorMockClass.Values := [[111, 222], [111, 333], [111, 444]];
  var Result := LoadClass<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(3, Length(Result.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenTheClassAsForeignKeyWithAnotherForeignKeyAndIsNullTheValuesMustJumpTheFieldsOfAllForeignKeys;
begin
  FCursorMockClass.Values := [[123, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 111, NULL, NULL, NULL, NULL, NULL, NULL, 555, 'My Field', 222.333]];
  var MyClass := LoadClass<TClassWithSubForeignKey>;

  Assert.IsTrue(Assigned(MyClass.ForeignKey2));

  Assert.IsTrue(Assigned(MyClass.ForeignKey2.ForeignKey3));

  Assert.AreEqual(555, MyClass.ForeignKey2.ForeignKey3.Id);
end;

procedure TClassLoaderTest.WhenTheClassAsMoreThenOneForeignKeyAndOneOfThenIsNullMustJumpTheFieldsOfNullForeignKey;
begin
  FCursorMockClass.Values := [[111, NULL, NULL, NULL, NULL, NULL, NULL, 555, 'My Field', 222.333]];
  var MyClass := LoadClass<TClassWithThreeForeignKey>;

  Assert.IsTrue(Assigned(MyClass.ForeignKey3));

  Assert.AreEqual(555, MyClass.ForeignKey3.Id);
  Assert.AreEqual('My Field', MyClass.ForeignKey3.Field1);
  Assert.AreEqual<Double>(222.333, MyClass.ForeignKey3.Field2);
end;

procedure TClassLoaderTest.WhenTheClassAsSpecialFieldsMustLoadTheFieldsAsExpected;
begin
  var MyGuid := TGUID.Create('{EFBF3977-8A0E-4508-B913-E1F8FA2B2D6C}');

  FCursorMockClass.Values := [[Ord(Enum2), MyGuid.ToString]];
  var MyClass := LoadClass<TMyClassWithSpecialTypes>;

  Assert.AreEqual(Enum2, MyClass.Enumerator);

  Assert.AreEqual(MyGuid.ToString, MyClass.Guid.ToString);
end;

procedure TClassLoaderTest.WhenTheClassBeenLoadedIsInheritedFromAnotherClassMustLoadAllFieldsAsExpected;
begin
  FCursorMockClass.Values := [[111, 222, 111, 'aaa', 'bbb']];
  var Result := LoadClassAll<TMyEntityInheritedFromSimpleClass>;

  Assert.AreEqual(222, Result[0].SimpleProperty);
  Assert.AreEqual('aaa', Result[0].AnotherProperty);
  Assert.AreEqual('bbb', Result[0].BaseProperty);
end;

procedure TClassLoaderTest.WhenTheClassDontHaveAPrimaryKeyTheLoaderMustReturnTheLoadedClass;
begin
  FCursorMockClass.Values := [['Value']];

  var MyClass := LoadClass<TMyEntityWithoutPrimaryKey>;

  Assert.IsNotNull(MyClass);
end;

procedure TClassLoaderTest.WhenTheClassHasAnLazyFieldMustLoadTheLoaderOfThatField;
begin
  FCursorMockClass.Values := [[111, 222]];
  var MyObject := LoadClass<TLazyClass>;

  Assert.IsNotEmpty(TLazyManipulator.GetManipulator(MyObject.Lazy).Loader);
end;

procedure TClassLoaderTest.WhenTheLazyFieldAlreadyLoadedAndTheInternalKeyValueHasChangedMustReloadTheLazyControl;
begin
  FCursorMockClass.Values := [[111, 222]];

  var MyObject := LoadClass<TLazyClass>;

  MyObject.Lazy := nil;

  FCursorMockClass.Values := [[111, 333]];
  MyObject := LoadClass<TLazyClass>;

  Assert.AreEqual(333, TLazyManipulator.GetManipulator(MyObject.Lazy).Loader.GetKey.AsInteger);

  Assert.IsFalse(TLazyManipulator.GetManipulator(MyObject.Lazy).Loaded);
end;

procedure TClassLoaderTest.WhenTheLoaderCreateANewObjectMustAddItToTheCacheControl;
begin
  FCursorMockClass.Values := [['aaa', 333]];
  var SharedObject: TObject;

  LoadClass<TMyClass>;

  Assert.IsTrue(FCache.Get('Delphi.ORM.Test.Entity.TMyClass.aaa', SharedObject));
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationFieldHasRepetedKeyMustLoadJustOnceThenProperty;
begin
  FCursorMockClass.Values := [[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]];

  LoadClassAll<TMyEntityWithManyValueAssociation>;

  FCursorMockClass.Values := [[1, 11], [1, 11], [1, 11], [2, 22], [2, 22], [2, 22]];

  var Result := LoadClassAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result[0].ManyValueAssociationList) + Length(Result[1].ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationHasAValueInAForeignKeyAndInsideTheManyValueMustLoadTheManyValueAssociationWithAllValues;
begin
  FCursorMockClass.Values := [[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]];
  var Obj := LoadClass<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationHasInheritedClassMustLoadTheValuesAsExpected;
begin
  FCursorMockClass.Values := [[1, 2, 2, 3, 1234]];
  var Result := LoadClass<TManyValueParentInherited>;

  Assert.AreEqual<Integer>(1234, Result.Childs[0].Value.Value);
end;

procedure TClassLoaderTest.WhenTheManyValueAssociationReturnTheValuesOutOfOrderMustGroupAllValuesInTheSingleObjectReference;
begin
  FCursorMockClass.Values := [[111, 222], [111, 333], [222, 444], [222, 333], [111, 444]];
  var Result := LoadClassAll<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(2, Length(Result));
end;

procedure TClassLoaderTest.WhenTheManyValueRepeatTheKeyCantDuplicateTheValueInTheList;
begin
  FCursorMockClass.Values := [[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555], [11, 222, 11, 222, 222],
    [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]];
  var Obj := LoadClass<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));
end;

procedure TClassLoaderTest.WhenThePrimaryKeyOfAForeignKeyIsNullCantLoadTheEntireObject;
begin
  FCursorMockClass.Values := [[111, NULL, NULL]];
  var Result := LoadClass<TMyEntityWithManyValueAssociationChild>;

  Assert.IsNull(Result.ManyValueAssociation);
end;

procedure TClassLoaderTest.WhenThePrimaryKeyOfAManyValueAssociationIsNullCantLoadTheEntireObject;
begin
  FCursorMockClass.Values := [[111, NULL]];
  var Result := LoadClass<TMyEntityWithManyValueAssociation>;

  Assert.AreEqual<Integer>(0, Length(Result.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenTheParentClassAsAForeignKeyToTheChildWithManyValueAssociationAndTheValueOfTheForeignKeyIsInTheManyValueAssociationTheValueMustBeAddedToTheList;
begin
  FCursorMockClass.Values := [[11, 222, 11, 222, 222], [11, 222, 11, 222, 333], [11, 222, 11, 222, 444], [11, 222, 11, 222, 555]];
  var Obj := LoadClass<TManyValueParent>;

  Assert.AreEqual<Integer>(4, Length(Obj.Childs));
end;

procedure TClassLoaderTest.WhenThePrimaryKeyDontChangeCantReloadTheForeignKeysOfTheClass;
begin
  FCursorMockClass.Values := [[111, 222, 333], [111, 333, 444]];
  var Result := LoadClass<TClassWithForeignKey>;

  Assert.AreEqual(222, Result.AnotherClass.Id);
end;

procedure TClassLoaderTest.WhenThereIsNoExistingRecordInCursorMustReturnNilToClassReference;
begin
  var MyClass := LoadClass<TMyClass>;

  Assert.IsNull(MyClass);
end;

procedure TClassLoaderTest.WhenThereIsNoRecordsMustReturnAEmptyArray;
begin
  var Result := LoadClassAll<TMyClass>;

  Assert.AreEqual<TArray<TMyClass>>(nil, Result);
end;

procedure TClassLoaderTest.WhenTheValueOfTheFieldIsNullCantRaiseAnError;
begin
  FCursorMockClass.Values := [[NULL, NULL]];

  Assert.WillNotRaise(
    procedure
    begin
      LoadClass<TMyClassWithSpecialTypes>;
    end);
end;

end.

