unit Delphi.ORM.Nullable.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TNullableTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure WhenCheckIfTheTypeIfNullableMustReturnTrueIfIsAnNullableType;
    [Test]
    procedure TheImplictOperatorMustLoadTheValueOfTheNullableValue;
    [Test]
    procedure WhenAssignTheNullValueToNullableValueMustReturnTrueInIsNullFunction;
    [Test]
    procedure WhenAssignAValueToTheNullableTheIsNullFunctionMustReturnFalse;
    [Test]
    procedure WhenFillTheValuePropertyOfNullableMustSetTheNullToFalse;
    [Test]
    procedure WhenCallTheGetValueFunctionMustReturnAEmptyTValueIfTheValueIsNull;
    [Test]
    procedure WhenCallTheGetValueFunctionMustReturnTheValue;
    [Test]
    procedure WhenCallTheSetValueFunctionMustReturnTrueToIsNullIfTheValueIsEmpty;
    [Test]
    procedure WhenCallTheSetValueFunctionMustReturnFalseToIsNullIfTheValueIsNotEmpty;
    [Test]
    procedure WhenCallTheSetValueFunctionMustLoadTheValueOfTheRecordWithTheValueInTheParam;
    [Test]
    procedure GetNullableRttiTypeMustReturnTheRttiTypeOfTheNullable;
    [Test]
    procedure TheImplicitConversionMustReturnTheValueOfTheNullableType;
    [Test]
    procedure WhenFillWithNullTheValueMustReturnTheDefaultValueInTheValueProperty;
  end;

implementation

uses System.Rtti, System.TypInfo, Delphi.ORM.Nullable;

{ TNullableTest }

procedure TNullableTest.GetNullableRttiTypeMustReturnTheRttiTypeOfTheNullable;
begin
  var Context := TRttiContext.Create;
  var RttiType := Context.GetType(TypeInfo(String));

  Assert.AreEqual(RttiType, GetNullableRttiType(Context.GetType(TypeInfo(Nullable<String>))));
end;

procedure TNullableTest.SetupFixture;
begin
  var RttiType := TRttiContext.Create.GetType(TypeInfo(Nullable<String>));

  TRttiContext.Create.GetType(TypeInfo(Nullable<Integer>)).QualifiedName;

  RttiType.GetFields;

  RttiType.GetMethods;
end;

procedure TNullableTest.TheImplicitConversionMustReturnTheValueOfTheNullableType;
begin
  var NullValue: Nullable<String>;
  NullValue := 'abc';
  var Value: String := NullValue;

  Assert.AreEqual('abc', Value);
end;

procedure TNullableTest.TheImplictOperatorMustLoadTheValueOfTheNullableValue;
begin
  var Value: Nullable<String>;

  Value := 'abc';

  Assert.AreEqual('abc', Value.Value);
end;

procedure TNullableTest.WhenAssignAValueToTheNullableTheIsNullFunctionMustReturnFalse;
begin
  var Value: Nullable<String>;

  Value := NULL;

  Value := 'abc';

  Assert.IsFalse(Value.IsNull);
end;

procedure TNullableTest.WhenAssignTheNullValueToNullableValueMustReturnTrueInIsNullFunction;
begin
  var Value: Nullable<String>;

  Value := NULL;

  Assert.IsTrue(Value.IsNull);
end;

procedure TNullableTest.WhenCallTheGetValueFunctionMustReturnAEmptyTValueIfTheValueIsNull;
begin
  var Value: Nullable<String>;

  Value := NULL;

  Assert.IsTrue(GetNullableAccess(TValue.From(Value)).GetValue.IsEmpty);
end;

procedure TNullableTest.WhenCallTheGetValueFunctionMustReturnTheValue;
begin
  var Value: Nullable<String>;

  Value := 'abcde';

  Assert.AreEqual('abcde', GetNullableAccess(TValue.From(Value)).GetValue.AsString);
end;

procedure TNullableTest.WhenCallTheSetValueFunctionMustLoadTheValueOfTheRecordWithTheValueInTheParam;
begin
  var Value: Nullable<String>;
  Value := NULL;

  GetNullableAccess(TValue.From(Value)).SetValue('abcde');

  Assert.AreEqual('abcde', GetNullableAccess(TValue.From(Value)).GetValue.AsString);
end;

procedure TNullableTest.WhenCallTheSetValueFunctionMustReturnFalseToIsNullIfTheValueIsNotEmpty;
begin
  var Value: Nullable<String>;
  Value := NULL;

  GetNullableAccess(TValue.From(Value)).SetValue('abcde');

  Assert.IsFalse(Value.IsNull);
end;

procedure TNullableTest.WhenCallTheSetValueFunctionMustReturnTrueToIsNullIfTheValueIsEmpty;
begin
  var Value: Nullable<String>;
  Value := 'abcde';

  GetNullableAccess(TValue.From(Value)).SetValue(TValue.Empty);

  Assert.IsTrue(Value.IsNull);
end;

procedure TNullableTest.WhenCheckIfTheTypeIfNullableMustReturnTrueIfIsAnNullableType;
begin
  var RttiType := TRttiContext.Create.GetType(TypeInfo(Nullable<Integer>));

  Assert.IsTrue(IsNullableType(RttiType));
end;

procedure TNullableTest.WhenFillTheValuePropertyOfNullableMustSetTheNullToFalse;
begin
  var Value: Nullable<String>;

  Value := NULL;

  Value.Value := 'abc';

  Assert.IsFalse(Value.IsNull);
end;

procedure TNullableTest.WhenFillWithNullTheValueMustReturnTheDefaultValueInTheValueProperty;
begin
  var NullValue: Nullable<Integer>;
  NullValue := 1234;

  NullValue := NULL;

  Assert.AreEqual(0, NullValue.Value);
end;

end.

