unit Delphi.ORM.Lazy.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Test.Entity, Delphi.ORM.Lazy, Delphi.ORM.Cache, Delphi.Mock.Intf;

type
  [TestFixture]
  TLazyTest = class
  private
    FClass: TLazyClass;
    FContext: TRttiContext;
    FLazyLoader: IMock<ILazyLoader>;
    FLazyProperty: TRttiProperty;
    FRttiType: TRttiType;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenFillTheValueMustReturnTheValueFilled;
    [Test]
    procedure WhenTheValueIsFilledTheHasValueFunctionMustReturnTrue;
    [Test]
    procedure WhenCallTheSetLazyValueAcessProcedureMustFillTheInternalAccessOfTheRecord;
    [Test]
    procedure WhenTheValueIsEmptyAndTheAccessFieldIsLoadedMustReturnTrueInTheHasValueFunction;
    [Test]
    procedure WhenFillTheValueMustFillWithNilTheLazyLoaderField;
    [Test]
    procedure WhenGetValueFromTheLazyFieldMoreThenOnceMustCallOnlyOnceTheLoader;
    [Test]
    procedure WhenOnlyCreatesTheClassAndTryToGetTheValueMustReturnNil;
    [Test]
    procedure TheValueOfTheLoaderMustBeReturnedInTheValuePropertyIfItExists;
    [Test]
    procedure WhenLazySetValueMustLoadTheValuePassedToTheLazyProperty;
    [Test]
    procedure AfterLoadedTheValueTheLoaderMustBeCleared;
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Rtti.Helper, Delphi.ORM.Lazy.Manipulator;

{ TLazyTest }

procedure TLazyTest.AfterLoadedTheValueTheLoaderMustBeCleared;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FClass, FLazyProperty);
  Manipulator.Loader := FLazyLoader.Instance;

  FLazyLoader.Setup.WillReturn(TValue.Empty).When.LoadValue;

  FClass.Lazy.Value;

  Assert.IsNull(Manipulator.Loader);
end;

procedure TLazyTest.Setup;
begin
  FClass := TLazyClass.Create;
  FContext := TRttiContext.Create;
  FLazyLoader := TMock.CreateInterface<ILazyLoader>;
  FRttiType := FContext.GetType(TLazyClass);

  FLazyProperty := FRttiType.GetProperty('Lazy');

  FLazyLoader.Setup.WillReturn(123).When.GetKey;
end;

procedure TLazyTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TLazyTest.TearDown;
begin
  FLazyLoader := nil;

  FContext.Free;

  FClass.Free;
end;

procedure TLazyTest.TheValueOfTheLoaderMustBeReturnedInTheValuePropertyIfItExists;
begin
  var MyClass := TMyEntity.Create;

  FLazyLoader.Setup.WillReturn(MyClass).When.LoadValue;

  TLazyManipulator.GetManipulator(FClass, FLazyProperty).Loader := FLazyLoader.Instance;

  Assert.AreEqual(MyClass, FClass.Lazy.Value);

  MyClass.Free;
end;

procedure TLazyTest.WhenCallTheSetLazyValueAcessProcedureMustFillTheInternalAccessOfTheRecord;
begin
  TLazyManipulator.GetManipulator(FClass.Lazy).Loader := FLazyLoader.Instance;

  Assert.AreEqual(FLazyLoader.Instance, TLazyManipulator.GetManipulator(FClass.Lazy).Loader);
end;

procedure TLazyTest.WhenFillTheValueMustFillWithNilTheLazyLoaderField;
begin
  TLazyManipulator.GetManipulator(FClass.Lazy).Loader := FLazyLoader.Instance;

  FClass.Lazy.Value := nil;

  Assert.IsNull(TLazyManipulator.GetManipulator(FClass.Lazy).Loader);
end;

procedure TLazyTest.WhenFillTheValueMustReturnTheValueFilled;
begin
  var MyClass := TMyEntity.Create;

  FClass.Lazy.Value := MyClass;

  Assert.AreEqual(MyClass, FClass.Lazy.Value);

  MyClass.Free;
end;

procedure TLazyTest.WhenGetValueFromTheLazyFieldMoreThenOnceMustCallOnlyOnceTheLoader;
begin
  FLazyLoader.Expect.Once.When.LoadValue;

  TLazyManipulator.GetManipulator(FClass, FLazyProperty).Loader := FLazyLoader.Instance;

  FClass.Lazy.Value;

  FClass.Lazy.Value;

  FClass.Lazy.Value;

  Assert.CheckExpectation(FLazyLoader.CheckExpectations);
end;

procedure TLazyTest.WhenLazySetValueMustLoadTheValuePassedToTheLazyProperty;
begin
  var MyClass := TMyEntity.Create;

  TLazyManipulator.GetManipulator(FClass, FLazyProperty).Value := MyClass;

  Assert.AreEqual(MyClass, FClass.Lazy.Value);

  MyClass.Free;
end;

procedure TLazyTest.WhenOnlyCreatesTheClassAndTryToGetTheValueMustReturnNil;
begin
  Assert.IsNull(FClass.Lazy.Value);
end;

procedure TLazyTest.WhenTheValueIsEmptyAndTheAccessFieldIsLoadedMustReturnTrueInTheHasValueFunction;
begin
  TLazyManipulator.GetManipulator(FClass, FLazyProperty).Loader := FLazyLoader.Instance;

  Assert.IsTrue(FClass.Lazy.HasValue);
end;

procedure TLazyTest.WhenTheValueIsFilledTheHasValueFunctionMustReturnTrue;
begin
  var MyClass := TMyEntity.Create;

  FClass.Lazy.Value := MyClass;

  Assert.IsTrue(FClass.Lazy.HasValue);

  MyClass.Free;
end;

end.

