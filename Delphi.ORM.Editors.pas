unit Delphi.ORM.Editors;

interface

uses DesignIntf, DesignEditors, System.Classes;

type
  TObjectClassNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;

    procedure GetValues(Proc: TGetStrProc); override;
  end;

implementation

uses System.Rtti, Delphi.ORM.Attributes;

{ TObjectClassNameProperty }

function TObjectClassNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TObjectClassNameProperty.GetValues(Proc: TGetStrProc);
begin
  var Context := TRttiContext.Create;

  for var &Type in Context.GetTypes do
    for var Attribute in &Type.GetAttributes do
      if Attribute is EntityAttribute then
        Proc(&Type.Name);
end;

end.
