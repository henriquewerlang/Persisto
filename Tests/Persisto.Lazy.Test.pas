unit Persisto.Lazy.Test;

interface

uses System.Rtti, Test.Insight.Framework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TLazyTest = class
  private
    FContext: TRttiContext;
  public
    [Test]
    procedure TheGetValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
    [Test]
    procedure TheGetLazyValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
    [Test]
    procedure TheSetLazyValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
    [Test]
    procedure WhenLoadTheLazyValueMustReturnTheValueLoaded;
    [Test]
    procedure TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
    [Test]
    procedure WhenGetLazyTypeMustReturnTheRttiTypeAsExpected;
    [Test]
    procedure WhenTheLazyValueIsntLoadedMustReturnTheTypeInfoFromTheTypeAsExpected;
    [Test]
    procedure WhenFillTheLazyValuePropertyMustReturnTheValueAsExpected;
    [Test]
    procedure WhenTheLazyValueIsFilledTheHasValueFunctionMustReturnTrue;
  end;

  [TestFixture]
  TLazyValueTest = class
  private
    FLazyValue: ILazyValue;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenGetTheKeyOfAnUnloadedLazyFieldMustReturnEmpty;
    [Test]
    procedure WhenFillTheValueMustReturnTheFilledValue;
    [Test]
    procedure WhenTheLazyValueIsUnloadedMustReturnTheValueEmptyButWithTheTypeInfoLoaded;
    [Test]
    procedure WhenCreateTheLazyValueWithOneValueMustReturnThisValue;
    [Test]
    procedure WhenTheValueIsFilledTheHasValueFunctionMustReturnTrue;
  end;

  [TestFixture]
  TLazyLoaderTest = class
  private
    FManager: TPersistoManager;

    procedure LoadDatabaseData;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
    [Test]
    procedure WhenFillTheValueMustReturnTheLoadedValueAsExpected;
    [Test]
    procedure WhenFillTheValueMustCleanUpTheKeyValue;
    [Test]
    procedure WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
    [Test]
    procedure WhenTheLazyKeyIsEmptyCantTryToLoadTheValueFromDatabase;
    [Test]
    procedure WhenTheKeyIsLoadedTheHasValueMustReturnTrue;
    [Test]
    procedure WhenTheValueIsLoadedTheHasValueMustReturnTrue;
    [Test]
    procedure AfterLoadTheValueMustCleanUpTheKeyValue;
    [Test]
    procedure WhenTheValueIsntLoadedMustLoadTheArrayValueFromDatabase;
    [Test]
    procedure WhenLoadTheLazyFieldCantRaiseAnyError;
    [Test]
    procedure WhenLoadTheStringLazyFieldMustReturnTheValueFromDatabase;
    [Test]
    procedure WhenLoadTheLazyArrayFieldCantRaiseAnyError;
    [Test]
    procedure WhenLoadTheArrayLazyFieldMustReturnTheValueFromDatabase;
  end;

implementation

uses System.TypInfo, Persisto.Test.Entity, Persisto.Test.Connection;

{ TLazyTest }

procedure TLazyTest.TheGetLazyValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
begin
  var RttiType := FContext.GetType(TypeInfo(Lazy<TMyEntity>));

  Assert.IsNotNil(RttiType.GetMethod('GetLazyValue'));
end;

procedure TLazyTest.TheGetValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
begin
  var RttiType := FContext.GetType(TypeInfo(Lazy<TMyEntity>));

  Assert.IsNotNil(RttiType.GetMethod('GetValue'));
end;

procedure TLazyTest.TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
begin
  Assert.IsTrue(IsLazy(FContext.GetType(TypeInfo(Lazy<TMyEntity>))));
end;

procedure TLazyTest.TheSetLazyValueFunctionMustBePublicInTheLazyRecordToDontBeRemovedFromRTTIInformation;
begin
  var RttiType := FContext.GetType(TypeInfo(Lazy<TMyEntity>));

  Assert.IsNotNil(RttiType.GetMethod('SetLazyValue'));
end;

procedure TLazyTest.WhenFillTheLazyValuePropertyMustReturnTheValueAsExpected;
begin
  var LazyValue: ILazyValue := TLazyLoader.Create(nil, nil, nil);
  var MyLazy: Lazy<TMyEntity>;

  MyLazy.LazyValue := LazyValue;

  Assert.AreEqual(Pointer(LazyValue), Pointer(MyLazy.LazyValue));
end;

procedure TLazyTest.WhenGetLazyTypeMustReturnTheRttiTypeAsExpected;
begin
  Assert.AreEqual(FContext.GetType(TMyEntity), GetLazyType(FContext.GetType(TypeInfo(Lazy<TMyEntity>))));
end;

procedure TLazyTest.WhenLoadTheLazyValueMustReturnTheValueLoaded;
begin
  var LazyClass := TLazyClass.Create;
  var MyEntity := TMyEntity.Create;

  LazyClass.Lazy := MyEntity;

  Assert.AreEqual(MyEntity, LazyClass.Lazy.Value);

  LazyClass.Free;

  MyEntity.Free;
end;

procedure TLazyTest.WhenTheLazyValueIsFilledTheHasValueFunctionMustReturnTrue;
begin
  var MyLazy: Lazy<TMyEntity>;

  MyLazy.LazyValue.Value := 10;

  Assert.IsTrue(MyLazy.HasValue);
end;

procedure TLazyTest.WhenTheLazyValueIsntLoadedMustReturnTheTypeInfoFromTheTypeAsExpected;
begin
  var LazyClass := TLazyClass.Create;

  Assert.AreEqual(TypeInfo(TMyEntity), LazyClass.Lazy.LazyValue.Value.TypeInfo);

  LazyClass.Free;
end;

{ TLazyValueTest }

procedure TLazyValueTest.Setup;
begin
  FLazyValue := TLazyValue.Create(nil, nil);
end;

procedure TLazyValueTest.TearDown;
begin
  FLazyValue := nil;
end;

procedure TLazyValueTest.WhenCreateTheLazyValueWithOneValueMustReturnThisValue;
begin
  var MyObject := TObject.Create;

  FLazyValue := TLazyValue.Create(TypeInfo(TObject), @MyObject);

  Assert.AreEqual(MyObject, FLazyValue.Value.AsObject);

  MyObject.Free;
end;

procedure TLazyValueTest.WhenFillTheValueMustReturnTheFilledValue;
begin
  FLazyValue.Value := 10;

  Assert.AreEqual(10, FLazyValue.Value.AsInteger);
end;

procedure TLazyValueTest.WhenGetTheKeyOfAnUnloadedLazyFieldMustReturnEmpty;
begin
  Assert.IsTrue(FLazyValue.Key.IsEmpty);
end;

procedure TLazyValueTest.WhenTheLazyValueIsUnloadedMustReturnTheValueEmptyButWithTheTypeInfoLoaded;
begin
  FLazyValue := TLazyValue.Create(TypeInfo(TObject), nil);

  Assert.AreEqual(TypeInfo(TObject), FLazyValue.Value.TypeInfo);
end;

procedure TLazyValueTest.WhenTheValueIsFilledTheHasValueFunctionMustReturnTrue;
begin
  FLazyValue.Value := 10;

  Assert.IsTrue(FLazyValue.HasValue);
end;

{ TLazyLoaderTest }

procedure TLazyLoaderTest.AfterLoadTheValueMustCleanUpTheKeyValue;
begin
  var Table := FManager.Mapper.GetTable(TLazyClass);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['Lazy'], 20) as ILazyValue;

  LazyFactory.Value;

  Assert.IsTrue(LazyFactory.Key.IsEmpty);
end;

procedure TLazyLoaderTest.LoadDatabaseData;
begin
  FManager.Mapper.GetTable(TLazyArrayClassChild);

  FManager.Mapper.GetTable(TLazyClass);

  FManager.Mapper.GetTable(TLazyBuildInType);

  FManager.Mapper.GetTable(TLazyBuildInArrayType);

  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into MyEntity (Id, Name, Value) values (20, ''abc'', 123.456)');

  FManager.ExectDirect('insert into LazyClass (Id, IdLazy) values (10, 20)');

  var LazyArrayClass := TLazyArrayClass.Create;
  LazyArrayClass.Id := 10;
  LazyArrayClass.LazyArray := [TLazyArrayClassChild.Create, TLazyArrayClassChild.Create, TLazyArrayClassChild.Create];

  var AObject := TLazyBuildInType.Create;
  AObject.Id := 'LazyString';
  AObject.LazyString := 'My text';

  var AObject2 := TLazyBuildInArrayType.Create;
  AObject2.Id := 'LazyArray';
  AObject2.LazyArray := [1, 2, 3, 4];

  FManager.Insert([LazyArrayClass, AObject, AObject2]);
end;

procedure TLazyLoaderTest.Setup;
begin
  FManager := TPersistoManager.Create(nil);
  FManager.Connection := CreateConnection(FManager);
  FManager.Manipulator := CreateDatabaseManipulator(FManager);

  CreateDatabase(FManager);

  LoadDatabaseData;
end;

procedure TLazyLoaderTest.TearDown;
begin
  FManager.DropDatabase;

  FManager.Free;
end;

procedure TLazyLoaderTest.WhenFillTheValueMustCleanUpTheKeyValue;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 10) as ILazyValue;

  LazyFactory.Value := 20;

  Assert.IsTrue(LazyFactory.Key.IsEmpty);
end;

procedure TLazyLoaderTest.WhenFillTheValueMustReturnTheLoadedValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 10;

  Assert.AreEqual(10, LazyFactory.Value.AsInteger);
end;

procedure TLazyLoaderTest.WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 10) as ILazyValue;

  Assert.AreEqual(10, LazyFactory.Key.AsInteger);
end;

procedure TLazyLoaderTest.WhenTheKeyIsLoadedTheHasValueMustReturnTrue;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 10) as ILazyValue;

  Assert.IsTrue(LazyFactory.HasValue);
end;

procedure TLazyLoaderTest.WhenTheLazyKeyIsEmptyCantTryToLoadTheValueFromDatabase;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil) as ILazyValue;

  Assert.WillNotRaise(
    procedure
    begin
      LazyFactory.Value;
    end);
end;

procedure TLazyLoaderTest.WhenTheValueIsLoadedTheHasValueMustReturnTrue;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 10;

  Assert.IsTrue(LazyFactory.HasValue);
end;

procedure TLazyLoaderTest.WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
begin
  var Table := FManager.Mapper.GetTable(TLazyClass);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['Lazy'], 20) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  Assert.IsNotNil(LazyFactory.Value.AsObject);
end;

procedure TLazyLoaderTest.WhenTheValueIsntLoadedMustLoadTheArrayValueFromDatabase;
begin
  var LazyField := FManager.Mapper.GetTable(TLazyArrayClass).Field['LazyArray'];

  var LazyFactory := TLazyLoader.Create(FManager, LazyField, 10) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  var ArrayValue := LazyFactory.Value.AsType<TArray<TLazyArrayClassChild>>;

  Assert.AreEqual(3, Length(ArrayValue));
end;

procedure TLazyLoaderTest.WhenLoadTheArrayLazyFieldMustReturnTheValueFromDatabase;
begin
  var Table := FManager.Mapper.GetTable(TLazyBuildInArrayType);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['LazyArray'], 'LazyArray') as ILazyValue;

  Assert.AreEqual(4, LazyFactory.Value.ArrayLength);
end;

procedure TLazyLoaderTest.WhenLoadTheLazyArrayFieldCantRaiseAnyError;
begin
  var Table := FManager.Mapper.GetTable(TLazyBuildInArrayType);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['LazyArray'], 'LazyArray') as ILazyValue;

  Assert.WillNotRaise(
    procedure
    begin
      LazyFactory.Value;
    end);
end;

procedure TLazyLoaderTest.WhenLoadTheLazyFieldCantRaiseAnyError;
begin
  var Table := FManager.Mapper.GetTable(TLazyBuildInType);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['LazyString'], 'LazyString') as ILazyValue;

  Assert.WillNotRaise(
    procedure
    begin
      LazyFactory.Value;
    end);
end;

procedure TLazyLoaderTest.WhenLoadTheStringLazyFieldMustReturnTheValueFromDatabase;
begin
  var Table := FManager.Mapper.GetTable(TLazyBuildInType);

  var LazyFactory := TLazyLoader.Create(FManager, Table.Field['LazyString'], 'LazyString') as ILazyValue;

  Assert.AreEqual('My text', LazyFactory.Value.AsString);
end;

end.

