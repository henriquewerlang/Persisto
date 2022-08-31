unit Delphi.ORM.Change.Manager.Test;

interface

uses DUnitX.TestFramework, Delphi.ORM.Change.Manager, Delphi.ORM.Test.Entity, Delphi.ORM.Mapper;

type
  [TestFixture]
  TChangeManagerTest = class
  private
    FChangeManager: IChangeManager;
    FInheritedClass: TMyEntityInheritedFromSimpleClass;
    FInheritedClassTable: TTable;
    FMyClass: TMyClass;
    FMyClassTable: TTable;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenAddMoreThenOneTheSameClassCantRaiseAnyError;
    [Test]
    procedure WhenAddAnInstanceMustLoadAllFieldValuesInTheChangeManager;
    [Test]
    procedure WhenAddAnInstanceMustAddTheFieldValuesInStringAsExpected;
    [Test]
    procedure WhenFillAChangeMustChangeTheValueTheFieldAsExpected;
    [Test]
    procedure WhenFillAChangeThatNotInTheChangeManagerCantRaiseAnyError;
    [Test]
    procedure WhenTheClassIsInheritedMustLoadAllFieldInTheChangeManager;
    [Test]
    procedure WhenTheClassHasAnArrayCantRaiseAnyErrorThenGettingTheValuesFromTheInstance;
  end;

implementation

uses System.SysUtils;

{ TChangeManagerTest }

procedure TChangeManagerTest.Setup;
begin
  FChangeManager := TChangeManager.Create;
  FInheritedClass := TMyEntityInheritedFromSimpleClass.Create;
  FInheritedClassTable := TMapper.Default.FindTable(FInheritedClass.ClassType);
  FMyClass := TMyClass.Create;
  FMyClassTable := TMapper.Default.FindTable(FMyClass.ClassType);
end;

procedure TChangeManagerTest.TearDown;
begin
  FChangeManager := nil;

  FMyClass.Free;

  FInheritedClass.Free;
end;

procedure TChangeManagerTest.WhenAddAnInstanceMustAddTheFieldValuesInStringAsExpected;
begin
  FMyClass.Name := 'MyName';
  FMyClass.Value := 123456;

  FChangeManager.AddInstance(FMyClassTable, FMyClass);

  Assert.AreEqual('''MyName''', FChangeManager.Changes[FMyClass][FMyClassTable.Field['Name']]);
  Assert.AreEqual('123456', FChangeManager.Changes[FMyClass][FMyClassTable.Field['Value']]);
end;

procedure TChangeManagerTest.WhenAddAnInstanceMustLoadAllFieldValuesInTheChangeManager;
begin
  FChangeManager.AddInstance(FMyClassTable, FMyClass);

  Assert.AreEqual(2, FChangeManager.Changes[FMyClass].ChangeCount);
end;

procedure TChangeManagerTest.WhenAddMoreThenOneTheSameClassCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FChangeManager.AddInstance(FMyClassTable, FMyClass);

      FChangeManager.AddInstance(FMyClassTable, FMyClass);

      FChangeManager.AddInstance(FMyClassTable, FMyClass);
    end);
end;

procedure TChangeManagerTest.WhenFillAChangeMustChangeTheValueTheFieldAsExpected;
begin
  FMyClass.Name := 'MyName';
  FMyClass.Value := 123456;

  FChangeManager.AddInstance(FMyClassTable, FMyClass);

  FChangeManager.Changes[FMyClass][FMyClassTable.Field['Value']] := 'abcd';

  Assert.AreEqual('abcd', FChangeManager.Changes[FMyClass][FMyClassTable.Field['Value']]);
end;

procedure TChangeManagerTest.WhenFillAChangeThatNotInTheChangeManagerCantRaiseAnyError;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FChangeManager.Changes[FMyClass][FMyClassTable.Field['Value']] := 'abcd';
    end);
end;

procedure TChangeManagerTest.WhenTheClassHasAnArrayCantRaiseAnyErrorThenGettingTheValuesFromTheInstance;
begin
  var AClass := TMyEntityWithManyValueAssociation.Create;
  AClass.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create];
  var Table := TMapper.Default.FindTable(AClass.ClassType);

  Assert.WillNotRaise(
    procedure
    begin
      FChangeManager.AddInstance(Table, AClass);
    end);

  AClass.ManyValueAssociationList[0].Free;

  AClass.Free;
end;

procedure TChangeManagerTest.WhenTheClassIsInheritedMustLoadAllFieldInTheChangeManager;
begin
  FChangeManager.AddInstance(FInheritedClassTable, FInheritedClass);

  Assert.WillNotRaise(
    procedure
    begin
      if FChangeManager.Changes[FInheritedClass][FInheritedClassTable.BaseTable.Field['BaseProperty']] = 'abcd' then
        raise Exception.Create('Any error!');
    end);
end;

end.

