unit Delphi.ORM.Lazy;

interface

uses System.Rtti, System.TypInfo, System.SysUtils{$IFDEF PAS2JS}, JS, Web{$ENDIF};

type
  ELazyFactoryNotLoaded = class(Exception)
  public
    constructor Create;
  end;

  ILazyAccess = interface
    ['{670D3E65-9747-4192-A4CE-CD612B5C16A2}']
    function GetHasKey: Boolean;
    function GetHasValue: Boolean;
    function GetKey: TValue;
    function GetRttiType: TRttiType;
    function GetValue: TValue;
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}

    procedure SetKey(const Value: TValue);
    procedure SetValue(const Value: TValue);

    property HasKey: Boolean read GetHasKey;
    property HasValue: Boolean read GetHasValue;
    property Key: TValue read GetKey write SetKey;
    property RttiType: TRttiType read GetRttiType;
    property Value: TValue read GetValue write SetValue;
  end;

  ILazyFactory = interface
    ['{62C671EE-2C9E-4753-BD86-924EA20B904F}']
    function Load(const RttiType: TRttiType; const Key: TValue): TValue;
  end;

  TLazyAccess = class(TInterfacedObject, ILazyAccess)
  private
    FFactory: ILazyFactory;
    FHasValue: Boolean;
    FKey: TValue;
    FRttiType: TRttiType;
    FValue: TValue;

    class var FGlobalFactory: ILazyFactory;

    function GetFactory: ILazyFactory;
    function GetHasKey: Boolean;
    function GetHasValue: Boolean;
    function GetKey: TValue; inline;
    function GetRttiType: TRttiType;
    function GetValue: TValue;

    procedure LoadValue;
    procedure SetKey(const Value: TValue); inline;
    procedure SetValue(const Value: TValue); inline;
  public
    constructor Create(const RttiType: TRttiType);
{$IFDEF PAS2JS}
    function GetValueAsync: TValue; async;
{$ENDIF}

    property Factory: ILazyFactory read GetFactory write FFactory;
    property HasKey: Boolean read GetHasKey;
    property HasValue: Boolean read GetHasValue;
    property Key: TValue read GetKey write SetKey;
    property RttiType: TRttiType read GetRttiType;
    property Value: TValue read GetValue write SetValue;

    class property GlobalFactory: ILazyFactory read FGlobalFactory write FGlobalFactory;
  end;

  TLazyAccessType = {$IFDEF PAS2JS}TLazyAccess{$ELSE}ILazyAccess{$ENDIF};

  Lazy<T: class> = record
  private
    FAccess: TLazyAccessType;

    function GetHasKey: Boolean;
    function GetKey: TValue;

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

    property Access: TLazyAccessType read GetAccess write FAccess;
    property HasKey: Boolean read GetHasKey;
    property Key: TValue read GetKey;
    property Value: T read GetValue write SetValue;
  end;

function GetLazyLoadingAccess(const Instance: TValue): TLazyAccessType;
function GetLazyLoadingRttiType(RttiType: TRttiType): TRttiType;
function IsLazyLoading(RttiType: TRttiType): Boolean;

implementation

uses Delphi.ORM.Rtti.Helper;

function GetLazyLoadingAccess(const Instance: TValue): TLazyAccessType;
var
  RttiType: TRttiType;

begin
  RttiType := GetRttiType(Instance.TypeInfo);

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
    FAccess := TLazyAccess.Create(GetRttiType(TypeInfo(T)));

  Result := FAccess;
end;

function Lazy<T>.GetHasKey: Boolean;
begin
  Result := Access.HasKey or Access.HasValue;
end;

function Lazy<T>.GetKey: TValue;
begin
  Result := Access.Key;
end;

function Lazy<T>.GetValue: T;
begin
  Result := Access.Value.AsType<T>;
end;

{$IFDEF PAS2JS}
function Lazy<T>.GetValueAsync: TValue;
begin
  Result := await(Access.GetValueAsync);
end;
{$ENDIF}

procedure Lazy<T>.SetValue(const Value: T);
begin
  Access.Value := TValue.From<T>(Value);
end;

{$IFDEF DCC}
class operator Lazy<T>.Initialize(out Dest: Lazy<T>);
begin
  Dest.Access;
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

constructor TLazyAccess.Create(const RttiType: TRttiType);
begin
  inherited Create;

  FKey := TValue.Empty;
  FRttiType := RttiType;
end;

function TLazyAccess.GetFactory: ILazyFactory;
begin
  if not Assigned(FFactory) then
    if Assigned(GlobalFactory) then
      FFactory := GlobalFactory
    else
      raise ELazyFactoryNotLoaded.Create;

  Result := FFactory;
end;

function TLazyAccess.GetHasKey: Boolean;
begin
  Result := not FKey.IsEmpty;
end;

function TLazyAccess.GetHasValue: Boolean;
begin
  Result := FHasValue;
end;

function TLazyAccess.GetKey: TValue;
begin
  Result := FKey;
end;

function TLazyAccess.GetRttiType: TRttiType;
begin
  Result := FRttiType;
end;

function TLazyAccess.GetValue: TValue;
begin
  if not HasValue then
    LoadValue;

  Result := FValue;
end;

{$IFDEF PAS2JS}
function TLazyAccess.GetValueAsync: TValue;
begin
  LoadValue;

  Result := FValue;
end;
{$ENDIF}

procedure TLazyAccess.LoadValue;
begin
  FHasValue := True;

  if HasKey then
    FValue := Factory.Load(FRttiType, FKey)
  else
    TValue.Make(nil, RttiType.Handle, FValue);
end;

procedure TLazyAccess.SetKey(const Value: TValue);
begin
  FKey := Value;
end;

procedure TLazyAccess.SetValue(const Value: TValue);
begin
  FHasValue := True;
  FValue := Value;
end;

{ ELazyFactoryNotLoaded }

constructor ELazyFactoryNotLoaded.Create;
begin
  inherited Create('To use the lazy loading, you must load the global factory, the class variable "GlobalFactory"!');
end;

end.

