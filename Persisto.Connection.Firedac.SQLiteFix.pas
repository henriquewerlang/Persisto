unit Persisto.Connection.Firedac.SQLiteFix;

interface

uses FireDAC.Phys.SQLiteWrapper;

type
  TSQLiteLibDynEx = class(TSQLiteLibDyn)
  protected
    procedure LoadEntries; override;
  end;

implementation

{ TSQLiteLibDynEx }

procedure TSQLiteLibDynEx.LoadEntries;
begin
  inherited;

  @Fsqlite3_column_database_name := nil;
  @Fsqlite3_column_table_name := nil;
  @Fsqlite3_column_origin_name := nil;
  @Fsqlite3_table_column_metadata := nil;
end;

initialization
  TSQLiteLib.GLibClasses[slDefault] := TSQLiteLibDynEx;

end.
