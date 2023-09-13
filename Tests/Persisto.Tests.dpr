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
  Persisto.Query.Builder.Test in 'Persisto.Query.Builder.Test.pas',
  Persisto.Classes.Loader.Test in 'Persisto.Classes.Loader.Test.pas',
  Persisto.Mapper.Test in 'Persisto.Mapper.Test.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Cursor.Mock in 'Persisto.Cursor.Mock.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Nullable.Test in 'Persisto.Nullable.Test.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Lazy.Factory.Test in 'Persisto.Lazy.Factory.Test.pas',
  Persisto.Database.Metadata.Test in 'Persisto.Database.Metadata.Test.pas',
  Persisto.Database.Metadata.Manipulator.Test in 'Persisto.Database.Metadata.Manipulator.Test.pas',
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
  Persisto.Database.Dialect.Test in 'Persisto.Database.Dialect.Test.pas',
  Persisto.SQLite.Firedac.Drive in 'Persisto.SQLite.Firedac.Drive.pas',
  Persisto.SQLite.Firedac.Functions in 'Persisto.SQLite.Firedac.Functions.pas';

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

