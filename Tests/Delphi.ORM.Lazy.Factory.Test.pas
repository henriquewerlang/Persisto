unit Delphi.ORM.Lazy.Factory.Test;

interface

uses DUnitX.TestFramework, Delphi.Mock, Delphi.Mock.Intf, Delphi.ORM.Cache, Delphi.ORM.Database.Connection, Delphi.ORM.Lazy, Delphi.ORM.Cursor.Mock;

type
  [TestFixture]
  TLazyFactoryTest = class
  private
    FCache: IMock<ICache>;
    FCursor: IDatabaseCursor;
    FCursorClass: TCursorMock;
    FConnection: IMock<IDatabaseConnection>;
    FFactory: ILazyFactory;
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
    procedure WhenTheLoadedPropertyIsAnArrayMustReturnAnArray;
    [Test]
    procedure WhenTheLoadedPropertyIsAnArrayCantRaiseErrorOfWrongType;
    [Test]
    procedure WhenTheLazyValueIsAnClassMustGetTheValueInTheCache;
    [Test]
    procedure WhenTheLoadedValueIsArrayCantLoadTheValueFromTheCache;
    [Test]
    procedure WhenGetTheValueFromCacheMustLoadTheCacheKeyOfTheClass;
    [Test]
    procedure WhenFindTheValueInCacheCantOpenTheCursorToLoadTheClass;
    [Test]
    procedure WhenTheValueIsInTheCacheMustReturnThisValue;
  end;

implementation

uses System.Rtti, Delphi.ORM.Lazy.Factory, Delphi.ORM.Test.Entity, Delphi.ORM.Rtti.Helper, Delphi.ORM.Shared.Obj;

{ TLazyFactoryTest }

procedure TLazyFactoryTest.Setup;
begin
  FCache := TMock.CreateInterface<ICache>(True);
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FFactory := TLazyFactory.Create(FConnection.Instance, FCache.Instance);

  FCursor := FCursorClass;

  FConnection.Setup.WillReturn(TValue.From(FCursor)).When.OpenCursor(It.IsAny<String>);
end;

procedure TLazyFactoryTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TLazyFactoryTest.TearDown;
begin
  FCache := nil;
  FConnection := nil;
  FCursor := nil;
  FFactory := nil;
end;

procedure TLazyFactoryTest.WhenFindTheValueInCacheCantOpenTheCursorToLoadTheClass;
begin
  var MyClass := TLazyClass.Create;
  var SharedObject := TSharedObject.Create(MyClass) as ISharedObject;

  FCache.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Params[2] := TValue.From(SharedObject);
      Result := True;
    end).When.Get(It.IsEqualTo(TCache.GenerateKey(TLazyClass, 123)), ItReference<ISharedObject>.IsAny.Value);

  FConnection.Expect.Never.When.OpenCursor(It.IsAny<String>);

  FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123);

  Assert.CheckExpectation(FConnection.CheckExpectations);
end;

procedure TLazyFactoryTest.WhenGetTheValueFromCacheMustLoadTheCacheKeyOfTheClass;
begin
  FCache.Expect.Once.When.Get(It.IsEqualTo(TCache.GenerateKey(TLazyClass, 123)), ItReference<ISharedObject>.IsAny.Value);

  FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123);

  Assert.CheckExpectation(FCache.CheckExpectations);
end;

procedure TLazyFactoryTest.WhenLoadTheValueMustBuildTheSelectHasExpected;
begin
  FConnection.Expect.Once.When.OpenCursor(It.IsEqualTo(
    'select T1.Id F1,' +
           'T1.IdLazy F2 ' +
      'from LazyClass T1 ' +
     'where T1.IdLazy=123'));

  FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123);

  Assert.CheckExpectation(FConnection.CheckExpectations);
end;

procedure TLazyFactoryTest.WhenLoadTheValueMustReturnTheLoadedObject;
begin
  FCursorClass.Values := [[111, 222]];
  var Value := FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123);

  Assert.IsNotNull(Value.AsObject);
end;

procedure TLazyFactoryTest.WhenTheLazyValueIsAnClassMustGetTheValueInTheCache;
begin
  FCache.Expect.Never.When.Get(It.IsAny<String>, ItReference<ISharedObject>.IsAny.Value);

  FFactory.Load(GetRttiType(TypeInfo(TArray<TLazyArrayClassChild>)), 'LazyArrayClass', 123);

  Assert.CheckExpectation(FCache.CheckExpectations);
end;

procedure TLazyFactoryTest.WhenTheLoadedPropertyIsAnArrayCantRaiseErrorOfWrongType;
begin
  FCursorClass.Values := [[111, 222, 333]];

  Assert.WillNotRaise(
    procedure
    begin
      var Value := FFactory.Load(GetRttiType(TypeInfo(TArray<TLazyArrayClassChild>)), 'LazyArrayClass', 123);

      Value.AsType<TArray<TLazyClass>>[0].Free;
    end);
end;

procedure TLazyFactoryTest.WhenTheLoadedPropertyIsAnArrayMustReturnAnArray;
begin
  FCursorClass.Values := [[111, 222, 333]];
  var Value := FFactory.Load(GetRttiType(TypeInfo(TArray<TLazyArrayClassChild>)), 'LazyArrayClass', 123);

  Assert.IsTrue(Value.IsArray);
end;

procedure TLazyFactoryTest.WhenTheLoadedValueIsArrayCantLoadTheValueFromTheCache;
begin
  FCache.Expect.Once.When.Get(It.IsAny<String>, ItReference<ISharedObject>.IsAny.Value);

  FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123);

  Assert.CheckExpectation(FCache.CheckExpectations);
end;

procedure TLazyFactoryTest.WhenTheValueIsInTheCacheMustReturnThisValue;
begin
  var MyClass := TLazyClass.Create;
  var SharedObject := TSharedObject.Create(MyClass) as ISharedObject;

  FCache.Setup.WillExecute(
    function (const Params: TArray<TValue>): TValue
    begin
      Params[2] := TValue.From(SharedObject);
      Result := True;
    end).When.Get(It.IsEqualTo(TCache.GenerateKey(TLazyClass, 123)), ItReference<ISharedObject>.IsAny.Value);

  Assert.AreEqual(MyClass, FFactory.Load(GetRttiType(TLazyClass), 'Lazy', 123).AsType<TLazyClass>);
end;

end.

