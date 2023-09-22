unit Persisto.Classes.Loader.Test;

interface

uses DUnitX.TestFramework, Persisto;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FManager: TManager;
    FManagerInsert: TManager;

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
    procedure WhenLoadAnObjectWithCircularReferenceMustRaiseAnError;
    [Test]
    procedure WhenTheLoadedObjectAsTheSameKeyMustKeepTheSameObjectInstance;
    [Test]
    procedure WhenLoadAnObjectAndTryToUpdateTheObjectCantRaiseErrorOfForeignKeyObject;
    [Test]
    procedure WhenLoadAnObjectAndUpdateAFieldMustUpdateOnlyTheChangedField;
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
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.Variants, Persisto.Test.Connection, Persisto.Test.Entity;

{ TClassLoaderTest }

procedure TClassLoaderTest.InsertDatabaseData(const Connection: IDatabaseConnection);
var
  Objects: TArray<TObject>;

  procedure UpdateDatabase;
  begin
    for var AObject in Objects do
      FManagerInsert.Mapper.GetTable(AObject.ClassType);

    FManagerInsert.UpdateDatabaseSchema;

    for var AObject in Objects do
      FManagerInsert.Insert(AObject);
  end;

  procedure InsertObjects;
  begin
    var Object1 := TClassWithPrimaryKey.Create;
    Object1.Value := 1;

    var Object2 := TMyEntityInheritedFromSimpleClass.Create;
    Object2.AnotherProperty := 'abc';
    Object2.BaseProperty := 'def';
    Object2.SimpleProperty := 111;

    var Object3 := TMyEntityWithManyValueAssociation.Create;
    var Object4 := TMyEntityWithManyValueAssociationChild.Create;
    Object4.Value := 111;
    var Object5 := TMyEntityWithManyValueAssociationChild.Create;
    Object5.Value := 222;
    var Object6 := TMyEntityWithManyValueAssociationChild.Create;
    Object6.Value := 333;
    Object3.ManyValueAssociationList := [Object4, Object5, Object6];

    var Object7 := TMyManyValue.Create;
    var Object8 := TMyChildLink.Create;
    Object8.ManyValueAssociation := Object3;
    var Object9 := TMyChildLink.Create;
    Object9.ManyValueAssociation := Object3;
    var Object10 := TMyChildLink.Create;
    Object10.ManyValueAssociation := Object3;

    Object7.Childs := [Object8, Object9, Object10];

    var Object11 := TLazyClass.Create;
    Object11.Id := 1;
    Object11.Lazy := TMyEntity.Create;
    Object11.Lazy.Value.Id := 1;

    Objects := [Object1, Object2, Object3, Object7, Object11];
  end;

begin
  Objects := nil;

  FManagerInsert.Mapper.GetTable(TInsertTestWithForeignKeyMoreOne);

  FManagerInsert.Mapper.GetTable(TManyValueAssociationParent);

  InsertObjects;

  UpdateDatabase;
end;

procedure TClassLoaderTest.Setup;
begin
  var Connection := CreateConnection;
  FManager := TManager.Create(Connection, CreateDialect);
  FManagerInsert := TManager.Create(Connection, CreateDialect);

  InsertDatabaseData(Connection);
end;

procedure TClassLoaderTest.TearDown;
begin
  FManager.Free;

  FManagerInsert.Free;
end;

procedure TClassLoaderTest.TheChildOfAChildObjectMustBeLoadedAsExpected;
begin
  var &Object := FManager.Select.All.From<TMyManyValue>.Open.One;

  Assert.AreEqual<NativeInt>(3, Length(&Object.Childs[0].ManyValueAssociation.ManyValueAssociationList));
end;

procedure TClassLoaderTest.WhenLoadAllObjectsFromAManyValueAssociationMustReturnAUniqueInstanceOfEachObject;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
end;

procedure TClassLoaderTest.WhenLoadAllObjectsMustReturnAllObjectsFromTheTable;
begin
  FManagerInsert.Insert(TInsertAutoGenerated.Create);
  FManagerInsert.Insert(TInsertAutoGenerated.Create);
  FManagerInsert.Insert(TInsertAutoGenerated.Create);

  var Objects := FManager.Select.All.From<TInsertAutoGenerated>.Open.All;

  Assert.AreEqual<NativeInt>(3, Length(Objects));
end;

procedure TClassLoaderTest.WhenLoadAnEmptyForeignKeyCantCreateTheForiegnKeyObject;
begin
  var &Object := TInsertTestWithForeignKey.Create;

  FManagerInsert.Insert(&Object);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.IsNull(&Object.FK1);
  Assert.IsNull(&Object.FK2);
end;

procedure TClassLoaderTest.WhenLoadAnEmptyManyValueAssociationValueClassCantLoadTheChildIfIsEmpty;
begin
  var &Object := TManyValueAssociationParent.Create;

  FManagerInsert.Insert(&Object);

  &Object := FManager.Select.All.From<TManyValueAssociationParent>.Open.One;

  Assert.AreEqual<NativeInt>(0, Length(&Object.ChildClass));
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
  var &Object := TInsertTestWithForeignKey.Create;
  &Object.FK1 := TInsertAutoGenerated.Create;

  FManagerInsert.Insert(&Object);

  var ForeignKeyValue := &Object.FK1.Id;

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  &Object.FK2 := &Object.FK1;

  &Object.FK1 := nil;

  FManager.Update(&Object);

  var Cursor := FManager.OpenCursor('select IdFK1, IdFK2 from InsertTestWithForeignKey');

  Cursor.Next;

  NullStrictConvert := False;

  Assert.IsEmpty(EmptyStr, String(Cursor.GetFieldValue(0)));
  Assert.AreEqual(ForeignKeyValue, String(Cursor.GetFieldValue(1)));
end;

procedure TClassLoaderTest.WhenLoadAnObjectAndTryToUpdateTheObjectCantRaiseErrorOfForeignKeyObject;
begin
  var AObject := TInsertAutoGenerated.Create;

  FManagerInsert.Insert(AObject);

  AObject := FManager.Select.All.From<TInsertAutoGenerated>.Open.One;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Update(AObject);
    end, EForeignObjectNotAllowed);
end;

procedure TClassLoaderTest.WhenLoadAnObjectAndUpdateAFieldMustUpdateOnlyTheChangedField;
begin
  var AObject := TInsertAutoGenerated.Create;
  AObject.Value := 111;

  FManagerInsert.Insert(AObject);

  AObject := FManager.Select.All.From<TInsertAutoGenerated>.Open.One;
  AObject.DateTime := EncodeDate(2023, 01, 01);

  FManager.ExectDirect('update InsertAutoGenerated set Value = 222');

  FManager.Update(AObject);

  var Cursor := FManager.OpenCursor('select Value from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(222, Integer(Cursor.GetFieldValue(0)));
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

  Assert.IsNotNull(AObject);
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

  Assert.IsNotNull(LazyObject.Lazy.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithChildValuesMustLoadTheChildPropertiesToo;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

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
  var &Object := TInsertTestWithForeignKey.Create;
  &Object.FK1 := TInsertAutoGenerated.Create;
  &Object.FK2 := TInsertAutoGenerated.Create;

  FManagerInsert.Insert(&Object);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.IsNotNull(&Object.FK1);
  Assert.IsNotNull(&Object.FK2);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyMustLoadAllLevelsOfForeignKey;
begin
  var &Object := TInsertTestWithForeignKeyMoreOne.Create;
  &Object.FK := TInsertTestWithForeignKey.Create;
  &Object.FK.FK1 := TInsertAutoGenerated.Create;
  &Object.FK.FK1.Value := 111;
  &Object.FK.FK2 := TInsertAutoGenerated.Create;
  &Object.FK.FK2.Value := 222;

  FManagerInsert.Insert(&Object);

  Assert.WillNotRaise(
    procedure
    begin
      &Object := &FManager.Select.All.From<TInsertTestWithForeignKeyMoreOne>.Open.One;
    end);

  Assert.IsNotNull(&Object.FK);
  Assert.IsNotEmpty(&Object.FK.FK1.Id);
  Assert.IsTrue(&Object.FK.FK1.DateTime > 0);
  Assert.AreEqual(111, &Object.FK.FK1.Value);
  Assert.IsNotEmpty(&Object.FK.FK2.Id);
  Assert.IsTrue(&Object.FK.FK2.DateTime > 0);
  Assert.AreEqual(222, &Object.FK.FK2.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithForeignKeyMustLoadTheFieldValuesOfTheForeignKeyObjects;
begin
  var &Object := TInsertTestWithForeignKey.Create;
  &Object.FK1 := TInsertAutoGenerated.Create;
  &Object.FK1.Value := 111;
  &Object.FK2 := TInsertAutoGenerated.Create;
  &Object.FK2.Value := 222;

  FManagerInsert.Insert(&Object);

  &Object := FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.IsNotEmpty(&Object.FK1.Id);

  Assert.IsTrue(&Object.FK1.DateTime > 0);

  Assert.AreEqual(111, &Object.FK1.Value);

  Assert.IsNotEmpty(&Object.FK2.Id);

  Assert.IsTrue(&Object.FK2.DateTime > 0);

  Assert.AreEqual(222, &Object.FK2.Value);
end;

procedure TClassLoaderTest.WhenLoadAnObjectWithManyValueAssociationMustLoadAllChildObjectsAsExpected;
begin
  var Objects := FManager.Select.All.From<TMyEntityWithManyValueAssociation>.Open.One;

  Assert.AreEqual<NativeInt>(3, Length(Objects.ManyValueAssociationList));
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

  Assert.AreEqual<NativeInt>(3, Length(&Object.Childs));
end;

procedure TClassLoaderTest.WhenTheForeignKeyIsLazyCantRaiseErrorOfCircularReference;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FManager.Select.All.From<TManyValueAssociationParent>.Open.One;
    end);
end;

procedure TClassLoaderTest.WhenTheLoadedObjectAsTheSameKeyMustKeepTheSameObjectInstance;
begin
  var &Object := TInsertTestWithForeignKey.Create;
  &Object.FK1 := TInsertAutoGenerated.Create;
  &Object.FK2 := &Object.FK1;

  FManagerInsert.Insert(&Object);

  &Object := &FManager.Select.All.From<TInsertTestWithForeignKey>.Open.One;

  Assert.AreSame(&Object.FK1, &Object.FK2);
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

