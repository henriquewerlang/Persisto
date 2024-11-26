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
    procedure WhenLoadTheLazyValueMustReturnTheValueLoaded;
    [Test]
    procedure TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
    [Test]
    procedure WhenGetLazyTypeMustReturnTheRttiTypeAsExpected;
    [Test]
    procedure WhenTheLazyValueIsntLoadedMustReturnTheTypeInfoFromTheTypeAsExpected;
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
  end;

  [TestFixture]
  TLazyLoaderObjectTest = class
  private
    FManager: TManager;

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
  end;

  [TestFixture]
  TLazyLoaderManyValueTest = class
  private
    FManager: TManager;

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
    procedure WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
  end;

implementation

uses System.TypInfo, Persisto.Test.Entity, Persisto.Test.Connection;

{ TLazyTest }

procedure TLazyTest.TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
begin
  Assert.IsTrue(IsLazy(FContext.GetType(TypeInfo(Lazy<TMyEntity>))));
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

procedure TLazyTest.WhenTheLazyValueIsntLoadedMustReturnTheTypeInfoFromTheTypeAsExpected;
begin
  var LazyClass := TLazyClass.Create;

  Assert.AreEqual(TypeInfo(TMyEntity), LazyClass.Lazy.LazyValue.Value.TypeInfo);
end;

{ TLazyValueTest }

procedure TLazyValueTest.Setup;
begin
  FLazyValue := TLazyValue.Create(nil);
end;

procedure TLazyValueTest.TearDown;
begin
  FLazyValue := nil;
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
  FLazyValue := TLazyValue.Create(TypeInfo(TObject));

  Assert.AreEqual(TypeInfo(TObject), FLazyValue.Value.TypeInfo);
end;

{ TLazyLoaderObjectTest }

procedure TLazyLoaderObjectTest.LoadDatabaseData;
begin
  RebootDatabase;

  FManager.Mapper.GetTable(TLazyClass);

  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into MyEntity (Id, Name, Value) values (20, ''abc'', 123.456)');

  FManager.ExectDirect('insert into LazyClass (Id, IdLazy) values (10, 20)');
end;

procedure TLazyLoaderObjectTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  LoadDatabaseData;
end;

procedure TLazyLoaderObjectTest.TearDown;
begin
  FManager.Free;
end;

procedure TLazyLoaderObjectTest.WhenFillTheValueMustCleanUpTheKeyValue;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 10, nil) as ILazyValue;

  LazyFactory.Value := 20;

  Assert.IsTrue(LazyFactory.Key.IsEmpty);
end;

procedure TLazyLoaderObjectTest.WhenFillTheValueMustReturnTheLoadedValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 10;

  Assert.AreEqual(10, LazyFactory.Value.AsInteger);
end;

procedure TLazyLoaderObjectTest.WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 10, nil) as ILazyValue;

  Assert.AreEqual(10, LazyFactory.Key.AsInteger);
end;

procedure TLazyLoaderObjectTest.WhenTheLazyKeyIsEmptyCantTryToLoadTheValueFromDatabase;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil, nil) as ILazyValue;

  Assert.WillNotRaise(
    procedure
    begin
      LazyFactory.Value;
    end);
end;

procedure TLazyLoaderObjectTest.WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
begin
  var LazyFactory := TLazyLoader.Create(FManager, FManager.Mapper.GetTable(TMyEntity).PrimaryKey, 20, TypeInfo(TMyEntity)) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  Assert.IsNotNil(LazyFactory.Value.AsObject);
end;

{ TLazyLoaderManyValueTest }

procedure TLazyLoaderManyValueTest.LoadDatabaseData;
begin
  RebootDatabase;

  FManager.Mapper.GetTable(TLazyArrayClassChild);

  FManager.UpdateDatabaseSchema;

  var LazyArrayClass := TLazyArrayClass.Create;
  LazyArrayClass.Id := 10;
  LazyArrayClass.LazyArray := [TLazyArrayClassChild.Create, TLazyArrayClassChild.Create, TLazyArrayClassChild.Create];

  FManager.Insert([LazyArrayClass]);
end;

procedure TLazyLoaderManyValueTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  LoadDatabaseData;
end;

procedure TLazyLoaderManyValueTest.TearDown;
begin
  FManager.Free;
end;

procedure TLazyLoaderManyValueTest.WhenFillTheValueMustReturnTheLoadedValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 20;

  Assert.AreEqual(20, LazyFactory.Value.AsInteger);
end;

procedure TLazyLoaderManyValueTest.WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
begin
  var LazyFactory := TLazyLoader.Create(nil, nil, 20, nil) as ILazyValue;

  Assert.AreEqual(20, LazyFactory.Key.AsInteger);
end;

procedure TLazyLoaderManyValueTest.WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
begin
  var Field := FManager.Mapper.GetTable(TLazyArrayClassChild).Field['LazyArrayClass'];
  var LazyFactory := TLazyLoader.Create(FManager, Field, 10, TypeInfo(TArray<TObject>)) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  var ArrayValue := LazyFactory.Value.AsType<TArray<TObject>>;

  Assert.AreEqual(3, Length(ArrayValue));
end;

end.

