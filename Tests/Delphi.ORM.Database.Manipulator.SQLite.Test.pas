unit Delphi.ORM.Database.Manipulator.SQLite.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Database.Metadata, Delphi.ORM.Database.Connection, Delphi.ORM.Database.Manipulator.SQLite, Delphi.ORM.Attributes;

type
  [TestFixture]
  TManipulatorSQLiteTest = class
  private
    FMetadataManipulator: TManipulatorSQLite;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [TestCase('Bigint', 'tkInt64,bigint')]
    [TestCase('Char', 'tkWChar,char')]
    [TestCase('Enumerator', 'tkEnumeration,tinyint')]
    [TestCase('Int', 'tkInteger,int')]
    [TestCase('Numeric', 'tkFloat,numeric')]
    [TestCase('Varchar', 'tkUString,varchar')]
    procedure TheFieldTypeFunctionMustReturnTheTypeHasExpected(const FieldType: TTypeKind; const FieldTypeComparision: String);
    [TestCase('Date', 'stDate,date')]
    [TestCase('DateTime', 'stDateTime,datetime')]
    [TestCase('Time', 'stTime,time')]
    [TestCase('Text', 'stText,text')]
    [TestCase('Boolean', 'stBoolean,bit')]
    [TestCase('Unique Identifier', 'stUniqueIdentifier,unique')]
    procedure TheSpecialFieldTypeFunctionMustReturnTheTypeHasExpected(const SpecialType: TDatabaseSpecialType; const SpecialTypeComparision: String);
  end;

implementation

uses System.SysUtils, System.Rtti, Delphi.ORM.Mapper;

{ TManipulatorSQLiteTest }

procedure TManipulatorSQLiteTest.Setup;
begin
  FMetadataManipulator := TManipulatorSQLite.Create(nil);
end;

procedure TManipulatorSQLiteTest.TearDown;
begin
  FMetadataManipulator.Free;
end;

procedure TManipulatorSQLiteTest.TheFieldTypeFunctionMustReturnTheTypeHasExpected(const FieldType: TTypeKind; const FieldTypeComparision: String);
begin
  var Context := TRttiContext.Create;
  var Field := TField.Create(nil);
  var Manipulator := TManipulatorSQLite.Create(nil);

  case FieldType of
    tkEnumeration: Field.FieldType := Context.GetType(TypeInfo(TDatabaseSpecialType));
    tkFloat: Field.FieldType := Context.GetType(TypeInfo(Double));
    tkInteger: Field.FieldType := Context.GetType(TypeInfo(Integer));
    tkInt64: Field.FieldType := Context.GetType(TypeInfo(Int64));
    tkUString: Field.FieldType := Context.GetType(TypeInfo(String));
    tkWChar: Field.FieldType := Context.GetType(TypeInfo(Char));
    else raise Exception.Create('Type not mapped!');
  end;

  Assert.AreEqual(FieldTypeComparision, Manipulator.GetFieldType(Field));

  Context.Free;

  Field.Free;

  Manipulator.Free;
end;

procedure TManipulatorSQLiteTest.TheSpecialFieldTypeFunctionMustReturnTheTypeHasExpected(const SpecialType: TDatabaseSpecialType; const SpecialTypeComparision: String);
begin
  var Field := TField.Create(nil);
  Field.SpecialType := SpecialType;
  var Manipulator := TManipulatorSQLite.Create(nil);

  Assert.AreEqual(SpecialTypeComparision, Manipulator.GetSpecialFieldType(Field));

  Field.Free;

  Manipulator.Free;
end;

end.

