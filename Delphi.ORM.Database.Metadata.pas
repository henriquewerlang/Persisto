unit Delphi.ORM.Database.Metadata;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Connection, Delphi.ORM.Mapper, Delphi.ORM.Attributes;

type
  TDatabaseField = class;
  TDatabaseForeignKey = class;
  TDatabaseIndex = class;
  TDatabaseTable = class;

  IMetadataManipulator = interface
    function GetInternalFunction(const Field: TField): String;

    procedure CreateField(const Field: TField);
    procedure CreateForeignKey(const ForeignKey: TForeignKey);
    procedure CreateIndex(const Index: TIndex);
    procedure CreateTable(const Table: TTable);
    procedure DropField(const Field: TDatabaseField);
    procedure DropIndex(const Index: TDatabaseIndex);
    procedure DropForeignKey(const ForeignKey: TDatabaseForeignKey);
    procedure DropTable(const Table: TDatabaseTable);
    procedure LoadTables(const Tables: TDictionary<String, TDatabaseTable>);
    procedure UpdateField(const SourceField, DestinyField: TField);
  end;

  TDatabaseNamedObject = class
  private
    FName: String;
  public
    constructor Create(const Name: String);

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
    FFields: TDictionary<String, TDatabaseField>;
    FForeignKeys: TDictionary<String, TDatabaseForeignKey>;
    FIndexes: TDictionary<String, TDatabaseIndex>;
  public
    constructor Create(const Name: String);

    destructor Destroy; override;

    property Fields: TDictionary<String, TDatabaseField> read FFields;
    property ForeignKeys: TDictionary<String, TDatabaseForeignKey> read FForeignKeys;
    property Indexes: TDictionary<String, TDatabaseIndex> read FIndexes;
  end;

  TDatabaseField = class(TDatabaseTableObject)
  private
    FCollation: String;
    FDefaultName: String;
    FDefaultValue: String;
    FFieldType: TTypeKind;
    FNullable: Boolean;
    FSize: Word;
    FScale: Word;
    FSpecialType: TDatabaseSpecialType;
  public
    constructor Create(const Table: TDatabaseTable; const Name: String);

    property Collation: String read FCollation write FCollation;
    property DefaultName: String read FDefaultName write FDefaultName;
    property DefaultValue: String read FDefaultValue write FDefaultValue;
    property FieldType: TTypeKind read FFieldType write FFieldType;
    property Nullable: Boolean read FNullable write FNullable;
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

  TDatabaseMetadataUpdate = class
  private
    FTempField: TField;
    FMapper: TMapper;
    FMetadataManipulator: IMetadataManipulator;

    function CheckSameFields(const Fields: TArray<TField>; const DatabaseFields: TArray<TDatabaseField>): Boolean;
    function GetMapper: TMapper; inline;

    procedure RecreateField(const Field: TField; const DatabaseField: TDatabaseField);
  public
    constructor Create(const MetadataManipulator: IMetadataManipulator);

    destructor Destroy; override;

    procedure UpdateDatabase;

    property Mapper: TMapper read GetMapper write FMapper;
  end;

implementation

uses System.SysUtils, System.TypInfo, System.Rtti;

{ TDatabaseNamedObject }

constructor TDatabaseNamedObject.Create(const Name: String);
begin
  inherited Create;

  FName := Name;
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
  FTable.ForeignKeys.Add(Name, Self);
end;

{ TDatabaseField }

constructor TDatabaseField.Create(const Table: TDatabaseTable; const Name: String);
begin
  inherited;

  FTable.Fields.Add(Name, Self);
end;

{ TDatabaseIndex }

constructor TDatabaseIndex.Create(const Table: TDatabaseTable; const Name: String);
begin
  inherited;

  FTable.Indexes.Add(Name, Self);
end;

{ TDatabaseTable }

constructor TDatabaseTable.Create(const Name: String);
begin
  inherited;

  FFields := TObjectDictionary<String, TDatabaseField>.Create([doOwnsValues]);
  FForeignKeys := TObjectDictionary<String, TDatabaseForeignKey>.Create([doOwnsValues]);
  FIndexes := TObjectDictionary<String, TDatabaseIndex>.Create([doOwnsValues]);
end;

destructor TDatabaseTable.Destroy;
begin
  FFields.Free;

  FForeignKeys.Free;

  FIndexes.Free;

  inherited;
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

destructor TDatabaseMetadataUpdate.Destroy;
begin
  FTempField.Free;

  inherited;
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
  FTempField.DefaultValue := Field.DefaultValue;
  FTempField.DefaultInternalFunction := Field.DefaultInternalFunction;
  FTempField.FieldType := Field.FieldType;
  FTempField.IsNullable := Field.IsNullable;
  FTempField.Name := Field.Name;
  FTempField.Scale := Field.Scale;
  FTempField.Size := Field.Size;
  FTempField.SpecialType := Field.SpecialType;

  FMetadataManipulator.CreateField(FTempField);

  FMetadataManipulator.UpdateField(Field, FTempField);

  FMetadataManipulator.DropField(DatabaseField);

  FMetadataManipulator.CreateField(Field);

  FMetadataManipulator.UpdateField(FTempField, Field);

  TDatabaseField.Create(DatabaseField.Table, FTempField.DatabaseName);
end;

procedure TDatabaseMetadataUpdate.UpdateDatabase;
var
  DatabaseField: TDatabaseField;

  DatabaseForeignKey: TDatabaseForeignKey;

  DatabaseIndex: TDatabaseIndex;

  DatabaseTable: TDatabaseTable;

  DatabaseTables: TObjectDictionary<String, TDatabaseTable>;

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
    Result := (Field.FieldType.TypeKind in [tkFloat]) and (Field.FieldType.Handle <> TypeInfo(TDate)) and (Field.FieldType.Handle <> TypeInfo(TDateTime))
      and (Field.FieldType.Handle <> TypeInfo(TTime));
  end;

  function FieldSizeChanged: Boolean;
  begin
    Result := (Field.Size <> DatabaseField.Size) and ((Field.FieldType.TypeKind in [tkUString]) and (Field.SpecialType = stNotDefined) or CheckScale);
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
    Result := Field.IsNullable <> DatabaseField.Nullable;
  end;

  function FieldDefaultValueChanged: Boolean;
  begin
    var DefaultFieldValue: String;

    if Field.DefaultInternalFunction = difNotDefined then
      DefaultFieldValue := Field.DefaultValue.AsString
    else
      DefaultFieldValue := FMetadataManipulator.GetInternalFunction(Field);

    Result := DefaultFieldValue <> DatabaseField.DefaultValue;
  end;

  function FieldChanged: Boolean;
  begin
    Result := FieldTypeChanged or FieldSizeChanged or FieldScaleChanged or FieldDatabaseTypeChanged or FieldNullableChange or FieldDefaultValueChanged;
  end;

begin
  DatabaseTables := TObjectDictionary<String, TDatabaseTable>.Create([doOwnsValues]);
  Tables := TDictionary<String, TTable>.Create;

  FMetadataManipulator.LoadTables(DatabaseTables);

  for Table in Mapper.Tables do
  begin
    Tables.Add(Table.DatabaseName, Table);

    if DatabaseTables.TryGetValue(Table.DatabaseName, DatabaseTable) then
    begin
      for Field in Table.Fields do
        if not DatabaseTable.Fields.TryGetValue(Field.DatabaseName, DatabaseField) then
          FMetadataManipulator.CreateField(Field)
        else if FieldChanged then
          RecreateField(Field, DatabaseField);
    end
    else
      FMetadataManipulator.CreateTable(Table);
  end;

  for Table in Mapper.Tables do
    if DatabaseTables.TryGetValue(Table.DatabaseName, DatabaseTable) then
    begin
      for Index in Table.Indexes do
        if not DatabaseTable.Indexes.TryGetValue(Index.DatabaseName, DatabaseIndex) then
          FMetadataManipulator.CreateIndex(Index)
        else if not CheckSameFields(Index.Fields, DatabaseIndex.Fields) then
        begin
          FMetadataManipulator.DropIndex(DatabaseIndex);

          FMetadataManipulator.CreateIndex(Index);
        end;

      for ForeignKey in Table.ForeignKeys do
        if not DatabaseTable.ForeignKeys.TryGetValue(ForeignKey.DatabaseName, DatabaseForeignKey) then
          FMetadataManipulator.CreateForeignKey(ForeignKey)
        else if not CheckSameFields([ForeignKey.Field], DatabaseForeignKey.Fields) then
        begin
          FMetadataManipulator.DropForeignKey(DatabaseForeignKey);

          FMetadataManipulator.CreateForeignKey(ForeignKey)
        end;
    end;

  for DatabaseTable in DatabaseTables.Values do
    if Tables.ContainsKey(DatabaseTable.Name) then
    begin
      for DatabaseForeignKey in DatabaseTable.ForeignKeys.Values do
        if not ExistsForeigKey(DatabaseForeignKey) then
          FMetadataManipulator.DropForeignKey(DatabaseForeignKey);

      for DatabaseIndex in DatabaseTable.Indexes.Values do
        if not ExistsIndex(DatabaseIndex) then
          FMetadataManipulator.DropIndex(DatabaseIndex);

      for DatabaseField in DatabaseTable.Fields.Values do
        if not ExistsField(DatabaseField) then
          FMetadataManipulator.DropField(DatabaseField);
    end
    else
      FMetadataManipulator.DropTable(DatabaseTable);

  Tables.Free;

  DatabaseTables.Free;
end;

end.

