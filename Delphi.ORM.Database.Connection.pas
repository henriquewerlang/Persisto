unit Delphi.ORM.Database.Connection;

interface

uses System.Rtti;

type
  IDatabaseCursor = interface
    ['{19CBD0F4-8766-4F1D-8E88-F7E03E6A5E28}']
    function GetFieldValue(const FieldName: String): TValue;
  end;

  IDatabaseConnection = interface
    ['{7FF2A2F4-0440-447D-9E64-C61A92E94800}']
    function OpenCursor(SQL: String): IDatabaseCursor;
  end;

implementation

end.
