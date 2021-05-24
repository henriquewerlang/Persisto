unit Delphi.ORM.Rtti.Helper;

interface

uses System.SysUtils, System.Rtti;

type
  TRttiTypeHelper = class helper for TRttiObject
  public
    function AsArray: TRttiDynamicArrayType;
    function GetAttribute<T: TCustomAttribute>: T;
    function IsArray: Boolean;
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

implementation

uses System.TypInfo, {$IFDEF PAS2JS}RTLConsts{$ELSE}System.SysConst{$ENDIF};

{ TRttiTypeHelper }

function TRttiTypeHelper.AsArray: TRttiDynamicArrayType;
begin
  Result := Self as TRttiDynamicArrayType;
end;

function TRttiTypeHelper.GetAttribute<T>: T;
var
  Attribute: TCustomAttribute;

begin
  Result := nil;

  for Attribute in GetAttributes do
    if Attribute is T then
      Exit(T(Attribute));
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

initialization
  TValue.GFFormatSettings := TFormatSettings.Invariant;
  TValue.GFFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  TValue.GFFormatSettings.LongTimeFormat := 'hh":"mm":"ss';

end.

