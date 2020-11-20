unit Delphi.ORM.Mapper;

interface

uses System.Rtti, System.Generics.Collections, System.Generics.Defaults;

type
  TField = class;
  TJoin = class;

  TTable = class
  private
    FPrimaryKey: TArray<TField>;
    FJoins: TArray<TJoin>;
    FFields: TArray<TField>;
    FTypeInfo: TRttiInstanceType;
    FDatabaseName: String;
  public
    constructor Create(TypeInfo: TRttiInstanceType);

    destructor Destroy; override;

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Fields: TArray<TField> read FFields;
    property Joins: TArray<TJoin> read FJoins;
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
    FField: TField;
    FAlias: String;
  public
    constructor Create(Field: TField; Alias: String);

    property Alias: String read FAlias write FAlias;
    property Field: TField read FField write FField;
  end;

  TJoin = class

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
    function GetPrimaryKey(TypeInfo: TRttiInstanceType): TArray<String>;
    function GetTableName(TypeInfo: TRttiInstanceType): String;
    function LoadTable(TypeInfo: TRttiInstanceType): TTable;

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

uses System.SysUtils, System.TypInfo, Delphi.ORM.Attributes, Delphi.ORM.Rtti.Helper;

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
  var Attribute := TypeInfo.GetAttribute<TableNameAttribute>;

  if Assigned(Attribute) then
    Result := Attribute.Name
  else
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

  SortTables;
end;

function TMapper.LoadClass(ClassInfo: TClass): TTable;
begin
  Result := LoadTable(FContext.GetType(ClassInfo) as TRttiInstanceType);

  SortTables;
end;

function TMapper.LoadTable(TypeInfo: TRttiInstanceType): TTable;
begin
  var PrimaryKey := GetPrimaryKey(TypeInfo);
  Result := TTable.Create(TypeInfo);
  Result.DatabaseName := GetTableName(TypeInfo);

  for var Prop in TypeInfo.GetProperties do
    if Prop.Visibility = mvPublished then
    begin
      var Field := TField.Create;
      Field.FDatabaseName := Prop.Name;
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

  inherited;
end;

{ TFieldAlias }

constructor TFieldAlias.Create(Field: TField; Alias: String);
begin
  FAlias := Alias;
  FField := Field;
end;

end.
