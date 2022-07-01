unit Delphi.ORM.Database.Manipulator;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper;

type
  TManipulator = class(TInterfacedObject)
  public
    procedure CreateField(const Field: TField);
    procedure CreateForeignKey(const ForeignKey: TForeignKey);
    procedure CreateIndex(const Index: TIndex);
    procedure CreateTable(const Table: TTable);
    procedure DropField(const Field: TDatabaseField);
    procedure DropIndex(const Index: TDatabaseIndex);
    procedure DropForeignKey(const ForeignKey: TDatabaseForeignKey);
    procedure DropTable(const Table: TDatabaseTable);
    procedure UpdateField(const SourceField, DestinyField: TField);
  end;

implementation

{ TManipulator }

procedure TManipulator.CreateField(const Field: TField);
begin

end;

procedure TManipulator.CreateForeignKey(const ForeignKey: TForeignKey);
begin

end;

procedure TManipulator.CreateIndex(const Index: TIndex);
begin

end;

procedure TManipulator.CreateTable(const Table: TTable);
begin

end;

procedure TManipulator.DropField(const Field: TDatabaseField);
begin

end;

procedure TManipulator.DropForeignKey(const ForeignKey: TDatabaseForeignKey);
begin

end;

procedure TManipulator.DropIndex(const Index: TDatabaseIndex);
begin

end;

procedure TManipulator.DropTable(const Table: TDatabaseTable);
begin

end;

procedure TManipulator.UpdateField(const SourceField, DestinyField: TField);
begin

end;

end.

