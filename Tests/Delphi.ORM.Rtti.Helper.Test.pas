unit Delphi.ORM.Rtti.Helper.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TValueHelperTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenGetTheArrayLengthMustReturnTheSizeOfTheArray;
    [Test]
    procedure WhenChangeTheArraySizeOfTheValueMustChangeTheSizeOfArrayOfValues;
    [Test]
    procedure WhenTryToChangeTheSizeOfAnConstArrayMustRaiseAnError;
    [Test]
    procedure WhenGetAnArrayElementMustReturnTheValueExpected;
    [Test]
    procedure WhenSetAnArrayElementMustChangeTheValueAsExpected;
  end;

  [TestFixture]
  TRttiTypeHelperTest = class
  public
    [Test]
    procedure WhenTheTypeIsAnArrayMustReturnTrueIsTheFunctionIsArray;
    [Test]
    procedure WhenCallTheAsArrayMustReturnTheRttiTypeOfDynamicArray;
    [Test]
    procedure WhenGetAnAttributeMustReturnTheChosenAttribute;
  end;

  TMyAttribute = class(TCustomAttribute);

  [TMy]
  TClassWithAttribute = class

  end;

implementation

uses System.Rtti, Delphi.ORM.Rtti.Helper;

const
  MyConstArray: array[0..2] of Integer = (1, 2, 3);

{ TRttiTypeHelperTest }

procedure TRttiTypeHelperTest.WhenCallTheAsArrayMustReturnTheRttiTypeOfDynamicArray;
begin
  var Context := TRttiContext.Create;

  var RttiType := Context.GetType(TypeInfo(TArray<Integer>));

  Assert.AreEqual(TRttiDynamicArrayType.ClassName, RttiType.AsArray.ClassName);
end;

procedure TRttiTypeHelperTest.WhenGetAnAttributeMustReturnTheChosenAttribute;
begin
  var Context := TRttiContext.Create;

  var Attribute := Context.GetType(TypeInfo(TClassWithAttribute)).GetAttribute<TMyAttribute>;

  Assert.IsNotNull(Attribute);

  Assert.AreEqual(TMyAttribute.ClassName, Attribute.ClassName);
end;

procedure TRttiTypeHelperTest.WhenTheTypeIsAnArrayMustReturnTrueIsTheFunctionIsArray;
begin
  var Context := TRttiContext.Create;

  var RttiType := Context.GetType(TypeInfo(TArray<Integer>));

  Assert.IsTrue(RttiType.IsArray);
end;

{ TValueHelperTest }

procedure TValueHelperTest.Setup;
begin
  try
    TValue.From(MyConstArray).ArrayLength := 4;
  except
  end;
end;

procedure TValueHelperTest.WhenChangeTheArraySizeOfTheValueMustChangeTheSizeOfArrayOfValues;
begin
  var MyArray: TArray<Integer> := [1, 2, 3];
  var Value := TValue.From(MyArray);

  Value.ArrayLength := 4;

  Assert.AreEqual<Integer>(4, Length(Value.AsType<TArray<Integer>>));
end;

procedure TValueHelperTest.WhenGetAnArrayElementMustReturnTheValueExpected;
begin
  var MyArray: TArray<Integer> := [111, 222, 333];
  var Value := TValue.From(MyArray);

  Assert.AreEqual(222, Value.ArrayElement[1].AsInteger);
end;

procedure TValueHelperTest.WhenGetTheArrayLengthMustReturnTheSizeOfTheArray;
begin
  var MyArray: TArray<Integer> := [1, 2, 3];
  var Value := TValue.From(MyArray);

  Assert.AreEqual(3, Value.ArrayLength);
end;

procedure TValueHelperTest.WhenSetAnArrayElementMustChangeTheValueAsExpected;
begin
  var MyArray: TArray<Integer> := [111, 222, 333];
  var Value := TValue.From(MyArray);

  Value.ArrayElement[1] := 888;

  Assert.AreEqual(888, Value.ArrayElement[1].AsInteger);
end;

procedure TValueHelperTest.WhenTryToChangeTheSizeOfAnConstArrayMustRaiseAnError;
begin
  Assert.WillRaise(
    procedure
    begin
      var Value := TValue.From(MyConstArray);

      Value.ArrayLength := 4;
    end);
end;

end.
