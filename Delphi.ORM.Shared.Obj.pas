unit Delphi.ORM.Shared.Obj;

interface

type
  ISharedObject = interface
    ['{4A4D2FAF-04D0-4FCD-A493-0C9DC4381369}']
    function GetObject: TObject;

    property &Object: TObject read GetObject;
  end;

  IStateObject = interface(ISharedObject)
    ['{55D7B4C2-0700-4CE8-A6DC-CD31D98CF67E}']
    function GetOldObject: TObject;

    property OldObject: TObject read GetOldObject;
  end;

  TSharedObject = class(TInterfacedObject, ISharedObject)
  private
    FObject: TObject;

    function GetObject: TObject;
  public
    constructor Create(const Instance: TObject);

    destructor Destroy; override;

    property &Object: TObject read GetObject;
  end;

  TStateObject = class(TSharedObject, ISharedObject, IStateObject)
  private
    FOldObject: TObject;

    function GetOldObject: TObject;
  public
    constructor Create(const Instance: TObject; const CopyProperties: Boolean);

    destructor Destroy; override;
  end;

implementation

uses System.Rtti;

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

{ TStateObject }

constructor TStateObject.Create(const Instance: TObject; const CopyProperties: Boolean);
begin
  inherited Create(Instance);

{$IFDEF DCC}
  FOldObject := Instance.ClassType.Create;

  if CopyProperties then
  begin
    var ClassInfo := TRttiContext.Create.GetType(Instance.ClassType);

    for var AProperty in ClassInfo.GetProperties do
      AProperty.SetValue(FOldObject, AProperty.GetValue(Instance));
  end;
{$ENDIF}
end;

destructor TStateObject.Destroy;
begin
  FOldObject.Free;

  inherited;
end;

function TStateObject.GetOldObject: TObject;
begin
  Result := FOldObject;
end;

end.

