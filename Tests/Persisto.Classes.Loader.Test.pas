unit Persisto.Classes.Loader.Test;

interface

uses DUnitX.TestFramework, Persisto;

type
  [TestFixture]
  TClassLoaderTest = class
  private
    FManager: TManager;

    procedure InsertDatabaseData(const Connection: IDatabaseConnection);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenSelectToOpenAnObjectFromDatabaseCantRaiseAnyError;
    [Test]
    procedure WhenLoadAnObjectMustCreateItWhenLoadFromDatabase;
    [Test]
    procedure WhenLoadAnObjectMustLoadTheFieldsOfTheObjectWithTheValueInTheDatabase;
    [Test]
    procedure WhenLoadAnObjectInheritedFromAnotherMustLoadTheFieldValueOfAllClassLevel;
  end;

implementation

uses System.Generics.Collections, Persisto.Test.Connection, Persisto.Test.Entity;

{ TClassLoaderTest }

procedure TClassLoaderTest.InsertDatabaseData(const Connection: IDatabaseConnection);
var
  Manager: TManager;

  Objects: TArray<TObject>;

  procedure UpdateDatabase;
  begin
    for var AObject in Objects do
      Manager.Mapper.GetTable(AObject.ClassType);

    Manager.UpdateDatabaseSchema;

    for var AObject in Objects do
      Manager.Insert(AObject);
  end;

  procedure InsertObjects;
  begin
    var Object1 := TClassWithPrimaryKey.Create;
    Object1.Value := 1;

    var Object2 := TMyEntityInheritedFromSimpleClass.Create;
    Object2.AnotherProperty := 'abc';
    Object2.BaseProperty := 'def';
    Object2.SimpleProperty := 111;

    Objects := [Object1, Object2];
  end;

begin
  Manager := TManager.Create(Connection, CreateDialect);
  Objects := nil;

  InsertObjects;

  UpdateDatabase;
end;

procedure TClassLoaderTest.Setup;
begin
  var Connection := CreateConnection;
  FManager := TManager.Create(Connection, CreateDialect);

  InsertDatabaseData(Connection);
end;

procedure TClassLoaderTest.TearDown;
begin
  FManager.Free;
end;

procedure TClassLoaderTest.WhenLoadAnObjectInheritedFromAnotherMustLoadTheFieldValueOfAllClassLevel;
begin
  var AObject := FManager.Select.All.From<TMyEntityInheritedFromSimpleClass>.Open.One;

  Assert.AreEqual('abc', AObject.AnotherProperty);
  Assert.AreEqual('def', AObject.BaseProperty);
  Assert.AreEqual(111, AObject.SimpleProperty);
  Assert.AreEqual(10, AObject.Id);
end;

procedure TClassLoaderTest.WhenLoadAnObjectMustCreateItWhenLoadFromDatabase;
begin
  var AObject := FManager.Select.All.From<TClassWithPrimaryKey>.Open.One;

  Assert.IsNotNull(AObject);
end;

procedure TClassLoaderTest.WhenLoadAnObjectMustLoadTheFieldsOfTheObjectWithTheValueInTheDatabase;
begin
  var AObject := FManager.Select.All.From<TClassWithPrimaryKey>.Open.One;

  Assert.AreEqual(35, AObject.Id);
  Assert.AreEqual(1, AObject.Value);
end;

procedure TClassLoaderTest.WhenSelectToOpenAnObjectFromDatabaseCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
        FManager.Select.All.From<TClassWithPrimaryKey>.Open;
    end);
end;

end.

