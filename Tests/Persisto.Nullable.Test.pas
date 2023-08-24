unit Persisto.Nullable.Test;

interface

uses DUnitX.TestFramework, Persisto.Test.Entity;

type
  [TestFixture]
  TNullableTest = class
  private
    FNullableInstance: TClassWithNullableProperty;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TheValueMustReturnTrueInIsNullFunctionIfTheValueHasBeenModified;
    [Test]
    procedure WhenFillTheValueTheIsNullFunctionMsutReturnFalse;
    [Test]
    procedure WhenCallClearMustReturnTrueInTheIsNullFunction;
    [Test]
    procedure WhenSetTheNullValueToThePropertyMustReturnTrueInTheIsNullFunction;
    [Test]
    procedure WhenFillTheValueUsingTheImplicitOperatorMustReturnFalseInTheIsNullFunction;
    [Test]
    procedure WhenFillTheValueMustReturnTheValueFilled;
    [Test]
    procedure WhenFillTheValueUsingTheImplicitOperatorMustReturnTheValueHasExpected;
  end;

implementation

uses Persisto.Mapping;

{ TNullableTest }

procedure TNullableTest.Setup;
begin
  FNullableInstance := TClassWithNullableProperty.Create;
end;

procedure TNullableTest.TearDown;
begin
  FNullableInstance.Free;
end;

procedure TNullableTest.TheValueMustReturnTrueInIsNullFunctionIfTheValueHasBeenModified;
begin
  Assert.IsTrue(FNullableInstance.Nullable.IsNull);
end;

procedure TNullableTest.WhenCallClearMustReturnTrueInTheIsNullFunction;
begin
  FNullableInstance.Nullable.Value := 123;

  FNullableInstance.Nullable.Clear;

  Assert.IsTrue(FNullableInstance.Nullable.IsNull);
end;

procedure TNullableTest.WhenFillTheValueMustReturnTheValueFilled;
begin
  FNullableInstance.Nullable.Value := 123;

  Assert.AreEqual(123, FNullableInstance.Nullable.Value);
end;

procedure TNullableTest.WhenFillTheValueTheIsNullFunctionMsutReturnFalse;
begin
  FNullableInstance.Nullable.Value := 123;

  Assert.IsFalse(FNullableInstance.Nullable.IsNull);
end;

procedure TNullableTest.WhenFillTheValueUsingTheImplicitOperatorMustReturnFalseInTheIsNullFunction;
begin
  FNullableInstance.Nullable := 123;

  Assert.IsFalse(FNullableInstance.Nullable.IsNull);
end;

procedure TNullableTest.WhenFillTheValueUsingTheImplicitOperatorMustReturnTheValueHasExpected;
begin
  FNullableInstance.Nullable := 123;

  Assert.AreEqual<Integer>(123, FNullableInstance.Nullable);
end;

procedure TNullableTest.WhenSetTheNullValueToThePropertyMustReturnTrueInTheIsNullFunction;
begin
  FNullableInstance.Nullable.Value := 123;

  FNullableInstance.Nullable := NULL;

  Assert.IsTrue(FNullableInstance.Nullable.IsNull);
end;

end.

