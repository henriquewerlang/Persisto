unit Delphi.ORM.Lazy.Factory.Test;

interface

uses DUnitX.TestFramework, Delphi.Mock, Delphi.Mock.Intf, Delphi.ORM.Cache, Delphi.ORM.Database.Connection, Delphi.ORM.Lazy, Delphi.ORM.Cursor.Mock, Delphi.ORM.Mapper,
  Delphi.ORM.Test.Entity;

type
  [TestFixture]
  TLazyFactoryTest = class
  public
    [Test]
    procedure WhenCreateTheFactoryForASingleClassMustCreateTheSingleFactory;
    [Test]
    procedure WhenCreateTheFactoryForAManyValueClassMustCreateTheManyValueFactory;
  end;

  [TestFixture]
  TLazySingleClassFactoryTest = class
  private
    FCache: IMock<ICache>;
    FCacheClass: TMyEntity;
    FCursor: IDatabaseCursor;
    FCursorClass: TCursorMock;
    FConnection: IMock<IDatabaseConnection>;
    FLazyField: TField;
    FTable: TTable;
    FLoader: ILazyLoader;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenLoadTheValueMustBuildTheSelectHasExpected;
    [Test]
    procedure WhenLoadTheValueMustReturnTheLoadedObject;
    [Test]
    procedure WhenTheLazyValueIsAnClassMustGetTheValueInTheCache;
    [Test]
    procedure WhenFindTheValueInCacheCantOpenTheCursorToLoadTheClass;
    [Test]
    procedure WhenTheValueIsInTheCacheMustReturnThisValue;
    [Test]
    procedure WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
  end;

  [TestFixture]
  TLazyManyValueClassFactoryTest = class
  private
    FCursor: IDatabaseCursor;
    FCursorClass: TCursorMock;
    FConnection: IMock<IDatabaseConnection>;
    FLazyField: TField;
    FLoader: ILazyLoader;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenLoadTheValueMustBuildTheSelectHasExpected;
    [Test]
    procedure WhenLoadTheValueMustReturnArrayOfObjectsHasExpected;
    [Test]
    procedure WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
    [Test]
    procedure TheArrayTypeMustBeEqualOfTheLazyFieldType;
  end;

implementation

uses System.Rtti, Delphi.ORM.Lazy.Factory, Delphi.ORM.Rtti.Helper;

{ TLazySingleClassFactoryTest }

procedure TLazySingleClassFactoryTest.Setup;
begin
  FCache := TMock.CreateInterface<ICache>(True);
  FCacheClass := TMyEntity.Create;
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FLazyField := TMapper.Default.FindTable(TLazyArrayClass).Field['Lazy'];
  FTable := TMapper.Default.FindTable(TMyEntity);

  FCursor := FCursorClass;
  FLoader := TLazySingleClassFactory.Create(FConnection.Instance, FCache.Instance, FLazyField, 1234);

  FCache.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Result := False;
    end).When.Get(It.IsAny<String>, ItReference<TObject>.IsAny.Value);

  FCache.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Result := True;
      Params[2] := FCacheClass;
    end).When.Get(It.IsEqualTo(FTable.GetCacheKey(12345)), ItReference<TObject>.IsAny.Value);

  FConnection.Setup.WillReturn(TValue.From(FCursor)).When.OpenCursor(It.IsAny<String>);
end;

procedure TLazySingleClassFactoryTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TLazySingleClassFactoryTest.TearDown;
begin
  FCache := nil;
  FConnection := nil;
  FCursor := nil;
  FLoader := nil;

  FCacheClass.Free;
end;

procedure TLazySingleClassFactoryTest.WhenFindTheValueInCacheCantOpenTheCursorToLoadTheClass;
begin
  FLoader := TLazySingleClassFactory.Create(FConnection.Instance, FCache.Instance, FLazyField, 12345);

  FConnection.Expect.Never.When.OpenCursor(It.IsAny<String>);

  var Value := FLoader.LoadValue;

  Assert.CheckExpectation(FConnection.CheckExpectations);
end;

procedure TLazySingleClassFactoryTest.WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
begin
  Assert.AreEqual<Integer>(1234, FLoader.GetKey.AsInteger);
end;

procedure TLazySingleClassFactoryTest.WhenLoadTheValueMustBuildTheSelectHasExpected;
 begin
  FConnection.Expect.Once.When.OpenCursor(It.IsEqualTo(
    'select T1.Id F1,' +
           'T1.Name F2,' +
           'T1.Value F3 ' +
      'from MyEntity T1 ' +
     'where T1.Id=1234'));

  var Value := FLoader.LoadValue;

  Assert.CheckExpectation(FConnection.CheckExpectations);

  Value.AsObject.Free;
end;

procedure TLazySingleClassFactoryTest.WhenLoadTheValueMustReturnTheLoadedObject;
begin
  FCursorClass.Values := [[111, 'abc', 333]];
  var Value := FLoader.LoadValue;

  Assert.IsNotNull(Value.AsObject);

  Value.AsObject.Free;
end;

procedure TLazySingleClassFactoryTest.WhenTheLazyValueIsAnClassMustGetTheValueInTheCache;
begin
  FCache.Expect.Once.When.Get(It.IsEqualTo(FTable.GetCacheKey(1234)), ItReference<TObject>.IsAny.Value);

  var Value := FLoader.LoadValue;

  Assert.CheckExpectation(FCache.CheckExpectations);

  Value.AsObject.Free;
end;

procedure TLazySingleClassFactoryTest.WhenTheValueIsInTheCacheMustReturnThisValue;
begin
  FLoader := TLazySingleClassFactory.Create(FConnection.Instance, FCache.Instance, FLazyField, 12345);

  var Value := FLoader.LoadValue;

  Assert.AreEqual<TObject>(FCacheClass, Value.AsObject);
end;

{ TLazyManyValueClassFactoryTest }

procedure TLazyManyValueClassFactoryTest.Setup;
begin
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FLazyField := TMapper.Default.FindTable(TLazyArrayClass).Field['LazyArray'];

  FCursor := FCursorClass;
  FLoader := TLazyManyValueClassFactory.Create(FConnection.Instance, TCache.Create, FLazyField, 1234);

  FConnection.Setup.WillReturn(TValue.From(FCursor)).When.OpenCursor(It.IsAny<String>);
end;

procedure TLazyManyValueClassFactoryTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TLazyManyValueClassFactoryTest.TearDown;
begin
  FConnection := nil;
  FCursor := nil;
  FLoader := nil;
end;

procedure TLazyManyValueClassFactoryTest.TheArrayTypeMustBeEqualOfTheLazyFieldType;
begin
  FCursorClass.Values := [[111, 111, 333], [222, 111, 333], [333, 111, 333]];

  var Value := FLoader.LoadValue;

  Assert.AreEqual(FLazyField.FieldType.Handle, Value.TypeInfo);
end;

procedure TLazyManyValueClassFactoryTest.WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
begin
  Assert.AreEqual<Integer>(1234, FLoader.GetKey.AsInteger);
end;

procedure TLazyManyValueClassFactoryTest.WhenLoadTheValueMustBuildTheSelectHasExpected;
begin
  FConnection.Expect.Once.When.OpenCursor(It.IsEqualTo(
       'select T1.Id F1,' +
              'T2.Id F2,' +
              'T2.IdLazy F3 ' +
         'from LazyArrayClassChild T1 ' +
    'left join LazyArrayClass T2 ' +
           'on T1.IdLazyArrayClass=T2.Id ' +
        'where T1.IdLazyArrayClass=1234'));

  FLoader.LoadValue;

  Assert.CheckExpectation(FConnection.CheckExpectations);
end;

procedure TLazyManyValueClassFactoryTest.WhenLoadTheValueMustReturnArrayOfObjectsHasExpected;
begin
  FCursorClass.Values := [[111, 111, 333], [222, 111, 333], [333, 111, 333]];

  var Value := FLoader.LoadValue;

  Assert.IsFalse(Value.IsEmpty);

  Assert.AreEqual(3, Value.ArrayLength);
end;

{ TLazyFactoryTest }

procedure TLazyFactoryTest.WhenCreateTheFactoryForAManyValueClassMustCreateTheManyValueFactory;
begin
  var Instance := CreateLoader(nil, nil, TMapper.Default.FindTable(TLazyArrayClass).Field['LazyArray'], 0);

  Assert.IsNotNull(Instance);

  Assert.AreEqual(TLazyManyValueClassFactory.ClassName, TObject(Instance).ClassName);
end;

procedure TLazyFactoryTest.WhenCreateTheFactoryForASingleClassMustCreateTheSingleFactory;
begin
  var Instance := CreateLoader(nil, nil, TMapper.Default.FindTable(TLazyArrayClass).Field['Lazy'], 0);

  Assert.IsNotNull(Instance);

  Assert.AreEqual(TLazySingleClassFactory.ClassName, TObject(Instance).ClassName);
end;

end.

