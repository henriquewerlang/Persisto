unit Persisto.DataSet.Test;

interface

uses System.SysUtils, System.Rtti, Data.DB, System.Generics.Collections, Persisto.DataSet, Test.Insight.Framework, Persisto, Persisto.Mapping;

type
  TDataLinkMock = class;

  [TestFixture]
  TPersistoDataSetTest = class
  private
    FContext: TRttiContext;
    FDataSet: TPersistoDataSet;
    FDataSetLink: TDataLinkMock;
    FDataSource: TDataSource;
    FManager: TPersistoManager;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenTheManagerPropertyIsEmptyMustRaiseAnError;
    [Test]
    procedure WhenTryToOpenTheDataSetWithoutAnObjectInformationMustRaiseAnError;
    [Test]
    procedure WhenLoadTheObjectClassNameMustOpenWithoutAnyError;
    [Test]
    procedure WhenLoadTheObjectClassPropertyCantRaiseErrorWhenOpenTheDataSet;
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
    procedure WhenUpdateTheFieldDefsCantRaiseAnyError;
    [Test]
    procedure WhenTheFieldIsCharTypeTheSizeMustBeOne;
    [Test]
    procedure WhenTheFieldIsStringTypeTheSizeMustBeTheValueFromAttribute;
    [Test]
    procedure WhenLoadTheClassNameWithAnInvalidClassNameMustRaiseAnError;
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
    procedure WhenTryToOpenTheDataSetWithoutClassInformationMustRaiseError;
    [Test]
    procedure WhenLoadACalculatedFieldCantRaiseAnyError;
    [Test]
    procedure WhenLoadADateTimeFieldCantRaiseAnyError;
    [Test]
    procedure WhenCreateADateTimeFieldMustReturnTheDateTimeInThePropertyHasExpected;
    [Test]
    procedure WhenCreateADateFieldMustReturnTheValueFromDateFieldHasExpected;
    [Test]
    procedure WhenCreateATimeFieldMustReturnTheValueFromTimeHasExpected;
    [Test]
    procedure WhenGetABookmarkAndCallTheGoToBookmarkMustGoToThePositionHasExpected;
    [Test]
    procedure TheBookmarkValidMustReturnTrue;
    [Test]
    procedure WhenTheStringFieldIsEmptyCantRaiseAnyErrorWhenTryToGetTheValue;
    [Test]
    procedure WhenCompareTwoBookmarksAndTheyAreEqualMustReturnZeroInTheComparingFunction;
    [Test]
    procedure WhenCompareTwoBookmarksAndTheFirstIsBeforeTheSecondMustReturnANegativeValueInTheComparingFunction;
    [Test]
    procedure WhenCompareTwoBookmarksAndTheFirstIsAfterTheSecondMustReturnAPositiveValueInTheComparingFunction;
    [Test]
    procedure WhenRestoreABookmarkAndNavigateInTheDataSetMustLoadTheCorrectRecord;
    [Test]
    procedure WhenFillTheActiveObjectMustReturnTheFilledObject;
    [Test]
    procedure WhenFillTheActiveObjectAndNavigateBetweenRecordsMustKeepTheObjectFilledLoaded;
    [Test]
    procedure WhenFillTheActiveObjectMustTriggerTheRecordChangedEvent;
    [Test]
    procedure WhenPostTheDataSetMustLoadTheInsertingObjectInTheObjectList;
    [Test]
    procedure WhenFillAFieldValueAndTheDataSetNotEditingModeMustRaiseAnError;
    [Test]
    procedure WhenFillTheValueOfOneFieldMustLoadTheValueInTheObjectProperty;
    [Test]
    procedure WhenFillTheValueOfAnIntegerFieldMustLoadTheValueInTheObjectProperty;
    [Test]
    procedure WhenCheckIfTheFieldIsNullCantRaiseAnyError;
    [Test]
    procedure WhenFillTheValueOfAnComplexFieldMustLoadTheValueOfTheLastFieldAsExpected;
    [Test]
    procedure WhenCancelTheDataSetCantRaiseAnyError;
    [Test]
    procedure WhenPostTheDataSetMustTheCurrentRecordBeInTheCorrectPosition;
    [Test]
    procedure WhenTryToGetTheValueOfAFieldAndTheDataSetIsEmptyCantRaiseAnyError;
    [Test]
    procedure WhenTryToGetTheCurrentObjectInAnInactiveDataSetMustRaiseNotOpenError;
    [Test]
    procedure WhenFillTheObjectFieldWithTheVariantValueCantRaiseAnyError;
    [Test]
    procedure WhenTryToGetTheValueTheObjectFieldCantRaiseAnyError;
    [Test]
    procedure WhenFillTheObjectFieldMustLoadTheValueInTheFieldHasExpected;
    [Test]
    procedure TheFieldClassOfDataSetFieldMustBeThePersistoMasterField;
    [Test]
    procedure WhenOpenANestedDataSetCantRaiseAnyError;
    [Test]
    procedure WhenOpenANestedDataSetMustLoadAllFieldFromTheArrayTypeField;
    [Test]
    procedure WhenOpenTheNestedDataSetMustLoadAllObjectsFromTheArrayInTheDataSet;
    [Test]
    procedure WhenChangeAFieldValueMustTriggerTheChangeFieldEvent;
    [Test]
    procedure WhenEditARecordCantInsertThisValueInTheDatSet;
    [Test]
    procedure WhenGetTheObjectFromTheObjectFieldMustReturnTheObjectHasExpected;
    [Test]
    procedure WhenGetValueFromALazyFieldCantRaiseAnyError;
    [Test]
    procedure WhenGetValueFromALazyFieldMustLoadTheValueFromDatabase;
    [Test]
    procedure WhenUseAComposeFieldNameWithALazyFieldCantRaiseAnyError;
    [Test]
    procedure WhenInsertingARecordMustInsertTheNewRecordInTheCurrentPositionOfTheDataSet;
    [Test]
    procedure WhenAppendARecordMustLoadThisRecordInTheLastPositionOfTheDataSet;
    [Test]
    procedure WhenAppendOneRecordAndCancelTheRecordCantRaiseError;
    [Test]
    procedure WhenInsertARecordInTheDetailDataSetMustLoadTheObjectInTheMasterArrayAsExpected;
    [Test]
    procedure WhenNavigatingBeetweenRecordosWithADataSetFieldMustLoadTheDetailWithTheValuesFromTheArrayAsExpected;
    [Test]
    procedure WhenLoadTheDataSetFieldMustTriggerTheDataSetChangeEventInTheDetail;
    [Test]
    procedure WhenCreateAFieldWithTheIncorrectTypeMustRaiseError;
    [Test]
    procedure WhenCloseTheMainDataSetTheNestedDataSetCantTriggerEvents;
    [Test]
    procedure WhenPostAnInsertingObjectCantDuplicateTheRecord;
  end;

  TDataLinkMock = class(TDataLink)
  private
    FEvents: TList<TDataEvent>;
  protected
    procedure DataEvent(Event: TDataEvent; Info: NativeInt); override;
  public
    constructor Create;

    destructor Destroy; override;

    procedure ClearEvents;

    property Events: TList<TDataEvent> read FEvents;
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
    [Size(150)]
    property AnotherName: String read FAnotherName write FAnotherName;
    property AnotherObject: TAnotherObject read FAnotherObject write FAnotherObject;
    [Size(150)]
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
    [Size(150)]
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
    property AnotherObject: TAnotherObject read FAnotherObject write FAnotherObject;
  end;

  TMyTestClassChild = class(TMyTestClass)
  private
    FAField: String;
    FAnotherField: Integer;
  published
    [Size(150)]
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
    FId: Integer;
  published
    property Id: Integer read FId write FId;
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

  TLazyValueMock = class(TInterfacedObject, ILazyValue)
  private
    FValue: TValue;
  public
    constructor Create(const LazyObject: TObject);

    function GetKey: TValue;
    function GetValue: TValue;
    function HasValue: Boolean;

    procedure SetValue(const Value: TValue);
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

procedure TPersistoDataSetTest.Setup;
begin
  inherited;

  FContext := TRttiContext.Create;
  FDataSet := TPersistoDataSet.Create(nil);
  FDataSetLink := TDataLinkMock.Create;
  FDataSource := TDataSource.Create(FDataSet);
  FDataSource.DataSet := FDataSet;
  FManager := TPersistoManager.Create(nil);

  FDataSet.Manager := FManager;
  FDataSetLink.DataSource := FDataSource;
end;

procedure TPersistoDataSetTest.TearDown;
begin
  var Objects := FDataSet.Objects;

  FManager.Free;

  FContext.Free;

  FDataSet.Free;

  FDataSetLink.Free;

  try
    for var &Object in Objects do
      &Object.Free;
  except
  end;
end;

procedure TPersistoDataSetTest.TheBookmarkValidMustReturnTrue;
begin
  Assert.IsTrue(FDataSet.BookmarkValid(nil));
end;

procedure TPersistoDataSetTest.TheFieldClassOfDataSetFieldMustBeThePersistoMasterField;
begin
  FDataSet.ObjectClass := TMyManyValue;

  FDataSet.Open;

  Assert.AreEqual(TDataSetField, FDataSet.FieldByName('Childs').ClassType);
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

procedure TPersistoDataSetTest.WhenAppendARecordMustLoadThisRecordInTheLastPositionOfTheDataSet;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Next;

  FDataSet.Append;

  var InsertingObject := FDataSet.CurrentObject;

  FDataSet.Post;

  FDataSet.Last;

  Assert.AreEqual(InsertingObject, FDataSet.CurrentObject);
end;

procedure TPersistoDataSetTest.WhenAppendOneRecordAndCancelTheRecordCantRaiseError;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Append;

  Assert.WillNotRaise(FDataSet.Cancel);
end;

procedure TPersistoDataSetTest.WhenTheClassHasAnArrayPropertyMustLoadTheFieldAsADataSetField;
begin
  FDataSet.ObjectClass := TMyManyValue;

  FDataSet.Open;

  Assert.AreEqual(ftDataSet, FDataSet.FieldByName('Childs').DataType);
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

procedure TPersistoDataSetTest.WhenCancelTheDataSetCantRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.Cancel;
    end);
end;

procedure TPersistoDataSetTest.WhenChangeAFieldValueMustTriggerTheChangeFieldEvent;
begin
  var MyObject1 := TMyTestClass.Create;

  FDataSet.Objects := [MyObject1];

  FDataSet.Open;

  FDataSet.Edit;

  FDataSetLink.ClearEvents;

  FDataSet.Fields[0].AsInteger := 1;

  Assert.IsFalse(FDataSetLink.Events.IsEmpty);

  Assert.AreEqual(deFieldChange, FDataSetLink.Events.First);
end;

procedure TPersistoDataSetTest.WhenCheckIfTheFieldIsNullCantRaiseAnyError;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Edit;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldByName('Id').IsNull;
    end);
end;

procedure TPersistoDataSetTest.WhenCloseTheMainDataSetTheNestedDataSetCantTriggerEvents;
begin
  var AObject := TMyManyValue.Create;
  AObject.Childs := [TMyChildLink.Create, TMyChildLink.Create, TMyChildLink.Create];
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.Objects := [AObject];
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  FDataSource.DataSet := NestedDataSet;

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSet.Open;

  FDataSetLink.Events.Clear;

  FDataSet.Close;

  Assert.IsFalse(FDataSetLink.Events.Contains(deDataSetChange));

  for var Child in AObject.Childs do
    Child.Free;
end;

procedure TPersistoDataSetTest.WhenCompareTwoBookmarksAndTheFirstIsAfterTheSecondMustReturnAPositiveValueInTheComparingFunction;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Last;

  var Bookmark1 := FDataSet.Bookmark;

  FDataSet.First;

  var Bookmark2 := FDataSet.Bookmark;

  Assert.IsTrue(FDataSet.CompareBookmarks(Bookmark1, Bookmark2) > 0);
end;

procedure TPersistoDataSetTest.WhenCompareTwoBookmarksAndTheFirstIsBeforeTheSecondMustReturnANegativeValueInTheComparingFunction;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  var Bookmark1 := FDataSet.Bookmark;

  FDataSet.Last;

  var Bookmark2 := FDataSet.Bookmark;

  Assert.IsTrue(FDataSet.CompareBookmarks(Bookmark1, Bookmark2) < 0);
end;

procedure TPersistoDataSetTest.WhenCompareTwoBookmarksAndTheyAreEqualMustReturnZeroInTheComparingFunction;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  var Bookmark1 := FDataSet.Bookmark;
  var Bookmark2 := FDataSet.Bookmark;

  Assert.AreEqual(0, FDataSet.CompareBookmarks(Bookmark1, Bookmark2));
end;

procedure TPersistoDataSetTest.WhenCreateADateFieldMustReturnTheValueFromDateFieldHasExpected;
begin
  var Field := TDateField.Create(FDataSet);
  Field.FieldName := 'DateTime';
  Field.FieldKind := fkData;
  var MyObject := TMyTestClassTypes.Create;
  var TheTime := EncodeDate(2025, 09, 26);

  MyObject.DateTime := TheTime;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(DateToStr(TheTime), DateTimeToStr(Field.AsDateTime));
end;

procedure TPersistoDataSetTest.WhenCreateADateTimeFieldMustReturnTheDateTimeInThePropertyHasExpected;
begin
  var Field := TDateTimeField.Create(FDataSet);
  Field.FieldName := 'DateTime';
  Field.FieldKind := fkData;
  var MyObject := TMyTestClassTypes.Create;
  var TheTime := EncodeDate(2025, 09, 26) + EncodeTime(10, 10, 10, 0);

  MyObject.DateTime := TheTime;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(DateTimeToStr(TheTime), DateTimeToStr(Field.AsDateTime));
end;

procedure TPersistoDataSetTest.WhenCreateAFieldWithTheIncorrectTypeMustRaiseError;
begin
  var Field := TWideStringField.Create(FDataSet);
  Field.FieldName := 'Value';
  var MyObject := TMyTestClass.Create;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  Assert.WillRaise(FDataSet.Open, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenCreateATimeFieldMustReturnTheValueFromTimeHasExpected;
begin
  var Field := TTimeField.Create(FDataSet);
  Field.FieldName := 'DateTime';
  Field.FieldKind := fkData;
  var MyObject := TMyTestClassTypes.Create;
  var TheTime := EncodeTime(10, 10, 10, 0);

  MyObject.DateTime := TheTime;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(TimeToStr(TheTime), TimeToStr(Field.AsDateTime));
end;

procedure TPersistoDataSetTest.WhenEditARecordCantInsertThisValueInTheDatSet;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Edit;

  FDataSet.Post;

  Assert.AreEqual(1, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenFillAFieldValueAndTheDataSetNotEditingModeMustRaiseAnError;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillRaise(
    procedure
    begin
      FDataSet.FieldByName('Name').AsString := 'Value';
    end, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenFillAnEmptyClassNameCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.ObjectClassName := EmptyStr;
    end);
end;

procedure TPersistoDataSetTest.WhenFillTheActiveObjectAndNavigateBetweenRecordsMustKeepTheObjectFilledLoaded;
begin
  var MyObject1 := TMyTestClass.Create;
  var MyObject2 := TMyTestClass.Create;

  FDataSet.Objects := [MyObject1, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.CurrentObject := MyObject2;

  FDataSet.Next;

  FDataSet.Prior;

  Assert.AreEqual(MyObject2, FDataSet.CurrentObject);

  MyObject1.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheActiveObjectMustReturnTheFilledObject;
begin
  var MyObject1 := TMyTestClass.Create;
  var MyObject2 := TMyTestClass.Create;

  FDataSet.Objects := [MyObject1];

  FDataSet.Open;

  FDataSet.CurrentObject := MyObject2;

  Assert.AreEqual(MyObject2, FDataSet.CurrentObject);

  MyObject1.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheActiveObjectMustTriggerTheRecordChangedEvent;
begin
  var MyObject1 := TMyTestClass.Create;

  FDataSet.Objects := [MyObject1];

  FDataSet.Open;

  FDataSetLink.ClearEvents;

  FDataSet.CurrentObject := MyObject1;

  Assert.IsFalse(FDataSetLink.Events.IsEmpty);

  Assert.AreEqual(deRecordChange, FDataSetLink.Events.First);
end;

procedure TPersistoDataSetTest.WhenFillTheObjectFieldMustLoadTheValueInTheFieldHasExpected;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;
  var AObject := TMyTestClass.Create;

  FDataSet.Open;

  FDataSet.Edit;

  FDataSet.FieldByName('Class').AsVariant := NativeInt(AObject);

  Assert.AreEqual(NativeInt(AObject), FDataSet.FieldByName('Class').AsVariant);

  AObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheObjectFieldWithTheVariantValueCantRaiseAnyError;
begin
  var AObject := TMyTestClass.Create;
  FDataSet.ObjectClass := TMyTestClassTypes;

  FDataSet.Open;

  FDataSet.Edit;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldByName('Class').AsVariant := NativeInt(AObject);
    end);

  AObject.Free;
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

  MyObject.Free;
end;

procedure TPersistoDataSetTest.WhenFillTheValueOfAnComplexFieldMustLoadTheValueOfTheLastFieldAsExpected;
begin
  var Field := TWideStringField.Create(FDataSet);
  Field.FieldName := 'AnotherObject.AnotherObject.AnotherName';
  var MyObject := TMyTestClass.Create;
  MyObject.AnotherObject := TAnotherObject.Create;
  MyObject.AnotherObject.AnotherObject := TAnotherObject.Create;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Edit;

  FDataSet.FieldByName('AnotherObject.AnotherObject.AnotherName').AsString := 'abc';

  Assert.AreEqual('abc', MyObject.AnotherObject.AnotherObject.AnotherName);
end;

procedure TPersistoDataSetTest.WhenFillTheValueOfAnIntegerFieldMustLoadTheValueInTheObjectProperty;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Edit;

  FDataSet.FieldByName('Id').AsInteger := 123;

  Assert.AreEqual(123, MyObject.Id);
end;

procedure TPersistoDataSetTest.WhenFillTheValueOfOneFieldMustLoadTheValueInTheObjectProperty;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  FDataSet.Edit;

  FDataSet.FieldByName('Name').AsString := 'Value';

  Assert.AreEqual('Value', MyObject.Name);
end;

procedure TPersistoDataSetTest.WhenGetABookmarkAndCallTheGoToBookmarkMustGoToThePositionHasExpected;
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

  for var A := 1 to 7 do
    FDataSet.Next;

  var Bookmark := FDataSet.Bookmark;

  FDataSet.First;

  FDataSet.Bookmark := Bookmark;

  Assert.AreEqual('Name8', FDataSet.FieldByName('Name').AsString);

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheObjectFromTheObjectFieldMustReturnTheObjectHasExpected;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;
  var AObject := TMyTestClass.Create;

  FDataSet.Open;

  FDataSet.Edit;

  var Field := FDataSet.FieldByName('Class') as TPersistoObjectField;

  Field.AsObject := AObject;

  Assert.AreEqual(AObject, Field.AsObject);

  AObject.Free;
end;

procedure TPersistoDataSetTest.WhenGetTheObjectListMustReturnTheObjectsFilledInTheList;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject, TMyTestClass.Create, TMyTestClass.Create];

  Assert.AreEqual(3, Length(FDataSet.Objects));
  Assert.AreEqual(MyObject, FDataSet.Objects[0]);
end;

procedure TPersistoDataSetTest.WhenGetValueFromALazyFieldCantRaiseAnyError;
begin
  var LazyObject := TMyEntity.Create;
  var MyObject := TLazyArrayClass.Create;
  MyObject.Lazy.LazyValue := TLazyValueMock.Create(LazyObject);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      TPersistoObjectField(FDataSet.FieldByName('Lazy')).AsObject;
    end);

  LazyObject.Free;
end;

procedure TPersistoDataSetTest.WhenGetValueFromALazyFieldMustLoadTheValueFromDatabase;
begin
  var LazyObject := TMyEntity.Create;
  var MyObject := TLazyArrayClass.Create;
  MyObject.Lazy.LazyValue := TLazyValueMock.Create(LazyObject);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.AreEqual(LazyObject, TPersistoObjectField(FDataSet.FieldByName('Lazy')).AsObject);

  LazyObject.Free;
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

procedure TPersistoDataSetTest.WhenInsertARecordInTheDetailDataSetMustLoadTheObjectInTheMasterArrayAsExpected;
begin
  var AObject := TMyManyValue.Create;
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.Objects := [AObject];
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSet.Open;

  NestedDataSet.Insert;

  NestedDataSet.Post;

  NestedDataSet.Insert;

  NestedDataSet.Post;

  NestedDataSet.Insert;

  NestedDataSet.Post;

  FDataSet.Post;

  Assert.AreEqual(3, Length(AObject.Childs));

  for var Child in AObject.Childs do
    Child.Free;
end;

procedure TPersistoDataSetTest.WhenInsertingARecordMustInsertTheNewRecordInTheCurrentPositionOfTheDataSet;
begin
  FDataSet.Objects := [TMyTestClass.Create, TMyTestClass.Create, TMyTestClass.Create];

  FDataSet.Open;

  FDataSet.Next;

  FDataSet.Insert;

  var InsertingObject := FDataSet.CurrentObject;

  FDataSet.Post;

  FDataSet.First;

  FDataSet.Next;

  Assert.AreEqual(InsertingObject, FDataSet.CurrentObject);
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

procedure TPersistoDataSetTest.WhenNavigatingBeetweenRecordosWithADataSetFieldMustLoadTheDetailWithTheValuesFromTheArrayAsExpected;
begin
  var Object1 := TMyManyValue.Create;
  var Object2 := TMyManyValue.Create;
  var Object3 := TMyManyValue.Create;
  Object1.Childs := [TMyChildLink.Create, TMyChildLink.Create, TMyChildLink.Create];
  Object3.Childs := [TMyChildLink.Create];
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.Objects := [Object1, Object2, Object3];
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSet.Open;

  Assert.AreEqual(3, NestedDataSet.RecordCount);

  FDataSet.Next;

  Assert.AreEqual(0, NestedDataSet.RecordCount);

  FDataSet.Next;

  Assert.AreEqual(1, NestedDataSet.RecordCount);

  for var Child in Object1.Childs + Object2.Childs + Object3.Childs do
    Child.Free;
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

procedure TPersistoDataSetTest.WhenOpenANestedDataSetCantRaiseAnyError;
begin
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.ObjectClass := TMyManyValue;
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  Assert.WillNotRaise(FDataSet.Open);
end;

procedure TPersistoDataSetTest.WhenOpenANestedDataSetMustLoadAllFieldFromTheArrayTypeField;
begin
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.ObjectClass := TMyManyValue;
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSet.Open;

  Assert.AreEqual(4, NestedDataSet.FieldCount);
end;

procedure TPersistoDataSetTest.WhenOpenTheDataSetWithOneObjectMustReturnFalseInTheEOFProperty;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.IsFalse(FDataSet.Eof);
end;

procedure TPersistoDataSetTest.WhenOpenTheNestedDataSetMustLoadAllObjectsFromTheArrayInTheDataSet;
begin
  var AObject := TMyManyValue.Create;
  AObject.Childs := [TMyChildLink.Create, TMyChildLink.Create, TMyChildLink.Create];
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.Objects := [AObject];
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSet.Open;

  Assert.AreEqual(3, NestedDataSet.RecordCount);

  for var Child in AObject.Childs do
    Child.Free;
end;

procedure TPersistoDataSetTest.WhenPostAnInsertingObjectCantDuplicateTheRecord;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  FDataSet.Post;

  FDataSet.Edit;

  FDataSet.Post;

  FDataSet.Edit;

  FDataSet.Post;

  Assert.AreEqual(1, FDataSet.RecordCount);
end;

procedure TPersistoDataSetTest.WhenPostTheDataSetMustLoadTheInsertingObjectInTheObjectList;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  FDataSet.Post;

  Assert.IsNotNil(FDataSet.Objects[0]);
end;

procedure TPersistoDataSetTest.WhenPostTheDataSetMustTheCurrentRecordBeInTheCorrectPosition;
begin
  FDataSet.ObjectClass := TMyTestClass;

  FDataSet.Open;

  FDataSet.Insert;

  FDataSet.FieldByName('Name').AsString := 'a';

  FDataSet.Post;

  FDataSet.Insert;

  FDataSet.FieldByName('Name').AsString := 'b';

  FDataSet.Post;

  FDataSet.Insert;

  FDataSet.FieldByName('Name').AsString := 'c';

  FDataSet.Post;

  Assert.AreEqual('c', FDataSet.FieldByName('Name').AsString);
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

procedure TPersistoDataSetTest.WhenRestoreABookmarkAndNavigateInTheDataSetMustLoadTheCorrectRecord;
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

  var Bookmark := FDataSet.Bookmark;

  FDataSet.Bookmark := Bookmark;

  FDataSet.Prior;

  FDataSet.Next;

  FDataSet.Next;

  FDataSet.Prior;

  FDataSet.Prior;

  FDataSet.Next;

  FDataSet.Next;

  Assert.AreEqual('Name3', FDataSet.FieldByName('Name').AsString);

  MyList.Free;
end;

procedure TPersistoDataSetTest.WhenLoadACalculatedFieldCantRaiseAnyError;
begin
  var Field := TWideStringField.Create(FDataSet);
  Field.FieldName := 'CalculatedField';
  Field.FieldKind := fkCalculated;
  var MyObject := TMyTestClass.Create;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      if Field.AsString = EmptyStr then
    end);
end;

procedure TPersistoDataSetTest.WhenLoadADateTimeFieldCantRaiseAnyError;
begin
  var Field := TDateTimeField.Create(FDataSet);
  Field.FieldName := 'DateTime';
  Field.FieldKind := fkData;
  var MyObject := TMyTestClassTypes.Create;
  MyObject.DateTime := Now;

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      if Field.AsString = EmptyStr then
    end);
end;

procedure TPersistoDataSetTest.WhenLoadTheClassNameWithAnInvalidClassNameMustRaiseAnError;
begin
  FDataSet.ObjectClassName := 'InvalidType';

  Assert.WillRaise(
    procedure
    begin
      FDataSet.Open;
    end, EDataSetWithoutObjectDefinition);
end;

procedure TPersistoDataSetTest.WhenLoadTheDataSetFieldMustTriggerTheDataSetChangeEventInTheDetail;
begin
  var Object1 := TMyManyValue.Create;
  Object1.Childs := [TMyChildLink.Create, TMyChildLink.Create, TMyChildLink.Create];
  var ChildsField := TDataSetField.Create(FDataSet);
  ChildsField.FieldName := 'Childs';
  FDataSet.Objects := [Object1];
  var NestedDataSet := TPersistoDataSet.Create(FDataSet);

  ChildsField.SetParentComponent(FDataSet);

  NestedDataSet.DataSetField := ChildsField;

  FDataSource.DataSet := NestedDataSet;

  FDataSet.Open;

  Assert.IsFalse(FDataSetLink.Events.IsEmpty);

  Assert.AreEqual(deDataSetChange, FDataSetLink.Events.Last);

  for var Child in Object1.Childs do
    Child.Free;
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

procedure TPersistoDataSetTest.WhenTheManagerPropertyIsEmptyMustRaiseAnError;
begin
  FDataSet.Manager := nil;

  Assert.WillRaise(
    procedure
    begin
      FDataSet.Open;
    end, EDataSetWithoutManager);
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

  Assert.AreEqual(TGUIDField, FDataSet.FieldByName('UniqueIdentifier').ClassType);
end;

procedure TPersistoDataSetTest.WhenTheStringFieldIsEmptyCantRaiseAnyErrorWhenTryToGetTheValue;
begin
  var MyObject := TMyTestClass.Create;

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldByName('Name').AsString;
    end);
end;

procedure TPersistoDataSetTest.WhenTryToGetTheCurrentObjectInAnInactiveDataSetMustRaiseNotOpenError;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataSet.GetCurrentObject<TObject>;
    end, EDatabaseError);
end;

procedure TPersistoDataSetTest.WhenTryToGetTheValueOfAFieldAndTheDataSetIsEmptyCantRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.Fields[0].AsString;
    end);
end;

procedure TPersistoDataSetTest.WhenTryToGetTheValueTheObjectFieldCantRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyTestClassTypes;

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldByName('Class').AsVariant;
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

procedure TPersistoDataSetTest.WhenTryToOpenTheDataSetWithoutAnObjectInformationMustRaiseAnError;
begin
  Assert.WillRaise(FDataSet.Open, EDataSetWithoutClassDefinitionLoaded);
end;

procedure TPersistoDataSetTest.WhenTryToOpenTheDataSetWithoutClassInformationMustRaiseError;
begin
  FDataSet.ObjectClass := nil;
  FDataSet.ObjectClassName := EmptyStr;

  Assert.WillRaise(
    procedure
    begin
      FDataSet.Open;
    end, EDataSetWithoutClassDefinitionLoaded);
end;

procedure TPersistoDataSetTest.WhenUpdateTheFieldDefsCantRaiseAnyError;
begin
  FDataSet.ObjectClass := TMyEntityWithAllTypeOfFields;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldDefs.Update;
    end);
end;

procedure TPersistoDataSetTest.WhenUseAComposeFieldNameWithALazyFieldCantRaiseAnyError;
begin
  var Field := TWideStringField.Create(FDataSet);
  Field.FieldName := 'Lazy.Name';
  var LazyObject := TMyEntity.Create;
  var MyObject := TLazyArrayClass.Create;
  MyObject.Lazy.LazyValue := TLazyValueMock.Create(LazyObject);

  Field.SetParentComponent(FDataSet);

  FDataSet.Objects := [MyObject];

  FDataSet.Open;

  Assert.WillNotRaise(
    procedure
    begin
      FDataSet.FieldByName('Lazy.Name').AsString;
    end);

  LazyObject.Free;
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

{ TDataLinkMock }

procedure TDataLinkMock.ClearEvents;
begin
  Events.Clear;
end;

constructor TDataLinkMock.Create;
begin
  inherited;

  FEvents := TList<TDataEvent>.Create;
end;

procedure TDataLinkMock.DataEvent(Event: TDataEvent; Info: NativeInt);
begin
  FEvents.Add(Event);
end;

destructor TDataLinkMock.Destroy;
begin
  FEvents.Free;

  inherited;
end;

{ TLazyValueMock }

constructor TLazyValueMock.Create(const LazyObject: TObject);
begin
  FValue := LazyObject;
end;

function TLazyValueMock.GetKey: TValue;
begin
  Result := TValue.Empty;
end;

function TLazyValueMock.GetValue: TValue;
begin
  Result := FValue;
end;

function TLazyValueMock.HasValue: Boolean;
begin
  Result := True;
end;

procedure TLazyValueMock.SetValue(const Value: TValue);
begin
  FValue := Value;
end;

end.

