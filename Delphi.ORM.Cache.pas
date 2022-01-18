unit Delphi.ORM.Cache;

interface

uses System.Generics.Collections;

type
  ISharedObject = interface
    function GetObject: TObject;

    property &Object: TObject read GetObject;
  end;

  ICache = interface
    ['{E910CEFC-7423-4307-B805-0B313BF46735}']
    function Add(const Key: String; const Value: TObject): ISharedObject; overload;
    function Get(const Key: String; var Value: ISharedObject): Boolean;

    procedure Add(const Key: String; const Value: ISharedObject); overload;
  end;

  TCache = class(TInterfacedObject, ICache)
  private
    FValues: TDictionary<String, ISharedObject>;

    function Add(const Key: String; const Value: TObject): ISharedObject; overload;
    function Get(const Key: String; var Value: ISharedObject): Boolean;

    procedure Add(const Key: String; const Value: ISharedObject); overload;
  public
    constructor Create;

    destructor Destroy; override;
  end;

implementation

type
  TSharedObject = class(TInterfacedObject, ISharedObject)
  private
    FObject: TObject;

    function GetObject: TObject;
  public
    constructor Create(const Instance: TObject);

    destructor Destroy; override;
  end;

{ TCache }

function TCache.Add(const Key: String; const Value: TObject): ISharedObject;
begin
  Result := TSharedObject.Create(Value);

  Add(Key, Result);
end;

procedure TCache.Add(const Key: String; const Value: ISharedObject);
begin
  FValues.Add(Key, Value);
end;

constructor TCache.Create;
begin
  inherited;

  FValues := TObjectDictionary<String, ISharedObject>.Create;
end;

destructor TCache.Destroy;
begin
  FValues.Free;

  inherited;
end;

function TCache.Get(const Key: String; var Value: ISharedObject): Boolean;
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

