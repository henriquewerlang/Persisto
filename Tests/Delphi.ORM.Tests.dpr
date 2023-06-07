program Delphi.ORM.Tests;

{$STRONGLINKTYPES ON}

uses
  FastMM5 in '..\Externals\FastMM5\FastMM5.pas',
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  DUnitX.MemoryLeakMonitor.FastMM5,
  Delphi.ORM.DataSet.Test in 'Delphi.ORM.DataSet.Test.pas',
  Delphi.ORM.DataSet in '..\Delphi.ORM.DataSet.pas',
  Delphi.ORM.Database.Connection in '..\Delphi.ORM.Database.Connection.pas',
  Delphi.ORM.Query.Builder.Test in 'Delphi.ORM.Query.Builder.Test.pas',
  Delphi.ORM.Query.Builder in '..\Delphi.ORM.Query.Builder.pas',
  Delphi.ORM.Classes.Loader.Test in 'Delphi.ORM.Classes.Loader.Test.pas',
  Delphi.ORM.Classes.Loader in '..\Delphi.ORM.Classes.Loader.pas',
  Delphi.ORM.Attributes in '..\Delphi.ORM.Attributes.pas',
  Delphi.ORM.Mapper.Test in 'Delphi.ORM.Mapper.Test.pas',
  Delphi.ORM.Mapper in '..\Delphi.ORM.Mapper.pas',
  Delphi.ORM.Rtti.Helper in '..\Delphi.ORM.Rtti.Helper.pas',
  Delphi.ORM.Test.Entity in 'Delphi.ORM.Test.Entity.pas',
  Delphi.ORM.Cursor.Mock in 'Delphi.ORM.Cursor.Mock.pas',
  Delphi.ORM.Rtti.Helper.Test in 'Delphi.ORM.Rtti.Helper.Test.pas',
  Delphi.ORM.Nullable in '..\Delphi.ORM.Nullable.pas',
  Delphi.ORM.Nullable.Test in 'Delphi.ORM.Nullable.Test.pas',
  Delphi.ORM.Lazy in '..\Delphi.ORM.Lazy.pas',
  Delphi.ORM.Lazy.Test in 'Delphi.ORM.Lazy.Test.pas',
  Delphi.ORM.Cache in '..\Delphi.ORM.Cache.pas',
  Delphi.ORM.Cache.Test in 'Delphi.ORM.Cache.Test.pas',
  Delphi.ORM.Lazy.Factory.Test in 'Delphi.ORM.Lazy.Factory.Test.pas',
  Delphi.ORM.Lazy.Factory in '..\Delphi.ORM.Lazy.Factory.pas',
  Delphi.ORM.Database.Metadata in '..\Delphi.ORM.Database.Metadata.pas',
  Delphi.ORM.Database.Metadata.Test in 'Delphi.ORM.Database.Metadata.Test.pas',
  Delphi.ORM.Database.Metadata.Manipulator in '..\Delphi.ORM.Database.Metadata.Manipulator.pas',
  Delphi.ORM.Database.Metadata.Manipulator.Test in 'Delphi.ORM.Database.Metadata.Manipulator.Test.pas',
  Delphi.ORM.Database.Manipulator.SQLServer in '..\Delphi.ORM.Database.Manipulator.SQLServer.pas',
  Delphi.ORM.Database.Manipulator.SQLServer.Test in 'Delphi.ORM.Database.Manipulator.SQLServer.Test.pas',
  Delphi.ORM.Lazy.Manipulator in '..\Delphi.ORM.Lazy.Manipulator.pas',
  Delphi.ORM.Lazy.Manipulator.Test in 'Delphi.ORM.Lazy.Manipulator.Test.pas',
  Delphi.ORM.Nullable.Manipulator in '..\Delphi.ORM.Nullable.Manipulator.pas',
  Delphi.ORM.Nullable.Manipulator.Test in 'Delphi.ORM.Nullable.Manipulator.Test.pas',
  Delphi.ORM.Change.Manager in '..\Delphi.ORM.Change.Manager.pas',
  Delphi.ORM.Change.Manager.Test in 'Delphi.ORM.Change.Manager.Test.pas',
  Delphi.ORM.Database.Manipulator.SQLite in '..\Delphi.ORM.Database.Manipulator.SQLite.pas',
  Delphi.ORM.Database.Manipulator.SQLite.Test in 'Delphi.ORM.Database.Manipulator.SQLite.Test.pas',
  Delphi.ORM.Database.Connection.FireDAC in '..\Delphi.ORM.Database.Connection.FireDAC.pas';

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

