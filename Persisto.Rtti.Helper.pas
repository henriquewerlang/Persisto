unit Persisto.Rtti.Helper;

interface

uses System.SysUtils, System.Rtti, System.TypInfo;

type
  {$IFDEF PAS2JS}
  Variant = JSValue;
  {$ENDIF}

  TRttiTypeHelper = class helper for TRttiObject
  public
    function AsArray: TRttiDynamicArrayType;
    function IsArray: Boolean;
  end;

  TRttiPropertyHelper = class helper for TRttiInstanceProperty
  public
    function GetRawValue(Instance: Pointer): Pointer;
  end;

  TValueHelper = record helper for TValue
  private
    class var GFFormatSettings: TFormatSettings;

    function GetArrayElementInternal(Index: Integer): TValue; inline;
    function GetArrayLengthInternal: Integer; inline;

    procedure SetArrayElementInternal(Index: Integer; const Value: TValue); inline;
    procedure SetArrayLengthInternal(const Size: Integer); inline;
  public
    function GetAsString: String;

    property ArrayElement[Index: Integer]: TValue read GetArrayElementInternal write SetArrayElementInternal;
    property ArrayLength: Integer read GetArrayLengthInternal write SetArrayLengthInternal;

    class property FormatSettings: TFormatSettings read GFFormatSettings;
  end;

function GetRttiType(const AClass: TClass): TRttiType; overload;
function GetRttiType(const TypeInfo: PTypeInfo): TRttiType; overload;

implementation

uses {$IFDEF PAS2JS}RTLConsts, JS{$ELSE}System.Variants, System.SysConst{$ENDIF};

function GetRttiType(const AClass: TClass): TRttiType;
begin
  Result := GetRttiType(AClass.ClassInfo);
end;

function GetRttiType(const TypeInfo: PTypeInfo): TRttiType;
var
  Context: TRttiContext;

begin
  Context := TRttiContext.Create;

  Result := Context.GetType(TypeInfo);

  Context.Free;
end;

{ TRttiTypeHelper }

function TRttiTypeHelper.AsArray: TRttiDynamicArrayType;
begin
  Result := Self as TRttiDynamicArrayType;
end;

function TRttiTypeHelper.IsArray: Boolean;
begin
  Result := Self is TRttiDynamicArrayType;
end;

{ TValueHelper }

function TValueHelper.GetArrayElementInternal(Index: Integer): TValue;
begin
  Result := GetArrayElement(Index);
end;

function TValueHelper.GetArrayLengthInternal: Integer;
begin
  Result := GetArrayLength;
end;

function TValueHelper.GetAsString: String;
begin
  if IsEmpty then
    Exit(EmptyStr);

  case Kind of
{$IFDEF DCC}
    tkWChar,
    tkLString,
    tkWString,
    tkUString,
{$ENDIF}
    tkChar,
    tkString:
      Result := Self.ToString;

{$IFDEF DCC}
    tkInt64,
{$ENDIF}
    tkInteger:
      Result := Self.ToString;

    tkEnumeration: Result := AsOrdinal.ToString;

    tkFloat:
    begin
      if TypeInfo = System.TypeInfo(TDate) then
        Result := DateToStr(AsExtended, FormatSettings)
      else if TypeInfo = System.TypeInfo(TTime) then
        Result := TimeToStr(AsExtended, FormatSettings)
      else if TypeInfo = System.TypeInfo(TDateTime) then
        Result := DateTimeToStr(AsExtended, FormatSettings)
      else
        Result := FloatToStr(AsExtended, FormatSettings);
    end;

    tkRecord: Result := AsType<TGUID>.ToString;
  end;
end;

procedure TValueHelper.SetArrayElementInternal(Index: Integer; const Value: TValue);
begin
  SetArrayElement(Index, Value);
end;

procedure TValueHelper.SetArrayLengthInternal(const Size: Integer);
begin
  if TypeInfo{$IFDEF DCC}^{$ENDIF}.Kind <> tkDynArray then
    raise EInvalidCast.{$IFDEF PAS2JS}Create(SErrInvalidTypecast){$ELSE}CreateRes(@SInvalidCast){$ENDIF};

{$IFDEF PAS2JS}
  SetArrayLength(Size);
{$ELSE}
  var NativeSize: NativeInt := Size;

  DynArraySetLength(PPointer(GetReferenceToRawData)^, TypeInfo, 1, @NativeSize);
{$ENDIF}
end;

{ TRttiPropertyHelper }

function TRttiPropertyHelper.GetRawValue(Instance: Pointer): Pointer;
{$IFDEF DCC}
type
  PIntPtr = ^IntPtr;

var
  getter: Pointer;
  code: Pointer;
  args: TArray<TValue>;
{$ENDIF}
begin
{$IFDEF DCC}
  getter := PropInfo^.GetProc;
  if (IntPtr(getter) and PROPSLOT_MASK) = PROPSLOT_FIELD then
    // Field
    Exit(PByte(Instance) + (IntPtr(getter) and (not PROPSLOT_MASK)));

  if (IntPtr(getter) and PROPSLOT_MASK) = PROPSLOT_VIRTUAL then
  begin
    // Virtual dispatch, but with offset, not slot
    code := PPointer(PIntPtr(Instance)^ + SmallInt(IntPtr(getter)))^;
  end
  else
  begin
    // Static dispatch
    code := getter;
  end;

//  CheckCodeAddress(code);

  if Index = Integer($80000000) then
  begin
    // no index
    SetLength(args, 1);
    args[0] := TObject(Instance);
    Result := Invoke(code, args, ccReg, PropertyType.Handle, False).AsType<Pointer>; // not static
  end
  else
  begin
    SetLength(args, 2);
    args[0] := TObject(Instance);
    args[1] := Index;
    Result := Invoke(code, args, ccReg, PropertyType.Handle, False).AsType<Pointer>; // not static
  end;
{$ELSE}
  Result := Pointer(TJSObject(Instance)[PropertyTypeInfo.Getter]);
{$ENDIF}
end;

initialization
  TValue.GFFormatSettings := TFormatSettings.Invariant;
  TValue.GFFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  TValue.GFFormatSettings.LongDateFormat := 'yyyy-mm-dd"T"hh":"mm":"ss.zzz';
  TValue.GFFormatSettings.LongTimeFormat := 'hh":"mm":"ss';

end.

