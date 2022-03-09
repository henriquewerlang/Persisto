unit Delphi.ORM.Lazy.Test;

interface

uses System.Rtti, DUnitX.TestFramework, Delphi.ORM.Lazy, Delphi.ORM.Cache;

type
  [TestFixture]
  TLazyTest = class
  private
    FContext: TRttiContext;
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure IfTheTypeIsSurroundedWithTheLazyRecordMustReturnTrueInTheFunctionIsLazyLoading;
    [Test]
    procedure WhenCallTheFunctionGetLazyLoadingRttiTypeMustReturnTheInternalType;
    [Test]
    procedure IfTheLazyPropertyIsNotInitializedMustReturnTheDefaultValue;
    [Test]
    procedure WhenFillTheValueMustReturnTheValueFilled;
    [Test]
    procedure WhenCallTheFunctionGetLazyLoadingAccessMustReturnTheInternalInterfaceToAccessTheLazyValue;
    [Test]
    procedure WhenFillTheValueCantCallTheLazyLoaderValue;
    [Test]
    procedure WhenUsingTheImplicitOperatorMustLoadWithTheValueFilled;
    [Test]
    procedure WhenUsingTheIMplicitOperatorToGetTheValueMustTheReturnTheValueExpected;
    [Test]
    procedure WhenGetTheLoadedInTheLazyAcessMustReturnTrueIfIsLoaded;
    [Test]
    procedure WhenTheLazyIsLoadedMustReturnTheInternalValueUsingTheLazyAccess;
    [Test]
    procedure WhenAssignALazyVariableToAnotherMustCopyTheInternalAccess;
    [Test]
    procedure WhenGetValueAndTheLoaderNotExistsMustReturnLoadedAsTrue;
    [Test]
    procedure WhenGetTheAccessPropertyMustReturnTheInternalRttiTypeOfTheLazyValue;
    [Test]
    procedure WhenTheLazyValueHasAKeyMustReturnTrueInTheFunction;
    [Test]
    procedure TheKeyPropertyMustReturnTheKeyValueProperty;
    [Test]
    procedure WhenTheValueIsLoadedTheHasKeyFunctionMustReturnTrue;
    [Test]
    procedure IfTheLazyAccessValueIsEmptyMustReturnTheValueWithTheRttiType;
    [Test]
    procedure WhenTheLazyAccessHasTheKeyLoadedTheHasKeyFunctionMustReturnTrue;
  end;

  [TestFixture]
  TLazyAccessTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenTheKeyIsEmptyTheGetValueMustReturnAEmptyValue;
    [Test]
    procedure WhenFillTheKeyValueMustReturnTheValueFilled;
    [Test]
    procedure WhenFillTheValueMustReturnTheValueLoaded;
    [Test]
    procedure WhenFillTheValueMustMarkTheLoadedAsTrue;
    [Test]
    procedure WhenTheTypeIsntLoadedTheValueMustReturnEmpty;
    [Test]
    procedure IfTheKeyIsEmptyMustReturnAnEmptyValue;
    [Test]
    procedure WhenTheTypeAndKeyIsLoadedAndTheValueIsntLoadedMustLoadTheValueFromTheFactory;
    [Test]
    procedure WhenTheTypeAndKeyIsLoadedAndTheValueIsntLoadedMustMarkTheValueAsLoaded;
    [Test]
    procedure WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
    [Test]
    procedure WhenCallTheLoadFunctionMustReturnTheValueLoaded;
    [Test]
    procedure WhenTheFactoryIsntLoadedAndTheGlobalReferenceIsEmptyTooMustRaiseAnError;
    [Test]
    procedure WhenTheFactoryIsntLoadedMustGetTheGlobalReferenceOfTheFactory;
    [Test]
    procedure WhenTheLazyIsEmptyTheValueMustHaveTheSameTypeInfoOfTheValue;
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Rtti.Helper;

{ TLazyTest }

procedure TLazyTest.IfTheLazyAccessValueIsEmptyMustReturnTheValueWithTheRttiType;
begin
  var Access := TLazyAccess.Create(TRttiContext.Create.GetType(TypeInfo(TMyEntity))) as ILazyAccess;

  Assert.AreEqual<Pointer>(TypeInfo(TMyEntity), Access.Value.TypeInfo);

  Access := nil;
end;

procedure TLazyTest.IfTheLazyPropertyIsNotInitializedMustReturnTheDefaultValue;
begin
  var Lazy: Lazy<TMyEntity>;

  Assert.AreEqual<TMyEntity>(nil, Lazy.Value);
end;

procedure TLazyTest.IfTheTypeIsSurroundedWithTheLazyRecordMustReturnTrueInTheFunctionIsLazyLoading;
begin
  var RttiType := TRttiContext.Create.GetType(TypeInfo(Lazy<TMyEntity>));

  Assert.IsTrue(IsLazyLoading(RttiType))
end;

procedure TLazyTest.Setup;
begin
  FContext := TRttiContext.Create;
  FContext.GetType(TypeInfo(Lazy<TMyEntity>)).GetMethod('GetValue');

  TMock.CreateInterface<ILazyAccess>;
end;

procedure TLazyTest.TheKeyPropertyMustReturnTheKeyValueProperty;
begin
  var Lazy: Lazy<TMyEntity>;

  Lazy.Access.Key := 'abc';

  Assert.AreEqual('abc', Lazy.Key.AsString);
end;

procedure TLazyTest.WhenAssignALazyVariableToAnotherMustCopyTheInternalAccess;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual(TheValue, Lazy.Value);

  TheValue.Free;
end;

procedure TLazyTest.WhenCallTheFunctionGetLazyLoadingAccessMustReturnTheInternalInterfaceToAccessTheLazyValue;
begin
  var Lazy: Lazy<TMyEntity>;

  var Access := GetLazyLoadingAccess(TValue.From(Lazy));

  Assert.AreNotEqual<ILazyAccess>(nil, Access);
end;

procedure TLazyTest.WhenCallTheFunctionGetLazyLoadingRttiTypeMustReturnTheInternalType;
begin
  var RttiType := TRttiContext.Create.GetType(TMyEntity);

  Assert.AreEqual(RttiType, GetLazyLoadingRttiType(TRttiContext.Create.GetType(TypeInfo(Lazy<TMyEntity>))));
end;

procedure TLazyTest.WhenFillTheValueCantCallTheLazyLoaderValue;
begin
  var Lazy: Lazy<TMyEntity>;
  var Factory := TMock.CreateInterface<ILazyFactory>(True);
  var TheValue := TMyEntity.Create;

  Factory.Expect.Never.When.Load(It.IsAny<TRttiType>, It.IsAny<TValue>);

  TLazyAccess.GlobalFactory := Factory.Instance;

  Lazy.Value := TheValue;

  Lazy.Value;

  Lazy.Value;

  Lazy.Value;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);

  TheValue.Free;
end;

procedure TLazyTest.WhenFillTheValueMustReturnTheValueFilled;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy.Value := TheValue;

  Assert.AreEqual(TheValue, Lazy.Value);

  TheValue.Free;
end;

procedure TLazyTest.WhenGetTheAccessPropertyMustReturnTheInternalRttiTypeOfTheLazyValue;
begin
  var Lazy: Lazy<TMyEntity>;

  Assert.AreEqual(GetRttiType(TMyEntity), Lazy.Access.RttiType)
end;

procedure TLazyTest.WhenGetTheLoadedInTheLazyAcessMustReturnTrueIfIsLoaded;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy.Value := TheValue;

  Assert.IsTrue(GetLazyLoadingAccess(TValue.From(Lazy)).HasValue);

  TheValue.Free;
end;

procedure TLazyTest.WhenGetValueAndTheLoaderNotExistsMustReturnLoadedAsTrue;
begin
  var Lazy: Lazy<TMyEntity>;

  Lazy.Value;

  Assert.IsTrue(Lazy.Access.HasValue);
end;

procedure TLazyTest.WhenTheLazyAccessHasTheKeyLoadedTheHasKeyFunctionMustReturnTrue;
begin
  var Access := TLazyAccess.Create(nil) as ILazyAccess;

  Access.Key := 'abc';

  Assert.IsTrue(Access.HasKey);

  Access := nil;
end;

procedure TLazyTest.WhenTheLazyIsLoadedMustReturnTheInternalValueUsingTheLazyAccess;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual<TObject>(TheValue, GetLazyLoadingAccess(TValue.From(Lazy)).GetValue.AsObject);

  TheValue.Free;
end;

procedure TLazyTest.WhenTheLazyValueHasAKeyMustReturnTrueInTheFunction;
begin
  var Lazy: Lazy<TMyEntity>;

  Lazy.Access.Key := 'abc';

  Assert.IsTrue(Lazy.HasKey);
end;

procedure TLazyTest.WhenTheValueIsLoadedTheHasKeyFunctionMustReturnTrue;
begin
  var MyEntity := TMyEntity.Create;
  var Lazy: Lazy<TMyEntity>;

  Lazy.Access.Value := MyEntity;

  Assert.IsTrue(Lazy.HasKey);

  MyEntity.Free;
end;

procedure TLazyTest.WhenUsingTheImplicitOperatorMustLoadWithTheValueFilled;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual(TheValue, Lazy.Value);

  TheValue.Free;
end;

procedure TLazyTest.WhenUsingTheIMplicitOperatorToGetTheValueMustTheReturnTheValueExpected;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual<TMyEntity>(TheValue, Lazy);

  TheValue.Free;
end;

{ TLazyAccessTest }

procedure TLazyAccessTest.IfTheKeyIsEmptyMustReturnAnEmptyValue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.AreEqual(TValue.From<TMyEntity>(nil), LazyAccess.Value);
end;

procedure TLazyAccessTest.Setup;
begin
  TMock.CreateInterface<ILazyFactory>;

  GetRttiType(TMyEntity);
end;

procedure TLazyAccessTest.WhenFillTheKeyValueMustReturnTheValueFilled;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  LazyAccess.Key := 1234;

  Assert.AreEqual(1234, LazyAccess.Key.AsInteger)
end;

procedure TLazyAccessTest.WhenFillTheValueMustMarkTheLoadedAsTrue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  LazyAccess.Value := 'abc';

  Assert.IsTrue(LazyAccess.HasValue);
end;

procedure TLazyAccessTest.WhenFillTheValueMustReturnTheValueLoaded;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  LazyAccess.Value := 'abc';

  Assert.AreEqual('abc', LazyAccess.Value.AsString);
end;

procedure TLazyAccessTest.WhenCallTheLoadFunctionMustReturnTheValueLoaded;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Factory := Factory.Instance;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Setup.WillReturn(5555).When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  Assert.AreEqual(5555, LazyLoaderIntf.Value.AsInteger);
end;

procedure TLazyAccessTest.WhenTheFactoryIsntLoadedAndTheGlobalReferenceIsEmptyTooMustRaiseAnError;
begin
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.GlobalFactory := nil;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Assert.WillRaise(
    procedure
    begin
      LazyLoaderIntf.GetValue;
    end, ELazyFactoryNotLoaded);
end;

procedure TLazyAccessTest.WhenTheFactoryIsntLoadedMustGetTheGlobalReferenceOfTheFactory;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.GlobalFactory := Factory.Instance;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Expect.Once.When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  LazyLoaderIntf.GetValue;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);

  LazyAccess.GlobalFactory := nil;
end;

procedure TLazyAccessTest.WhenTheKeyIsEmptyTheGetValueMustReturnAEmptyValue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.IsTrue(LazyAccess.Value.IsEmpty)
end;

procedure TLazyAccessTest.WhenTheLazyIsEmptyTheValueMustHaveTheSameTypeInfoOfTheValue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.AreEqual<Pointer>(TypeInfo(TMyEntity), LazyAccess.Value.TypeInfo);
end;

procedure TLazyAccessTest.WhenTheTypeAndKeyIsLoadedAndTheValueIsntLoadedMustLoadTheValueFromTheFactory;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Key := 1234;
  TLazyAccess.GlobalFactory := Factory.Instance;
  var TheValue := TMyEntity.Create;

  Factory.Setup.WillReturn(TheValue).When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  Factory.Expect.Once.When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  LazyAccess.Value;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);

  TheValue.Free;

  TLazyAccess.GlobalFactory := nil;
end;

procedure TLazyAccessTest.WhenTheTypeAndKeyIsLoadedAndTheValueIsntLoadedMustMarkTheValueAsLoaded;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Key := 1234;
  TLazyAccess.GlobalFactory := Factory.Instance;
  var TheValue := TMyEntity.Create;

  Factory.Setup.WillReturn(TheValue).When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  LazyAccess.Value;

  Assert.IsTrue(LazyAccess.HasValue);

  TheValue.Free;

  TLazyAccess.GlobalFactory := nil;
end;

procedure TLazyAccessTest.WhenTheTypeIsntLoadedTheValueMustReturnEmpty;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.AreEqual(TValue.From<TMyEntity>(nil), LazyAccess.Value);
end;

procedure TLazyAccessTest.WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Key := 1234;
  LazyAccess.Factory := Factory.Instance;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Expect.Once.When.Load(It(0).IsAny<TRttiType>, It(1).IsAny<TValue>);

  LazyLoaderIntf.GetValue;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);
end;

end.


