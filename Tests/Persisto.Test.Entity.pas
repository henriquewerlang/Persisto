﻿unit Persisto.Test.Entity;

interface

uses System.SysUtils, Persisto.Mapping;

type
{$M+}
  TMyEntityInheritedFromSimpleClass = class;

  [Entity]
  TMyEntityForeignKeyAlias = class
  private
    FForeignKey: TMyEntityInheritedFromSimpleClass;
  published
    property ForeignKey: TMyEntityInheritedFromSimpleClass read FForeignKey write FForeignKey;
  end;

  [Entity]
  TMyEntityForeignKeyWithName = class
  private
    FForeignKey: TMyEntityInheritedFromSimpleClass;
  published
    [ForeignKeyName('MyForeignKey')]
    property ForeignKey: TMyEntityInheritedFromSimpleClass read FForeignKey write FForeignKey;
  end;

  [Entity]
  TAutoGeneratedClass = class
  private
    FAnotherField: String;
    FFixedValue: String;
    FId: String;
    FSequence: Integer;
    FValue: String;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    [NewUniqueIdentifier, UniqueIdentifier]
    property AnotherField: String read FAnotherField write FAnotherField;
    [FixedValue('''MyValue'''), Size(150)]
    property FixedValue: String read FFixedValue write FFixedValue;
    [Sequence('MySequence')]
    property Sequence: Integer read FSequence write FSequence;
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  TClassWithSequence = class
  private
    FId: Integer;
    FSequence: Integer;
  published
    property Id: Integer read FId write FId;
    [Sequence('AnotherSequence')]
    property AnotherSequence: Integer read FSequence write FSequence;
    [Sequence('MySequence')]
    property Sequence: Integer read FSequence write FSequence;
  end;

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
    [Size(150)]
    property Name: String read FName write FName;
    [Precision(15, 7)]
    property Value: Double read FValue write FValue;
  end;

  TClassOnlyPublic = class
  private
    FName: String;
    FValue: Integer;
  public
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TPublicClass = class
  private
    FId: Integer;
    FName: String;
    FValue: Integer;
  public
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  published
    property Id: Integer read FId write FId;
  end;

  [Entity]
  [PrimaryKey('Id2')]
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

  TClassRecursiveThird = class;

  [Entity]
  TClassRecursiveFirst = class
  private
    FGoingThird: TClassRecursiveThird;
    FId: Integer;
  published
    property GoingThird: TClassRecursiveThird read FGoingThird write FGoingThird;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassRecursiveSecond = class
  private
    FGoingFirst: TClassRecursiveFirst;
    FId: Integer;
  published
    property GoingFirst: TClassRecursiveFirst read FGoingFirst write FGoingFirst;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassRecursiveThird = class
  private
    FGoingSecond: TClassRecursiveSecond;
    FId: Integer;
  published
    [Required]
    property GoingSecond: TClassRecursiveSecond read FGoingSecond write FGoingSecond;
    property Id: Integer read FId write FId;
  end;

  TManyValueRecursive = class;

  TManyValueRecursiveChild = class
  private
    FManyValueRecursive: TManyValueRecursive;
    FRecursiveClass: TClassRecursiveFirst;
  published
    property ManyValueRecursive: TManyValueRecursive read FManyValueRecursive write FManyValueRecursive;
    property RecursiveClass: TClassRecursiveFirst read FRecursiveClass write FRecursiveClass;
  end;

  TManyValueRecursive = class
  private
    FChilds: TArray<TManyValueRecursiveChild>;
    FId: Integer;
  published
    property Childs: TArray<TManyValueRecursiveChild> read FChilds write FChilds;
    property Id: Integer read FId write FId;
  end;

  TMyEntityWithManyValueAssociation = class;

  [Entity]
  TMyEntityWithManyValueAssociationChild = class
  private
    FId: String;
    FManyValueAssociation: TMyEntityWithManyValueAssociation;
    FValue: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property ManyValueAssociation: TMyEntityWithManyValueAssociation read FManyValueAssociation write FManyValueAssociation;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TMyEntityWithManyValueAssociation = class
  private
    FId: String;
    FManyValueAssociation: TArray<TMyEntityWithManyValueAssociationChild>;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    [ManyValueAssociationLinkName('ManyValueAssociation')]
    property ManyValueAssociationList: TArray<TMyEntityWithManyValueAssociationChild> read FManyValueAssociation write FManyValueAssociation;
  end;

  TMyManyValue = class;

  [Entity]
  TMyChildLink = class
  private
    FId: String;
    FManyValueAssociation: TMyEntityWithManyValueAssociation;
    FMyManyValue: Lazy<TMyManyValue>;
    FValue: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property ManyValueAssociation: TMyEntityWithManyValueAssociation read FManyValueAssociation write FManyValueAssociation;
    property MyManyValue: Lazy<TMyManyValue> read FMyManyValue write FMyManyValue;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TMyManyValue = class
  private
    FChilds: TArray<TMyChildLink>;
    FId: String;
    FValue: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property Childs: TArray<TMyChildLink> read FChilds write FChilds;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TMyEntityWithPrimaryKeyInLastField = class
  private
    FField1: Integer;
    FField2: Integer;
    FField3: String;
    FId: Integer;
  published
    property Field1: Integer read FField1 write FField1;
    property Field2: Integer read FField2 write FField2;
    [Size(150)]
    property Field3: String read FField3 write FField3;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  [PrimaryKey('Name')]
  TMyClass = class
  private
    FName: String;
    FValue: Integer;
  published
    [Size(150)]
    property Name: String read FName write FName;
    property Value: Integer read FValue write FValue;
  end;

  TMyEnumerator = (Enum1, Enum2, Enum3, Enum4);

  [Entity]
  TMyClassWithSpecialTypes = class
  private
    FEnumerator: TMyEnumerator;
  published
    property Enumerator: TMyEnumerator read FEnumerator write FEnumerator;
  end;

  TManyValueAssociationParent = class;

  [Entity]
  TManyValueAssociationWithThreeForeignKey = class
  private
    FId: Integer;
    FForeignKeyOne: Lazy<TManyValueAssociationParent>;
    FForeignKeyTwo: Lazy<TManyValueAssociationParent>;
    FManyValueAssociationParent: TManyValueAssociationParent;
  published
    property Id: Integer read FId write FId;
    property ForeignKeyOne: Lazy<TManyValueAssociationParent> read FForeignKeyOne write FForeignKeyOne;
    property ForeignKeyTwo: Lazy<TManyValueAssociationParent> read FForeignKeyTwo write FForeignKeyTwo;
    property ManyValueAssociationParent: TManyValueAssociationParent read FManyValueAssociationParent write FManyValueAssociationParent;
  end;

  [Entity]
  TManyValueAssociationParent = class
  private
    FId: Integer;
    FChildClass: TArray<TManyValueAssociationWithThreeForeignKey>;
  published
    property Id: Integer read FId write FId;
    property ChildClass: TArray<TManyValueAssociationWithThreeForeignKey> read FChildClass write FChildClass;
  end;

  TManyValueAssociationParentNoLink = class
  private
    FChildClass: TArray<TManyValueAssociationWithThreeForeignKey>;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    property ChildClass: TArray<TManyValueAssociationWithThreeForeignKey> read FChildClass write FChildClass;
  end;

  [Entity]
  TMyEntity = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
    FPublicField: String;
  public
    property PublicField: String read FPublicField write FPublicField;
  published
    [FixedValue('100')]
    property Id: Integer read FId write FId;
    [Size(100)]
    property Name: String read FName write FName;
    [Precision(15, 7)]
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  [TableName('AnotherTableName')]
  TMyEntity2 = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
    FAField: Integer;
  published
    property AField: Integer read FAField write FAField;
    property Id: Integer read FId write FId;
    [Size(150)]
    property Name: String read FName write FName;
    [Precision(15, 7)]
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TMyEntity3 = class
  private
    FId: Integer;
  published
    property Id: Integer read FId write FId;
  end;

  [Entity]
  [PrimaryKey('Value')]
  TMyEntityWithPrimaryKey = class
  private
    FId: Integer;
    FValue: Double;
  published
    property Id: Integer read FId write FId;
    [Precision(15, 7)]
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TMyEntityWithFieldNameAttribute = class
  private
    FName: String;
    FMyForeignKey: TMyEntityWithPrimaryKey;
    FMyForeignKey2: TMyEntity2;
  published
    [FieldName('AnotherFieldName'), Size(150)]
    property Name: String read FName write FName;
    property MyForeignKey: TMyEntityWithPrimaryKey read FMyForeignKey write FMyForeignKey;
    property MyForeignKey2: TMyEntity2 read FMyForeignKey2 write FMyForeignKey2;
  end;

  TMyEntityWithoutEntityAttribute = class
  private
    FId: Integer;
    FName: String;
    FValue: Double;
  published
    property Id: Integer read FId write FId;
    [Size(150)]
    property Name: String read FName write FName;
    [Precision(15, 7)]
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TAAAA = class
  private
    FId: Integer;
    FValue: String;
  published
    property Id: Integer read FId write FId;
    [Size(50)]
    property Value: String read FValue write FValue;
  end;

  [Entity]
  TZZZZ = class
  private
    FAAAA: TAAAA;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    property AAAA: TAAAA read FAAAA write FAAAA;
  end;

  [Entity]
  TMyEntityWithoutPrimaryKey = class
  private
    FValue: String;
  published
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  TMyEntityForeignKeyToClassWithoutPrimaryKey = class
  private
    FValue: String;
    FId: Integer;
    FForerignKey: TMyEntityWithoutPrimaryKey;
  published
    property Id: Integer read FId write FId;
    property ForerignKey: TMyEntityWithoutPrimaryKey read FForerignKey write FForerignKey;
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  [SingleTableInheritance]
  TMyEntityWithSingleTableInheritanceAttribute = class
  private
    FId: Integer;
    FBaseProperty: String;
  published
    [Size(50)]
    property BaseProperty: String read FBaseProperty write FBaseProperty;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TMyEntityInheritedFromSingle = class(TMyEntityWithSingleTableInheritanceAttribute)
  private
    FAnotherProperty: String;
  published
    [Size(50)]
    property AnotherProperty: String read FAnotherProperty write FAnotherProperty;
  end;

  [Entity]
  TMyClassInheritedWithoutFields = class(TMyEntityWithSingleTableInheritanceAttribute)
  end;

  [Entity]
  TMyEntityInheritedFromSimpleClass = class(TMyEntityInheritedFromSingle)
  private
    FSimpleProperty: Integer;
  published
    property SimpleProperty: Integer read FSimpleProperty write FSimpleProperty;
  end;

  [SingleTableInheritance]
  TAnotherSingleInherited = class(TMyEntityWithSingleTableInheritanceAttribute)
  private
    FAProperty: String;
  published
    [Size(50)]
    property AProperty: String read FAProperty write FAProperty;
  end;

  [Entity]
  TAnotherSingleInheritedConcrete = class(TAnotherSingleInherited)
  private
    FValue: String;
  published
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  TMyEntityForeignKeyToAnotherSingle = class
  private
    FId: String;
    FMyForeignKey: TAnotherSingleInherited;
  published
    [Size(150)]
    property Id: String read FId write FId;
    property MyForeignKey: TAnotherSingleInherited read FMyForeignKey write FMyForeignKey;
  end;

  [Entity]
  TMyEntityForeignKeyToConcrete = class
  private
    FAnotherClass: TAnotherSingleInheritedConcrete;
    FId: Integer;
  published
    property AnotherClass: TAnotherSingleInheritedConcrete read FAnotherClass write FAnotherClass;
    property Id: Integer read FId write FId;
  end;

  TMyEntityAlias = class;

  TMyEntityWithForeignKeyAlias = class
  private
    FId: Integer;
    FForeignKey: TMyEntity;
  published
    property ForeignKey: TMyEntity read FForeignKey write FForeignKey;
    property Id: Integer read FId write FId;
  end;

  TMyEntityAlias = class
  private
    FId: Integer;
  published
    property Id: Integer read FId write FId;
  end;

  [Entity]
  [PrimaryKey('Integer')]
  TMyEntityWithAllTypeOfFields = class
  private
    FAnsiChar: AnsiChar;
    FAnsiString: AnsiString;
    FBoolean: Boolean;
    FChar: Char;
    FDate: TDate;
    FDateTime: TDateTime;
    FEnumerator: TMyEnumerator;
    FFloat: Double;
    FInt64: Int64;
    FInteger: Integer;
    FString: String;
    FText: String;
    FTime: TTime;
    FUniqueIdentifier: String;
  published
    property AnsiChar: AnsiChar read FAnsiChar write FAnsiChar;
    [Size(150)]
    property AnsiString: AnsiString read FAnsiString write FAnsiString;
    property Boolean: Boolean read FBoolean write FBoolean;
    property Char: Char read FChar write FChar;
    property Date: TDate read FDate write FDate;
    property DateTime: TDateTime read FDateTime write FDateTime;
    property Enumerator: TMyEnumerator read FEnumerator write FEnumerator;
    [Precision(10, 2)]
    property Float: Double read FFloat write FFloat;
    property Int64: Int64 read FInt64 write FInt64;
    property Integer: Integer read FInteger write FInteger;
    [Size(150)]
    property &String: String read FString write FString;
    [Text]
    property Text: String read FText write FText;
    property Time: TTime read FTime write FTime;
    [UniqueIdentifier, NewUniqueIdentifier]
    property UniqueIdentifier: String read FUniqueIdentifier write FUniqueIdentifier;
  end;

  TMyChildClass = class;
  TMyClassParent = class;

  [Entity]
  TMyChildChildClass = class
  private
    FId: Integer;
    FValue: String;
    FMyChildClass: TMyChildClass;
  published
    property Id: Integer read FId write FId;
    property MyChildClass: TMyChildClass read FMyChildClass write FMyChildClass;
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  [Entity]
  TMyChildClass = class
  private
    FId: Integer;
    FValue: String;
    FChild: TArray<TMyChildChildClass>;
    FMyClassParent: TMyClassParent;
  published
    property Child: TArray<TMyChildChildClass> read FChild write FChild;
    property Id: Integer read FId write FId;
    property MyClassParent: TMyClassParent read FMyClassParent write FMyClassParent;
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  [Entity]
  TMyClassParent = class
  private
    FId: Integer;
    FChild: TArray<TMyChildClass>;
  published
    property Child: TArray<TMyChildClass> read FChild write FChild;
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TClassWithNullableProperty = class
  private
    FId: Integer;
    FNullable: Integer;
    FNullableStored: Boolean;
    FNullableField: Integer;
    FNullableProcedure: Integer;
    FNullableFieldStored: Boolean;
    function GetNullableProcedureStored: Boolean;
    procedure SetNullable(const Value: Integer);
  public
    property NullableFieldStored: Boolean read FNullableFieldStored write FNullableFieldStored;
    property NullableStored: Boolean read FNullableStored write FNullableStored;
  published
    property Id: Integer read FId write FId;
    property Nullable: Integer read FNullable write SetNullable stored FNullableStored;
    property NullableField: Integer read FNullableField write FNullableField stored FNullableFieldStored;
    property NullableProcedure: Integer read FNullableProcedure write FNullableProcedure stored GetNullableProcedureStored;
  end;

  TClassWithPrimaryKeyNullableProperty = class
  private
    FId: Integer;
    FIdStored: Boolean;
  public
    property IdStored: Boolean read FIdStored write FIdStored;
  published
    property Id: Integer read FId write FId stored FIdStored;
  end;

  [Entity]
  TLazyClass = class
  private
    FId: Integer;
    FLazy: Lazy<TMyEntity>;
  published
    property Id: Integer read FId write FId;
    property Lazy: Lazy<TMyEntity> read FLazy write FLazy;
  end;

  TLazyArrayClass = class;

  [Entity]
  TLazyArrayClassChild = class
  private
    FId: String;
    FLazyArrayClass: Lazy<TLazyArrayClass>;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    [Required]
    property LazyArrayClass: Lazy<TLazyArrayClass> read FLazyArrayClass write FLazyArrayClass;
  end;

  [Entity]
  TLazyArrayClass = class
  private
    FId: Integer;
    FLazy: Lazy<TMyEntity>;
    FLazyArray: Lazy<TArray<TLazyArrayClassChild>>;
  published
    property Id: Integer read FId write FId;
    property Lazy: Lazy<TMyEntity> read FLazy write FLazy;
    property LazyArray: Lazy<TArray<TLazyArrayClassChild>> read FLazyArray write FLazyArray;
  end;

  [Entity]
  TClassWithLazyArrayClass = class
  private
    FId: Integer;
    FValue1: TLazyArrayClass;
    FValue2: TLazyArrayClass;
  published
    property Id: Integer read FId write FId;
    property Value1: TLazyArrayClass read FValue1 write FValue1;
    property Value2: TLazyArrayClass read FValue2 write FValue2;
  end;

  [Entity]
  TUnorderedClass = class
  private
    FAField: String;
    FBField: Integer;
    FId: Integer;
    FAManyValue: TArray<TUnorderedClass>;
    FBManyValue: TArray<TUnorderedClass>;
    FBForeignKey: TUnorderedClass;
    FAForeignKey: TUnorderedClass;
    FALazy: Lazy<TUnorderedClass>;
    FBLazy: Lazy<TUnorderedClass>;
    FLastField: String;
  published
    property BField: Integer read FBField write FBField;
    [Size(150)]
    property AField: String read FAField write FAField;
    property Id: Integer read FId write FId;
    [ManyValueAssociationLinkName('BForeignKey')]
    property BManyValue: TArray<TUnorderedClass> read FBManyValue write FBManyValue;
    [ManyValueAssociationLinkName('AForeignKey')]
    property AManyValue: TArray<TUnorderedClass> read FAManyValue write FAManyValue;
    property BLazy: Lazy<TUnorderedClass> read FBLazy write FBLazy;
    property ALazy: Lazy<TUnorderedClass> read FALazy write FALazy;
    property BForeignKey: TUnorderedClass read FBForeignKey write FBForeignKey;
    property AForeignKey: TUnorderedClass read FAForeignKey write FAForeignKey;
    [Size(150)]
    property LastField: String read FLastField write FLastField;
  end;

  TManyValueParent = class;

  [Entity]
  TManyValueChild = class
  private
    FId: String;
    FParent: TManyValueParent;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property Parent: TManyValueParent read FParent write FParent;
  end;

  [Entity]
  TManyValueParent = class
  private
    FId: Integer;
    FChild: TManyValueChild;
    FChilds: TArray<TManyValueChild>;
  published
    property Child: TManyValueChild read FChild write FChild;
    [ManyValueAssociationLinkName('Parent')]
    property Childs: TArray<TManyValueChild> read FChilds write FChilds;
    property Id: Integer read FId write FId;
  end;

  TManyValueParentInherited = class;

  [Entity]
  TManyValueChildInheritedBase = class
  private
    FId: Integer;
    FValue: TClassWithPrimaryKey;
  published
    property Id: Integer read FId write FId;
    property Value: TClassWithPrimaryKey read FValue write FValue;
  end;

  [Entity]
  TManyValueChildInherited = class(TManyValueChildInheritedBase)
  private
    FParent: TManyValueParentInherited;
  published
    property Parent: TManyValueParentInherited read FParent write FParent;
  end;

  [Entity]
  TManyValueParentInherited = class
  private
    FId: Integer;
    FChilds: TArray<TManyValueChildInherited>;
  published
    [ManyValueAssociationLinkName('Parent')]
    property Childs: TArray<TManyValueChildInherited> read FChilds write FChilds;
    property Id: Integer read FId write FId;
  end;

  TManyValueParentError = class;

  [Entity]
  TManyValueParentChildError = class
  private
    FId: String;
    FParent: TManyValueParentError;
    FPassCount: Integer;

    function GetParent: TManyValueParentError;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property ManyValueParentError: TManyValueParentError read GetParent write FParent;
  end;

  [Entity]
  TManyValueParentError = class
  private
    FId: Integer;
    FValues: TArray<TManyValueParentChildError>;
    FPassCount: Integer;
  published
    property Id: Integer read FId write FId;
    property PassCount: Integer read FPassCount write FPassCount;
    property Childs: TArray<TManyValueParentChildError> read FValues write FValues;
  end;

  [Entity]
  TClassWithNamedForeignKey = class
  private
    FId: Integer;
    FForeignKey: TMyEntity;
  published
    property Id: Integer read FId write FId;
    [FieldName('MyFk')]
    property ForeignKey: TMyEntity read FForeignKey write FForeignKey;
  end;

  [Entity]
  [PrimaryKey('Value')]
  TClassWithNamedPrimaryKey = class
  private
    FValue: Integer;
  published
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  [PrimaryKey('Field')]
  TClassWithForeignKeyNamedLinked = class
  private
    FField: Integer;
    FFK: TClassWithNamedPrimaryKey;
  published
    property Field: Integer read FField write FField;
    [FieldName('Another')]
    property FK: TClassWithNamedPrimaryKey read FFK write FFK;
  end;

  TManyValueClassBase = class;

  [Entity]
  TManyValueClassBaseChild = class
  private
    FManyValueClassBase: TManyValueClassBase;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    property ManyValueClassBase: TManyValueClassBase read FManyValueClassBase write FManyValueClassBase;
  end;

  [Entity]
  TManyValueClassBase = class
  private
    FValues: TArray<TManyValueClassBaseChild>;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    property Childs: TArray<TManyValueClassBaseChild> read FValues write FValues;
  end;

  TManyValueClassInherited = class;

  [Entity]
  TManyValueClassInheritedChild = class
  private
    FManyValueClassInherited: TManyValueClassInherited;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    property ManyValueClassInherited: TManyValueClassInherited read FManyValueClassInherited write FManyValueClassInherited;
  end;

  [Entity]
  TManyValueClassInherited = class(TManyValueClassBase)
  private
    FAnotherValues: TArray<TManyValueClassInheritedChild>;
  published
    property AnotherValues: TArray<TManyValueClassInheritedChild> read FAnotherValues write FAnotherValues;
  end;

  [Entity]
  [Index('MyIndex', 'MyField')]
  [Index('MyIndex2', 'MyField;MyField2')]
  [UniqueIndex('MyUnique', 'MyField;MyField2')]
  TMyClassWithIndex = class
  private
    FId: Integer;
    FMyField: String;
    FMyField2: Integer;
  published
    property Id: Integer read FId write FId;
    [Size(150)]
    property MyField: String read FMyField write FMyField;
    property MyField2: Integer read FMyField2 write FMyField2;
  end;

  [Index('MyIndex', 'MyField')]
  TMyClassWithIndexWithError = class
  private
    FId: Integer;
  published
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TRequiredClass = class
  private
    FId: Integer;
    FRequiredField: String;
    FRequiredObject: TMyClass;
  published
    property Id: Integer read FId write FId;
    [Required, Size(150)]
    property RequiredField: String read FRequiredField write FRequiredField;
    [Required]
    property RequiredObject: TMyClass read FRequiredObject write FRequiredObject;
  end;

  [Entity]
  TPrimaryDateTime = class
  private
    FId: TDateTime;
  published
    property Id: TDateTime read FId write FId;
  end;

  [Entity]
  TPrimaryFloat = class
  private
    FId: Double;
  published
    [Precision(20, 5)]
    property Id: Double read FId write FId;
  end;

  [Entity]
  TPrimarySpecialType = class
  private
    FId: String;
  published
    [UniqueIdentifier]
    property Id: String read FId write FId;
  end;

  [Entity]
  TForeignKeyClassToSpecialCase = class
  private
    FDateTimeForeignKey: TPrimaryDateTime;
    FFloatForeignKey: TPrimaryFloat;
    FSpecialTypeForeignKey: TPrimarySpecialType;
  published
    property DateTimeForeignKey: TPrimaryDateTime read FDateTimeForeignKey write FDateTimeForeignKey;
    property FloatForeignKey: TPrimaryFloat read FFloatForeignKey write FFloatForeignKey;
    property SpecialTypeForeignKey: TPrimarySpecialType read FSpecialTypeForeignKey write FSpecialTypeForeignKey;
  end;

  [Entity]
  TClassEnumPrimaryKey = class
  private
    FId: TMyEnumerator;
    FValue: String;
  published
    property Id: TMyEnumerator read FId write FId;
    [Size(150)]
    property Value: String read FValue write FValue;
  end;

  [Entity]
  TClassWithoutPrimaryKey = class
  private
    FValue: Integer;
  published
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TMySQLiteTable = class
  private
    FId: String;
  published
    [Size(150)]
    property Id: String read FId write FId;
  end;

  TMyClassWithoutPublishedFields = class
  private
    FId: Integer;
  public
    property Id: Integer read FId write FId;
  end;

  [Entity]
  TInsertTest = class
  private
    FId: String;
    FIntegerValue: Integer;
    FValue: Double;
  published
    [Size(20)]
    property Id: String read FId write FId;
    property IntegerValue: Integer read FIntegerValue write FIntegerValue;
    [Precision(10, 3)]
    property Value: Double read FValue write FValue;
  end;

  [Entity]
  TInsertAutoGenerated = class
  private
    FId: String;
    FDateTime: TDateTime;
    FValue: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    [CurrentDateTime]
    property DateTime: TDateTime read FDateTime write FDateTime;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TInsertAutoGeneratedSequence = class
  private
    FId: Integer;
    FValue: Integer;
    FDateTime: TDateTime;
  published
    [Sequence('AutoGeneratedSequence')]
    property Id: Integer read FId write FId;
    [CurrentDateTime]
    property DateTime: TDateTime read FDateTime write FDateTime;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TInsertTestWithForeignKey = class
  private
    FFK1: TInsertAutoGeneratedSequence;
    FFK2: TInsertAutoGeneratedSequence;
    FId: String;
    FValue: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property FK1: TInsertAutoGeneratedSequence read FFK1 write FFK1;
    property FK2: TInsertAutoGeneratedSequence read FFK2 write FFK2;
    property Value: Integer read FValue write FValue;
  end;

  [Entity]
  TInsertTestWithForeignKeyMoreOne = class
  private
    FFK: TInsertTestWithForeignKey;
    FId: String;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property FK: TInsertTestWithForeignKey read FFK write FFK;
  end;

  [Entity]
  TClassLevel1 = class
  private
    FField1: String;
    FId: Integer;
  published
    property Id: Integer read FId write FId;
    [Size(10)]
    property Field1: String read FField1 write FField1;
  end;

  [SingleTableInheritance]
  TClassLevel2 = class(TClassLevel1)
  private
    FField2: String;
  published
    [Size(10)]
    property Field2: String read FField2 write FField2;
  end;

  [SingleTableInheritance]
  TClassLevel3 = class(TClassLevel2)
  private
    FField3: String;
  published
    [Size(10)]
    property Field3: String read FField3 write FField3;
  end;

  [Entity]
  TClassLevel4 = class(TClassLevel3)
  private
    FField4: String;
  published
    [Size(10)]
    property Field4: String read FField4 write FField4;
  end;

  [Entity]
  TStackOverflowClass = class
  private
    FCallBack: TStackOverflowClass;
    FPassCount: Integer;
    FId: String;

    function GetCallBack: TStackOverflowClass;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property CallBack: TStackOverflowClass read GetCallBack write FCallBack;
  end;

  [Entity]
  TMyClassWithAllFieldsType = class
  private
    FBigint: Int64;
    FBoolean: Boolean;
    FByte: Byte;
    FChar: Char;
    FDate: TDate;
    FDateTime: TDateTime;
    FDefaultField: String;
    FEnumerator: TMyEnumerator;
    FFloat: Double;
    FInteger: Integer;
    FSmallint: Word;
    FText: String;
    FTime: TTime;
    FUniqueIdentifier: String;
    FVarChar: String;
    FNullField: Integer;
    FDefaultInternalFunction: String;
    FNullFieldStored: Boolean;
    FBinaryField: TArray<Byte>;
  public
    property NullFieldStored: Boolean read FNullFieldStored write FNullFieldStored;
  published
    property Boolean: Boolean read FBoolean write FBoolean;
    property Bigint: Int64 read FBigint write FBigint;
    [Binary]
    property BinaryField: TArray<Byte> read FBinaryField write FBinaryField;
    property Byte: Byte read FByte write FByte;
    property Char: Char read FChar write FChar;
    [CurrentDate]
    property Date: TDate read FDate write FDate;
    [CurrentDateTime]
    property DateTime: TDateTime read FDateTime write FDateTime;
    [NewUniqueIdentifier, UniqueIdentifier]
    property DefaultField: String read FDefaultField write FDefaultField;
    [NewUniqueIdentifier, UniqueIdentifier]
    property DefaultInternalFunction: String read FDefaultInternalFunction write FDefaultInternalFunction;
    property Enumerator: TMyEnumerator read FEnumerator write FEnumerator;
    [Precision(10, 5)]
    property Float: Double read FFloat write FFloat;
    [Sequence('Integer')]
    property Integer: Integer read FInteger write FInteger;
    property NullField: Integer read FNullField write FNullField stored FNullFieldStored;
    property Smallint: Word read FSmallint write FSmallint;
    [Text]
    property Text: String read FText write FText;
    [CurrentTime]
    property Time: TTime read FTime write FTime;
    [NewUniqueIdentifier, UniqueIdentifier]
    property UniqueIdentifier: String read FUniqueIdentifier write FUniqueIdentifier;
    [Size(250)]
    property VarChar: String read FVarChar write FVarChar;
  end;

  [Entity]
  TMyRequiredField = class
  private
    FId: Integer;
    FRequired: Integer;
    FNotRequired: String;
    FMyUnique: String;
  published
    property Id: Integer read FId write FId;
    property Required: Integer read FRequired write FRequired;
    [Size(150)]
    property NotRequired: String read FNotRequired write FNotRequired;
    [Required, UniqueIdentifier]
    property MyUnique: String read FMyUnique write FMyUnique;
  end;

  [Entity]
  TEntityWithError = class
  private
    FId: String;
    FError: Integer;
    function GetError: Integer;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property Error: Integer read GetError write FError;
  end;

  TMyClassWithByteArray = class
  private
    FId: Integer;
    FMyArray: TArray<Byte>;
  published
    property Id: Integer read FId write FId;
    property MyArray: TArray<Byte> read FMyArray write FMyArray;
  end;

  [Entity]
  TLazyFilterChild = class
  private
    FId: String;
    FField: String;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    [Size(150)]
    property Field: String read FField write FField;
  end;

  [Entity]
  TLazyFilter = class
  private
    FId: String;
    FLazyField: Lazy<TLazyFilterChild>;
    FLazyString: Lazy<String>;
  published
    [NewUniqueIdentifier, UniqueIdentifier]
    property Id: String read FId write FId;
    property LazyField: Lazy<TLazyFilterChild> read FLazyField write FLazyField;
    [Text]
    property LazyString: Lazy<String> read FLazyString write FLazyString;
  end;

  TClassWithoutEntityAttribute = class
  private
    FId: String;
  published
    [Size(20)]
    property Id: String read FId write FId;
  end;

implementation

uses System.Internal.ExcUtils;

{ TManyValueParentChildError }

function TManyValueParentChildError.GetParent: TManyValueParentError;
begin
  Result := FParent;

  if Assigned(FParent) and (FPassCount >= FParent.PassCount) then
    raise Exception.Create('Can not access this property!');

  Inc(FPassCount);
end;

{ TStackOverflowClass }

function TStackOverflowClass.GetCallBack: TStackOverflowClass;
begin
  Result := FCallBack;

  Inc(FPassCount);

  if FPassCount > 10 then
    raise ExceptTypes[etStackOverflow].Create('Error!');
end;

{ TClassWithNullableProperty }

function TClassWithNullableProperty.GetNullableProcedureStored: Boolean;
begin
  Result := FNullableProcedure > 0;
end;

procedure TClassWithNullableProperty.SetNullable(const Value: Integer);
begin
  FNullable := Value;
  FNullableStored := True;
end;

{ TEntityWithError }

function TEntityWithError.GetError: Integer;
begin
  Result := FError;

  if FError > 10 then
    raise Exception.Create('Error');
end;

end.

