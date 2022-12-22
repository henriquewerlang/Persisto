unit Delphi.ORM.Database.Metadata;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Attributes;

type
  TDatabaseCheckConstraint = class;
  TDatabaseDefaultConstraint = class;
  TDatabaseField = class;
  TDatabaseForeignKey = class;
  TDatabaseIndex = class;
  TDatabaseSchema = class;
  TDatabaseTable = class;

  IMetadataManipulator = interface
    ['{7ED4F3DE-1C13-4CF3-AE3C-B51386EA271F}']
    function GetInternalFunction(const Field: TField): String;
    function GetDefaultConstraintName(const Field: TField): String;

    procedure CreateField(const Field: TField);
    procedure CreateForeignKey(const ForeignKey: TForeignKey);
    procedure CreateIndex(const Index: TIndex);
    procedure CreateTable(const Table: TTable);
    procedure DropDefaultConstraint(const Field: TDatabaseField);
    procedure DropField(const Field: TDatabaseField);
    procedure DropForeignKey(const ForeignKey: TDatabaseForeignKey);
    procedure DropIndex(const Index: TDatabaseIndex);
    procedure DropTable(const Table: TDatabaseTable);
    procedure LoadSchema(const Schema: TDatabaseSchema);
    procedure UpdateField(const SourceField, DestinyField: TField);
  end;

  TDatabaseSchema = class
  private
    FTables: TList<TDatabaseTable>;

    function GetTable(const Name: String): TDatabaseTable;
  public
    constructor Create;

    destructor Destroy; override;

    property Table[const Name: String]: TDatabaseTable read GetTable;
    property Tables: TList<TDatabaseTable> read FTables;
  end;

  TDatabaseNamedObject = class
  private
    FName: String;
  public
    constructor Create(const Name: String);

    class function FindObject<T: TDatabaseNamedObject>(const List: TList<T>; const Name: String): T;

    property Name: String read FName write FName;
  end;

  TDatabaseTableObject = class(TDatabaseNamedObject)
  private
    FTable: TDatabaseTable;
  public
    constructor Create(const Table: TDatabaseTable; const Name: String);

    property Table: TDatabaseTable read FTable;
  end;

  TDatabaseTable = class(TDatabaseNamedObject)
  private
    FFields: TList<TDatabaseField>;
    FForeignKeys: TList<TDatabaseForeignKey>;
    FIndexes: TList<TDatabaseIndex>;

    function GetField(const Name: String): TDatabaseField;
    function GetForeignKey(const Name: String): TDatabaseForeignKey;
    function GetIndex(const Name: String): TDatabaseIndex;
  public
    constructor Create(const Schema: TDatabaseSchema; const Name: String);

    destructor Destroy; override;

    property Field[const Name: String]: TDatabaseField read GetField;
    property Fields: TList<TDatabaseField> read FFields;
    property ForeignKey[const Name: String]: TDatabaseForeignKey read GetForeignKey;
    property ForeignKeys: TList<TDatabaseForeignKey> read FForeignKeys;
    property Index[const Name: String]: TDatabaseIndex read GetIndex;
    property Indexes: TList<TDatabaseIndex> read FIndexes;
  end;

  TDatabaseField = class(TDatabaseTableObject)
  private
    FCheck: TDatabaseCheckConstraint;
    FCollation: String;
    FDefault: TDatabaseDefaultConstraint;
    FFieldType: TTypeKind;
    FRequired: Boolean;
    FSize: Word;
    FScale: Word;
    FSpecialType: TDatabaseSpecialType;
  public
    constructor Create(const Table: TDatabaseTable; const Name: String);

    destructor Destroy; override;

    property Check: TDatabaseCheckConstraint read FCheck write FCheck;
    property Collation: String read FCollation write FCollation;
    property Default: TDatabaseDefaultConstraint read FDefault write FDefault;
    property FieldType: TTypeKind read FFieldType write FFieldType;
    property Required: Boolean read FRequired write FRequired;
    property Scale: Word read FScale write FScale;
    property Size: Word read FSize write FSize;
    property SpecialType: TDatabaseSpecialType read FSpecialType write FSpecialType;
  end;

  TDatabaseIndex = class(TDatabaseTableObject)
  private
    FFields: TArray<TDatabaseField>;
    FPrimaryKey: Boolean;
    FUnique: Boolean;
  public
    constructor Create(const Table: TDatabaseTable; const Name: String);

    property Fields: TArray<TDatabaseField> read FFields write FFields;
    property PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;
    property Unique: Boolean read FUnique write FUnique;
  end;

  TDatabaseForeignKey = class(TDatabaseTableObject)
  private
    FFields: TArray<TDatabaseField>;
    FFieldsReference: TArray<TDatabaseField>;
    FReferenceTable: TDatabaseTable;
  public
    constructor Create(const ParentTable: TDatabaseTable; const Name: String; const ReferenceTable: TDatabaseTable);

    property Fields: TArray<TDatabaseField> read FFields write FFields;
    property FieldsReference: TArray<TDatabaseField> read FFieldsReference write FFieldsReference;
    property ReferenceTable: TDatabaseTable read FReferenceTable write FReferenceTable;
  end;

  TDatabaseDefaultConstraint = class(TDatabaseNamedObject)
  private
    FValue: String;
  public
    constructor Create(const Field: TDatabaseField; const Name, Value: String);

    property Value: String read FValue write FValue;
  end;

  TDatabaseCheckConstraint = class(TDatabaseNamedObject)
  private
    FCheck: String;
  public
    constructor Create(const Field: TDatabaseField; const Name, Check: String);

    property Check: String read FCheck write FCheck;
  end;

  TDatabaseMetadataUpdate = class
  private
    FMapper: TMapper;
    FMetadataManipulator: IMetadataManipulator;
    FTempField: TField;

    function CheckSameFields(const Fields: TArray<TField>; const DatabaseFields: TArray<TDatabaseField>): Boolean;
    function GetMapper: TMapper; inline;

    procedure CreateField(const Field: TField);
    procedure DropField(const DatabaseField: TDatabaseField);
    procedure RecreateField(const Field: TField; const DatabaseField: TDatabaseField);
  public
    constructor Create(const MetadataManipulator: IMetadataManipulator);

    destructor Destroy; override;

    procedure UpdateDatabase;

    property Mapper: TMapper read GetMapper write FMapper;
  end;

implementation

uses System.SysUtils, System.TypInfo, System.Rtti, System.Generics.Defaults;

{ TDatabaseNamedObject }

constructor TDatabaseNamedObject.Create(const Name: String);
begin
  inherited Create;

  FName := Name;
end;

class function TDatabaseNamedObject.FindObject<T>(const List: TList<T>; const Name: String): T;
begin
  Result := nil;

  for var AObject in List do
    if AnsiCompareText(AObject.Name, Name) = 0 then
      Exit(AObject);
end;

{ TDatabaseTableObject }

constructor TDatabaseTableObject.Create(const Table: TDatabaseTable; const Name: String);
begin
  inherited Create(Name);

  FTable := Table;
end;

{ TDatabaseForeignKey }

constructor TDatabaseForeignKey.Create(const ParentTable: TDatabaseTable; const Name: String; const ReferenceTable: TDatabaseTable);
begin
  inherited Create(ParentTable, Name);

  FReferenceTable := ReferenceTable;

  FTable.FForeignKeys.Add(Self);
end;

{ TDatabaseField }

constructor TDatabaseField.Create(const Table: TDatabaseTable; const Name: String);
begin
  inherited;

  FTable.FFields.Add(Self);
end;

destructor TDatabaseField.Destroy;
begin
  FDefault.Free;

  FCheck.Free;

  inherited;
end;

{ TDatabaseIndex }

constructor TDatabaseIndex.Create(const Table: TDatabaseTable; const Name: String);
begin
  inherited;

  FTable.FIndexes.Add(Self);
end;

{ TDatabaseTable }

constructor TDatabaseTable.Create(const Schema: TDatabaseSchema; const Name: String);
begin
  inherited Create(Name);

  FFields := TObjectList<TDatabaseField>.Create;
  FForeignKeys := TObjectList<TDatabaseForeignKey>.Create;
  FIndexes := TObjectList<TDatabaseIndex>.Create;

  Schema.Tables.Add(Self);
end;

destructor TDatabaseTable.Destroy;
begin
  FFields.Free;

  FForeignKeys.Free;

  FIndexes.Free;

  inherited;
end;

function TDatabaseTable.GetField(const Name: String): TDatabaseField;
begin
  Result := TDatabaseNamedObject.FindObject<TDatabaseField>(Fields, Name);
end;

function TDatabaseTable.GetForeignKey(const Name: String): TDatabaseForeignKey;
begin
  Result := TDatabaseNamedObject.FindObject<TDatabaseForeignKey>(ForeignKeys, Name);
end;

function TDatabaseTable.GetIndex(const Name: String): TDatabaseIndex;
begin
  Result := TDatabaseNamedObject.FindObject<TDatabaseIndex>(Indexes, Name);
end;

{ TDatabaseMetadataUpdate }

function TDatabaseMetadataUpdate.CheckSameFields(const Fields: TArray<TField>; const DatabaseFields: TArray<TDatabaseField>): Boolean;
begin
  Result := Length(Fields) = Length(DatabaseFields);

  if Result then
    for var A := Low(Fields) to High(Fields) do
      if Fields[A].DatabaseName <> DatabaseFields[A].Name then
        Exit(False);
end;

constructor TDatabaseMetadataUpdate.Create(const MetadataManipulator: IMetadataManipulator);
begin
  inherited Create;

  FTempField := TField.Create;
  FMetadataManipulator := MetadataManipulator;

  Randomize;
end;

procedure TDatabaseMetadataUpdate.CreateField(const Field: TField);

  function CheckDefaultValue: Boolean;
  begin
    Result := Field.DefaultValue.IsEmpty and Field.Required;

    if Result then
    begin
      var Value: TValue;

      TValue.Make(nil, Field.FieldType.Handle, Value);

      Field.DefaultValue := Value;
    end;
  end;

begin
  var DefaultChanged := CheckDefaultValue;

  try
    FMetadataManipulator.CreateField(Field);
  finally
    if DefaultChanged then
      Field.DefaultValue := TValue.Empty;
  end;
end;

destructor TDatabaseMetadataUpdate.Destroy;
begin
  FTempField.Free;

  inherited;
end;

procedure TDatabaseMetadataUpdate.DropField(const DatabaseField: TDatabaseField);
begin
  if Assigned(DatabaseField.Default) then
    FMetadataManipulator.DropDefaultConstraint(DatabaseField);

  FMetadataManipulator.DropField(DatabaseField);
end;

function TDatabaseMetadataUpdate.GetMapper: TMapper;
begin
  if not Assigned(FMapper) then
    FMapper := TMapper.Default;

  Result := FMapper;
end;

procedure TDatabaseMetadataUpdate.RecreateField(const Field: TField; const DatabaseField: TDatabaseField);
begin
  FTempField.DatabaseName := 'TempField' + Trunc(Random * 1000000).ToString;
  FTempField.DefaultInternalFunction := Field.DefaultInternalFunction;
  FTempField.DefaultValue := Field.DefaultValue;
  FTempField.FieldType := Field.FieldType;
  FTempField.Name := Field.Name;
  FTempField.Required := Field.Required;
  FTempField.Scale := Field.Scale;
  FTempField.Size := Field.Size;
  FTempField.SpecialType := Field.SpecialType;
  FTempField.Table := Field.Table;

  CreateField(FTempField);

  var TempDatabaseField := TDatabaseField.Create(DatabaseField.Table, FTempField.DatabaseName);

  if not FTempField.DefaultValue.IsEmpty or FTempField.Required then
    TDatabaseDefaultConstraint.Create(TempDatabaseField, FMetadataManipulator.GetDefaultConstraintName(FTempField), '');

  FMetadataManipulator.UpdateField(Field, FTempField);

  DropField(DatabaseField);

  CreateField(Field);

  FMetadataManipulator.UpdateField(FTempField, Field);
end;

procedure TDatabaseMetadataUpdate.UpdateDatabase;
var
  DatabaseField: TDatabaseField;

  DatabaseForeignKey: TDatabaseForeignKey;

  DatabaseIndex: TDatabaseIndex;

  DatabaseTable: TDatabaseTable;

  ForeignKey: TForeignKey;

  Field: TField;

  Index: TIndex;

  Table: TTable;

  Tables: TDictionary<String, TTable>;

  function ExistsForeigKey(const DatabaseForeignKey: TDatabaseForeignKey): Boolean;
  begin
    Result := False;

    for var ForeignKey in Tables[DatabaseForeignKey.Table.Name].ForeignKeys do
      if ForeignKey.DatabaseName = DatabaseForeignKey.Name then
        Exit(True);
  end;

  function ExistsIndex(const DatabaseIndex: TDatabaseIndex): Boolean;
  begin
    Result := False;

    for var Index in Tables[DatabaseIndex.Table.Name].Indexes do
      if Index.DatabaseName = DatabaseIndex.Name then
        Exit(True);
  end;

  function ExistsField(const DatabaseField: TDatabaseField): Boolean;
  begin
    Result := False;

    for var Field in Tables[DatabaseField.Table.Name].Fields do
      if Field.DatabaseName = DatabaseField.Name then
        Exit(True);
  end;

  function CheckScale: Boolean;
  begin
    Result := (Field.FieldType.TypeKind = tkFloat) and (Field.SpecialType = stNotDefined);
  end;

  function FieldSizeChanged: Boolean;
  begin
    Result := (Field.Size <> DatabaseField.Size) and ((Field.FieldType.TypeKind = tkUString) and (Field.SpecialType = stNotDefined) or CheckScale);
  end;

  function FieldScaleChanged: Boolean;
  begin
    Result := (Field.Scale <> DatabaseField.Scale) and CheckScale;
  end;

  function FieldDatabaseTypeChanged: Boolean;
  begin
    Result := (Field.SpecialType <> DatabaseField.SpecialType);
  end;

  function FieldTypeChanged: Boolean;
  begin
    Result := (Field.FieldType.TypeKind <> DatabaseField.FieldType) and ((Field.FieldType.TypeKind <> tkEnumeration) or (DatabaseField.FieldType <> tkInteger));
  end;

  function FieldNullableChange: Boolean;
  begin
    Result := Field.Required <> DatabaseField.Required;
  end;

  function FieldDefaultValueChanged: Boolean;
  begin
    var DefaultFieldValue: String;

    if Field.DefaultInternalFunction = difNotDefined then
      DefaultFieldValue := Field.DefaultValue.AsString
    else
      DefaultFieldValue := FMetadataManipulator.GetInternalFunction(Field);

    Result := Assigned(DatabaseField.Default) and (DefaultFieldValue <> DatabaseField.Default.Value);
  end;

  function FieldChanged: Boolean;
  begin
    Result := FieldTypeChanged or FieldSizeChanged or FieldScaleChanged or FieldDatabaseTypeChanged or FieldNullableChange or FieldDefaultValueChanged;
  end;

begin
  var Schema := TDatabaseSchema.Create;
  Tables := TDictionary<String, TTable>.Create;

  FMetadataManipulator.LoadSchema(Schema);

  for Table in Mapper.Tables do
  begin
    DatabaseTable := Schema.Table[Table.DatabaseName];

    Tables.Add(Table.DatabaseName, Table);

    if Assigned(DatabaseTable) then
      for Field in Table.Fields do
      begin
        DatabaseField := DatabaseTable.Field[Field.DatabaseName];

        if not Assigned(DatabaseField) then
          CreateField(Field)
        else if FieldChanged then
          RecreateField(Field, DatabaseField);
      end
    else
      FMetadataManipulator.CreateTable(Table);
  end;

  for Table in Mapper.Tables do
  begin
    DatabaseTable := Schema.Table[Table.DatabaseName];

    if Assigned(DatabaseTable) then
    begin
      for Index in Table.Indexes do
      begin
        DatabaseIndex := DatabaseTable.Index[Index.DatabaseName];

        if not Assigned(DatabaseIndex) then
          FMetadataManipulator.CreateIndex(Index)
        else if not CheckSameFields(Index.Fields, DatabaseIndex.Fields) then
        begin
          FMetadataManipulator.DropIndex(DatabaseIndex);

          FMetadataManipulator.CreateIndex(Index);
        end;
      end;

      for ForeignKey in Table.ForeignKeys do
      begin
        DatabaseForeignKey := DatabaseTable.ForeignKey[ForeignKey.DatabaseName];

        if not Assigned(DatabaseForeignKey) then
          FMetadataManipulator.CreateForeignKey(ForeignKey)
        else if not CheckSameFields([ForeignKey.Field], DatabaseForeignKey.Fields) then
        begin
          FMetadataManipulator.DropForeignKey(DatabaseForeignKey);

          FMetadataManipulator.CreateForeignKey(ForeignKey)
        end;
      end;
    end;
  end;

  for DatabaseTable in Schema.Tables do
    if Tables.ContainsKey(DatabaseTable.Name) then
    begin
      for DatabaseForeignKey in DatabaseTable.ForeignKeys do
        if not ExistsForeigKey(DatabaseForeignKey) then
          FMetadataManipulator.DropForeignKey(DatabaseForeignKey);

      for DatabaseIndex in DatabaseTable.Indexes do
        if not ExistsIndex(DatabaseIndex) then
          FMetadataManipulator.DropIndex(DatabaseIndex);

      for DatabaseField in DatabaseTable.Fields do
        if not ExistsField(DatabaseField) then
          DropField(DatabaseField);
    end
    else
      FMetadataManipulator.DropTable(DatabaseTable);

  Schema.Free;

  Tables.Free;
end;

{ TDatabaseSchema }

constructor TDatabaseSchema.Create;
begin
  inherited;

  FTables := TObjectList<TDatabaseTable>.Create;
end;

destructor TDatabaseSchema.Destroy;
begin
  FTables.Free;

  inherited;
end;

function TDatabaseSchema.GetTable(const Name: String): TDatabaseTable;
begin
  Result := TDatabaseNamedObject.FindObject<TDatabaseTable>(Tables, Name);
end;

{ TDatabaseDefaultConstraint }

constructor TDatabaseDefaultConstraint.Create(const Field: TDatabaseField; const Name, Value: String);
begin
  inherited Create(Name);

  Field.Default := Self;
  FValue := Value;
end;

{ TDatabaseCheckConstraint }

constructor TDatabaseCheckConstraint.Create(const Field: TDatabaseField; const Name, Check: String);
begin
  inherited Create(Name);

  FCheck := Check;
end;

end.

