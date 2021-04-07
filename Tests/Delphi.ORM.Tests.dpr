program Delphi.ORM.Tests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  FastMM5 in '..\Externals\FastMM5\FastMM5.pas',
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
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
  Delphi.ORM.Database.Connection.Unidac in '..\Delphi.ORM.Database.Connection.Unidac.pas',
  Delphi.ORM.Cursor.Mock in 'Delphi.ORM.Cursor.Mock.pas',
  Delphi.ORM.Rtti.Helper.Test in 'Delphi.ORM.Rtti.Helper.Test.pas',
  Delphi.ORM.Nullable in '..\Delphi.ORM.Nullable.pas',
  Delphi.ORM.Nullable.Test in 'Delphi.ORM.Nullable.Test.pas',
  Delphi.ORM.Lazy in '..\Delphi.ORM.Lazy.pas',
  Delphi.ORM.Lazy.Test in 'Delphi.ORM.Lazy.Test.pas',
  Delphi.ORM.Lazy.Loader in '..\Delphi.ORM.Lazy.Loader.pas';

// Para não remover o valor abaixo
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
  FastMM_OutputDebugStringEvents := [];
  FastMM_LogToFileEvents := [mmetUnexpectedMemoryLeakSummary];
  FastMM_MessageBoxEvents := [mmetDebugBlockDoubleFree, mmetDebugBlockReallocOfFreedBlock, mmetVirtualMethodCallOnFreedObject];

  FastMM_DeleteEventLogFile;

{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
