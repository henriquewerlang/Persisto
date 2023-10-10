unit Persisto.Lazy.Test;

interface

uses DUnitX.TestFramework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TLazyTest = class
  public
    [Test]
    procedure WhenLoadTheLazyValueMustReturnTheValueLoaded;
    [Test]
    procedure TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
    [Test]
    procedure WhenGetLazyTypeMustReturnTheRttiTypeAsExpected;
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
  end;

  [TestFixture]
  TLazyFactoryObjectTest = class
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
  end;

  [TestFixture]
  TLazyFactoryManyValueTest = class
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

uses Persisto.Test.Entity, Persisto.Test.Connection;

{ TLazyTest }

procedure TLazyTest.TheIsLazyFunctionMustReturnTrueIfTheValueIsLazy;
begin
  Assert.IsTrue(IsLazy(GetRttiType(TypeInfo(Lazy<TMyEntity>))));
end;

procedure TLazyTest.WhenGetLazyTypeMustReturnTheRttiTypeAsExpected;
begin
  Assert.AreEqual(GetRttiType(TMyEntity), GetLazyType(GetRttiType(TypeInfo(Lazy<TMyEntity>))));
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

{ TLazyValueTest }

procedure TLazyValueTest.Setup;
begin
  FLazyValue := TLazyValue.Create;
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

{ TLazyFactoryObjectTest }

procedure TLazyFactoryObjectTest.LoadDatabaseData;
begin
  RebootDatabase;

  FManager.Mapper.GetTable(TLazyClass);

  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into MyEntity (Id, Name, Value) values (20, ''abc'', 123.456)');

  FManager.ExectDirect('insert into LazyClass (Id, IdLazy) values (10, 20)');
end;

procedure TLazyFactoryObjectTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  LoadDatabaseData;
end;

procedure TLazyFactoryObjectTest.TearDown;
begin
  FManager.Free;
end;

procedure TLazyFactoryObjectTest.WhenFillTheValueMustCleanUpTheKeyValue;
begin
  var LazyFactory := TLazyFactory.Create(nil, nil, 10, nil) as ILazyValue;

  LazyFactory.Value := 20;

  Assert.IsTrue(LazyFactory.Key.IsEmpty);
end;

procedure TLazyFactoryObjectTest.WhenFillTheValueMustReturnTheLoadedValueAsExpected;
begin
  var LazyFactory := TLazyFactory.Create(nil, nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 10;

  Assert.AreEqual(10, LazyFactory.Value.AsInteger);
end;

procedure TLazyFactoryObjectTest.WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
begin
  var LazyFactory := TLazyFactory.Create(nil, nil, 10, nil) as ILazyValue;

  Assert.AreEqual(10, LazyFactory.Key.AsInteger);
end;

procedure TLazyFactoryObjectTest.WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
begin
  var LazyFactory := TLazyFactory.Create(FManager, FManager.Mapper.GetTable(TMyEntity).PrimaryKey, 20, TypeInfo(TMyEntity)) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  Assert.IsNotNull(LazyFactory.Value.AsObject);
end;

{ TLazyFactoryManyValueTest }

procedure TLazyFactoryManyValueTest.LoadDatabaseData;
begin
  RebootDatabase;

  FManager.Mapper.GetTable(TLazyArrayClassChild);

  FManager.UpdateDatabaseSchema;

  FManager.ExectDirect('insert into LazyArrayClassChild (Id, IdLazyArrayClass) values (1, 10)');

  FManager.ExectDirect('insert into LazyArrayClassChild (Id, IdLazyArrayClass) values (2, 10)');

  FManager.ExectDirect('insert into LazyArrayClassChild (Id, IdLazyArrayClass) values (3, 10)');
end;

procedure TLazyFactoryManyValueTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDatabaseManipulator);

  LoadDatabaseData;
end;

procedure TLazyFactoryManyValueTest.TearDown;
begin
  FManager.Free;
end;

procedure TLazyFactoryManyValueTest.WhenFillTheValueMustReturnTheLoadedValueAsExpected;
begin
  var LazyFactory := TLazyFactory.Create(nil, nil, nil, nil) as ILazyValue;

  LazyFactory.Value := 20;

  Assert.AreEqual(20, LazyFactory.Value.AsInteger);
end;

procedure TLazyFactoryManyValueTest.WhenGetTheKeyValueFromTheLazyValueFactoryMustReturnTheValueAsExpected;
begin
  var LazyFactory := TLazyFactory.Create(nil, nil, 20, nil) as ILazyValue;

  Assert.AreEqual(20, LazyFactory.Key.AsInteger);
end;

procedure TLazyFactoryManyValueTest.WhenTheValueIsntLoadedMustLoadTheValueFromDatabase;
begin
  var Field := FManager.Mapper.GetTable(TLazyArrayClassChild).Field['LazyArrayClass'];
  var LazyFactory := TLazyFactory.Create(FManager, Field, 10, TypeInfo(TArray<TObject>)) as ILazyValue;

  Assert.IsFalse(LazyFactory.Value.IsEmpty);

  var ArrayValue := LazyFactory.Value.AsType<TArray<TObject>>;

  Assert.AreEqual<NativeInt>(3, Length(ArrayValue));
end;

end.

