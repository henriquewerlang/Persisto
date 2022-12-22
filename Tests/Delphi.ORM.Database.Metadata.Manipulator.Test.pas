unit Delphi.ORM.Database.Metadata.Manipulator.Test;

interface

uses System.Rtti, System.Generics.Collections, DUnitX.TestFramework, Delphi.Mock.Intf, Delphi.ORM.Database.Metadata.Manipulator, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper,
  Delphi.ORM.Database.Connection;

type
  TMetadataManipulatorMock = class;

  [TestFixture]
  TMetadataManipulatorTest = class
  private
    FConnection: IMock<IDatabaseConnection>;
    FContext: TRttiContext;
    FDatabaseField: TDatabaseField;
    FDatabaseSchema: TDatabaseSchema;
    FDatabaseTable: TDatabaseTable;
    FField: TField;
    FMetadataManipulator: IMetadataManipulator;
    FMetadataManipulatorClass: TMetadataManipulatorMock;
    FSQLExecuted: String;
    FTable: TTable;
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TheFieldDefinitionMustBuildTheSQLHasExpected;
    [Test]
    procedure IfTheFieldIsNullableMustBuildTheSQLHasExpected;
    [Test]
    procedure IfTheFieldHasASpecialTypeMustLoadThisTypeInTheSQL;
    [Test]
    procedure IfTheFieldHasCollationMustLoadTheCollationOfTheField;
    [Test]
    procedure TheFieldDefinitionMustLoadTheSQLWithTheDatabaseNameFieldName;
    [Test]
    procedure WhenTheFieldTypeIsStringMustLoadTheSizeInTheFieldDefinition;
    [Test]
    procedure WhenTheFieldTypeIsCharMustLoadTheSizeInTheFieldDefinition;
    [Test]
    procedure WhenTheFieldIsAndFloatFieldMustLoadThePrecisionAndScaleInTheFieldDefinition;
    [Test]
    procedure IfTheFieldIsASpecialTypeCantLoadTheSizeOfTheField;
    [Test]
    procedure WhenTheFieldHasDefaultValueMustLoadTheDefaultValueHasExpected;
    [Test]
    procedure IfTheFieldHasADefaultFunctionMustLoadTheSQLHasExpected;
    [Test]
    procedure WhenCreateTheTableMustBuildTheSQLHasExpected;
    [Test]
    procedure WhenCreateAFieldMustBuildTheSQLHasExpected;
    [Test]
    procedure WhenDropAFieldMustExecuteTheSQLHasExpected;
    [Test]
    procedure WhenDropATableMustExecuteTheSQLHasExpected;
    [Test]
    procedure WhenUpdateAFieldMustExecuteTheSQLHasExpected;
    [Test]
    procedure WhenDropADefaultConstratintMustExecuteTheSQLHasExpected;
    [Test]
    procedure WhenGetTheNameOfDefaultContraintFunctionMustReturnTheNameAsExpected;
  end;

  TMetadataManipulatorMock = class(TMetadataManipulator, IMetadataManipulator)
  private
    procedure LoadSchema(const Schema: TDatabaseSchema);
  public
    function GetFieldType(const Field: TField): String; override;
    function GetInternalFunction(const Field: TField): String; override;
    function GetSpecialFieldType(const Field: TField): String; override;
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Attributes;

{ TMetadataManipulatorTest }

procedure TMetadataManipulatorTest.IfTheFieldHasADefaultFunctionMustLoadTheSQLHasExpected;
begin
  FField.DefaultInternalFunction := difNow;

  Assert.AreEqual('MyFieldDB FieldType not null constraint DF_MyTable_MyFieldDB default(InternalFunction())', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.IfTheFieldHasASpecialTypeMustLoadThisTypeInTheSQL;
begin
  FField.SpecialType := stDateTime;

  Assert.AreEqual('MyFieldDB SpecialFieldType not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.IfTheFieldHasCollationMustLoadTheCollationOfTheField;
begin
  FField.Collation := 'MyCollate';

  Assert.AreEqual('MyFieldDB FieldType not null collate MyCollate', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.IfTheFieldIsASpecialTypeCantLoadTheSizeOfTheField;
begin
  FField.FieldType := FContext.GetType(TypeInfo(Double));
  FField.Scale := 5;
  FField.Size := 10;
  FField.SpecialType := stDate;

  Assert.AreEqual('MyFieldDB SpecialFieldType not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.IfTheFieldIsNullableMustBuildTheSQLHasExpected;
begin
  FField.Required := False;

  Assert.AreEqual('MyFieldDB FieldType null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.Setup;
begin
  FConnection := TMock.CreateInterface<IDatabaseConnection>(True);
  FContext := TRttiContext.Create;
  FDatabaseSchema := TDatabaseSchema.Create;
  FDatabaseTable := TDatabaseTable.Create(FDatabaseSchema, 'MyTableDB');
  FField := TField.Create;
  FField.DatabaseName := 'MyFieldDB';
  FField.Name := 'MyField';
  FField.FieldType := FContext.GetType(TypeInfo(Integer));
  FField.Required := True;
  FMetadataManipulatorClass := TMetadataManipulatorMock.Create(FConnection.Instance);
  FSQLExecuted := EmptyStr;
  FTable := TTable.Create(nil);
  FTable.Fields := [FField];
  FTable.DatabaseName := 'MyTableDB';
  FTable.Name := 'MyTable';

  FDatabaseField := TDatabaseField.Create(FDatabaseTable, 'MyFieldDB');
  FField.Table := FTable;
  FMetadataManipulator := FMetadataManipulatorClass;

  FConnection.Setup.WillExecute(
    procedure (const Params: TArray<TValue>)
    begin
      FSQLExecuted := Params[1].AsString;
    end).When.ExecuteDirect(It.IsAny<String>);
end;

procedure TMetadataManipulatorTest.SetupFixture;
begin
  Setup;

  TearDown;
end;

procedure TMetadataManipulatorTest.TearDown;
begin
  FConnection := nil;
  FMetadataManipulator := nil;
  FSQLExecuted := EmptyStr;

  FDatabaseSchema.Free;

  FContext.Free;

  FTable.Free;
end;

procedure TMetadataManipulatorTest.TheFieldDefinitionMustBuildTheSQLHasExpected;
begin
  Assert.AreEqual('MyFieldDB FieldType not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.TheFieldDefinitionMustLoadTheSQLWithTheDatabaseNameFieldName;
begin
  FField.DatabaseName := 'IdMyField';
  FField.Name := 'MyField';

  Assert.AreEqual('IdMyField FieldType not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.WhenCreateAFieldMustBuildTheSQLHasExpected;
begin
  var SQL := 'alter table MyTableDB add MyFieldDB FieldType not null';

  FMetadataManipulator.CreateField(FField);

  Assert.AreEqual(SQL, FSQLExecuted);
end;

procedure TMetadataManipulatorTest.WhenCreateTheTableMustBuildTheSQLHasExpected;
begin
  var AnotherField := TField.Create;
  AnotherField.DatabaseName := 'AnotherField';
  AnotherField.FieldType := FField.FieldType;
  AnotherField.Required := True;
  FTable.Fields := [FField, AnotherField];
  var SQL :=
    'create table MyTableDB (' +
      'MyFieldDB FieldType not null,' +
      'AnotherField FieldType not null)';

  FMetadataManipulator.CreateTable(FTable);

  Assert.AreEqual(SQL, FSQLExecuted);
end;

procedure TMetadataManipulatorTest.WhenDropADefaultConstratintMustExecuteTheSQLHasExpected;
begin
  var SQL := 'alter table MyTableDB drop constraint MyConstraint';

  TDatabaseDefaultConstraint.Create(FDatabaseField, 'MyConstraint', 'MyValue');

  FMetadataManipulator.DropDefaultConstraint(FDatabaseField);

  Assert.AreEqual(SQL, FSQLExecuted);
end;

procedure TMetadataManipulatorTest.WhenDropAFieldMustExecuteTheSQLHasExpected;
begin
  var SQL := 'alter table MyTableDB drop column MyFieldDB';

  FMetadataManipulatorClass.DropField(FDatabaseField);

  Assert.AreEqual(SQL, FSQLExecuted);
end;

procedure TMetadataManipulatorTest.WhenDropATableMustExecuteTheSQLHasExpected;
begin
  var SQL := 'drop table MyTableDB';

  FMetadataManipulatorClass.DropTable(FDatabaseTable);

  Assert.AreEqual(SQL, FSQLExecuted);
end;

procedure TMetadataManipulatorTest.WhenGetTheNameOfDefaultContraintFunctionMustReturnTheNameAsExpected;
begin
  Assert.AreEqual('DF_MyTable_MyFieldDB', FMetadataManipulator.GetDefaultConstraintName(FField));
end;

procedure TMetadataManipulatorTest.WhenTheFieldHasDefaultValueMustLoadTheDefaultValueHasExpected;
begin
  FField.DefaultValue := 'abc';
  FField.FieldType := FContext.GetType(TypeInfo(String));
  FField.Size := 25;

  Assert.AreEqual('MyFieldDB FieldType(25) not null constraint DF_MyTable_MyFieldDB default(''abc'')', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.WhenTheFieldIsAndFloatFieldMustLoadThePrecisionAndScaleInTheFieldDefinition;
begin
  FField.FieldType := FContext.GetType(TypeInfo(Double));
  FField.Scale := 5;
  FField.Size := 10;

  Assert.AreEqual('MyFieldDB FieldType(10,5) not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.WhenTheFieldTypeIsCharMustLoadTheSizeInTheFieldDefinition;
begin
  FField.FieldType := FContext.GetType(TypeInfo(Char));
  FField.Size := 1;

  Assert.AreEqual('MyFieldDB FieldType(1) not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.WhenTheFieldTypeIsStringMustLoadTheSizeInTheFieldDefinition;
begin
  FField.FieldType := FContext.GetType(TypeInfo(String));
  FField.Size := 250;

  Assert.AreEqual('MyFieldDB FieldType(250) not null', FMetadataManipulatorClass.GetFieldDefinition(FField));
end;

procedure TMetadataManipulatorTest.WhenUpdateAFieldMustExecuteTheSQLHasExpected;
begin
  var AnotherField := TField.Create;
  AnotherField.DatabaseName := 'AnotherFieldDB';
  var SQL := 'update MyTableDB set AnotherFieldDB = MyFieldDB';

  FMetadataManipulatorClass.UpdateField(FField, AnotherField);

  Assert.AreEqual(SQL, FSQLExecuted);

  AnotherField.Free;
end;

{ TMetadataManipulatorMock }

function TMetadataManipulatorMock.GetFieldType(const Field: TField): String;
begin
  Result := 'FieldType';
end;

function TMetadataManipulatorMock.GetInternalFunction(const Field: TField): String;
begin
  Result := 'InternalFunction()';
end;

function TMetadataManipulatorMock.GetSpecialFieldType(const Field: TField): String;
begin
  Result := 'SpecialFieldType';
end;

procedure TMetadataManipulatorMock.LoadSchema(const Schema: TDatabaseSchema);
begin

end;

end.

