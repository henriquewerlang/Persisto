unit Delphi.ORM.Nullable;

interface

uses System.Rtti, System.TypInfo;

type
  TNullEnumerator = (NULL);

{$IFDEF PAS2JS}
  Nullable<T> = record
  private
    FValue: JSValue;
  public
    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);

    property Value: T read GetValue write SetValue;
  end;
{$ElSE}
  INullableValue<T> = interface
    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);

    property Value: T read GetValue write SetValue;
  end;

  TNullableValue<T> = class(TInterfacedObject, INullableValue<T>)
  private
    FIsLoaded: Boolean;
    FValue: T;

    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);
  end;

  Nullable<T> = record
  private
    FValue: INullableValue<T>;
  public
    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);

    class operator Initialize(out Dest: Nullable<T>);
    class operator Implicit(const Value: T): Nullable<T>; overload;
    class operator Implicit(const Value: TNullEnumerator): Nullable<T>; overload;

    property Value: T read GetValue write SetValue;
  end;
{$ENDIF}

{$IFDEF PAS2JS}
function GetNullableTypeInfo(RttiType: TRttiType): PTypeInfo;
function GetNullableValue(RttiType: TRttiType; const Instance: TValue): TValue;
function IsNullableType(RttiType: TRttiType): Boolean;

procedure SetNullableValue(RttiType: TRttiType; const Instance: TValue; const NullableValue: JSValue);
{$ELSE}
function GetNullableTypeInfo(RttiType: TRttiType): PTypeInfo;
function GetNullableValue(RttiType: TRttiType; const Instance: TValue): TValue;
function IsNullableType(RttiType: TRttiType): Boolean;

procedure SetNullableValue(RttiType: TRttiType; const Instance, NullableValue: TValue);
{$ENDIF}

implementation

uses System.SysUtils{$IFDEF PAS2JS}, Pas2JS.JS{$ENDIF};

function GetNullableTypeInfo(RttiType: TRttiType): PTypeInfo;
begin
  Result := RttiType.GetMethod('GetValue').ReturnType.Handle;
end;

{$IFDEF PAS2JS}
function GetNullableValue(RttiType: TRttiType; const Instance: TValue): TValue;
begin
  if TJSFunction(TJSObject(Instance.AsJSValue)['IsNull']).apply(TJSObject(Instance.AsJSValue), nil) then
    Result := TValue.Empty
  else
    Result := TValue.FromJSValue(TJSFunction(TJSObject(Instance.AsJSValue)['GetValue']).apply(TJSObject(Instance.AsJSValue), nil));
end;

function IsNullableType(RttiType: TRttiType): Boolean;
begin
  Result := RttiType.Name.StartsWith('Nullable<');
end;

procedure SetNullableValue(RttiType: TRttiType; const Instance: TValue; const NullableValue: JSValue);
begin
  if NullableValue = NULL then
    TJSFunction(TJSObject(Instance.AsJSValue)['Clear']).apply(TJSObject(Instance.AsJSValue), nil)
  else
    TJSFunction(TJSObject(Instance.AsJSValue)['SetValue']).apply(TJSObject(Instance.AsJSValue), [NullableValue]);
end;

{ Nullable<T> }

procedure Nullable<T>.Clear;
begin
  FValue := NULL;
end;

function Nullable<T>.GetValue: T;
begin
  Result := T(FValue);
end;

function Nullable<T>.IsNull: Boolean;
begin
  Result := Pas2JS.JS.isNull(FValue) or isUndefined(FValue);
end;

procedure Nullable<T>.SetValue(const Value: T);
begin
  FValue := Value;
end;

{$ELSE}
function GetNullableValue(RttiType: TRttiType; const Instance: TValue): TValue;
begin
  if RttiType.GetMethod('IsNull').Invoke(Instance, []).AsBoolean then
    Result := TValue.Empty
  else
    Result := RttiType.GetMethod('GetValue').Invoke(Instance, []);
end;

function IsNullableType(RttiType: TRttiType): Boolean;
begin
  Result := RttiType.QualifiedName.StartsWith('Delphi.ORM.Nullable.Nullable<');
end;

procedure SetNullableValue(RttiType: TRttiType; const Instance, NullableValue: TValue);
begin
  if NullableValue.IsEmpty then
    RttiType.GetMethod('Clear').Invoke(Instance, [])
  else
    RttiType.GetMethod('SetValue').Invoke(Instance, [NullableValue]);
end;

{ Nullable<T> }

class operator Nullable<T>.Initialize(out Dest: Nullable<T>);
begin
  Dest.FValue := TNullableValue<T>.Create;
end;

class operator Nullable<T>.Implicit(const Value: T): Nullable<T>;
begin
  Result.Value := Value;
end;

procedure Nullable<T>.Clear;
begin
  FValue.Clear;
end;

function Nullable<T>.GetValue: T;
begin
  Result := FValue.Value;
end;

class operator Nullable<T>.Implicit(const Value: TNullEnumerator): Nullable<T>;
begin
  Result.Clear;
end;

function Nullable<T>.IsNull: Boolean;
begin
  Result := FValue.IsNull;
end;

procedure Nullable<T>.SetValue(const Value: T);
begin
  FValue.Value := Value;
end;

{ TNullableValue<T> }

procedure TNullableValue<T>.Clear;
begin
  FIsLoaded := False;
end;

function TNullableValue<T>.GetValue: T;
begin
  Result := FValue;
end;

function TNullableValue<T>.IsNull: Boolean;
begin
  Result := not FIsLoaded;
end;

procedure TNullableValue<T>.SetValue(const Value: T);
begin
  FIsLoaded := True;
  FValue := Value;
end;
{$ENDIF}

end.

