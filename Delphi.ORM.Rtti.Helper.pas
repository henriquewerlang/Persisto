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
    procedure SetArrayLength(const Size: Integer);
  public
    property ArrayElement[Index: Integer]: TValue read GetArrayElementInternal write SetArrayElementInternal;
    property ArrayLength: Integer read GetArrayLengthInternal write SetArrayLength;
  end;

implementation

uses System.SysUtils, System.SysConst, System.TypInfo;

{ TRttiTypeHelper }

function TRttiTypeHelper.AsArray: TRttiDynamicArrayType;
begin
  Result := Self as TRttiDynamicArrayType;
end;

function TRttiTypeHelper.GetAttribute<T>: T;
begin
  Result := nil;

  for var Attribute in GetAttributes do
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

procedure TValueHelper.SetArrayLength(const Size: Integer);
begin
  if TypeInfo^.Kind <> tkDynArray then
    raise EInvalidCast.CreateRes(@SInvalidCast);

  DynArraySetLength(PPointer(GetReferenceToRawData)^, TypeInfo, 1, @Size);
end;

end.
