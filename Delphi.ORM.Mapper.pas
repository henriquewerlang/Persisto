unit Delphi.ORM.Mapper;

interface

uses System.Rtti, System.Generics.Collections, System.Generics.Defaults, System.SysUtils;

type
  EClassWithoutPrimaryKeyDefined = class(Exception);
  TField = class;
  TForeignKey = class;

  TTable = class
  private
    FPrimaryKey: TArray<TField>;
    FForeignKeys: TArray<TForeignKey>;
    FFields: TArray<TField>;
    FTypeInfo: TRttiInstanceType;
    FDatabaseName: String;
  public
    constructor Create(TypeInfo: TRttiInstanceType);

    destructor Destroy; override;

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Fields: TArray<TField> read FFields;
    property ForeignKeys: TArray<TForeignKey> read FForeignKeys;
    property PrimaryKey: TArray<TField> read FPrimaryKey;
    property TypeInfo: TRttiInstanceType read FTypeInfo;
  end;

  TField = class
  private
    FDatabaseName: String;
    FInPrimaryKey: Boolean;
    FTypeInfo: TRttiInstanceProperty;
  public
    property DatabaseName: String read FDatabaseName;
    property InPrimaryKey: Boolean read FInPrimaryKey;
    property TypeInfo: TRttiInstanceProperty read FTypeInfo;
  end;

  TFieldAlias = record
  private
    FAlias: String;
    FField: TField;
  public
    constructor Create(Field: TField; Alias: String);

    property Alias: String read FAlias;
    property Field: TField read FField;
  end;

  TForeignKey = class
  private
    FParentTable: TTable;
    FField: TField;
  public
    constructor Create(ParentTable: TTable; Field: TField);

    property Field: TField read FField;
    property ParentTable: TTable read FParentTable;
  end;

  TMapper = class
  private
    class var [Unsafe] FDefault: TMapper;

    class constructor Create;
    class destructor Destroy;
  private
    FContext: TRttiContext;
    FTables: TArray<TTable>;

    function CheckAttribute<T: TCustomAttribute>(TypeInfo: TRttiType): Boolean;
    function CreateComparer: IComparer<TTable>;
    function GetFieldName(TypeInfo: TRttiInstanceProperty): String;
    function GetNameAttribute(TypeInfo: TRttiNamedObject; var Name: String): Boolean;
    function GetPrimaryKey(TypeInfo: TRttiInstanceType): TArray<String>;
    function GetTableName(TypeInfo: TRttiInstanceType): String;
    function LoadTable(TypeInfo: TRttiInstanceType): TTable;

    procedure FinishLoad;
    procedure LoadForeignKeys;
    procedure SortTables;
  public
    constructor Create;

    destructor Destroy; override;

    function FindTable(ClassInfo: TClass): TTable;
    function LoadClass(ClassInfo: TClass): TTable;

    procedure LoadAll;

    property Tables: TArray<TTable> read FTables;

    class property Default: TMapper read FDefault;
  end;

implementation

uses System.TypInfo, Delphi.ORM.Attributes, Delphi.ORM.Rtti.Helper;

{ TMapper }

function TMapper.CheckAttribute<T>(TypeInfo: TRttiType): Boolean;
begin
  Result := False;

  for var TypeToCompare in TypeInfo.GetAttributes do
    if TypeToCompare is T then
      Exit(True);
end;

class constructor TMapper.Create;
begin
  FDefault := TMapper.Create;
end;

constructor TMapper.Create;
begin
  FContext := TRttiContext.Create;
end;

function TMapper.CreateComparer: IComparer<TTable>;
begin
  Result := TDelegatedComparer<TTable>.Create(
    function(const Left, Right: TTable): Integer
    begin
      Result := CompareStr(Left.TypeInfo.Name, Right.TypeInfo.Name);
    end);
end;

destructor TMapper.Destroy;
begin
  for var Table in Tables do
    Table.Free;

  FContext.Free;
end;

function TMapper.FindTable(ClassInfo: TClass): TTable;
begin
  var Find := TTable.Create(FContext.GetType(ClassInfo) as TRttiInstanceType);
  var Index := 0;

  if TArray.BinarySearch<TTable>(FTables, Find, Index, CreateComparer) then
    Result := Tables[Index]
  else
    Result := nil;

  Find.Free;
end;

procedure TMapper.FinishLoad;
begin
  SortTables;

  LoadForeignKeys;
end;

function TMapper.GetFieldName(TypeInfo: TRttiInstanceProperty): String;
begin
  if not GetNameAttribute(TypeInfo, Result) then
  begin
    Result := TypeInfo.Name;

    if TypeInfo.PropertyType.IsInstance then
      Result := 'Id' + Result;
  end;
end;

function TMapper.GetNameAttribute(TypeInfo: TRttiNamedObject; var Name: String): Boolean;
begin
  var Attribute := TypeInfo.GetAttribute<TCustomNameAttribute>;
  Result := Assigned(Attribute);

  if Result then
    Name := Attribute.Name;
end;

function TMapper.GetPrimaryKey(TypeInfo: TRttiInstanceType): TArray<String>;
begin
  var Attribute := TypeInfo.GetAttribute<PrimaryKeyAttribute>;

  if Assigned(Attribute) then
    Result := Attribute.Fields
  else
    Result := ['Id'];
end;

function TMapper.GetTableName(TypeInfo: TRttiInstanceType): String;
begin
  if not GetNameAttribute(TypeInfo, Result) then
    Result := TypeInfo.Name.Substring(1);
end;

class destructor TMapper.Destroy;
begin
  FDefault.Free;
end;

procedure TMapper.LoadAll;
begin
  for var TypeInfo in FContext.GetTypes do
    if CheckAttribute<EntityAttribute>(TypeInfo) then
      LoadTable(TypeInfo as TRttiInstanceType);

  FinishLoad;
end;

function TMapper.LoadClass(ClassInfo: TClass): TTable;
begin
  Result := LoadTable(FContext.GetType(ClassInfo) as TRttiInstanceType);

  FinishLoad;
end;

procedure TMapper.LoadForeignKeys;
begin
  for var Table in FTables do
    for var Field in Table.Fields do
      if Field.TypeInfo.PropertyType.IsInstance then
      begin
        var ForeignTable := FindTable((Field.TypeInfo.PropertyType as TRttiInstanceType).MetaclassType);

        if Length(ForeignTable.PrimaryKey) = 0 then
          raise EClassWithoutPrimaryKeyDefined.CreateFmt('You must define a primary key for class %s!', [ForeignTable.TypeInfo.Name]);

        Table.FForeignKeys := Table.FForeignKeys + [TForeignKey.Create(ForeignTable, Field)];
      end;
end;

function TMapper.LoadTable(TypeInfo: TRttiInstanceType): TTable;
begin
  var PrimaryKey := GetPrimaryKey(TypeInfo);
  Result := TTable.Create(TypeInfo);
  Result.DatabaseName := GetTableName(TypeInfo);

  for var Prop in TypeInfo.GetDeclaredProperties do
    if Prop.Visibility = mvPublished then
    begin
      var Field := TField.Create;
      Field.FDatabaseName := GetFieldName(Prop as TRttiInstanceProperty);
      Field.FTypeInfo := Prop as TRttiInstanceProperty;
      Result.FFields := Result.FFields + [Field];
    end;

  for var PropertyName in PrimaryKey do
    for var Field in Result.Fields do
      if Field.TypeInfo.Name = PropertyName then
      begin
        Field.FInPrimaryKey := True;
        Result.FPrimaryKey := Result.FPrimaryKey + [Field];
      end;

  FTables := FTables + [Result];
end;

procedure TMapper.SortTables;
begin
  TArray.Sort<TTable>(FTables, CreateComparer);
end;

{ TTable }

constructor TTable.Create(TypeInfo: TRttiInstanceType);
begin
  inherited Create;

  FTypeInfo := TypeInfo;
end;

destructor TTable.Destroy;
begin
  for var Field in Fields do
    Field.Free;

  for var ForeignKey in ForeignKeys do
    ForeignKey.Free;

  inherited;
end;

{ TFieldAlias }

constructor TFieldAlias.Create(Field: TField; Alias: String);
begin
  FAlias := Alias;
  FField := Field;
end;

{ TForeignKey }

constructor TForeignKey.Create(ParentTable: TTable; Field: TField);
begin
  inherited Create;

  FParentTable := ParentTable;
  FField := Field;
end;

end.
