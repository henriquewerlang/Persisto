unit Delphi.ORM.Mapper.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Attributes;

type
  [TestFixture]
  TMapperTeste = class
  private
    FContext: TRttiContext;
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenCallLoadAllMustLoadAllClassesWithTheEntityAttribute;
    [Test]
    procedure WhenTryToFindATableMustReturnTheTableOfTheClass;
    [Test]
    procedure WhenTryToFindATableWithoutTheEntityAttributeMustReturnANilValue;
    [Test]
    procedure WhenLoadATableMustLoadAllFieldsToo;
    [Test]
    procedure WhenTheFieldsAreLoadedMustFillTheNameWithTheNameOfPropertyOfTheClass;
    [Test]
    procedure WhenLoadAClassMustKeepTheOrderingOfTablesToTheFindTableContinueToWorking;
    [Test]
    procedure WhenLoadAFieldMustFillThePropertyWithThePropertyInfo;
    [Test]
    procedure WhenAClassDoesNotHaveThePrimaryKeyAttributeAndHasAnIdFieldThisWillBeThePrimaryKey;
    [Test]
    procedure WhenTheClassHaveThePrimaryKeyAttributeThePrimaryKeyWillBeTheFieldFilled;
    [Test]
    procedure WhenThePrimaryKeyAttributeHasMoreThanOneFieldHasToPutEveryoneOnTheList;
    [Test]
    procedure TheFieldInPrimaryKeyMustBeMarkedWithInPrimaryKey;
    [Test]
    procedure TheDatabaseNameOfATableMustBeTheNameOfClassRemovingTheFirstCharOfTheClassName;
    [Test]
    procedure WhenTheClassHaveTheTableNameAttributeTheDatabaseNameMustBeLikeTheNameInAttribute;
    [Test]
    procedure OnlyPublishedFieldMutsBeLoadedInTheTable;
    [Test]
    procedure WhenTheFieldHaveTheFieldNameAttributeMustLoadThisNameInTheDatabaseName;
  end;

  [Entity]
  TMyEntity = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
    FPublicField: String;
  public
    property PublicField: String read FPublicField write FPublicField;
  published
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  [TableName('AnotherTableName')]
  TMyEntity2 = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
    FAField: Integer;
  published
    property AField: Integer read FAField write FAField;
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TMyEntity3 = class
  private
    FId: Integer;
  published
    property Id: Integer read FId write FId;
  end;

  [Entity]
  [PrimaryKey('Value')]
  TMyEntityWithPrimaryKey = class
  private
    FId: Integer;
    FValue: Double;
  published
    property Id: Integer read FId write FId;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  [PrimaryKey('Value,Id')]
  TMyEntityWithPrimaryKey2 = class
  private
    FId: Integer;
    FValue: Double;
  published
    property Id: Integer read FId write FId;
    property Value: Double read FValue write FValue;
  end;

  TMyEntityWithoutEntityAttribute = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
  published
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TMyEntityWithFieldNameAttribute = class
  private
    FName: String;
  published
    [FieldName('AnotherFieldName')]
    property Name: String read FName write FName;
  end;

implementation

uses Delphi.ORM.Mapper;

{ TMapperTeste }

procedure TMapperTeste.OnlyPublishedFieldMutsBeLoadedInTheTable;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  var Table := Mapper.FindTable(TMyEntity);

  Assert.AreEqual<Integer>(3, Length(Table.Fields));

  Mapper.Free;
end;

procedure TMapperTeste.Setup;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  FContext.GetType(TMyEntity);

  Mapper.Free;
end;

procedure TMapperTeste.TheDatabaseNameOfATableMustBeTheNameOfClassRemovingTheFirstCharOfTheClassName;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity);

  Assert.AreEqual('MyEntity', Table.DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.TheFieldInPrimaryKeyMustBeMarkedWithInPrimaryKey;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity);

  Assert.IsTrue(Table.PrimaryKey[0].InPrimaryKey);

  Mapper.Free;
end;

procedure TMapperTeste.WhenAClassDoesNotHaveThePrimaryKeyAttributeAndHasAnIdFieldThisWillBeThePrimaryKey;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity2);

  Assert.AreEqual<Integer>(1, Length(Table.PrimaryKey));
  Assert.AreEqual('Id', Table.PrimaryKey[0].DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.WhenCallLoadAllMustLoadAllClassesWithTheEntityAttribute;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  Assert.IsTrue(Length(Mapper.Tables) > 0, 'No entities loaded!');

  Mapper.Free;
end;

procedure TMapperTeste.WhenLoadAClassMustKeepTheOrderingOfTablesToTheFindTableContinueToWorking;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadClass(TMyEntity2);

  Mapper.LoadClass(TMyEntity);

  Mapper.LoadClass(TMyEntity3);

  var Table := Mapper.FindTable(TMyEntity);

  Assert.AreSame(FContext.GetType(TMyEntity), Table.TypeInfo);

  Mapper.Free;
end;

procedure TMapperTeste.WhenLoadAFieldMustFillThePropertyWithThePropertyInfo;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity3);
  var TypeInfo := FContext.GetType(TMyEntity3).GetProperties[0];

  Assert.AreEqual<TObject>(TypeInfo, Table.Fields[0].TypeInfo);

  Mapper.Free;
end;

procedure TMapperTeste.WhenLoadATableMustLoadAllFieldsToo;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  var Table := Mapper.FindTable(TMyEntity);

  Assert.AreEqual<Integer>(3, Length(Table.Fields));

  Mapper.Free;
end;

procedure TMapperTeste.WhenTheClassHaveThePrimaryKeyAttributeThePrimaryKeyWillBeTheFieldFilled;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntityWithPrimaryKey);

  Assert.AreEqual('Value', Table.PrimaryKey[0].DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.WhenTheClassHaveTheTableNameAttributeTheDatabaseNameMustBeLikeTheNameInAttribute;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity2);

  Assert.AreEqual('AnotherTableName', Table.DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.WhenTheFieldHaveTheFieldNameAttributeMustLoadThisNameInTheDatabaseName;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  var Table := Mapper.FindTable(TMyEntityWithFieldNameAttribute);

  Assert.AreEqual('AnotherFieldName', Table.Fields[0].DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.WhenTheFieldsAreLoadedMustFillTheNameWithTheNameOfPropertyOfTheClass;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntity3);

  Assert.AreEqual('Id', Table.Fields[0].DatabaseName);

  Mapper.Free;
end;

procedure TMapperTeste.WhenThePrimaryKeyAttributeHasMoreThanOneFieldHasToPutEveryoneOnTheList;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.LoadClass(TMyEntityWithPrimaryKey2);

  Assert.AreEqual<Integer>(2, Length(Table.PrimaryKey));

  Mapper.Free;
end;

procedure TMapperTeste.WhenTryToFindATableMustReturnTheTableOfTheClass;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  var Table := Mapper.LoadClass(TMyEntity3);

  Assert.AreEqual(TMyEntity3, Table.TypeInfo.MetaclassType);

  Mapper.Free;
end;

procedure TMapperTeste.WhenTryToFindATableWithoutTheEntityAttributeMustReturnANilValue;
begin
  var Mapper := TMapper.Create;

  Mapper.LoadAll;

  var Table := Mapper.FindTable(TMyEntityWithoutEntityAttribute);

  Assert.IsNull(Table);

  Mapper.Free;
end;

end.
