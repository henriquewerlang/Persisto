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
    procedure WhenTheKeyIsFilledMustTryToGetTheValueFromCache;
    [Test]
    procedure WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
    [Test]
    procedure WhenCallTheLoadFunctionMustReturnTheValueLoaded;
    [Test]
    procedure WhenTheFactoryIsntLoadedAndTheGlobalReferenceIsEmptyTooMustRaiseAnError;
    [Test]
    procedure WhenTheFactoryIsntLoadedMustGetTheGlobalReferenceOfTheFactory;
    [Test]
    procedure WhenTheValueIsInTheCacheMustReturnLoadedAsTrue;
    [Test]
    procedure WhenTheKeyIsEmptyMustReturnThePropertyLoadedAsTrue;
    [Test]
    procedure WhenTheLazyIsEmptyTheValueMustHaveTheSameTypeInfoOfTheValue;
  end;

  TCacheMock = class(TInterfacedObject, ICache)
  private
    FMethodCalled: String;
    FGetReturnValue: TValue;
  public
    constructor Create(GetReturnValue: TValue);

    function Get(RttiType: TRttiType; const PrimaryKey: TValue; var Value: TValue): Boolean;

    procedure Add(RttiType: TRttiType; const PrimaryKey, Value: TValue);

    property MethodCalled: String read FMethodCalled write FMethodCalled;
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Test.Entity, Delphi.ORM.Rtti.Helper;

{ TLazyTest }

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
  var LazyAccess := TMock.CreateInterface<ILazyAccess>;
  var TheValue := TMyEntity.Create;

  LazyAccess.Expect.Never.When.GetValue;

//  GetLazyLoadingAccess(TValue.From(Lazy)).SetLazyLoader(LazyAccess.Instance);

  Lazy.Value := TheValue;

  Lazy.Value;

  Lazy.Value;

  Lazy.Value;

  Assert.AreEqual(EmptyStr, LazyAccess.CheckExpectations);

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

  Assert.IsTrue(GetLazyLoadingAccess(TValue.From(Lazy)).Loaded);

  TheValue.Free;
end;

procedure TLazyTest.WhenGetValueAndTheLoaderNotExistsMustReturnLoadedAsTrue;
begin
  var Lazy: Lazy<TMyEntity>;

  Lazy.Value;

  Assert.IsTrue(Lazy.Access.Loaded);
end;

procedure TLazyTest.WhenTheLazyIsLoadedMustReturnTheInternalValueUsingTheLazyAccess;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual<TObject>(TheValue, GetLazyLoadingAccess(TValue.From(Lazy)).GetValue.AsObject);

  TheValue.Free;
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
  TCache.Instance;

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

  Assert.IsTrue(LazyAccess.Loaded);
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
  LazyAccess.Cache := TCacheMock.Create(nil);
  LazyAccess.Factory := Factory.Instance;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Setup.WillReturn(5555).When.Load(It.IsAny<TRttiType>, It.IsAny<TValue>);

  Assert.AreEqual(5555, LazyLoaderIntf.Value.AsInteger);
end;

procedure TLazyAccessTest.WhenTheFactoryIsntLoadedAndTheGlobalReferenceIsEmptyTooMustRaiseAnError;
begin
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Cache := TCacheMock.Create(nil);
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
  LazyAccess.Cache := TCacheMock.Create(nil);
  LazyAccess.GlobalFactory := Factory.Instance;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Expect.Once.When.Load(It.IsAny<TRttiType>, It.IsAny<TValue>);

  LazyLoaderIntf.GetValue;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);

  LazyAccess.GlobalFactory := nil;
end;

procedure TLazyAccessTest.WhenTheKeyIsEmptyMustReturnThePropertyLoadedAsTrue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.IsTrue(LazyAccess.Loaded);
end;

procedure TLazyAccessTest.WhenTheKeyIsEmptyTheGetValueMustReturnAEmptyValue;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.IsTrue(LazyAccess.Value.IsEmpty)
end;

procedure TLazyAccessTest.WhenTheKeyIsFilledMustTryToGetTheValueFromCache;
begin
  var Cache := TCacheMock.Create(1234);
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Cache := Cache;
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  LazyLoaderIntf.Value;

  Assert.AreEqual('Get', Cache.MethodCalled);
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

  Assert.IsTrue(LazyAccess.Loaded);

  TheValue.Free;

  TLazyAccess.GlobalFactory := nil;
end;

procedure TLazyAccessTest.WhenTheTypeIsntLoadedTheValueMustReturnEmpty;
begin
  var LazyAccess: ILazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));

  Assert.AreEqual(TValue.From<TMyEntity>(nil), LazyAccess.Value);
end;

procedure TLazyAccessTest.WhenTheValueIsInTheCacheMustReturnLoadedAsTrue;
begin
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Cache := TCacheMock.Create('abcde');
  LazyAccess.Key := 1234;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Assert.IsTrue(LazyLoaderIntf.Loaded);
end;

procedure TLazyAccessTest.WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
begin
  var Factory := TMock.CreateInterface<ILazyFactory>;
  var LazyAccess := TLazyAccess.Create(GetRttiType(TMyEntity));
  LazyAccess.Cache := TCacheMock.Create(nil);
  LazyAccess.Key := 1234;
  LazyAccess.Factory := Factory.Instance;
  var LazyLoaderIntf := LazyAccess as ILazyAccess;

  Factory.Expect.Once.When.Load(It.IsAny<TRttiType>, It.IsAny<TValue>);

  LazyLoaderIntf.GetValue;

  Assert.AreEqual(EmptyStr, Factory.CheckExpectations);
end;

{ TCacheMock }

procedure TCacheMock.Add(RttiType: TRttiType; const PrimaryKey, Value: TValue);
begin
  MethodCalled := 'Add';
end;

constructor TCacheMock.Create(GetReturnValue: TValue);
begin
  inherited Create;

  FGetReturnValue := GetReturnValue;
end;

function TCacheMock.Get(RttiType: TRttiType; const PrimaryKey: TValue; var Value: TValue): Boolean;
begin
  MethodCalled := 'Get';
  Result := not FGetReturnValue.IsEmpty;
end;

end.


