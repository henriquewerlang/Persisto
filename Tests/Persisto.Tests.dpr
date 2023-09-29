program Persisto.Tests;

{$STRONGLINKTYPES ON}

uses
  FastMM5 in '..\Externals\FastMM5\FastMM5.pas',
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  DUnitX.MemoryLeakMonitor.FastMM5,
  Persisto.DataSet.Test in 'Persisto.DataSet.Test.pas',
  Persisto.DataSet in '..\Persisto.DataSet.pas',
  Persisto.Classes.Loader.Test in 'Persisto.Classes.Loader.Test.pas',
  Persisto.Mapper.Test in 'Persisto.Mapper.Test.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Nullable.Test in 'Persisto.Nullable.Test.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Database.Schema.Updater.Test in 'Persisto.Database.Schema.Updater.Test.pas',
  Persisto.Database.Manipulator.Test in 'Persisto.Database.Manipulator.Test.pas',
  Persisto.SQLServer in '..\Persisto.SQLServer.pas',
  Persisto.SQLServer.Test in 'Persisto.SQLServer.Test.pas',
  Persisto.Lazy.Manipulator.Test in 'Persisto.Lazy.Manipulator.Test.pas',
  Persisto.Nullable.Manipulator.Test in 'Persisto.Nullable.Manipulator.Test.pas',
  Persisto.SQLite in '..\Persisto.SQLite.pas',
  Persisto.SQLite.Test in 'Persisto.SQLite.Test.pas',
  Persisto.Connection.Firedac in '..\Persisto.Connection.Firedac.pas',
  Persisto.Mapping in '..\Persisto.Mapping.pas',
  Persisto in '..\Persisto.pas',
  Persisto.Manager.Test in 'Persisto.Manager.Test.pas',
  Persisto.SQLite.Firedac.Drive in '..\Persisto.SQLite.Firedac.Drive.pas',
  Persisto.SQLite.Firedac.Functions in '..\Persisto.SQLite.Firedac.Functions.pas',
  Persisto.Test.Connection in 'Persisto.Test.Connection.pas';

begin
  FastMM_EnterDebugMode;

  FastMM_OutputDebugStringEvents := [];
  FastMM_LogToFileEvents := [mmetUnexpectedMemoryLeakSummary, mmetUnexpectedMemoryLeakDetail];
  FastMM_MessageBoxEvents := [mmetDebugBlockDoubleFree, mmetVirtualMethodCallOnFreedObject];

  FastMM_DeleteEventLogFile;

  FormatSettings := TFormatSettings.Invariant;

  FastMM_BeginEraseFreedBlockContent;

  TestInsight.DUnitX.RunRegisteredTests;
end.

