unit Persisto.DataSet.Test;

interface

uses System.SysUtils, System.Rtti, Data.DB, System.Generics.Collections, Persisto.DataSet, Test.Insight.Framework, Persisto.Mapping;

type
  [TestFixture]
  TPersistoDataSetTest = class
  private
    FContext: TRttiContext;
    FDataSet: TPersistoDataSet;

    procedure DestroyObjects(DataSet: TPersistoDataSet);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenTryToOpenTheDataSetWithoutAnObjectInformationMustRaiseAnError;
    [Test]
    procedure WhenLoadTheObjectClassNameMustOpenWithoutAnyError;
    [Test]
    procedure WhenLoadTheObjectClassNameMustLoadTheObjectTypeInfoWithTheObjectType;
    [Test]
    procedure WhenTryToChangeTheObjectClassNameWithAnOpenDataSetMustRaiseAnError;
    [Test]
    procedure WhenLoadTheObjectClassPropertyCantRaiseErrorWhenOpenTheDataSet;
    [Test]
    procedure WhenLoadTheObjectClassPropertyMustLoadTheObjectTypePropertyWithTheClassInfo;
    [Test]
    procedure WhenTryToChangeTheObjectClassWhenTheDataSetIsOpenMustRaiseAnError;
    [Test]
    procedure AfterOpenTheDataSetAndTryToInserMustInsertWithoutAnyError;
    [Test]
    procedure WhenPostTheRecordInTheDataSetMustKeepTheObjectInsideTheDataSet;
    [Test]
    procedure WhenInsertingARecordTheCurrentObjectMustReturnTheObjectBeenInserted;
    [Test]
    procedure WhenFillTheObjectListMustLoadTheObjectClassTypeWithTheObjectClassType;
    [Test]
    procedure WhenGetTheObjectListMustReturnTheObjectsFilledInTheList;
    [Test]
    procedure WhenFillTheObjectListAndOpenTheDataSetTheRecordCountMustBeEqualTheLengthOfTheObjectList;
    [Test]
    procedure WhenTheDataSetIsCloseAndTryToGetTheRecordCountMustRaiseError;
    [Test]
    procedure WhenOpenAnEmptyDataSetTheEOFPropertyMustBeTrue;
    [Test]
    procedure WhenOpenTheDataSetWithOneObjectMustReturnFalseInTheEOFProperty;
    [Test]
    procedure WhenOpenAListOfObjectTheCurrentObjectMustBeTheFirstObjectInTheList;
    [Test]
    procedure WhenNavigateAllObjectInTheDataSetMustMarkTheOEFPropertyHasTrue;
    [Test]
    procedure WhenGoToTheLastRecordInTheListMustMarkTheEOFPropertyHasTrue;
    [Test]
    procedure WhenGoToTheLastRecordTheCurrentObjectMustReturnTheLastObjectInTheList;
    [Test]
    procedure WhenGoBackInAllRecordMustMarkTheBOFPropertyHasTrue;
    [Test]
    procedure WhenGoToTheFirstRecordTheCurrentObjectMustBeTheFirstRecordOfTheList;
    [Test]
    procedure WhenAppendADataSourceInDataSetCantRaiseAnyError;
    [Test]
    procedure WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
    [Test]
    procedure TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
    [Test]
    procedure WhenThePropertyIsOfIntegerTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfStringTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfFloatTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfInt64TypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfEnumeratorTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfBooleanTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfDateTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfTimeTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfDateTimeTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfUniqueIdentifierTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenThePropertyIsOfClassTypeMustCreateTheFieldWithTheTypeExpected;
    [Test]
    procedure WhenTheFieldTypeIsntMappedCanRaiseAnyError;
    [Test]
    procedure WhenTheDataSetHasFieldsLoadedCantReloadThisFields;
    [Test]
    procedure WhenUpdateFieldDefsMustLoadTheFieldInformationInTheFieldDefsCollection;
    [Test]
    procedure WhenTheFieldIsCharTypeTheSizeMustBeOne;
    [Test]
    procedure WhenTheFieldIsStringTypeTheSizeMustBeTheValueFromAttribute;
    [Test]
    procedure WhenLoadAClassWithAForeignKeyMustLoadTheForeignKeyFieldInTheFieldList;
    [Test]
    procedure WhenCreateAFieldOfOneObjectClassMustLoadAllClassLevelsInTheFieldName;
    [Test]
    procedure WhenChangeTheObjectTypeFromTheDataSetMustMarkTheFieldDefsToUpdateAgain;
    [Test]
    procedure WhenLoadAnInvalidClassNameInThePropertyCantRaiseAnyError;
    [Test]
    procedure WhenTryToLoadTheClassNameAndTheTypeDontExistsMustRaiseAnError;
    [Test]
    procedure WhenFillAnEmptyClassNameCantRaiseAnyError;
    [Test]
    procedure WhenTheClassHasAnArrayPropertyMustLoadTheFieldAsADataSetField;
    [Test]
    procedure AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
    [Test]
    procedure WhenNavigateByDataSetMustHaveToShowTheValuesFromTheList;
    [Test]
    procedure WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
    [Test]
    procedure WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
    [Test]
    procedure WhenCallFirstHaveToGoToTheFirstRecord;
    [Test]
    procedure WhenFillTheObjectListMoreThanOnceMustLoadTheObjectListWithTheLastLoadingObjects;
    [Test]
    procedure WhenFillTheObjectListWithAnEmptyListCantRaiseAnyError;
    [Test]
    procedure WhenFillTheObjectListWithAnEmptyValueMustEmptyTheDataSet;
    [Test]
    procedure WhenTryToOpenTheDataSetInDesigningTimeCantRaiseAnyError;
    [Test]
    procedure WhenTryToGetTheFieldListInDesigningTimeCantRaiseAnyError;
  end;

{$M+}
  TAnotherObject = class
  private
    FAnotherObject: TAnotherObject;
    FAnotherName: String;
    FId: String;
  public
    destructor Destroy; override;
  published
    property AnotherName: String read FAnotherName write FAnotherName;
    property AnotherObject: TAnotherObject read FAnotherObject write FAnotherObject;
    property Id: String read FId write FId;
  end;

   TMyTestClass = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
    FAnotherObject: TAnotherObject;
  public
    destructor Destroy; override;
  published
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
    property AnotherObject: TAnotherObject read FAnotherObject write FAnotherObject;
  end;

  TMyTestClassChild = class(TMyTestClass)
  private
    FAField: String;
    FAnotherField: Integer;
  published
    property AField: String read FAField write FAField;
    property AnotherField: Integer read FAnotherField write FAnotherField;
  end;

  TMyEnumerator = (Enum1, Enum2, Enum3);

  TMyTestClassTypes = class
  private
    FInt: Integer;
    FDate: TDate;
    FWideChar: WideChar;
    FWord: Word;
    FByte: Byte;
    FDouble: Double;
    FChar: AnsiChar;
    FCardinal: Cardinal;
    FStr: String;
    FBoolean: Boolean;
    FTime: TTime;
    FSmallInt: SmallInt;
    FExtended: Extended;
    FDateTime: TDateTime;
    FWideString: WideString;
    FInt64: Int64;
    FSingle: Single;
    FCurrency: Currency;
    FClass: TMyTestClass;
    FMyEnum: TMyEnumerator;
    FMyArray: TArray<TMyTestClassTypes>;
  published
    property Boolean: Boolean read FBoolean write FBoolean;
    property Byte: Byte read FByte write FByte;
    property Cardinal: Cardinal read FCardinal write FCardinal;
    property Char: AnsiChar read FChar write FChar;
    property &Class: TMyTestClass read FClass write FClass;
    property Currency: Currency read FCurrency write FCurrency;
    property Date: TDate read FDate write FDate;
    property DateTime: TDateTime read FDateTime write FDateTime;
    property Double: Double read FDouble write FDouble;
    property Extended: Extended read FExtended write FExtended;
    property Int64: Int64 read FInt64 write FInt64;
    property Int: Integer read FInt write FInt;
    property MyEnum: TMyEnumerator read FMyEnum write FMyEnum;
    property Single: Single read FSingle write FSingle;
    property SmallInt: SmallInt read FSmallInt write FSmallInt;
    property Str: String read FStr write FStr;
    property Time: TTime read FTime write FTime;
    property WideChar: WideChar read FWideChar write FWideChar;
    property WideString: WideString read FWideString write FWideString;
    property Word: Word read FWord write FWord;
    property MyArray: TArray<TMyTestClassTypes> read FMyArray write FMyArray;
  end;

  TParentClass = class
  private
    FMyClass: TMyTestClassTypes;
  published
    property MyClass: TMyTestClassTypes read FMyClass write FMyClass;
  end;

  TCallbackClass = class
  private
    FCallbackProc: TProc<TPersistoDataSet>;
  public
    constructor Create(CallbackProc: TProc<TPersistoDataSet>);

    procedure OnCalcFields(DataSet: TDataSet);
  end;

  TPersistoDataSetHack = class(TPersistoDataSet)
  end;

implementation

uses System.Classes, System.Variants, Data.DBConsts, Persisto.Test.Entity;

{ TPersistoDataSetTest }

procedure TPersistoDataSetTest.AfterOpenTheDataSetAndTryToInserMustInsertWithoutAnyError;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.WillNotRaise(FDataSet.Insert);
end;

procedure TPersistoDataSetTest.AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
begin
  var MyObject := TMyTestClass.Create;
  MyObject.Id := 123456;
  MyObject.Name := 'MyName';
  MyObject.Value := 5477.555;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(123456, FDataSet.FieldByName('Id').AsInteger);
  Assert.AreEqual('MyName', FDataSet.FieldByName('Name').AsString);
  Assert.AreEqual(FloatToStr(5477.555), FDataSet.FieldByName('Value').AsString);
end;

procedure TPersistoDataSetTest.DestroyObjects(DataSet: TPersistoDataSet);
begin
  try
    if DataSet.Active then
    begin
      DataSet.First;

      while not DataSet.Eof do
      begin
        DataSet.GetCurrentObject<TObject>.Free;

        DataSet.Next;
      end;
    end;
  except
    // Não mostrar erros por que não mostra o resultado da execução do teste
  end;
end;

procedure TPersistoDataSetTest.Setup;
begin
  inherited;

  FContext := TRttiContext.Create;
  FDataSet := TPersistoDataSet.Create(nil);
end;

procedure TPersistoDataSetTest.TearDown;
begin
  DestroyObjects(FDataSet);

  FContext.Free;

  FDataSet.Free;
end;

procedure TPersistoDataSetTest.TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.AreEqual('Id', FDataSet.Fields[0].FieldName);
  Assert.AreEqual('Name', FDataSet.Fields[1].FieldName);
  Assert.AreEqual('Value', FDataSet.Fields[2].FieldName);
  Assert.AreEqual('AnotherObject', FDataSet.Fields[3].FieldName);
end;

procedure TPersistoDataSetTest.WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
begin
  var Field := TWideStringField.Create(FDataSet);
  Field.FieldName := 'AnotherObject.AnotherObject.AnotherName';
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject.AnotherName := 'MyName';

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual('MyName', FDataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString);
end;

procedure TPersistoDataSetTest.WhenAppendADataSourceInDataSetCantRaiseAnyError;
begin
  var DataSource := TDataSource.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      DataSource.DataSet := FDataSet;
    end);

  DataSource.Free;
end;

procedure TPersistoDataSetTest.WhenTheClassHasAnArrayPropertyMustLoadTheFieldAsADataSetField;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;

  FDataSet.Open;

  Assert.AreEqual(ftDataSet, FDataSet.FieldByName('MyArray').DataType);
end;

procedure TPersistoDataSetTest.WhenTheDataSetHasFieldsLoadedCantReloadThisFields;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;
  var Field := TIntegerField.Create(FDataSet);
  Field.FieldName := 'Integer';

  Field.SetParentComponent(FDataSet);

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenTheDataSetIsCloseAndTryToGetTheRecordCountMustRaiseError;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataSet.RecordCount;
    end, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenCallFirstHaveToGoToTheFirstRecord;
begin
  var MyList := TList<TObject>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  FDataSet.Objects := MyList.ToArray;

  FDataSet.Open;

  while not FDataSet.Eof do
    FDataSet.Next;

  FDataSet.First;

  Assert.AreEqual('Name1', FDataSet.FieldByName('Name').AsString);

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenFillAnEmptyClassNameCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.ObjectClassName := EmptyStr;
    end);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListAndOpenTheDataSetTheRecordCountMustBeEqualTheLengthOfTheObjectList;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  Assert.AreEqual(3, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListMoreThanOnceMustLoadTheObjectListWithTheLastLoadingObjects;
begin
  var MyObject := TMyTestClass.Create;
  MyObject.Id := 123456;
  MyObject.Name := 'MyName';
  MyObject.Value := 5477.555;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Close;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Close;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(1, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListMustLoadTheObjectClassTypeWithTheObjectClassType;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  Assert.AreEqual(FDataSet.ObjectClass, MyObject.ClassType);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListWithAnEmptyListCantRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyTestClass;
  FDataSet.Objects := nil;

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListWithAnEmptyValueMustEmptyTheDataSet;
begin
  var MyObject := TMyTestClass.Create;
  MyObject.Id := 123456;
  MyObject.Name := 'MyName';
  MyObject.Value := 5477.555;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Close;

  FDataSet.Objects := nil;

  FDataSet.Open;

  Assert.AreEqual(0, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenGetTheObjectListMustReturnTheObjectsFilledInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, MyObject, MyObject];

  Assert.AreEqual(3, Length(FDataSet.Objects));
  Assert.AreEqual(MyObject, FDataSet.Objects[0]);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenGoBackInAllRecordMustMarkTheBOFPropertyHasTrue;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Last;

  FDataSet.Prior;

  FDataSet.Prior;

  FDataSet.Prior;

  Assert.IsTrue(FDataSet.Bof);
end;

procedure TPersistoDataSetTest.WhenGoToTheFirstRecordTheCurrentObjectMustBeTheFirstRecordOfTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Last;

  FDataSet.First;

  Assert.AreEqual(MyObject, FDataSet.CurrentObject);
end;

procedure TPersistoDataSetTest.WhenGotoTheLastRecordInTheListMustMarkTheEOFPropertyHasTrue;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Last;

  Assert.IsTrue(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenGoToTheLastRecordTheCurrentObjectMustReturnTheLastObjectInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, MyObject];

  FDataSet.Open;

  FDataSet.Last;

  Assert.AreEqual(MyObject, FDataSet.CurrentObject);
end;

procedure TPersistoDataSetTest.WhenInsertingARecordTheCurrentObjectMustReturnTheObjectBeenInserted;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  Assert.IsNotNil(FDataSet.CurrentObject);
end;

procedure TPersistoDataSetTest.WhenNavigateAllObjectInTheDataSetMustMarkTheOEFPropertyHasTrue;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Next;

  FDataSet.Next;

  FDataSet.Next;

  Assert.IsTrue(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenNavigateByDataSetMustHaveToShowTheValuesFromTheList;
begin
  var MyList := TList<TObject>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  FDataSet.Objects := MyList.ToArray;

  FDataSet.Open;

  for var B := 1 to 10 do
  begin
    Assert.AreEqual(B, FDataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), FDataSet.FieldByName('Name').AsString);
    Assert.AreEqual(B + B, FDataSet.FieldByName('Value').AsFloat);

    FDataSet.Next;
  end;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
begin
  var MyList := TList<TObject>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  FDataSet.Objects := MyList.ToArray;

  FDataSet.Open;

  FDataSet.Last;

  for var B := 10 downto 1 do
  begin
    Assert.AreEqual(B, FDataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), FDataSet.FieldByName('Name').AsString);
    Assert.AreEqual(B + B, FDataSet.FieldByName('Value').AsFloat);

    FDataSet.Prior;
  end;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenOpenAListOfObjectTheCurrentObjectMustBeTheFirstObjectInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  Assert.AreEqual(MyObject, FDataSet.GetCurrentObject<TMyTestClass>);
end;

procedure TPersistoDataSetTest.WhenOpenAnEmptyDataSetTheEOFPropertyMustBeTrue;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.IsTrue(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.AreEqual(7, FDataSet.FieldCount);
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithOneObjectMustReturnFalseInTheEOFProperty;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.IsFalse(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenPostTheRecordInTheDataSetMustKeepTheObjectInsideTheDataSet;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  FDataSet.Post;

  FDataSet.Insert;

  FDataSet.Post;

  FDataSet.Insert;

  FDataSet.Post;

  Assert.AreEqual(3, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenLoadAClassWithAForeignKeyMustLoadTheForeignKeyFieldInTheFieldList;
begin
  FDataSet.ObjectClass := TMyEntityForeignKeyAlias;

  FDataSet.Open;

  Assert.IsNotNil(FDataSet.FindField('ForeignKey.SimpleProperty'));
end;

procedure TPersistoDataSetTest.WhenLoadAnInvalidClassNameInThePropertyCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.ObjectClassName := 'InvalidType';
    end);
end;

procedure TPersistoDataSetTest.WhenLoadTheObjectClassNameMustLoadTheObjectTypeInfoWithTheObjectType;
begin
  FDataSet.ObjectClassName := TMyTestClass.QualifiedClassName;

  FDataSet.Open;

  Assert.AreEqual(FContext.GetType(TMyTestClass).AsInstance, FDataSet.ObjectType);
end;

procedure TPersistoDataSetTest.WhenLoadTheObjectClassNameMustOpenWithoutAnyError;
begin
  FDataSet.ObjectClassName := TMyTestClass.QualifiedClassName;

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenLoadTheObjectClassPropertyCantRaiseErrorWhenOpenTheDataSet;
begin
  FDataSet.ObjectClass := TMyTestClass;

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenLoadTheObjectClassPropertyMustLoadTheObjectTypePropertyWithTheClassInfo;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.AreEqual(FContext.GetType(TMyTestClass).AsInstance, FDataSet.ObjectType);
end;

procedure TPersistoDataSetTest.WhenTheFieldIsCharTypeTheSizeMustBeOne;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(1, FDataSet.FieldByName('Char').Size);
end;

procedure TPersistoDataSetTest.WhenTheFieldIsStringTypeTheSizeMustBeTheValueFromAttribute;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(150, FDataSet.FieldByName('String').Size);
end;

procedure TPersistoDataSetTest.WhenTheFieldTypeIsntMappedCanRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfBooleanTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TBooleanField, FDataSet.FieldByName('Boolean').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfClassTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;

  FDataSet.Open;

  Assert.AreEqual(TPersistoObjectField, FDataSet.FieldByName('Class').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfDateTimeTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TDateTimeField, FDataSet.FieldByName('DateTime').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfDateTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TDateField, FDataSet.FieldByName('Date').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfEnumeratorTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TIntegerField, FDataSet.FieldByName('Enumerator').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfFloatTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TFloatField, FDataSet.FieldByName('Float').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfInt64TypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TLargeintField, FDataSet.FieldByName('Int64').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfIntegerTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TIntegerField, FDataSet.FieldByName('Integer').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfStringTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TWideStringField, FDataSet.FieldByName('String').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfTimeTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TTimeField, FDataSet.FieldByName('Time').ClassType);
end;

procedure TPersistoDataSetTest.WhenThePropertyIsOfUniqueIdentifierTypeMustCreateTheFieldWithTheTypeExpected;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.AreEqual(TWideStringField, FDataSet.FieldByName('UniqueIdentifier').ClassType);
end;

procedure TPersistoDataSetTest.WhenTryToChangeTheObjectClassNameWithAnOpenDataSetMustRaiseAnError;
begin
  FDataSet.ObjectClassName := TMyTestClass.QualifiedClassName;

  FDataSet.Open;

  Assert.WillRaise(
    procedure
    begin
      FDataSet.ObjectClassName := TMyTestClass.QualifiedClassName;
    end, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenTryToChangeTheObjectClassWhenTheDataSetIsOpenMustRaiseAnError;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.WillRaise(
    procedure
    begin
      FDataSet.ObjectClass := TMyTestClass;
    end, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenTryToGetTheFieldListInDesigningTimeCantRaiseAnyError;
begin
  TPersistoDataSetHack(FDataSet).SetDesigning(True);

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldDefs.Update;
    end);
end;

procedure TPersistoDataSetTest.WhenTryToLoadTheClassNameAndTheTypeDontExistsMustRaiseAnError;
begin
  FDataSet.ObjectClassName := 'InvalidType';

  Assert.WillRaise(
    procedure
    begin
      FDataSet.Open;
    end, EDataSetWithoutObjectDefinition);
end;

procedure TPersistoDataSetTest.WhenTryToOpenTheDataSetInDesigningTimeCantRaiseAnyError;
begin
  TPersistoDataSetHack(FDataSet).SetDesigning(True);

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenTryToOpenTheDataSetWithoutAnObjectInformationMustRaiseAnError;
begin
  Assert.WillRaise(FDataSet.Open, EDataSetWithoutObjectDefinition);
end;

procedure TPersistoDataSetTest.WhenUpdateFieldDefsMustLoadTheFieldInformationInTheFieldDefsCollection;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.FieldDefs.Update;

  Assert.GreaterThan(4, FDataSet.FieldDefs.Count);
end;

procedure TPersistoDataSetTest.WhenChangeTheObjectTypeFromTheDataSetMustMarkTheFieldDefsToUpdateAgain;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.FieldDefs.Update;

  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  Assert.IsFalse(FDataSet.FieldDefs.Updated);
end;

procedure TPersistoDataSetTest.WhenCreateAFieldOfOneObjectClassMustLoadAllClassLevelsInTheFieldName;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;

  FDataSet.Open;

  Assert.IsNotNil(FDataSet.FieldByName('Class.AnotherObject.AnotherName').ClassType);
end;

{ TMyTestClass }

destructor TMyTestClass.Destroy;
begin
  FAnotherObject.Free;

  inherited;
end;

{ TAnotherObject }

destructor TAnotherObject.Destroy;
begin
  FAnotherObject.Free;

  inherited;
end;

{ TCallbackClass }

constructor TCallbackClass.Create(CallbackProc: TProc<TPersistoDataSet>);
begin
  FCallbackProc := CallbackProc;
end;

procedure TCallbackClass.OnCalcFields(DataSet: TDataSet);
var
  ORMDataSet: TPersistoDataSet absolute DataSet;

begin
  FCallbackProc(ORMDataSet);
end;

end.

