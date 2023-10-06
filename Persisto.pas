unit Persisto;

interface

uses System.TypInfo, System.Rtti, System.SysUtils, System.Generics.Collections, System.Generics.Defaults, System.Classes, Data.DB, Persisto.Mapping;

type
  TBuilderOptions = set of (boBeautifyQuery, boJoinMapping);

  TDatabaseCheckConstraint = class;
  TDatabaseDefaultConstraint = class;
  TDatabaseField = class;
  TDatabaseForeignKey = class;
  TDatabaseIndex = class;
  TDatabaseSequence = class;
  TDatabaseTable = class;
  TDefaultConstraint = class;
  TField = class;
  TForeignKey = class;
  TIndex = class;
  TManager = class;
  TManyValueAssociation = class;
  TMapper = class;
  TQueryBuilder = class;
  TQueryBuilderFieldSearch = class;
  TQueryBuilderFrom = class;
  TQueryBuilderOrderByField = class;
  TQueryBuilderWhere = class;
  TQueryBuilderWhere<T: class> = class;
  TSequence = class;
  TTable = class;

  IDatabaseCursor = interface
    ['{19CBD0F4-8766-4F1D-8E88-F7E03E6A5E28}']
    function GetDataSet: TDataSet;
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  IDatabaseTransaction = interface
    ['{218FA473-10BD-406B-B01B-79AF603570FE}']
    procedure Commit;
    procedure Rollback;
  end;

  IDatabaseConnection = interface
    ['{7FF2A2F4-0440-447D-9E64-C61A92E94800}']
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  end;

  IDatabaseManipulator = interface
    ['{7ED4F3DE-1C13-4CF3-AE3C-B51386EA271F}']
    function CreateDefaultConstraint(const Field: TField): String;
    function CreateField(const Field: TField): String;
    function CreateForeignKey(const ForeignKey: TForeignKey): String;
    function CreateIndex(const Index: TIndex): String;
    function CreateSequence(const Sequence: TSequence): String;
    function CreateTempField(const Field: TField): String;
    function DropDefaultConstraint(const Field: TDatabaseField): String;
    function DropField(const Field: TDatabaseField): String;
    function DropForeignKey(const ForeignKey: TDatabaseForeignKey): String;
    function DropIndex(const Index: TDatabaseIndex): String;
    function DropSequence(const Sequence: TDatabaseSequence): String;
    function DropTable(const Table: TDatabaseTable): String;
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
    function MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
    function RenameField(const Current, Destiny: TField): String;
    function UpdateField(const SourceField, DestinyField: TField): String;
  end;

  EFieldNotInCurrentSelection = class(Exception)
  public
    constructor Create(const Field: TQueryBuilderFieldSearch);
  end;

  EClassWithoutPrimaryKeyDefined = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EClassWithPrimaryKeyNullable = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EFieldIndexNotFound = class(Exception)
  public
    constructor Create(const Table: TTable; const FieldName: String);
  end;

  EForeignKeyToSingleTableInheritanceTable = class(Exception)
  public
    constructor Create(ParentTable: TRttiInstanceType);
  end;

  EManyValueAssociationLinkError = class(Exception)
  public
    constructor Create(ParentTable, ChildTable: TTable);
  end;

  ESequenceAlreadyExists = class(Exception)
  public
    constructor Create(const SequenceName: String);
  end;

  ETableWithoutPublishedFields = class(Exception)
  public
    constructor Create(const Table: TTable);
  end;

  EForeignObjectNotAllowed = class(Exception)
  public
    constructor Create;
  end;

  ERecursionInsertionError = class(Exception)
  private
    FRecursionTree: String;
  public
    constructor Create(const RecursionTree: String);

    property RecursionTree: String read FRecursionTree write FRecursionTree;
  end;

  ERecursionSelectionError = class(Exception)
  private
    FRecursionTree: String;
  public
    constructor Create(const RecursionTree: String);

    property RecursionTree: String read FRecursionTree write FRecursionTree;
  end;

  TTableObject = class
  private
    FTable: TTable;
  public
    constructor Create(const Table: TTable);

    property Table: TTable read FTable;
  end;

  TTable = class
  private
    FAllFieldCount: Integer;
    FBaseTable: TTable;
    FClassTypeInfo: TRttiInstanceType;
    FDatabaseName: String;
    FDefaultRecords: TList<TObject>;
    FFields: TArray<TField>;
    FForeignKeys: TArray<TForeignKey>;
    FIndexes: TArray<TIndex>;
    FManyValueAssociations: TArray<TManyValueAssociation>;
    FMapper: TMapper;
    FName: String;
    FPrimaryKey: TField;
    FReturningFields: TArray<TField>;

    function GetDefaultRecords: TList<TObject>;
    function GetField(const FieldName: String): TField;
    function GetHasPrimaryKey: Boolean;
  public
    constructor Create(TypeInfo: TRttiInstanceType);

    destructor Destroy; override;

    function FindField(const FieldName: String; var Field: TField): Boolean;

    property AllFieldCount: Integer read FAllFieldCount;
    property BaseTable: TTable read FBaseTable;
    property ClassTypeInfo: TRttiInstanceType read FClassTypeInfo;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property DefaultRecords: TList<TObject> read GetDefaultRecords;
    property Field[const FieldName: String]: TField read GetField; default;
    property Fields: TArray<TField> read FFields write FFields;
    property ForeignKeys: TArray<TForeignKey> read FForeignKeys;
    property HasPrimaryKey: Boolean read GetHasPrimaryKey;
    property Indexes: TArray<TIndex> read FIndexes;
    property ManyValueAssociations: TArray<TManyValueAssociation> read FManyValueAssociations;
    property Mapper: TMapper read FMapper;
    property Name: String read FName write FName;
    property PrimaryKey: TField read FPrimaryKey;
    property ReturningFields: TArray<TField> read FReturningFields;
  end;

  TSequence = class
  private
    FName: String;
  public
    constructor Create(const Name: String);

    property Name: String read FName write FName;
  end;

  TDefaultConstraint = class
  private
    FAutoGeneratedType: TAutoGeneratedType;
    FDatabaseName: String;
    FFixedValue: String;
    FSequence: TSequence;
  public
    property AutoGeneratedType: TAutoGeneratedType read FAutoGeneratedType write FAutoGeneratedType;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property FixedValue: String read FFixedValue write FFixedValue;
    property Sequence: TSequence read FSequence write FSequence;
  end;

  TField = class(TTableObject)
  private
    FAutoGenerated: Boolean;
    FCollation: String;
    FDatabaseName: String;
    FDefaultConstraint: TDefaultConstraint;
    FFieldType: TRttiType;
    FForeignKey: TForeignKey;
    FIndex: Integer;
    FInPrimaryKey: Boolean;
    FIsForeignKey: Boolean;
    FIsInheritedLink: Boolean;
    FIsLazy: Boolean;
    FIsManyValueAssociation: Boolean;
    FIsNullable: Boolean;
    FIsReadOnly: Boolean;
    FManyValueAssociation: TManyValueAssociation;
    FName: String;
    FPropertyInfo: TRttiInstanceProperty;
    FRequired: Boolean;
    FScale: Word;
    FSize: Word;
    FSpecialType: TDatabaseSpecialType;
  strict private
    function GetLazyValue(const Instance: TObject): ILazyValue;
    function GetPropertyValue(const Instance: TObject): TValue;
    function GetValue(const Instance: TObject): TValue; virtual;

    procedure SetLazyValue(const Instance: TObject; const Value: ILazyValue);
    procedure SetValue(const Instance: TObject; const Value: TValue); overload;
  public
    destructor Destroy; override;

    function HasValue(const Instance: TObject; var Value: TValue): Boolean;

    property AutoGenerated: Boolean read FAutoGenerated;
    property Collation: String read FCollation write FCollation;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property DefaultConstraint: TDefaultConstraint read FDefaultConstraint write FDefaultConstraint;
    property FieldType: TRttiType read FFieldType write FFieldType;
    property ForeignKey: TForeignKey read FForeignKey write FForeignKey;
    property Index: Integer read FIndex;
    property InPrimaryKey: Boolean read FInPrimaryKey;
    property IsForeignKey: Boolean read FIsForeignKey write FIsForeignKey;
    property IsInheritedLink: Boolean read FIsInheritedLink;
    property IsLazy: Boolean read FIsLazy;
    property IsManyValueAssociation: Boolean read FIsManyValueAssociation;
    property IsReadOnly: Boolean read FIsReadOnly;
    property LazyValue[const Instance: TObject]: ILazyValue read GetLazyValue write SetLazyValue;
    property ManyValueAssociation: TManyValueAssociation read FManyValueAssociation;
    property Name: String read FName write FName;
    property PropertyInfo: TRttiInstanceProperty read FPropertyInfo;
    property Required: Boolean read FRequired write FRequired;
    property Scale: Word read FScale write FScale;
    property Size: Word read FSize write FSize;
    property SpecialType: TDatabaseSpecialType read FSpecialType write FSpecialType;
    property Value[const Instance: TObject]: TValue read GetValue write SetValue;
  end;

  TFieldAlias = record
  private
    FField: TField;
    FTableAlias: String;
  public
    constructor Create(TableAlias: String; Field: TField);

    property Field: TField read FField write FField;
    property TableAlias: String read FTableAlias write FTableAlias;
  end;

  TForeignKey = class(TTableObject)
  private
    FDatabaseName: String;
    FField: TField;
    FParentTable: TTable;
  public
    property DatabaseName: String read FDatabaseName;
    property Field: TField read FField;
    property ParentTable: TTable read FParentTable;
  end;

  TManyValueAssociation = class
  private
    FChildField: TField;
    FChildTable: TTable;
    FField: TField;
  public
    constructor Create(const Field: TField; const ChildTable: TTable; const ChildField: TField);

    property ChildField: TField read FChildField;
    property ChildTable: TTable read FChildTable;
    property Field: TField read FField;
  end;

  TIndex = class(TTableObject)
  private
    FDatabaseName: String;
    FFields: TArray<TField>;
    FPrimaryKey: Boolean;
    FUnique: Boolean;
  public
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Fields: TArray<TField> read FFields write FFields;
    property PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;
    property Unique: Boolean read FUnique write FUnique;
  end;

  TMapper = class
  private
    FContext: TRttiContext;
    FDefaultRecords: TDictionary<String, TObject>;
    FFieldComparer: IComparer<TField>;
    FSequences: TDictionary<String, TSequence>;
    FTables: TDictionary<TRttiInstanceType, TTable>;

    function CheckAttribute<T: TCustomAttribute>(const TypeInfo: TRttiType): Boolean;
    function CreateSequence(const Name: String): TSequence;
    function CreateIndex(const Table: TTable; const Name: String): TIndex;
    function GetFieldComparer: IComparer<TField>;
    function GetFieldDatabaseName(const Field: TField): String;
    function GetNameAttribute<T: TCustomNameAttribute>(const TypeInfo: TRttiNamedObject; var Name: String): Boolean;
    function GetSequences: TArray<TSequence>;
    function GetTableDatabaseName(const Table: TTable): String;
    function GetTables: TArray<TTable>;
    function IsSingleTableInheritance(const RttiType: TRttiInstanceType): Boolean;
    function LoadDefaultConstraint(const Field: TField): Boolean;
    function LoadTable(const TypeInfo: TRttiInstanceType): TTable;
    function SortFieldFunction(const Left, Right: TField): Integer;

    procedure AddTableManyValueAssociation(const Table: TTable; const Field: TField);
    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable); overload;
    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ClassInfoType: TRttiInstanceType); overload;
    procedure LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
    procedure LoadFieldTypeInfo(const Field: TField);
    procedure LoadTableFields(const TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableIndexes(const TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableInfo(const TypeInfo: TRttiInstanceType; const Table: TTable);

    property FieldComparer: IComparer<TField> read GetFieldComparer write FFieldComparer;
  public
    constructor Create;

    destructor Destroy; override;

    function GetTable(const ClassInfo: TClass): TTable; overload;
    function GetTable(const TypeInfo: PTypeInfo): TTable; overload;

    procedure AddDefaultRecord(const Value: TObject);
    procedure LoadAll; overload;
    procedure LoadAll(const Schema: TArray<TClass>); overload;

    property DefaultRecords: TDictionary<String, TObject> read FDefaultRecords;
    property Sequences: TArray<TSequence> read GetSequences;
    property Tables: TArray<TTable> read GetTables;
  end;

  TLazyAccess = record
  private
    FLazyValue: ILazyValue;
  public
    constructor Create(const LazyValue: ILazyValue);
  end;

  TLazyFactory = class(TInterfacedObject)
  private
    FFilterField: TField;
    FKeyValue: TValue;
    FLazyValue: TValue;
    FManager: TManager;

    function GetKey: TValue;
    function GetValue: TValue;

    procedure SetValue(const Value: TValue);
  protected
    function LoadValue: TValue; virtual; abstract;
  public
    constructor Create(const Manager: TManager; const FilterField: TField; const KeyValue: TValue);
  end;

  TLazyFactoryObject = class(TLazyFactory, ILazyValue)
  protected
    function LoadValue: TValue; override;
  end;

  TLazyFactoryManyValue = class(TLazyFactory, ILazyValue)
  protected
    function LoadValue: TValue; override;
  end;

  TClassLoader = class
  private
    FQueryBuilder: TQueryBuilder;

    function CreateLazyFactory(const LazyField: TField; const KeyValue: TValue): ILazyValue;
  public
    constructor Create(const QueryBuilder: TQueryBuilder);

    function Load: TValue;
  end;

  TQueryBuilderTableField = class
  private
    FDataSetField: Data.DB.TField;
    FField: TField;
    FFieldAlias: String;
  public
    constructor Create(const Field: TField; const FieldIndex: Integer);

    property DataSetField: Data.DB.TField read FDataSetField write FDataSetField;
    property Field: TField read FField write FField;
    property FieldAlias: String read FFieldAlias write FFieldAlias;
  end;

  TQueryBuilderTable = class
  private
    FAlias: String;
    FDatabaseFields: TList<TQueryBuilderTableField>;
    FForeignKeyField: TForeignKey;
    FForeignKeyTables: TList<TQueryBuilderTable>;
    FInheritedTable: TQueryBuilderTable;
    FManyValueAssociationField: TManyValueAssociation;
    FManyValueAssociationTables: TList<TQueryBuilderTable>;
    FPrimaryKeyField: TQueryBuilderTableField;
    FTable: TTable;
  public
    constructor Create(const ForeignKeyField: TForeignKey); overload;
    constructor Create(const ManyValueAssociationField: TManyValueAssociation); overload;
    constructor Create(const Table: TTable); overload;

    destructor Destroy; override;

    property Alias: String read FAlias write FAlias;
    property DatabaseFields: TList<TQueryBuilderTableField> read FDatabaseFields write FDatabaseFields;
    property ForeignKeyField: TForeignKey read FForeignKeyField write FForeignKeyField;
    property ForeignKeyTables: TList<TQueryBuilderTable> read FForeignKeyTables write FForeignKeyTables;
    property InheritedTable: TQueryBuilderTable read FInheritedTable write FInheritedTable;
    property ManyValueAssociationField: TManyValueAssociation read FManyValueAssociationField write FManyValueAssociationField;
    property ManyValueAssociationTables: TList<TQueryBuilderTable> read FManyValueAssociationTables write FManyValueAssociationTables;
    property PrimaryKeyField: TQueryBuilderTableField read FPrimaryKeyField write FPrimaryKeyField;
    property Table: TTable read FTable write FTable;
  end;

  TQueryBuilder = class
  private
    FLoader: TClassLoader;
    FManager: TManager;
    FOrderByFields: TList<TQueryBuilderOrderByField>;
    FParams: TParams;
    FQueryFrom: TQueryBuilderFrom;
    FQueryOpen: TObject;
    FQueryOrderBy: TObject;
    FQueryTable: TQueryBuilderTable;
    FQueryWhere: TQueryBuilderWhere;

    function BuildCommand: String;
    function OpenCursor: IDatabaseCursor;

    procedure AfterOpenDataSet(DataSet: TDataSet);
    procedure LoadTable(const Table: TTable);
  public
    constructor Create(const Manager: TManager);

    destructor Destroy; override;

    function All: TQueryBuilderFrom;
  end;

  TQueryBuilderFrom = class
  private
    FQueryBuilder: TQueryBuilder;
  public
    constructor Create(const QueryBuilder: TQueryBuilder);

    function From<T: class>: TQueryBuilderWhere<T>; overload;
    function From<T: class>(const Table: TTable): TQueryBuilderWhere<T>; overload;
  end;

  TQueryBuilderOpen<T: class> = class
  private
    FQueryBuilder: TQueryBuilder;
  public
    constructor Create(const QueryBuilder: TQueryBuilder);

    function All: TArray<T>;
    function One: T;
  end;

  TQueryBuilderOrderByField = class
  private
    FAscending: Boolean;
    FField: TQueryBuilderFieldSearch;
  public
    constructor Create(const Field: TQueryBuilderFieldSearch; const Ascending: Boolean);

    destructor Destroy; override;

    property Ascending: Boolean read FAscending;
    property Field: TQueryBuilderFieldSearch read FField write FField;
  end;

  TQueryBuilderOrderBy<T: class> = class
  private
    FQueryBuilder: TQueryBuilder;
  public
    constructor Create(const QueryBuilder: TQueryBuilder);

    function Field(const FieldName: String; const Ascending: Boolean = True): TQueryBuilderOrderBy<T>;
    function Open: TQueryBuilderOpen<T>;
  end;

  TQueryBuilderComparisonOperation = (qbcoNone, qbcoAnd, qbcoOr, qbcoEqual, qbcoNotEqual, qbcoGreaterThan, qbcoGreaterThanOrEqual, qbcoLessThan, qbcoLessThanOrEqual, qbcoIsNull,
    qbcoBetween, qbcoLike, qbcoValue, qbcoFieldName, qbcoLogicalNot);

  TQueryBuilderComparison = class
  private
    FField: TQueryBuilderFieldSearch;
    FLeft: TQueryBuilderComparison;
    FOperarion: TQueryBuilderComparisonOperation;
    FRight: TQueryBuilderComparison;
    FValue: Variant;
  public
    destructor Destroy; override;

    property Field: TQueryBuilderFieldSearch read FField;
    property Left: TQueryBuilderComparison read FLeft;
    property Operarion: TQueryBuilderComparisonOperation read FOperarion;
    property Right: TQueryBuilderComparison read FRight;
    property Value: Variant read FValue write FValue;
  end;

  TQueryBuilderFieldSearch = class
  private
    FFieldName: String;
  public
    constructor Create(const FieldName: String);

    property FieldName: String read FFieldName write FFieldName;
  end;

  TQueryBuilderComparisonHelper = record
  private
    FComparison: TQueryBuilderComparison;

    class function Create(const FieldName: TQueryBuilderFieldSearch): TQueryBuilderComparisonHelper; overload; static;
    class function Create(const Operation: TQueryBuilderComparisonOperation): TQueryBuilderComparisonHelper; overload; static;
    class function Create(const Operation: TQueryBuilderComparisonOperation; const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper; overload; static;
    class function Create(const Operation: TQueryBuilderComparisonOperation; const UnaryOperator: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper; overload; static;
    class function Create(const Value: Variant): TQueryBuilderComparisonHelper; overload; static;
  public
    function Between(const ValueStart, ValueEnd: Variant): TQueryBuilderComparisonHelper;
    function IsNull: TQueryBuilderComparisonHelper;
    function Like(const Value: String): TQueryBuilderComparisonHelper;

    class operator BitwiseAnd(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator BitwiseOr(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator Equal(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator GreaterThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator Implicit(const Value: Variant): TQueryBuilderComparisonHelper;
    class operator LessThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator LessThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator LogicalNot(const UnaryOperator: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
    class operator NotEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
  end;

  TQueryBuilderWhere = class
  private
    FComparison: TQueryBuilderComparison;
    FQueryBuilder: TQueryBuilder;
  public
    constructor Create(const QueryBuilder: TQueryBuilder);

    destructor Destroy; override;

    function Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere;
  end;

  TQueryBuilderWhere<T: class> = class(TQueryBuilderWhere)
  public
    function Open: TQueryBuilderOpen<T>;
    function OrderBy: TQueryBuilderOrderBy<T>;
    function Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
  end;

  [SingleTableInheritance]
  TDatabaseObject = class
  private
    FName: String;
  published
    property Name: String read FName write FName;
  end;

  [PrimaryKey('Name')]
  [TableName('PersistoDatabaseTable')]
  TDatabaseTable = class(TDatabaseObject)
  private
    FFields: TArray<TDatabaseField>;
    FForeignKeys: Lazy<TArray<TDatabaseForeignKey>>;
    FIndexes: Lazy<TArray<TDatabaseIndex>>;
  public
    property ForeignKeys: Lazy<TArray<TDatabaseForeignKey>> read FForeignKeys write FForeignKeys;
    property Indexes: Lazy<TArray<TDatabaseIndex>> read FIndexes write FIndexes;
  published
    [ManyValueAssociationLinkName('Table')]
    property Fields: TArray<TDatabaseField> read FFields write FFields;
  end;

  [PrimaryKey('Name')]
  [TableName('PersistoDatabaseTableField')]
  TDatabaseField = class(TDatabaseObject)
  private
    FCheck: TDatabaseCheckConstraint;
    FCollation: String;
    FDefaultConstraint: TDatabaseDefaultConstraint;
    FFieldType: TTypeKind;
    FRequired: Boolean;
    FTable: TDatabaseTable;
    FScale: Word;
    FSize: Word;
    FSpecialType: TDatabaseSpecialType;
  public
    property Check: TDatabaseCheckConstraint read FCheck write FCheck;
    property Collation: String read FCollation write FCollation;
    property DefaultConstraint: TDatabaseDefaultConstraint read FDefaultConstraint write FDefaultConstraint;
    property FieldType: TTypeKind read FFieldType write FFieldType;
    property Required: Boolean read FRequired write FRequired;
    property Scale: Word read FScale write FScale;
    property Size: Word read FSize write FSize;
    property SpecialType: TDatabaseSpecialType read FSpecialType write FSpecialType;
  published
    property Table: TDatabaseTable read FTable write FTable;
  end;

  TDatabaseIndex = class(TDatabaseObject)
  private
    FFields: TArray<TDatabaseField>;
    FPrimaryKey: Boolean;
    FTable: TDatabaseTable;
    FUnique: Boolean;
  public
    property Fields: TArray<TDatabaseField> read FFields write FFields;
    property PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;
    property Unique: Boolean read FUnique write FUnique;
  published
    property Table: TDatabaseTable read FTable write FTable;
  end;

  TDatabaseForeignKey = class(TDatabaseObject)
  private
    FFields: TArray<TDatabaseField>;
    FFieldsReference: TArray<TDatabaseField>;
    FReferenceTable: TDatabaseTable;
    FTable: TDatabaseTable;
  public
    property Fields: TArray<TDatabaseField> read FFields write FFields;
    property FieldsReference: TArray<TDatabaseField> read FFieldsReference write FFieldsReference;
    property ReferenceTable: TDatabaseTable read FReferenceTable write FReferenceTable;
  published
    property Table: TDatabaseTable read FTable write FTable;
  end;

  TDatabaseDefaultConstraint = class(TDatabaseObject)
  private
    FValue: String;
  public
    property Value: String read FValue write FValue;
  end;

  TDatabaseCheckConstraint = class(TDatabaseObject)
  private
    FCheck: String;
  public
    property Check: String read FCheck write FCheck;
  end;

  TDatabaseSequence = class(TDatabaseObject)
  end;

  TDatabaseSchemaUpdater = class
  private
    FDatabaseManipulator: IDatabaseManipulator;
    FManager: TManager;
    FManagerSchema: TManager;

    function CheckSameFields(const Fields: TArray<TField>; const DatabaseFields: TArray<TDatabaseField>): Boolean;
    function FieldInTheList(const DatabaseField: TDatabaseField; const DatabaseFields: TArray<TDatabaseField>): Boolean;

    procedure CheckChangingTheList<T>(const List: Lazy<TArray<T>>; const Func: TFunc<T, Boolean>);
    procedure CreateField(const Field: TField);
    procedure DropField(const DatabaseField: TDatabaseField);
    procedure DropForeignKey(const DatabaseForeignKey: TDatabaseForeignKey);
    procedure DropIndex(const DatabaseIndex: TDatabaseIndex);
    procedure DropTable(const DatabaseTable: TDatabaseTable);
    procedure RecreateField(const Field: TField; const DatabaseField: TDatabaseField);
  public
    constructor Create(const Manager: TManager);

    destructor Destroy; override;

    procedure UpdateDatabase;
  end;

  TDatabaseManipulator = class(TInterfacedObject)
  protected
    function CreateField(const Field: TField): String;
    function CreateForeignKey(const ForeignKey: TForeignKey): String;
    function CreateIndex(const Index: TIndex): String;
    function CreateTempField(const Field: TField): String;
    function DropDefaultConstraint(const Field: TDatabaseField): String;
    function DropField(const Field: TDatabaseField): String;
    function DropForeignKey(const ForeignKey: TDatabaseForeignKey): String;
    function DropIndex(const Index: TDatabaseIndex): String;
    function DropSequence(const Sequence: TDatabaseSequence): String;
    function DropTable(const Table: TDatabaseTable): String;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
    function MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
    function UpdateField(const SourceField, DestinyField: TField): String;
  end;

  TDatabaseClassGenerator = class
  private
    FManager: TManager;
  public
    constructor Create(const Manager: TManager);

    procedure GenerateFile(const Destiny: TStream);
  end;

  TStateObject = class
  private
    FObject: TObject;
    FOldValues: TArray<TValue>;

    function GetOldValue(const Field: TField): TValue;

    procedure SetOldValue(const Field: TField; const Value: TValue);
  public
    constructor Create(const Table: TTable; const &Object: TObject);

    destructor Destroy; override;

    property &Object: TObject read FObject write FObject;
    property OldValue[const Field: TField]: TValue read GetOldValue write SetOldValue;
  end;

  TManager = class
  private
    FConnection: IDatabaseConnection;
    FDatabaseManipulator: IDatabaseManipulator;
    FMapper: TMapper;
    FProcessedObjects: TDictionary<TObject, Boolean>;
    FQueryBuilder: TQueryBuilder;
    FStateObjects: TDictionary<String, TStateObject>;

    function BuildStateObjectKey(const Table: TTable; const PrimaryKeyValue: String): String; overload;
    function BuildStateObjectKey(const Table: TTable; const &Object: TObject): String; overload;
    function CheckStateObjectExists(const Table: TTable; const &Object: TObject): Boolean;
    function GetStateObject(const Table: TTable; const &Object: TObject): TStateObject;
    function InsertTable(const Table: TTable; const &Object: TObject): Boolean;
    function SaveTable(const Table: TTable; const &Object: TObject): Boolean;
    function UpdateTable(const Table: TTable; const &Object: TObject): Boolean;
    function TryGetStateObject(const StateObjectKey: String; var StateObject: TStateObject): Boolean;

    procedure AddStateObject(const StateObjectKey: String; const StateObject: TStateObject);
    procedure InternalUpdateTable(const Table: TTable; const &Object: TObject);
  public
    constructor Create(const Connection: IDatabaseConnection; const DatabaseManipulator: IDatabaseManipulator);

    destructor Destroy; override;

    function OpenCursor(const SQL: String): IDatabaseCursor;
    function PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
    function Select: TQueryBuilder;

    procedure Delete(const &Object: TObject);
    procedure ExectDirect(const SQL: String);
    procedure Insert(const &Object: TObject);
    procedure Save(const &Object: TObject);
    procedure Update(const &Object: TObject);
    procedure UpdateDatabaseSchema;

    property Mapper: TMapper read FMapper;
  end;

function Field(const Name: String): TQueryBuilderComparisonHelper;

implementation

uses System.Variants, System.SysConst, System.Math;

function Field(const Name: String): TQueryBuilderComparisonHelper;
begin
  Result := TQueryBuilderComparisonHelper.Create(TQueryBuilderFieldSearch.Create(Name));
end;

{ EFieldNotInCurrentSelection }

constructor EFieldNotInCurrentSelection.Create(const Field: TQueryBuilderFieldSearch);
begin
  inherited CreateFmt('Field "%s" not found in current selection!', [Field.FieldName]);
end;

{ EManyValueAssociationLinkError }

constructor EManyValueAssociationLinkError.Create(ParentTable, ChildTable: TTable);
begin
  inherited CreateFmt('The link between %s and %s can''t be maded. Check if it exists, as the same name of the parent table or has the attribute defining the name of the link!',
    [ParentTable.ClassTypeInfo.Name, ChildTable.ClassTypeInfo.Name]);
end;

{ EClassWithPrimaryKeyNullable }

constructor EClassWithPrimaryKeyNullable.Create(Table: TTable);
begin
  inherited CreateFmt('The primary key of the class %s is nullable, it''s not accepted!', [Table.ClassTypeInfo.Name]);
end;

{ EClassWithoutPrimaryKeyDefined }

constructor EClassWithoutPrimaryKeyDefined.Create(Table: TTable);
begin
  inherited CreateFmt('You must define a primary key for class %s!', [Table.ClassTypeInfo.Name])
end;

{ EForeignKeyToSingleTableInheritanceTable }

constructor EForeignKeyToSingleTableInheritanceTable.Create(ParentTable: TRttiInstanceType);
begin
  inherited CreateFmt('The parent table %s can''t be single inheritence table, check the implementation!', [ParentTable.Name]);
end;

{ EFieldIndexNotFound }

constructor EFieldIndexNotFound.Create(const Table: TTable; const FieldName: String);
begin
  inherited CreateFmt('Field "%s" not found in the table "%s"!', [Table.Name, FieldName]);
end;

{ ESequenceAlreadyExists }

constructor ESequenceAlreadyExists.Create(const SequenceName: String);
begin
  inherited CreateFmt('The sequence [%s] already exists!', [SequenceName]);
end;

{ ETableWithoutPublishedFields }

constructor ETableWithoutPublishedFields.Create(const Table: TTable);
begin
  inherited CreateFmt('The class %s hasn''t published field, check yout implementation!', [Table.Name]);
end;

{ EForeignObjectNotAllowed }

constructor EForeignObjectNotAllowed.Create;
begin
  inherited Create('Update foreign object isn''t allowed, the object must be inserted ou select from this manager!');
end;

{ TMapper }

procedure TMapper.AddDefaultRecord(const Value: TObject);
begin
  GetTable(Value.ClassType).DefaultRecords.Add(Value);
end;

procedure TMapper.AddTableForeignKey(const Table: TTable; const Field: TField; const ClassInfoType: TRttiInstanceType);
begin
  var ParentTable := LoadTable(ClassInfoType);

  if Assigned(ParentTable) then
    AddTableForeignKey(Table, Field, ParentTable)
  else
    raise EForeignKeyToSingleTableInheritanceTable.Create(ClassInfoType);
end;

procedure TMapper.AddTableManyValueAssociation(const Table: TTable; const Field: TField);

  function GetManyValueAssociationLinkName: String;
  begin
    if not GetNameAttribute<ManyValueAssociationLinkNameAttribute>(Field.PropertyInfo, Result) then
      Result := Field.Table.Name;
  end;

begin
  var ChildTable := LoadTable(Field.FieldType.AsArray.ElementType.AsInstance);

  if Assigned(Table.PrimaryKey) then
  begin
    var LinkName := GetManyValueAssociationLinkName;

    for var ChildField in ChildTable.Fields do
      if ChildField.Name = LinkName then
        Field.FManyValueAssociation := TManyValueAssociation.Create(Field, ChildTable, ChildField);

    if Assigned(Field.ManyValueAssociation) then
      Table.FManyValueAssociations := Table.FManyValueAssociations + [Field.ManyValueAssociation]
    else
      raise EManyValueAssociationLinkError.Create(Table, ChildTable);
  end
  else
    raise EClassWithoutPrimaryKeyDefined.Create(Table);
end;

procedure TMapper.AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable);

  function GetForeignKeyName: String;
  begin
    if not GetNameAttribute<ForeignKeyNameAttribute>(Field.PropertyInfo, Result) then
      Result := Format('FK_%s_%s_%s', [Table.DatabaseName, ForeignTable.DatabaseName, Field.DatabaseName]);
  end;

begin
  if Assigned(ForeignTable.PrimaryKey) then
  begin
    var ForeignKey := TForeignKey.Create(Table);
    ForeignKey.FDatabaseName := GetForeignKeyName;
    ForeignKey.FField := Field;
    ForeignKey.FParentTable := ForeignTable;

    Field.FForeignKey := ForeignKey;
    Table.FForeignKeys := Table.FForeignKeys + [ForeignKey];

    LoadFieldTypeInfo(Field);
  end
  else
    raise EClassWithoutPrimaryKeyDefined.Create(ForeignTable);
end;

function TMapper.CheckAttribute<T>(const TypeInfo: TRttiType): Boolean;
begin
  Result := False;

  for var TypeToCompare in TypeInfo.GetAttributes do
    if TypeToCompare is T then
      Exit(True);
end;

constructor TMapper.Create;
begin
  inherited;

  FContext := TRttiContext.Create;
  FDefaultRecords := TDictionary<String, TObject>.Create;
  FSequences := TObjectDictionary<String, TSequence>.Create([doOwnsValues]);
  FTables := TObjectDictionary<TRttiInstanceType, TTable>.Create([doOwnsValues]);
end;

function TMapper.CreateIndex(const Table: TTable; const Name: String): TIndex;
begin
  Result := TIndex.Create(Table);
  Result.DatabaseName := Name;

  Table.FIndexes := Table.Indexes + [Result];
end;

function TMapper.CreateSequence(const Name: String): TSequence;
begin
  if FSequences.ContainsKey(Name) then
    raise ESequenceAlreadyExists.Create(Name)
  else
  begin
    Result := TSequence.Create(Name);

    FSequences.Add(Name, Result);
  end;
end;

destructor TMapper.Destroy;
begin
  FContext.Free;

  FDefaultRecords.Free;

  FSequences.Free;

  FTables.Free;

  inherited;
end;

function TMapper.GetFieldComparer: IComparer<TField>;
begin
  if not Assigned(FFieldComparer) then
    FFieldComparer := TDelegatedComparer<TField>.Create(SortFieldFunction);

  Result := FFieldComparer;
end;

function TMapper.GetFieldDatabaseName(const Field: TField): String;
begin
  if not GetNameAttribute<FieldNameAttribute>(Field.PropertyInfo, Result) then
  begin
    Result := Field.Name;

    if Field.IsForeignKey then
      Result := 'Id' + Result;
  end;
end;

function TMapper.GetNameAttribute<T>(const TypeInfo: TRttiNamedObject; var Name: String): Boolean;
begin
  var Attribute := TypeInfo.GetAttribute<T>;
  Result := Assigned(Attribute);

  if Result then
    Name := Attribute.Name;
end;

function TMapper.GetSequences: TArray<TSequence>;
begin
  Result := FSequences.Values.ToArray;
end;

function TMapper.GetTable(const TypeInfo: PTypeInfo): TTable;
begin
  Result := LoadTable(FContext.GetType(TypeInfo).AsInstance);
end;

function TMapper.GetTable(const ClassInfo: TClass): TTable;
begin
  Result := GetTable(ClassInfo.ClassInfo);
end;

function TMapper.GetTableDatabaseName(const Table: TTable): String;
begin
  if not GetNameAttribute<TableNameAttribute>(Table.ClassTypeInfo, Result) then
    Result := Table.Name;
end;

function TMapper.GetTables: TArray<TTable>;
begin
  Result := FTables.Values.ToArray;
end;

function TMapper.IsSingleTableInheritance(const RttiType: TRttiInstanceType): Boolean;
begin
  Result := RttiType.GetAttribute<SingleTableInheritanceAttribute> <> nil;
end;

procedure TMapper.LoadAll;
begin
  LoadAll(nil);
end;

procedure TMapper.LoadAll(const Schema: TArray<TClass>);
begin
  var SchemaList := EmptyStr;

  FSequences.Clear;

  FTables.Clear;

  for var AClass in Schema do
    SchemaList := Format('%s;%s;', [SchemaList, AClass.UnitName]);

  for var TypeInfo in FContext.GetTypes do
    if CheckAttribute<EntityAttribute>(TypeInfo) and (SchemaList.IsEmpty or (SchemaList.IndexOf(Format(';%s;', [TypeInfo.AsInstance.DeclaringUnitName])) > -1)) then
      GetTable(TypeInfo.Handle);
end;

function TMapper.LoadDefaultConstraint(const Field: TField): Boolean;
begin
  var Attribute := Field.PropertyInfo.GetAttribute<TAutoGeneratedAttribute>;
  Result := Assigned(Attribute);

  if Result then
  begin
    Field.FDefaultConstraint := TDefaultConstraint.Create;
    Field.FDefaultConstraint.AutoGeneratedType := Attribute.&Type;
    Field.FDefaultConstraint.DatabaseName := Format('DF_%s_%s', [Field.Table.DatabaseName, Field.DatabaseName]);

    if Attribute is SequenceAttribute then
      Field.FDefaultConstraint.Sequence := CreateSequence(SequenceAttribute(Attribute).Name);

    if Attribute is FixedValueAttribute then
      Field.FDefaultConstraint.FixedValue := FixedValueAttribute(Attribute).Value;
  end;
end;

procedure TMapper.LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
begin
  Field.FFieldType := PropertyInfo.PropertyType;
  Field.FIndex := Length(Table.FFields);
  Field.FIsReadOnly := not PropertyInfo.IsWritable;
  Field.FName := PropertyInfo.Name;
  Field.FPropertyInfo := PropertyInfo;
  Field.FTable := Table;
  Table.FFields := Table.FFields + [Field];

  Field.FIsLazy := IsLazy(Field.FieldType);
  Field.FIsNullable := TNullableManipulator.IsNullable(Field.PropertyInfo);

//  if Field.FIsNullable then
//    Field.FFieldType := TNullableManipulator.GetNullableType(Field.PropertyInfo)
//  else
  if Field.IsLazy then
    Field.FFieldType := GetLazyType(Field.FieldType);

  Field.FIsForeignKey := Field.FieldType.IsInstance;
  Field.FIsManyValueAssociation := Field.FieldType.IsArray;
  Field.FRequired := PropertyInfo.HasAttribute<RequiredAttribute> or not Field.FIsNullable and not (Field.FieldType.TypeKind in [tkClass]);

  Field.FDatabaseName := GetFieldDatabaseName(Field);

  if not Field.IsForeignKey then
    LoadFieldTypeInfo(Field);

  Field.FAutoGenerated := LoadDefaultConstraint(Field);

  if Field.AutoGenerated then
    Table.FReturningFields := Table.FReturningFields + [Field];
end;

procedure TMapper.LoadFieldTypeInfo(const Field: TField);
begin
  if Field.IsForeignKey then
  begin
    Field.FFieldType := Field.ForeignKey.ParentTable.PrimaryKey.FieldType;
    Field.FScale := Field.ForeignKey.ParentTable.PrimaryKey.Scale;
    Field.FSize := Field.ForeignKey.ParentTable.PrimaryKey.Size;
    Field.FSpecialType := Field.ForeignKey.ParentTable.PrimaryKey.SpecialType;
  end
  else
  begin
    var FieldInfo := Field.PropertyInfo.GetAttribute<FieldInfoAttribute>;

    if Assigned(FieldInfo) then
    begin
      Field.FScale := FieldInfo.Scale;
      Field.FSize := FieldInfo.Size;
      Field.FSpecialType := FieldInfo.SpecialType;
    end
    else if Field.FieldType.Handle = TypeInfo(TDate) then
      Field.FSpecialType := stDate
    else if Field.FieldType.Handle = TypeInfo(TDateTime) then
      Field.FSpecialType := stDateTime
    else if Field.FieldType.Handle = TypeInfo(TTime) then
      Field.FSpecialType := stTime
    else if Field.FieldType.Handle = TypeInfo(Boolean) then
      Field.FSpecialType := stBoolean;
  end;
end;

function TMapper.LoadTable(const TypeInfo: TRttiInstanceType): TTable;
begin
  if not FTables.TryGetValue(TypeInfo, Result) and not IsSingleTableInheritance(TypeInfo) then
  begin
    Result := TTable.Create(TypeInfo);
    Result.FMapper := Self;
    Result.FName := TypeInfo.Name.Substring(1);

    Result.FDatabaseName := GetTableDatabaseName(Result);

    FTables.Add(TypeInfo, Result);

    LoadTableInfo(TypeInfo, Result);
  end;
end;

procedure TMapper.LoadTableFields(const TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  for var Prop in TypeInfo.GetDeclaredProperties do
    if Prop.Visibility = mvPublished then
      LoadFieldInfo(Table, Prop as TRttiInstanceProperty, TField.Create(Table));

  if Table.Fields = nil then
    raise ETableWithoutPublishedFields.Create(Table);
end;

procedure TMapper.LoadTableIndexes(const TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  for var Attribute in TypeInfo.GetAttributes do
    if Attribute is IndexAttribute then
    begin
      var IndexInfo := IndexAttribute(Attribute);

      var Index := CreateIndex(Table, IndexInfo.Name);
      Index.Unique := Attribute is UniqueKeyAttribute;

      for var FieldName in IndexInfo.Fields.Split([';']) do
      begin
        var Field: TField;

        if not Table.FindField(FieldName, Field) then
          raise EFieldIndexNotFound.Create(Table, FieldName);

        Index.Fields := Index.Fields + [Field];
      end;
    end;
end;

procedure TMapper.LoadTableInfo(const TypeInfo: TRttiInstanceType; const Table: TTable);

  function GetPrimaryKeyPropertyName: String;
  begin
    var Attribute := TypeInfo.GetAttribute<PrimaryKeyAttribute>;

    if Assigned(Attribute) then
      Result := Attribute.Name
    else
      Result := 'Id';
  end;

  procedure LoadPrimaryKeyInfo;
  begin
    var Field := Table.Field[GetPrimaryKeyPropertyName];

    if Assigned(Field) then
      if Field.FIsNullable then
        raise EClassWithPrimaryKeyNullable.Create(Table)
      else
      begin
        Field.FInPrimaryKey := True;
        Table.FPrimaryKey := Field;

        var PrimaryKeyIndex := CreateIndex(Table, Format('PK_%s', [Table.DatabaseName]));
        PrimaryKeyIndex.Fields := [Field];
        PrimaryKeyIndex.PrimaryKey := True;
        PrimaryKeyIndex.Unique := True;
      end;
  end;

begin
  var BaseClassInfo := TypeInfo.BaseType;

  LoadTableFields(TypeInfo, Table);

  while BaseClassInfo.MetaclassType <> TObject do
  begin
    if IsSingleTableInheritance(BaseClassInfo) then
      LoadTableFields(BaseClassInfo, Table)
    else
    begin
      Table.FBaseTable := LoadTable(BaseClassInfo);
      Table.FPrimaryKey := TField.Create(Table);

      Table.FPrimaryKey.FIsInheritedLink := True;
      Table.FAllFieldCount := Table.FBaseTable.AllFieldCount;

      LoadFieldInfo(Table, Table.BaseTable.PrimaryKey.PropertyInfo, Table.FPrimaryKey);

      Table.FPrimaryKey.FAutoGenerated := False;

      AddTableForeignKey(Table, Table.FPrimaryKey, Table.BaseTable);

      Break;
    end;

    BaseClassInfo := BaseClassInfo.BaseType
  end;

  LoadPrimaryKeyInfo;

  for var Field in Table.Fields do
  begin
    Inc(Field.FIndex, Table.FAllFieldCount);

    if Field.IsManyValueAssociation then
      AddTableManyValueAssociation(Table, Field)
    else if Field.IsForeignKey then
      AddTableForeignKey(Table, Field, Field.FieldType.AsInstance);
  end;

  Inc(Table.FAllFieldCount, Length(Table.Fields));

  TArray.Sort<TField>(Table.FFields, FieldComparer);

  LoadTableIndexes(TypeInfo, Table);
end;

function TMapper.SortFieldFunction(const Left, Right: TField): Integer;

  function FieldPriority(const Field: TField): Integer;
  begin
    if Field.InPrimaryKey then
      Result := 1
    else if Field.IsLazy then
      Result := 2
    else if Field.IsForeignKey then
      Result := 3
    else if Field.IsManyValueAssociation then
      Result := 4
    else
      Result := 2;
  end;

begin
  Result := FieldPriority(Left) - FieldPriority(Right);

  if Result = 0 then
    Result := CompareStr(Left.DatabaseName, Right.DatabaseName);
end;

{ TTable }

constructor TTable.Create(TypeInfo: TRttiInstanceType);
begin
  inherited Create;

  FClassTypeInfo := TypeInfo;
end;

destructor TTable.Destroy;
begin
  for var Field in Fields do
    Field.Free;

  for var ForeignKey in ForeignKeys do
    ForeignKey.Free;

  for var ManyValueAssociation in ManyValueAssociations do
    ManyValueAssociation.Free;

  for var Index in Indexes do
    Index.Free;

  FDefaultRecords.Free;

  inherited;
end;

function TTable.FindField(const FieldName: String; var Field: TField): Boolean;
begin
  Field := nil;
  Result := False;

  for var TableField in Fields do
    if TableField.Name = FieldName then
    begin
      Field := TableField;

      Exit(True);
    end;
end;

function TTable.GetDefaultRecords: TList<TObject>;
begin
  if not Assigned(FDefaultRecords) then
    FDefaultRecords := TList<TObject>.Create;

  Result := FDefaultRecords;
end;

function TTable.GetField(const FieldName: String): TField;
begin
  FindField(FieldName, Result);
end;

function TTable.GetHasPrimaryKey: Boolean;
begin
  Result := Assigned(FPrimaryKey);
end;

{ TFieldAlias }

constructor TFieldAlias.Create(TableAlias: String; Field: TField);
begin
  FField := Field;
  FTableAlias := TableAlias;
end;

{ TManyValueAssociation }

constructor TManyValueAssociation.Create(const Field: TField; const ChildTable: TTable; const ChildField: TField);
begin
  inherited Create;

  FChildField := ChildField;
  FChildTable := ChildTable;
  FField := Field;
end;

{ TField }

destructor TField.Destroy;
begin
  FDefaultConstraint.Free;

  inherited;
end;

function TField.GetLazyValue(const Instance: TObject): ILazyValue;
begin
  Result := PropertyInfo.PropertyType.GetMethod('GetLazyValue').Invoke(GetPropertyValue(Instance), []).AsType<ILazyValue>;
end;

function TField.GetPropertyValue(const Instance: TObject): TValue;
begin
  Result := PropertyInfo.GetValue(Instance);
end;

function TField.GetValue(const Instance: TObject): TValue;
begin
  HasValue(Instance, Result);
end;

function TField.HasValue(const Instance: TObject; var Value: TValue): Boolean;
begin
  if IsLazy then
  begin
    var Lazy := LazyValue[Instance];
    Value := Lazy.Key;

    if Value.IsEmpty then
      Value := Lazy.Value;
  end
  else if FIsNullable then
    Value := TNullableManipulator.GetManipulator(Instance, PropertyInfo).Value
  else
    Value := GetPropertyValue(Instance);

  Result := not Value.IsEmpty;
end;

procedure TField.SetLazyValue(const Instance: TObject; const Value: ILazyValue);
begin
  var LazyInstance := PByte(Instance) + (IntPtr(PropertyInfo.PropInfo^.GetProc) and (not PROPSLOT_MASK));

  PropertyInfo.PropertyType.GetField('FLazyValue').SetValue(LazyInstance, TValue.From(Value));
end;

procedure TField.SetValue(const Instance: TObject; const Value: TValue);
begin
  if FIsNullable then
    TNullableManipulator.GetManipulator(Instance, PropertyInfo).Value := Value
  else if IsLazy then
    LazyValue[Instance].Value := Value
  else
    PropertyInfo.SetValue(Instance, Value);
end;

{ TTableObject }

constructor TTableObject.Create(const Table: TTable);
begin
  inherited Create;

  FTable := Table;
end;

{ TSequence }

constructor TSequence.Create(const Name: String);
begin
  inherited Create;

  FName := Name;
end;

{ TLazyFactory }

constructor TLazyFactory.Create(const Manager: TManager; const FilterField: TField; const KeyValue: TValue);
begin
  inherited Create;

  FFilterField := FilterField;
  FKeyValue := KeyValue;
  FManager := Manager;
end;

function TLazyFactory.GetKey: TValue;
begin
  Result := FKeyValue;
end;

function TLazyFactory.GetValue: TValue;
begin
  if FLazyValue.IsEmpty then
    FLazyValue := LoadValue;

  Result := FLazyValue;
end;

procedure TLazyFactory.SetValue(const Value: TValue);
begin
  FKeyValue := TValue.Empty;
  FLazyValue := Value;
end;

{ TLazyFactoryObject }

function TLazyFactoryObject.LoadValue: TValue;
begin
  Result := FManager.Select.All.From<TObject>(FFilterField.Table).Where(Field(FFilterField.Name) = FKeyValue.AsVariant).Open.One;
end;

{ TLazyFactoryManyValue }

function TLazyFactoryManyValue.LoadValue: TValue;
begin
  FManager.Select.All.From<TObject>(FFilterField.FTable).Where(Field(FFilterField.Name) = FKeyValue.AsVariant).Open;

  Result := FManager.FQueryBuilder.FLoader.Load;
end;

{ TClassLoader }

constructor TClassLoader.Create(const QueryBuilder: TQueryBuilder);
begin
  inherited Create;

  FQueryBuilder := QueryBuilder;
end;

function TClassLoader.CreateLazyFactory(const LazyField: TField; const KeyValue: TValue): ILazyValue;
begin
  if LazyField.IsManyValueAssociation then
    Result := TLazyFactoryManyValue.Create(FQueryBuilder.FManager, LazyField.ManyValueAssociation.ChildField, KeyValue)
  else
    Result := TLazyFactoryObject.Create(FQueryBuilder.FManager, LazyField.ForeignKey.Field, KeyValue);
end;

function TClassLoader.Load: TValue;
var
  LoadedObjects: TDictionary<TObject, Boolean>;

  ManyValueLoadedObjects: TDictionary<String, Boolean>;

  function BuildStateObjectKey(const QueryTable: TQueryBuilderTable): String;
  begin
    Result := FQueryBuilder.FManager.BuildStateObjectKey(QueryTable.Table, QueryTable.PrimaryKeyField.DataSetField.AsString);
  end;

  function BuildStateObjectKeyManyValue(const QueryTable: TQueryBuilderTable): String;
  begin
    Result := '#.' + BuildStateObjectKey(QueryTable);
  end;

  function CheckManyValueLoaded(const QueryTable: TQueryBuilderTable): Boolean;
  begin
    Result := not ManyValueLoadedObjects.TryAdd(BuildStateObjectKeyManyValue(QueryTable), False);
  end;

  function CreateObject(const QueryTable: TQueryBuilderTable): TStateObject;
  begin
    var StateObjectKey := BuildStateObjectKey(QueryTable);

    if not FQueryBuilder.FManager.TryGetStateObject(StateObjectKey, Result) then
    begin
      Result := TStateObject.Create(QueryTable.Table, QueryTable.Table.ClassTypeInfo.MetaclassType.Create);

      FQueryBuilder.FManager.AddStateObject(StateObjectKey, Result);
    end;
  end;

  procedure LoadFieldValues(const QueryTable: TQueryBuilderTable; const StateObject: TStateObject);
  var
    ArrayLength: Integer;

    Field: TField;

    FieldValue: TValue;

    ForeignKeyTable, ManyValueAssociationTable: TQueryBuilderTable;

    ForeignObject, ManyValueObject: TStateObject;

  begin
    for var QueryField in QueryTable.DatabaseFields do
    begin
      Field := QueryField.Field;

      if QueryField.DataSetField.IsNull then
        FieldValue := TValue.Empty
      else
      begin
        FieldValue := TValue.FromVariant(QueryField.DataSetField.AsVariant);

        if Field.IsLazy then
          Field.LazyValue[StateObject.&Object] := CreateLazyFactory(Field, FieldValue);
      end;

      Field.Value[StateObject.&Object] := FieldValue;
      StateObject.OldValue[Field] := FieldValue;
    end;

    if Assigned(QueryTable.InheritedTable) then
      LoadFieldValues(QueryTable.InheritedTable, StateObject);

    for ForeignKeyTable in QueryTable.ForeignKeyTables do
      if not ForeignKeyTable.PrimaryKeyField.DataSetField.IsNull then
      begin
        ForeignObject := CreateObject(ForeignKeyTable);
        StateObject.OldValue[ForeignKeyTable.ForeignKeyField.Field] := TValue.FromVariant(ForeignKeyTable.PrimaryKeyField.DataSetField.AsVariant);

        ForeignKeyTable.ForeignKeyField.Field.Value[StateObject.&Object] := ForeignObject.&Object;

        LoadFieldValues(ForeignKeyTable, ForeignObject);
      end;

    for ManyValueAssociationTable in QueryTable.ManyValueAssociationTables do
      if not ManyValueAssociationTable.PrimaryKeyField.DataSetField.IsNull then
      begin
        ManyValueObject := CreateObject(ManyValueAssociationTable);

        if not CheckManyValueLoaded(ManyValueAssociationTable) then
        begin
          FieldValue := ManyValueAssociationTable.ManyValueAssociationField.Field.Value[StateObject.&Object];

          ArrayLength := FieldValue.ArrayLength;
          FieldValue.ArrayLength := ArrayLength + 1;

          FieldValue.SetArrayElement(ArrayLength, ManyValueObject.&Object);

          ManyValueAssociationTable.ManyValueAssociationField.Field.Value[StateObject.&Object] := FieldValue;
        end;

        LoadFieldValues(ManyValueAssociationTable, ManyValueObject);
      end;
  end;

begin
  var Cursor := FQueryBuilder.OpenCursor;
  LoadedObjects := TDictionary<TObject, Boolean>.Create;
  ManyValueLoadedObjects := TDictionary<String, Boolean>.Create;

  while Cursor.Next do
  begin
    var StateObject := CreateObject(FQueryBuilder.FQueryTable);

    LoadedObjects.AddOrSetValue(StateObject.&Object, False);

    LoadFieldValues(FQueryBuilder.FQueryTable, StateObject);
  end;

  Result := TValue.From<TArray<TObject>>(LoadedObjects.Keys.ToArray);

  ManyValueLoadedObjects.Free;

  LoadedObjects.Free;
end;

{ TQueryBuilderFrom }

constructor TQueryBuilderFrom.Create(const QueryBuilder: TQueryBuilder);
begin
  inherited Create;

  FQueryBuilder := QueryBuilder;
end;

function TQueryBuilderFrom.From<T>: TQueryBuilderWhere<T>;
begin
  Result := From<T>(FQueryBuilder.FManager.Mapper.GetTable(TypeInfo(T)));
end;

function TQueryBuilderFrom.From<T>(const Table: TTable): TQueryBuilderWhere<T>;
begin
  FQueryBuilder.LoadTable(Table);

  Result := TQueryBuilderWhere<T>.Create(FQueryBuilder);
end;

{ TQueryBuilder }

procedure TQueryBuilder.AfterOpenDataSet(DataSet: TDataSet);
var
  FieldIndex: Integer;

  procedure LoadDataSetFields(const QueryTable: TQueryBuilderTable);
  begin
    for var DatabaseField in QueryTable.DatabaseFields do
    begin
      DatabaseField.DataSetField := DataSet.Fields[FieldIndex];

      Inc(FieldIndex);
    end;

    if Assigned(QueryTable.InheritedTable) then
      LoadDataSetFields(QueryTable.InheritedTable);

    for var ForiegnKeyTable in QueryTable.ForeignKeyTables do
      LoadDataSetFields(ForiegnKeyTable);

    for var ManyValueAssociationTable in QueryTable.ManyValueAssociationTables do
      LoadDataSetFields(ManyValueAssociationTable);
  end;

begin
  FieldIndex := 0;

  LoadDataSetFields(FQueryTable);
end;

function TQueryBuilder.All: TQueryBuilderFrom;
begin
  FQueryFrom := TQueryBuilderFrom.Create(Self);
  Result := FQueryFrom;
end;

function TQueryBuilder.BuildCommand: String;
const
  STRING_BUILDER_START_CAPACITY = $2FF;

var
  FieldIndex, TableIndex: Integer;

  RecursiveControl: TDictionary<TField, Boolean>;

  SQL: TStringBuilder;

  procedure AppendFieldName(const QueryTable: TQueryBuilderTable; const Field: TField);
  begin
    SQL.Append(QueryTable.Alias).Append('.').Append(Field.DatabaseName);
  end;

  procedure LoadFieldList(const QueryTable: TQueryBuilderTable; const FieldToIgnore: TField);
  var
    DatabaseField: TQueryBuilderTableField;

    Field: TField;

    ForeignKeyTable, ManyValueAssociationTable: TQueryBuilderTable;

  begin
    QueryTable.Alias := 'T' + TableIndex.ToString;

    Inc(TableIndex);

    for Field in QueryTable.Table.Fields do
      if Field.IsInheritedLink then
        QueryTable.InheritedTable := TQueryBuilderTable.Create(Field.ForeignKey.ParentTable)
      else if Field.IsManyValueAssociation then
        QueryTable.ManyValueAssociationTables.Add(TQueryBuilderTable.Create(Field.ManyValueAssociation))
      else if Field.IsForeignKey and not Field.IsLazy then
      begin
        if Field <> FieldToIgnore then
        begin
          if not RecursiveControl.TryAdd(Field, False) then
            raise ERecursionSelectionError.Create(Format('%s.%s', [Field.Table.Name, Field.Name]));

          QueryTable.ForeignKeyTables.Add(TQueryBuilderTable.Create(Field.ForeignKey));
        end;
      end
      else
      begin
        DatabaseField := TQueryBuilderTableField.Create(Field, FieldIndex);

        if Field.InPrimaryKey then
          QueryTable.PrimaryKeyField := DatabaseField;

        if FieldIndex > 1 then
          SQL.Append(',');

        AppendFieldName(QueryTable, Field);

        SQL.Append(' ').Append(DatabaseField.FieldAlias);

        QueryTable.DatabaseFields.Add(DatabaseField);

        Inc(FieldIndex);
      end;

    if Assigned(QueryTable.InheritedTable) then
    begin
      LoadFieldList(QueryTable.InheritedTable, nil);

      QueryTable.PrimaryKeyField := QueryTable.InheritedTable.PrimaryKeyField;
    end;

    for ForeignKeyTable in QueryTable.ForeignKeyTables do
      try
        LoadFieldList(ForeignKeyTable, nil);
      except
        on E: ERecursionSelectionError do
          raise ERecursionSelectionError.Create(Format('%s.%s->%s', [ForeignKeyTable.Table.Name, ForeignKeyTable.ForeignKeyField.Field.Name, E.RecursionTree]));
      end;

    for ManyValueAssociationTable in QueryTable.ManyValueAssociationTables do
      LoadFieldList(ManyValueAssociationTable, ManyValueAssociationTable.ManyValueAssociationField.ChildField);
  end;

  procedure BuildJoin(const QueryTable: TQueryBuilderTable);
  var
    ManyValueAssociationTable, ForeignKeyTable: TQueryBuilderTable;

    procedure MakeJoin(const QueryTable: TQueryBuilderTable; const QueryTableField: TField; const ForeignQueryTable: TQueryBuilderTable; const ForeignField: TField);
    begin
      SQL.Append(' left join ');

      SQL.Append(ForeignQueryTable.Table.DatabaseName).Append(' ').Append(ForeignQueryTable.Alias);

      SQL.Append(' on ');

      AppendFieldName(ForeignQueryTable, QueryTableField);

      SQL.Append('=');

      AppendFieldName(QueryTable, ForeignField);
    end;

    procedure MakeForeignKeyJoin(const QueryTable, ForeignQueryTable: TQueryBuilderTable; const LinkField: TField);
    begin
      MakeJoin(QueryTable, QueryTable.PrimaryKeyField.Field, ForeignQueryTable, LinkField);

      BuildJoin(ForeignQueryTable);
    end;

    procedure MakeManyValueAssociationJoin(const QueryTable, ManyValueAssociationTable: TQueryBuilderTable);
    begin
      MakeJoin(QueryTable, ManyValueAssociationTable.ManyValueAssociationField.ChildField, ManyValueAssociationTable, QueryTable.PrimaryKeyField.Field);

      BuildJoin(ManyValueAssociationTable);
    end;

  begin
    if Assigned(QueryTable.InheritedTable) then
      MakeForeignKeyJoin(QueryTable, QueryTable.InheritedTable, QueryTable.Table.PrimaryKey);

    for ForeignKeyTable in QueryTable.ForeignKeyTables do
      MakeForeignKeyJoin(QueryTable, ForeignKeyTable, ForeignKeyTable.ForeignKeyField.Field);

    for ManyValueAssociationTable in QueryTable.ManyValueAssociationTables do
      MakeManyValueAssociationJoin(QueryTable, ManyValueAssociationTable);
  end;

  function FindQueryField(const FieldNameToFind: TQueryBuilderFieldSearch; var CurrentTable: TQueryBuilderTable): TQueryBuilderTableField;
  var
    FieldName: String;

    function FindTable(const QueryTable: TQueryBuilderTable; const FindFieldName: String): TQueryBuilderTable;
    begin
      Result := nil;

      if Assigned(QueryTable) then
      begin
        for var FindTable in QueryTable.ForeignKeyTables do
          if FindTable.ForeignKeyField.Field.Name = FindFieldName then
            Exit(FindTable);

        for var FindTable in QueryTable.ManyValueAssociationTables do
          if FindTable.ManyValueAssociationField.Field.Name = FindFieldName then
            Exit(FindTable);

        if Assigned(QueryTable.InheritedTable) then
          Result := FindTable(QueryTable.InheritedTable, FindFieldName);
      end;
    end;

    function FindField: TQueryBuilderTableField;
    begin
      if Assigned(CurrentTable) then
      begin
        for var FindFieldName in CurrentTable.DatabaseFields do
          if FindFieldName.Field.Name = FieldName then
            Exit(FindFieldName);

        CurrentTable := CurrentTable.InheritedTable;

        Result := FindField;
      end
      else
        raise EFieldNotInCurrentSelection.Create(FieldNameToFind);
    end;

  begin
    CurrentTable := FQueryTable;
    var FieldNameList := TList<String>.Create(FieldNameToFind.FieldName.Split(['.']));

    FieldName := FieldNameList.ExtractAt(Pred(FieldNameList.Count));

    for var FindFieldName in FieldNameList do
      CurrentTable := FindTable(CurrentTable, FindFieldName);

    FieldNameList.Free;

    Result := FindField;
  end;

  procedure LoadOrderBy;
  begin
    if Assigned(FQueryOrderBy) then
    begin
      var CurrentTable: TQueryBuilderTable;
      var Separator := EmptyStr;

      SQL.Append(' order by ');

      for var Field in FOrderByFields do
      begin
        SQL.Append(Separator);

        SQL.Append(FindQueryField(Field.Field, CurrentTable).FieldAlias);

        if not Field.Ascending then
          SQL.Append(' desc');

        Separator := ',';
      end;
    end;
  end;

  procedure BuildWhere;
  var
    ParamIndex: Integer;

    procedure BuildWhereCondition(const Comparison: TQueryBuilderComparison);

      procedure BuildComparison(const Operator: String);
      begin
        BuildWhereCondition(Comparison.Left);

        SQL.Append(Operator);

        BuildWhereCondition(Comparison.Right);
      end;

      procedure BuildLogical(const Operator: String);

        procedure DoBuildLogical(const DoComparison: TQueryBuilderComparison);
        begin
          var LogicalOperation := (DoComparison.Operarion = qbcoOr) and (Comparison.Operarion = qbcoAnd);

          if LogicalOperation then
            SQL.Append('(');

          BuildWhereCondition(DoComparison);

          if LogicalOperation then
            SQL.Append(')');
        end;

      begin
        DoBuildLogical(Comparison.Left);

        SQL.Append(Operator);

        DoBuildLogical(Comparison.Right);
      end;

      procedure BuildBetween;
      begin
        BuildWhereCondition(Comparison.Left);

        SQL.Append(' between ');

        BuildWhereCondition(Comparison.Right);
      end;

      procedure BuildLike;
      begin
        BuildWhereCondition(Comparison.Left);

        SQL.Append(' like ');

        BuildWhereCondition(Comparison.Right);
      end;

      procedure BuildIsNull;
      begin
        BuildWhereCondition(Comparison.Left);

        SQL.Append(' is null');
      end;

      procedure BuildLogicalNot;
      begin
        SQL.Append('not ');

        BuildWhereCondition(Comparison.Left);
      end;

      procedure BuildParamValue;
      begin
        var ParamName := 'P' + ParamIndex.ToString;
        FParams.CreateParam(ftUnknown, ParamName, ptInput).Value := Comparison.Value;

        SQL.Append(':');

        SQL.Append(ParamName);

        Inc(ParamIndex);
      end;

      procedure BuildFieldName;
      begin
        var CurrentTable: TQueryBuilderTable;
        var QueryField := FindQueryField(Comparison.Field, CurrentTable);

        SQL.Append(CurrentTable.Alias);

        SQL.Append('.');

        SQL.Append(QueryField.Field.DatabaseName);
      end;

    begin
      case Comparison.Operarion of
        qbcoAnd: BuildLogical(' and ');
        qbcoBetween: BuildBetween;
        qbcoEqual: BuildComparison('=');
        qbcoFieldName: BuildFieldName;
        qbcoGreaterThan: BuildComparison('>');
        qbcoGreaterThanOrEqual: BuildComparison('>=');
        qbcoIsNull: BuildIsNull;
        qbcoLessThan: BuildComparison('<');
        qbcoLessThanOrEqual: BuildComparison('<=');
        qbcoLike: BuildLike;
        qbcoLogicalNot: BuildLogicalNot;
        qbcoNotEqual: BuildComparison('<>');
        qbcoOr: BuildLogical(' or ');
        qbcoValue: BuildParamValue;
      end;
    end;

  begin
    if Assigned(FQueryWhere.FComparison) then
    begin
      ParamIndex := 1;

      SQL.Append(' where ');

      BuildWhereCondition(FQueryWhere.FComparison);
    end;
  end;

begin
  FieldIndex := 1;
  RecursiveControl := TDictionary<TField, Boolean>.Create;
  SQL := TStringBuilder.Create(STRING_BUILDER_START_CAPACITY);
  TableIndex := 1;

  FParams.Clear;

  try
    SQL.Append('select ');

    LoadFieldList(FQueryTable, nil);

    SQL.Append(' from ').Append(FQueryTable.Table.DatabaseName).Append(' ').Append(FQueryTable.Alias);

    BuildJoin(FQueryTable);

    BuildWhere;

    LoadOrderBy;

    Result := SQL.ToString;
  finally
    RecursiveControl.Free;

    SQL.Free;
  end;
end;

constructor TQueryBuilder.Create(const Manager: TManager);
begin
  inherited Create;

  FManager := Manager;
  FOrderByFields := TObjectList<TQueryBuilderOrderByField>.Create;
  FParams := TParams.Create(nil);
end;

destructor TQueryBuilder.Destroy;
begin
  FOrderByFields.Free;

  FQueryTable.Free;

  FQueryOpen.Free;

  FQueryOrderBy.Free;

  FQueryFrom.Free;

  FQueryWhere.Free;

  FParams.Free;

  FLoader.Free;

  inherited;
end;

procedure TQueryBuilder.LoadTable(const Table: TTable);
begin
  FQueryTable := TQueryBuilderTable.Create(Table);
end;

function TQueryBuilder.OpenCursor: IDatabaseCursor;
begin
  Result := FManager.PrepareCursor(BuildCommand, FParams);
  Result.GetDataSet.AfterOpen := AfterOpenDataSet;
end;

{ TQueryBuilderWhere }

constructor TQueryBuilderWhere.Create(const QueryBuilder: TQueryBuilder);
begin
  inherited Create;

  FQueryBuilder := QueryBuilder;
  FQueryBuilder.FQueryWhere := Self;
end;

destructor TQueryBuilderWhere.Destroy;
begin
  FComparison.Free;

  inherited;
end;

function TQueryBuilderWhere.Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere;
begin
  FComparison := Condition.FComparison;
  Result := Self;
end;

{ TQueryBuilderOpen<T> }

function TQueryBuilderOpen<T>.All: TArray<T>;
begin
  Result := TArray<T>(FQueryBuilder.FLoader.Load.AsType<TArray<TObject>>);
end;

constructor TQueryBuilderOpen<T>.Create(const QueryBuilder: TQueryBuilder);
begin
  inherited Create;

  FQueryBuilder := QueryBuilder;
  FQueryBuilder.FLoader := TClassLoader.Create(QueryBuilder);
  FQueryBuilder.FQueryOpen := Self;
end;

function TQueryBuilderOpen<T>.One: T;
begin
  var Objects := All;

  if Length(Objects) > 0 then
    Result := Objects[0]
  else
    Result := nil;
 end;

{ TQueryBuilderComparison }

destructor TQueryBuilderComparison.Destroy;
begin
  FLeft.Free;

  FRight.Free;

  FField.Free;

  inherited;
end;

{ TQueryBuilderComparisonHelper }

function TQueryBuilderComparisonHelper.Between(const ValueStart, ValueEnd: Variant): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoBetween, Self, Create(qbcoAnd, Create(ValueStart), Create(ValueEnd)));
end;

class operator TQueryBuilderComparisonHelper.BitwiseAnd(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoAnd, Left, Right);
end;

class operator TQueryBuilderComparisonHelper.BitwiseOr(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoOr, Left, Right);
end;

class function TQueryBuilderComparisonHelper.Create(const Operation: TQueryBuilderComparisonOperation;
  const UnaryOperator: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(Operation);
  Result.FComparison.FLeft := UnaryOperator.FComparison;
end;

class function TQueryBuilderComparisonHelper.Create(const Operation: TQueryBuilderComparisonOperation; const Left,
  Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(Operation);
  Result.FComparison.FLeft := Left.FComparison;
  Result.FComparison.FRight := Right.FComparison;
end;

class function TQueryBuilderComparisonHelper.Create(const Value: Variant): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoValue);
  Result.FComparison.Value := Value;
end;

class function TQueryBuilderComparisonHelper.Create(const Operation: TQueryBuilderComparisonOperation): TQueryBuilderComparisonHelper;
begin
  Result.FComparison := TQueryBuilderComparison.Create;
  Result.FComparison.FOperarion := Operation;
end;

class function TQueryBuilderComparisonHelper.Create(const FieldName: TQueryBuilderFieldSearch): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoFieldName);
  Result.FComparison.FField := FieldName;
end;

class operator TQueryBuilderComparisonHelper.Equal(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoEqual, Left, Right);
end;

class operator TQueryBuilderComparisonHelper.GreaterThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoGreaterThan, Left, Right);
end;

class operator TQueryBuilderComparisonHelper.GreaterThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoGreaterThanOrEqual, Left, Right);
end;

class operator TQueryBuilderComparisonHelper.Implicit(const Value: Variant): TQueryBuilderComparisonHelper;
begin
  Result := Create(Value);
end;

function TQueryBuilderComparisonHelper.IsNull: TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoIsNull, Self);
end;

class operator TQueryBuilderComparisonHelper.LessThan(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoLessThan, Left, Right);
end;

class operator TQueryBuilderComparisonHelper.LessThanOrEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoLessThanOrEqual, Left, Right);
end;

function TQueryBuilderComparisonHelper.Like(const Value: String): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoLike, Self, Create(Value));
end;

class operator TQueryBuilderComparisonHelper.LogicalNot(const UnaryOperator: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoLogicalNot, UnaryOperator);
end;

class operator TQueryBuilderComparisonHelper.NotEqual(const Left, Right: TQueryBuilderComparisonHelper): TQueryBuilderComparisonHelper;
begin
  Result := Create(qbcoNotEqual, Left, Right);
end;

{ TQueryBuilderOrderByField }

constructor TQueryBuilderOrderByField.Create(const Field: TQueryBuilderFieldSearch; const Ascending: Boolean);
begin
  inherited Create;

  FAscending := Ascending;
  FField := Field;
end;

destructor TQueryBuilderOrderByField.Destroy;
begin
  FField.Free;

  inherited;
end;

{ TQueryBuilderWhere<T> }

function TQueryBuilderWhere<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FQueryBuilder);
end;

function TQueryBuilderWhere<T>.OrderBy: TQueryBuilderOrderBy<T>;
begin
  Result := TQueryBuilderOrderBy<T>.Create(FQueryBuilder);
end;

function TQueryBuilderWhere<T>.Where(const Condition: TQueryBuilderComparisonHelper): TQueryBuilderWhere<T>;
begin
  inherited Where(Condition);

  Result := Self;
end;

{ TQueryBuilderOrderBy<T> }

constructor TQueryBuilderOrderBy<T>.Create(const QueryBuilder: TQueryBuilder);
begin
  inherited Create;

  FQueryBuilder := QueryBuilder;
  FQueryBuilder.FQueryOrderBy := Self;
end;

function TQueryBuilderOrderBy<T>.Field(const FieldName: String; const Ascending: Boolean): TQueryBuilderOrderBy<T>;
begin
  Result := Self;

  FQueryBuilder.FOrderByFields.Add(TQueryBuilderOrderByField.Create(TQueryBuilderFieldSearch.Create(FieldName), Ascending));
end;

function TQueryBuilderOrderBy<T>.Open: TQueryBuilderOpen<T>;
begin
  Result := TQueryBuilderOpen<T>.Create(FQueryBuilder);
end;

{ TDatabaseSchemaUpdater }

procedure TDatabaseSchemaUpdater.CheckChangingTheList<T>(const List: Lazy<TArray<T>>; const Func: TFunc<T, Boolean>);
begin
  var A := 0;

//  while A < List.Count do
//    if not Func(List[A]) then
//      Inc(A);
end;

function TDatabaseSchemaUpdater.CheckSameFields(const Fields: TArray<TField>; const DatabaseFields: TArray<TDatabaseField>): Boolean;
begin
  Result := Length(Fields) = Length(DatabaseFields);

  if Result then
    for var A := Low(Fields) to High(Fields) do
      if Fields[A].DatabaseName <> DatabaseFields[A].Name then
        Exit(False);
end;

constructor TDatabaseSchemaUpdater.Create(const Manager: TManager);
begin
  inherited Create;

  FDatabaseManipulator := Manager.FDatabaseManipulator;
  FManager := Manager;
  FManagerSchema := TManager.Create(FManager.FConnection, FManager.FDatabaseManipulator);

  Randomize;
end;

procedure TDatabaseSchemaUpdater.CreateField(const Field: TField);
begin
  FDatabaseManipulator.CreateField(Field);
end;

destructor TDatabaseSchemaUpdater.Destroy;
begin
  FManagerSchema.Free;

  inherited;
end;

procedure TDatabaseSchemaUpdater.DropField(const DatabaseField: TDatabaseField);
begin
//  for var Table in DatabaseField.Table.Schema.Tables do
//    CheckChangingTheList<TDatabaseForeignKey>(Table.ForeignKeys,
//      function (DatabaseForeignKey: TDatabaseForeignKey): Boolean
//      begin
//        Result := FieldInTheList(DatabaseField, DatabaseForeignKey.FieldsReference) or FieldInTheList(DatabaseField, DatabaseForeignKey.Fields);
//
//        if Result then
//          DropForeignKey(DatabaseForeignKey);
//      end);
//
//  CheckChangingTheList<TDatabaseIndex>(DatabaseField.Table.Indexes,
//    function (Index: TDatabaseIndex): Boolean
//    begin
//      Result := FieldInTheList(DatabaseField, Index.Fields);
//
//      if Result then
//        DropIndex(Index);
//    end);
//
//  if Assigned(DatabaseField.DefaultConstraint) then
//    FDatabaseManipulator.DropDefaultConstraint(DatabaseField);
//
//  FDatabaseManipulator.DropField(DatabaseField);
//
//  DatabaseField.Table.Fields.Remove(DatabaseField);
end;

procedure TDatabaseSchemaUpdater.DropForeignKey(const DatabaseForeignKey: TDatabaseForeignKey);
begin
  FDatabaseManipulator.DropForeignKey(DatabaseForeignKey);
//
//  DatabaseForeignKey.Table.ForeignKeys.Remove(DatabaseForeignKey);
end;

procedure TDatabaseSchemaUpdater.DropIndex(const DatabaseIndex: TDatabaseIndex);
begin
//  if DatabaseIndex.PrimaryKey then
//    for var Table in DatabaseIndex.Table.Schema.Tables do
//      CheckChangingTheList<TDatabaseForeignKey>(Table.ForeignKeys,
//        function (DatabaseForeignKey: TDatabaseForeignKey): Boolean
//        begin
//          Result := DatabaseIndex.Table = DatabaseForeignKey.ReferenceTable;
//
//          if Result then
//            DropForeignKey(DatabaseForeignKey);
//        end);
//
//  FDatabaseManipulator.DropIndex(DatabaseIndex);
//
//  DatabaseIndex.Table.Indexes.Remove(DatabaseIndex);
end;

procedure TDatabaseSchemaUpdater.DropTable(const DatabaseTable: TDatabaseTable);
begin
//  for var Table in DatabaseTable.Schema.Tables do
//    CheckChangingTheList<TDatabaseForeignKey>(Table.ForeignKeys,
//      function (DatabaseForeignKey: TDatabaseForeignKey): Boolean
//      begin
//        Result := (DatabaseTable = DatabaseForeignKey.ReferenceTable) or (DatabaseTable = DatabaseForeignKey.Table);
//
//        if Result then
//          DropForeignKey(DatabaseForeignKey);
//      end);
//
//  FDatabaseManipulator.DropTable(DatabaseTable);
end;

function TDatabaseSchemaUpdater.FieldInTheList(const DatabaseField: TDatabaseField; const DatabaseFields: TArray<TDatabaseField>): Boolean;
begin
//  Result := False;
//
//  for var Field in DatabaseFields do
//    if Field = DatabaseField then
//      Exit(True);
end;

procedure TDatabaseSchemaUpdater.RecreateField(const Field: TField; const DatabaseField: TDatabaseField);
begin
  try
    var TempField := TField.Create(Field.Table);
    TempField.DatabaseName := 'TempField' + Trunc(Random * 1000000).ToString;
    TempField.FieldType := Field.FieldType;
    TempField.ForeignKey := Field.ForeignKey;
    TempField.IsForeignKey := Field.IsForeignKey;
    TempField.Name := TempField.DatabaseName;
    TempField.Required := Field.Required;
    TempField.Scale := Field.Scale;
    TempField.Size := Field.Size;
    TempField.SpecialType := Field.SpecialType;

    FDatabaseManipulator.CreateTempField(TempField);

    FDatabaseManipulator.UpdateField(Field, TempField);

    DropField(DatabaseField);

    FDatabaseManipulator.RenameField(TempField, Field);

    TempField.Free;
  except
    on E: Exception do
      raise Exception.CreateFmt('Erro trying to convert the field %s.%s: %s', [Field.Table.DatabaseName, Field.DatabaseName, E.Message]);
  end;
end;

procedure TDatabaseSchemaUpdater.UpdateDatabase;
var
  Comparer: TOrdinalIStringComparer;
  DatabaseField: TDatabaseField;
  DatabaseForeignKey: TDatabaseForeignKey;
  DatabaseIndex: TDatabaseIndex;
  DatabaseSequence: TDatabaseSequence;
  DatabaseTable: TDatabaseTable;
  DatabaseTables: TDictionary<String, TDatabaseTable>;
  ForeignKey: TForeignKey;
  Index: TIndex;
  Sequence: TSequence;
  SQL: TStringBuilder;
  Table: TTable;

  procedure ExecuteDirect(const SQL: String);
  begin
    FManager.ExectDirect(SQL);
  end;

  procedure ExecuteSchemarScripts(const Scripts: TArray<String>);
  begin
    for var SQL in Scripts do
      FManagerSchema.ExectDirect(SQL);
  end;

  procedure ExecuteSQL;
  begin
    ExecuteDirect(SQL.ToString);

    SQL.Length := 0;
  end;

  function ExistsForeigKey(const DatabaseForeignKey: TDatabaseForeignKey): Boolean;
  begin
//    Result := False;
//
//    for var ForeignKey in Tables[DatabaseForeignKey.Table.Name].ForeignKeys do
//      if ForeignKey.DatabaseName = DatabaseForeignKey.Name then
//        Exit(True);
  end;

  function ExistsIndex(const DatabaseIndex: TDatabaseIndex): Boolean;
  begin
//    Result := False;
//
//    for var Index in Tables[DatabaseIndex.Table.Name].Indexes do
//      if Index.DatabaseName = DatabaseIndex.Name then
//        Exit(True);
  end;

  function ExistsField(const DatabaseField: TDatabaseField): Boolean;
  begin
//    Result := False;
//
//    for var Field in Tables[DatabaseField.Table.Name].Fields do
//      if Field.DatabaseName = DatabaseField.Name then
//        Exit(True);
  end;

  function IsSpecialType(const Field: TField): Boolean;
  begin
    Result := Field.SpecialType <> stNotDefined;
  end;

  function FieldNeedSize(const Field: TField): Boolean;
  begin
    Result := (Field.FieldType.TypeKind in [tkUString, tkFloat]) and not IsSpecialType(Field);
  end;

  function FieldNeedPrecision(const Field: TField): Boolean;
  begin
    Result := (Field.FieldType.TypeKind = tkFloat) and not IsSpecialType(Field);;
  end;

  function FieldSizeChanged(const Field: TField): Boolean;
  begin
    Result := (Field.Size <> DatabaseField.Size) and FieldNeedSize(Field);
  end;

  function FieldScaleChanged(const Field: TField): Boolean;
  begin
    Result := (Field.Scale <> DatabaseField.Scale) and FieldNeedPrecision(Field);
  end;

  function FieldSpecialTypeChanged(const Field: TField): Boolean;
  begin
    Result := Field.SpecialType <> DatabaseField.SpecialType;
  end;

  function FieldTypeChanged(const Field: TField): Boolean;
  begin
    var FieldKind := Field.FieldType.TypeKind;

    Result := FieldKind <> DatabaseField.FieldType;
  end;

  function FieldRequiredChanged(const Field: TField): Boolean;
  begin
    Result := Field.Required <> DatabaseField.Required;
  end;

  function FieldDefaultValueChanged(const Field: TField): Boolean;
  begin
    Result := Assigned(DatabaseField.DefaultConstraint) xor Assigned(Field.DefaultConstraint) or Assigned(DatabaseField.DefaultConstraint)
      {and ((DatabaseField.DefaultConstraint.Name <> Field.DefaultConstraint.DatabaseName)
        or (FDatabaseManipulator.GetAutoGeneratedValue(Field.DefaultConstraint).ToLower <> DatabaseField.DefaultConstraint.Value.ToLower))};
  end;

  function FieldChanged(const Field: TField): Boolean;
  begin
    Result := FieldTypeChanged(Field) or FieldSizeChanged(Field) or FieldScaleChanged(Field) or FieldSpecialTypeChanged(Field) or FieldRequiredChanged(Field);
  end;

  procedure RecreateIndex(const Index: TIndex; const DatabaseIndex: TDatabaseIndex);
  begin
    if Assigned(DatabaseIndex) then
      DropIndex(DatabaseIndex);

    FDatabaseManipulator.CreateIndex(Index);
  end;

  function GetPrimaryKeyDatabaseIndex: TDatabaseIndex;
  begin
    Result := nil;

    for var DatabaseIndex in DatabaseTable.Indexes.Value do
      if DatabaseIndex.PrimaryKey then
        Exit(DatabaseIndex);
  end;

  procedure AppendDefaultConstraint(const Field: TField);
  begin
    if Assigned(Field.DefaultConstraint) then
    begin
      SQL.Append(' constraint ');

      SQL.Append(Field.DefaultConstraint.DatabaseName);

      SQL.Append(' default ');

      SQL.Append('(');

      SQL.Append(FDatabaseManipulator.GetDefaultValue(Field.DefaultConstraint));

      SQL.Append(')');
    end;
  end;

  procedure BuildFieldList;
  begin
    for var Field in Table.Fields do
      if not Field.IsManyValueAssociation then
      begin
        SQL.Append(Field.DatabaseName);

        SQL.Append(' ');

        if IsSpecialType(Field) then
          SQL.Append(FDatabaseManipulator.GetSpecialFieldType(Field))
        else
          SQL.Append(FDatabaseManipulator.GetFieldType(Field));

        if FieldNeedSize(Field) then
        begin
          SQL.Append('(');

          SQL.Append(Field.Size);

          if FieldNeedPrecision(Field) then
          begin
            SQL.Append(',');

            SQL.Append(Field.Scale);
          end;

          SQL.Append(')');
        end;

        AppendDefaultConstraint(Field);

        SQL.Append(',');
      end;

    SQL.Remove(Pred(SQL.Length), 1);
  end;

  procedure CreateTable;
  begin
    SQL.Append('create table ');

    SQL.Append(Table.DatabaseName);

    SQL.Append('(');

    BuildFieldList;

    SQL.Append(')');

    ExecuteSQL;
  end;

  procedure LoadDatabaseTables;
  begin
    DatabaseTables := TDictionary<String, TDatabaseTable>.Create(Comparer);

    for var DatabaseTable in FManagerSchema.Select.All.From<TDatabaseTable>.Open.All do
      DatabaseTables.Add(DatabaseTable.Name, DatabaseTable);
  end;

begin
  Comparer := TOrdinalIStringComparer.Create;
  SQL := TStringBuilder.Create(5000);

  ExecuteSchemarScripts(FDatabaseManipulator.GetSchemaTablesScripts);

  LoadDatabaseTables;

//  for Sequence in FManager.Mapper.Sequences do
//    if not Assigned(Schema.Sequence[Sequence.Name]) then
//      FDatabaseManipulator.CreateSequence(Sequence);
//Exit;
  for Table in FManager.Mapper.Tables do
    if not DatabaseTables.TryGetValue(Table.DatabaseName, DatabaseTable) then
      CreateTable;

  for Table in FManager.Mapper.Tables do
  begin
//      for Field in Table.Fields do
//        if not Field.IsManyValueAssociation then
//        begin
//          DatabaseField := DatabaseTable.Field[Field.DatabaseName];
//
//          if not Assigned(DatabaseField) then
//            CreateField(Field)
//          else if FieldChanged then
//            RecreateField(Field, DatabaseField)
//          else
//          begin
//            if FieldDefaultValueChanged then
//            begin
//              if Assigned(DatabaseField.DefaultConstraint) then
//                FDatabaseManipulator.DropDefaultConstraint(DatabaseField);
//
//              if Assigned(Field.DefaultConstraint) then
//                FDatabaseManipulator.CreateDefaultConstraint(Field);
//            end;
//
//            if Field.DatabaseName <> DatabaseField.Name then
//            begin
//              DatabaseField.Name := Field.DatabaseName;
//
//              FDatabaseManipulator.RenameField(Field, Field);
//            end;
//          end;
//        end;
  end;
//
//  for Table in FManager.Mapper.Tables do
//    if Table.DefaultRecords.Count > 0 then
//    begin
//      var RecordFound: Boolean;
//      var Records := FDatabaseManipulator.GetAllRecords(Table);
//
//      for var DefaultRecord in Table.DefaultRecords do
//      begin
//        RecordFound := False;
//
//        for var DatabaseRecord in Records do
//          RecordFound := RecordFound or (Table.PrimaryKey.Value[DefaultRecord].AsVariant = Table.PrimaryKey.Value[DatabaseRecord].AsVariant);
//
//        if RecordFound then
//          FDatabaseManipulator.UpdateRecord(DefaultRecord)
//        else
//          FDatabaseManipulator.InsertRecord(DefaultRecord);
//      end;
//    end;
//
//  for Table in FManager.Mapper.Tables do
//  begin
//    DatabaseTable := Schema.Table[Table.DatabaseName];
//
//    if Assigned(DatabaseTable) then
//      for Index in Table.Indexes do
//      begin
//        if Index.PrimaryKey then
//          DatabaseIndex := GetPrimaryKeyDatabaseIndex
//        else
//          DatabaseIndex := DatabaseTable.Index[Index.DatabaseName];
//
//        if not Assigned(DatabaseIndex) or not CheckSameFields(Index.Fields, DatabaseIndex.Fields) or (DatabaseIndex.Name <> Index.DatabaseName)
//          or (DatabaseIndex.Unique xor Index.Unique) then
//          RecreateIndex(Index, DatabaseIndex);
//      end;
//  end;
//
//  for Table in FManager.Mapper.Tables do
//  begin
//    DatabaseTable := Schema.Table[Table.DatabaseName];
//
//    if Assigned(DatabaseTable) then
//      for ForeignKey in Table.ForeignKeys do
//      begin
//        DatabaseForeignKey := DatabaseTable.ForeignKey[ForeignKey.DatabaseName];
//
//        if not Assigned(DatabaseForeignKey) then
//          FDatabaseManipulator.CreateForeignKey(ForeignKey)
//        else if not CheckSameFields([ForeignKey.Field], DatabaseForeignKey.Fields) then
//        begin
//          DropForeignKey(DatabaseForeignKey);
//
//          FDatabaseManipulator.CreateForeignKey(ForeignKey)
//        end;
//      end;
//  end;
//
//  for DatabaseTable in Schema.Tables do
//    if Tables.ContainsKey(DatabaseTable.Name) then
//    begin
//      for DatabaseForeignKey in DatabaseTable.ForeignKeys.Value do
//        if not ExistsForeigKey(DatabaseForeignKey) then
//          DropForeignKey(DatabaseForeignKey);
//
//      for DatabaseIndex in DatabaseTable.Indexes.Value do
//        if not ExistsIndex(DatabaseIndex) then
//          DropIndex(DatabaseIndex);
//
//      for DatabaseField in DatabaseTable.Fields.Value do
//        if not ExistsField(DatabaseField) then
//          DropField(DatabaseField);
//    end
//    else
//      DropTable(DatabaseTable);
//
//    if not Assigned(FManager.Mapper.FindSequence(DatabaseSequence.Name)) then
//      FDatabaseManipulator.DropSequence(DatabaseSequence);
//
  DatabaseTables.Free;

  SQL.Free;

  Comparer.Free;
end;

{ TDatabaseManipulator }

function TDatabaseManipulator.CreateField(const Field: TField): String;
begin
//  ExecuteDirect(Format('alter table %s add %s', [Field.Table.DatabaseName, GetFieldDefinition(Field)]));
end;

function TDatabaseManipulator.CreateForeignKey(const ForeignKey: TForeignKey): String;
begin
//  ExecuteDirect(Format('alter table %s add constraint %s foreign key (%s) references %s (%s)', [ForeignKey.Table.DatabaseName,
//    ForeignKey.DatabaseName, ForeignKey.Field.DatabaseName, ForeignKey.ParentTable.DatabaseName, ForeignKey.ParentTable.PrimaryKey.DatabaseName]));
end;

function TDatabaseManipulator.CreateIndex(const Index: TIndex): String;

//  function CheckUniqueIndex: String;
//  begin
//    if Index.Unique then
//      Result := 'unique '
//    else
//      Result := EmptyStr;
//  end;

begin
//  if Index.PrimaryKey then
//    ExecuteDirect(Format('alter table %s add %s', [Index.Table.DatabaseName, GetPrimaryKey(Index.Table, EmptyStr)]))
//  else
//    ExecuteDirect(Format('create %sindex %s on %s (%s)', [CheckUniqueIndex, Index.DatabaseName, Index.Table.DatabaseName, GetFieldList(Index.Fields)]));
end;

function TDatabaseManipulator.CreateTempField(const Field: TField): String;
begin
  CreateField(Field);
end;

function TDatabaseManipulator.DropDefaultConstraint(const Field: TDatabaseField): String;
begin
//  ExecuteDirect(Format('alter table %s drop constraint %s', [Field.Table.Name, Field.DefaultConstraint.Name]));
end;

function TDatabaseManipulator.DropField(const Field: TDatabaseField): String;
begin
//  ExecuteDirect(Format('alter table %s drop column %s', [Field.Table.Name, Field.Name]));
end;

function TDatabaseManipulator.DropForeignKey(const ForeignKey: TDatabaseForeignKey): String;
begin
//  ExecuteDirect(Format('alter table %s drop constraint %s', [ForeignKey.Table.Name, ForeignKey.Name]));
end;

function TDatabaseManipulator.DropIndex(const Index: TDatabaseIndex): String;
begin
//  ExecuteDirect(Format('drop index %s on %s', [Index.Name, Index.Table.Name]));
end;

function TDatabaseManipulator.DropSequence(const Sequence: TDatabaseSequence): String;
begin
//  ExecuteDirect(Format('drop sequence %s', [Sequence.Name]));
end;

function TDatabaseManipulator.DropTable(const Table: TDatabaseTable): String;
begin
//  ExecuteDirect(Format('drop table %s', [Table.Name]));
end;

//function TDatabaseManipulator.GetFieldCollation(const Field: TField): String;
//begin
//  Result := EmptyStr;
//
//  if not Field.Collation.IsEmpty then
//    Result := Format(' collate %s', [Field.Collation]);
//end;

//function TDatabaseManipulator.GetFieldDefaultConstraint(const Field: TField): String;
//begin
//  Result := EmptyStr;
//
//  if Assigned(Field.DefaultConstraint) then
//    Result := Format(' constraint %s default(%s)', [GetDefaultConstraintName(Field), GetAutoGeneratedValue(Field.DefaultConstraint)]);
//end;
//
//function TDatabaseManipulator.GetFieldDefinition(const Field: TField): String;
//const
//  IS_NULL_VALUE: array[Boolean] of String = ('', 'not ');
//
//begin
//  Result := Format('%s %s %snull%s%s', [Field.DatabaseName, GetFieldTypeDefinition(Field), IS_NULL_VALUE[Field.Required], GetFieldCollation(Field),
//    GetFieldDefaultConstraint(Field)]);
//end;
//
//function TDatabaseManipulator.GetFieldTypeDefinition(Field: TField): String;
//begin
//  if Field.SpecialType = stNotDefined then
//  begin
//    Result := GetFieldType(Field);
//
//    if Field.FieldType.TypeKind in [tkFloat, tkUString, tkWChar] then
//    begin
//      var Size := Field.Size.ToString;
//
//      if Field.FieldType.TypeKind = tkFloat then
//        Size := Size + ',' + Field.Scale.ToString;
//
//      Result := Format('%s(%s)', [Result, Size]);
//    end;
//  end
//  else
//    Result := GetSpecialFieldType(Field);
//end;

function TDatabaseManipulator.MakeInsertStatement(const Table: TTable; const Params: TParams): String;
begin
  var FieldNames := EmptyStr;
  var ParamNames := EmptyStr;
  var ReturningFields := EmptyStr;

  if Params.Count = 0 then
    Result := ' default values '
  else
  begin
    for var A := 0 to Pred(Params.Count) do
    begin
      var Param := Params[A];

      if not FieldNames.IsEmpty then
      begin
        FieldNames := FieldNames + ',';
        ParamNames := ParamNames + ',';
      end;

      FieldNames := FieldNames + Param.Name;
      ParamNames := ParamNames + ':' + Param.Name;
    end;

    Result := Format('(%s)values(%s)', [FieldNames, ParamNames]);
  end;

  Result := 'insert into %s' + Result;

  for var Field in Table.ReturningFields do
  begin
    if not ReturningFields.IsEmpty then
      ReturningFields := ReturningFields + ',';

    ReturningFields := ReturningFields + Field.DatabaseName;
  end;

  if not ReturningFields.IsEmpty then
    Result := Result + 'returning %s';

  Result := Format(Result, [Table.DatabaseName, ReturningFields]);
end;

function TDatabaseManipulator.MakeUpdateStatement(const Table: TTable; const Params: TParams): String;
begin
  Result := EmptyStr;

  for var A := 0 to Pred(Params.Count) do
  begin
    var Param := Params[A];

    if not Table.HasPrimaryKey or (Param.Name <> Table.PrimaryKey.DatabaseName) then
    begin
      if not Result.IsEmpty then
        Result := Result + ',';

      Result := Result + Format('%0:s=:%0:s', [Param.Name]);
    end;
  end;

  Result := Format('update %s set %s', [Table.DatabaseName, Result, '']);

  if Table.HasPrimaryKey then
    Result := Format('%s where %1:s=:%1:s', [Result, Table.PrimaryKey.DatabaseName]);
end;

function TDatabaseManipulator.UpdateField(const SourceField, DestinyField: TField): String;
begin
//  ExecuteDirect(Format('update %s set %s = %s', [SourceField.Table.DatabaseName, DestinyField.DatabaseName, SourceField.DatabaseName]));
end;

{ TManager }

procedure TManager.AddStateObject(const StateObjectKey: String; const StateObject: TStateObject);
begin
  FStateObjects.Add(StateObjectKey, StateObject);
end;

function TManager.BuildStateObjectKey(const Table: TTable; const PrimaryKeyValue: String): String;
begin
  Result := Format('%s.%s', [Table.DatabaseName, PrimaryKeyValue]);
end;

function TManager.BuildStateObjectKey(const Table: TTable; const &Object: TObject): String;
begin
  Result := BuildStateObjectKey(Table, Table.PrimaryKey.Value[&Object].ToString);
end;

function TManager.CheckStateObjectExists(const Table: TTable; const &Object: TObject): Boolean;
begin
  Result := FStateObjects.ContainsKey(BuildStateObjectKey(Table, &Object));
end;

constructor TManager.Create(const Connection: IDatabaseConnection; const DatabaseManipulator: IDatabaseManipulator);
begin
  inherited Create;

  FConnection := Connection;
  FDatabaseManipulator := DatabaseManipulator;
  FMapper := TMapper.Create;
  FProcessedObjects := TDictionary<TObject, Boolean>.Create;
  FStateObjects := TObjectDictionary<String, TStateObject>.Create([doOwnsValues]);
end;

procedure TManager.Delete(const &Object: TObject);
begin

end;

destructor TManager.Destroy;
begin
  FProcessedObjects.Free;

  FMapper.Free;

  FQueryBuilder.Free;

  FStateObjects.Free;

  inherited;
end;

procedure TManager.ExectDirect(const SQL: String);
begin
  FConnection.ExecuteDirect(SQL);
end;

function TManager.GetStateObject(const Table: TTable; const &Object: TObject): TStateObject;
begin
  if not FStateObjects.TryGetValue(BuildStateObjectKey(Table, &Object), Result) then
    raise EForeignObjectNotAllowed.Create;
end;

procedure TManager.Insert(const &Object: TObject);
begin
  FProcessedObjects.Clear;

  InsertTable(Mapper.GetTable(&Object.ClassType), &Object);
end;

function TManager.InsertTable(const Table: TTable; const &Object: TObject): Boolean;
var
  DelayedSave: TArray<TField>;
  FieldValue: TValue;
  ManyValueAssociationFields: TArray<TField>;
  StateObject: TStateObject;

  procedure SaveForeignTable(const Field: TField);
  begin
    try
      if not SaveTable(Field.ForeignKey.ParentTable, FieldValue.AsObject) then
        raise ERecursionInsertionError.Create(Field.ForeignKey.ParentTable.Name);
    except
      on E: ERecursionInsertionError do
        raise ERecursionInsertionError.Create(Table.Name + '->' + E.RecursionTree);
    end;
  end;

  procedure DoInsertTable(const Table: TTable; const &Object: TObject);
  begin
    var Field: TField;
    var FieldIndex := 0;
    var Params := TParams.Create(nil);

    try
      if Assigned(Table.BaseTable) then
        DoInsertTable(Table.BaseTable, &Object);

      for Field in Table.Fields do
        if not Field.AutoGenerated then
          if Field.IsManyValueAssociation then
            ManyValueAssociationFields := ManyValueAssociationFields + [Field]
          else if Field.IsForeignKey and not Field.Required then
            DelayedSave := DelayedSave + [Field]
          else
          begin
            if Field.HasValue(&Object, FieldValue) and Field.IsForeignKey then
            begin
              SaveForeignTable(Field);

              FieldValue := Field.ForeignKey.ParentTable.PrimaryKey.Value[FieldValue.AsObject];
            end;

            Params.CreateParam(Field.FieldType.FieldType, Field.DatabaseName, ptInput).Value := FieldValue.AsVariant;
            StateObject.OldValue[Field] := FieldValue;
          end;

      var Cursor := FConnection.PrepareCursor(FDatabaseManipulator.MakeInsertStatement(Table, Params), Params);

      Cursor.Next;

      for Field in Table.ReturningFields do
      begin
        FieldValue := TValue.FromVariant(Cursor.GetFieldValue(FieldIndex));

        Field.Value[&Object] := FieldValue;
        StateObject.OldValue[Field] := FieldValue;

        Inc(FieldIndex);
      end;
    finally
      Params.Free;
    end;
  end;

begin
  if not FProcessedObjects.TryGetValue(&Object, Result) then
  begin
    DelayedSave := nil;
    var Field: TField;
    ManyValueAssociationFields := nil;
    Result := True;
    StateObject := TStateObject.Create(Table, &Object);

    FProcessedObjects.Add(&Object, False);

    try
      DoInsertTable(Table, &Object);
    except
      StateObject.Free;

      raise;
    end;

    AddStateObject(BuildStateObjectKey(Table, &Object), StateObject);

    FProcessedObjects[&Object] := Result;

    if DelayedSave <> nil then
    begin
      for Field in DelayedSave do
        if Field.HasValue(&Object, FieldValue) then
          SaveForeignTable(Field);

      InternalUpdateTable(Table, &Object);
    end;

    for Field in ManyValueAssociationFields do
    begin
      FieldValue := Field.Value[&Object];

      for var A := 0 to Pred(FieldValue.ArrayLength) do
      begin
        Field.ManyValueAssociation.ChildField.Value[FieldValue.ArrayElement[A].AsObject] := &Object;

        InsertTable(Field.ManyValueAssociation.ChildTable, FieldValue.ArrayElement[A].AsObject);
      end;
    end;
  end;
end;

procedure TManager.InternalUpdateTable(const Table: TTable; const &Object: TObject);
var
  StateObject: TStateObject;

  procedure DoUpdateTable(const Table: TTable; const &Object: TObject);
  var
    Params: TParams;

    procedure CreateParam(const Field: TField; const FieldValue: TValue);
    begin
      Params.CreateParam(Field.FieldType.FieldType, Field.DatabaseName, ptInput).Value := FieldValue.AsVariant;
    end;

  begin
    Params := TParams.Create(nil);
    var FieldValue: TValue;

    try
      if Assigned(Table.BaseTable) then
        DoUpdateTable(Table.BaseTable, &Object);

      for var Field in Table.Fields do
      begin
        if Field.HasValue(&Object, FieldValue) and Field.IsForeignKey then
        begin
          var ForeignObject := FieldValue.AsObject;

          SaveTable(Field.ForeignKey.ParentTable, ForeignObject);

          FieldValue := Field.ForeignKey.ParentTable.PrimaryKey.Value[ForeignObject];
        end;

        if Field.IsManyValueAssociation then
          for var A := 0 to Pred(FieldValue.ArrayLength) do
            SaveTable(Field.ManyValueAssociation.ChildTable, FieldValue.ArrayElement[A].AsObject)
        else if StateObject.OldValue[Field].AsVariant <> FieldValue.AsVariant then
          CreateParam(Field, FieldValue);
      end;

      if Params.Count > 0 then
      begin
        CreateParam(Table.PrimaryKey, Table.PrimaryKey.Value[&Object]);

        FConnection.PrepareCursor(FDatabaseManipulator.MakeUpdateStatement(Table, Params), Params).Next;
      end;
    finally
      Params.Free;
    end;
  end;

begin
  StateObject := GetStateObject(Table, &Object);

  DoUpdateTable(Table, &Object);
end;

function TManager.OpenCursor(const SQL: String): IDatabaseCursor;
begin
  Result := FConnection.OpenCursor(SQL);
end;

function TManager.PrepareCursor(const SQL: String; const Params: TParams): IDatabaseCursor;
begin
  Result := FConnection.PrepareCursor(SQL, Params);
end;

procedure TManager.Save(const &Object: TObject);
begin
  FProcessedObjects.Clear;

  SaveTable(Mapper.GetTable(&Object.ClassType), &Object);
end;

function TManager.SaveTable(const Table: TTable; const &Object: TObject): Boolean;
begin
  if CheckStateObjectExists(Table, &Object) then
    Result := UpdateTable(Table, &Object)
  else
    Result := InsertTable(Table, &Object);
end;

function TManager.Select: TQueryBuilder;
begin
  FQueryBuilder.Free;

  FQueryBuilder := TQueryBuilder.Create(Self);
  Result := FQueryBuilder;
end;

function TManager.TryGetStateObject(const StateObjectKey: String; var StateObject: TStateObject): Boolean;
begin
  Result := FStateObjects.TryGetValue(StateObjectKey, StateObject);
end;

procedure TManager.Update(const &Object: TObject);
begin
  FProcessedObjects.Clear;

  UpdateTable(Mapper.GetTable(&Object.ClassType), &Object);
end;

procedure TManager.UpdateDatabaseSchema;
begin
  var Updater := TDatabaseSchemaUpdater.Create(Self);

  try
    Updater.UpdateDatabase;
  finally
    Updater.Free;
  end;
end;

function TManager.UpdateTable(const Table: TTable; const &Object: TObject): Boolean;
begin
  Result := True;

  if FProcessedObjects.TryAdd(&Object, False) then
    InternalUpdateTable(Table, &Object);
end;

{ TStateObject }

constructor TStateObject.Create(const Table: TTable; const &Object: TObject);
begin
  inherited Create;

  FObject := &Object;

  SetLength(FOldValues, Table.AllFieldCount);
end;

destructor TStateObject.Destroy;
begin
  &Object.Free;

  inherited;
end;

function TStateObject.GetOldValue(const Field: TField): TValue;
begin
  Result := FOldValues[Field.Index];
end;

procedure TStateObject.SetOldValue(const Field: TField; const Value: TValue);
begin
  FOldValues[Field.Index] := Value;
end;

{ ERecursionInsertionError }

constructor ERecursionInsertionError.Create(const RecursionTree: String);
begin
  inherited Create('Error of recursion inserting object, the sequence of error was ' + RecursionTree + ' please check your data and try again!');

  FRecursionTree := RecursionTree;
end;

{ TQueryBuilderTable }

constructor TQueryBuilderTable.Create(const Table: TTable);
begin
  inherited Create;
  FDatabaseFields := TObjectList<TQueryBuilderTableField>.Create;
  FForeignKeyTables := TObjectList<TQueryBuilderTable>.Create;
  FManyValueAssociationTables := TObjectList<TQueryBuilderTable>.Create;
  FTable := Table;
end;

constructor TQueryBuilderTable.Create(const ForeignKeyField: TForeignKey);
begin
  Create(ForeignKeyField.ParentTable);

  FForeignKeyField := ForeignKeyField;
end;

constructor TQueryBuilderTable.Create(const ManyValueAssociationField: TManyValueAssociation);
begin
  Create(ManyValueAssociationField.ChildTable);

  FManyValueAssociationField := ManyValueAssociationField;
end;

destructor TQueryBuilderTable.Destroy;
begin
  FForeignKeyTables.Free;

  FManyValueAssociationTables.Free;

  InheritedTable.Free;

  FDatabaseFields.Free;

  inherited;
end;

{ TQueryBuilderTableField }

constructor TQueryBuilderTableField.Create(const Field: TField; const FieldIndex: Integer);
begin
  inherited Create;

  FField := Field;
  FFieldAlias := 'F' + FieldIndex.ToString;
end;

{ ERecursionSelectionError }

constructor ERecursionSelectionError.Create(const RecursionTree: String);
begin
  inherited Create('Error of recursion selecting object, the sequence of error was ' + RecursionTree + ' please change any field in the list to lazy!');

  FRecursionTree := RecursionTree;
end;

{ TQueryBuilderFieldSearch }

constructor TQueryBuilderFieldSearch.Create(const FieldName: String);
begin
  inherited Create;

  FFieldName := FieldName;
end;

{ TDatabaseClassGenerator }

constructor TDatabaseClassGenerator.Create(const Manager: TManager);
begin
  inherited Create;

  FManager := Manager;
end;

procedure TDatabaseClassGenerator.GenerateFile(const Destiny: TStream);
begin

end;

{ TLazyAccess }

constructor TLazyAccess.Create(const LazyValue: ILazyValue);
begin
  FLazyValue := LazyValue;
end;

end.

//  if Assigned(Table.PrimaryKey) then
//  begin
//    var Index := GetPrimaryKeyIndex(Table);
//
//    Result := Format('%sconstraint %s primary key (%s)', [Separator, Index.DatabaseName, GetFieldList(Index.Fields)]);
//  end;

