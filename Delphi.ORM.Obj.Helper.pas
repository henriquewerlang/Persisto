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
    class function Copy(const Source: TObject): TObject; overload;
    class function Copy(const Source: TObject; const CreateFunction: TCreateFunction): TObject; overload;

    class procedure Copy(const Source, Destiny: TObject); overload;
    class procedure Copy(const Source, Destiny: TObject; const CreateFunction: TCreateFunction); overload;
  end;

implementation

uses System.TypInfo, System.SysConst, Delphi.ORM.Rtti.Helper;

function ObjectCreateFunction(const Source: TObject): TObject;
begin
  Result := Source.ClassType.Create;
end;

{ TObjectHelper }

class procedure TObjectHelper.Copy(const Source, Destiny: TObject);
begin
  Copy(Source, Destiny, ObjectCreateFunction);
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

class function TObjectHelper.Copy(const Source: TObject): TObject;
begin
  Result := Copy(Source, ObjectCreateFunction);
end;

class function TObjectHelper.Copy(const Source: TObject; const CreateFunction: TCreateFunction): TObject;
begin
  Result := CreateFunction(Source);

  Copy(Source, Result, CreateFunction);
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
      var DestinyFieldValue := Field.GetValue(Result);
      var SourceFieldValue := Field.GetValue(Source);

      if not SourceFieldValue.IsEmpty then
        if Field.FieldType.IsArray and Field.FieldType.AsArray.ElementType.IsInstance then
        begin
          DestinyFieldValue.ArrayLength := SourceFieldValue.ArrayLength;

          for var A := 0 to Pred(SourceFieldValue.ArrayLength) do
            DestinyFieldValue.ArrayElement[A] := InternalCopy(Context, SourceFieldValue.ArrayElement[A].AsObject, DestinyFieldValue.ArrayElement[A].AsObject, ProcessedObjects,
              CreateFunction);

          SourceFieldValue := DestinyFieldValue;
        end
        else if Field.FieldType.IsInstance then
          SourceFieldValue := InternalCopy(Context, SourceFieldValue.AsObject, DestinyFieldValue.AsObject, ProcessedObjects, CreateFunction);

      Field.SetValue(Result, SourceFieldValue);
    end;
  end;
end;

{ EDiffentObjectTypes }

constructor EDiffentObjectTypes.Create(const Source, Destiny: TClass);
begin
  inherited CreateFmt('You can''t copy different types of objects, source: %s, destiny: %s!', [Source.QualifiedClassName, Destiny.QualifiedClassName]);
end;

end.

