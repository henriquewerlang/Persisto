unit Delphi.ORM.Classes.Loader.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Database.Connection;

type
  [TestFixture]
  TClassLoaderTest = class
  public
    // Tem que carregar os dados a partir de uma lista de campos, que vieram do QueryBuilder
    // Carregar uma class simples, sem as depedências
    [Test]
    procedure MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
  end;

  TMyClass = class
  private
    FName: String;
    FValue: Integer;
  published
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

implementation

uses System.Rtti, System.Generics.Collections, Delphi.ORM.Classes.Loader, Delphi.Mock;

{ TClassLoaderTest }

procedure TClassLoaderTest.MustLoadThePropertiesOfTheClassWithTheValuesOfCursor;
begin
  var Cursor := TMock.CreateInterface<IDatabaseCursor>;
  var Loader := TClassLoader.Create;
  var Mapper := TMock.CreateInterface<IFieldXPropertyMapping>;
  var MyClassType := TRttiContext.Create.GetType(TMyClass);

  Mapper.Setup.WillReturn(TValue.FromArray(TypeInfo(TArray<TFieldMapPair>),
    [TValue.From(TFieldMapPair.Create(MyClassType.GetProperty('Name'), 'Name')),
      TValue.From(TFieldMapPair.Create(MyClassType.GetProperty('Value'), 'Value'))])).When.GetProperties;

  Cursor.Setup.WillReturn('abc').When.GetFieldValue(It.IsEqualTo('Name'));
  Cursor.Setup.WillReturn(123).When.GetFieldValue(It.IsEqualTo('Value'));

  var MyClass := Loader.Load<TMyClass>(Cursor.Instance, Mapper.Instance);

  Assert.AreEqual('abc', MyClass.Name);
  Assert.AreEqual(123, MyClass.Value);

  MyClass.Free;

  Loader.Free;
end;

initialization
  // Avoid leak reporting
  TRttiContext.Create.GetType(TMyClass).GetProperties;
  TMock.CreateInterface<IDatabaseCursor>;
  TMock.CreateInterface<IFieldXPropertyMapping>;

end.
