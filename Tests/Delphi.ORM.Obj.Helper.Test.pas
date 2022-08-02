unit Delphi.ORM.Obj.Helper.Test;

interface

uses DUnitX.TestFramework;

type

{
  Objeto já processado em um array
  Função para criar uma copia apartir de um objeto
  Copia de array de objetos
}

  [TestFixture]
  TObjectHelperTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure WhenCopyAnObjectMustCopyAllFieldsValues;
    [Test]
    procedure WhenTryToCopyDifferentTypesOfObjectsMustRaiseAnError;
    [Test]
    procedure WhenTheObjectPropertyIsAnObjectMustCreateANewReferenceInTheDestinyObject;
    [Test]
    procedure WhenTheObjectPropertyIsEmptyCantRaiseAnyError;
    [Test]
    procedure TheObjectFieldPropertyMustHaveTheFieldsCopiedToo;
    [Test]
    procedure WhenTheObjectHasACircularReferenceCantRaiseAnyError;
    [Test]
    procedure TheRecursivityMustBeLinkedHasExpected;
    [Test]
    procedure WhenFillTheFunctionToCreateObjectMustUseItToCreateTheObjects;
    [Test]
    procedure WhenTheObjectHasAnArrayMustCopyForTheDestinyObjectHasExpected;
    [Test]
    procedure WhenTheObjectHasAnArrayOfObjectsTheDestinyArrayMustCreateACopyOsThisObjects;
    [Test]
    procedure WhenTheObjectHasAFieldAndThisValueIsInTheArrayMustUseTheSameInstanceInTheCopy;
    [Test]
    procedure WhenCopyTheObjectWithOnlyTheSourceMustCreateTheDestinyObjectToCopy;
    [Test]
    procedure TheCopyWithSourceOnlyMustReturnTheDestinyObject;
    [Test]
    procedure TheCopyWithSourceOnlyMustCopyTheSourceProperties;
    [Test]
    procedure TheCopyWithSourceOnlyWithoutCreationFunctionMustCopyTheSourceHasExpected;
    [Test]
    procedure ForAllObjectInTheCopyMustCallTheCreateFunctionPassedInParameters;
  end;

  TMyObject = class
  private
    FField1: Integer;
    FField2: String;
    FField3: TMyObject;
    FField4: TArray<TMyObject>;
    FField5: TArray<Integer>;
  public
    property Field1: Integer read FField1 write FField1;
    property Field2: String read FField2 write FField2;
    property Field3: TMyObject read FField3 write FField3;
    property Field4: TArray<TMyObject> read FField4 write FField4;
    property Field5: TArray<Integer> read FField5 write FField5;
  end;

implementation

{ TObjectHelperTest }

uses Delphi.ORM.Obj.Helper;

procedure TObjectHelperTest.ForAllObjectInTheCopyMustCallTheCreateFunctionPassedInParameters;
begin
  var PassCountInTheFunction := 0;
  var Source := TMyObject.Create;
  Source.Field3 := TMyObject.Create;

  var Destiny := TObjectHelper.Copy(Source,
    function (const Source: TObject): TObject
    begin
      Result := Source.ClassType.Create;

      Inc(PassCountInTheFunction);
    end) as TMyObject;

  Assert.AreEqual(2, PassCountInTheFunction);

  Destiny.Field3.Free;

  Destiny.Free;

  Source.Field3.Free;

  Source.Free;
end;

procedure TObjectHelperTest.SetupFixture;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;

  TObjectHelper.Copy(Source, Destiny);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.TheCopyWithSourceOnlyMustCopyTheSourceProperties;
begin
  var Source := TMyObject.Create;
  Source.Field1 := 123;

  var Destiny := TObjectHelper.Copy(Source,
    function (const Source: TObject): TObject
    begin
      Result := Source.ClassType.Create;
    end) as TMyObject;

  Assert.AreEqual(123, Destiny.Field1);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.TheCopyWithSourceOnlyMustReturnTheDestinyObject;
begin
  var Source := TMyObject.Create;

  var Destiny := TObjectHelper.Copy(Source,
    function (const Source: TObject): TObject
    begin
      Result := Source.ClassType.Create;
    end);

  Assert.IsNotNull(Destiny);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.TheCopyWithSourceOnlyWithoutCreationFunctionMustCopyTheSourceHasExpected;
begin
  var Source := TMyObject.Create;
  Source.Field1 := 123;

  var Destiny := TObjectHelper.Copy(Source) as TMyObject;

  Assert.IsNotNull(Destiny);

  Assert.AreEqual(123, Destiny.Field1);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.TheObjectFieldPropertyMustHaveTheFieldsCopiedToo;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field3 := TMyObject.Create;
  Source.Field3.Field1 := 444;
  Source.Field3.Field2 := 'abc';

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual(Source.Field3.Field1, Destiny.Field3.Field1);

  Assert.AreEqual(Source.Field3.Field2, Destiny.Field3.Field2);

  Destiny.Field3.Free;

  Destiny.Free;

  Source.Field3.Free;

  Source.Free;
end;

procedure TObjectHelperTest.TheRecursivityMustBeLinkedHasExpected;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field3 := Source;

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual(Destiny, Destiny.Field3);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenCopyAnObjectMustCopyAllFieldsValues;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field1 := 444;
  Source.Field2 := 'abc';

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual(Source.Field1, Destiny.Field1);

  Assert.AreEqual(Source.Field2, Destiny.Field2);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenCopyTheObjectWithOnlyTheSourceMustCreateTheDestinyObjectToCopy;
begin
  var FunctionCalled := False;
  var Source := TMyObject.Create;

  var Destiny := TObjectHelper.Copy(Source,
    function (const Source: TObject): TObject
    begin
      FunctionCalled := True;
      Result := Source.ClassType.Create;
    end);

  Assert.IsTrue(FunctionCalled);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenFillTheFunctionToCreateObjectMustUseItToCreateTheObjects;
begin
  var Destiny := TMyObject.Create;
  var FunctionCalled := False;
  var Source := TMyObject.Create;
  Source.Field3 := TMyObject.Create;

  TObjectHelper.Copy(Source, Destiny,
    function (const Source: TObject): TObject
    begin
      FunctionCalled := True;
      Result := Source.ClassType.Create;
    end);

  Assert.IsTrue(FunctionCalled);

  Destiny.Field3.Free;

  Destiny.Free;

  Source.Field3.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectHasACircularReferenceCantRaiseAnyError;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field3 := Source;

  Assert.WillNotRaise(
    procedure
    begin
      TObjectHelper.Copy(Source, Destiny);
    end);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectHasAFieldAndThisValueIsInTheArrayMustUseTheSameInstanceInTheCopy;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field3 := TMyObject.Create;
  Source.Field4 := [Source.Field3];

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual(Destiny.Field3, Destiny.Field4[0]);

  Destiny.Field3.Free;

  Destiny.Free;

  Source.Field3.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectHasAnArrayMustCopyForTheDestinyObjectHasExpected;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field5 := [1, 2, 3, 4];

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual<NativeInt>(4, Length(Destiny.Field5));

  Assert.AreEqual(1, Destiny.Field5[0]);

  Assert.AreEqual(2, Destiny.Field5[1]);

  Assert.AreEqual(3, Destiny.Field5[2]);

  Assert.AreEqual(4, Destiny.Field5[3]);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectHasAnArrayOfObjectsTheDestinyArrayMustCreateACopyOsThisObjects;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field4 := [TMyObject.Create, TMyObject.Create];
  Source.Field4[0].Field1 := 123;
  Source.Field4[1].Field1 := 456;

  TObjectHelper.Copy(Source, Destiny);

  Assert.AreEqual<NativeInt>(2, Length(Destiny.Field4));

  Assert.AreNotEqual(Source.Field4[0], Destiny.Field4[0]);

  Assert.AreNotEqual(Source.Field4[1], Destiny.Field4[1]);

  Assert.AreEqual<NativeInt>(123, Destiny.Field4[0].Field1);

  Assert.AreEqual<NativeInt>(456, Destiny.Field4[1].Field1);

  Destiny.Field4[1].Free;

  Destiny.Field4[0].Free;

  Destiny.Free;

  Source.Field4[1].Free;

  Source.Field4[0].Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectPropertyIsAnObjectMustCreateANewReferenceInTheDestinyObject;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;
  Source.Field3 := TMyObject.Create;

  TObjectHelper.Copy(Source, Destiny);

  Assert.IsNotNull(Destiny.Field3);

  Assert.AreNotEqual(Source.Field3, Destiny.Field3);

  Destiny.Field3.Free;

  Destiny.Free;

  Source.Field3.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTheObjectPropertyIsEmptyCantRaiseAnyError;
begin
  var Destiny := TMyObject.Create;
  var Source := TMyObject.Create;

  Assert.WillNotRaise(
    procedure
    begin
      TObjectHelper.Copy(Source, Destiny);
    end);

  Destiny.Free;

  Source.Free;
end;

procedure TObjectHelperTest.WhenTryToCopyDifferentTypesOfObjectsMustRaiseAnError;
begin
  var Source := TMyObject.Create;

  Assert.WillRaise(
    procedure
    begin
      TObjectHelper.Copy(Source, Self);
    end, EDiffentObjectTypes);

  Source.Free;
end;

end.
