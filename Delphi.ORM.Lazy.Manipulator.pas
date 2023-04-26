unit Delphi.ORM.Lazy.Manipulator;

interface

uses System.Rtti, Delphi.ORM.Lazy;

type
  ILazyManipulator = interface
    function GetHasValue: Boolean;
    function GetKey: TValue;
    function GetLoaded: Boolean;
    function GetLoader: ILazyLoader;
    function GetRttiType: TRttiType;
    function GetValue: TValue;

    procedure SetLoaded(const Value: Boolean);
    procedure SetLoader(const Value: ILazyLoader);
    procedure SetValue(const Value: TValue);

    property HasValue: Boolean read GetHasValue;
    property Key: TValue read GetKey;
    property Loaded: Boolean read GetLoaded write SetLoaded;
    property Loader: ILazyLoader read GetLoader write SetLoader;
    property RttiType: TRttiType read GetRttiType;
    property Value: TValue read GetValue write SetValue;
  end;

  TLazyManipulator = class(TInterfacedObject, ILazyManipulator)
  private
    FLazyInstance: Pointer;
    FLazyType: TRttiType;

    function GetHasValue: Boolean;
    function GetKey: TValue;
    function GetLazyLoadedField: TRttiField;
    function GetLazyLoaderField: TRttiField;
    function GetLazyValueField: TRttiField;
    function GetLoaded: Boolean;
    function GetLoader: ILazyLoader;
    function GetRttiType: TRttiType;
    function GetValue: TValue;

    procedure SetLoaded(const Value: Boolean);
    procedure SetLoader(const Value: ILazyLoader);
    procedure SetValue(const Value: TValue);

    property LazyLoadedField: TRttiField read GetLazyLoadedField;
    property LazyLoaderField: TRttiField read GetLazyLoaderField;
    property LazyValueField: TRttiField read GetLazyValueField;
  public
    constructor Create(const LazyInstance: Pointer; const LazyType: TRttiType);

    class function GetManipulator(const ObjectInstance: TObject; const LazyProperty: TRttiProperty): ILazyManipulator; overload;
    class function GetManipulator(const LazyInstance: Pointer; const LazyType: TRttiType): ILazyManipulator; overload;
    class function GetManipulator<T>(const LazyInstance: T): ILazyManipulator; overload;
    class function GetLazyLoadingType(const LazyProperty: TRttiProperty): TRttiType; overload;
    class function GetLazyLoadingType(const LazyType: TRttiType): TRttiType; overload;
    class function IsLazyLoading(const LazyProperty: TRttiProperty): Boolean; overload;
    class function IsLazyLoading(const LazyType: TRttiType): Boolean; overload;
  end;

implementation

uses System.SysUtils, System.TypInfo, Delphi.ORM.Rtti.Helper{$IFDEF PAS2JS}, JS{$ENDIF};

const
  LAZY_NAME = 'Lazy<';

{ TLazyManipulator }

constructor TLazyManipulator.Create(const LazyInstance: Pointer; const LazyType: TRttiType);
begin
  inherited Create;

  FLazyInstance := LazyInstance;
  FLazyType := LazyType;
end;

function TLazyManipulator.GetHasValue: Boolean;
begin
  Result := FLazyType.GetMethod('GetHasValue').Invoke(TValue.From(FLazyInstance), []).AsBoolean;
end;

function TLazyManipulator.GetLazyLoadedField: TRttiField;
begin
  Result := FLazyType.GetField('FLoaded');
end;

function TLazyManipulator.GetLazyLoaderField: TRttiField;
begin
  Result := FLazyType.GetField('FLoader');
end;

class function TLazyManipulator.GetLazyLoadingType(const LazyType: TRttiType): TRttiType;
begin
  Result := LazyType.GetMethod('GetValue').ReturnType;
end;

function TLazyManipulator.GetLazyValueField: TRttiField;
begin
  Result := FLazyType.GetField('FValue');
end;

class function TLazyManipulator.GetLazyLoadingType(const LazyProperty: TRttiProperty): TRttiType;
begin
  Result := GetLazyLoadingType(LazyProperty.PropertyType);
end;

function TLazyManipulator.GetLoaded: Boolean;
begin
{$IFDEF DCC}
  Result := LazyLoadedField.GetValue(FLazyInstance).AsBoolean;
{$ELSE}
  Result := Boolean(TJSObject(FLazyInstance)['FLoaded']);
{$ENDIF}
end;

function TLazyManipulator.GetLoader: ILazyLoader;
begin
{$IFDEF DCC}
  Result := LazyLoaderField.GetValue(FLazyInstance).AsType<ILazyLoader>;
{$ELSE}
  Result := ILazyLoader(TJSObject(FLazyInstance)['FLoader']);
{$ENDIF}
end;

class function TLazyManipulator.GetManipulator(const ObjectInstance: TObject; const LazyProperty: TRttiProperty): ILazyManipulator;
begin
  Result := GetManipulator(TRttiInstanceProperty(LazyProperty).GetRawValue(ObjectInstance), LazyProperty.PropertyType)
end;

class function TLazyManipulator.GetManipulator(const LazyInstance: Pointer; const LazyType: TRttiType): ILazyManipulator;
begin
  Result := TLazyManipulator.Create(LazyInstance, LazyType);
end;

class function TLazyManipulator.GetManipulator<T>(const LazyInstance: T): ILazyManipulator;
begin
  Result := GetManipulator(@LazyInstance, Delphi.ORM.Rtti.Helper.GetRttiType(TypeInfo(T)));
end;

function TLazyManipulator.GetRttiType: TRttiType;
begin
  Result := GetLazyLoadingType(FLazyType);
end;

function TLazyManipulator.GetValue: TValue;
begin
{$IFDEF DCC}
  Result := PValue(PByte(FLazyInstance) + LazyValueField.Offset)^;
{$ELSE}
  Result := TValue(TJSObject(FLazyInstance)['FValue']);
{$ENDIF}
end;

function TLazyManipulator.GetKey: TValue;
var
  Loader: ILazyLoader;

begin
  Loader := GetLoader;

  if Assigned(Loader) then
    Result := Loader.GetKey
  else
    Result := TValue.Empty;
end;

class function TLazyManipulator.IsLazyLoading(const LazyType: TRttiType): Boolean;
begin
  Result := LazyType.Name.StartsWith(LAZY_NAME);
end;

class function TLazyManipulator.IsLazyLoading(const LazyProperty: TRttiProperty): Boolean;
begin
  Result := IsLazyLoading(LazyProperty.PropertyType);
end;

procedure TLazyManipulator.SetLoaded(const Value: Boolean);
begin
{$IFDEF DCC}
  LazyLoadedField.SetValue(FLazyInstance, TValue.From(Value));
{$ELSE}
  TJSObject(FLazyInstance)['FLoaded'] := Value;
{$ENDIF}
end;

procedure TLazyManipulator.SetLoader(const Value: ILazyLoader);
begin
  SetLoaded(False);

{$IFDEF DCC}
  LazyLoaderField.SetValue(FLazyInstance, TValue.From(Value));
{$ELSE}
  TJSObject(FLazyInstance)['FLoader'] := Value;
{$ENDIF}
end;

procedure TLazyManipulator.SetValue(const Value: TValue);
begin
  FLazyType.GetMethod('SetValue').Invoke(TValue.From(FLazyInstance), [Value]);
end;

end.

