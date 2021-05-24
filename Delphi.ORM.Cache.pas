unit Delphi.ORM.Cache;

interface

uses System.Rtti, System.Generics.Collections;

type
  ICache = interface
    function Get(RttiType: TRttiType; const PrimaryKey: TValue; var Value: TValue): Boolean;

    procedure Add(RttiType: TRttiType; const PrimaryKey, Value: TValue);
  end;

  TCache = class(TInterfacedObject, ICache)
  private
    FValues: TDictionary<String, TValue>;

    class var GFCache: ICache;

    function Get(RttiType: TRttiType; const PrimaryKey: TValue; var Value: TValue): Boolean;

    class function GetInstance: ICache; static;

    procedure Add(RttiType: TRttiType; const PrimaryKey, Value: TValue);
  public
    constructor Create;

    destructor Destroy; override;

    class function GenerateKey(RttiType: TRttiType; const PrimaryKey: TValue): String;

    class property Instance: ICache read GetInstance;

    property Values: TDictionary<String, TValue> read FValues write FValues;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Rtti.Helper;

{ TCache }

procedure TCache.Add(RttiType: TRttiType; const PrimaryKey, Value: TValue);
begin
  Values.Add(GenerateKey(RttiType, PrimaryKey), Value);
end;

constructor TCache.Create;
begin
  inherited;

  FValues := TDictionary<String, TValue>.Create;
end;

destructor TCache.Destroy;
begin
  FValues.Free;

  inherited;
end;

class function TCache.GenerateKey(RttiType: TRttiType; const PrimaryKey: TValue): String;
begin
  Result := Format('%s.%s', [RttiType.QualifiedName, PrimaryKey.GetAsString]);
end;

function TCache.Get(RttiType: TRttiType; const PrimaryKey: TValue; var Value: TValue): Boolean;
begin
  Result := Values.TryGetValue(GenerateKey(RttiType, PrimaryKey), Value);
end;

class function TCache.GetInstance: ICache;
begin
  if not Assigned(GFCache) then
    GFCache := TCache.Create;

  Result := GFCache;
end;

end.

