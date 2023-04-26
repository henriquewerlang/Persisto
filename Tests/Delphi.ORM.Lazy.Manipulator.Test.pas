unit Delphi.ORM.Lazy.Manipulator.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Lazy, Delphi.ORM.Test.Entity, Delphi.Mock.Intf;

type
  [TestFixture]
  TLazyManipulatorTest = class
  private
    FContext: TRttiContext;
    FLazyClass: TLazyArrayClass;
    FLazyLoaderMock: IMock<ILazyLoader>;
    FLazyProperty: TRttiProperty;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenTheTypeIsLazyLoadingTheIsLazyLoadingFunctionMustReturnTrue;
    [Test]
    procedure WhenThePropertyIsLazyLoadingTheIsLazyLoadingFunctionMustReturnTrue;
    [Test]
    procedure TheRttiTypeFunctionMustReturnTheGenericTypeOfTheLazy;
    [Test]
    procedure TheRttiTypeFunctionMustReturnTheGenericTypeOfTheLazyProperty;
    [Test]
    procedure WhenGetManipulatorMustReturnTheInstanceWhenPassTheInstanceAndPropertyValue;
    [Test]
    procedure WhenGetManipulatorMustReturnTheInstanceWhenPassTheLazyInstanceInParam;
    [Test]
    procedure TheManipulatorMustReturnTheLazyTypeHasExpected;
    [Test]
    procedure WhenLoadTheLazyLoaderMustFillTheValueInsideTheRecord;
    [Test]
    procedure WhenLoadTheLazyLoaderMustReturnTheValueOfTheLoaderInTheProperty;
    [Test]
    procedure WhenTheLazyPropertyIsLoadedMustReturnTrueInThePropertyOfTheManipulator;
    [Test]
    procedure WhenGetValueFromTheManipulatorMustReturnTheValueLoadedInLazyProperty;
    [Test]
    procedure WhenSetTheValueInTheManipulatorMustLoadTheValueInsideTheLazyProperty;
    [Test]
    procedure WhenSetTheValueInTheManipulatorMustReturnLoaedInTheProperty;
    [Test]
    procedure WhenSetTheValueInTheManipulatorMustClearTheLoaderValue;
    [TestCase('All empty', 'False,False,False')]
    [TestCase('With value', 'True,False,True')]
    [TestCase('With loader', 'False,True,True')]
    procedure TheHasValuePropertyMustHaveTheSameBehaviorOfTheLazyRecord(const LoadValue, LoadLoader, ExpectedValue: Boolean);
    [Test]
    procedure WhenGetKeyInTheManipulatorMustReturnTheInternalKeyOfTheLazy;
    [Test]
    procedure IfTheLazyLoaderIsntLoadedMustReturnEmptyInTheGetKeyFunction;
    [Test]
    procedure WhenSetTheLoadedValueTheLazyFieldMustLoadTheInternalValueAgain;
    [Test]
    procedure WhenFillTheLoaderTheLoadedPropertyMustBeFilledWithFalseValue;
  end;

implementation

uses Delphi.ORM.Lazy.Manipulator, Delphi.Mock;

{ TLazyManipulatorTest }

procedure TLazyManipulatorTest.IfTheLazyLoaderIsntLoadedMustReturnEmptyInTheGetKeyFunction;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  Manipulator.Loader := nil;

  Assert.IsTrue(Manipulator.Key.IsEmpty);
end;

procedure TLazyManipulatorTest.Setup;
begin
  FContext := TRttiContext.Create;
  FLazyClass := TLazyArrayClass.Create;
  FLazyLoaderMock := TMock.CreateInterface<ILazyLoader>(True);
  FLazyProperty := FContext.GetType(FLazyClass.ClassType).GetProperty('Lazy');
end;

procedure TLazyManipulatorTest.TearDown;
begin
  FLazyLoaderMock := nil;

  FContext.Free;

  FLazyClass.Free;
end;

procedure TLazyManipulatorTest.TheHasValuePropertyMustHaveTheSameBehaviorOfTheLazyRecord(const LoadValue, LoadLoader, ExpectedValue: Boolean);
begin
  var MyEntity := TMyEntity.Create;
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  if LoadValue then
    Manipulator.Value := MyEntity;

  if LoadLoader then
    Manipulator.Loader := FLazyLoaderMock.Instance;

  Assert.AreEqual(ExpectedValue, Manipulator.HasValue);

  MyEntity.Free;
end;

procedure TLazyManipulatorTest.TheManipulatorMustReturnTheLazyTypeHasExpected;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Assert.AreEqual(FContext.GetType(TMyEntity), Manipulator.RttiType);
end;

procedure TLazyManipulatorTest.TheRttiTypeFunctionMustReturnTheGenericTypeOfTheLazy;
begin
  var GenericType := FContext.GetType(TypeInfo(Integer));

  Assert.AreEqual(GenericType, TLazyManipulator.GetLazyLoadingType(FContext.GetType(TypeInfo(Lazy<Integer>))));
end;

procedure TLazyManipulatorTest.TheRttiTypeFunctionMustReturnTheGenericTypeOfTheLazyProperty;
begin
  var GenericType := FContext.GetType(TMyEntity);

  Assert.AreEqual(GenericType, TLazyManipulator.GetLazyLoadingType(FLazyProperty));
end;

procedure TLazyManipulatorTest.WhenFillTheLoaderTheLoadedPropertyMustBeFilledWithFalseValue;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Manipulator.Loaded := True;

  Manipulator.Loader := FLazyLoaderMock.Instance;

  Assert.IsFalse(Manipulator.Loaded);
end;

procedure TLazyManipulatorTest.WhenGetKeyInTheManipulatorMustReturnTheInternalKeyOfTheLazy;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  Manipulator.Loader := FLazyLoaderMock.Instance;

  FLazyLoaderMock.Setup.WillReturn(1234).When.GetKey;

  Assert.AreEqual(1234, Manipulator.Key.AsInteger);
end;

procedure TLazyManipulatorTest.WhenGetManipulatorMustReturnTheInstanceWhenPassTheInstanceAndPropertyValue;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Assert.IsNotNull(Manipulator);
end;

procedure TLazyManipulatorTest.WhenGetManipulatorMustReturnTheInstanceWhenPassTheLazyInstanceInParam;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass.Lazy);

  Assert.IsNotNull(Manipulator);
end;

procedure TLazyManipulatorTest.WhenGetValueFromTheManipulatorMustReturnTheValueLoadedInLazyProperty;
begin
  FLazyClass.Lazy := TMyEntity.Create;
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Assert.AreEqual(FLazyClass.Lazy.Value, Manipulator.Value.AsType<TMyEntity>);

  FLazyClass.Lazy.Value.Free;
end;

procedure TLazyManipulatorTest.WhenLoadTheLazyLoaderMustFillTheValueInsideTheRecord;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Manipulator.Loader := FLazyLoaderMock.Instance;

  Assert.AreEqual(FLazyLoaderMock.Instance, FLazyProperty.PropertyType.GetField('FLoader').GetValue(@FLazyClass.Lazy).AsType<ILazyLoader>);
end;

procedure TLazyManipulatorTest.WhenLoadTheLazyLoaderMustReturnTheValueOfTheLoaderInTheProperty;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Manipulator.Loader := FLazyLoaderMock.Instance;

  Assert.AreEqual(FLazyLoaderMock.Instance, Manipulator.Loader);
end;

procedure TLazyManipulatorTest.WhenSetTheLoadedValueTheLazyFieldMustLoadTheInternalValueAgain;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  var MyEntity := TMyEntity.Create;

  Manipulator.Value := MyEntity;

  Manipulator.Loaded := False;

  Assert.IsFalse(Manipulator.Loaded);

  MyEntity.Free;
end;

procedure TLazyManipulatorTest.WhenSetTheValueInTheManipulatorMustClearTheLoaderValue;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  var MyEntity := TMyEntity.Create;

  Manipulator.Loader := FLazyLoaderMock.Instance;
  Manipulator.Value := MyEntity;

  Assert.IsNull(Manipulator.Loader);

  MyEntity.Free;
end;

procedure TLazyManipulatorTest.WhenSetTheValueInTheManipulatorMustLoadTheValueInsideTheLazyProperty;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  var MyEntity := TMyEntity.Create;

  Manipulator.Value := MyEntity;

  Assert.AreEqual(MyEntity, FLazyClass.Lazy.Value);

  MyEntity.Free;
end;

procedure TLazyManipulatorTest.WhenSetTheValueInTheManipulatorMustReturnLoaedInTheProperty;
begin
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);
  var MyEntity := TMyEntity.Create;

  Manipulator.Value := MyEntity;

  Assert.IsTrue(Manipulator.Loaded);

  MyEntity.Free;
end;

procedure TLazyManipulatorTest.WhenTheLazyPropertyIsLoadedMustReturnTrueInThePropertyOfTheManipulator;
begin
  FLazyClass.Lazy := TMyEntity.Create;
  var Manipulator := TLazyManipulator.GetManipulator(FLazyClass, FLazyProperty);

  Assert.IsTrue(Manipulator.Loaded);

  FLazyClass.Lazy.Value.Free;
end;

procedure TLazyManipulatorTest.WhenThePropertyIsLazyLoadingTheIsLazyLoadingFunctionMustReturnTrue;
begin
  Assert.IsTrue(TLazyManipulator.IsLazyLoading(FLazyProperty));
end;

procedure TLazyManipulatorTest.WhenTheTypeIsLazyLoadingTheIsLazyLoadingFunctionMustReturnTrue;
begin
  Assert.IsTrue(TLazyManipulator.IsLazyLoading(FContext.GetType(TypeInfo(Lazy<Integer>))));
end;

end.

