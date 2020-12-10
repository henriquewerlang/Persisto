unit Delphi.ORM.Query.Builder.Test.Entity;

interface

uses Delphi.ORM.Attributes;

type
  [Entity]
  TMyTestClass = class
  private
    FField: Integer;
    FName: String;
    FValue: Double;
    FPublicField: String;
  public
    property PublicField: String read FPublicField write FPublicField;
  published
    property Field: Integer read FField write FField;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TClassOnlyPublic = class
  private
    FName: String;
    FValue: Integer;
  public
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  [PrimaryKey('Id,Id2')]
  TClassWithPrimaryKeyAttribute = class
  private
    FId: Integer;
    FId2: Integer;
    FValue: Integer;
  published
    property Id: Integer read FId write FId;
    property Id2: Integer read FId2 write FId2;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TClassWithPrimaryKey = class
  private
    FId: Integer;
    FValue: Integer;
  published
    property Id: Integer read FId write FId;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TClassWithForeignKey = class
  private
    FAnotherClass: TClassWithPrimaryKey;
    FId: Integer;
  published
    property AnotherClass: TClassWithPrimaryKey read FAnotherClass write FAnotherClass;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassWithTwoForeignKey = class
  private
    FAnotherClass: TClassWithPrimaryKey;
    FAnotherClass2: TClassWithPrimaryKey;
    FId: Integer;
  published
    property AnotherClass: TClassWithPrimaryKey read FAnotherClass write FAnotherClass;
    property AnotherClass2: TClassWithPrimaryKey read FAnotherClass2 write FAnotherClass2;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassWithForeignKeyRecursive = class
  private
    FAnotherClass: TClassWithForeignKey;
    FId: Integer;
  published
    property AnotherClass: TClassWithForeignKey read FAnotherClass write FAnotherClass;
    property Id: Integer read FId write FId;
  end;

  TClassRecursiveThrid = class;

  [Entity]
  TClassRecursiveFirst = class
  private
    FId: Integer;
    FRecursive: TClassRecursiveThrid;
  published
    property Id: Integer read FId write FId;
    property Recursive: TClassRecursiveThrid read FRecursive write FRecursive;
  end;

  [Entity]
  TClassRecursiveSecond = class
  private
    FId: Integer;
    FRecursive: TClassRecursiveFirst;
  published
    property Id: Integer read FId write FId;
    property Recursive: TClassRecursiveFirst read FRecursive write FRecursive;
  end;

  [Entity]
  TClassRecursiveThrid = class
  private
    FId: Integer;
    FRecursive: TClassRecursiveSecond;
  published
    property Id: Integer read FId write FId;
    property Recursive: TClassRecursiveSecond read FRecursive write FRecursive;
  end;

  TClassHierarchy2 = class;
  TClassHierarchy3 = class;

  [Entity]
  TClassHierarchy1 = class
  private
    FClass1: TClassHierarchy2;
    FId: Integer;
    FClass3: TClassHierarchy3;
  published
    property Class1: TClassHierarchy2 read FClass1 write FClass1;
    property Class2: TClassHierarchy3 read FClass3 write FClass3;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassHierarchy2 = class
  private
    FId: Integer;
    FClass2: TClassHierarchy1;
    FClass3: TClassHierarchy1;
  published
    property Class3: TClassHierarchy1 read FClass2 write FClass2;
    property Class4: TClassHierarchy1 read FClass3 write FClass3;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassHierarchy3 = class
  private
    FId: Integer;
    FValue: String;
  published
    property Id: Integer read FId write FId;
    property Value: String read FValue write FValue;
  end;

  [Entity]
  TClassRecursiveItself = class
  private
    FId: Integer;
    FRecursive1: TClassRecursiveItself;
    FRecursive2: TClassRecursiveItself;
  published
    property Id: Integer read FId write FId;
    property Recursive1: TClassRecursiveItself read FRecursive1 write FRecursive1;
    property Recursive2: TClassRecursiveItself read FRecursive2 write FRecursive2;
  end;

  TMyEntityWithManyValueAssociation = class;

  [Entity]
  TMyEntityWithManyValueAssociationChild = class
  private
    FId: Integer;
    FManyValueAssociation: TMyEntityWithManyValueAssociation;
  published
    property Id: Integer read FId write FId;
    property ManyValueAssociation: TMyEntityWithManyValueAssociation read FManyValueAssociation write FManyValueAssociation;
  end;
  [Entity]
  TMyEntityWithManyValueAssociation = class
  private
    FId: Integer;
    FManyValueAssociation: TArray<TMyEntityWithManyValueAssociationChild>;
  published
    property Id: Integer read FId write FId;
    property ManyValueAssociationList: TArray<TMyEntityWithManyValueAssociationChild> read FManyValueAssociation write FManyValueAssociation;
  end;


implementation

end.
