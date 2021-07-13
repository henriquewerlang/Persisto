unit Delphi.ORM.Lazy;

interface

uses System.Rtti, System.TypInfo, System.SysUtils, Delphi.ORM.Cache{$IFDEF PAS2JS}, JS, Web{$ENDIF};

type
  ELazyFactoryNotLoaded = class(Exception)
  public
    constructor Create;
  end;

  ILazyLoader = interface
    ['{FADB37E1-82F4-41F4-8659-A54A3DD4EDFA}']
    function GetKey: TValue;
    function GetValue: TValue;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}
  end;

  ILazyAccess = interface
    ['{670D3E65-9747-4192-A4CE-CD612B5C16A2}']
    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetValue: TValue;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}

    procedure SetValue(const Value: TValue);
    procedure SetLazyLoader(const Loader: ILazyLoader);

    property Loaded: Boolean read GetLoaded;
  end;

  ILazyFactory = interface
    ['{62C671EE-2C9E-4753-BD86-924EA20B904F}']
    function Load(const RttiType: TRttiType; const Key: TValue): TValue;
{$IFDEF PAS2JS}
    function LoadAsync(const RttiType: TRttiType; const Key: TValue): TValue; async;
{$ENDIF}
  end;

  TLazyLoader = class(TInterfacedObject, ILazyLoader)
  private
    FKey: TValue;
    FCache: ICache;
    FRttiType: TRttiType;
    FFactory: ILazyFactory;

    class var FGlobalFactory: ILazyFactory;

    function CheckValue(var Value: TValue): Boolean;
    function GetFactory: ILazyFactory;
    function GetKey: TValue;
    function GetValue: TValue;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}
  public
    constructor Create(const RttiType: TRttiType; const Key: TValue);

    property Cache: ICache read FCache write FCache;
    property Factory: ILazyFactory read GetFactory write FFactory;
    property Key: TValue read GetKey;
    property RttiType: TRttiType read FRttiType;

    class property GlobalFactory: ILazyFactory read FGlobalFactory write FGlobalFactory;
  end;

  TLazyAccess = class(TInterfacedObject, ILazyAccess)
  private
    FLoaded: Boolean;
    FLoader: ILazyLoader;
    FValue: TValue;
  public
    function CanLoadValue: Boolean;
    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetValue: TValue;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}
    function FlagAsLoaded: Boolean;

    procedure SetLazyLoader(const Loader: ILazyLoader);
    procedure SetValue(const Value: TValue);

    property Loaded: Boolean read GetLoaded;
  end;

  TLazyAccessType = {$IFDEF PAS2JS}TLazyAccess{$ELSE}ILazyAccess{$ENDIF};

  Lazy<T: class> = record
  private
    FAccess: TLazyAccessType;

    procedure SetValue(const Value: T);
  public
    function GetAccess: TLazyAccessType;
    function GetValue: T;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}

{$IFDEF DCC}
    class operator Initialize(out Dest: Lazy<T>);
    class operator Implicit(const Value: Lazy<T>): T;
    class operator Implicit(const Value: T): Lazy<T>;
{$ENDIF}

    property Access: TLazyAccessType read GetAccess;
    property Value: T read GetValue write SetValue;
  end;

function GetLazyLoadingAccess(const Instance: TValue): TLazyAccessType;
function GetLazyLoadingRttiType(RttiType: TRttiType): TRttiType;
function IsLazyLoading(RttiType: TRttiType): Boolean;

implementation

function GetLazyLoadingAccess(const Instance: TValue): TLazyAccessType;
var
  RttiType: TRttiType;

begin
  RttiType := TRttiContext.Create.GetType(Instance.TypeInfo);

{$IFDEF PAS2JS}
  Result := RttiType.GetProperty('Access').GetValue(Instance.AsJSValue).AsType<TLazyAccessType>;
{$ELSE}
  Result := RttiType.GetMethod('GetAccess').Invoke(Instance, []).AsType<TLazyAccessType>;
{$ENDIF}
end;

function GetLazyLoadingRttiType(RttiType: TRttiType): TRttiType;
begin
  Result := RttiType.GetMethod('GetValue').ReturnType;
end;

function IsLazyLoading(RttiType: TRttiType): Boolean;
begin
  Result := RttiType.Name.StartsWith('Lazy<');
end;

{ Lazy<T> }

function Lazy<T>.GetAccess: TLazyAccessType;
begin
  if not Assigned(FAccess) then
    FAccess := TLazyAccess.Create;

  Result := FAccess;
end;

function Lazy<T>.GetValue: T;
begin
  Result := GetAccess.GetValue.AsType<T>;
end;

{$IFDEF PAS2JS}
function Lazy<T>.GetValueAsync: TValue;
begin
  Result := await(GetAccess.GetValueAsync);
end;
{$ENDIF}

procedure Lazy<T>.SetValue(const Value: T);
begin
  GetAccess.SetValue(TValue.From<T>(Value));
end;

{$IFDEF DCC}
class operator Lazy<T>.Initialize(out Dest: Lazy<T>);
begin
  Dest.GetAccess;
end;

class operator Lazy<T>.Implicit(const Value: T): Lazy<T>;
begin
  Result.Value := Value;
end;

class operator Lazy<T>.Implicit(const Value: Lazy<T>): T;
begin
  Result := Value.Value;
end;
{$ENDIF}

{ TLazyAccess }

function TLazyAccess.CanLoadValue: Boolean;
begin
  Result := not FLoaded and Assigned(FLoader);
end;

function TLazyAccess.FlagAsLoaded: Boolean;
begin
  Result := CanLoadValue;

  FLoaded := not Result;
end;

function TLazyAccess.GetKey: TValue;
begin
  if Assigned(FLoader) then
    Result := FLoader.GetKey
  else
    Result := TValue.Empty;
end;

function TLazyAccess.GetLoaded: Boolean;
begin
  Result := FLoaded;
end;

function TLazyAccess.GetValue: TValue;
begin
  if FlagAsLoaded then
    SetValue(FLoader.GetValue);

  Result := FValue;
end;

{$IFDEF PAS2JS}
function TLazyAccess.GetValueAsync: TValue;
begin
  if FlagAsLoaded then
    SetValue(await(FLoader.GetValueAsync));

  Result := FValue;
end;
{$ENDIF}

procedure TLazyAccess.SetLazyLoader(const Loader: ILazyLoader);
begin
  FLoader := Loader;
end;

procedure TLazyAccess.SetValue(const Value: TValue);
begin
  FLoaded := True;
  FValue := Value;
end;

{ TLazyLoader }

function TLazyLoader.CheckValue(var Value: TValue): Boolean;
begin
  Result := True;

  if FKey.IsEmpty then
    Value := TValue.Empty
  else if not Cache.Get(FRttiType, FKey, Value) then
    Result := False;
end;

constructor TLazyLoader.Create(const RttiType: TRttiType; const Key: TValue);
begin
  inherited Create;

  FCache := TCache.Instance;
  FKey := Key;
  FRttiType := RttiType;
end;

function TLazyLoader.GetFactory: ILazyFactory;
begin
  if not Assigned(FFactory) then
    if Assigned(GlobalFactory) then
      FFactory := GlobalFactory
    else
      raise ELazyFactoryNotLoaded.Create;

  Result := FFactory;
end;

function TLazyLoader.GetKey: TValue;
begin
  Result := FKey;
end;

function TLazyLoader.GetValue: TValue;
begin
  if not CheckValue(Result) then
    Result := Factory.Load(FRttiType, FKey);
end;

{$IFDEF PAS2JS}
function TLazyLoader.GetValueAsync: TValue;
begin
  if not CheckValue(Result) then
    Result := await(Factory.LoadAsync(FRttiType, FKey));
end;
{$ENDIF}

{ ELazyFactoryNotLoaded }

constructor ELazyFactoryNotLoaded.Create;
begin
  inherited Create('To use the lazy loading, you must load the global factory, the class variable "GlobalFactory"!');
end;

end.

