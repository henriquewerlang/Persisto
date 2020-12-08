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

implementation

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

end.
