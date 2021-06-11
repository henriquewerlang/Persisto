unit Delphi.ORM.DataSet.Test;

interface

uses System.SysUtils, Data.DB, System.Generics.Collections, Delphi.ORM.DataSet, DUnitX.TestFramework;

type
  [TestFixture]
  TORMDataSetTest = class
  private
    procedure DestroyObjects(DataSet: TORMDataSet);
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
    [Test]
    procedure TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
    [Test]
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
    [Test]
    procedure WhenOpenTheDataSetWithAObjectTheRecordCountMustBeOne;
    [Test]
    procedure WhenOpenTheDataSetWithAListTheRecordCountMustBeTheSizeOfTheList;
    [Test]
    procedure AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
    [Test]
    procedure WhenNavigateByDataSetMustHaveToShowTheValuesFromTheList;
    [Test]
    procedure WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
    [Test]
    procedure WhenHaveFieldDefDefinedCantLoadFieldsFromTheClass;
    [Test]
    procedure WhenTheFieldDefNameNotExistsInPropertyListMustRaiseAException;
    [Test]
    procedure WhenTheFieldAndPropertyTypeAreDifferentItHasToRaiseAnException;
    [Test]
    procedure WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
    [Test]
    procedure WhenTryOpenADataSetWithoutAObjectDefinitionMustRaiseAnError;
    [Test]
    procedure WhenFilledTheObjectClassNameHasToLoadTheDataSetWithoutErrors;
    [Test]
    procedure WhenUseQualifiedClassNameHasToLoadTheDataSetWithoutErrors;
    [Test]
    procedure WhenCheckingIfTheFieldIsNullCantRaiseAnError;
    [Test]
    procedure WhenCallFirstHaveToGoToTheFirstRecord;
    [Test]
    procedure UsingBookmarkHaveToWorkLikeSpected;
    [Test]
    procedure WhenUseTheOpenClassMustLoadFieldFromTheClass;
    [Test]
    procedure WhenExistsAFieldInDataSetMustFillTheFieldDefFromThisField;
    [Test]
    procedure WhenInsertIntoDataSetCantRaiseAnError;
    [Test]
    procedure WhenPostARecordMustAppendToListOfObjects;
    [TestCase('Boolean', 'Boolean,True')]
    [TestCase('Byte', 'Byte,123')]
    [TestCase('Cardinal', 'Cardinal,123')]
    [TestCase('Char', 'Char,C')]
    [TestCase('Currency', 'Currency;123,456', ';')]
    [TestCase('Date', 'Date,21/12/2020')]
    [TestCase('DateTime', 'DateTime,21/12/2020 17:17:17')]
    [TestCase('Double', 'Double;123,456', ';')]
    [TestCase('Enumerator', 'MyEnum,1')]
    [TestCase('Int64', 'Int64,123')]
    [TestCase('Integer', 'Int,123')]
    [TestCase('Sigle', 'Single;123,456', ';')]
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
    [Test]
    procedure WhenOpenAnEmptyDataSetCantRaiseAnError;
    [Test]
    procedure WhenOpenAnEmptyDataSetTheCurrentObjectMustReturnNil;
    [Test]
    procedure WhenTryToGetAFieldValueFromAEmptyDataSetCantRaiseAnError;
    [Test]
    procedure WhenOpenAnEmptyDataSetTheValueOfTheFieldMustReturnNull;
    [Test]
    procedure WhenASubPropertyIsAnObjectAndTheValueIsNilCantRaiseAnError;
    [Test]
    procedure WhenFillingAFieldWithSubPropertyMustFillTheLastLevelOfTheField;
    [Test]
    procedure WhenOpenAClassWithDerivationMustLoadTheFieldFromTheBaseClassToo;
    [Test]
    procedure WhenTheDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldFromASubPropertyThatIsAnObject;
    [Test]
    procedure EveryInsertedObjectMustGoToTheObjectList;
    [Test]
    procedure AfterInsertAnObjectMustResetTheObjectToSaveTheNewInfo;
    [Test]
    procedure WhenEditingTheDataSetAndSetAFieldValueMustChangeThePropertyOfTheObjectToo;
    [Test]
    procedure TheOldValuePropertyFromFieldMustReturnTheOriginalValueOfTheObjectBeingEdited;
    [Test]
    procedure WhenAStringFieldIsEmptyCantRaiseAnErrorBecauseOfIt;
    [Test]
    procedure WhenTheEditionIsCanceledMustReturnTheOriginalValueFromTheField;
    [Test]
    procedure WhenEditingCantIncreseTheRecordCountWhenPostTheRecord;
    [Test]
    procedure WhenSetAValueToAFieldThatIsAnObjectMustFillThePropertyInTheClassWithThisObject;
    [Test]
    procedure WhenGetAValueFromAFieldAndIsAnObjectMustReturnTheObjectFromTheClass;
    [Test]
    procedure OpenArrayObjectMustLoadTheObjectTypeFromTheParam;
    [Test]
    procedure OpenArrayObjectMustActiveTheDataSet;
    [Test]
    procedure OpenArrayMustLoadTheObjectListWithTheParamPassed;
    [Test]
    procedure TheRecNoPropertyMustReturnTheCurrentRecordPositionInTheDataSet;
    [Test]
    procedure WhenADataSetIsActiveCantOpenItAgainMustRaiseAnError;
    [Test]
    procedure WhenCleanUpTheObjectClassNameMustStayEmpty;
    [Test]
    procedure WhenChangeTheObjectTypeOfTheDataSetMustBeClosedToAcceptTheChange;
    [Test]
    procedure WhenFillTheDataSetFieldPropertyMustLoadTheParentDataSetPropertyWithTheDataSetCorrect;
    [Test]
    procedure WhenCleanUpTheDataSetFieldPropertyTheParentDataSetMustBeCleanedToo;
    [Test]
    procedure WhenFillTheDataSetFieldMustLoadTheObjectTypeFromThePropertyOfTheField;
    [Test]
    procedure WhenOpenTheDetailDataSetMustLoadAllRecordsFromTheParentDataSet;
    [Test]
    procedure WhenScrollTheParentDataSetMustLoadTheArrayInDetailDataSet;
    [Test]
    procedure WhenPostTheDetailDataSetMustUpdateTheArrayValueFromParentDataSet;
    [Test]
    procedure WhenTheRecordBufferIsBiggerThenOneMustLoadTheBufferOfTheDataSetAsExpected;
    [Test]
    procedure WhenOpenADataSetWithDetailMustLoadTheRecordsOfTheDetail;
    [Test]
    procedure WhenTheDetailDataSetHasAComposeNameMustLoadTheObjectTypeCorrectly;
    [Test]
    procedure WhenTheDetailDataSetHasAComposeNameMustLoadTheDataCorrecty;
    [Test]
    procedure WhenInsertARecordThenCancelTheInsertionAndStartANewInsertTheOldBufferMustBeCleanedUp;
    [Test]
    procedure WhenThePropertyIsANullableTypeMustCreateTheField;
    [Test]
    procedure WhenThePropertyIsANullableTypeMustCreateTheFieldWithTheInternalTypeOfTheNullable;
    [Test]
    procedure WhenTheFieldIsMappedToANullableFieldAndTheValueIsntFilledMustReturnNullInTheFieldValue;
    [Test]
    procedure WhenTheNullablePropertyIsFilledMustReturnTheValueFilled;
    [Test]
    procedure WhenClearAFieldCantRaiseAnError;
    [Test]
    procedure WhenFillANullableFieldWithTheNullValueMustMarkThePropertyWithIsNullTrue;
    [Test]
    procedure WhenFillANullableFieldWithAnValueMustFillThePropertyWithTheValue;
    [Test]
    procedure GetADateTimeFieldMustReturnTheValueAsExpected;
    [Test]
    procedure WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheField;
    [Test]
    procedure WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheFieldWithTheGenericTypeOfTheLazyRecord;
    [Test]
    procedure WhenGetTheValueOfALazyPropertyMustReturnTheValueInsideTheLazyRecord;
    [Test]
    procedure WhenFillAFieldOfALazyPropertyMustFieldTheLazyStructure;
    [Test]
    procedure WhenTryToGetAComposeFieldNameFromALazyPropertyMustLoadAsExpected;
    [Test]
    procedure WhenOpenADataSetWithCalculatedFieldCantRaiseAnyError;
    [Test]
    procedure WhenTryToGetTheValueOfACalculatedFieldCantRaiseAnyError;
    [Test]
    procedure WhenADataSetNotInEditingStateMustRaiseAnErrorIfTryToFillAFieldValue;
    [Test]
    procedure WhenFillTheValueOfACalculatedFieldCantRaiseAnyError;
    [Test]
    procedure WhenToCalculateAFieldMustReturnTheValueExpected;
    [Test]
    procedure WhenExitsMoreThenOneCalculatedFieldMustReturnTheValueAsExpected;
    [Test]
    procedure WhenOpenADataSetWithAnEmptyArrayCantRaiseAnyError;
    [Test]
    procedure WhenCloseTheDataSetMustUmbingTheFieldsAndCloseTheDataSetDetail;
    [Test]
    procedure WhenMoveTheMasterDataSetTheCountOfTheDetailRecordMustRepresentTheExatValueFromArrayOfMasterClass;
    [Test]
    procedure WhenTheDetailDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldValue;
    [Test]
    procedure WhenMoveTheMasterDataSetTheDetailDataSetMustBeInTheFirstRecord;
    [Test]
    procedure WhenDeleteARecordFromADataSetMustRemoveTheValueFromTheDataSet;
    [Test]
    procedure WhenRemoveARecordFromDetailMustUpdateTheArrayOfTheParentClass;
    [Test]
    procedure WhenScrollTheDataSetMustCalculateTheFields;
    [Test]
    procedure WhenPutTheDataSetInInsertStateMustClearTheCalculatedFields;
    [Test]
    procedure WhenIsRemovedTheLastRecordFromDataSetCantRaiseAnError;
    [Test]
    procedure WhenRemoveAComposeDetailFieldNameMustUpdateTheParentClassWithTheNewValues;
    [Test]
    procedure WhenOpenTheDataSetWithAListAndTheListIsChangedTheResyncCantRaiseAnyError;
    [Test]
    procedure TheCalcBufferMustBeClearedOnScrollingTheDataSet;
    [Test]
    procedure WhenOpenADataSetWithoutFieldsMustAddTheSelfFieldToDataSet;
    [Test]
    procedure WhenAddTheSelfFieldCantRaiseAnyError;
    [Test]
    procedure TheSelfFieldTypeMustBeVariant;
    [Test]
    procedure WhenAddTheSelfFieldMustBeOfTheVariantType;
    [Test]
    procedure WhenGetTheValueOfTheSelfFieldMustReturnTheCurrentObjectOfThDataSet;
    [Test]
    procedure WhenFillTheCurrentObjectMustReplaceTheCurrentValueInTheInternalList;
    [Test]
    procedure WhenInsertingMustTheSelfFieldMustReplaceTheCurrentObjectHasExpected;
    [Test]
    procedure WhenFillANilValueToSelfFieldMustRaiseAnError;
    [Test]
    procedure WhenTryToFillAnObjectWithDifferentTypeMustRaiseAnError;
    [Test]
    procedure WhenChangeTheSelfFieldMustNotifyTheChangeOfAllFieldsInDataSet;
    [Test]
    procedure WhenFillTheIndexFieldNamesMustOrderTheValuesInAscendingOrderAsExpected;
    [Test]
    procedure WhenFillTheIndexFieldNamesWithMoreTheOnFieldMustOrderAsExpected;
    [Test]
    procedure WhenPutTheMinusSymbolBeforeTheFieldNameInIndexMustSortDescending;
    [Test]
    procedure WhenChangeTheIndexFieldNamesWithDataSetOpenMustSortTheValues;
    [Test]
    procedure AfterChangeAnRecordMustSortTheDataSetAgain;
    [Test]
    procedure WhenSortACalculatedFieldCantRaiseAnyError;
    [Test]
    procedure WhenSortACalculatedFieldAsExpected;
    [Test]
    procedure WhenFillTheIndexFieldNamesMustRemainInTheCurrentPositionAfterTheSortCompletes;
    [Test]
    procedure WhenNotUsingACalculatedFieldInTheIndexCantCallTheOnCalcFields;
    [Test]
    procedure WhenCallTheResyncMustReorderTheDataSet;
    [Test]
    procedure WhenFilterTheDataSetMustStayOnlyTheFilteredRecords;
    [Test]
    procedure WhenApplyAFilterBeforeOpenTheDataSetMustFilterTheRecordAfterOpen;
    [Test]
    procedure WhenRemoveTheFilterMustReturnTheOriginalRecordsToTheDataSet;
    [Test]
    procedure WhenInsertingARecordInAFilteredDataSetMustCheckTheFilterToAddTheRecordToTheDataSet;
    [Test]
    procedure WhenEditingARecordAndTheFilterBecameInvalidMustRemoveTheRecordFromDataSet;
  end;

  [TestFixture]
  TORMListIteratorTest = class
  private
    function CreateCursor<T: class>(const Value: TArray<T>): IORMObjectIterator; overload;
    function CreateCursor<T: class>(const Value: array of T): IORMObjectIterator; overload;
    function CreateCursorList<T: class>(const Value: TList<T>): IORMObjectIterator; overload;
  public
    [Test]
    procedure WhenTheArrayIsEmptyTheNextProcedureMustReturnFalse;
    [Test]
    procedure WhenTheArrayIsEmptyThePriorProcedureMustReturnFalse;
    [Test]
    procedure WhenTheArrayIsNotEmptyTheNextProcedureMustReturnTrue;
    [Test]
    procedure WhenTheIterationInCursorReachTheEndOfTheArrayTheNextFunctionMustReturnFalse;
    [Test]
    procedure AccessingTheObjectListMustReturnTheObjectInThePositionPassedInTheParam;
    [Test]
    procedure TheCurrentPositionOfRecordMustBeSaved;
    [Test]
    procedure TheRecordCountFunctionMustReturnTheTotalOfItensInTheList;
    [Test]
    procedure WhenAddAnObjectToCursorThisMustBeAddedToTheList;
    [Test]
    procedure WhenCallResetBeginMustPutTheIteratorInTheFirstPosition;
    [Test]
    procedure WhenClassResetEndMustPutTheIteratorInLastPosition;
    [Test]
    procedure WhenAddAnObjectTheCurrentPositionMustBeTheInsertedObjectPosition;
    [Test]
    procedure WhenCallClearProcedureMustCleanUpTheItensInTheInternalList;
    [Test]
    procedure WhenCallClearProcedureMustResetTheCurrentPositionOfTheIterator;
    [Test]
    procedure TheUpdateArrayMustFillTheValuesInThePropertyPassedInTheParam;
    [Test]
    procedure WhenCallRemoveMustRemoveTheCurrentValueFromTheList;
    [Test]
    procedure WhenRemoveTheLastPositionInTheListMustUpdateTheCurrentPositionOfTheIterator;
    [Test]
    procedure WhenAValueIsRemovedFromTheListTheResyncMustPutTheCurrentPositionInAValidPosition;
    [Test]
    procedure WhenSetObjectToTheIteratorMustReplaceTheObjectInTheIndex;
    [Test]
    procedure TheSwapProcedureMustChangeTheItemsByThePositionPassed;
  end;

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
    FCallbackProc: TProc<TORMDataSet>;
  public
    constructor Create(CallbackProc: TProc<TORMDataSet>);

    procedure OnCalcFields(DataSet: TDataSet);
  end;

  TDataLinkMock = class(TDataLink)
  private
    FMethodCalled: String;
  protected
    procedure RecordChanged(Field: TField); override;
  public
    property MethodCalled: String read FMethodCalled write FMethodCalled;
  end;

implementation

uses System.Rtti, System.Classes, System.Variants, Data.DBConsts, Delphi.ORM.Test.Entity;

{ TORMDataSetTest }

procedure TORMDataSetTest.AfterChangeAnRecordMustSortTheDataSetAgain;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];
  var MyNewClass := TMyTestClass.Create;
  MyNewClass.Id := -1;

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

  DataSet.IndexFieldNames := 'Id';

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.Insert;

  (DataSet.FieldByName('Self') as TORMObjectField).AsObject := MyNewClass;

  DataSet.Post;

  DataSet.First;

  Assert.AreEqual(-1, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  MyNewClass.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.AfterInsertAnObjectMustResetTheObjectToSaveTheNewInfo;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

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

procedure TORMDataSetTest.AfterOpenTheFieldMustLoadTheValuesFromTheObjectClass;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.Id := 123456;
  MyObject.Name := 'MyName';
  MyObject.Value := 5477.555;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(123456, DataSet.FieldByName('Id').AsInteger);
  Assert.AreEqual('MyName', DataSet.FieldByName('Name').AsString);
  Assert.AreEqual<Double>(5477.555, DataSet.FieldByName('Value').AsFloat);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.DestroyObjects(DataSet: TORMDataSet);
begin
  DataSet.First;

  while not DataSet.Eof do
  begin
    DataSet.GetCurrentObject<TObject>.Free;

    DataSet.Next;
  end;
end;

procedure TORMDataSetTest.EveryInsertedObjectMustGoToTheObjectList;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  DataSet.Post;

  Assert.IsNotNull(DataSet.GetCurrentObject<TObject>);

  DestroyObjects(DataSet);

  DataSet.Free;
end;

procedure TORMDataSetTest.GetADateTimeFieldMustReturnTheValueAsExpected;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClassTypes.Create;
  MyObject.DateTime := EncodeDate(2020, 02, 18) + EncodeTime(12, 34, 56, 0);

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(MyObject.DateTime, DataSet.FieldByName('DateTime').AsDateTime);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.OpenArrayMustLoadTheObjectListWithTheParamPassed;
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  DataSet.OpenObjectArray(TMyTestClass, [MyClass]);

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.OpenArrayObjectMustActiveTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenObjectArray(TMyTestClass, nil);

  Assert.IsTrue(DataSet.Active);

  DataSet.Free;
end;

procedure TORMDataSetTest.OpenArrayObjectMustLoadTheObjectTypeFromTheParam;
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenObjectArray(TMyTestClass, nil);

  Assert.AreEqual(Context.GetType(TMyTestClass) as TRttiInstanceType, DataSet.ObjectType);

  DataSet.Free;
end;

procedure TORMDataSetTest.Setup;
begin
  if DebugHook = 0 then
  begin
    var DataSet := TORMDataSet.Create(nil);

    DataSet.OpenClass<TMyTestClassTypes>;

    DataSet.Free;

    for var &Type in TRttiContext.Create.GetTypes do
      &Type.QualifiedName;

    try
      DatabaseError(SDataSetOpen, nil);
    except
    end;
  end;
end;

procedure TORMDataSetTest.TheCalcBufferMustBeClearedOnScrollingTheDataSet;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
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
  var DataSet := TORMDataSet.Create(nil);
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

  DataSet.OpenArray<TMyTestClass>(List);

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

procedure TORMDataSetTest.TheFieldTypeMustMatchWithPropertyType(FieldName: String; TypeToCompare: TFieldType);
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClassTypes.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(TypeToCompare, DataSet.FieldByName(FieldName).DataType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.TheNameOfFieldMustBeEqualToTheNameOfTheProperty;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual('Id', DataSet.Fields[0].FieldName);
  Assert.AreEqual('Name', DataSet.Fields[1].FieldName);
  Assert.AreEqual('Value', DataSet.Fields[2].FieldName);
  Assert.AreEqual('AnotherObject', DataSet.Fields[3].FieldName);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.TheOldValuePropertyFromFieldMustReturnTheOriginalValueOfTheObjectBeingEdited;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  MyClass.Name := 'My Name';

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'Another Name';

  Assert.AreEqual<String>('My Name', DataSet.FieldByName('Name').OldValue);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.TheRecNoPropertyMustReturnTheCurrentRecordPositionInTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);
  var List: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  DataSet.OpenArray<TMyTestClass>(List);

  DataSet.Next;

  DataSet.Next;

  Assert.AreEqual(3, DataSet.RecNo);

  for var Item in List do
    Item.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.TheSelfFieldTypeMustBeVariant;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(ftVariant, DataSet.FieldByName('Self').DataType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.UsingBookmarkHaveToWorkLikeSpected;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  DataSet.OpenList<TMyTestClass>(MyList);

  for var A := 1 to 4 do
    DataSet.Next;

  var Bookmark := DataSet.Bookmark;

  DataSet.First;

  DataSet.Bookmark := Bookmark;

  Assert.AreEqual('Name5', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenADataSetIsActiveCantOpenItAgainMustRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassTypes>;

  Assert.WillRaise(DataSet.OpenClass<TMyTestClassTypes>);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenADataSetNotInEditingStateMustRaiseAnErrorIfTryToFillAFieldValue;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  DataSet.OpenObject(MyClass);

  Assert.WillRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString := 'Another Name';
    end, EDataSetNotInEditingState);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenAddTheSelfFieldCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.OpenObject(MyObject);
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenAddTheSelfFieldMustBeOfTheVariantType;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field := TStringField.Create(DataSet);
  Field.FieldName := 'Self';

  Field.DataSet := DataSet;

  Assert.WillRaise(
    procedure
    begin
      DataSet.OpenClass<TMyTestClass>;
    end, ESelfFieldTypeWrong);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenAFieldIsACreateTheFieldMustHaveTheMinimalSizeDefined(FieldName: String; Size: Integer);
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassTypes>;

  Assert.AreEqual(Size, DataSet.FieldByName(FieldName).Size);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenAFieldIsSeparatedByAPointItHasToLoadTheSubPropertiesOfTheObject;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject.AnotherName := 'MyName';

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

  DataSet.OpenObject(MyObject);

  Assert.AreEqual('MyName', DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenApplyAFilterBeforeOpenTheDataSetMustFilterTheRecordAfterOpen;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.Filter(
    function (DataSet: TORMDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

  DataSet.OpenArray<TMyTestClass>(MyArray);

  Assert.AreEqual(1, DataSet.RecordCount);

  Assert.AreEqual(5, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenTheDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldFromASubPropertyThatIsAnObject;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.FieldDefs.Add('AnotherObject.AnotherName', ftString, 50);

  DataSet.OpenClass<TMyTestClass>;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('AnotherObject.AnotherName').AsString
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTheDetailDataSetHasAComposeNameMustLoadTheDataCorrecty;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  var MyClass: TArray<TParentClass> := [TParentClass.Create, TParentClass.Create];
  MyClass[0].MyClass := TMyTestClassTypes.Create;
  MyClass[0].MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

  DataSet.OpenArray<TParentClass>(MyClass);

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass[0].MyClass.MyArray[0].Free;

  MyClass[0].MyClass.MyArray[1].Free;

  MyClass[0].MyClass.Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTheDetailDataSetHasAComposeNameMustLoadTheObjectTypeCorrectly;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

  DataSet.OpenClass<TParentClass>;

  Assert.AreEqual('TMyTestClassTypes', DataSetDetail.ObjectType.Name);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTheDetailDataSetIsEmptyCantRaiseAnErrorWhenGetAFieldValue;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  DataSet.OpenArray<TMyTestClassTypes>(MyClass);

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

procedure TORMDataSetTest.WhenTheEditionIsCanceledMustReturnTheOriginalValueFromTheField;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Name := 'My Name';

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'New Name';

  DataSet.Cancel;

  Assert.AreEqual('My Name', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenAStringFieldIsEmptyCantRaiseAnErrorBecauseOfIt;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  DataSet.OpenObject(MyClass);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString;
    end);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenASubPropertyIsAnObjectAndTheValueIsNilCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

  DataSet.OpenObject(MyObject);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenCallFirstHaveToGoToTheFirstRecord;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  DataSet.OpenList<TMyTestClass>(MyList);

  while not DataSet.Eof do
    DataSet.Next;

  DataSet.First;

  Assert.AreEqual('Name1', DataSet.FieldByName('Name').AsString);

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenCallTheResyncMustReorderTheDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.IndexFieldNames := 'Id';

  DataSet.OpenArray<TMyTestClass>(MyArray);

  MyArray[0].Id := 10;

  DataSet.Resync([]);

  Assert.AreEqual(2, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;end;

procedure TORMDataSetTest.WhenEditingARecordAndTheFilterBecameInvalidMustRemoveTheRecordFromDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Id := 5;

  DataSet.Filter(
    function (DataSet: TORMDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Id').AsInteger := 4;

  DataSet.Post;

  Assert.AreEqual(0, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenEditingCantIncreseTheRecordCountWhenPostTheRecord;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.Name := 'My Name';

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.Post;

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenEditingTheDataSetAndSetAFieldValueMustChangeThePropertyOfTheObjectToo;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  MyClass.Name := 'My Name';

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Name').AsString := 'Name1';

  Assert.AreEqual('Name1', MyClass.Name);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenExistsAFieldInDataSetMustFillTheFieldDefFromThisField;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field := TStringField.Create(DataSet);
  Field.FieldName := 'Name';

  Field.DataSet := DataSet;

  DataSet.OpenClass<TMyTestClass>;

  Assert.AreEqual(1, DataSet.FieldDefs.Count);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenExitsMoreThenOneCalculatedFieldMustReturnTheValueAsExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      DataSet.FieldByName('Calculated1').AsInteger := 1;
      DataSet.FieldByName('Calculated2').AsInteger := 2;
      DataSet.FieldByName('Calculated3').AsInteger := 3;
    end);
  var DataSet := TORMDataSet.Create(nil);
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

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Edit;

  DataSet.FieldByName('Value').AsInteger := 20;

  Assert.AreEqual(1, DataSet.FieldByName('Calculated1').AsInteger);
  Assert.AreEqual(2, DataSet.FieldByName('Calculated2').AsInteger);
  Assert.AreEqual(3, DataSet.FieldByName('Calculated3').AsInteger);

  CallbackClass.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFillAFieldOfALazyPropertyMustFieldTheLazyStructure;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TLazyClass.Create;
  var TheValue := TMyEntity.Create;

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  TORMObjectField(DataSet.FindField('Lazy')).AsObject := TheValue;

  Assert.AreEqual<TObject>(TheValue, MyClass.Lazy.Value);

  DataSet.Free;

  MyClass.Free;

  TheValue.Free;
end;

procedure TORMDataSetTest.WhenFillANilValueToSelfFieldMustRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  Assert.WillRaise(
    procedure
    begin
      TORMObjectField(DataSet.FieldByName('Self')).AsObject := nil;
    end, ESelfFieldNotAllowEmptyValue);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFillANullableFieldWithAnValueMustFillThePropertyWithTheValue;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Nullable').AsInteger := 12345678;

  DataSet.Post;

  Assert.AreEqual(12345678, MyClass.Nullable.Value);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenFillANullableFieldWithTheNullValueMustMarkThePropertyWithIsNullTrue;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;
  MyClass.Nullable := 12345678;

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  DataSet.FieldByName('Nullable').Clear;

  DataSet.Post;

  Assert.IsTrue(MyClass.Nullable.IsNull);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenFilledTheObjectClassNameHasToLoadTheDataSetWithoutErrors;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  Assert.WillNotRaise(DataSet.Open);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFillingAFieldWithSubPropertyMustFillTheLastLevelOfTheField;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;

  DataSet.FieldDefs.Add('AnotherObject.AnotherObject.AnotherName', ftString, 50);

  DataSet.OpenObject(MyObject);

  DataSet.Edit;

  DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString := 'A Name';

  Assert.AreEqual('A Name', DataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString);

  DataSet.Free;

  MyObject.AnotherObject := nil;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenFillTheCurrentObjectMustReplaceTheCurrentValueInTheInternalList;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;
  var MyNewObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  DataSet.Edit;

  TORMObjectField(DataSet.FieldByName('Self')).AsObject := MyNewObject;

  DataSet.Post;

  Assert.AreEqual<TObject>(DataSet.GetCurrentObject<TObject>, MyNewObject);

  DataSet.Free;

  MyObject.Free;

  MyNewObject.Free;
end;

procedure TORMDataSetTest.WhenFillTheDataSetFieldMustLoadTheObjectTypeFromThePropertyOfTheField;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassTypes>;

  DataSet.Open;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  Assert.IsNotNull(DataSetDetail.ObjectType);

  Assert.AreEqual('TMyTestClassTypes', DataSetDetail.ObjectType.Name);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFillTheDataSetFieldPropertyMustLoadTheParentDataSetPropertyWithTheDataSetCorrect;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassTypes>;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  Assert.AreEqual(DataSet, DataSetDetail.ParentDataSet);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFillTheIndexFieldNamesMustOrderTheValuesInAscendingOrderAsExpected;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A) * -1;

  DataSet.IndexFieldNames := 'Id';

  DataSet.OpenArray<TMyTestClass>(MyArray);

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(Succ(A) * -1, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenFillTheIndexFieldNamesMustRemainInTheCurrentPositionAfterTheSortCompletes;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A + 1;

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.Last;

  DataSet.IndexFieldNames := '-Id';

  Assert.AreEqual(1, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenFillTheIndexFieldNamesWithMoreTheOnFieldMustOrderAsExpected;
const
  SORTED_VALUE: array[0..4] of String = ('Name0', 'Name3', 'Name1', 'Name4', 'Name2');

begin
  var DataSet := TORMDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := Low(MyArray) to High(MyArray) do
  begin
    MyArray[A].Id := A mod 3;

    MyArray[A].Name := 'Name' + A.ToString;
  end;

  DataSet.IndexFieldNames := 'Id;Name';

  DataSet.OpenArray<TMyTestClass>(MyArray);

  for var A := 0 to High(MyArray) do
  begin
    Assert.AreEqual(SORTED_VALUE[A], DataSet.FieldByName('Name').AsString);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenFillTheValueOfACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  DataSet.OpenClass<TParentClass>;

  DataSet.Edit;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Calculated').AsInteger := 20;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenFilterTheDataSetMustStayOnlyTheFilteredRecords;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.Filter(
    function (DataSet: TORMDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

  Assert.AreEqual(1, DataSet.RecordCount);

  Assert.AreEqual(5, DataSet.FieldByName('Id').AsInteger);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenGetAValueFromAFieldAndIsAnObjectMustReturnTheObjectFromTheClass;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;
  MyClass.AnotherObject := TAnotherObject.Create;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual<TObject>(MyClass.AnotherObject, (DataSet.FieldByName('AnotherObject') as TORMObjectField).AsObject);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenGetTheValueOfALazyPropertyMustReturnTheValueInsideTheLazyRecord;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TLazyClass.Create;
  var TheValue := TMyEntity.Create;

  MyClass.Lazy := TheValue;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual<TObject>(TheValue, TORMObjectField(DataSet.FindField('Lazy')).AsObject);

  DataSet.Free;

  MyClass.Free;

  TheValue.Free;
end;

procedure TORMDataSetTest.WhenGetTheValueOfTheSelfFieldMustReturnTheCurrentObjectOfThDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(DataSet.GetCurrentObject<TObject>, TORMObjectField(DataSet.FieldByName('Self')).AsObject);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenHaveFieldDefDefinedCantLoadFieldsFromTheClass;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('Id', ftInteger);
  DataSet.FieldDefs.Add('Name', ftString, 20);
  DataSet.FieldDefs.Add('Value', ftFloat);

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(3, DataSet.FieldDefs.Count);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenInsertARecordThenCancelTheInsertionAndStartANewInsertTheOldBufferMustBeCleanedUp;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  DataSet.FieldByName('Name').AsString := 'Name1';

  DataSet.Cancel;

  DataSet.Append;

  Assert.AreEqual(EmptyStr, DataSet.FieldByName('Name').AsString);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenInsertingARecordInAFilteredDataSetMustCheckTheFilterToAddTheRecordToTheDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.Filter(
    function (DataSet: TORMDataSet): Boolean
    begin
      Result := DataSet.FieldByName('Id').AsInteger = 5;
    end);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  DataSet.FieldByName('Id').AsInteger := 5;

  DataSet.Post;

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.GetCurrentObject<TMyTestClass>.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenInsertingMustTheSelfFieldMustReplaceTheCurrentObjectHasExpected;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  TORMObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;

  Assert.AreEqual<TObject>(DataSet.GetCurrentObject<TObject>, MyObject);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenInsertIntoDataSetCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.WillNotRaise(DataSet.Append);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenMoveTheMasterDataSetTheCountOfTheDetailRecordMustRepresentTheExatValueFromArrayOfMasterClass;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  DataSet.OpenArray<TMyTestClassTypes>(MyClass);

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

procedure TORMDataSetTest.WhenMoveTheMasterDataSetTheDetailDataSetMustBeInTheFirstRecord;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass.MyArray[0].Cardinal := 10;
  MyClass.MyArray[1].Cardinal := 20;

  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Close;

  DataSetDetail.Close;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual(10, DataSetDetail.FieldByName('Cardinal').AsInteger);

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenNavigateByDataSetMustHaveToShowTheValuesFromTheList;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  DataSet.OpenList<TMyTestClass>(MyList);

  for var B := 1 to 10 do
  begin
    Assert.AreEqual<Integer>(B, DataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), DataSet.FieldByName('Name').AsString);
    Assert.AreEqual<Double>(B + B, DataSet.FieldByName('Value').AsFloat);

    DataSet.Next;
  end;

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenNavigatingBackHaveToLoadTheListValuesAsExpected;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  for var A := 1 to 10 do
  begin
    var MyObject := TMyTestClass.Create;
    MyObject.Id := A;
    MyObject.Name := Format('Name%d', [A]);
    MyObject.Value := A + A;

    MyList.Add(MyObject);
  end;

  DataSet.OpenList<TMyTestClass>(MyList);

  DataSet.Last;

  for var B := 10 downto 1 do
  begin
    Assert.AreEqual<Integer>(B, DataSet.FieldByName('Id').AsInteger);
    Assert.AreEqual(Format('Name%d', [B]), DataSet.FieldByName('Name').AsString);
    Assert.AreEqual<Double>(B + B, DataSet.FieldByName('Value').AsFloat);

    DataSet.Prior;
  end;

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenNotUsingACalculatedFieldInTheIndexCantCallTheOnCalcFields;
begin
  var CalcCount := 0;
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      Inc(CalcCount);
    end);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  var DataSet := TORMDataSet.Create(nil);
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

  DataSet.OpenArray<TMyTestClass>(MyArray);

  // Calc on open and after sort
  Assert.AreEqual(2, CalcCount);

  CallbackClass.Free;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenOpenAClassWithDerivationMustLoadTheFieldFromTheBaseClassToo;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassChild>;

  Assert.AreEqual(7, DataSet.FieldCount);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenADataSetWithAnEmptyArrayCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.OpenArray<TMyTestClass>(nil);
    end);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Value').AsString;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenADataSetWithCalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.OpenClass<TParentClass>;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenADataSetWithDetailMustLoadTheRecordsOfTheDetail;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[0].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  DataSet.OpenArray<TMyTestClassTypes>(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass[0].MyArray[0].Free;

  MyClass[0].MyArray[1].Free;

  MyClass[1].Free;

  MyClass[0].Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenADataSetWithoutFieldsMustAddTheSelfFieldToDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.IsNotNull(DataSet.FindField('Self'));

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenOpenAnEmptyDataSetCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.GetCurrentObject<TMyTestClass>;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenAnEmptyDataSetTheCurrentObjectMustReturnNil;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.IsNull(DataSet.GetCurrentObject<TMyTestClass>);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenAnEmptyDataSetTheValueOfTheFieldMustReturnNull;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.IsNull(DataSet.FieldByName('Name').Value);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenOpenDataSetFromAListMustHaveToLoadFieldListWithPropertiesOfMappedObject;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TObjectList<TMyTestClass>.Create;

  DataSet.OpenList<TMyTestClass>(MyObject);

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenOpenDataSetHaveToLoadFieldListWithPropertiesOfMappedObject;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenOpenTheDataSetWithAListAndTheListIsChangedTheResyncCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  DataSet.OpenList<TMyTestClass>(MyList);

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

procedure TORMDataSetTest.WhenOpenTheDataSetWithAListTheRecordCountMustBeTheSizeOfTheList;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyList := TObjectList<TMyTestClass>.Create;

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  MyList.Add(TMyTestClass.Create);

  DataSet.OpenList<TMyTestClass>(MyList);

  Assert.AreEqual(4, DataSet.RecordCount);

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenOpenTheDataSetWithAObjectTheRecordCountMustBeOne;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.AreEqual(1, DataSet.RecordCount);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenOpenTheDetailDataSetMustLoadAllRecordsFromTheParentDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  MyClass.MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Close;

  DataSetDetail.Close;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual(2, DataSetDetail.RecordCount);

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenPostARecordMustAppendToListOfObjects;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  DataSet.Post;

  DataSet.Append;

  DataSet.Post;

  Assert.AreEqual(2, DataSet.RecordCount);

  DestroyObjects(DataSet);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenPostTheDetailDataSetMustUpdateTheArrayValueFromParentDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;

  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSet.Edit;

  DataSetDetail.Append;

  DataSetDetail.Post;

  DataSetDetail.Append;

  DataSetDetail.Post;

  Assert.AreEqual<Integer>(2, Length(MyClass.MyArray));

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  DataSetDetail.Free;

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenPutTheDataSetInInsertStateMustClearTheCalculatedFields;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := 200;
    end);
  var DataSet := TORMDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyClass := TMyTestClass.Create;

  Field.DataSet := DataSet;

  DataSet.OpenObject<TMyTestClass>(MyClass);

  DataSet.Insert;

  Assert.IsTrue(DataSet.FieldByName('Calculated').IsNull);

  CallbackClass.Free;

  MyClass.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenPutTheMinusSymbolBeforeTheFieldNameInIndexMustSortDescending;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

  DataSet.IndexFieldNames := '-Id';

  DataSet.OpenArray<TMyTestClass>(MyArray);

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(A, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenRemoveAComposeDetailFieldNameMustUpdateTheParentClassWithTheNewValues;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  var MyArray: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  var MyClass: TArray<TParentClass> := [TParentClass.Create, TParentClass.Create];
  MyClass[0].MyClass := TMyTestClassTypes.Create;
  MyClass[0].MyClass.MyArray := MyArray;

  Field.FieldName := 'MyClass.MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

  DataSet.OpenArray<TParentClass>(MyClass);

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

procedure TORMDataSetTest.WhenIsRemovedTheLastRecordFromDataSetCantRaiseAnError;
begin
  var DataLink := TDataLink.Create;
  var DataSet := TORMDataSet.Create(nil);
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

  DataSet.OpenList<TMyTestClass>(MyList);

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

procedure TORMDataSetTest.WhenRemoveARecordFromDetailMustUpdateTheArrayOfTheParentClass;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass := TMyTestClassTypes.Create;
  var MyArray: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass.MyArray := MyArray;

  DataSet.OpenObject(MyClass);

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSetDetail.Delete;

  Assert.AreEqual<Integer>(1, Length(MyClass.MyArray));

  MyArray[0].Free;

  MyArray[1].Free;

  MyClass.Free;

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenRemoveTheFilterMustReturnTheOriginalRecordsToTheDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := Succ(A);

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.Filter(
    function (DataSet: TORMDataSet): Boolean
    begin
      Result := False;
    end);

  DataSet.Filter(nil);

  Assert.AreEqual(5, DataSet.RecordCount);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenScrollTheDataSetMustCalculateTheFields;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := DataSet.GetCurrentObject<TMyTestClass>.Id;
    end);
  var DataSet := TORMDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create];

  Field.DataSet := DataSet;

  for var A := 0 to 1 do
    MyArray[A].Id := A + 1;

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.Next;

  DataSet.Next;

  Assert.AreEqual(2, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  MyArray[0].Free;

  MyArray[1].Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenScrollTheParentDataSetMustLoadTheArrayInDetailDataSet;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var MyClass: TArray<TMyTestClassTypes> := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];
  MyClass[1].MyArray := [TMyTestClassTypes.Create, TMyTestClassTypes.Create];

  DataSet.OpenArray<TMyTestClassTypes>(MyClass);

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

procedure TORMDataSetTest.WhenSetAValueToAFieldThatIsAnObjectMustFillThePropertyInTheClassWithThisObject;
begin
  var AnotherObject := TAnotherObject.Create;
  var DataSet := TORMDataSet.Create(nil);
  var MyClass := TMyTestClass.Create;

  DataSet.OpenObject(MyClass);

  DataSet.Edit;

  (DataSet.FieldByName('AnotherObject') as TORMObjectField).AsObject := AnotherObject;

  DataSet.Post;

  Assert.AreEqual(AnotherObject, MyClass.AnotherObject);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenSetTheFieldValueMustChangeTheValueFromTheClass(FieldName, FieldValue: String);
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);
  var RttiType := Context.GetType(TMyTestClassTypes);
  var Value := NULL;

  var &Property := RttiType.GetProperty(FieldName);

  DataSet.OpenClass<TMyTestClassTypes>;

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

procedure TORMDataSetTest.WhenSortACalculatedFieldAsExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := DataSet.GetCurrentObject<TMyTestClass>.Id * -1;
    end);
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  var DataSet := TORMDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  DataSet.IndexFieldNames := 'Calculated';

  for var A := 0 to 2 do
    MyArray[A].Id := A + 1;

  DataSet.OpenArray<TMyTestClass>(MyArray);

  Assert.AreEqual(-3, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenSortACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;
  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  Field.DataSet := DataSet;

  DataSet.IndexFieldNames := 'Calculated';

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.OpenArray<TMyTestClass>(MyArray);
    end);

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenTheFieldAndPropertyTypeAreDifferentItHasToRaiseAnException;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('Name', ftInteger);

  Assert.WillRaise(
    procedure
    begin
      DataSet.OpenObject(MyObject);
    end, EPropertyWithDifferentType);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenTheFieldDefNameNotExistsInPropertyListMustRaiseAException;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.FieldDefs.Add('InvalidPropertyName', ftInteger);

  Assert.WillRaise(
    procedure
    begin
      DataSet.OpenObject(MyObject);
    end, EPropertyNameDoesNotExist);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenTheFieldIsMappedToANullableFieldAndTheValueIsntFilledMustReturnNullInTheFieldValue;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

  DataSet.OpenObject(MyClass);

  Assert.IsNull(DataSet.FieldByName('Nullable').Value);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenTheNullablePropertyIsFilledMustReturnTheValueFilled;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;
  MyClass.Nullable := 12345678;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual(12345678, DataSet.FieldByName('Nullable').AsInteger);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenThePropertyIsANullableTypeMustCreateTheField;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

  DataSet.OpenObject(MyClass);

  Assert.IsTrue(DataSet.FindField('Nullable') <> nil);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenThePropertyIsANullableTypeMustCreateTheFieldWithTheInternalTypeOfTheNullable;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TClassWithNullableProperty.Create;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual(ftInteger, DataSet.FieldByName('Nullable').DataType);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheField;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TLazyClass.Create;

  DataSet.OpenObject(MyClass);

  Assert.IsTrue(DataSet.FindField('Lazy') <> nil);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenThePropertyOfTheClassIsLazyLoadingMustCreateTheFieldWithTheGenericTypeOfTheLazyRecord;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyClass := TLazyClass.Create;

  DataSet.OpenObject(MyClass);

  Assert.AreEqual(ftVariant, DataSet.FindField('Lazy').DataType);

  DataSet.Free;

  MyClass.Free;
end;

procedure TORMDataSetTest.WhenTryOpenADataSetWithoutAObjectDefinitionMustRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  Assert.WillRaise(
    procedure
    begin
      DataSet.Open;
    end, EDataSetWithoutObjectDefinition);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTryToFillAnObjectWithDifferentTypeMustRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  Assert.WillRaise(
    procedure
    begin
      var MyObject := TAnotherObject.Create;

      try
        TORMObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;
      finally
        MyObject.Free;
      end;
    end, ESelfFieldDifferentObjectType);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTryToGetAComposeFieldNameFromALazyPropertyMustLoadAsExpected;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TLazyClass.Create;
  MyObject.Lazy := TMyEntity.Create;
  MyObject.Lazy.Value.Name := 'Test';

  DataSet.FieldDefs.Add('Lazy.Name', ftString, 50);

  DataSet.OpenObject(MyObject);

  Assert.AreEqual('Test', DataSet.FieldByName('Lazy.Name').AsString);

  DataSet.Free;

  MyObject.Lazy.Value.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenTryToGetAFieldValueFromAEmptyDataSetCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Name').AsString;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTryToGetTheValueOfACalculatedFieldCantRaiseAnyError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var Field := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  DataSet.OpenClass<TParentClass>;

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Calculated').AsInteger;
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenUseQualifiedClassNameHasToLoadTheDataSetWithoutErrors;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.ObjectClassName := 'Delphi.ORM.DataSet.Test.TMyTestClass';

  Assert.WillNotRaise(DataSet.Open);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenUseTheOpenClassMustLoadFieldFromTheClass;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  Assert.AreEqual(5, DataSet.FieldCount);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenTheRecordBufferIsBiggerThenOneMustLoadTheBufferOfTheDataSetAsExpected;
begin
  var DataLink := TDataLink.Create;
  var DataSet := TORMDataSet.Create(nil);
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

  DataSet.OpenList<TMyTestClass>(MyList);

  for var A := 1 to 10 do
    DataSet.Next;

  Assert.AreEqual<Integer>(10, DataSet.FieldByName('Id').AsInteger);
  Assert.AreEqual('Name10', DataSet.FieldByName('Name').AsString);
  Assert.AreEqual<Double>(20, DataSet.FieldByName('Value').AsFloat);

  DataLink.Free;

  DataSource.Free;

  DataSet.Free;

  MyList.Free;
end;

procedure TORMDataSetTest.WhenToCalculateAFieldMustReturnTheValueExpected;
begin
  var CallbackClass := TCallbackClass.Create(
    procedure (DataSet: TORMDataSet)
    begin
      DataSet.FieldByName('Calculated').AsInteger := 12345;
    end);
  var DataSet := TORMDataSet.Create(nil);
  DataSet.OnCalcFields := CallbackClass.OnCalcFields;
  var Field: TField := TIntegerField.Create(nil);
  Field.FieldName := 'Calculated';
  Field.FieldKind := fkCalculated;

  Field.DataSet := DataSet;

  Field := TFloatField.Create(nil);
  Field.FieldName := 'Value';

  Field.DataSet := DataSet;

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Edit;

  DataSet.FieldByName('Value').AsInteger := 20;

  Assert.AreEqual(12345, DataSet.FieldByName('Calculated').AsInteger);

  CallbackClass.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenChangeTheIndexFieldNamesWithDataSetOpenMustSortTheValues;
begin
  var DataSet := TORMDataSet.Create(nil);

  var MyArray: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  for var A := 0 to High(MyArray) do
    MyArray[A].Id := A;

  DataSet.OpenArray<TMyTestClass>(MyArray);

  DataSet.IndexFieldNames := '-Id';

  for var A := Pred(DataSet.RecordCount) downto 0 do
  begin
    Assert.AreEqual(A, DataSet.FieldByName('Id').AsInteger);

    DataSet.Next;
  end;

  DataSet.Free;

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMDataSetTest.WhenChangeTheObjectTypeOfTheDataSetMustBeClosedToAcceptTheChange;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  DataSet.Open;

  Assert.WillRaise(
    procedure
    begin
      DataSet.ObjectClassName := 'TMyTestClass';
    end);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenChangeTheSelfFieldMustNotifyTheChangeOfAllFieldsInDataSet;
begin
  var DataLink := TDataLinkMock.Create;
  var DataSet := TORMDataSet.Create(nil);
  var DataSource := TDataSource.Create(DataSet);
  var MyObject := TMyTestClass.Create;

  DataLink.DataSource := DataSource;
  DataSource.DataSet := DataSet;

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Insert;

  TORMObjectField(DataSet.FieldByName('Self')).AsObject := MyObject;

  Assert.AreEqual('RecordChanged', DataLink.FMethodCalled);

  DataSet.Free;

  DataLink.Free;
end;

procedure TORMDataSetTest.WhenCheckingIfTheFieldIsNullCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);
  var MyObject := TMyTestClass.Create;

  DataSet.OpenObject(MyObject);

  Assert.WillNotRaise(
    procedure
    begin
      DataSet.FieldByName('Id').IsNull;
    end);

  DataSet.Free;

  MyObject.Free;
end;

procedure TORMDataSetTest.WhenCleanUpTheDataSetFieldPropertyTheParentDataSetMustBeCleanedToo;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClassTypes>;

  DataSet.Open;

  DataSetDetail.DataSetField := DataSet.FieldByName('MyArray') as TDataSetField;

  DataSetDetail.DataSetField := nil;

  Assert.IsNull(DataSetDetail.ParentDataSet);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenCleanUpTheObjectClassNameMustStayEmpty;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.ObjectClassName := 'TMyTestClass';

  DataSet.ObjectClassName := EmptyStr;

  Assert.AreEqual(EmptyStr, DataSet.ObjectClassName);

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenClearAFieldCantRaiseAnError;
begin
  var DataSet := TORMDataSet.Create(nil);

  DataSet.OpenClass<TMyTestClass>;

  DataSet.Append;

  Assert.WillNotRaise(DataSet.FieldByName('Id').Clear);

  DataSet.Cancel;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenCloseTheDataSetMustUmbingTheFieldsAndCloseTheDataSetDetail;
begin
  var DataSet := TORMDataSet.Create(nil);
  var DataSetDetail := TORMDataSet.Create(nil);
  var Field := TDataSetField.Create(nil);
  Field.FieldName := 'MyArray';

  Field.DataSet := DataSet;

  DataSetDetail.DataSetField := Field;

  var AnotherField := TLongWordField.Create(nil);
  AnotherField.FieldName := 'Cardinal';

  AnotherField.DataSet := DataSet;

  DataSet.OpenClass<TMyTestClassTypes>;

  DataSet.Close;

  Assert.AreEqual(0, AnotherField.FieldNo);

  Assert.IsFalse(DataSetDetail.Active);

  DataSetDetail.Free;

  DataSet.Free;
end;

procedure TORMDataSetTest.WhenDeleteARecordFromADataSetMustRemoveTheValueFromTheDataSet;
begin
  var Context := TRttiContext.Create;
  var DataSet := TORMDataSet.Create(nil);
  var List: TArray<TMyTestClass> := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  DataSet.OpenArray<TMyTestClass>(List);

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

constructor TCallbackClass.Create(CallbackProc: TProc<TORMDataSet>);
begin
  FCallbackProc := CallbackProc;
end;

procedure TCallbackClass.OnCalcFields(DataSet: TDataSet);
var
  ORMDataSet: TORMDataSet absolute DataSet;

begin
  FCallbackProc(ORMDataSet);
end;

{ TORMListIteratorTest }

procedure TORMListIteratorTest.AccessingTheObjectListMustReturnTheObjectInThePositionPassedInTheParam;
begin
  var Value := [TObject(1), TObject(2), TObject(3)];

  var Cursor := CreateCursor<TObject>(Value);

  Assert.AreEqual<Pointer>(Value[1], Cursor.Objects[2]);
end;

function TORMListIteratorTest.CreateCursor<T>(const Value: TArray<T>): IORMObjectIterator;
begin
  Result := TORMListIterator<T>.Create(Value);
end;

function TORMListIteratorTest.CreateCursor<T>(const Value: array of T): IORMObjectIterator;
begin
  Result := TORMListIterator<T>.Create(Value);
end;

function TORMListIteratorTest.CreateCursorList<T>(const Value: TList<T>): IORMObjectIterator;
begin
  Result := TORMListIterator<T>.Create(Value);
end;

procedure TORMListIteratorTest.TheCurrentPositionOfRecordMustBeSaved;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.CurrentPosition := 1;

  Assert.AreEqual<Cardinal>(1, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.TheRecordCountFunctionMustReturnTheTotalOfItensInTheList;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Assert.AreEqual(3, Cursor.RecordCount);
end;

procedure TORMListIteratorTest.TheSwapProcedureMustChangeTheItemsByThePositionPassed;
begin
  var MyArray := [TMyClass.Create, TMyClass.Create, TMyClass.Create];

  var Cursor := CreateCursor<TMyClass>(MyArray);

  for var A := Low(MyArray) to High(MyArray) do
    MyArray[A].Value := A;

  Cursor.Swap(1, 3);

  Assert.AreEqual(2, TMyClass(Cursor.Objects[1]).Value);

  Assert.AreEqual(0, TMyClass(Cursor.Objects[3]).Value);

  for var Item in MyArray do
    Item.Free;
end;

procedure TORMListIteratorTest.TheUpdateArrayMustFillTheValuesInThePropertyPassedInTheParam;
begin
  var Context := TRttiContext.Create;
  var &Property := Context.GetType(TMyTestClassTypes).GetProperty('MyArray') as TRttiProperty;
  var Cursor := CreateCursor<TMyTestClassTypes>([TMyTestClassTypes.Create, TMyTestClassTypes.Create]);
  var MyClass := TMyTestClassTypes.Create;

  Cursor.UpdateArrayProperty(&Property, MyClass);

  Assert.AreEqual<Integer>(2, Length(MyClass.MyArray));

  MyClass.MyArray[0].Free;

  MyClass.MyArray[1].Free;

  MyClass.Free;
end;

procedure TORMListIteratorTest.WhenAddAnObjectTheCurrentPositionMustBeTheInsertedObjectPosition;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.Add(TObject(4));

  Assert.AreEqual(4, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.WhenAddAnObjectToCursorThisMustBeAddedToTheList;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.Add(TObject(4));

  Assert.AreEqual(4, Cursor.RecordCount);

  Assert.AreEqual<Pointer>(TObject(4), Cursor.Objects[4]);
end;

procedure TORMListIteratorTest.WhenAValueIsRemovedFromTheListTheResyncMustPutTheCurrentPositionInAValidPosition;
begin
  var List := TList<TObject>.Create;

  var Cursor := CreateCursorList<TObject>(List);

  List.Add(TObject(1));

  List.Add(TObject(1));

  List.Add(TObject(1));

  List.Add(TObject(1));

  Cursor.ResetEnd;

  List.Delete(0);

  List.Delete(0);

  Cursor.Resync;

  Assert.AreEqual(2, Cursor.CurrentPosition);

  List.Free;
end;

procedure TORMListIteratorTest.WhenCallClearProcedureMustCleanUpTheItensInTheInternalList;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.Clear;

  Assert.AreEqual(0, Cursor.RecordCount);
end;

procedure TORMListIteratorTest.WhenCallClearProcedureMustResetTheCurrentPositionOfTheIterator;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.Next;

  Cursor.Next;

  Cursor.Clear;

  Assert.AreEqual(0, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.WhenCallRemoveMustRemoveTheCurrentValueFromTheList;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.CurrentPosition := 2;

  Cursor.Remove;

  Assert.AreEqual(2, Cursor.RecordCount);

  Assert.AreEqual<Pointer>(TObject(1), Cursor.GetObject(1));

  Assert.AreEqual<Pointer>(TObject(3), Cursor.GetObject(2));
end;

procedure TORMListIteratorTest.WhenCallResetBeginMustPutTheIteratorInTheFirstPosition;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.ResetBegin;

  Assert.AreEqual(0, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.WhenClassResetEndMustPutTheIteratorInLastPosition;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.ResetEnd;

  Assert.AreEqual(4, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.WhenRemoveTheLastPositionInTheListMustUpdateTheCurrentPositionOfTheIterator;
begin
  var Cursor := CreateCursor<TObject>([TObject(1), TObject(2), TObject(3)]);

  Cursor.ResetEnd;

  Cursor.Prior;

  Cursor.Remove;

  Assert.AreEqual(2, Cursor.CurrentPosition);
end;

procedure TORMListIteratorTest.WhenSetObjectToTheIteratorMustReplaceTheObjectInTheIndex;
begin
  var Cursor := CreateCursor<TObject>([TObject(1)]);

  Cursor.SetObject(1, TObject(2));

  Assert.AreEqual<Pointer>(TObject(2), Cursor.GetObject(1));
end;

procedure TORMListIteratorTest.WhenTheArrayIsEmptyTheNextProcedureMustReturnFalse;
begin
  var Cursor := CreateCursor<TObject>(nil);

  Assert.IsFalse(Cursor.Next);
end;

procedure TORMListIteratorTest.WhenTheArrayIsEmptyThePriorProcedureMustReturnFalse;
begin
  var Cursor := CreateCursor<TObject>(nil);

  Assert.IsFalse(Cursor.Prior);
end;

procedure TORMListIteratorTest.WhenTheArrayIsNotEmptyTheNextProcedureMustReturnTrue;
begin
  var Cursor := CreateCursor<TObject>([TObject(1)]);

  Assert.IsTrue(Cursor.Next);
end;

procedure TORMListIteratorTest.WhenTheIterationInCursorReachTheEndOfTheArrayTheNextFunctionMustReturnFalse;
begin
  var Cursor := CreateCursor<TObject>([TObject(1)]);

  Cursor.Next;

  Assert.IsFalse(Cursor.Next);
end;

{ TDataLinkMock }

procedure TDataLinkMock.RecordChanged(Field: TField);
begin
  inherited;

  MethodCalled := 'RecordChanged';
end;

end.

