unit Delphi.ORM.Lazy;

interface

uses System.Rtti, System.TypInfo, System.SysUtils{$IFDEF PAS2JS}, JS, Web{$ENDIF};

type
  ILazyLoader = {$IFDEF DCC}interface{$ELSE}class
  public
{$ENDIF}
    function GetKey: TValue;{$IFDEF PAS2JS} virtual; abstract;{$ENDIF}
    function LoadValue: TValue;{$IFDEF PAS2JS} virtual; abstract;{$ENDIF}
{$IFDEF PAS2JS}
    function LoadValueAsync: TValue; virtual; abstract; async;
{$ENDIF}
  end;

  Lazy<T> = record
  private
    FLoaded: Boolean;
    FLoader: ILazyLoader;
    FValue: TValue;

    function NeedLoadValue: Boolean;

    procedure SetTValue(const Value: TValue);
  public
    function GetHasValue: Boolean;
    function GetValue: T;
{$IFDEF PAS2JS}
    function GetValueAsync: T; async;
{$ENDIF}

    procedure SetValue(const Value: T);

{$IFDEF DCC}
    class operator Implicit(const Value: Lazy<T>): T;
    class operator Implicit(const Value: T): Lazy<T>;
{$ENDIF}

    property HasValue: Boolean read GetHasValue;
    property Loaded: Boolean read FLoaded;
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
  if NeedLoadValue then
    SetTValue(FLoader.LoadValue);

  Result := FValue.AsType<T>;
end;

{$IFDEF PAS2JS}
function Lazy<T>.GetValueAsync: T;
begin
  if NeedLoadValue then
    SetTValue(await(FLoader.LoadValueAsync));

  Result := FValue.AsType<T>;
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

function Lazy<T>.NeedLoadValue: Boolean;
begin
  Result := not FLoaded and Assigned(FLoader);

  if not FLoaded and not Assigned(FLoader) then
    SetTValue(TValue.Empty);
end;

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

