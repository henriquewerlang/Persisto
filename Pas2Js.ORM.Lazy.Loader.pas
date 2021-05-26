unit Pas2Js.ORM.Lazy.Loader;

interface

uses System.Rtti, Delphi.ORM.Lazy;

type
  TLazyLoadFunction = function(RttiType: TRttiType; const Key: TValue): TValue;

  TLazyLoaderImpl = class(TLazyLoader)
  protected
    function LoadValue: TValue; override;
  end;

var
  GLazyLoadFunction: TLazyLoadFunction = nil;

implementation

uses System.SysUtils, Delphi.ORM.Cache;

{ TLazyLoaderImpl }

function TLazyLoaderImpl.LoadValue: TValue;
begin
  if Assigned(GLazyLoadFunction) then
  begin
    Result := GLazyLoadFunction(RttiType, Key);

    Cache.Add(RttiType, Key, Result);
  end
  else
    raise Exception.Create('You must load the GLazyLoadFunction variable to load the object!');
end;

end.

