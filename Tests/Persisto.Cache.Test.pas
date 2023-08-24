unit Persisto.Cache.Test;

interface

uses DUnitX.TestFramework, Persisto;

type
  [TestFixture]
  TCacheTest = class
  private
    function CreateCache: ICache;
  public
    [Test]
    procedure WhenAddAnObjectToTheCacheMustReturnTheSharedInstanceOfThatObject;
    [Test]
    procedure AfterAddTheObjectMustReturnTheValueAddedToTheCacheUsingTheSameKey;
    [Test]
    procedure WhenTheKeyValueDontExistMustReturnFalseInGetValue;
    [Test]
    procedure TheGenerateKeyFunctionMustReturnTheQualifiedClassNamePlusTheKeyValue;
    [Test]
    procedure WhenGenerateKeyFunctionIsATClassMustReturnTheQualifiedClassNamePlusTheKeyValue;
  end;

implementation

uses System.Rtti, Persisto.Test.Entity;

{ TCacheTest }

procedure TCacheTest.AfterAddTheObjectMustReturnTheValueAddedToTheCacheUsingTheSameKey;
begin
  var Cache := CreateCache;
  var MyObject := TObject.Create;
  var SharedObject: TObject;

  Cache.Add('MyKey', MyObject);

  Cache.Get('MyKey', SharedObject);

  Assert.AreEqual(MyObject, SharedObject);
end;

function TCacheTest.CreateCache: ICache;
begin
  Result := TCache.Create;
end;

procedure TCacheTest.TheGenerateKeyFunctionMustReturnTheQualifiedClassNamePlusTheKeyValue;
begin
  Assert.AreEqual('Persisto.Cache.Test.TCacheTest.MyKey', TCache.GenerateKey(TRttiContext.Create.GetType(TCacheTest), 'MyKey'));
end;

procedure TCacheTest.WhenAddAnObjectToTheCacheMustReturnTheSharedInstanceOfThatObject;
begin
  var Cache := CreateCache;
  var MyObject := TObject.Create;

  var SharedObject := Cache.Add('MyKey', MyObject);

  Assert.AreEqual(MyObject, SharedObject);
end;

procedure TCacheTest.WhenGenerateKeyFunctionIsATClassMustReturnTheQualifiedClassNamePlusTheKeyValue;
begin
  Assert.AreEqual('Persisto.Cache.Test.TCacheTest.MyKey', TCache.GenerateKey(TCacheTest, 'MyKey'));
end;

procedure TCacheTest.WhenTheKeyValueDontExistMustReturnFalseInGetValue;
begin
  var Cache := CreateCache;
  var SharedObject: TObject;

  Assert.IsFalse(Cache.Get('MyKey', SharedObject));
end;

end.

