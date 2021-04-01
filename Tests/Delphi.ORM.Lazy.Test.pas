unit Delphi.ORM.Lazy.Test;

interface

uses System.Rtti, DUnitX.TestFramework;

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
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.ORM.Lazy, Delphi.ORM.Test.Entity;

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

end.

