unit Delphi.ORM.Lazy;

interface

uses System.Rtti, System.TypInfo{$IFDEF PAS2JS}, JS, Web{$ENDIF};

type
  ILazyLoader = {$IFDEF DCC}interface{$ELSE}class
  public
{$ENDIF}
    function GetKey: TValue;{$IFDEF PAS2JS} virtual; abstract;{$ENDIF}
    function LoadValue: TValue;{$IFDEF PAS2JS} virtual; abstract;{$ENDIF}
  end;

  Lazy<T> = record
  private
    FLoaded: Boolean;
    FLoader: ILazyLoader;
    FValue: TValue;

    procedure SetTValue(const Value: TValue);
  public
    function GetHasValue: Boolean;
    function GetValue: T;
{$IFDEF PAS2JS}
    function GetValueAsync: TJSPromise;
{$ENDIF}

    procedure SetValue(const Value: T);

{$IFDEF DCC}
    class operator Implicit(const Value: Lazy<T>): T;
    class operator Implicit(const Value: T): Lazy<T>;
{$ENDIF}

    property HasValue: Boolean read GetHasValue;
    property Value: T read GetValue write SetValue;
  end;

implementation

{ Lazy<T> }

function Lazy<T>.GetHasValue: Boolean;
begin
  Result := not FValue.IsEmpty or Assigned(FLoader);
end;

function Lazy<T>.GetValue: T;
begin
  if not FLoaded then
    if Assigned(FLoader) then
      SetTValue(FLoader.LoadValue)
    else
      SetTValue(TValue.Empty);

  Result := FValue.AsType<T>;
end;

{$IFDEF PAS2JS}
function Lazy<T>.GetValueAsync: TJSPromise;
begin
  Result := TJSPromise.New(procedure (Resolve, Reject: TJSPromiseResolver)
    begin
      Resolve(GetValue);
    end);
end;
{$ENDIF}

{$IFDEF DCC}
class operator Lazy<T>.Implicit(const Value: T): Lazy<T>;
begin
  Result.Value := Value;
end;

class operator Lazy<T>.Implicit(const Value: Lazy<T>): T;
begin
  Result := Value.Value;
end;
{$ENDIF}

procedure Lazy<T>.SetTValue(const Value: TValue);
begin
  FLoaded := True;
  FLoader := nil;
  FValue := Value;
end;

procedure Lazy<T>.SetValue(const Value: T);
begin
  SetTValue(TValue.From<T>(Value));
end;

end.

