unit Delphi.ORM.Database.Manipulator.SQLServer;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Metadata.Manipulator, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Attributes, Delphi.ORM.Database.Connection;

type
  TManipulatorSQLServer = class(TMetadataManipulator, IMetadataManipulator)
  private
    FFieldSpecialTypeMapping: TDictionary<String, TDatabaseSpecialType>;
    FFieldTypeMapping: TDictionary<String, TTypeKind>;

    procedure LoadSchema(const Schema: TDatabaseSchema);
  protected
    function GetInternalFunction(const Field: TField): String; override;
  public
    constructor Create(const Connection: IDatabaseConnection);

    destructor Destroy; override;

    function GetFieldType(const Field: TField): String; override;
    function GetSpecialFieldType(const Field: TField): String; override;
  end;

  TDatabaseDefaultConstraintSQLServer = class(TDatabaseDefaultConstraint)
  public
    constructor Create(const Field: TDatabaseField; const Name, Value: String);
  end;

const
  TABLE_LOAD_SQL =
       'select T.name TableName,' +
              'C.name ColumnName,' +
              'Ty.name TypeName,' +
              'C.max_length Size,' +
              'C.precision Precision,' +
              'C.scale Scale,' +
              'C.is_nullable Nullable,' +
              'C.collation_name Collation,' +
              'DC.name DefaultName,' +
              'DC.definition DefaultValue ' +
         'from sys.tables T ' +
         'join sys.columns C ' +
           'on C.object_id = T.object_id ' +
         'join sys.types Ty ' +
           'on Ty.user_type_id = C.user_type_id ' +
    'left join sys.default_constraints DC ' +
           'on DC.object_id = C.default_object_id ' +
     'order by TableName, ColumnName';

  INDEX_LOAD_SQL =
      'select T.name TableName,' +
             'I.name IndexName,' +
             'CI.name IndexColumnName,' +
             'I.is_primary_key PrimaryKey,' +
             'I.is_unique [Unique] ' +
        'from sys.tables T ' +
        'join sys.indexes I ' +
          'on I.object_id = T.object_id ' +
        'join sys.index_columns IC ' +
          'on IC.object_id = T.object_id ' +
         'and IC.index_id = I.index_id ' +
        'join sys.columns CI ' +
          'on CI.object_id = IC.object_id ' +
         'and CI.column_id = IC.column_id ' +
    'order by TableName, IndexName, IC.index_column_id';

  FOREIGN_KEY_LOAD_SQL =
      'select T.name TableName,' +
             'FK.name ForeignKeyName,' +
             'PC.name ParentColumnName,' +
             'RT.name ReferenceTableName,' +
             'PR.name ReferenceColumnName ' +
        'from sys.tables T ' +
        'join sys.foreign_keys FK ' +
          'on FK.parent_object_id = T.object_id ' +
        'join sys.foreign_key_columns FKC ' +
          'on FKC.constraint_object_id = FK.object_id ' +
        'join sys.columns PC ' +
          'on PC.object_id = FKC.parent_object_id ' +
         'and PC.column_id = FKC.parent_column_id ' +
        'join sys.tables RT ' +
          'on RT.object_id = FK.referenced_object_id ' +
        'join sys.columns PR ' +
          'on PR.object_id = FKC.referenced_object_id ' +
         'and PR.column_id = FKC.referenced_column_id ' +
    'order by TableName, ForeignKeyName, FKC.constraint_column_id';

implementation

uses System.Variants, System.SysUtils;

const
  FIELD_SPECIAL_TYPE_MAPPING: array[TDatabaseSpecialType] of String = ('', 'date', 'datetime', 'time', 'varchar(max)', 'uniqueidentifier', 'bit');
  FIELD_TYPE_MAPPING: array[TTypeKind] of String = ('', 'int', '', 'tinyint', 'numeric', '', '', '', '', 'char', '', '', '', '', '', '', 'bigint', '', 'varchar', '', '', '', '');
  SPECIAL_TYPE_IN_SYSTEM_TYPE: array[TDatabaseSpecialType] of TTypeKind = (tkUnknown, tkFloat, tkFloat, tkFloat, tkUString, tkUString, tkEnumeration);

{ TManipulatorSQLServer }

constructor TManipulatorSQLServer.Create(const Connection: IDatabaseConnection);
begin
  inherited;

  FFieldTypeMapping := TDictionary<String, TTypeKind>.Create;
  FFieldSpecialTypeMapping := TDictionary<String, TDatabaseSpecialType>.Create;

  for var AType := Low(TTypeKind) to High(TTypeKind) do
    if not FIELD_TYPE_MAPPING[AType].IsEmpty then
      FFieldTypeMapping.Add(FIELD_TYPE_MAPPING[AType], AType);

  for var AType := Succ(Low(TDatabaseSpecialType)) to High(TDatabaseSpecialType) do
  begin
    FFieldSpecialTypeMapping.Add(FIELD_SPECIAL_TYPE_MAPPING[AType], AType);

    FFieldTypeMapping.Add(FIELD_SPECIAL_TYPE_MAPPING[AType], SPECIAL_TYPE_IN_SYSTEM_TYPE[AType]);
  end;

  FFieldSpecialTypeMapping.Add('text', stText);

  FFieldTypeMapping.Add('text', tkUString);
end;

destructor TManipulatorSQLServer.Destroy;
begin
  FFieldTypeMapping.Free;

  FFieldSpecialTypeMapping.Free;

  inherited;
end;

function TManipulatorSQLServer.GetFieldType(const Field: TField): String;
begin
  Result := FIELD_TYPE_MAPPING[Field.FieldType.TypeKind]
end;

function TManipulatorSQLServer.GetInternalFunction(const Field: TField): String;
const
  INTERNAL_FUNCTIONS: array[TDatabaseInternalFunction] of String = ('', 'getdate()', 'newuniqueidentifier()', 'newid()');

begin
  Result := INTERNAL_FUNCTIONS[Field.DefaultInternalFunction];
end;

function TManipulatorSQLServer.GetSpecialFieldType(const Field: TField): String;
begin
  Result := FIELD_SPECIAL_TYPE_MAPPING[Field.SpecialType];
end;

procedure TManipulatorSQLServer.LoadSchema(const Schema: TDatabaseSchema);
const
  COLUMN_COLLATION_INDEX = 7;
  COLUMN_DEFAULT_NAME_INDEX = 8;
  COLUMN_DEFAULT_VALUE_INDEX = 9;
  COLUMN_NAME_INDEX = 1;
  COLUMN_NULLABLE_INDEX = 6;
  COLUMN_PRECISION_INDEX = 4;
  COLUMN_SCALE_INDEX = 5;
  COLUMN_SIZE_INDEX = 3;
  COLUMN_TYPE_INDEX = 2;
  FOREIGN_KEY_NAME_INDEX = 1;
  FOREIGN_KEY_PARENT_FIELD_NAME_INDEX = 2;
  FOREIGN_KEY_REFERENCE_NAME_INDEX = 3;
  FOREIGN_KEY_REFERENCE_FIELD_NAME_INDEX = 4;
  INDEX_FIELD_NAME_INDEX = 2;
  INDEX_NAME_INDEX = 1;
  INDEX_PRIMARY_KEY_INDEX = 3;
  INDEX_UNIQUE_INDEX = 4;
  TABLE_NAME_INDEX = 0;

var
  Cursor: IDatabaseCursor;

  ForeignKey: TDatabaseForeignKey;

  Index: TDatabaseIndex;

  Table: TDatabaseTable;

  Field: TDatabaseField;

  procedure LoadDefaultValue;
  begin
    var DefaultName := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_NAME_INDEX));
    var DefaultValue := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_VALUE_INDEX));

    if not DefaultName.IsEmpty then
      TDatabaseDefaultConstraintSQLServer.Create(Field, DefaultName, DefaultValue);
  end;

  procedure LoadFieldInfo;
  begin
    Field := TDatabaseField.Create(Table, Cursor.GetFieldValue(COLUMN_NAME_INDEX));
    var FieldType := Cursor.GetFieldValue(COLUMN_TYPE_INDEX);
    Field.Collation := VarToStr(Cursor.GetFieldValue(COLUMN_COLLATION_INDEX));
    Field.Required := Cursor.GetFieldValue(COLUMN_NULLABLE_INDEX) = 0;
    Field.Scale := Cursor.GetFieldValue(COLUMN_SCALE_INDEX);
    Field.Size := Cursor.GetFieldValue(COLUMN_SIZE_INDEX) + Cursor.GetFieldValue(COLUMN_PRECISION_INDEX);

    if FFieldTypeMapping.ContainsKey(FieldType) then
      Field.FieldType := FFieldTypeMapping[FieldType];

    if (Field.FieldType = tkUString) and (Field.Size = Word(-1)) then
      FieldType := 'varchar(max)';

    if FFieldSpecialTypeMapping.ContainsKey(FieldType) then
      Field.SpecialType := FFieldSpecialTypeMapping[FieldType];

    LoadDefaultValue;
  end;

begin
  Cursor := Connection.OpenCursor(TABLE_LOAD_SQL);

  while Cursor.Next do
  begin
    var TableName := Cursor.GetFieldValue(TABLE_NAME_INDEX);

    Table := Schema.Table[TableName];

    if not Assigned(Table) then
      Table := TDatabaseTable.Create(Schema, TableName);

    LoadFieldInfo;
  end;

  Cursor := Connection.OpenCursor(INDEX_LOAD_SQL);

  while Cursor.Next do
  begin
    var IndexName: String := Cursor.GetFieldValue(INDEX_NAME_INDEX);
    Table := Schema.Table[Cursor.GetFieldValue(TABLE_NAME_INDEX)];

    Index := Table.Index[IndexName];

    if not Assigned(Index) then
    begin
      Index := TDatabaseIndex.Create(Table, IndexName);
      Index.PrimaryKey := Cursor.GetFieldValue(INDEX_PRIMARY_KEY_INDEX) = 1;
      Index.Unique := Cursor.GetFieldValue(INDEX_UNIQUE_INDEX) = 1;
    end;

    Index.Fields := Index.Fields + [Table.Field[Cursor.GetFieldValue(INDEX_FIELD_NAME_INDEX)]];
  end;

  Cursor := Connection.OpenCursor(FOREIGN_KEY_LOAD_SQL);

  while Cursor.Next do
  begin
    var ForeignKeyName: String := Cursor.GetFieldValue(FOREIGN_KEY_NAME_INDEX);
    var ReferenceTable := Schema.Table[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_NAME_INDEX)];
    Table := Schema.Table[Cursor.GetFieldValue(TABLE_NAME_INDEX)];

    ForeignKey := Table.ForeignKey[ForeignKeyName];

    if not Assigned(ForeignKey) then
      ForeignKey := TDatabaseForeignKey.Create(Table, ForeignKeyName, ReferenceTable);

    ForeignKey.Fields := ForeignKey.Fields + [Table.Field[Cursor.GetFieldValue(FOREIGN_KEY_PARENT_FIELD_NAME_INDEX)]];
    ForeignKey.FieldsReference := ForeignKey.FieldsReference + [ReferenceTable.Field[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_FIELD_NAME_INDEX)]];
  end;
end;

{ TDatabaseDefaultConstraintSQLServer }

constructor TDatabaseDefaultConstraintSQLServer.Create(const Field: TDatabaseField; const Name, Value: String);
begin
  inherited Create(Field, Name, Value.SubString(1, Value.Length - 2));
end;

end.

