unit Delphi.ORM.Nullable.Manipulator;

interface

uses System.Rtti;

type
  INullableManipulator = interface
    ['{495AE37A-7DDE-467B-8453-EB234DEB7D10}']
    function GetRttiType: TRttiType;
    function GetValue: TValue;
    function IsNull: Boolean;

    procedure SetValue(const Value: TValue);

    property RttiType: TRttiType read GetRttiType;
    property Value: TValue read GetValue write SetValue;
  end;

  TNullableManipulator = class(TInterfacedObject, INullableManipulator)
  private
    FNullableInstance: TValue;
    FNullableType: TRttiType;

    function GetRttiType: TRttiType;
    function GetValue: TValue;
    function IsNull: Boolean;

    procedure SetValue(const Value: TValue);
  public
    constructor Create(const NullableInstance: Pointer; const NullableType: TRttiType);

    class function GetManipulator(const ObjectInstance: TObject; const NullableProperty: TRttiProperty): INullableManipulator; overload;
    class function GetManipulator(const Instance: Pointer; const NullableType: TRttiType): INullableManipulator; overload;
    class function GetNullableType(const NullableProperty: TRttiProperty): TRttiType; overload;
    class function GetNullableType(const NullableType: TRttiType): TRttiType; overload;
    class function IsNullable(const NullableProperty: TRttiProperty): Boolean; overload;
    class function IsNullable(const NullableType: TRttiType): Boolean; overload;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Rtti.Helper;

const
  NULLABLE_TYPE_NAME = 'Nullable<';

{ TNullableManipulator }

constructor TNullableManipulator.Create(const NullableInstance: Pointer; const NullableType: TRttiType);
begin
  inherited Create;

  FNullableInstance := TValue.From(NullableInstance);
  FNullableType := NullableType;
end;

class function TNullableManipulator.GetManipulator(const ObjectInstance: TObject; const NullableProperty: TRttiProperty): INullableManipulator;
begin
  Result := GetManipulator(TRttiInstanceProperty(NullableProperty).GetRawValue(ObjectInstance), NullableProperty.PropertyType);
end;

class function TNullableManipulator.GetManipulator(const Instance: Pointer; const NullableType: TRttiType): INullableManipulator;
begin
  Result := TNullableManipulator.Create(Instance, NullableType);
end;

class function TNullableManipulator.GetNullableType(const NullableType: TRttiType): TRttiType;
begin
  Result := NullableType.GetMethod('GetValue').ReturnType;
end;

class function TNullableManipulator.GetNullableType(const NullableProperty: TRttiProperty): TRttiType;
begin
  Result := GetNullableType(NullableProperty.PropertyType);
end;

function TNullableManipulator.GetRttiType: TRttiType;
begin
  Result := GetNullableType(FNullableType);
end;

function TNullableManipulator.GetValue: TValue;
begin
  if IsNull then
    Result := TValue.Empty
  else
    Result := FNullableType.GetMethod('GetValue').Invoke(FNullableInstance, []);
end;

function TNullableManipulator.IsNull: Boolean;
begin
  Result := FNullableType.GetMethod('IsNull').Invoke(FNullableInstance, []).AsBoolean;
end;

class function TNullableManipulator.IsNullable(const NullableType: TRttiType): Boolean;
begin
  Result := NullableType.Name.StartsWith(NULLABLE_TYPE_NAME);
end;

class function TNullableManipulator.IsNullable(const NullableProperty: TRttiProperty): Boolean;
begin
  Result := IsNullable(NullableProperty.PropertyType);
end;

procedure TNullableManipulator.SetValue(const Value: TValue);
begin
  if Value.IsEmpty then
    FNullableType.GetMethod('Clear').Invoke(FNullableInstance, [])
  else
    FNullableType.GetMethod('SetValue').Invoke(FNullableInstance, [Value])
end;

end.

