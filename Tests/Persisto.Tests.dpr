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
  Persisto.Connection in '..\Persisto.Connection.pas',
  Persisto.Query.Builder.Test in 'Persisto.Query.Builder.Test.pas',
  Persisto.Query.Builder in '..\Persisto.Query.Builder.pas',
  Persisto.Classes.Loader.Test in 'Persisto.Classes.Loader.Test.pas',
  Persisto.Classes.Loader in '..\Persisto.Classes.Loader.pas',
  Persisto.Attributes in '..\Persisto.Attributes.pas',
  Persisto.Mapper.Test in 'Persisto.Mapper.Test.pas',
  Persisto.Mapper in '..\Persisto.Mapper.pas',
  Persisto.Rtti.Helper in '..\Persisto.Rtti.Helper.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Cursor.Mock in 'Persisto.Cursor.Mock.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Nullable in '..\Persisto.Nullable.pas',
  Persisto.Nullable.Test in 'Persisto.Nullable.Test.pas',
  Persisto.Lazy in '..\Persisto.Lazy.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Cache in '..\Persisto.Cache.pas',
  Persisto.Cache.Test in 'Persisto.Cache.Test.pas',
  Persisto.Lazy.Factory.Test in 'Persisto.Lazy.Factory.Test.pas',
  Persisto.Lazy.Factory in '..\Persisto.Lazy.Factory.pas',
  Persisto.Database.Metadata in '..\Persisto.Database.Metadata.pas',
  Persisto.Database.Metadata.Test in 'Persisto.Database.Metadata.Test.pas',
  Persisto.Database.Metadata.Manipulator in '..\Persisto.Database.Metadata.Manipulator.pas',
  Persisto.Database.Metadata.Manipulator.Test in 'Persisto.Database.Metadata.Manipulator.Test.pas',
  Persisto.Database.Manipulator.SQLServer in '..\Persisto.Database.Manipulator.SQLServer.pas',
  Persisto.Database.Manipulator.SQLServer.Test in 'Persisto.Database.Manipulator.SQLServer.Test.pas',
  Persisto.Lazy.Manipulator in '..\Persisto.Lazy.Manipulator.pas',
  Persisto.Lazy.Manipulator.Test in 'Persisto.Lazy.Manipulator.Test.pas',
  Persisto.Nullable.Manipulator in '..\Persisto.Nullable.Manipulator.pas',
  Persisto.Nullable.Manipulator.Test in 'Persisto.Nullable.Manipulator.Test.pas',
  Persisto.Change.Manager in '..\Persisto.Change.Manager.pas',
  Persisto.Change.Manager.Test in 'Persisto.Change.Manager.Test.pas',
  Persisto.Database.Manipulator.SQLite in '..\Persisto.Database.Manipulator.SQLite.pas',
  Persisto.Database.Manipulator.SQLite.Test in 'Persisto.Database.Manipulator.SQLite.Test.pas',
  Persisto.Connection.Firedac in '..\Persisto.Connection.Firedac.pas';

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

