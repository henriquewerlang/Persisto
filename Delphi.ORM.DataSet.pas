unit Delphi.ORM.DataSet;

interface

uses System.Classes, Data.DB, System.Rtti, System.Generics.Collections;

type
  TORMObjectField = class(TField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TORMDataSet = class(TDataSet)
  private
    FInternalList: TList<TObject>;
    FObjectList: TList<TObject>;
    FPropertyMappingList: TList<TRttiInstanceProperty>;
    FRecordIndex: Integer;

    function GetInternalList: TList<TObject>;

    procedure LoadFieldDefsFromClass<T: class>;

    property InternalList: TList<TObject> read GetInternalList;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; override;
    function GetNextRecord: Boolean; override;
    function GetPriorRecord: Boolean; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function IsCursorOpen: Boolean; override;

    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    function GetCurrentObject<T: class>: T;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;

    procedure OpenList<T: class>(List: TList<T>);
    procedure OpenObject<T: class>(&Object: T);
  end;

implementation

uses System.TypInfo, System.Variants;

{ TORMDataSet }

function TORMDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := TRecordBuffer(1);
end;

constructor TORMDataSet.Create(AOwner: TComponent);
begin
  inherited;

  FPropertyMappingList := TList<TRttiInstanceProperty>.Create;
end;

destructor TORMDataSet.Destroy;
begin
  FPropertyMappingList.Free;

  FInternalList.Free;

  inherited;
end;

procedure TORMDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  Buffer := nil;
end;

function TORMDataSet.GetCurrentObject<T>: T;
begin
  Result := FObjectList[FRecordIndex] as T;
end;

function TORMDataSet.GetFieldClass(FieldDef: TFieldDef): TFieldClass;
begin
  if FieldDef.DataType = ftObject then
    Result := TORMObjectField
  else
    Result := inherited GetFieldClass(FieldDef);
end;

function TORMDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  if Field is TStringField then
  begin
    var StringData := FPropertyMappingList[Pred(Field.FieldNo)].GetValue(GetCurrentObject<TObject>).AsType<AnsiString>;
    var StringSize := Length(StringData);

    Move(PAnsiChar(@StringData[1])^, PAnsiChar(@Buffer[0])^, StringSize);

    Buffer[StringSize] := 0;
  end
  else
    FPropertyMappingList[Pred(Field.FieldNo)].GetValue(GetCurrentObject<TObject>).ExtractRawData(@Buffer[0]);

  Result := True;
end;

function TORMDataSet.GetInternalList: TList<TObject>;
begin
  if not Assigned(FInternalList) then
    FInternalList := TList<TObject>.Create;

  Result := FInternalList;
end;

function TORMDataSet.GetNextRecord: Boolean;
begin
  Inc(FRecordIndex);

  Result := inherited GetNextRecord;
end;

function TORMDataSet.GetPriorRecord: Boolean;
begin
  Dec(FRecordIndex);

  Result := inherited GetPriorRecord;
end;

function TORMDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  if FRecordIndex < 0 then
    Result := grBOF
  else if FRecordIndex < RecordCount then
    Result := grOK
  else
    Result := grEOF;
end;

function TORMDataSet.GetRecordCount: Integer;
begin
  Result := FObjectList.Count;
end;

procedure TORMDataSet.InternalClose;
begin
  inherited;

end;

procedure TORMDataSet.InternalHandleException;
begin
  inherited;

end;

procedure TORMDataSet.InternalInitFieldDefs;
begin
  inherited;

end;

procedure TORMDataSet.InternalLast;
begin
  FRecordIndex := FObjectList.Count;
end;

procedure TORMDataSet.InternalOpen;
begin
  FRecordIndex := -1;

  CreateFields;

  BindFields(True);
end;

function TORMDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FObjectList) and (FObjectList.Count > 0);
end;

procedure TORMDataSet.LoadFieldDefsFromClass<T>;
begin
  var Context := TRttiContext.Create;

  FPropertyMappingList.Clear;

  for var &Property in Context.GetType(T).GetProperties do
    if &Property.Visibility = mvPublished then
    begin
      var FieldType := ftUnknown;

      case &Property.PropertyType.TypeKind of
        tkChar,
        tkString,
        tkLString,
        tkUString,
        tkWChar: FieldType := ftString;
        tkClass: FieldType := ftObject;
        tkEnumeration:
          if &Property.PropertyType.Handle = TypeInfo(Boolean) then
            FieldType := ftBoolean;
        tkFloat:
          if &Property.PropertyType.Handle = TypeInfo(TDate) then
            FieldType := ftDate
          else if &Property.PropertyType.Handle = TypeInfo(TDateTime) then
            FieldType := ftDateTime
          else if &Property.PropertyType.Handle = TypeInfo(TTime) then
            FieldType := ftTime
          else
            case TRttiInstanceProperty(&Property).PropInfo.PropType^.TypeData.FloatType of
              ftSingle: FieldType := TFieldType.ftSingle;
              ftDouble: FieldType := ftFloat;
              ftExtended: FieldType := TFieldType.ftExtended;
              ftCurr: FieldType := ftCurrency;
            end;
        tkInteger:
          case &Property.PropertyType.AsOrdinal.OrdType of
            otSByte,
            otUByte: FieldType := ftByte;
            otSWord: FieldType := ftInteger;
            otUWord: FieldType := ftWord;
            otSLong: FieldType := ftInteger;
            otULong: FieldType := ftLongWord;
          end;
        tkInt64: FieldType := ftLargeint;
        tkWString: FieldType := ftWideString;
      end;

      FieldDefs.Add(&Property.Name, FieldType);

      FPropertyMappingList.Add(&Property as TRttiInstanceProperty);
    end;
end;

procedure TORMDataSet.OpenList<T>(List: TList<T>);
begin
  FObjectList := TList<TObject>(List);

  LoadFieldDefsFromClass<T>;

  Open;
end;

procedure TORMDataSet.OpenObject<T>(&Object: T);
begin
  FObjectList := InternalList;

  InternalList.Add(&Object);

  OpenList<T>(TList<T>(InternalList));
end;

procedure TORMDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin

end;

{ TORMObjectField }

constructor TORMObjectField.Create(AOwner: TComponent);
begin
  inherited;

  SetDataType(ftObject);
end;

end.

