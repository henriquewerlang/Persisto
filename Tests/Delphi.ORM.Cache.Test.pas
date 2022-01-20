unit Delphi.ORM.Cache.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Cache;

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
    procedure WhenAddASharedObjectJustMustAddToTheCacheTheObject;
    [Test]
    procedure TheGenerateKeyFunctionMustReturnTheQualifiedClassNamePlusTheKeyValue;
    [Test]
    procedure WhenGenerateKeyFunctionIsATClassMustReturnTheQualifiedClassNamePlusTheKeyValue;
    [Test]
    procedure WhenAddTheSameKeyToTheCacheCantRaiseAnyError;
  end;

implementation

uses System.Rtti, Delphi.ORM.Test.Entity;

{ TCacheTest }

procedure TCacheTest.AfterAddTheObjectMustReturnTheValueAddedToTheCacheUsingTheSameKey;
begin
  var Cache := CreateCache;
  var MyObject := TObject.Create;
  var SharedObject: ISharedObject;

  Cache.Add('MyKey', MyObject);

  Cache.Get('MyKey', SharedObject);

  Assert.AreEqual(MyObject, SharedObject.&Object);
end;

function TCacheTest.CreateCache: ICache;
begin
  Result := TCache.Create;
end;

procedure TCacheTest.TheGenerateKeyFunctionMustReturnTheQualifiedClassNamePlusTheKeyValue;
begin
  Assert.AreEqual('Delphi.ORM.Cache.Test.TCacheTest.MyKey', TCache.GenerateKey(TRttiContext.Create.GetType(TCacheTest), 'MyKey'));
end;

procedure TCacheTest.WhenAddAnObjectToTheCacheMustReturnTheSharedInstanceOfThatObject;
begin
  var Cache := CreateCache;
  var MyObject := TObject.Create;

  var SharedObject := Cache.Add('MyKey', MyObject);

  Assert.AreEqual(MyObject, SharedObject.&Object);
end;

procedure TCacheTest.WhenAddASharedObjectJustMustAddToTheCacheTheObject;
begin
  var Cache := CreateCache;
  var MyObject := TObject.Create;

  var SharedObject := Cache.Add('MyKey', MyObject);

  Cache.Add('MyKey2', SharedObject);

  Cache.Get('MyKey2', SharedObject);

  Assert.AreEqual(MyObject, SharedObject.&Object);
end;

procedure TCacheTest.WhenAddTheSameKeyToTheCacheCantRaiseAnyError;
begin
  var Cache := CreateCache;

  Cache.Add('MyKey', nil);

  Assert.WillNotRaise(
    procedure
    begin
      Cache.Add('MyKey', nil);
    end);
end;

procedure TCacheTest.WhenGenerateKeyFunctionIsATClassMustReturnTheQualifiedClassNamePlusTheKeyValue;
begin
  Assert.AreEqual('Delphi.ORM.Cache.Test.TCacheTest.MyKey', TCache.GenerateKey(TCacheTest, 'MyKey'));
end;

procedure TCacheTest.WhenTheKeyValueDontExistMustReturnFalseInGetValue;
begin
  var Cache := CreateCache;
  var SharedObject: ISharedObject;

  Assert.IsFalse(Cache.Get('MyKey', SharedObject));
end;

end.

