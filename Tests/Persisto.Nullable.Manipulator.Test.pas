unit Persisto.Nullable.Manipulator.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Persisto.Mapping, Persisto.Test.Entity;

type
  [TestFixture]
  TNullableManipulatorTest = class
  private
    FContext: TRttiContext;
    FNullableInstance: TClassWithNullableProperty;
    FNullableManipulator: INullableManipulator;
    FNullableProperty: TRttiProperty;
    FNullableType: TRttiInstanceType;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenCheckTheIsNullableFunctionMustReturnTrueIfThePropertyIsNullable;
    [Test]
    procedure WhenCheckTheIsNullableFunctionMustReturnTrueIfTheTypeIsNullable;
    [Test]
    procedure WhenCallGetRttiTypeFromANullablePropertyMustReturnTheTypeExpected;
    [Test]
    procedure WhenCallGetRttiTypeFromNullableMustReturnTheTypeExpected;
    [Test]
    procedure WhenCallGetManipulatorMustReturnTheInstanceOfTheManipulator;
    [Test]
    procedure WhenCallTheIsNullFunctionMustReturnTrueIfTheInternalValueIsNull;
    [Test]
    procedure WhenFillTheValueMustLoadTheValueOfTheNullableProperty;
    [Test]
    procedure WhenGetTheValueMustReturnTheValueOfTheNullableProperty;
    [Test]
    procedure WhenTheNullableIsNullMustReturnEmptyInTheGetValueProperty;
    [Test]
    procedure WhenFillAnEmptyValueMustReturnTrueInIsNullFunction;
    [Test]
    procedure WhenGetRttiTypeMustReturnTheInternalNullableType;
  end;

implementation

{ TNullableManipulatorTest }

procedure TNullableManipulatorTest.Setup;
begin
  FContext := TRttiContext.Create;
  FNullableInstance := TClassWithNullableProperty.Create;
  FNullableType := FContext.GetType(TClassWithNullableProperty).AsInstance;

  FNullableProperty := FNullableType.GetProperty('Nullable');

  FNullableManipulator := TNullableManipulator.GetManipulator(FNullableInstance, FNullableProperty);
end;

procedure TNullableManipulatorTest.TearDown;
begin
  FNullableManipulator := nil;

  FContext.Free;

  FNullableInstance.Free;
end;

procedure TNullableManipulatorTest.WhenCallGetManipulatorMustReturnTheInstanceOfTheManipulator;
begin
  Assert.IsNotNull(TNullableManipulator.GetManipulator(FNullableInstance, FNullableProperty));
end;

procedure TNullableManipulatorTest.WhenCallGetRttiTypeFromANullablePropertyMustReturnTheTypeExpected;
begin
  Assert.AreEqual(FContext.GetType(TypeInfo(Integer)), TNullableManipulator.GetNullableType(FNullableProperty));
end;

procedure TNullableManipulatorTest.WhenCallGetRttiTypeFromNullableMustReturnTheTypeExpected;
begin
  Assert.AreEqual(FContext.GetType(TypeInfo(Integer)), TNullableManipulator.GetNullableType(FNullableProperty.PropertyType));
end;

procedure TNullableManipulatorTest.WhenCallTheIsNullFunctionMustReturnTrueIfTheInternalValueIsNull;
begin
  Assert.IsTrue(FNullableManipulator.IsNull);
end;

procedure TNullableManipulatorTest.WhenCheckTheIsNullableFunctionMustReturnTrueIfThePropertyIsNullable;
begin
  Assert.IsTrue(TNullableManipulator.IsNullable(FNullableProperty));
end;

procedure TNullableManipulatorTest.WhenCheckTheIsNullableFunctionMustReturnTrueIfTheTypeIsNullable;
begin
  Assert.IsTrue(TNullableManipulator.IsNullable(FNullableProperty.PropertyType));
end;

procedure TNullableManipulatorTest.WhenFillAnEmptyValueMustReturnTrueInIsNullFunction;
begin
  FNullableInstance.Nullable := 1234;

  FNullableManipulator.Value := TValue.Empty;

  Assert.IsTrue(FNullableInstance.Nullable.IsNull);
end;

procedure TNullableManipulatorTest.WhenFillTheValueMustLoadTheValueOfTheNullableProperty;
begin
  FNullableManipulator.Value := 1234;

  Assert.AreEqual(1234, FNullableInstance.Nullable.Value);
end;

procedure TNullableManipulatorTest.WhenGetRttiTypeMustReturnTheInternalNullableType;
begin
  Assert.AreEqual(FContext.GetType(TypeInfo(Integer)), FNullableManipulator.RttiType);
end;

procedure TNullableManipulatorTest.WhenGetTheValueMustReturnTheValueOfTheNullableProperty;
begin
  FNullableInstance.Nullable := 1234;

  Assert.AreEqual(1234, FNullableManipulator.Value.AsInteger);
end;

procedure TNullableManipulatorTest.WhenTheNullableIsNullMustReturnEmptyInTheGetValueProperty;
begin
  FNullableInstance.Nullable := 1234;

  FNullableInstance.Nullable.Clear;

  Assert.IsTrue(FNullableManipulator.Value.IsEmpty);
end;

end.

