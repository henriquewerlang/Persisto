unit Delphi.ORM.Cache.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Cache;

type
  [TestFixture]
  TCacheTest = class
  private
    function CreateCache: ICache;
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure MustGenerateTheKeyOfCacheAsExpected;
    [Test]
    procedure WhenAddAnItemMustGoToTheList;
    [Test]
    procedure TheKeyValueAddedMustBeTheKeyGeneratedByTheCache;
    [Test]
    procedure TheValueAddedMustByTheValuePassedInTheParameter;
    [Test]
    procedure WhenTryToGetAValueThatDontExtistMustReturnFalseInGetValue;
    [Test]
    procedure WhenFindTheValueInTheCacheMustReturnTrueInGetValue;
    [Test]
    procedure WhenFindTheValueMustReturnTheValueInTheKey;
  end;

implementation

uses System.Rtti, Delphi.ORM.Test.Entity;

{ TCacheTest }

function TCacheTest.CreateCache: ICache;
begin
  Result := TCache.Create;
end;

procedure TCacheTest.MustGenerateTheKeyOfCacheAsExpected;
begin
  var Context := TRttiContext.Create;
  var RttiType := Context.GetType(TMyClass);

  Assert.AreEqual('Delphi.ORM.Test.Entity.TMyClass.MyKey', TCache.GenerateKey(RttiType, 'MyKey'));
end;

procedure TCacheTest.SetupFixture;
begin
  var RttiType := TRttiContext.Create.GetType(TMyClass);

  RttiType.GetProperties;

  RttiType.QualifiedName;
end;

procedure TCacheTest.TheKeyValueAddedMustBeTheKeyGeneratedByTheCache;
begin
  var Cache := TCache.Create;
  var CacheInterface: ICache := Cache;
  var Context := TRttiContext.Create;
  var MyClass := TMyClass.Create;
  var RttiType := Context.GetType(TMyClass);

  CacheInterface.Add(RttiType, 'MyKey', MyClass);

  Assert.AreEqual('Delphi.ORM.Test.Entity.TMyClass.MyKey', Cache.Values.Keys.ToArray[0]);

  MyClass.Free;
end;

procedure TCacheTest.TheValueAddedMustByTheValuePassedInTheParameter;
begin
  var Cache := TCache.Create;
  var CacheInterface: ICache := Cache;
  var Context := TRttiContext.Create;
  var MyClass := TMyClass.Create;
  var RttiType := Context.GetType(TMyClass);

  CacheInterface.Add(RttiType, 'MyKey', MyClass);

  Assert.AreEqual<TObject>(MyClass, Cache.Values.Values.ToArray[0].AsObject);

  MyClass.Free;
end;

procedure TCacheTest.WhenAddAnItemMustGoToTheList;
begin
  var Cache := TCache.Create;
  var CacheInterface: ICache := Cache;
  var Context := TRttiContext.Create;
  var MyClass := TMyClass.Create;
  var RttiType := Context.GetType(TMyClass);

  CacheInterface.Add(RttiType, 'MyKey', MyClass);

  Assert.AreEqual(1, Cache.Values.Count);

  MyClass.Free;
end;

procedure TCacheTest.WhenFindTheValueInTheCacheMustReturnTrueInGetValue;
begin
  var Cache := CreateCache;
  var Context := TRttiContext.Create;
  var MyClass := TMyClass.Create;
  var RttiType := Context.GetType(TMyClass);
  var Value := TValue.Empty;

  Cache.Add(RttiType, 'MyKey', MyClass);

  Assert.IsTrue(Cache.Get(RttiType, 'MyKey', Value));

  MyClass.Free;
end;

procedure TCacheTest.WhenFindTheValueMustReturnTheValueInTheKey;
begin
  var Cache := CreateCache;
  var Context := TRttiContext.Create;
  var MyClass := TMyClass.Create;
  var RttiType := Context.GetType(TMyClass);
  var Value := TValue.Empty;

  Cache.Add(RttiType, 'MyKey', MyClass);

  Cache.Get(RttiType, 'MyKey', Value);

  Assert.AreEqual<TObject>(MyClass, Value.AsObject);

  MyClass.Free;
end;

procedure TCacheTest.WhenTryToGetAValueThatDontExtistMustReturnFalseInGetValue;
begin
  var Cache := CreateCache;
  var Context := TRttiContext.Create;
  var RttiType := Context.GetType(TMyClass);
  var Value := TValue.Empty;

  Assert.IsFalse(Cache.Get(RttiType, 'MyKey', Value));
end;

end.

