unit Delphi.ORM.Attributes.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TPrimaryKeyAttributeTest = class
  public
    [Test]
    procedure TheFieldsPropertyMustReturnAllFieldsInTheStringInTheConstructor;
    [Test]
    procedure TheFieldsPassedInConstructorMustReturnInTheListOfFields;
    [Test]
    procedure MustRemoveAllWhiteSpaceFromFieldNames;
  end;

implementation

uses Delphi.ORM.Attributes;

{ TPrimaryKeyAttributeTest }

procedure TPrimaryKeyAttributeTest.MustRemoveAllWhiteSpaceFromFieldNames;
begin
  var Attribute := PrimaryKeyAttribute.Create(' F1 ,F2  ,F3 ');

  Assert.AreEqual('F1', Attribute.Fields[0]);
  Assert.AreEqual('F2', Attribute.Fields[1]);
  Assert.AreEqual('F3', Attribute.Fields[2]);

  Attribute.Free;
end;

procedure TPrimaryKeyAttributeTest.TheFieldsPassedInConstructorMustReturnInTheListOfFields;
begin
  var Attribute := PrimaryKeyAttribute.Create('F1,F2,F3');

  Assert.AreEqual('F1', Attribute.Fields[0]);
  Assert.AreEqual('F2', Attribute.Fields[1]);
  Assert.AreEqual('F3', Attribute.Fields[2]);

  Attribute.Free;
end;

procedure TPrimaryKeyAttributeTest.TheFieldsPropertyMustReturnAllFieldsInTheStringInTheConstructor;
begin
  var Attribute := PrimaryKeyAttribute.Create('F1,F2,F3');

  Assert.AreEqual<Integer>(3, Length(Attribute.Fields));

  Attribute.Free;
end;

end.
