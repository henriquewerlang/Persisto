unit Delphi.ORM.Database.Manipulator.SQLServer;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Manipulator, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Attributes, Delphi.ORM.Database.Connection;

type
  TManipulatorSQLServer = class(TManipulator, IMetadataManipulator)
  private
    FConnection: IDatabaseConnection;
    FFieldSpecialTypeMapping: TDictionary<String, TDatabaseSpecialType>;
    FFieldTypeMapping: TDictionary<String, TTypeKind>;

    function GetInternalFunction(const Field: TField): String;

    procedure LoadTables(const Tables: TDictionary<String, TDatabaseTable>);
  public
    constructor Create(const Connection: IDatabaseConnection);

    destructor Destroy; override;
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
           'on Ty.system_type_id = C.system_type_id ' +
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

{ TManipulatorSQLServer }

constructor TManipulatorSQLServer.Create(const Connection: IDatabaseConnection);
begin
  inherited Create;

  FConnection := Connection;
  FFieldTypeMapping := TDictionary<String, TTypeKind>.Create;
  FFieldSpecialTypeMapping := TDictionary<String, TDatabaseSpecialType>.Create;

  FFieldTypeMapping.Add('bigint', tkInt64);
  FFieldTypeMapping.Add('bit', tkEnumeration);
  FFieldTypeMapping.Add('char', tkChar);
  FFieldTypeMapping.Add('date', tkFloat);
  FFieldTypeMapping.Add('datetime', tkFloat);
  FFieldTypeMapping.Add('int', tkInteger);
  FFieldTypeMapping.Add('numeric', tkFloat);
  FFieldTypeMapping.Add('smallint', tkInteger);
  FFieldTypeMapping.Add('text', tkUString);
  FFieldTypeMapping.Add('time', tkFloat);
  FFieldTypeMapping.Add('tinyint', tkInteger);
  FFieldTypeMapping.Add('uniqueidentifier', tkUString);
  FFieldTypeMapping.Add('varchar', tkUString);

  FFieldSpecialTypeMapping.Add('date', stDate);
  FFieldSpecialTypeMapping.Add('datetime', stDateTime);
  FFieldSpecialTypeMapping.Add('time', stTime);
  FFieldSpecialTypeMapping.Add('uniqueidentifier', stUniqueIdentifier);
  FFieldSpecialTypeMapping.Add('text', stText);
  FFieldSpecialTypeMapping.Add('varchar(max)', stText);
end;

destructor TManipulatorSQLServer.Destroy;
begin
  FFieldTypeMapping.Free;

  FFieldSpecialTypeMapping.Free;

  inherited;
end;

function TManipulatorSQLServer.GetInternalFunction(const Field: TField): String;
const
  INTERNAL_FUNCTIONS: array[TDatabaseInternalFunction] of String = ('', 'getdate()', 'newuniqueidentifier()', 'newid()');

begin
  Result := INTERNAL_FUNCTIONS[Field.DefaultInternalFunction];
end;

procedure TManipulatorSQLServer.LoadTables(const Tables: TDictionary<String, TDatabaseTable>);
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

  procedure LoadFieldInfo;
  begin
    var Field := TDatabaseField.Create(Table, Cursor.GetFieldValue(COLUMN_NAME_INDEX));
    var FieldType := Cursor.GetFieldValue(COLUMN_TYPE_INDEX);
    Field.Collation := VarToStr(Cursor.GetFieldValue(COLUMN_COLLATION_INDEX));
    Field.DefaultName := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_NAME_INDEX));
    Field.DefaultValue := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_VALUE_INDEX));
    Field.DefaultValue := Field.DefaultValue.SubString(1, Field.DefaultValue.Length - 2);
    Field.FieldType := FFieldTypeMapping[FieldType];
    Field.Nullable := Cursor.GetFieldValue(COLUMN_NULLABLE_INDEX) = 1;
    Field.Scale := Cursor.GetFieldValue(COLUMN_SCALE_INDEX);
    Field.Size := Cursor.GetFieldValue(COLUMN_SIZE_INDEX) + Cursor.GetFieldValue(COLUMN_PRECISION_INDEX);

    if (Field.FieldType = tkUString) and (Field.Size = Word(-1)) then
      FieldType := 'varchar(max)';

    if FFieldSpecialTypeMapping.ContainsKey(FieldType) then
      Field.SpecialType := FFieldSpecialTypeMapping[FieldType];
  end;

begin
  Cursor := FConnection.OpenCursor(TABLE_LOAD_SQL);

  while Cursor.Next do
  begin
    var TableName := Cursor.GetFieldValue(TABLE_NAME_INDEX);

    if not Tables.TryGetValue(TableName, Table) then
    begin
      Table := TDatabaseTable.Create(TableName);

      Tables.Add(Table.Name, Table);
    end;

    LoadFieldInfo;
  end;

  Cursor := FConnection.OpenCursor(INDEX_LOAD_SQL);

  while Cursor.Next do
  begin
    var IndexName: String := Cursor.GetFieldValue(INDEX_NAME_INDEX);
    Table := Tables[Cursor.GetFieldValue(TABLE_NAME_INDEX)];

    if not Table.Indexes.TryGetValue(IndexName, Index) then
    begin
      Index := TDatabaseIndex.Create(Table, IndexName);
      Index.PrimaryKey := Cursor.GetFieldValue(INDEX_PRIMARY_KEY_INDEX) = 1;
      Index.Unique := Cursor.GetFieldValue(INDEX_UNIQUE_INDEX) = 1;
    end;

    Index.Fields := Index.Fields + [Table.Fields[Cursor.GetFieldValue(INDEX_FIELD_NAME_INDEX)]];
  end;

  Cursor := FConnection.OpenCursor(FOREIGN_KEY_LOAD_SQL);

  while Cursor.Next do
  begin
    var ForeignKeyName: String := Cursor.GetFieldValue(FOREIGN_KEY_NAME_INDEX);
    var ReferenceTable := Tables[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_NAME_INDEX)];
    Table := Tables[Cursor.GetFieldValue(TABLE_NAME_INDEX)];

    if not Table.ForeignKeys.TryGetValue(ForeignKeyName, ForeignKey) then
      ForeignKey := TDatabaseForeignKey.Create(Table, ForeignKeyName, ReferenceTable);

    ForeignKey.Fields := ForeignKey.Fields + [Table.Fields[Cursor.GetFieldValue(FOREIGN_KEY_PARENT_FIELD_NAME_INDEX)]];
    ForeignKey.FieldsReference := ForeignKey.FieldsReference + [ReferenceTable.Fields[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_FIELD_NAME_INDEX)]];
  end;
end;

end.

