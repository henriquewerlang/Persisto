unit Delphi.ORM.Lazy.Loader.Pas2Js;

interface

uses System.Rtti, Delphi.ORM.Lazy;

type
  TLazyLoadFunction = function(const TypeName: String; const Key: TValue): TValue;

  TLazyLoader = class(TInterfacedObject, ILazyLoader)
  private
    FKey: TValue;
    FTypeName: String;

    function GetKey: TValue;
    function GetValue: TValue;
  public
    constructor Create(const TypeName: String; const Key: TValue);
  end;

var
  GLazyLoadFunction: TLazyLoadFunction = nil;

implementation

uses System.SysUtils;

{ TLazyLoader }

constructor TLazyLoader.Create(const TypeName: String; const Key: TValue);
begin
  inherited Create;

  FKey := Key;
  FTypeName := TypeName;
end;

function TLazyLoader.GetKey: TValue;
begin
  Result := FKey;
end;

function TLazyLoader.GetValue: TValue;
begin
  if not Assigned(GLazyLoadFunction) then
    raise Exception.Create('You must load the GLazyLoadFunction variable to load the object!');

  Result := GLazyLoadFunction(FTypeName, FKey);
end;

end.
