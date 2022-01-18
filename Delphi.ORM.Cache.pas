unit Delphi.ORM.Cache;

interface

uses System.Rtti, System.Generics.Collections;

type
  ISharedObject = interface
    function GetObject: TObject;

    property &Object: TObject read GetObject;
  end;

  TSharedObject = class(TInterfacedObject, ISharedObject)
  private
    FObject: TObject;

    function GetObject: TObject;
  public
    constructor Create(const Instance: TObject);

    destructor Destroy; override;
  end;

  TSharedObjectType = {$IFDEF PAS2JS}TSharedObject{$ELSE}ISharedObject{$ENDIF};

  ICache = interface
    ['{E910CEFC-7423-4307-B805-0B313BF46735}']
    function Add(const Key: String; const Value: TObject): TSharedObjectType; overload;
    function Get(const Key: String; var Value: TSharedObjectType): Boolean;

    procedure Add(const Key: String; const Value: TSharedObjectType); overload;
  end;

  TCache = class(TInterfacedObject, ICache)
  private
    FValues: TDictionary<String, TSharedObjectType>;

    function Add(const Key: String; const Value: TObject): TSharedObjectType; overload;
    function Get(const Key: String; var Value: TSharedObjectType): Boolean;

    procedure Add(const Key: String; const Value: TSharedObjectType); overload;
  public
    constructor Create;

    destructor Destroy; override;

    class function GenerateKey(RttiType: TRttiType; const KeyValue: TValue): String;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Rtti.Helper;

{ TCache }

function TCache.Add(const Key: String; const Value: TObject): TSharedObjectType;
begin
  Result := TSharedObject.Create(Value);

  Add(Key, Result);
end;

procedure TCache.Add(const Key: String; const Value: TSharedObjectType);
begin
  FValues.Add(Key, Value);
end;

constructor TCache.Create;
begin
  inherited;

  FValues := TObjectDictionary<String, TSharedObjectType>.Create;
end;

destructor TCache.Destroy;
begin
  FValues.Free;

  inherited;
end;

class function TCache.GenerateKey(RttiType: TRttiType; const KeyValue: TValue): String;
begin
  Result := Format('%s.%s', [RttiType.QualifiedName, KeyValue.GetAsString]);
end;

function TCache.Get(const Key: String; var Value: TSharedObjectType): Boolean;
begin
  Result := FValues.TryGetValue(Key, Value);
end;

{ TSharedObject }

constructor TSharedObject.Create(const Instance: TObject);
begin
  inherited Create;

  FObject := Instance;
end;

destructor TSharedObject.Destroy;
begin
  FObject.Free;

  inherited;
end;

function TSharedObject.GetObject: TObject;
begin
  Result := FObject;
end;

end.

