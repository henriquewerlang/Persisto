unit Delphi.ORM.Rtti.Helper;

interface

uses System.Rtti;

type
  TRttiTypeHelper = class helper for TRttiType
  public
    function GetAttribute<T: TCustomAttribute>: T;
  end;

implementation

{ TRttiTypeHelper }

function TRttiTypeHelper.GetAttribute<T>: T;
begin
  Result := nil;

  for var Attribute in GetAttributes do
    if Attribute is T then
      Exit(T(Attribute));
end;

end.
