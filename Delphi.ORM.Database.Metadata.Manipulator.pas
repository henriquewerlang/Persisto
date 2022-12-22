unit Delphi.ORM.Database.Metadata.Manipulator;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Database.Connection;

type
  TMetadataManipulator = class(TInterfacedObject)
  private
    FConnection: IDatabaseConnection;
  protected
    function GetDefaultConstraintName(const Field: TField): String;
    function GetFieldCollation(const Field: TField): String;
    function GetFieldDefaultConstratint(const Field: TField): String;
    function GetFieldTypeDefinition(const Field: TField): String;
    function GetFieldType(const Field: TField): String; virtual; abstract;
    function GetInternalFunction(const Field: TField): String; virtual; abstract;
    function GetSpecialFieldType(const Field: TField): String; virtual; abstract;

    procedure CreateField(const Field: TField);
    procedure CreateForeignKey(const ForeignKey: TForeignKey);
    procedure CreateIndex(const Index: TIndex);
    procedure CreateTable(const Table: TTable);
    procedure DropDefaultConstraint(const Field: TDatabaseField);
    procedure DropField(const Field: TDatabaseField);
    procedure DropIndex(const Index: TDatabaseIndex);
    procedure DropForeignKey(const ForeignKey: TDatabaseForeignKey);
    procedure DropTable(const Table: TDatabaseTable);
    procedure UpdateField(const SourceField, DestinyField: TField);
  public
    constructor Create(const Connection: IDatabaseConnection);

    function GetFieldDefinition(const Field: TField): String;

    property Connection: IDatabaseConnection read FConnection;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Attributes;

{ TMetadataManipulator }

constructor TMetadataManipulator.Create(const Connection: IDatabaseConnection);
begin
  inherited Create;

  FConnection := Connection;
end;

procedure TMetadataManipulator.CreateField(const Field: TField);
begin
  Connection.ExecuteDirect(Format('alter table %s add %s', [Field.Table.DatabaseName, GetFieldDefinition(Field)]));
end;

procedure TMetadataManipulator.CreateForeignKey(const ForeignKey: TForeignKey);
begin

end;

procedure TMetadataManipulator.CreateIndex(const Index: TIndex);
begin

end;

procedure TMetadataManipulator.CreateTable(const Table: TTable);
begin
  var Fields := EmptyStr;

  for var Field in Table.Fields do
  begin
    if not Fields.IsEmpty then
      Fields := Fields + ',';

    Fields := Fields + GetFieldDefinition(Field);
  end;

  Connection.ExecuteDirect(Format('create table %s (%s)', [Table.DatabaseName, Fields]));
end;

procedure TMetadataManipulator.DropDefaultConstraint(const Field: TDatabaseField);
begin
  Connection.ExecuteDirect(Format('alter table %s drop constraint %s', [Field.Table.Name, Field.Default.Name]));
end;

procedure TMetadataManipulator.DropField(const Field: TDatabaseField);
begin
  Connection.ExecuteDirect(Format('alter table %s drop column %s', [Field.Table.Name, Field.Name]));
end;

procedure TMetadataManipulator.DropForeignKey(const ForeignKey: TDatabaseForeignKey);
begin

end;

procedure TMetadataManipulator.DropIndex(const Index: TDatabaseIndex);
begin

end;

procedure TMetadataManipulator.DropTable(const Table: TDatabaseTable);
begin
  Connection.ExecuteDirect(Format('drop table %s', [Table.Name]));
end;

function TMetadataManipulator.GetDefaultConstraintName(const Field: TField): String;
begin
  Result := Format('DF_%s_%s', [Field.Table.Name, Field.DatabaseName]);
end;

function TMetadataManipulator.GetFieldCollation(const Field: TField): String;
begin
  Result := EmptyStr;

  if not Field.Collation.IsEmpty then
    Result := Format(' collate %s', [Field.Collation]);
end;

function TMetadataManipulator.GetFieldDefaultConstratint(const Field: TField): String;
begin
  var DefaultValue := EmptyStr;

  if not Field.DefaultValue.IsEmpty then
    DefaultValue := Field.GetAsString(Field.DefaultValue)
  else if Field.DefaultInternalFunction <> difNotDefined then
    DefaultValue := GetInternalFunction(Field)
  else
    Result := EmptyStr;

  if not DefaultValue.IsEmpty then
    Result := Format(' constraint %s default(%s)', [GetDefaultConstraintName(Field), DefaultValue])
end;

function TMetadataManipulator.GetFieldDefinition(const Field: TField): String;
const
  IS_NULL_VALUE: array[Boolean] of String = ('', 'not ');

begin
  Result := Format('%s %s %snull%s%s', [Field.DatabaseName, GetFieldTypeDefinition(Field), IS_NULL_VALUE[Field.Required], GetFieldCollation(Field),
    GetFieldDefaultConstratint(Field)]);
end;

function TMetadataManipulator.GetFieldTypeDefinition(const Field: TField): String;
begin
  if Field.SpecialType = stNotDefined then
  begin
    Result := GetFieldType(Field);

    if Field.FieldType.TypeKind in [tkFloat, tkUString, tkWChar] then
    begin
      var Size := Field.Size.ToString;

      if Field.FieldType.TypeKind = tkFloat then
        Size := Size + ',' + Field.Scale.ToString;

      Result := Format('%s(%s)', [Result, Size]);
    end;
  end
  else
    Result := GetSpecialFieldType(Field);
end;

procedure TMetadataManipulator.UpdateField(const SourceField, DestinyField: TField);
begin
  Connection.ExecuteDirect(Format('update %s set %s = %s', [SourceField.Table.DatabaseName, DestinyField.DatabaseName, SourceField.DatabaseName]));
end;

end.

