unit Persisto.Classes.Loader.Test;

interface

uses System.Generics.Collections, Test.Insight.Framework, Persisto;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FObjects: TList<TObject>;
    FManager: TManager;
    FManagerInsert: TManager;

    function CreateObject<T: class, constructor>: T;

    procedure InsertDatabaseData(const Connection: IDatabaseConnection);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenSelectToOpenAnObjectFromDatabaseCantRaiseAnyError;
    [Test]
    procedure WhenLoadAnObjectMustCreateItWhenLoadFromDatabase;
    [Test]
    procedure WhenLoadAnObjectMustLoadTheFieldsOfTheObjectWithTheValueInTheDatabase;
    [Test]
    procedure WhenLoadAnObjectInheritedFromAnotherMustLoadTheFieldValueOfAllClassLevel;
    [Test]
    procedure WhenLoadAnObjectWithForeignKeyCantRaiseAnyError;
    [Test]
    procedure WhenLoadAnEmptyTableCantRaiseAnyError;
    [Test]
    procedure WhenLoadAnObjectWithForeignKeyMustCreateTheForeignKeyObject;
    [Test]
    procedure WhenLoadAnObjectWithForeignKeyMustLoadTheFieldValuesOfTheForeignKeyObjects;
    [Test]
    procedure WhenLoadAnObjectWithForeignKeyMustLoadAllLevelsOfForeignKey;
    [Test]
    procedure WhenLoadAnObjectAndTryToUpdateTheObjectCantRaiseErrorOfForeignKeyObject;
    [Test]
    procedure WhenTryToLoadASingleObjectFromAnEmptyTableCantRaiseAnyError;
    [Test]
    procedure WhenLoadAllObjectsMustReturnAllObjectsFromTheTable;
    [Test]
    procedure WhenLoadAnObjectWithManyValueAssociationMustLoadAllChildObjectsAsExpected;
    [Test]
    procedure WhenLoadAllObjectsFromAManyValueAssociationMustReturnAUniqueInstanceOfEachObject;
    [Test]
    procedure WhenLoadAnObjectWithChildValuesMustLoadTheChildPropertiesToo;
    [Test]
    procedure WhenTheChildObjectIsRepeatedInTheReturningCursorTheValueCantBeDuplicated;
    [Test]
    procedure TheChildOfAChildObjectMustBeLoadedAsExpected;
    [Test]
    procedure WhenLoadAnEmptyForeignKeyCantCreateTheForiegnKeyObject;
    [Test]
    procedure WhenLoadAnEmptyManyValueAssociationValueClassCantLoadTheChildIfIsEmpty;
    [Test]
    procedure WhenTheForeignKeyIsLazyCantRaiseErrorOfCircularReference;
    [Test]
    procedure WhenLoadAnObjectAndChangeTheForiegnKeyValueMustUpdateTheTableAsExpected;
    [Test]
    procedure WhenLoadAnLazyObjectCantRaiseAnyErrorThenOpenTheCursor;
    [Test]
    procedure WhenLoadAnObjectWithALazyPropertyMustCreateTheLazyFactoryToLoadTheLazyValue;
    [Test]
    procedure WhenLoadAnObjectWithNullableFieldMustLoadTheFieldAsExpected;
    [Test]
    procedure WhenLoadAClassWithAllTypeOfFieldMustLoadTheValuesWithoutAnyError;
    [Test]
    procedure WhenLoadAnObjectWithCircularReferenceMustRaiseAnError;
    [Test]
    procedure WhenLoadAnObjectWithCircularReferenceMustRaiseTheCircularReferenceTreeWithThePathOfThError;
    [Test]
    procedure WhenSelectingAChildTableWithAForeignKeyCantRaiseRecursionErrorThatNotReal;
    [Test]
    procedure WhenSelectingAClassWithManyValueAssociationWithCircularReferenteMustLoadTheReferenceCircularTreeWithTheManyValueInformationToo;
    [Test]
    procedure WhenLoadAClassWithManyValueAssociationMoreThenOneTimeMustResetTheArrayEveryTime;
    [Test]
    procedure WhenTheLazyValueIsntAnObjectOrArrayCantRaiseErrorWhenAreLoading;
    [Test]
    procedure WhenLoadAManyValueAssociationTheChildClassMustHaveTheLinkPropertyLoadedWithTheParentClassPointer;
    [Test]
    procedure WhenLoadALazyManyValueAssociationTheChildLinkFieldMustBeLoadedWithTheParentClassValue;
    [Test]
    procedure WhenTheLazyValueIsTheSameForMoreThanOneClassMustUseTheSameLoaderInAllClasses;
    [Test]
    procedure WhenSelectAnEntityWithTheForeignKeyFieldNamedMustLoadTheClassWithoutError;
  end;

implementation

uses System.SysUtils, System.Variants, Persisto.Test.Connection, Persisto.Test.Entity;

{ TClassLoaderTest }

function TClassLoaderTest.CreateObject<T>: T;
begin
  Result := T.Create;

  FObjects.Add(Result);
end;

procedure TClassLoaderTest.InsertDatabaseData(const Connection: IDatabaseConnection);
var
  Objects: TArray<TObject>;

  procedure UpdateDatabase;
  begin
    for var AObject in Objects do
      FManagerInsert.Mapper.GetTable(AObject.ClassType);

    FManagerInsert.UpdateDatabaseSchema;

    for var AObject in Objects do
      FManagerInsert.Insert([AObject]);
  end;

  procedure LoadObjects;
  begin
    var Object1 := CreateObject<TClassWithPrimaryKey>;
    Object1.Id := 35;
    Object1.Value := 1;

    var Object2 := CreateObject<TMyEntityInheritedFromSimpleClass>;
    Object2.AnotherProperty := 'abc';
    Object2.BaseProperty := 'def';
    Object2.Id := 10;
    Object2.SimpleProperty := 111;

    var Object3 := CreateObject<TMyEntityWithManyValueAssociation>;
    var Object4 := CreateObject<TMyEntityWithManyValueAssociationChild>;
    Object4.Value := 111;
    var Object5 := CreateObject<TMyEntityWithManyValueAssociationChild>;
    Object5.Value := 222;
    var Object6 := CreateObject<TMyEntityWithManyValueAssociationChild>;
    Object6.Value := 333;
    Object3.ManyValueAssociationList := [Object4, Object5, Object6];

    var Object7 := CreateObject<TMyManyValue>;
    var Object8 := CreateObject<TMyChildLink>;
    Object8.ManyValueAssociation := Object3;
    var Object9 := CreateObject<TMyChildLink>;
    Object9.ManyValueAssociation := Object3;
    var Object10 := CreateObject<TMyChildLink>;
    Object10.ManyValueAssociation := Object3;

    Object7.Childs := [Object8, Object9, Object10];

    var Object11 := CreateObject<TLazyClass>;
    Object11.Id := 1;
    Object11.Lazy := CreateObject<TMyEntity>;
    Object11.Lazy.Value.Id := 1;
    Object11.Lazy.Value.Name := 'Name';

    var Object15 := CreateObject<TLazyClass>;
    Object15.Id := 2;
    Object15.Lazy := Object11.Lazy;

    var Object16 := CreateObject<TLazyClass>;
    Object16.Id := 3;
    Object16.Lazy := Object11.Lazy;

    var Object12 := CreateObject<TClassWithNullableProperty>;
    Object12.Id := 20;

    var Object13 := CreateObject<TMyEntityWithAllTypeOfFields>;
    Object13.AnsiChar := 'a';
    Object13.AnsiString := 'Value';
    Object13.&String := 'Value';
    Object13.Char := 'a';
    Object13.Integer := 1;
    Object13.Text := 'Text';

    var Object14 := CreateObject<TLazyFilter>;

    Objects := [Object1, Object2, Object3, Object7, Object11, Object12, Object13, Object14, Object15, Object16];
  end;

begin
  Objects := nil;

  FManagerInsert.Mapper.GetTable(TInsertTestWithForeignKeyMoreOne);

  FManagerInsert.Mapper.GetTable(TManyValueAssociationParent);

  FManagerInsert.Mapper.GetTable(TMyManyValue);

  FManagerInsert.Mapper.GetTable(TClassWithForeignKeyNamedLinked);

  FManagerInsert.Mapper.GetTable(TInsertAutoGenerated);

  LoadObjects;

  UpdateDatabase;
end;

procedure TClassLoaderTest.Setup;
begin
  FObjects := TObjectList<TObject>.Create;

  var Connection := CreateConnection;
  FManager := TManager.Create(Connection, CreateDatabaseManipulator);
  FManagerInsert := TManager.Create(Connection, CreateDatabaseManipulator);

  FManager.CreateDatabase;

  InsertDatabaseData(Connection);
end;

procedure TClassLoaderTest.TearDown;
begin
  FManager.DropDatabase;

  FObjects.Free;

  FManager.Free;

  FManagerInsert.Free;
end;

procedure TClassLoaderTest.TheChildOfAChildObjectMustBeLoadedAsExpected;
begin
  var &Object := FManager.Select.All.From<TMyManyValue>.Open.One;

  Assert.AreEqual(3, Length(&Object.Childs[0].ManyValueAssociation.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenLoadAClassWithAllTypeOfFieldMustLoadTheValuesWithoutAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TMyEntityWithAllTypeOfFields>.Where(Field('Integer') = 1).Open.One;
    end);
end;

procedure TClassLoaderTest.WhenLoadAClassWithManyValueAssociationMoreThenOneTimeMustResetTheArrayEveryTime;
begin
  FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  Assert.AreEqual(3, Length(Objects.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenLoadALazyManyValueAssociationTheChildLinkFieldMustBeLoadedWithTheParentClassValue;
begin
  var LazyClass := FManager.Select.All.From<TMyManyValue>.Open.One;

  FManager.ExectDirect('delete from MyChildLink');

  FManager.ExectDirect('delete from MyManyValue');

  Assert.AreEqual(LazyClass, LazyClass.Childs[0].MyManyValue.Value);
end;

procedure TClassLoaderTest.WhenLoadAllObjectsFromAManyValueAssociationMustReturnAUniqueInstanceOfEachObject;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.All;

  Assert.AreEqual(1, Length(Objects));
end;

procedure TClassLoaderTest.WhenLoadAllObjectsMustReturnAllObjectsFromTheTable;
begin
  FManagerInsert.Insert([CreateObject<TInsertAutoGenerated>]);
  FManagerInsert.Insert([CreateObject<TInsertAutoGenerated>]);
  FManagerInsert.Insert([CreateObject<TInsertAutoGenerated>]);

  var Objects := FManager.Select.All.From<TInsertAutoGenerated>.Open.All;

  Assert.AreEqual(3, Length(Objects));
end;

procedure TClassLoaderTest.WhenLoadAManyValueAssociationTheChildClassMustHaveTheLinkPropertyLoadedWithTheParentClassPointer;
begin
  var LazyClass := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  Assert.AreEqual(LazyClass, LazyClass.ManyValueAssociationList[0].ManyValueAssociation);
end;

procedure TClassLoaderTest.WhenLoadAnEmptyForeignKeyCantCreateTheForiegnKeyObject;
begin
  var &Object := CreateObject<TInsertTestWithForeignKey>;

  FManagerInsert.Insert([&Object]);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.IsNil(&Object.FK1);
  Assert.IsNil(&Object.FK2);
end;

procedure TClassLoaderTest.WhenLoadAnEmptyManyValueAssociationValueClassCantLoadTheChildIfIsEmpty;
begin
  var &Object := CreateObject<TManyValueAssociationParent>;

  FManagerInsert.Insert([&Object]);

  &Object := FManager.Select.All.From<TManyValueAssociationParent>.Open.One;

  Assert.AreEqual(0, Length(&Object.ChildClass));
end;

procedure TClassLoaderTest.WhenLoadAnEmptyTableCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenLoadAnLazyObjectCantRaiseAnyErrorThenOpenTheCursor;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TLazyClass>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenLoadAnObjectAndChangeTheForiegnKeyValueMustUpdateTheTableAsExpected;
begin
  var &Object := CreateObject<TInsertTestWithForeignKey>;
  &Object.FK1 := CreateObject<TInsertAutoGeneratedSequence>;

  FManagerInsert.Insert([&Object]);

  var ForeignKeyValue := &Object.FK1.Id;

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  &Object.FK2 := &Object.FK1;

  &Object.FK1 := nil;

  FManager.Update([&Object]);

  var Cursor := FManager.OpenCursor('select IdFK1, IdFK2 from InsertTestWithForeignKey');

  Cursor.Next;

  NullStrictConvert := False;

  Assert.IsEmpty(EmptyStr, Cursor.GetDataSet.Fields[0].AsString);
  Assert.AreEqual(ForeignKeyValue, Cursor.GetDataSet.Fields[1].AsString);
end;

procedure TClassLoaderTest.WhenLoadAnObjectAndTryToUpdateTheObjectCantRaiseErrorOfForeignKeyObject;
begin
  var AObject := CreateObject<TInsertAutoGenerated>;

  FManagerInsert.Insert([AObject]);

  AObject := FManager.Select.All.From<TInsertAutoGenerated>.Open.One;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Update([AObject]);
    end);
end;

procedure TClassLoaderTest.WhenLoadAnObjectInheritedFromAnotherMustLoadTheFieldValueOfAllClassLevel;
begin
  var AObject := FManager.Select.All.From<TMyEntityInheritedFromSimpleClass>.Open.One;

  Assert.AreEqual('abc', AObject.AnotherProperty);
  Assert.AreEqual('def', AObject.BaseProperty);
  Assert.AreEqual(111, AObject.SimpleProperty);
  Assert.AreEqual(10, AObject.Id);
end;

procedure TClassLoaderTest.WhenLoadAnObjectMustCreateItWhenLoadFromDatabase;
begin
  var AObject := FManager.Select.All.From<TClassWithPrimaryKey>.Open.One;

  Assert.IsNotNil(AObject);
end;

procedure TClassLoaderTest.WhenLoadAnObjectMustLoadTheFieldsOfTheObjectWithTheValueInTheDatabase;
begin
  var AObject := FManager.Select.All.From<TClassWithPrimaryKey>.Open.One;

  Assert.AreEqual(35, AObject.Id);
  Assert.AreEqual(1, AObject.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithALazyPropertyMustCreateTheLazyFactoryToLoadTheLazyValue;
begin
  var LazyObject := FManager.Select.All.From<TLazyClass>.Open.One;

  Assert.IsNotNil(LazyObject.Lazy.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithChildValuesMustLoadTheChildPropertiesToo;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.OrderBy.Field('ManyValueAssociationList.Value').Open.One;

  Assert.AreEqual(111, Objects.ManyValueAssociationList[0].Value);
  Assert.AreEqual(222, Objects.ManyValueAssociationList[1].Value);
  Assert.AreEqual(333, Objects.ManyValueAssociationList[2].Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithCircularReferenceMustRaiseAnError;
begin
  Assert.WillRaise(
    procedure
    begin
      FManager.Select.All.From<TClassRecursiveFirst>.Open.One;
    end, ERecursionSelectionError);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithCircularReferenceMustRaiseTheCircularReferenceTreeWithThePathOfThError;
begin
  try
    FManager.Select.All.From<TClassRecursiveFirst>.Open.One;
  except
    on Erro: ERecursionSelectionError do
      Assert.AreEqual('ClassRecursiveFirst.GoingThird->ClassRecursiveThird.GoingSecond->ClassRecursiveSecond.GoingFirst->ClassRecursiveFirst.GoingThird', Erro.RecursionTree);
  end;
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyMustCreateTheForeignKeyObject;
begin
  var &Object := CreateObject<TInsertTestWithForeignKey>;
  &Object.FK1 := CreateObject<TInsertAutoGeneratedSequence>;
  &Object.FK2 := CreateObject<TInsertAutoGeneratedSequence>;

  FManagerInsert.Insert([&Object]);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.IsNotNil(&Object.FK1);
  Assert.IsNotNil(&Object.FK2);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyMustLoadAllLevelsOfForeignKey;
begin
  var &Object := CreateObject<TInsertTestWithForeignKeyMoreOne>;
  &Object.FK := CreateObject<TInsertTestWithForeignKey>;
  &Object.FK.FK1 := CreateObject<TInsertAutoGeneratedSequence>;
  &Object.FK.FK1.Value := 111;
  &Object.FK.FK2 := CreateObject<TInsertAutoGeneratedSequence>;
  &Object.FK.FK2.Value := 222;

  FManagerInsert.Insert([&Object]);

  Assert.WillNotRaise(
    procedure
    begin
      &Object := &FManager.Select.All.From<TInsertTestWithForeignKeyMoreOne>.Open.One;
    end);

  Assert.IsNotNil(&Object.FK);
  Assert.GreaterThan(0, &Object.FK.FK1.Id);
  Assert.GreaterThan(0, &Object.FK.FK1.DateTime);
  Assert.AreEqual(111, &Object.FK.FK1.Value);
  Assert.GreaterThan(0, &Object.FK.FK2.Id);
  Assert.IsTrue(&Object.FK.FK2.DateTime > 0);
  Assert.AreEqual(222, &Object.FK.FK2.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyMustLoadTheFieldValuesOfTheForeignKeyObjects;
begin
  var &Object := CreateObject<TInsertTestWithForeignKey>;
  &Object.FK1 := CreateObject<TInsertAutoGeneratedSequence>;
  &Object.FK1.Value := 111;
  &Object.FK2 := CreateObject<TInsertAutoGeneratedSequence>;
  &Object.FK2.Value := 222;

  FManagerInsert.Insert([&Object]);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.GreaterThan(0, &Object.FK1.Id);

  Assert.IsTrue(&Object.FK1.DateTime > 0);

  Assert.AreEqual(111, &Object.FK1.Value);

  Assert.GreaterThan(0, &Object.FK2.Id);

  Assert.IsTrue(&Object.FK2.DateTime > 0);

  Assert.AreEqual(222, &Object.FK2.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithManyValueAssociationMustLoadAllChildObjectsAsExpected;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  Assert.AreEqual(3, Length(Objects.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithNullableFieldMustLoadTheFieldAsExpected;
begin
  var &Object := FManager.Select.All.From<TClassWithNullableProperty>.Open.One;

  Assert.IsFalse(&Object.NullableStored);
end;

procedure TClassLoaderTest.WhenSelectAnEntityWithTheForeignKeyFieldNamedMustLoadTheClassWithoutError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TClassWithForeignKeyNamedLinked>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenSelectingAChildTableWithAForeignKeyCantRaiseRecursionErrorThatNotReal;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TMyChildLink>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenSelectingAClassWithManyValueAssociationWithCircularReferenteMustLoadTheReferenceCircularTreeWithTheManyValueInformationToo;
begin
  try
    FManager.Select.All.From<TManyValueRecursiveChild>.Open.One;
  except
    on Erro: ERecursionSelectionError do
      Assert.AreEqual('ManyValueRecursiveChild.ManyValueRecursive->ManyValueRecursive.Childs->ManyValueRecursiveChild.RecursiveClass->' +
        'ClassRecursiveFirst.GoingThird->ClassRecursiveThird.GoingSecond->ClassRecursiveSecond.GoingFirst->ClassRecursiveFirst.GoingThird', Erro.RecursionTree);
  end;
end;

procedure TClassLoaderTest.WhenSelectToOpenAnObjectFromDatabaseCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TClassWithPrimaryKey>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenTheChildObjectIsRepeatedInTheReturningCursorTheValueCantBeDuplicated;
begin
  var &Object := FManager.Select.All.From<TMyManyValue>.Open.One;

  Assert.AreEqual(3, Length(&Object.Childs));
end;

procedure TClassLoaderTest.WhenTheForeignKeyIsLazyCantRaiseErrorOfCircularReference;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TManyValueAssociationParent>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenTheLazyValueIsntAnObjectOrArrayCantRaiseErrorWhenAreLoading;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TLazyFilter>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenTheLazyValueIsTheSameForMoreThanOneClassMustUseTheSameLoaderInAllClasses;
begin
  var MyEntity := FManager.Select.All.From<TMyEntity>.Open.One;

  var LazyClass := FManager.Select.All.From<TLazyClass>.Open.All;

  FManager.ExectDirect('delete from LazyClass');

  FManager.ExectDirect('delete from MyEntity');

  Assert.AreEqual(MyEntity, LazyClass[0].Lazy.Value);

  Assert.AreEqual(MyEntity, LazyClass[1].Lazy.Value);

  Assert.AreEqual(MyEntity, LazyClass[2].Lazy.Value);
end;

procedure TClassLoaderTest.WhenTryToLoadASingleObjectFromAnEmptyTableCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;
    end);
end;

end.

