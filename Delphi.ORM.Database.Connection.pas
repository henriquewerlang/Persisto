unit Delphi.ORM.Database.Connection;

interface

type
  IDatabaseCursor = interface
    ['{19CBD0F4-8766-4F1D-8E88-F7E03E6A5E28}']
    function GetFieldValue(const FieldIndex: Integer): Variant;
    function Next: Boolean;
  end;

  IDatabaseTransaction = interface
    ['{218FA473-10BD-406B-B01B-79AF603570FE}']
    procedure Commit;
    procedure Rollback;
  end;

  IDatabaseConnection = interface
    ['{7FF2A2F4-0440-447D-9E64-C61A92E94800}']
    function ExecuteInsert(const SQL: String; const OutputFields: TArray<String>): IDatabaseCursor;
    function OpenCursor(const SQL: String): IDatabaseCursor;
    function StartTransaction: IDatabaseTransaction;

    procedure ExecuteDirect(const SQL: String);
  end;

implementation

end.

