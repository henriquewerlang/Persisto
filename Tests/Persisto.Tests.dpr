program Persisto.Tests;

{$STRONGLINKTYPES ON}

uses
  FastMM5 in '..\Externals\FastMM5\FastMM5.pas',
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  DUnitX.MemoryLeakMonitor.FastMM5,
  {$IF DEFINED(POSTGRESQL)}
  Persisto.PostgreSQL.Test in 'Persisto.PostgreSQL.Test.pas',
  {$ELSEIF}
  Persisto.SQLServer.Test in 'Persisto.SQLServer.Test.pas',
  {$ELSE}
  Persisto.SQLite.Test in 'Persisto.SQLite.Test.pas',
  {$ENDIF }
  Persisto.DataSet.Test in 'Persisto.DataSet.Test.pas',
  Persisto.Classes.Loader.Test in 'Persisto.Classes.Loader.Test.pas',
  Persisto.Mapper.Test in 'Persisto.Mapper.Test.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Nullable.Test in 'Persisto.Nullable.Test.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Database.Schema.Updater.Test in 'Persisto.Database.Schema.Updater.Test.pas',
  Persisto.Nullable.Manipulator.Test in 'Persisto.Nullable.Manipulator.Test.pas',
  Persisto.Manager.Test in 'Persisto.Manager.Test.pas',
  Persisto.Test.Connection in 'Persisto.Test.Connection.pas';

begin
  FastMM_EnterDebugMode;

  FastMM_OutputDebugStringEvents := [];
  FastMM_LogToFileEvents := [mmetUnexpectedMemoryLeakSummary, mmetUnexpectedMemoryLeakDetail];
  FastMM_MessageBoxEvents := [mmetDebugBlockDoubleFree, mmetVirtualMethodCallOnFreedObject];

  FastMM_DeleteEventLogFile;

  FastMM_BeginEraseFreedBlockContent;

  TestInsight.DUnitX.RunRegisteredTests;
end.

