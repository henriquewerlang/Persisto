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
  Persisto.Rtti.Helper in '..\Persisto.Rtti.Helper.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Cursor.Mock in 'Persisto.Cursor.Mock.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Nullable.Test in 'Persisto.Nullable.Test.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Cache.Test in 'Persisto.Cache.Test.pas',
  Persisto.Lazy.Factory.Test in 'Persisto.Lazy.Factory.Test.pas',
  Persisto.Database.Metadata.Test in 'Persisto.Database.Metadata.Test.pas',
  Persisto.Database.Metadata.Manipulator.Test in 'Persisto.Database.Metadata.Manipulator.Test.pas',
  Persisto.SQLServer in '..\Persisto.SQLServer.pas',
  Persisto.Database.Manipulator.SQLServer.Test in 'Persisto.Database.Manipulator.SQLServer.Test.pas',
  Persisto.Lazy.Manipulator.Test in 'Persisto.Lazy.Manipulator.Test.pas',
  Persisto.Nullable.Manipulator.Test in 'Persisto.Nullable.Manipulator.Test.pas',
  Persisto.Change.Manager.Test in 'Persisto.Change.Manager.Test.pas',
  Persisto.SQLite in '..\Persisto.SQLite.pas',
  Persisto.Database.Manipulator.SQLite.Test in 'Persisto.Database.Manipulator.SQLite.Test.pas',
  Persisto.Connection.Firedac in '..\Persisto.Connection.Firedac.pas',
  Persisto.Mapping in '..\Persisto.Mapping.pas',
  Persisto in '..\Persisto.pas';

begin
  FastMM_EnterDebugMode;

  FastMM_OutputDebugStringEvents := [];
  FastMM_LogToFileEvents := [mmetUnexpectedMemoryLeakSummary, mmetUnexpectedMemoryLeakDetail];
  FastMM_MessageBoxEvents := [mmetDebugBlockDoubleFree, mmetVirtualMethodCallOnFreedObject];

  FastMM_DeleteEventLogFile;

  FormatSettings := TFormatSettings.Invariant;

  FastMM_BeginEraseFreedBlockContent;

  try
    TMapper.Default.LoadAll;
  except
  end;

  TestInsight.DUnitX.RunRegisteredTests;
end.

