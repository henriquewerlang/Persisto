unit Delphi.ORM.Lazy.Factory.Test;

interface

uses DUnitX.TestFramework, Delphi.Mock, Delphi.Mock.Intf, Delphi.ORM.Cache, Delphi.ORM.Database.Connection, Delphi.ORM.Lazy, Delphi.ORM.Cursor.Mock;

type
  [TestFixture]
  TLazyFactoryTest = class
  private
    FCache: ICache;
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
  end;

implementation

uses System.Rtti, Delphi.ORM.Lazy.Factory, Delphi.ORM.Test.Entity, Delphi.ORM.Rtti.Helper;

{ TLazyFactoryTest }

procedure TLazyFactoryTest.Setup;
begin
  FCache := TCache.Create;
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FCursorClass := TCursorMock.Create;
  FFactory := TLazyFactory.Create(FConnection.Instance, FCache);

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

end.

