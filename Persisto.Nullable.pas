unit Persisto.Nullable;

interface

uses System.Rtti;

type
  TNullEnumerator = (NULL);

  Nullable<T> = record
  private
    FLoaded: Boolean;
    FValue: TValue;
  public
    function GetValue: T;
    function IsNull: Boolean;

    procedure Clear;
    procedure SetValue(const Value: T);

{$IFDEF DCC}
    class operator Implicit(const Value: Nullable<T>): T; overload;
    class operator Implicit(const Value: T): Nullable<T>; overload;
    class operator Implicit(const Value: TNullEnumerator): Nullable<T>; overload;
{$ENDIF}

    property Value: T read GetValue write SetValue;
  end;

implementation

{ Nullable<T> }

{$IFDEF DCC}
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
  FLoaded := False;
end;

function Nullable<T>.GetValue: T;
begin
  Result := FValue.AsType<T>;
end;

function Nullable<T>.IsNull: Boolean;
begin
  Result := not FLoaded;
end;

procedure Nullable<T>.SetValue(const Value: T);
begin
  FLoaded := True;

  TValue.Make<T>(Value, FValue);
end;

end.

