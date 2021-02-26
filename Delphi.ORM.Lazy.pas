unit Delphi.ORM.Lazy;

interface

uses System.Rtti;

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
    destructor Destroy; override;

    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetValue: TValue;

    procedure SetLazyLoader(const Loader: ILazyLoader);
    procedure SetValue(const Value: TValue);

    property Loaded: Boolean read GetLoaded;
  end;

{$IFDEF PAS2JS}
  Lazy<T: class> = record
  private
    FAccess: TLazyAccess;

    function GetAccess: TLazyAccess;

    procedure SetValue(const Value: T);
  public
    function GetValue: T;

    property Access: TLazyAccess read GetAccess;
    property Value: T read GetValue write SetValue;
  end;

{$ELSE}
  ILazyAccessTyped<T> = interface(ILazyAccess)
    ['{BDF2E5FA-5ECE-47FA-9EE3-C70A29779112}']
    function GetTypedValue: T;

    procedure SetTypedValue(const Value: T);
  end;

  TLazyAccessTyped<T> = class(TLazyAccess, ILazyAccessTyped<T>)
  private
    function GetTypedValue: T;

    procedure SetTypedValue(const Value: T);
  end;

  Lazy<T: class> = record
  private
    FAccess: ILazyAccessTyped<T>;

    procedure SetValue(const Value: T);
  public
    function GetValue: T;

    class operator Initialize(out Dest: Lazy<T>);
    class operator Implicit(const Value: Lazy<T>): T;
    class operator Implicit(const Value: T): Lazy<T>;

    property Value: T read GetValue write SetValue;
  end;
{$ENDIF}

function GetLazyLoadingAccess(const Instance: TValue): {$IFDEF PAS2JS}TLazyAccess{$ELSE}ILazyAccess{$ENDIF};
function GetLazyLoadingRttiType(RttiType: TRttiType): TRttiType;
function IsLazyLoading(RttiType: TRttiType): Boolean;

implementation

uses System.SysUtils;

function GetLazyLoadingAccess(const Instance: TValue): {$IFDEF PAS2JS}TLazyAccess{$ELSE}ILazyAccess{$ENDIF};
var
  RttiType: TRttiType;

begin
  RttiType := TRttiContext.Create.GetType(Instance.TypeInfo);

{$IFDEF PAS2JS}
  Result := RttiType.GetProperty('Access').GetValue(Instance.AsJSValue).AsObject as TLazyAccess;
{$ELSE}
  Result := RttiType.GetField('FAccess').GetValue(Instance.GetReferenceToRawData).AsType<ILazyAccess>;
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

function Lazy<T>.GetValue: T;
begin
{$IFDEF PAS2JS}
  Result := Access.GetValue.AsType<T>;
{$ELSE}
  Result := FAccess.GetTypedValue;
{$ENDIF}
end;

procedure Lazy<T>.SetValue(const Value: T);
begin
{$IFDEF PAS2JS}
  Access.SetValue(TValue.From(Value));
{$ELSE}
  FAccess.SetTypedValue(Value);
{$ENDIF}
end;

{$IFDEF PAS2JS}
function Lazy<T>.GetAccess: TLazyAccess;
begin
  if not Assigned(FAccess) then
    FAccess := TLazyAccess.Create;

  Result := FAccess;
end;
{$ELSE}
class operator Lazy<T>.Initialize(out Dest: Lazy<T>);
begin
  Dest.FAccess := TLazyAccessTyped<T>.Create;
end;

class operator Lazy<T>.Implicit(const Value: T): Lazy<T>;
begin
  Result.Value := Value;
end;

class operator Lazy<T>.Implicit(const Value: Lazy<T>): T;
begin
  Result := Value.Value;
end;

{ TLazyAccessTyped<T> }

function TLazyAccessTyped<T>.GetTypedValue: T;
begin
  Result := GetValue.AsType<T>;
end;

procedure TLazyAccessTyped<T>.SetTypedValue(const Value: T);
begin
  SetValue(TValue.From<T>(Value));
end;
{$ENDIF}

{ TLazyAccess }

destructor TLazyAccess.Destroy;
var
  Obj: TObject;

begin
  Obj := FValue.AsObject;

  Obj.Free;

  inherited;
end;

function TLazyAccess.GetKey: TValue;
begin
  Result := FLoader.GetKey;
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

