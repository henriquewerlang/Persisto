unit Delphi.ORM.Nullable;

interface

uses System.Rtti, System.TypInfo;

type
  TNullEnumerator = (NULL);

  INullableAccess = interface
    ['{B8A61E24-B4A1-400E-A1F9-293C14E30CA4}']
    function GetValue: TValue;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: TValue);
  end;

  TNullableAccess = class(TInterfacedObject, INullableAccess)
  private
    FValue: TValue;
  public
    function GetValue: TValue;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: TValue);
  end;

  TNullableAccessType = {$IFDEF PAS2JS}TNullableAccess{$ELSE}INullableAccess{$ENDIF};

  Nullable<T> = record
  private
    FAccess: TNullableAccessType;
  public
    function GetAccess: TNullableAccessType;
    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);

{$IFDEF DCC}
    class operator Initialize(out Dest: Nullable<T>);
    class operator Implicit(const Value: Nullable<T>): T; overload;
    class operator Implicit(const Value: T): Nullable<T>; overload;
    class operator Implicit(const Value: TNullEnumerator): Nullable<T>; overload;
{$ENDIF}

    property Access: TNullableAccessType read GetAccess;
    property Value: T read GetValue write SetValue;
  end;

function GetNullableAccess(const Instance: TValue): TNullableAccessType;
function GetNullableRttiType(RttiType: TRttiType): TRttiType;
function IsNullableType(RttiType: TRttiType): Boolean;

implementation

uses System.SysUtils;

function GetNullableAccess(const Instance: TValue): TNullableAccessType;
var
  RttiType: TRttiType;

begin
  RttiType := TRttiContext.Create.GetType(Instance.TypeInfo);

{$IFDEF PAS2JS}
  Result := RttiType.GetProperty('Access').GetValue(Instance.AsJSValue).AsType<TNullableAccessType>;
{$ELSE}
  Result := RttiType.GetMethod('GetAccess').Invoke(Instance, []).AsType<TNullableAccessType>;
{$ENDIF}
end;

function GetNullableRttiType(RttiType: TRttiType): TRttiType;
begin
  Result := RttiType.GetMethod('GetValue').ReturnType;
end;

function IsNullableType(RttiType: TRttiType): Boolean;
begin
  Result := RttiType.Name.StartsWith('Nullable<');
end;

{ Nullable<T> }

{$IFDEF DCC}
class operator Nullable<T>.Initialize(out Dest: Nullable<T>);
begin
  Dest.GetAccess;
end;

class operator Nullable<T>.Implicit(const Value: Nullable<T>): T;
begin
  Result := Value.Value;
end;

class operator Nullable<T>.Implicit(const Value: T): Nullable<T>;
begin
  Result.Value := Value;
end;

class operator Nullable<T>.Implicit(const Value: TNullEnumerator): Nullable<T>;
begin
  Result.Clear;
end;
{$ENDIF}

procedure Nullable<T>.Clear;
begin
  FAccess.Clear;
end;

function Nullable<T>.GetAccess: TNullableAccessType;
begin
  if not Assigned(FAccess) then
    FAccess := TNullableAccess.Create;

  Result := FAccess;
end;

function Nullable<T>.GetValue: T;
begin
  Result := FAccess.GetValue.AsType<T>;
end;

function Nullable<T>.IsNull: Boolean;
begin
  Result := FAccess.IsNull;
end;

procedure Nullable<T>.SetValue(const Value: T);
begin
  FAccess.SetValue(TValue.From<T>(Value));
end;

{ TNullableAccess }

procedure TNullableAccess.Clear;
begin
  FValue := TValue.Empty;
end;

function TNullableAccess.GetValue: TValue;
begin
  Result := FValue;
end;

function TNullableAccess.IsNull: Boolean;
begin
  Result := FValue.IsEmpty;
end;

procedure TNullableAccess.SetValue(const Value: TValue);
begin
  FValue := Value;
end;

end.

