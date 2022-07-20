unit Delphi.ORM.Shared.Obj.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TSharedObjectTeste = class
  public
    [Test]
    procedure WhenDestroyTheSharedObjectMustDestroyTheInternalObject;
  end;

  [TestFixture]
  TStateObjectTest = class
  public
    [Test]
    procedure WhenCreateAStateObjectMustCreateAnCopyFromTheOriginalObject;
    [Test]
    procedure WhenCreateTheStateObjectToCopyThePropertyMustCopyAllPropertyValues;
    [Test]
    procedure WhenCreateTheStateObjectToDontCopyThePropertiesCantCopyTheValues;
    [Test]
    procedure WhenCopyThePropertiesOfTheObjectMustCopyOnlyWritableProperties;
  end;

  TMyObject = class
  private
    FExpect: PBoolean;
  public
    constructor Create(Expect: PBoolean);

    destructor Destroy; override;
  end;

  TMyClassProperties = class
  private
    FProperty1: Integer;
    FProperty2: String;
    FReadOnlyProp: Double;
  published
    property Property1: Integer read FProperty1 write FProperty1;
    property Property2: String read FProperty2 write FProperty2;
    property ReadOnlyProp: Double read FReadOnlyProp;
  end;

implementation

uses Delphi.ORM.Shared.Obj;

{ TSharedObjectTeste }

procedure TSharedObjectTeste.WhenDestroyTheSharedObjectMustDestroyTheInternalObject;
begin
  var AssertValue := False;
  var SharedObject := TSharedObject.Create(TMyObject.Create(@AssertValue)) as ISharedObject;

  SharedObject := nil;

  Assert.IsTrue(AssertValue);
end;

{ TMyObject }

constructor TMyObject.Create(Expect: PBoolean);
begin
  inherited Create;

  FExpect := Expect;
end;

destructor TMyObject.Destroy;
begin
  FExpect^ := True;

  inherited;
end;

{ TStateObjectTest }

procedure TStateObjectTest.WhenCopyThePropertiesOfTheObjectMustCopyOnlyWritableProperties;
begin
  var StateObject: IStateObject;

  Assert.WillNotRaise(
    procedure
    begin
      StateObject := TStateObject.Create(TMyClassProperties.Create, True) as IStateObject;
    end);

  StateObject := nil;
end;

procedure TStateObjectTest.WhenCreateAStateObjectMustCreateAnCopyFromTheOriginalObject;
begin
  var StateObject := TStateObject.Create(TMyClassProperties.Create, False) as IStateObject;

  Assert.IsNotNull(StateObject.OldObject);

  Assert.AreEqual(TMyClassProperties, StateObject.OldObject.ClassType)
end;

procedure TStateObjectTest.WhenCreateTheStateObjectToCopyThePropertyMustCopyAllPropertyValues;
begin
  var MyClass := TMyClassProperties.Create;
  MyClass.Property1 := 1234;
  MyClass.Property2 := 'abcde';
  var StateObject := TStateObject.Create(MyClass, True) as IStateObject;

  Assert.AreNotSame(MyClass, StateObject.OldObject);

  var OldValue := StateObject.OldObject as TMyClassProperties;

  Assert.AreEqual(MyClass.Property1, OldValue.Property1);

  Assert.AreEqual(MyClass.Property2, OldValue.Property2);
end;

procedure TStateObjectTest.WhenCreateTheStateObjectToDontCopyThePropertiesCantCopyTheValues;
begin
  var MyClass := TMyClassProperties.Create;
  MyClass.Property1 := 1234;
  MyClass.Property2 := 'abcde';
  var StateObject := TStateObject.Create(MyClass, False) as IStateObject;

  Assert.AreNotSame(MyClass, StateObject.OldObject);

  var OldValue := StateObject.OldObject as TMyClassProperties;

  Assert.AreEqual(0, OldValue.Property1);

  Assert.AreEqual('', OldValue.Property2);
end;

end.

