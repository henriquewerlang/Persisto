unit Delphi.ORM.Obj.Helper;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections;

type
  TCreateFunction = reference to function (const Sorce: TObject): TObject;

  EDiffentObjectTypes = class(Exception)
  public
    constructor Create(const Source, Destiny: TClass);
  end;

  TObjectHelper = class
  private
    class function InternalCopy(const Context: TRttiContext; const Source, Destiny: TObject; const ProcessedObjects: TDictionary<TObject, TObject>; const CreateFunction: TCreateFunction): TObject;
  public
    class procedure Copy(const Source, Destiny: TObject); overload;
    class procedure Copy(const Source, Destiny: TObject; const CreateFunction: TCreateFunction); overload;
  end;

implementation

uses Delphi.ORM.Rtti.Helper;

{ TObjectHelper }

class procedure TObjectHelper.Copy(const Source, Destiny: TObject);
begin
  Copy(Source, Destiny,
    function (const Source: TObject): TObject
    begin
      Result := Source.ClassType.Create;
    end);
end;

class procedure TObjectHelper.Copy(const Source, Destiny: TObject; const CreateFunction: TCreateFunction);
begin
  if Source.ClassType = Destiny.ClassType then
  begin
    var Context := TRttiContext.Create;
    var ProcessedObjects := TDictionary<TObject, TObject>.Create;

    InternalCopy(Context, Source, Destiny, ProcessedObjects, CreateFunction);

    ProcessedObjects.Free;

    Context.Free;
  end
  else
    raise EDiffentObjectTypes.Create(Source.ClassType, Destiny.ClassType);
end;

class function TObjectHelper.InternalCopy(const Context: TRttiContext; const Source, Destiny: TObject; const ProcessedObjects: TDictionary<TObject, TObject>;
  const CreateFunction: TCreateFunction): TObject;
begin
  if not ProcessedObjects.TryGetValue(Source, Result) then
  begin
    if not Assigned(Result) then
      if Assigned(Destiny) then
        Result := Destiny
      else
        Result := CreateFunction(Source);

    ProcessedObjects.Add(Source, Result);

    for var Field in Context.GetType(Source.ClassType).GetFields do
    begin
      var FieldValue := Field.GetValue(Source);

      if not FieldValue.IsEmpty then
        if Field.FieldType.IsArray and Field.FieldType.AsArray.ElementType.IsInstance then
        begin
          var DestinyArray := Field.GetValue(Result);

          DestinyArray.ArrayLength := FieldValue.ArrayLength;

          for var A := 0 to Pred(FieldValue.ArrayLength) do
            DestinyArray.ArrayElement[A] := InternalCopy(Context, FieldValue.ArrayElement[A].AsObject, DestinyArray.ArrayElement[A].AsObject, ProcessedObjects, CreateFunction);

          FieldValue := DestinyArray;
        end
        else if Field.FieldType.IsInstance then
          FieldValue := InternalCopy(Context, FieldValue.AsObject, Field.GetValue(Result).AsObject, ProcessedObjects, CreateFunction);

      Field.SetValue(Result, FieldValue);
    end;
  end;
end;

{ EDiffentObjectTypes }

constructor EDiffentObjectTypes.Create(const Source, Destiny: TClass);
begin
  inherited CreateFmt('You can''t copy different types of objects, source: %s, destiny: %s!', [Source.QualifiedClassName, Destiny.QualifiedClassName]);
end;

end.

