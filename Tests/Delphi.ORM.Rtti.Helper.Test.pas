unit Delphi.ORM.Rtti.Helper.Test;

interface

uses System.Rtti, DUnitX.TestFramework;

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
    [TestCase('AnsiChar', 'AnsiChar,C')]
    [TestCase('AnsiString', 'AnsiString,AnsiString')]
    [TestCase('Char', 'Char,C')]
    [TestCase('Enumerator', 'Enumerator,1')]
    [TestCase('Empty Value', 'EmptyValue,')]
    [TestCase('Float', 'Float,1234.456')]
    [TestCase('Date', 'Date,2020-01-31')]
    [TestCase('DateTime', 'DateTime,2020-01-31 12:34:56')]
    [TestCase('GUID', 'GUID,{BD2BBA84-C691-4C5E-ABD3-4F32937C53F8}')]
    [TestCase('Integer', 'Integer,1234')]
    [TestCase('Int64', 'Int64,1234')]
    [TestCase('String', 'String,String')]
    [TestCase('Time', 'Time,12:34:56')]
    procedure TheConversionOfTheTValueMustBeLikeExpected(TypeToConvert, ValueToCompare: String);
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

  [TestFixture]
  TRttiHelperFunctionTest = class
  private
    FContext: TRttiContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenCallTheGetRttiTypeMustReturnTheTypeAsExpected;
    [Test]
    procedure WhencallTheGetRttiTypeOfAnClassMustReturnTheTypeAsExpected;
    [Test]
    procedure WhenCallTheGetGenericRttiTypeMustReturnTheInternalTypeOfTheDeclaredGeneric;
  end;

  TMyAttribute = class(TCustomAttribute);

  [TMy]
  TClassWithAttribute = class

  end;

implementation

uses System.SysUtils, System.DateUtils, System.Variants, System.TypInfo, System.SysConst, System.Generics.Collections, Delphi.ORM.Rtti.Helper, Delphi.ORM.Test.Entity;

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

procedure TValueHelperTest.TheConversionOfTheTValueMustBeLikeExpected(TypeToConvert, ValueToCompare: String);
begin
  var Value: TValue;

  if TypeToConvert = 'AnsiChar' then
    Value := TValue.From(AnsiChar('C'))
  else if TypeToConvert = 'AnsiString' then
    Value := TValue.From(AnsiString('AnsiString'))
  else if TypeToConvert = 'Char' then
    Value := TValue.From(Char('C'))
  else if TypeToConvert = 'EmptyValue' then
    Value := TValue.Empty
  else if TypeToConvert = 'Enumerator' then
    Value := TValue.From(Enum2)
  else if TypeToConvert = 'Float' then
    Value := 1234.456
  else if TypeToConvert = 'Date' then
    Value := TValue.From(EncodeDate(2020, 1, 31))
  else if TypeToConvert = 'DateTime' then
    Value := TValue.From(EncodeDateTime(2020, 1, 31, 12, 34, 56, 0))
  else if TypeToConvert = 'GUID' then
    Value := TValue.From(StringToGUID('{BD2BBA84-C691-4C5E-ABD3-4F32937C53F8}'))
  else if TypeToConvert = 'Integer' then
    Value := 1234
  else if TypeToConvert = 'Int64' then
    Value := Int64(1234)
  else if TypeToConvert = 'String' then
    Value := 'String'
  else if TypeToConvert = 'Time' then
    Value := TValue.From(TTime(EncodeTime(12, 34, 56, 0)))
  else
    raise Exception.Create('Test not mapped!');

  Assert.AreEqual(ValueToCompare, Value.GetAsString);
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

{ TRttiHelperFunctionTest }

procedure TRttiHelperFunctionTest.Setup;
begin
  FContext := TRttiContext.Create;
end;

procedure TRttiHelperFunctionTest.TearDown;
begin
  FContext.Free;
end;

procedure TRttiHelperFunctionTest.WhenCallTheGetGenericRttiTypeMustReturnTheInternalTypeOfTheDeclaredGeneric;
begin
  Assert.AreEqual(FContext.GetType(TypeInfo(Integer)), GetGenericRttiType('TList', FContext.GetType(TypeInfo(TList<Integer>))));
end;

procedure TRttiHelperFunctionTest.WhenCallTheGetRttiTypeMustReturnTheTypeAsExpected;
begin
  Assert.AreEqual(FContext.GetType(TRttiHelperFunctionTest), GetRttiType(TypeInfo(TRttiHelperFunctionTest)));
end;

procedure TRttiHelperFunctionTest.WhencallTheGetRttiTypeOfAnClassMustReturnTheTypeAsExpected;
begin
  Assert.AreEqual(FContext.GetType(TRttiHelperFunctionTest), GetRttiType(TRttiHelperFunctionTest));
end;

end.

