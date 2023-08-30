unit Persisto.Lazy.Factory.Test;

interface

uses DUnitX.TestFramework, Translucent, Translucent.Intf, Persisto, Persisto.Mapping, Persisto.Cursor.Mock, Persisto.Test.Entity;

type
  [TestFixture]
  TLazySingleClassFactoryTest = class
  private
    FCursor: IDatabaseCursor;
    FCursorClass: TCursorMock;
    FConnection: IMock<IDatabaseConnection>;
    FLazyField: TField;
    FLoader: ILazyLoader;
    FManager: TManager;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenLoadTheValueMustReturnTheLoadedObject;
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
    FManager: TManager;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenLoadTheValueMustReturnArrayOfObjectsHasExpected;
    [Test]
    procedure WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
    [Test]
    procedure TheArrayTypeMustBeEqualOfTheLazyFieldType;
  end;

implementation

uses System.Rtti, Persisto.Rtti.Helper;

{ TLazySingleClassFactoryTest }

procedure TLazySingleClassFactoryTest.Setup;
begin
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FManager := TManager.Create(FConnection.Instance, nil);

  FLazyField := FManager.Mapper.GetTable(TLazyArrayClass).Field['Lazy'];

  FCursor := FCursorClass;
  FLoader := TLazySingleClassFactory.Create(FManager, FLazyField, 1234);

  FConnection.Setup.WillReturn(TValue.From(FCursor)).When.OpenCursor(It.IsAny<String>);
end;

procedure TLazySingleClassFactoryTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TLazySingleClassFactoryTest.TearDown;
begin
  FConnection := nil;
  FCursor := nil;
  FLoader := nil;

  FManager.Free;
end;

procedure TLazySingleClassFactoryTest.WhenGetTheKeyOfTheLoaderMustReturnTheValueExpected;
begin
  Assert.AreEqual<Integer>(1234, FLoader.GetKey.AsInteger);
end;

procedure TLazySingleClassFactoryTest.WhenLoadTheValueMustReturnTheLoadedObject;
begin
  FCursorClass.Values := [[111, 'abc', 333]];
  var Value := FLoader.LoadValue;

  Assert.IsNotNull(Value.AsObject);

  Value.AsObject.Free;
end;

{ TLazyManyValueClassFactoryTest }

procedure TLazyManyValueClassFactoryTest.Setup;
begin
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FManager := TManager.Create(FConnection.Instance, nil);

  FLazyField := FManager.Mapper.GetTable(TLazyArrayClass).Field['LazyArray'];

  FCursor := FCursorClass;
  FLoader := TLazyManyValueClassFactory.Create(FManager, FLazyField, 1234);

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

  FManager.Free;
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

procedure TLazyManyValueClassFactoryTest.WhenLoadTheValueMustReturnArrayOfObjectsHasExpected;
begin
  FCursorClass.Values := [[111, 111, 333], [222, 111, 333], [333, 111, 333]];

  var Value := FLoader.LoadValue;

  Assert.IsFalse(Value.IsEmpty);

  Assert.AreEqual(3, Value.ArrayLength);
end;

end.

