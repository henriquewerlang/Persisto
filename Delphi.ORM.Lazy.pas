unit Delphi.ORM.Lazy;

interface

uses System.Rtti, System.TypInfo;

type
  ILazyLoader = interface
    ['{FADB37E1-82F4-41F4-8659-A54A3DD4EDFA}']
    function GetKey: TValue;
    function GetValue: TValue;
  end;

  ILazyAccess = interface
    ['{670D3E65-9747-4192-A4CE-CD612B5C16A2}']
    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetValue: TValue;

    procedure SetValue(const Value: TValue);
    procedure SetLazyLoader(const Loader: ILazyLoader);

    property Loaded: Boolean read GetLoaded;
  end;

  TLazyAccess = class(TInterfacedObject, ILazyAccess)
  private
    FLoaded: Boolean;
    FLoader: ILazyLoader;
    FValue: TValue;
  public
    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetValue: TValue;

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

uses System.SysUtils;

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
  if Assigned(FLoader) and not FLoaded then
    SetValue(FLoader.GetValue);

  Result := FValue;
end;

procedure TLazyAccess.SetLazyLoader(const Loader: ILazyLoader);
begin
  FLoader := Loader;
end;

procedure TLazyAccess.SetValue(const Value: TValue);
begin
  FLoaded := True;
  FValue := Value;
end;

end.

