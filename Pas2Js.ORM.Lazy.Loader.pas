unit Pas2Js.ORM.Lazy.Loader;

interface

uses System.Rtti, Delphi.ORM.Lazy;

type
  TLazyLoadFunction = function(RttiType: TRttiType; const Key: TValue): TValue;

  TLazyLoader = class(TInterfacedObject, ILazyLoader)
  private
    FKey: TValue;
    FRttiType: TRttiType;

    function GetKey: TValue;
    function GetValue: TValue;
  public
    constructor Create(RttiType: TRttiType; const Key: TValue);
  end;

var
  GLazyLoadFunction: TLazyLoadFunction = nil;

implementation

uses System.SysUtils, Delphi.ORM.Cache;

{ TLazyLoader }

constructor TLazyLoader.Create(RttiType: TRttiType; const Key: TValue);
begin
  inherited Create;

  FKey := Key;
  FRttiType := RttiType;
end;

function TLazyLoader.GetKey: TValue;
begin
  Result := FKey;
end;

function TLazyLoader.GetValue: TValue;
begin
  if FKey.IsEmpty then
    Result := TValue.Empty
  else if not TCache.Instance.Get(FRttiType, FKey, Result) then
  begin
    if not Assigned(GLazyLoadFunction) then
      raise Exception.Create('You must load the GLazyLoadFunction variable to load the object!');

    Result := GLazyLoadFunction(FRttiType, FKey);

    TCache.Instance.Add(FRttiType, FKey, Result);
  end;
end;

end.

