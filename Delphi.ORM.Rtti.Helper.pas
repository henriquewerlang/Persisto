unit Delphi.ORM.Rtti.Helper;

interface

uses System.Rtti;

type
  TRttiTypeHelper = class helper for TRttiObject
  public
    function AsArray: TRttiDynamicArrayType;
    function GetAttribute<T: TCustomAttribute>: T;
    function IsArray: Boolean;
  end;

  TValueHelper = record helper for TValue
  private
    function GetArrayElementInternal(Index: Integer): TValue; inline;
    function GetArrayLengthInternal: Integer; inline;

    procedure SetArrayElementInternal(Index: Integer; const Value: TValue); inline;
    procedure SetArrayLengthInternal(const Size: Integer); inline;
  public
    property ArrayElement[Index: Integer]: TValue read GetArrayElementInternal write SetArrayElementInternal;
    property ArrayLength: Integer read GetArrayLengthInternal write SetArrayLengthInternal;
  end;

implementation

uses System.SysUtils, System.TypInfo, {$IFDEF PAS2JS}RTLConsts{$ELSE}System.SysConst{$ENDIF};

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

end.
