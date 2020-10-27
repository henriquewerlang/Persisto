unit Delphi.ORM.Query.Builder.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Database.Connection;

type
  [TestFixture]
  TDelphiORMQueryBuilderTest = class
  public
    [Test]
    procedure IfNoCommandCalledTheSQLMustReturnEmpty;
    [Test]
    procedure WhenCallSelectCommandTheSQLMustReturnTheWordSelect;
    [Test]
    procedure IfNoCommandIsCalledCantRaiseAnExceptionOfAccessViolation;
    [Test]
    procedure WhenCallUpdateCommandMustReturnTheUpdateCommandSQL;
    [Test]
    procedure WhenCallInsertCommandMustReturnTheInsertCommandSQL;
    [Test]
    procedure WhenCallDeleteCommandMustReturnTheDeleteCommandSQL;
    [Test]
    procedure WhenSelectAllFieldsFromAClassMustPutAllThenInTheResultingSQL;
    [Test]
    procedure IfTheAllFieldNoCalledCantRaiseAnExceptionOfAccessViolation;
    [Test]
    procedure OnlyPublishedPropertiesCanAppearInSQL;
    [Test]
    procedure WhenCallOpenProcedureMustOpenTheDatabaseCursor;
    [Test]
    procedure WhenOpenOneMustFillTheClassWithTheValuesOfCursor;
  end;

  TMyTestClass = class
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

  TDatabase = class(TInterfacedObject, IDatabaseConnection)
  private
    FCursor: IDatabaseCursor;
    FCursorSQL: String;

    function OpenCursor(SQL: String): IDatabaseCursor;
  public
    constructor Create(Cursor: IDatabaseCursor);

    property CursorSQL: String read FCursorSQL write FCursorSQL;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Query.Builder, Delphi.Mock;

{ TDelphiORMQueryBuilderTest }

procedure TDelphiORMQueryBuilderTest.IfNoCommandCalledTheSQLMustReturnEmpty;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.AreEqual(EmptyStr, Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfNoCommandIsCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Assert.WillNotRaise(
    procedure
    begin
      Query.Build
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.IfTheAllFieldNoCalledCantRaiseAnExceptionOfAccessViolation;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.WillNotRaise(
    procedure
    begin
      Query.Build;
    end, EAccessViolation);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.OnlyPublishedPropertiesCanAppearInSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select Id F1,Name F2,Value F3 from MyTestClass', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallDeleteCommandMustReturnTheDeleteCommandSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Delete;

  Assert.AreEqual('delete ', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallInsertCommandMustReturnTheInsertCommandSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Insert;

  Assert.AreEqual('insert ', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallOpenProcedureMustOpenTheDatabaseCursor;
begin
  var Database := TDatabase.Create(nil);
  var Query := TQueryBuilder.Create(Database);

  Query.Select.All.From<TMyTestClass>.Open;

  Assert.AreEqual('select Id F1,Name F2,Value F3 from MyTestClass', Database.CursorSQL);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallSelectCommandTheSQLMustReturnTheWordSelect;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select;

  Assert.AreEqual('select ', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenCallUpdateCommandMustReturnTheUpdateCommandSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Update;

  Assert.AreEqual('update ', Query.Build);

  Query.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenOpenOneMustFillTheClassWithTheValuesOfCursor;
begin
  var Cursor := TMock.CreateInterface<IDatabaseCursor>;
  var Database := TDatabase.Create(Cursor.Instance);
  var Query := TQueryBuilder.Create(Database);

  Cursor.Setup.WillReturn(123).When.GetFieldValue(It.IsEqualTo('F1'));

  Cursor.Setup.WillReturn('My name').When.GetFieldValue(It.IsEqualTo('F2'));

  Cursor.Setup.WillReturn(123.456).When.GetFieldValue(It.IsEqualTo('F3'));

  var Result := Query.Select.All.From<TMyTestClass>.Open.One;

  Assert.AreEqual(123, Result.Id);

  Assert.AreEqual('My name', Result.Name);

  Assert.AreEqual(123.456, Result.Value);

  Query.Free;

  Result.Free;
end;

procedure TDelphiORMQueryBuilderTest.WhenSelectAllFieldsFromAClassMustPutAllThenInTheResultingSQL;
begin
  var Query := TQueryBuilder.Create(nil);

  Query.Select.All.From<TMyTestClass>;

  Assert.AreEqual('select Id F1,Name F2,Value F3 from MyTestClass', Query.Build);

  Query.Free;
end;

{ TDatabase }

constructor TDatabase.Create(Cursor: IDatabaseCursor);
begin
  inherited Create;

  FCursor := Cursor;
end;

function TDatabase.OpenCursor(SQL: String): IDatabaseCursor;
begin
  CursorSQL := SQL;
  Result := FCursor;
end;

end.

