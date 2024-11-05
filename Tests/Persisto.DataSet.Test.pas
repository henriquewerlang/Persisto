unit Persisto.DataSet.Test;

interface

uses System.SysUtils, System.Rtti, Data.DB, System.Generics.Collections, Persisto.DataSet, Test.Insight.Framework;

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
    procedure WhenFillTheObjectListAndOpenTheDataSetWithAnEmptyArrayMustRaiseError;
    [Test]
    procedure WhenFillTheObjectListMustLoadTheObjectClassTypeWithTheObjectClassType;
    [Test]
    procedure WhenGetTheObjectListMustReturnTheObjectsFilledInTheList;
    [Test]
    procedure WhenFillTheObjectListAndOpenTheDataSetTheRecordCountMustBeEqualTheLengthOfTheObjectList;
    [Test]
    procedure IfTheDataSetIsntOpenTheRecordCountMustReturnMinusOneValue;
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



    [TTest]
    procedure WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
    [TTest]
    procedure TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
    [TTest]
    procedure WhenOpenDataSetFromAListMustHaveToLoadFieldListWithPropertiesOfMappedObject;
    [TestCase('Array', 'MyArray,ftDataSet')]
    [TestCase('Boolean', 'Boolean,ftBoolean')]
    [TestCase('Byte', 'Byte,ftByte')]
    [TestCase('Cardinal', 'Cardinal,ftLongWord')]
    [TestCase('Char', 'Char,ftString')]
    [TestCase('Class', 'Class,ftVariant')]
    [TestCase('Currency', 'Currency,ftCurrency')]
    [TestCase('Date', 'Date,ftDate')]
    [TestCase('DateTime', 'DateTime,ftDateTime')]
    [TestCase('Double', 'Double,ftFloat')]
    [TestCase('Enumerator', 'MyEnum,ftInteger')]
    [TestCase('Int64', 'Int64,ftLargeint')]
    [TestCase('Integer', 'Int,ftInteger')]
    [TestCase('Sigle', 'Single,ftSingle')]
    [TestCase('String', 'Str,ftString')]
    [TestCase('Time', 'Time,ftTime')]
    [TestCase('WideChar', 'WideChar,ftString')]
    [TestCase('WideString', 'WideString,ftWideString')]
    [TestCase('Word', 'Word,ftWord')]
    procedure TheFieldTypeMustMatchWithPropertyType(FieldName: String; TypeToCompare: TFieldType);
    [TTest]
    procedure WhenOpenTheDataSetWithAObjectTheRecordCountMustBeOne;
    [TTest]
    procedure WhenOpenTheDataSetWithAListTheRecordCountMustBeTheSizeOfTheList;
    [TTest]
    procedure AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
    [TTest]
    procedure WhenNavigateByDataSetMustHaveToShowTheValuesFromTheList;
    [TTest]
    procedure WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
    [TTest]
    procedure WhenHaveFieldDefDefinedCantLoadFieldsFromTheClass;
    [TTest]
    procedure WhenTheFieldDefNameNotExistsInPropertyListMustRaiseAException;
    [TTest]
    procedure WhenTheFieldAndPropertyTypeAreDifferentItHasToRaiseAnException;
    [TTest]
    procedure WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
    [TTest]
    procedure WhenTryOpenADataSetWithoutAObjectDefinitionMustRaiseAnError;
    [TTest]
    procedure WhenFilledTheObjectClassNameHasToLoadTheDataSetWithoutErrors;
    [TTest]
    procedure WhenUseQualifiedClassNameHasToLoadTheDataSetWithoutErrors;
    [TTest]
    procedure WhenCheckingIfTheFieldIsNullCantRaiseAnError;
    [TTest]
    procedure WhenCallFirstHaveToGoToTheFirstRecord;
    [TTest]
    procedure UsingBookmarkHaveToWorkLikeSpected;
    [TTest]
    procedure WhenUseTheOpenClassMustLoadFieldFromTheClass;
    [TTest]
    procedure WhenExistsAFieldInDataSetMustFillTheFieldDefFromThisField;
    [TTest]
    procedure WhenInsertIntoDataSetCantRaiseAnError;
    [TTest]
    procedure WhenPostARecordMustAppendToListOfObjects;
    [TestCase('Boolean', 'Boolean,True')]
    [TestCase('Byte', 'Byte,123')]
    [TestCase('Cardinal', 'Cardinal,123')]
    [TestCase('Char', 'Char,C')]
    [TestCase('Currency', 'Currency;123.456', ';')]
    [TestCase('Date', 'Date,12/21/2020')]
    [TestCase('DateTime', 'DateTime,12/21/2020 17:17:17')]
    [TestCase('Double', 'Double;123.456', ';')]
    [TestCase('Enumerator', 'MyEnum,1')]
    [TestCase('Int64', 'Int64,123')]
    [TestCase('Integer', 'Int,123')]
    [TestCase('Sigle', 'Single;123.456', ';')]
    [TestCase('String', 'Str,Value String')]
    [TestCase('Time', 'Time,17:17:17')]
    [TestCase('WideChar', 'WideChar,C')]
    [TestCase('WideString', 'WideString,Value String')]
    [TestCase('Word', 'Word,123')]
    procedure WhenSetTheFieldValueMustChangeTheValueFromTheClass(FieldName, FieldValue: String);
    [TestCase('Char', 'Char,1')]
    [TestCase('String', 'Str,50')]
    [TestCase('WideChar', 'WideChar,1')]
    [TestCase('WideString', 'WideString,50')]
    procedure WhenAFieldIsACreateTheFieldMustHaveTheMinimalSizeDefined(FieldName: String; Size: Integer);
    [TTest]
    procedure WhenOpenAnEmptyDataSetCantRaiseAnError;
    [TTest]
    procedure WhenOpenAnEmptyDataSetTheCurrentObjectMustReturnNil;
    [TTest]
    procedure WhenTryToGetAFieldValueFromAEmptyDataSetCantRaiseAnError;
    [TTest]
    procedure WhenOpenAnEmptyDataSetTheValueOfTheFieldMustReturnNull;
    [TTest]
    procedure WhenASubPropertyIsAnObjectAndTheValueIsNilCantRaiseAnError;
    [TTest]
    procedure WhenFillingAFieldWithSubPropertyMustFillTheLastLevelOfTheField;
    [TTest]
    procedure WhenOpenAClassWithDerivationMustLoadTheFieldFromTheBaseClassToo;
    [TTest]
    procedure WhenTheDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldFromASubPropertyThatIsAnObject;
    [TTest]
    procedure EveryInsertedObjectMustGoToTheObjectList;
    [TTest]
    procedure AfterInsertAnObjectMustResetTheObjectToSaveTheNewInfo;
    [TTest]
    procedure WhenEditingTheDataSetAndSetAFieldValueMustChangeThePropertyOfTheObjectToo;
    [TTest]
    procedure TheOldValuePropertyFromFieldMustReturnTheOriginalValueOfTheObjectBeingEdited;
    [TTest]
    procedure WhenAStringFieldIsEmptyCantRaiseAnErrorBecauseOfIt;
    [TTest]
    procedure WhenTheEditionIsCanceledMustReturnTheOriginalValueFromTheField;
    [TTest]
    procedure WhenEditingCantIncreseTheRecordCountWhenPostTheRecord;
    [TTest]
    procedure WhenSetAValueToAFieldThatIsAnObjectMustFillThePropertyInTheClassWithThisObject;
    [TTest]
    procedure WhenGetAValueFromAFieldAndIsAnObjectMustReturnTheObjectFromTheClass;
    [TTest]
    procedure OpenArrayObjectMustLoadTheObjectTypeFromTheParam;
    [TTest]
    procedure OpenArrayObjectMustActiveTheDataSet;
    [TTest]
    procedure OpenArrayMustLoadTheObjectListWithTheParamPassed;
    [TTest]
    procedure TheRecNoPropertyMustReturnTheCurrentRecordPositionInTheDataSet;
    [TTest]
    procedure WhenADataSetIsActiveCantOpenItAgainMustRaiseAnError;
    [TTest]
    procedure WhenCleanUpTheObjectClassNameMustStayEmpty;
    [TTest]
    procedure WhenChangeTheObjectTypeOfTheDataSetMustBeClosedToAcceptTheChange;
    [TTest]
    procedure WhenFillTheDataSetFieldPropertyMustLoadTheParentDataSetPropertyWithTheDataSetCorrect;
    [TTest]
    procedure WhenCleanUpTheDataSetFieldPropertyTheParentDataSetMustBeCleanedToo;
    [TTest]
    procedure WhenFillTheDataSetFieldMustLoadTheObjectTypeFromThePropertyOfTheField;
    [TTest]
    procedure WhenOpenTheDetailDataSetMustLoadAllRecordsFromTheParentDataSet;
    [TTest]
    procedure WhenScrollTheParentDataSetMustLoadTheArrayInDetailDataSet;
    [TTest]
    procedure WhenPostTheDetailDataSetMustUpdateTheArrayValueFromParentDataSet;
    [TTest]
    procedure WhenTheRecordBufferIsBiggerThenOneMustLoadTheBufferOfTheDataSetAsExpected;
    [TTest]
    procedure WhenOpenADataSetWithDetailMustLoadTheRecordsOfTheDetail;
    [TTest]
    procedure WhenTheDetailDataSetHasAComposeNameMustLoadTheObjectTypeCorrectly;
    [TTest]
    procedure WhenTheDetailDataSetHasAComposeNameMustLoadTheDataCorrecty;
    [TTest]
    procedure WhenInsertARecordThenCancelTheInsertionAndStartANewInsertTheOldBufferMustBeCleanedUp;
    [TTest]
    procedure WhenThePropertyIsANullableTypeMustCreateTheField;
    [TTest]
    procedure WhenThePropertyIsANullableTypeMustCreateTheFieldWithTheInternalTypeOfTheNullable;
    [TTest]
    procedure WhenTheFieldIsMappedToANullableFieldAndTheValueIsntFilledMustReturnNullInTheFieldValue;
    [TTest]
    procedure WhenTheNullablePropertyIsFilledMustReturnTheValueFilled;
    [TTest]
    procedure WhenClearAFieldCantRaiseAnError;
    [TTest]
    procedure WhenFillANullableFieldWithTheNullValueMustMarkThePropertyWithIsNullTrue;
    [TTest]
    procedure WhenFillANullableFieldWithAnValueMustFillThePropertyWithTheValue;
    [TTest]
    procedure GetADateTimeFieldMustReturnTheValueAsExpected;
    [TTest]
    procedure WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheField;
    [TTest]
    procedure WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheFieldWithTheGenericTypeOfTheLazyRecord;
    [TTest]
    procedure WhenGetTheValueOfALazyPropertyMustReturnTheValueInsideTheLazyRecord;
    [TTest]
    procedure WhenFillAFieldOfALazyPropertyMustFieldTheLazyStructure;
    [TTest]
    procedure WhenTryToGetAComposeFieldNameFromALazyPropertyMustLoadAsExpected;
    [TTest]
    procedure WhenOpenADataSetWithCalculatedFieldCantRaiseAnyError;
    [TTest]
    procedure WhenTryToGetTheValueOfACalculatedFieldCantRaiseAnyError;
    [TTest]
    procedure WhenADataSetNotInEditingStateMustRaiseAnErrorIfTryToFillAFieldValue;
    [TTest]
    procedure WhenFillTheValueOfACalculatedFieldCantRaiseAnyError;
    [TTest]
    procedure WhenToCalculateAFieldMustReturnTheValueExpected;
    [TTest]
    procedure WhenExitsMoreThenOneCalculatedFieldMustReturnTheValueAsExpected;
    [TTest]
    procedure WhenOpenADataSetWithAnEmptyArrayCantRaiseAnyError;
    [TTest]
    procedure WhenCloseTheDataSetMustUmbingTheFieldsAndCloseTheDataSetDetail;
    [TTest]
    procedure WhenMoveTheMasterDataSetTheCountOfTheDetailRecordMustRepresentTheExatValueFromArrayOfMasterClass;
    [TTest]
    procedure WhenTheDetailDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldValue;
    [TTest]
    procedure WhenMoveTheMasterDataSetTheDetailDataSetMustBeInTheFirstRecord;
    [TTest]
    procedure WhenDeleteARecordFromADataSetMustRemoveTheValueFromTheDataSet;
    [TTest]
    procedure WhenRemoveARecordFromDetailMustUpdateTheArrayOfTheParentClass;
    [TTest]
    procedure WhenScrollTheDataSetMustCalculateTheFields;
    [TTest]
    procedure WhenPutTheDataSetInInsertStateMustClearTheCalculatedFields;
    [TTest]
    procedure WhenIsRemovedTheLastRecordFromDataSetCantRaiseAnError;
    [TTest]
    procedure WhenRemoveAComposeDetailFieldNameMustUpdateTheParentClassWithTheNewValues;
    [TTest]
    procedure WhenOpenTheDataSetWithAListAndTheListIsChangedTheResyncCantRaiseAnyError;
    [TTest]
    procedure TheCalcBufferMustBeClearedOnScrollingTheDataSet;
    [TTest]
    procedure WhenOpenADataSetWithoutFieldsMustAddTheSelfFieldToDataSet;
    [TTest]
    procedure WhenAddTheSelfFieldCantRaiseAnyError;
    [TTest]
    procedure TheSelfFieldTypeMustBeVariant;
    [TTest]
    procedure WhenAddTheSelfFieldMustBeOfTheVariantType;
    [TTest]
    procedure WhenGetTheValueOfTheSelfFieldMustReturnTheCurrentObjectOfThDataSet;
    [TTest]
    procedure WhenFillTheCurrentObjectMustReplaceTheCurrentValueInTheInternalList;
    [TTest]
    procedure WhenInsertingMustTheSelfFieldMustReplaceTheCurrentObjectHasExpected;
    [TTest]
    procedure WhenFillANilValueToSelfFieldMustRaiseAnError;
    [TTest]
    procedure WhenTryToFillAnObjectWithDifferentTypeMustRaiseAnError;
    [TTest]
    procedure WhenChangeTheSelfFieldMustNotifyTheChangeOfAllFieldsInDataSet;
    [TTest]
    procedure WhenFillTheIndexFieldNamesMustOrderTheValuesInAscendingOrderAsExpected;
    [TTest]
    procedure WhenFillTheIndexFieldNamesWithMoreTheOnFieldMustOrderAsExpected;
    [TTest]
    procedure WhenPutTheMinusSymbolBeforeTheFieldNameInIndexMustSortDescending;
    [TTest]
    procedure WhenChangeTheIndexFieldNamesWithDataSetOpenMustSortTheValues;
    [TTest]
    procedure AfterChangeAnRecordMustSortTheDataSetAgain;
    [TTest]
    procedure WhenSortACalculatedFieldCantRaiseAnyError;
    [TTest]
    procedure WhenSortACalculatedFieldAsExpected;
    [TTest]
    procedure WhenNotUsingACalculatedFieldInTheIndexCantCallTheOnCalcFields;
    [TTest]
    procedure WhenCallTheResyncMustReorderTheDataSet;
    [TTest]
    procedure WhenFilterTheDataSetMustStayOnlyTheFilteredRecords;
    [TTest]
    procedure WhenApplyAFilterBeforeOpenTheDataSetMustFilterTheRecordAfterOpen;
    [TTest]
    procedure WhenRemoveTheFilterMustReturnTheOriginalRecordsToTheDataSet;
    [TTest]
    procedure WhenInsertingARecordInAFilteredDataSetMustCheckTheFilterToAddTheRecordToTheDataSet;
    [TTest]
    procedure WhenEditingARecordAndTheFilterBecameInvalidMustRemoveTheRecordFromDataSet;
    [TTest]
    procedure WhenSortAFilteredDataSetCantRaiseAnyError;
    [TTest]
    procedure WhenOrderingANullFieldValueItMustBeTheFirstRecordInTheSortedDataSet;
    [TTest]
    procedure WhenExistsMoreTheOneNullValueMustBeTheFirstRecordsAnThenTheFieldsWithValue;
    [TTest]
    procedure WhenOrderingANullFieldValueInDescendingOrderItMustBeTheLastRecordInTheSortedDataSet;
    [TTest]
    procedure WhenGetTheRecordCountFromAClosedDataSetCantRaiseAnyError;
    [TTest]
    procedure WhenTheDataSetIsClosedTheRecordCountMustReturnMinusOne;
    [TTest]
    procedure WhenCreateADataSetFieldAndOpenTheParentDataSetMustOpenTheDetailToo;
    [TTest]
    procedure WhenGetTheCurrentObjectOfAClosedDataSetCantRaiseAnyError;
    [TTest]
    procedure WhenGetValueOfAnFieldInAClosedDataSetCantRaiseAnyError;
    [TTest]
    procedure WhenTheDataLinkTryToGetAFieldValueInTheDetailDataSetCantRaiseAnyError;
    [TTest]
    procedure WhenTheDataSetIsOpenAndHasADetailAndTheDetailHasRecordsMustClearTheDetailAfterIntertingInTheParentDataSet;
    [TTest]
    procedure WhenTheDataSetDetailIsFilteredAndIsInsertedAnRecordInvalidForFilterMustLoadTheParentArrayAnyWay;
  end;

{$M+}
  TAnotherObject = class
  private
    FAnotherObject: TAnotherObject;
    FAnotherName: String;
  public
    destructor Destroy; override;
  published
    property AnotherName: String read FAnotherName write FAnotherName;
    property AnotherObject: TAnotherObject read FAnotherObject write FAnotherObject;
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
    FClass: TObject;
    FMyEnum: TMyEnumerator;
    FMyArray: TArray<TMyTestClassTypes>;
  published
    property Boolean: Boolean read FBoolean write FBoolean;
    property Byte: Byte read FByte write FByte;
    property Cardinal: Cardinal read FCardinal write FCardinal;
    property Char: AnsiChar read FChar write FChar;
    property &Class: TObject read FClass write FClass;
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

implementation

uses System.Classes, System.Variants, Data.DBConsts, Persisto.Test.Entity;

{ TPersistoDataSetTest }

procedure TPersistoDataSetTest.AfterChangeAnRecordMustSortTheDataSetAgain;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];
  var MyNewClass := TMyTestClass.Create;
  MyNewClass.Id := -1;

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

  DataSet.IndexFieldNames := 'Id';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.Insert;

  (DataSet.FieldByName('Self') as TPersistoObjectField).AsObject := MyNewClass;

  DataSet.Post;

  DataSet.First;

  Assert.AreEqual(-1, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.AfterInsertAnObjectMustResetTheObjectToSaveTheNewInfo;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  DataSet.FieldByName('Name').AsString := 'Name1';

  DataSet.Post;

  DataSet.Append;

  DataSet.FieldByName('Name').AsString := 'Name2';

  DataSet.Post;

  Assert.AreEqual('Name2', DataSet.GetCurrentObject<TMyTestClass>.Name);

  DestroyObjects(DataSet);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.AfterOpenTheDataSetAndTryToInserMustInsertWithoutAnyError;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.WillNotRaise(FDataSet.Insert);
end;

procedure TPersistoDataSetTest.AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.Id := 123456;
  MyObject.Name := 'MyName';
  MyObject.Value := 5477.555;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(123456, DataSet.FieldByName('Id').AsInteger);
  Assert.AreEqual('MyName', DataSet.FieldByName('Name').AsString);
  Assert.AreEqual(5477.555, DataSet.FieldByName('Value').AsFloat);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.DestroyObjects(DataSet: TPersistoDataSet);
begin
//  DataSet.First;
//
//  while not DataSet.Eof do
//  begin
//    DataSet.GetCurrentObject<TObject>.Free;
//
//    DataSet.Next;
//  end;
end;

procedure TPersistoDataSetTest.EveryInsertedObjectMustGoToTheObjectList;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  DataSet.Post;

  Assert.IsNotNil(DataSet.GetCurrentObject<TObject>);

  DestroyObjects(DataSet);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.GetADateTimeFieldMustReturnTheValueAsExpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClassTypes.Create;
  MyObject.DateTime := EncodeDate(2020, 02, 18) + EncodeTime(12, 34, 56, 0);

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(MyObject.DateTime, DataSet.FieldByName('DateTime').AsDateTime);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.IfTheDataSetIsntOpenTheRecordCountMustReturnMinusOneValue;
begin
  Assert.AreEqual(-1, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.OpenArrayMustLoadTheObjectListWithTheParamPassed;
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

//  DataSet.OpenObjectArray(TMyTestClass, [MyClass]);

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.OpenArrayObjectMustActiveTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenObjectArray(TMyTestClass, nil);

  Assert.IsTrue(DataSet.Active);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.OpenArrayObjectMustLoadTheObjectTypeFromTheParam;
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenObjectArray(TMyTestClass, nil);

  Assert.AreEqual(Context.GetType(TMyTestClass) as TRttiInstanceType, DataSet.ObjectType);

  DataSet.Free;
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

procedure TPersistoDataSetTest.TheCalcBufferMustBeClearedOnScrollingTheDataSet;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      if DataSet.RecNo = 1 then
      begin
        DataSet.FieldByName('Calculated1').AsInteger := 20;
        DataSet.FieldByName('Calculated2').AsInteger := 20;
        DataSet.FieldByName('Calculated3').AsInteger := 20;
      end
      else if DataSet.RecNo = 2 then
        DataSet.FieldByName('Calculated2').AsInteger := 10;
    end);
  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var DataLink := TDataLink.Create;
  DataLink.BufferCount := 5;
  var DataSource := TDataSource.Create(DataSet);
  var Field: TField := TIntegerField.Create(DataSet);
  Field.FieldName := 'Calculated1';
  Field.FieldKind := fkCalculated;
  var List: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  DataLink.DataSource := DataSource;
  DataSource.DataSet := DataSet;

  Field.DataSet := DataSet;

  Field := TIntegerField.Create(DataSet);
  Field.FieldName := 'Calculated2';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TIntegerField.Create(DataSet);
  Field.FieldName := 'Calculated3';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

//  DataSet.OpenArray<TMyTestClass>(List);

  DataSet.Next;

  DataSet.Next;

  DataSet.Resync([]);

  DataSet.Prior;

  Assert.AreEqual(0, DataSet.FieldByName('Calculated1').AsInteger);
  Assert.AreEqual(10, DataSet.FieldByName('Calculated2').AsInteger);
  Assert.AreEqual(0, DataSet.FieldByName('Calculated3').AsInteger);

  CallbackClass.Free;

  DataSet.Free;

  DataLink.Free;

  for var Item in List do
    Item.Free;
end;

procedure TPersistoDataSetTest.TheFieldTypeMustMatchWithPropertyType(FieldName: String; TypeToCompare: TFieldType);
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClassTypes.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(TypeToCompare, DataSet.FieldByName(FieldName).DataType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual('Id', DataSet.Fields[0].FieldName);
  Assert.AreEqual('Name', DataSet.Fields[1].FieldName);
  Assert.AreEqual('Value', DataSet.Fields[2].FieldName);
  Assert.AreEqual('AnotherObject', DataSet.Fields[3].FieldName);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.TheOldValuePropertyFromFieldMustReturnTheOriginalValueOfTheObjectBeingEdited;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  MyClass.Name := 'My Name';

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'Another Name';

  Assert.AreEqual('My Name', DataSet.FieldByName('Name').OldValue);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.TheRecNoPropertyMustReturnTheCurrentRecordPositionInTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var List: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

//  DataSet.OpenArray<TMyTestClass>(List);

  DataSet.Next;

  DataSet.Next;

  Assert.AreEqual(3, DataSet.RecNo);

  for var Item in List do
    Item.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.TheSelfFieldTypeMustBeVariant;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(ftVariant, DataSet.FieldByName('Self').DataType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.UsingBookmarkHaveToWorkLikeSpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  for var A := 1 to 4 do
    DataSet.Next;

  var Bookmark := DataSet.Bookmark;

  DataSet.First;

  DataSet.Bookmark := Bookmark;

  Assert.AreEqual('Name5', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenADataSetIsActiveCantOpenItAgainMustRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClassTypes>;
//
//  Assert.WillRaise(DataSet.OpenClass<TMyTestClassTypes>, Exception);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenADataSetNotInEditingStateMustRaiseAnErrorIfTryToFillAFieldValue;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

//  DataSet.OpenObject(MyClass);

  Assert.WillRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString := 'Another Name';
    end, EDataSetNotInEditingState);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenAddTheSelfFieldCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  Assert.WillNotRaise(
    procedure
    begin
//      DataSet.OpenObject(MyObject);
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenAddTheSelfFieldMustBeOfTheVariantType;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TStringField.Create(DataSet);
  Field.FieldName := 'Self';

  Field.DataSet := DataSet;

  Assert.WillRaise(
    procedure
    begin
//      DataSet.OpenClass<TMyTestClass>;
    end, ESelfFieldTypeWrong);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenAFieldIsACreateTheFieldMustHaveTheMinimalSizeDefined(FieldName: String; Size: Integer);
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClassTypes>;

  Assert.AreEqual(Size, DataSet.FieldByName(FieldName).Size);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject.AnotherName := 'MyName';

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual('MyName', DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenApplyAFilterBeforeOpenTheDataSetMustFilterTheRecordAfterOpen;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  Assert.AreEqual(1, DataSet.RecordCount);

  Assert.AreEqual(5, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenTheDataLinkTryToGetAFieldValueInTheDetailDataSetCantRaiseAnyError;
begin
//  var DataLink := TDataLinkMock.Create;
//  var DataSet := TPersistoDataSet.Create(nil);
//  DataSet.Name := 'Pai';
//  var DataSetDetail := TPersistoDataSet.Create(nil);
//  DataSetDetail.Name := 'Filho';
//  var DataSetField := TDataSetField.Create(nil);
//  DataSetField.FieldName := 'MyArray';
//  DataSetField.DataSet := DataSet;
//  var DataSource := TDataSource.Create(nil);
//  var DetailField := TStringField.Create(nil);
//  DetailField.FieldName := 'Str';
//  DetailField.DataSet := DataSetDetail;
//  var MyClass := TMyTestClassTypes.Create;
//  MyClass.MyArray := [TMyTestClassTypes.Create];
//
//  DataLink.DataSource := DataSource;
//  DataLink.OnActiveChanged :=
//    procedure
//    begin
//      DataSetDetail.FieldByName('Str').DisplayText;
//    end;
//  DataSetDetail.DataSetField := DataSetField;
//  DataSource.DataSet := DataSetDetail;
//
//  DataSet.OpenObject(MyClass);
//
//  DataSet.Close;
//
//  Assert.WillNotRaise(
//    procedure
//    begin
//      DataSet.OpenObject(MyClass);
//    end);
//
//  MyClass.MyArray[0].Free;
//
//  MyClass.Free;
//
//  DataSetDetail.Free;
//
//  DataSet.Free;
//
//  DataSource.Free;
//
//  DataLink.Free;
end;

procedure TPersistoDataSetTest.WhenTheDataSetDetailIsFilteredAndIsInsertedAnRecordInvalidForFilterMustLoadTheParentArrayAnyWay;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);

  Field.FieldName := 'MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenClass<TMyTestClassTypes>;

  DataSet.Insert;

  DataSetDetail.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := False;
    end);

  DataSetDetail.Append;

  DataSetDetail.Post;

  DataSetDetail.Append;

  DataSetDetail.Post;

  var MyClass := DataSet.GetCurrentObject<TMyTestClassTypes>;

  Assert.AreEqual(2, Length(MyClass.MyArray));

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDataSetIsClosedTheRecordCountMustReturnMinusOne;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  Assert.AreEqual(-1, DataSet.RecordCount);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldFromASubPropertyThatIsAnObject;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.FieldDefs.Add('AnotherObject.AnotherName', ftString, 50);

//  DataSet.OpenClass<TMyTestClass>;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('AnotherObject.AnotherName').AsString
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDataSetIsOpenAndHasADetailAndTheDetailHasRecordsMustClearTheDetailAfterIntertingInTheParentDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  var MyClass: TArray<TParentClass> := [TParentClass.Create, TParentClass.Create];
  MyClass[0].MyClass := TMyTestClassTypes.Create;
  MyClass[0].MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSet.Insert;

  Assert.AreEqual(0, DataSetDetail.RecordCount);

  MyClass[0].MyClass.MyArray[0].Free;

  MyClass[0].MyClass.MyArray[1].Free;

  MyClass[0].MyClass.Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDetailDataSetHasAComposeNameMustLoadTheDataCorrecty;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  var MyClass: TArray<TParentClass> := [TParentClass.Create, TParentClass.Create];
  MyClass[0].MyClass := TMyTestClassTypes.Create;
  MyClass[0].MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass[0].MyClass.MyArray[0].Free;

  MyClass[0].MyClass.MyArray[1].Free;

  MyClass[0].MyClass.Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDetailDataSetHasAComposeNameMustLoadTheObjectTypeCorrectly;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenClass<TParentClass>;

  Assert.AreEqual('TMyTestClassTypes', DataSetDetail.ObjectType.Name);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheDetailDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldValue;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Next;

  Assert.WillNotRaise(
    procedure
    begin
      DataSetDetail.FieldByName('Cardinal').AsInteger;
    end);

  MyClass[0].MyArray[0].Free;

  MyClass[0].MyArray[1].Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheEditionIsCanceledMustReturnTheOriginalValueFromTheField;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Name := 'My Name';

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'New Name';

  DataSet.Cancel;

  Assert.AreEqual('My Name', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenAStringFieldIsEmptyCantRaiseAnErrorBecauseOfIt;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

//  DataSet.OpenObject(MyClass);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString;
    end);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenASubPropertyIsAnObjectAndTheValueIsNilCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

//  DataSet.OpenObject(MyObject);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenCallFirstHaveToGoToTheFirstRecord;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  while not DataSet.Eof do
    DataSet.Next;

  DataSet.First;

  Assert.AreEqual('Name1', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenCallTheResyncMustReorderTheDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.IndexFieldNames := 'Id';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  MyArray[0].Id := 10;

  DataSet.Resync([]);

  Assert.AreEqual(2, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;end;

procedure TPersistoDataSetTest.WhenEditingARecordAndTheFilterBecameInvalidMustRemoveTheRecordFromDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Id := 5;

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Id').AsInteger := 4;

  DataSet.Post;

  Assert.AreEqual(0, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenEditingCantIncreseTheRecordCountWhenPostTheRecord;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Name := 'My Name';

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.Post;

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenEditingTheDataSetAndSetAFieldValueMustChangeThePropertyOfTheObjectToo;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  MyClass.Name := 'My Name';

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'Name1';

  Assert.AreEqual('Name1', MyClass.Name);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenExistsAFieldInDataSetMustFillTheFieldDefFromThisField;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TStringField.Create(DataSet);
  Field.FieldName := 'Name';

  Field.DataSet := DataSet;

//  DataSet.OpenClass<TMyTestClass>;

  Assert.AreEqual(1, DataSet.FieldDefs.Count);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenExistsMoreTheOneNullValueMustBeTheFirstRecordsAnThenTheFieldsWithValue;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TClassWithNullableProperty> := [TClassWithNullableProperty.Create, TClassWithNullableProperty.Create, TClassWithNullableProperty.Create,
    TClassWithNullableProperty.Create, TClassWithNullableProperty.Create];

  for var A := 0 to High(MyArray) do
    if A in [0, 2, 4] then
      MyArray[A].Nullable := Succ(A) * -1;

  DataSet.IndexFieldNames := 'Nullable';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.First;

  Assert.IsTrue(DataSet.FieldByName('Nullable').IsNull);

  DataSet.Next;

  Assert.IsTrue(DataSet.FieldByName('Nullable').IsNull);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenExitsMoreThenOneCalculatedFieldMustReturnTheValueAsExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      DataSet.FieldByName('Calculated1').AsInteger := 1;
      DataSet.FieldByName('Calculated2').AsInteger := 2;
      DataSet.FieldByName('Calculated3').AsInteger := 3;
    end);
  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated1';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated2';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated3';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TFloatField.Create(nil);
  Field.FieldName := 'Value';

  Field.DataSet := DataSet;

//  DataSet.OpenClass<TMyTestClass>;

  DataSet.Edit;

  DataSet.FieldByName('Value').AsInteger := 20;

  Assert.AreEqual(1, DataSet.FieldByName('Calculated1').AsInteger);
  Assert.AreEqual(2, DataSet.FieldByName('Calculated2').AsInteger);
  Assert.AreEqual(3, DataSet.FieldByName('Calculated3').AsInteger);

  CallbackClass.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFillAFieldOfALazyPropertyMustFieldTheLazyStructure;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TLazyClass.Create;
  var TheValue := TMyEntity.Create;

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  TPersistoObjectField(DataSet.FindField('Lazy')).AsObject := TheValue;

  Assert.AreEqual(TheValue, MyClass.Lazy.Value);

  DataSet.Free;

  MyClass.Free;

  TheValue.Free;
end;

procedure TPersistoDataSetTest.WhenFillANilValueToSelfFieldMustRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  Assert.WillRaise(
    procedure
    begin
      TPersistoObjectField(DataSet.FieldByName('Self')).AsObject := nil;
    end, ESelfFieldNotAllowEmptyValue);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFillANullableFieldWithAnValueMustFillThePropertyWithTheValue;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Nullable').AsInteger := 12345678;

  DataSet.Post;

  Assert.AreEqual(12345678, MyClass.Nullable);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenFillANullableFieldWithTheNullValueMustMarkThePropertyWithIsNullTrue;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;
  MyClass.Nullable := 12345678;

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Nullable').Clear;

  DataSet.Post;

  Assert.IsTrue(MyClass.NullableStored);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenFilledTheObjectClassNameHasToLoadTheDataSetWithoutErrors;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  Assert.WillNotRaise(DataSet.Open);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFillingAFieldWithSubPropertyMustFillTheLastLevelOfTheField;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

//  DataSet.OpenObject(MyObject);

  DataSet.Edit;

  DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString := 'A Name';

  Assert.AreEqual('A Name', DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString);

  DataSet.Free;

  MyObject.AnotherObject := nil;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheCurrentObjectMustReplaceTheCurrentValueInTheInternalList;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  var MyNewObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  DataSet.Edit;

  TPersistoObjectField(DataSet.FieldByName('Self')).AsObject := MyNewObject;

  DataSet.Post;

  Assert.AreEqual(DataSet.GetCurrentObject<TObject>, MyNewObject);

  DataSet.Free;

  MyObject.Free;

  MyNewObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheDataSetFieldMustLoadTheObjectTypeFromThePropertyOfTheField;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClassTypes>;

  DataSet.Open;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  Assert.IsNotNil(DataSetDetail.ObjectType);

  Assert.AreEqual('TMyTestClassTypes', DataSetDetail.ObjectType.Name);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheDataSetFieldPropertyMustLoadTheParentDataSetPropertyWithTheDataSetCorrect;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass<TMyTestClassTypes>;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

//  Assert.AreEqual(DataSet, DataSetDetail.ParentDataSet);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheIndexFieldNamesMustOrderTheValuesInAscendingOrderAsExpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A) * -1;

  DataSet.IndexFieldNames := 'Id';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(Succ(A) * -1, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheIndexFieldNamesWithMoreTheOnFieldMustOrderAsExpected;
const
  SORTED_VALUE: array[0..4] of String = ('Name0', 'Name3', 'Name1', 'Name4', 'Name2');

begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := Low(MyArray) to High(MyArray) do
  begin
    MyArray[A].Id := A mod 3;

    MyArray[A].Name := 'Name' + A.ToString;
  end;

  DataSet.IndexFieldNames := 'Id;Name';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  for var A := 0 to High(MyArray) do
  begin
    Assert.AreEqual(SORTED_VALUE[A], DataSet.FieldByName('Name').AsString);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListAndOpenTheDataSetTheRecordCountMustBeEqualTheLengthOfTheObjectList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, MyObject, MyObject];

  FDataSet.Open;

  Assert.AreEqual(3, FDataSet.RecordCount);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListAndOpenTheDataSetWithAnEmptyArrayMustRaiseError;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataSet.Objects := nil;
    end, EObjectArrayCantBeEmpty);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectListMustLoadTheObjectClassTypeWithTheObjectClassType;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  Assert.AreEqual(FDataSet.ObjectClass, MyObject.ClassType);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheValueOfACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

//  DataSet.OpenClass<TParentClass>;

  DataSet.Edit;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Calculated').AsInteger := 20;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenFilterTheDataSetMustStayOnlyTheFilteredRecords;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

  Assert.AreEqual(1, DataSet.RecordCount);

  Assert.AreEqual(5, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenGetAValueFromAFieldAndIsAnObjectMustReturnTheObjectFromTheClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.AnotherObject := TAnotherObject.Create;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(MyClass.AnotherObject, (DataSet.FieldByName('AnotherObject') as TPersistoObjectField).AsObject);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheCurrentObjectOfAClosedDataSetCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.GetCurrentObject<TMyTestClassTypes>;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheObjectListMustReturnTheObjectsFilledInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, MyObject, MyObject];

  Assert.AreEqual(3, Length(FDataSet.Objects));
  Assert.AreEqual(MyObject, FDataSet.Objects[0]);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheRecordCountFromAClosedDataSetCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.RecordCount;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheValueOfALazyPropertyMustReturnTheValueInsideTheLazyRecord;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TLazyClass.Create;
  var TheValue := TMyEntity.Create;

  MyClass.Lazy.Value := TheValue;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(TheValue, TPersistoObjectField(DataSet.FindField('Lazy')).AsObject);

  DataSet.Free;

  MyClass.Free;

  TheValue.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheValueOfTheSelfFieldMustReturnTheCurrentObjectOfThDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(DataSet.GetCurrentObject<TObject>, TPersistoObjectField(DataSet.FieldByName('Self')).AsObject);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenGetValueOfAnFieldInAClosedDataSetCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TStringField.Create(nil);
  Field.FieldName := 'Str';
  Field.DataSet := DataSet;
  var MyClass := TMyTestClassTypes.Create;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Str').AsString;
    end);

  MyClass.Free;

  DataSet.Free;
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

procedure TPersistoDataSetTest.WhenHaveFieldDefDefinedCantLoadFieldsFromTheClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('Id', ftInteger);
  DataSet.FieldDefs.Add('Name', ftString, 20);
  DataSet.FieldDefs.Add('Value', ftFloat);

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(3, DataSet.FieldDefs.Count);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenInsertARecordThenCancelTheInsertionAndStartANewInsertTheOldBufferMustBeCleanedUp;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Append;

  DataSet.FieldByName('Name').AsString := 'Name1';

  DataSet.Cancel;

  DataSet.Append;

  Assert.AreEqual(EmptyStr, DataSet.FieldByName('Name').AsString);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenInsertingARecordInAFilteredDataSetMustCheckTheFilterToAddTheRecordToTheDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Insert;

  DataSet.FieldByName('Id').AsInteger := 5;

  DataSet.Post;

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.GetCurrentObject<TMyTestClass>.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenInsertingARecordTheCurrentObjectMustReturnTheObjectBeenInserted;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  Assert.IsNotNil(FDataSet.CurrentObject);
end;

procedure TPersistoDataSetTest.WhenInsertingMustTheSelfFieldMustReplaceTheCurrentObjectHasExpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Insert;

  TPersistoObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;

  Assert.AreEqual(DataSet.GetCurrentObject<TObject>, MyObject);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenInsertIntoDataSetCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.WillNotRaise(DataSet.Append);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenMoveTheMasterDataSetTheCountOfTheDetailRecordMustRepresentTheExatValueFromArrayOfMasterClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Next;

  DataSet.Prior;

  DataSet.Next;

  DataSet.Prior;

  DataSet.Next;

  Assert.AreEqual(0, DataSetDetail.RecordCount);

  MyClass[0].MyArray[0].Free;

  MyClass[0].MyArray[1].Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenMoveTheMasterDataSetTheDetailDataSetMustBeInTheFirstRecord;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass.MyArray[0].Cardinal := 10;
  MyClass.MyArray[1].Cardinal := 20;

//  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Close;

  DataSetDetail.Close;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(10, DataSetDetail.FieldByName('Cardinal').AsInteger);

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
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
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  for var B := 1 to 10 do
  begin
    Assert.AreEqual(B, DataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), DataSet.FieldByName('Name').AsString);
    Assert.AreEqual(B + B, DataSet.FieldByName('Value').AsFloat);

    DataSet.Next;
  end;

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  DataSet.Last;

  for var B := 10 downto 1 do
  begin
    Assert.AreEqual(B, DataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), DataSet.FieldByName('Name').AsString);
    Assert.AreEqual(B + B, DataSet.FieldByName('Value').AsFloat);

    DataSet.Prior;
  end;

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenNotUsingACalculatedFieldInTheIndexCantCallTheOnCalcFields;
begin
  var CalcCount := 0;
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      Inc(CalcCount);
    end);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TIntegerField.Create(nil);
  Field.FieldName := 'Id';
  Field.FieldKind := fkData;

  Field.DataSet := DataSet;

  DataSet.IndexFieldNames := 'Id';

  for var A := 0 to 2 do
    MyArray[A].Id := A + 1;

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  // Calc on open and after sort
  Assert.AreEqual(2, CalcCount);

  CallbackClass.Free;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenOpenAClassWithDerivationMustLoadTheFieldFromTheBaseClassToo;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClassChild);

  Assert.AreEqual(7, DataSet.FieldCount);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenADataSetWithAnEmptyArrayCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
//      DataSet.OpenArray(nil);
    end);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Value').AsString;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenADataSetWithCalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Assert.WillNotRaise(
    procedure
    begin
//      DataSet.OpenClass(TParentClass);
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenADataSetWithDetailMustLoadTheRecordsOfTheDetail;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass[0].MyArray[0].Free;

  MyClass[0].MyArray[1].Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenADataSetWithoutFieldsMustAddTheSelfFieldToDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.IsNotNil(DataSet.FindField('Self'));

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenOpenAListOfObjectTheCurrentObjectMustBeTheFirstObjectInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  Assert.AreEqual(MyObject, FDataSet.GetCurrentObject<TMyTestClass>);
end;

procedure TPersistoDataSetTest.WhenOpenAnEmptyDataSetCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.GetCurrentObject<TMyTestClass>;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenAnEmptyDataSetTheCurrentObjectMustReturnNil;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.IsNil(DataSet.GetCurrentObject<TMyTestClass>);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenAnEmptyDataSetTheEOFPropertyMustBeTrue;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  Assert.IsTrue(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenOpenAnEmptyDataSetTheValueOfTheFieldMustReturnNull;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.AreEqual(NULL, DataSet.FieldByName('Name').Value);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenDataSetFromAListMustHaveToLoadFieldListWithPropertiesOfMappedObject;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TObjectList<TMyTestClass>.Create;

//  DataSet.OpenList<TMyTestClass>(MyObject);

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithAListAndTheListIsChangedTheResyncCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

//  DataSet.OpenList<TMyTestClass>(MyList);

  DataSet.Last;

  MyList.Delete(0);

  MyList.Delete(0);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.Resync([]);

      DataSet.GetCurrentObject<TObject>;
    end);

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithAListTheRecordCountMustBeTheSizeOfTheList;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

//  DataSet.OpenList<TMyTestClass>(MyList);

  Assert.AreEqual(4, DataSet.RecordCount);

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithAObjectTheRecordCountMustBeOne;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithOneObjectMustReturnFalseInTheEOFProperty;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.IsFalse(FDataSet.Eof);

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenOpenTheDetailDataSetMustLoadAllRecordsFromTheParentDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

//  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Close;

  DataSetDetail.Close;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenOrderingANullFieldValueInDescendingOrderItMustBeTheLastRecordInTheSortedDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TClassWithNullableProperty> := [TClassWithNullableProperty.Create, TClassWithNullableProperty.Create, TClassWithNullableProperty.Create,
    TClassWithNullableProperty.Create, TClassWithNullableProperty.Create];

  for var A := 0 to Pred(High(MyArray)) do
    MyArray[A].Nullable := Succ(A) * -1;

  DataSet.IndexFieldNames := '-Nullable';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.Last;

  Assert.IsTrue(DataSet.FieldByName('Nullable').IsNull);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenOrderingANullFieldValueItMustBeTheFirstRecordInTheSortedDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TClassWithNullableProperty> := [TClassWithNullableProperty.Create, TClassWithNullableProperty.Create, TClassWithNullableProperty.Create,
    TClassWithNullableProperty.Create, TClassWithNullableProperty.Create];

  for var A := 0 to Pred(High(MyArray)) do
    MyArray[A].Nullable := Succ(A) * -1;

  DataSet.IndexFieldNames := 'Nullable';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.First;

  Assert.IsTrue(DataSet.FieldByName('Nullable').IsNull);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenPostARecordMustAppendToListOfObjects;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Append;

  DataSet.Post;

  DataSet.Append;

  DataSet.Post;

  Assert.AreEqual(2, DataSet.RecordCount);

  DestroyObjects(DataSet);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenPostTheDetailDataSetMustUpdateTheArrayValueFromParentDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;

//  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Edit;

  DataSetDetail.Append;

  DataSetDetail.Post;

  DataSetDetail.Append;

  DataSetDetail.Post;

  Assert.AreEqual(2, Length(MyClass.MyArray));

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  DataSetDetail.Free;

  DataSet.Free;

  MyClass.Free;
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

procedure TPersistoDataSetTest.WhenPutTheDataSetInInsertStateMustClearTheCalculatedFields;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := 200;
    end);
  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyClass := TMyTestClass.Create;

  Field.DataSet := DataSet;

//  DataSet.OpenObject(MyClass);

  DataSet.Insert;

  Assert.IsTrue(DataSet.FieldByName('Calculated').IsNull);

  CallbackClass.Free;

  MyClass.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenPutTheMinusSymbolBeforeTheFieldNameInIndexMustSortDescending;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

  DataSet.IndexFieldNames := '-Id';

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(A, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenRemoveAComposeDetailFieldNameMustUpdateTheParentClassWithTheNewValues;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  var MyArray: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  var MyClass: TArray<TParentClass> := [TParentClass.Create, TParentClass.Create];
  MyClass[0].MyClass := TMyTestClassTypes.Create;
  MyClass[0].MyClass.MyArray := MyArray;

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSetDetail.Delete;

  Assert.AreEqual(1, DataSetDetail.RecordCount);

  MyArray[0].Free;

  MyArray[1].Free;

  MyClass[0].MyClass.Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenIsRemovedTheLastRecordFromDataSetCantRaiseAnError;
begin
  var DataLink := TDataLink.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSource := TDataSource.Create(nil);

  DataLink.BufferCount := 15;
  DataLink.DataSource := DataSource;
  DataSource.DataSet := DataSet;

  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 5 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  DataSet.Last;

  DataSet.Delete;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.GetCurrentObject<TObject>;
    end);

  DataLink.Free;

  DataSource.Free;

  DataSet.Free;

  MyList.Free;
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

procedure TPersistoDataSetTest.WhenRemoveARecordFromDetailMustUpdateTheArrayOfTheParentClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  var MyArray: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass.MyArray := MyArray;

//  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSetDetail.Delete;

  Assert.AreEqual(1, Length(MyClass.MyArray));

  MyArray[0].Free;

  MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenRemoveTheFilterMustReturnTheOriginalRecordsToTheDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := False;
    end);

  DataSet.Filter(nil);

  Assert.AreEqual(5, DataSet.RecordCount);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenScrollTheDataSetMustCalculateTheFields;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := DataSet.GetCurrentObject<TMyTestClass>.Id;
    end);
  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create];

  Field.DataSet := DataSet;

  for var A := 0 to 1 do
    MyArray[A].Id := A + 1;

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.Next;

  DataSet.Next;

  Assert.AreEqual(2, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  MyArray[0].Free;

  MyArray[1].Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenScrollTheParentDataSetMustLoadTheArrayInDetailDataSet;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[1].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

//  DataSet.OpenArray(TArray<TObject>(MyClass));

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Next;

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass[1].MyArray[0].Free;

  MyClass[1].MyArray[1].Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenSetAValueToAFieldThatIsAnObjectMustFillThePropertyInTheClassWithThisObject;
begin
  var AnotherObject := TAnotherObject.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

//  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  (DataSet.FieldByName('AnotherObject') as TPersistoObjectField).AsObject := AnotherObject;

  DataSet.Post;

  Assert.AreEqual(AnotherObject, MyClass.AnotherObject);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenSetTheFieldValueMustChangeTheValueFromTheClass(FieldName, FieldValue: String);
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var RttiType := Context.GetType(TMyTestClassTypes);
  var Value := NULL;

  var &Property := RttiType.GetProperty(FieldName);

//  DataSet.OpenClass(TMyTestClassTypes);

  DataSet.Append;

  var Field := DataSet.FieldByName(FieldName);

  Field.AsString := FieldValue;

  case Field.DataType of
    ftBoolean: Value := True;
    ftDate: Value := EncodeDate(2020, 12, 21);
    ftDateTime: Value := EncodeDate(2020, 12, 21) + EncodeTime(17, 17, 17, 0);
    ftTime: Value := EncodeTime(17, 17, 17, 0);
    ftString,
    ftWideString:
      if Field.Size = 1 then
        Value := 'C'
      else
        Value := 'Value String';
    ftByte,
    ftInteger,
    ftLargeint,
    ftLongWord,
    ftWord:
    begin
      if &Property.PropertyType is TRttiEnumerationType then
        Value := Enum2
      else
        Value := 123;
    end;
    ftCurrency,
    ftFloat,
    ftSingle: Value := 123.456;
  end;

  Assert.IsTrue(Value = &Property.GetValue(DataSet.GetCurrentObject<TMyTestClassTypes>).AsVariant);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenSortACalculatedFieldAsExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := DataSet.GetCurrentObject<TMyTestClass>.Id * -1;
    end);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  DataSet.IndexFieldNames := 'Calculated';

  for var A := 0 to 2 do
    MyArray[A].Id := A + 1;

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  Assert.AreEqual(-3, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenSortACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  Field.DataSet := DataSet;

  DataSet.IndexFieldNames := 'Calculated';

  Assert.WillNotRaise(
    procedure
    begin
//      DataSet.OpenArray(TArray<TObject>(MyArray));
    end);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenSortAFilteredDataSetCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A) * -1;

  DataSet.Filter(
    function (DataSet: TPersistoDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger in [1, 3, 5];
    end);

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.IndexFieldNames := 'Id';
    end);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenTheFieldAndPropertyTypeAreDifferentItHasToRaiseAnException;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('Name', ftInteger);

  Assert.WillRaise(
    procedure
    begin
//      DataSet.OpenObject(MyObject);
    end, EPropertyWithDifferentType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenTheFieldDefNameNotExistsInPropertyListMustRaiseAException;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('InvalidPropertyName', ftInteger);

  Assert.WillRaise(
    procedure
    begin
//      DataSet.OpenObject(MyObject);
    end, EPropertyNameDoesNotExist);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenTheFieldIsMappedToANullableFieldAndTheValueIsntFilledMustReturnNullInTheFieldValue;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(NULL, DataSet.FieldByName('Nullable').Value);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenTheNullablePropertyIsFilledMustReturnTheValueFilled;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;
  MyClass.Nullable := 12345678;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(12345678, DataSet.FieldByName('Nullable').AsInteger);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenThePropertyIsANullableTypeMustCreateTheField;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

//  DataSet.OpenObject(MyClass);

  Assert.IsTrue(DataSet.FindField('Nullable') <> nil);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenThePropertyIsANullableTypeMustCreateTheFieldWithTheInternalTypeOfTheNullable;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(ftInteger, DataSet.FieldByName('Nullable').DataType);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheField;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TLazyClass.Create;

//  DataSet.OpenObject(MyClass);

  Assert.IsTrue(DataSet.FindField('Lazy') <> nil);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheFieldWithTheGenericTypeOfTheLazyRecord;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyClass := TLazyClass.Create;

//  DataSet.OpenObject(MyClass);

  Assert.AreEqual(ftVariant, DataSet.FindField('Lazy').DataType);

  DataSet.Free;

  MyClass.Free;
end;

procedure TPersistoDataSetTest.WhenTryOpenADataSetWithoutAObjectDefinitionMustRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  Assert.WillRaise(
    procedure
    begin
      DataSet.Open;
    end, EDataSetWithoutObjectDefinition);

  DataSet.Free;
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

procedure TPersistoDataSetTest.WhenTryToFillAnObjectWithDifferentTypeMustRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Insert;

  Assert.WillRaise(
    procedure
    begin
      var MyObject := TAnotherObject.Create;

      try
        TPersistoObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;
      finally
        MyObject.Free;
      end;
    end, ESelfFieldDifferentObjectType);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTryToGetAComposeFieldNameFromALazyPropertyMustLoadAsExpected;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TLazyClass.Create;
  MyObject.Lazy.Value := TMyEntity.Create;
  MyObject.Lazy.Value.Name := 'Test';

  DataSet.FieldDefs.Add('Lazy.Name', ftString, 50);

//  DataSet.OpenObject(MyObject);

  Assert.AreEqual('Test', DataSet.FieldByName('Lazy.Name').AsString);

  DataSet.Free;

  MyObject.Lazy.Value.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenTryToGetAFieldValueFromAEmptyDataSetCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTryToGetTheValueOfACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

//  DataSet.OpenClass(TParentClass);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Calculated').AsInteger;
    end);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTryToOpenTheDataSetWithoutAnObjectInformationMustRaiseAnError;
begin
  Assert.WillRaise(FDataSet.Open, EDataSetWithoutObjectDefinition);
end;

procedure TPersistoDataSetTest.WhenUseQualifiedClassNameHasToLoadTheDataSetWithoutErrors;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.ObjectClassName := 'Persisto.DataSet.Test.TMyTestClass';

  Assert.WillNotRaise(DataSet.Open);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenUseTheOpenClassMustLoadFieldFromTheClass;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenTheRecordBufferIsBiggerThenOneMustLoadTheBufferOfTheDataSetAsExpected;
begin
  var DataLink := TDataLink.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSource := TDataSource.Create(nil);

  DataLink.BufferCount := 15;
  DataLink.DataSource := DataSource;
  DataSource.DataSet := DataSet;

  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

//  DataSet.OpenList<TMyTestClass>(MyList);

  for var A := 1 to 10 do
    DataSet.Next;

  Assert.AreEqual(10, DataSet.FieldByName('Id').AsInteger);
  Assert.AreEqual('Name10', DataSet.FieldByName('Name').AsString);
  Assert.AreEqual(20, DataSet.FieldByName('Value').AsFloat);

  DataLink.Free;

  DataSource.Free;

  DataSet.Free;

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenToCalculateAFieldMustReturnTheValueExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TPersistoDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := 12345;
    end);
  var DataSet := TPersistoDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TFloatField.Create(nil);
  Field.FieldName := 'Value';

  Field.DataSet := DataSet;

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Edit;

  DataSet.FieldByName('Value').AsInteger := 20;

  Assert.AreEqual(12345, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenChangeTheIndexFieldNamesWithDataSetOpenMustSortTheValues;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

//  DataSet.OpenArray(TArray<TObject>(MyArray));

  DataSet.IndexFieldNames := '-Id';

  DataSet.First;

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(A, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TPersistoDataSetTest.WhenChangeTheObjectTypeOfTheDataSetMustBeClosedToAcceptTheChange;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  DataSet.Open;

  Assert.WillRaise(
    procedure
    begin
      DataSet.ObjectClassName := 'TMyTestClass';
    end, Exception);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenChangeTheSelfFieldMustNotifyTheChangeOfAllFieldsInDataSet;
begin
//  var DataLink := TDataLinkMock.Create;
//  var DataSet := TPersistoDataSet.Create(nil);
//  var DataSource := TDataSource.Create(DataSet);
//  var MyObject := TMyTestClass.Create;
//
//  DataLink.DataSource := DataSource;
//  DataSource.DataSet := DataSet;
//
//  DataSet.OpenClass(TMyTestClass);
//
//  DataSet.Insert;
//
//  TPersistoObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;
//
//  Assert.AreEqual('RecordChanged', DataLink.FMethodCalled);
//
//  DataSet.Free;
//
//  DataLink.Free;
end;

procedure TPersistoDataSetTest.WhenCheckingIfTheFieldIsNullCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

//  DataSet.OpenObject(MyObject);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Id').IsNull;
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenCleanUpTheDataSetFieldPropertyTheParentDataSetMustBeCleanedToo;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClassTypes);

  DataSet.Open;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSetDetail.DataSetField := nil;

//  Assert.IsNil(DataSetDetail.ParentDataSet);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenCleanUpTheObjectClassNameMustStayEmpty;
begin
  var DataSet := TPersistoDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  DataSet.ObjectClassName := EmptyStr;

  Assert.AreEqual(EmptyStr, DataSet.ObjectClassName);

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenClearAFieldCantRaiseAnError;
begin
  var DataSet := TPersistoDataSet.Create(nil);

//  DataSet.OpenClass(TMyTestClass);

  DataSet.Append;

  Assert.WillNotRaise(DataSet.FieldByName('Id').Clear);

  DataSet.Cancel;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenCloseTheDataSetMustUmbingTheFieldsAndCloseTheDataSetDetail;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  Field.FieldName := 'MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

  var AnotherField := TLongWordField.Create(nil);
  AnotherField.FieldName := 'Cardinal';

  AnotherField.DataSet := DataSet;

//  DataSet.OpenClass(TMyTestClassTypes);

  DataSet.Close;

  Assert.AreEqual(0, AnotherField.FieldNo);

  Assert.IsFalse(DataSetDetail.Active);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenCreateADataSetFieldAndOpenTheParentDataSetMustOpenTheDetailToo;
begin
  var DataSet := TPersistoDataSet.Create(nil);
  var DataSetDetail := TPersistoDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  Field.FieldName := 'MyArray';
  Field.DataSet := DataSet;
  var MyClass := TMyTestClassTypes.Create;

  DataSetDetail.DataSetField := Field;

//  DataSet.OpenObject(MyClass);

  Assert.IsTrue(DataSetDetail.Active);

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TPersistoDataSetTest.WhenDeleteARecordFromADataSetMustRemoveTheValueFromTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TPersistoDataSet.Create(nil);
  var List: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

//  DataSet.OpenArray(TArray<TObject>(List));

  DataSet.Delete;

  Assert.AreEqual(4, DataSet.RecordCount);

  for var Item in List do
    Item.Free;

  DataSet.Free;
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

