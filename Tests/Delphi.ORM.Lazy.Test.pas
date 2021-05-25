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
    procedure WhenTheLazyLoaderIsFilledMustReturnTheValueFromThere;
    [Test]
    procedure TheLazyLoaderCantBeCalledJustOnce;
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
    procedure WhenTheLazyIsntLoadedAndCallTheGetKeyFunctionMustReturnTheKeyFilledByLoader;
    [Test]
    procedure WhenAssignALazyVariableToAnotherMustCopyTheInternalAccess;
    [Test]
    procedure WhenCreateAClassTheGetKeyMustReturnAnEmptyValue;
  end;

  [TestFixture]
  TLazyLoaderTest = class
  public
    [SetupFixture]
    procedure Setup;
    [Test]
    procedure WhenTheKeyIsEmptyTheGetValueMustReturnAEmptyValue;
    [Test]
    procedure WhenCallTheGetKeyMustReturnTheValueFilledInTheConstructor;
    [Test]
    procedure WhenTheKeyIsFilledMustTryToGetTheValueFromCache;
    [Test]
    procedure WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
    [Test]
    procedure WhenCallTheLoadFunctionMustReturnTheValueLoaded;
    [Test]
    procedure AfterLoadTheValueMustAddTheValueInTheCacheList;
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

  TLazyLoaderMock = class(TLazyLoader)
  private
    FMethodCalled: String;
    FValue: TValue;
  protected
    function LoadValue: TValue; override;
  public
    constructor Create(const RttiType: TRttiType; const Key: TValue); overload;
    constructor Create(const RttiType: TRttiType; const Key, Value: TValue); overload;

    property MethodCalled: String read FMethodCalled write FMethodCalled;
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Test.Entity;

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

  TMock.CreateInterface<ILazyLoader>;
end;

procedure TLazyTest.TheLazyLoaderCantBeCalledJustOnce;
begin
  var Lazy: Lazy<TMyEntity>;
  var LazyLoader := TMock.CreateInterface<ILazyLoader>;
  var TheValue := TMyEntity.Create;

  LazyLoader.Expect.Once.When.GetValue;

  GetLazyLoadingAccess(TValue.From(Lazy)).SetLazyLoader(LazyLoader.Instance);

  Lazy.Value;

  Lazy.Value;

  Lazy.Value;

  Assert.AreEqual(EmptyStr, LazyLoader.CheckExpectations);

  TheValue.Free;
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

procedure TLazyTest.WhenCreateAClassTheGetKeyMustReturnAnEmptyValue;
begin
  var Lazy := TLazyClass.Create;
  var LazyAccess := GetLazyLoadingAccess(TValue.From(Lazy.Lazy));

  Assert.AreEqual(TValue.Empty, LazyAccess.GetKey);

  Lazy.Free;
end;

procedure TLazyTest.WhenFillTheValueCantCallTheLazyLoaderValue;
begin
  var Lazy: Lazy<TMyEntity>;
  var LazyLoader := TMock.CreateInterface<ILazyLoader>;
  var TheValue := TMyEntity.Create;

  LazyLoader.Expect.Never.When.GetValue;

  GetLazyLoadingAccess(TValue.From(Lazy)).SetLazyLoader(LazyLoader.Instance);

  Lazy.Value := TheValue;

  Lazy.Value;

  Lazy.Value;

  Lazy.Value;

  Assert.AreEqual(EmptyStr, LazyLoader.CheckExpectations);

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

procedure TLazyTest.WhenGetTheLoadedInTheLazyAcessMustReturnTrueIfIsLoaded;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.IsTrue(GetLazyLoadingAccess(TValue.From(Lazy)).Loaded);

  TheValue.Free;
end;

procedure TLazyTest.WhenTheLazyIsLoadedMustReturnTheInternalValueUsingTheLazyAccess;
begin
  var Lazy: Lazy<TMyEntity>;
  var TheValue := TMyEntity.Create;

  Lazy := TheValue;

  Assert.AreEqual<TObject>(TheValue, GetLazyLoadingAccess(TValue.From(Lazy)).GetValue.AsObject);

  TheValue.Free;
end;

procedure TLazyTest.WhenTheLazyIsntLoadedAndCallTheGetKeyFunctionMustReturnTheKeyFilledByLoader;
begin
  var Lazy: Lazy<TMyEntity>;
  var LazyAccess := GetLazyLoadingAccess(TValue.From(Lazy));
  var LazyLoader := TMock.CreateInterface<ILazyLoader>;

  LazyLoader.Setup.WillReturn(123456).When.GetKey;

  LazyAccess.SetLazyLoader(LazyLoader.Instance);

  Assert.AreEqual<Integer>(123456, LazyAccess.GetKey.AsInteger);
end;

procedure TLazyTest.WhenTheLazyLoaderIsFilledMustReturnTheValueFromThere;
begin
  var Lazy: Lazy<TMyEntity>;
  var LazyLoader := TMock.CreateInterface<ILazyLoader>;
  var TheValue := TMyEntity.Create;

  LazyLoader.Setup.WillReturn(TheValue).When.GetValue;

  GetLazyLoadingAccess(TValue.From(Lazy)).SetLazyLoader(LazyLoader.Instance);

  Assert.AreEqual(TheValue, Lazy.Value);

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

{ TLazyLoaderTest }

procedure TLazyLoaderTest.AfterLoadTheValueMustAddTheValueInTheCacheList;
begin
  var Cache := TCacheMock.Create(nil);
  var LazyLoader := TLazyLoaderMock.Create(nil, 12345, 5555);
  LazyLoader.Cache := Cache;
  var LazyLoaderIntf := LazyLoader as ILazyLoader;

  var Value := LazyLoaderIntf.GetValue;

  Assert.AreEqual('Add', Cache.MethodCalled);
end;

procedure TLazyLoaderTest.Setup;
begin
  TCache.Instance;
end;

procedure TLazyLoaderTest.WhenCallTheGetKeyMustReturnTheValueFilledInTheConstructor;
begin
  var LazyLoader: ILazyLoader := TLazyLoaderMock.Create(nil, 1234);

  Assert.AreEqual(1234, LazyLoader.GetKey.AsInteger)
end;

procedure TLazyLoaderTest.WhenCallTheLoadFunctionMustReturnTheValueLoaded;
begin
  var Cache := TCacheMock.Create(nil);
  var LazyLoader := TLazyLoaderMock.Create(nil, 12345, 5555);
  LazyLoader.Cache := Cache;
  var LazyLoaderIntf := LazyLoader as ILazyLoader;

  var Value := LazyLoaderIntf.GetValue;

  Assert.AreEqual(5555, Value.AsInteger);
end;

procedure TLazyLoaderTest.WhenTheKeyIsEmptyTheGetValueMustReturnAEmptyValue;
begin
  var LazyLoader: ILazyLoader := TLazyLoaderMock.Create(nil, nil);

  Assert.IsTrue(LazyLoader.GetValue.IsEmpty)
end;

procedure TLazyLoaderTest.WhenTheKeyIsFilledMustTryToGetTheValueFromCache;
begin
  var Cache := TCacheMock.Create(1234);
  var LazyLoader := TLazyLoaderMock.Create(nil, 12345);
  LazyLoader.Cache := Cache;
  var LazyLoaderIntf := LazyLoader as ILazyLoader;

  LazyLoaderIntf.GetValue;

  Assert.AreEqual('Get', Cache.MethodCalled);
end;

procedure TLazyLoaderTest.WhenTheValueNotExitstInCacheTheLoaderMustCallTheLoadFunctionOfImplentationClass;
begin
  var Cache := TCacheMock.Create(nil);
  var LazyLoader := TLazyLoaderMock.Create(nil, 12345);
  LazyLoader.Cache := Cache;
  var LazyLoaderIntf := LazyLoader as ILazyLoader;

  LazyLoaderIntf.GetValue;

  Assert.AreEqual('LoadValue', LazyLoader.MethodCalled);
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

{ TLazyLoaderMock }

constructor TLazyLoaderMock.Create(const RttiType: TRttiType; const Key, Value: TValue);
begin
  Create(RttiType, Key);

  FValue := Value;
end;

constructor TLazyLoaderMock.Create(const RttiType: TRttiType; const Key: TValue);
begin
  inherited;
end;

function TLazyLoaderMock.LoadValue: TValue;
begin
  MethodCalled := 'LoadValue';
  Result := FValue;
end;

end.

