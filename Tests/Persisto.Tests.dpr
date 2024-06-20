program Persisto.Tests;

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  Persisto.DataSet.Test in 'Persisto.DataSet.Test.pas',
  Persisto.Classes.Loader.Test in 'Persisto.Classes.Loader.Test.pas',
  Persisto.Mapper.Test in 'Persisto.Mapper.Test.pas',
  Persisto.Test.Entity in 'Persisto.Test.Entity.pas',
  Persisto.Rtti.Helper.Test in 'Persisto.Rtti.Helper.Test.pas',
  Persisto.Lazy.Test in 'Persisto.Lazy.Test.pas',
  Persisto.Database.Schema.Updater.Test in 'Persisto.Database.Schema.Updater.Test.pas',
  Persisto.Manager.Test in 'Persisto.Manager.Test.pas',
  Persisto.Test.Connection in 'Persisto.Test.Connection.pas',
  Persisto.DataSet in '..\Persisto.DataSet.pas';

begin
  ReportMemoryLeaksOnShutdown := True;

  TestInsight.DUnitX.RunRegisteredTests;
end.

