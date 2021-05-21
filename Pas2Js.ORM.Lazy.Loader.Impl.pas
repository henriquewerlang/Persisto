unit Pas2Js.ORM.Lazy.Loader.Impl;

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

uses System.SysUtils;

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
  else
  begin
    if not Assigned(GLazyLoadFunction) then
      raise Exception.Create('You must load the GLazyLoadFunction variable to load the object!');

    Result := GLazyLoadFunction(FRttiType, FKey);
  end;
end;

end.
