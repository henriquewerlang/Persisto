unit Persisto.SQLite.Firedac.Drive;

interface

// Unit copied from delphi source!

uses
  System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Util,
  FireDAC.Phys, FireDAC.Phys.SQLiteWrapper;

type
  TFDPhysSQLiteDriverLink = class;
  TFDSQLiteBackup = class;
  TFDSQLiteValidate = class;
  TFDSQLiteSecurity = class;
  TFDSQLiteFunction = class;
  TFDSQLiteCollation = class;
  TFDSQLiteRTree = class;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDPhysSQLiteDriverLink = class(TFDPhysDriverLink)
  private
    FEngineLinkage: TSQLiteEngineLinkage;
    FSEEKey: string;
  protected
    function GetBaseDriverID: String; override;
    function IsConfigured: Boolean; override;
    procedure ApplyTo(const AParams: IFDStanDefinition); override;
  published
    property EngineLinkage: TSQLiteEngineLinkage read FEngineLinkage
      write FEngineLinkage default slDefault;
    property SEEKey: string read FSEEKey write FSEEKey;
  end;

  TFDSQLiteService = class (TFDPhysDriverService)
  private
    function GetDriverLink: TFDPhysSQLiteDriverLink;
    procedure SetDriverLink(const AValue: TFDPhysSQLiteDriverLink);
  published
    property DriverLink: TFDPhysSQLiteDriverLink read GetDriverLink write SetDriverLink;
  end;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteBackup = class (TFDSQLiteService)
  private
    FDestPassword: String;
    FOnProgress: TFDPhysServiceProgressEvent;
    FDestDatabase: String;
    FPassword: String;
    FDatabase: String;
    FDestMode: TSQLiteDatabaseMode;
    FPagesPerStep: Integer;
    FWaitForLocks: Boolean;
    FDestCatalog: String;
    FCatalog: String;
    FBackup: TSQLiteBackup;
    FBusyTimeout: Integer;
    FDestDatabaseObj: TSQLiteDatabase;
    FDatabaseObj: TSQLiteDatabase;
    procedure SetDatabase(const AValue: String);
    procedure SetDatabaseObj(const AValue: TSQLiteDatabase);
    procedure SetDestDatabase(const AValue: String);
    procedure SetDestDatabaseObj(const AValue: TSQLiteDatabase);
    function GetPageCount: Integer;
    function GetRemaining: Integer;
  protected
    procedure InternalExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Backup;
    property Remaining: Integer read GetRemaining;
    property PageCount: Integer read GetPageCount;

    property DatabaseObj: TSQLiteDatabase read FDatabaseObj write SetDatabaseObj;
    property DestDatabaseObj: TSQLiteDatabase read FDestDatabaseObj write SetDestDatabaseObj;

  published
    property PagesPerStep: Integer read FPagesPerStep write FPagesPerStep default -1;
    property WaitForLocks: Boolean read FWaitForLocks write FWaitForLocks default True;
    property BusyTimeout: Integer read FBusyTimeout write FBusyTimeout default 10000;

    property Database: String read FDatabase write SetDatabase;
    property Catalog: String read FCatalog write FCatalog;
    property Password: String read FPassword write FPassword;

    property DestDatabase: String read FDestDatabase write SetDestDatabase;
    property DestCatalog: String read FDestCatalog write FDestCatalog;
    property DestMode: TSQLiteDatabaseMode read FDestMode write FDestMode default smCreate;
    property DestPassword: String read FDestPassword write FDestPassword;
    property OnProgress: TFDPhysServiceProgressEvent read FOnProgress write FOnProgress;
  end;

  TFDSQLiteValidateOption = (voCheckIndexes);
  TFDSQLiteValidateOptions = set of TFDSQLiteValidateOption;
  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteValidate = class (TFDSQLiteService)
  private type
    TAction = (saCheckOnly, saSweep, saAnalyze);
  private
    FAction: TAction;
    FDatabase: String;
    FMaxErrors: Integer;
    FOptions: TFDSQLiteValidateOptions;
    FTable, FIndex: String;
    FOnProgress: TFDPhysServiceProgressEvent;
    FPassword: String;
    FLastStatus: Boolean;
  protected
    procedure InternalExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    function CheckOnly: Boolean;
    procedure Sweep;
    procedure Analyze(const ATable: String = ''; const AIndex: String = '');
  published
    property Database: String read FDatabase write FDatabase;
    property Password: String read FPassword write FPassword;
    property MaxErrors: Integer read FMaxErrors write FMaxErrors default -1;
    property Options: TFDSQLiteValidateOptions read FOptions write FOptions default [voCheckIndexes];
    property OnProgress: TFDPhysServiceProgressEvent read FOnProgress write FOnProgress;
  end;

  TFDSQLiteSecurityOptions = set of (soSetLargeCache);
  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteSecurity = class (TFDSQLiteService)
  private type
    TAction = (saSetPassword, saRemovePassword, saChangePassword, saCheckEncryption);
  private
    FAction: TAction;
    FDatabase: String;
    FToPassword: String;
    FPassword: String;
    FEncryption: String;
    FOptions: TFDSQLiteSecurityOptions;
  protected
    procedure InternalExecute; override;
  public
    procedure SetPassword;
    procedure RemovePassword;
    procedure ChangePassword;
    function CheckEncryption: String;
  published
    property Database: String read FDatabase write FDatabase;
    property Password: String read FPassword write FPassword;
    property ToPassword: String read FToPassword write FToPassword;
    property Options: TFDSQLiteSecurityOptions read FOptions write FOptions default [];
  end;


  TFDSQLiteSecurityHelper = class helper for TFDSQLiteSecurity
  public
    procedure DecryptLegacyDatabase;
  end;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteFunction = class (TFDSQLiteService)
  private
    FArgumentsCount: Integer;
    FOnFinalize: TSQLiteFunctionFinalizeEvent;
    FOnCalculate: TSQLiteFunctionCalculateEvent;
    FAggregated: Boolean;
    FDeterministic: Boolean;
    FFunctionName: String;
    FFunction: TSQLiteFunction;
    procedure SetAggregated(const AValue: Boolean);
    procedure SetDeterministic(const AValue: Boolean);
    procedure SetArgumentsCount(const AValue: Integer);
    procedure SetFunctionName(const AValue: String);
    procedure SetOnCalculate(const AValue: TSQLiteFunctionCalculateEvent);
    procedure SetOnFinalize(const AValue: TSQLiteFunctionFinalizeEvent);
  protected
    function GetActualActive: Boolean; override;
    procedure InternalUninstall; override;
    procedure InternalInstall; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Active;
    property FunctionName: String read FFunctionName write SetFunctionName;
    property ArgumentsCount: Integer read FArgumentsCount write SetArgumentsCount default 0;
    property Aggregated: Boolean read FAggregated write SetAggregated default False;
    property Deterministic: Boolean read FDeterministic write SetDeterministic default True;
    property OnCalculate: TSQLiteFunctionCalculateEvent read FOnCalculate write SetOnCalculate;
    property OnFinalize: TSQLiteFunctionFinalizeEvent read FOnFinalize write SetOnFinalize;
  end;

  TFDSQLiteCollationKind = (scCompareString, scCustomUTF8, scCustomUTF16);
  TFDSQLiteCollationFlag = (sfLingIgnoreCase, sfLingIgnoreDiacritic,
    sfIgnoreCase, sfIgnoreKanatype, sfIgnoreNonSpace, sfIgnoreSymbols,
    sfIgnoreWidth, sfLingCasing, sfDigitAsNumbers, sfStringSort);
  TFDSQLiteCollationFlags = set of TFDSQLiteCollationFlag;
  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteCollation = class (TFDSQLiteService)
  private
    FCollationName: String;
    FLocaleName: String;
    FCollationKind: TFDSQLiteCollationKind;
    FFlags: TFDSQLiteCollationFlags;
    FCollation: TSQLiteCollation;
    FOnCompare: TSQLiteCollationEvent;
    procedure SetCollationKind(const AValue: TFDSQLiteCollationKind);
    procedure SetCollationName(const AValue: String);
    procedure SetFlags(const AValue: TFDSQLiteCollationFlags);
    procedure SetLocaleName(const AValue: String);
    procedure SetOnCompare(const AValue: TSQLiteCollationEvent);
  protected
    function GetActualActive: Boolean; override;
    procedure InternalUninstall; override;
    procedure InternalInstall; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Active;
    property CollationName: String read FCollationName write SetCollationName;
    property CollationKind: TFDSQLiteCollationKind read FCollationKind
      write SetCollationKind default scCompareString;
    property LocaleName: String read FLocaleName write SetLocaleName;
    property Flags: TFDSQLiteCollationFlags read FFlags write SetFlags default [];
    property OnCompare: TSQLiteCollationEvent read FOnCompare write SetOnCompare;
  end;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TFDSQLiteRTree = class (TFDSQLiteService)
  private
    FRTree: TSQLiteRTree;
    FOnFinalize: TSQLiteRTreeFinalizeEvent;
    FOnCalculate: TSQLiteRTreeCalculateEvent;
    FRTreeName: String;
    procedure SetOnCalculate(const AValue: TSQLiteRTreeCalculateEvent);
    procedure SetOnFinalize(const AValue: TSQLiteRTreeFinalizeEvent);
    procedure SetRTreeName(const AValue: String);
  protected
    function GetActualActive: Boolean; override;
    procedure InternalUninstall; override;
    procedure InternalInstall; override;
  published
    property Active;
    property RTreeName: String read FRTreeName write SetRTreeName;
    property OnCalculate: TSQLiteRTreeCalculateEvent read FOnCalculate write SetOnCalculate;
    property OnFinalize: TSQLiteRTreeFinalizeEvent read FOnFinalize write SetOnFinalize;
  end;

procedure FDSQLiteTypeName2ADDataType(const AOptions: IFDStanOptions;
  const AColName, ATypeName: String; out ABaseColName, ABaseTypeName: String;
  out AType: TFDDataType; out AAttrs: TFDDataAttributes; out ALen: LongWord;
  out APrec, AScale: Integer);














{-------------------------------------------------------------------------------}
implementation

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
{$IFDEF MACOS}
  Macapi.CoreFoundation,
{$ENDIF}
  System.Variants, Data.FmtBCD, Data.SQLTimSt, System.SysUtils,
    System.Generics.Collections, Data.DB,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.Stan.Consts,
    FireDAC.Stan.Cipher, FireDAC.Stan.Factory,
  FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.Phys.SQLGenerator, FireDAC.Phys.SQLiteCli,
    FireDAC.Phys.SQLiteMeta, FireDAC.Phys.SQLiteDef;

type
  TFDPhysSQLiteDriver = class;
  TFDPhysSQLiteConnection = class;
  TFDPhysSQLiteTransaction = class;
  TFDPhysSQLiteEventAlerter = class;
  TFDPhysSQLiteCommand = class;

  // this class don't exists in the orignal source
  TFDPhysSQLiteMetadataEx = class(TFDPhysSQLiteMetadata)
  protected
    function InternalGetSQLCommandKind(const ATokens: TStrings): TFDPhysCommandKind; override;
  end;

  TFDPhysSQLiteDriver = class(TFDPhysDriver)
  private
    FLib: TSQLiteLib;
  protected
    class function GetBaseDriverID: String; override;
    class function GetBaseDriverDesc: String; override;
    class function GetRDBMSKind: TFDRDBMSKind; override;
    class function GetConnectionDefParamsClass: TFDConnectionDefParamsClass; override;
    procedure InternalLoad; override;
    procedure InternalUnload; override;
    function InternalCreateConnection(AConnHost: TFDPhysConnectionHost): TFDPhysConnection; override;
    function GetCliObj: Pointer; override;
    function GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable; override;
  public
    constructor Create(AManager: TFDPhysManager; const ADriverDef: IFDStanDefinition); override;
    destructor Destroy; override;
  end;

  TFDPhysSQLiteConnection = class(TFDPhysConnection)
  private
    FDatabase: TSQLiteDatabase;
    FStringFormat: TSQLiteExtDataType;
    FGuidFormat: TSQLiteExtDataType;
    FDateTimeFormat: TSQLiteExtDataType;
    FBusyTimeout: Integer;
    procedure SetupForStmt(AUpdOptions: TFDUpdateOptions);
    function PreparePwd(const APwd: String): String;
  protected
    procedure InternalConnect; override;
    procedure InternalSetMeta; override;
    procedure InternalDisconnect; override;
    procedure InternalPing; override;
    function InternalCreateTransaction: TFDPhysTransaction; override;
    function InternalCreateEvent(const AEventKind: String): TFDPhysEventAlerter; override;
    function InternalCreateCommand: TFDPhysCommand; override;
    function InternalCreateMetadata: TObject; override;
    function InternalCreateCommandGenerator(const ACommand: IFDPhysCommand): TFDPhysCommandGenerator; override;
{$IFDEF FireDAC_MONITOR}
    procedure InternalTracingChanged; override;
{$ENDIF}
    procedure InternalChangePassword(const AUserName, AOldPassword, ANewPassword: String); override;
    procedure InternalExecuteDirect(const ASQL: String; ATransaction: TFDPhysTransaction); override;
    procedure GetItem(AIndex: Integer; out AName: String;
      out AValue: Variant; out AKind: TFDMoniAdapterItemKind); override;
    function GetItemCount: Integer; override;
    function GetMessages: EFDDBEngineException; override;
    function GetCliObj: Pointer; override;
    function InternalGetCliHandle: Pointer; override;
    function GetLastAutoGenValue(const AName: String): Variant; override;
    function InternalGetCurrentCatalog: String; override;
  public
    constructor Create(ADriverObj: TFDPhysDriver; AConnHost: TFDPhysConnectionHost); override;
    destructor Destroy; override;
    property SQLiteDatabase: TSQLiteDatabase read FDatabase;
  end;

  TFDPhysSQLiteTransaction = class(TFDPhysTransaction)
  protected
    procedure InternalStartTransaction(ATxID: LongWord); override;
    procedure InternalCommit(ATxID: LongWord); override;
    procedure InternalRollback(ATxID: LongWord); override;
    procedure InternalChanged; override;
    procedure InternalCheckState(ACommandObj: TFDPhysCommand; ASuccess: Boolean); override;
    procedure InternalNotify(ANotification: TFDPhysTxNotification; ACommandObj: TFDPhysCommand); override;
  end;

  TFDPhysSQLitePostEventFunc = class(TSQLiteFunction)
  protected
    class procedure Register(ALib: TSQLiteLib); override;
    procedure DoCalculate(AData: TSQLiteFunctionInstance); override;
  public
    constructor Create(ALib: TSQLiteLib); override;
  end;

  TFDPhysSQLiteEventAlerter = class(TFDPhysEventAlerter)
  protected
    // TFDPhysEventAlerter
    procedure InternalHandle(AEventMessage: TFDPhysEventMessage); override;
    procedure InternalSignal(const AEvent: String; const AArgument: Variant); override;
  end;

  PFDSQLiteVarInfoRec = ^TFDSQLiteVarInfoRec;
  TFDSQLiteVarInfoRec = record
    FName,
    FOriginDBName,
    FOriginTabName,
    FOriginColName: String;
    FPos: Integer;
    FSrcFieldType: TFieldType;
    FSize: LongWord;
    FPrec, FScale: Integer;
    FAttrs: TFDDataAttributes;
    FSrcDataType,
    FDestDataType,
    FOutDataType: TFDDataType;
    FSrcTypeName: String;
    FOutSQLDataType: TSQLiteExtDataType;
    FVar: TSQLiteStmtVar;
    FParamType: TParamType;
    FOpts: TFDDataOptions;
  end;

  TFDPhysSQLiteStatementProps = set of (cpBatch, cpOnNextResult, cpOnNextResultValue);

  TFDPhysSQLiteCommand = class(TFDPhysCommand)
  private
    FStmt: TSQLiteStatement;
    FColumnIndex: Integer;
    FColInfos: array of TFDSQLiteVarInfoRec;
    FParInfos: array of TFDSQLiteVarInfoRec;
    FStatementProps: TFDPhysSQLiteStatementProps;
    FPreparedBatchSize: Integer;
    procedure SetupStatement(AStmt: TSQLiteStatement);
    procedure FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
    function FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
      ARowNo: Longword): Boolean;
    function GetConnection: TFDPhysSQLiteConnection;
    procedure DestroyParamInfos;
    procedure DestroyColInfos;
    procedure CreateColInfos;
    procedure CreateParamInfos;
    function FD2SQLDataType(ADataType: TFDDataType): TSQLiteExtDataType;
    function SQL2FDDataType(ADataType: TSQLiteExtDataType;
      AUnsigned: Boolean): TFDDataType;
    procedure TypeName2ADDataType(const AColName, ATypeName: String;
      out ABaseColName, ABaseTypeName: String; out AType: TFDDataType;
      out AAttrs: TFDDataAttributes; out ALen: LongWord; out APrec, AScale: Integer);
    procedure SetParamValue(AFmtOpts: TFDFormatOptions; AParam: TFDParam;
      AVar: TSQLiteStmtVar; ApInfo: PFDSQLiteVarInfoRec; AParIndex: Integer);
    procedure SetParamValues(ABatchSize, AOffset: Integer);
    function GetCursor(AOffset: Integer): Boolean;
    function CheckArray(ASize: Integer): Boolean;
    procedure ExecuteBatchInsert(ATimes, AOffset: Integer;
      var ACount: TFDCounter);
  protected
    procedure InternalClose; override;
    procedure InternalExecute(ATimes, AOffset: Integer; var ACount: TFDCounter); override;
    function InternalFetchRowSet(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
      ARowsetSize: LongWord): LongWord; override;
    procedure InternalAbort; override;
    function InternalOpen(var ACount: TFDCounter): Boolean; override;
    function InternalNextRecordSet: Boolean; override;
    procedure InternalPrepare; override;
    function InternalUseStandardMetadata: Boolean; override;
    function InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean; override;
    function InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean; override;
    procedure InternalUnprepare; override;
    function GetCliObj: Pointer; override;
  public
    property SQLiteConnection: TFDPhysSQLiteConnection read GetConnection;
    property SQLiteStatement: TSQLiteStatement read FStmt;
  end;

const
  S_FD_Default = 'Default';
  S_FD_Dynamic = 'Dynamic';
  S_FD_Static = 'Static';
  S_FD_SEEStatic = 'SEEStatic';

  S_FD_CreateUTF8 = 'CreateUTF8';
  S_FD_CreateUTF16 = 'CreateUTF16';
  S_FD_ReadWrite = 'ReadWrite';
  S_FD_ReadOnly = 'ReadOnly';
  S_FD_Normal = 'Normal';
  S_FD_Exclusive = 'Exclusive';
  S_FD_Full = 'Full';
  S_FD_Off = 'Off';
  S_FD_On = 'On';
  S_FD_CacheSize = '10000';
  S_FD_String = 'String';
  S_FD_Binary = 'Binary';
  S_FD_DateTime = 'DateTime';
  S_FD_Choose = 'Choose';
  S_FD_Unicode = 'Unicode';
  S_FD_ANSI = 'ANSI';
  S_FD_Delete = 'Delete';
  S_FD_Truncate = 'Truncate';
  S_FD_Persist = 'Persist';
  S_FD_Memory = 'Memory';
  S_FD_WAL = ' WAL';

  C_FD_Type2SQLDataType: array [TFDDataType] of TSQLiteExtDataType = (
    etUnknown,
    etBoolean,
    etInteger, etInteger, etInteger, etInteger,
    etInteger, etInteger, etInteger, etInteger,
    etDouble, etDouble, etDouble,
    etCurrency, etNumber, etNumber,
    etDateTime, etTime, etDate, etDateTime,
    etUnknown, etUnknown, etUnknown,
    etString, etUString, etBlob,
    etBlob, etString, etUString, etUString,
    etBlob, etString, etUString,
    etBlob,
    etUnknown, etUnknown, etUnknown,
      etUnknown, etUnknown,
    etString, etUnknown
  );

  C_FD_SQLDataType2Type: array [TSQLiteExtDataType] of TFDDataType =
    (dtUnknown, dtAnsiString, dtWideString, dtInt64, dtDouble,
     dtFmtBCD, dtCurrency, dtBlob, dtBoolean, dtDate, dtTime, dtDateTimeStamp);

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteDriverLink                                                       }
{-------------------------------------------------------------------------------}
function TFDPhysSQLiteDriverLink.GetBaseDriverID: String;
begin
  Result := S_FD_SQLiteId;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteDriverLink.ApplyTo(const AParams: IFDStanDefinition);
var
  s: String;
begin
  inherited ApplyTo(AParams);
  if EngineLinkage <> slDefault then begin
    case EngineLinkage of
    slDefault:   s := S_FD_Default;
    slStatic:    s := S_FD_Static;
    slDynamic:   s := S_FD_Dynamic;
    slSEEStatic: s := S_FD_SEEStatic;
    end;
    AParams.AsString[S_FD_ConnParam_SQLite_EngineLinkage] := s;
  end;
  if SEEKey <> '' then
    AParams.AsString[S_FD_ConnParam_SQLite_SEEKey] := SEEKey;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteDriverLink.IsConfigured: Boolean;
begin
  Result := inherited IsConfigured or (EngineLinkage <> slDefault) or (SEEKey <> '');
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteService                                                              }
{-------------------------------------------------------------------------------}
function TFDSQLiteService.GetDriverLink: TFDPhysSQLiteDriverLink;
begin
  Result := inherited DriverLink as TFDPhysSQLiteDriverLink;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteService.SetDriverLink(const AValue: TFDPhysSQLiteDriverLink);
begin
  inherited DriverLink := AValue;
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteBackup                                                               }
{-------------------------------------------------------------------------------}
constructor TFDSQLiteBackup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPagesPerStep := -1;
  FWaitForLocks := True;
  FBusyTimeout := 10000;
  FCatalog := 'MAIN';
  FDestCatalog := 'MAIN';
  FDestMode := smCreate;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.SetDatabase(const AValue: String);
begin
  FDatabase := AValue;
  if AValue <> '' then
    DatabaseObj := nil;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.SetDatabaseObj(const AValue: TSQLiteDatabase);
begin
  FDatabaseObj := AValue;
  if AValue <> nil then
    Database := '';
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.SetDestDatabase(const AValue: String);
begin
  FDestDatabase := AValue;
  if AValue <> '' then
    DestDatabaseObj := nil;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.SetDestDatabaseObj(const AValue: TSQLiteDatabase);
begin
  FDestDatabaseObj := AValue;
  if AValue <> nil then
    DestDatabase := '';
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteBackup.GetPageCount: Integer;
begin
  if FBackup = nil then
    Result := 0
  else
    Result := FBackup.PageCount;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteBackup.GetRemaining: Integer;
begin
  if FBackup = nil then
    Result := 0
  else
    Result := FBackup.Remaining;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.InternalExecute;
var
  oLib: TSQLiteLib;
  oSrc, oDest: TSQLiteDatabase;
begin
  oLib := CliObj as TSQLiteLib;
  if DatabaseObj <> nil then
    oSrc := DatabaseObj
  else
    oSrc := TSQLiteDatabase.Create(oLib, Self);
  if DestDatabaseObj <> nil then
    oDest := DestDatabaseObj
  else
    oDest := TSQLiteDatabase.Create(oLib, Self);
  FBackup := TSQLiteBackup.Create(oLib, oDest);
  try
    if DatabaseObj = nil then begin
      // smReadWrite is required to cleanup WAL / SHM files after backup
      oSrc.Open(FDExpandStr(Database), smReadWrite, scDefault);
      oSrc.BusyTimeout := BusyTimeout;
      if Password <> '' then
        oSrc.Key(Password);
    end;
    if DestDatabaseObj = nil then begin
      oDest.Open(FDExpandStr(DestDatabase), DestMode, scDefault);
      if DestPassword <> '' then
        oDest.Key(DestPassword);
    end;
    FBackup.SourceDatabase := oSrc;
    FBackup.SourceDBName := Catalog;
    FBackup.DestinationDatabase := oDest;
    FBackup.DestinationDBName := DestCatalog;
    FBackup.PagesPerStep := PagesPerStep;
    FBackup.WaitForLocks := WaitForLocks;
    FBackup.Init;
    try
      while not FBackup.Step do
        if Assigned(FOnProgress) then
          FOnProgress(Self, '');
    finally
      FBackup.Finish;
    end;
  finally
    FDFreeAndNil(FBackup);
    if DatabaseObj = nil then
      FDFree(oSrc);
    if DestDatabaseObj = nil then
      FDFree(oDest);
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteBackup.Backup;
begin
  Execute;
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteValidate                                                             }
{-------------------------------------------------------------------------------}
constructor TFDSQLiteValidate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [voCheckIndexes];
  FMaxErrors := -1;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteValidate.CheckOnly: Boolean;
begin
  FLastStatus := True;
  FAction := saCheckOnly;
  Execute;
  Result := FLastStatus;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteValidate.Sweep;
begin
  FLastStatus := True;
  FAction := saSweep;
  Execute;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteValidate.Analyze(const ATable, AIndex: String);
begin
  FLastStatus := True;
  FTable := ATable;
  FIndex := AIndex;
  FAction := saAnalyze;
  Execute;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteValidate.InternalExecute;
var
  oConn: IFDPhysConnection;
  oCmd: IFDPhysCommand;
  oTab: TFDDatSTable;
  sConn, sAction, sLine: String;
  i, j: Integer;
  rFmt: TFDParseFmtSettings;
begin
  sConn := 'DriverID=' + DriverLink.ActualDriverID + ';Database=' + Database;
  if Password <> '' then
    sConn := sConn + ';Password=' + Password;
  FDPhysManager().CreateConnection(sConn, oConn);
  oConn.Open;
  oConn.CreateCommand(oCmd);
  case FAction of
  saCheckOnly:
    begin
      sAction := 'PRAGMA ';
      if voCheckIndexes in Options then
        sAction := sAction + 'integrity_check'
      else
        sAction := sAction + 'quick_check';
      if MaxErrors >= 0 then
        sAction := sAction + '(' + IntToStr(MaxErrors) + ')';
    end;
  saSweep:
    sAction := 'VACUUM';
  saAnalyze:
    begin
      sAction := 'ANALYZE';
      if FTable <> '' then
        sAction := sAction + ' ' + FTable;
    end;
  end;
  oCmd.Prepare(sAction);
  if FAction = saCheckOnly then begin
    oTab := oCmd.Define();
    try
      oCmd.Open(True);
      oCmd.Fetch(oTab, True, True);
      FLastStatus := (oTab.Rows.Count = 0) or
        (oTab.Rows.Count = 1) and (CompareText(oTab.Rows[0].ValueI[0], 'ok') = 0);
      if not FLastStatus and Assigned(FOnProgress) then begin
        rFmt.FQuote := #0;
        rFmt.FQuote1 := #0;
        rFmt.FQuote2 := #0;
        rFmt.FDelimiter := #10;
        for i := 0 to oTab.Rows.Count - 1 do begin
          sLine := VarToStr(oTab.Rows[i].ValueI[0]);
          j := 1;
          while j <= Length(sLine) do
            FOnProgress(Self, FDExtractFieldName(sLine, j, rFmt));
        end;
      end;
    finally
      FDFree(oTab);
    end;
  end
  else
    oCmd.Execute();
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteSecurity                                                             }
{-------------------------------------------------------------------------------}
procedure TFDSQLiteSecurity.SetPassword;
begin
  FAction := saSetPassword;
  Execute;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteSecurity.RemovePassword;
begin
  FAction := saRemovePassword;
  Execute;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteSecurity.ChangePassword;
begin
  FAction := saChangePassword;
  Execute;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteSecurity.CheckEncryption: String;
begin
  FAction := saCheckEncryption;
  FEncryption := '';
  Execute;
  Result := FEncryption;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteSecurity.InternalExecute;
var
  oDef: IFDStanConnectionDef;
  oConn: IFDPhysConnection;

  procedure SetLargerCache;
  var
    sDB: String;
    oFS: TFileStream;
    iSize: Int64;
  begin
    if soSetLargeCache in Options then begin
      sDB := oDef.Params.ExpandedDatabase;
      if FileExists(sDB) then begin
        oFS := TFileStream.Create(sDB, fmOpenRead or fmShareDenyNone);
        try
          iSize := Trunc(oFS.Size * 1.1) div 1024;
          if iSize > StrToInt(S_FD_CacheSize) then
            oDef.Params.Add(S_FD_ConnParam_SQLite_CacheSize + '=' + IntToStr(iSize));
        finally
          FDFree(oFS);
        end;
      end;
    end;
  end;

begin
  FDCreateInterface(IFDStanConnectionDef, oDef);
  oDef.Params.DriverID := DriverLink.ActualDriverID;
  oDef.Params.Database := Database;
  case FAction of
  saSetPassword:
    begin
      if Password = '' then
        FDException(Self, [S_FD_LPhys, S_FD_SQLiteId], er_FD_SQLitePwdInvalid, []);
      SetLargerCache;
      oDef.Params.Add(S_FD_ConnParam_Common_NewPassword + '=' + Password);
    end;
  saRemovePassword:
    begin
      if Password = '' then
        FDException(Self, [S_FD_LPhys, S_FD_SQLiteId], er_FD_SQLitePwdInvalid, []);
      SetLargerCache;
      oDef.Params.Add(S_FD_ConnParam_Common_Password + '=' + Password);
      oDef.Params.Add(S_FD_ConnParam_Common_NewPassword + '=');
    end;
  saChangePassword:
    begin
      if (Password = '') and (ToPassword = '') then
        FDException(Self, [S_FD_LPhys, S_FD_SQLiteId], er_FD_SQLitePwdInvalid, []);
      SetLargerCache;
      oDef.Params.Add(S_FD_ConnParam_Common_Password + '=' + Password);
      oDef.Params.Add(S_FD_ConnParam_Common_NewPassword + '=' + ToPassword);
    end;
  saCheckEncryption:
    oDef.Params.Add(S_FD_ConnParam_Common_Password + '=' + Password);
  end;
  FDPhysManager().CreateConnection(oDef, oConn);
  try
    oConn.Open;
    if FAction = saCheckEncryption then
      FEncryption := TSQLiteDatabase(oConn.CliObj).Encryption;
  except
    on E: EFDDBEngineException do
      if FAction <> saCheckEncryption then
        raise
      else if E.FDCode = er_FD_SQLiteDBUnencrypted then
        FEncryption := '<unencrypted>'
      else if (E.FDCode = er_FD_SQLitePwdInvalid) or
              (E.FDCode = er_FD_SQLiteAlgFailure) or
              (E[0].ErrorCode = SQLITE_NOTADB) then
        FEncryption := '<encrypted>';
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteSecurityHelper.DecryptLegacyDatabase;
var
  oStd_Link: TFDPhysSQLiteDriverLink;
  oSEE_Link: TFDPhysSQLiteDriverLink;
  oStd_Sec: TFDSQLiteSecurity;
  oSEE_Sec: TFDSQLiteSecurity;
begin
  oStd_Link := nil;
  oSEE_Link := nil;
  oStd_Sec := nil;
  oSEE_Sec := nil;
  try
    oStd_Link := TFDPhysSQLiteDriverLink.Create(nil);
    oStd_Link.DriverID := C_FD_SysNamePrefix + 'SQLite_Std';
    oStd_Link.EngineLinkage := slStatic;

    oSEE_Link := TFDPhysSQLiteDriverLink.Create(nil);
    oSEE_Link.DriverID := C_FD_SysNamePrefix + 'SQLite_SEE';
    oSEE_Link.EngineLinkage := slSEEStatic;

    oStd_Sec := TFDSQLiteSecurity.Create(nil);
    oStd_Sec.DriverLink := oStd_Link;
    oStd_Sec.Options := Options;

    oSEE_Sec := TFDSQLiteSecurity.Create(nil);
    oSEE_Sec.DriverLink := oSEE_Link;
    oStd_Sec.Options := Options;

    oStd_Sec.Password := Password;
    oStd_Sec.Database := Database;
    oStd_Sec.RemovePassword;

    if ToPassword <> '' then
      oSEE_Sec.Password := ToPassword
    else
      oSEE_Sec.Password := Password;
    oSEE_Sec.Database := Database;
    oSEE_Sec.SetPassword;

  finally
    oStd_Sec.Free;
    oSEE_Sec.Free;
    oStd_Link.Free;
    oSEE_Link.Free;
  end;
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteFunction                                                             }
{-------------------------------------------------------------------------------}
constructor TFDSQLiteFunction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDeterministic := True;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetAggregated(const AValue: Boolean);
begin
  if FAggregated <> AValue then begin
    Active := False;
    FAggregated := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetArgumentsCount(const AValue: Integer);
begin
  if FArgumentsCount <> AValue then begin
    Active := False;
    FArgumentsCount := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetDeterministic(const AValue: Boolean);
begin
  if FDeterministic <> AValue then begin
    Active := False;
    FDeterministic := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetFunctionName(const AValue: String);
begin
  if FFunctionName <> AValue then begin
    Active := False;
    FFunctionName := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetOnCalculate(const AValue: TSQLiteFunctionCalculateEvent);
begin
  if (TMethod(FOnCalculate).Code <> TMethod(AValue).Code) or
     (TMethod(FOnCalculate).Data <> TMethod(AValue).Data) then begin
    Active := False;
    FOnCalculate := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.SetOnFinalize(const AValue: TSQLiteFunctionFinalizeEvent);
begin
  if (TMethod(FOnFinalize).Code <> TMethod(AValue).Code) or
     (TMethod(FOnFinalize).Data <> TMethod(AValue).Data) then begin
    Active := False;
    FOnFinalize := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteFunction.GetActualActive: Boolean;
begin
  Result := inherited GetActualActive and (FunctionName <> '') and
    Assigned(OnCalculate);
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.InternalUninstall;
begin
  FDFreeAndNil(FFunction);
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteFunction.InternalInstall;
begin
  FFunction := TSQLiteFunction.Create(CliObj as TSQLiteLib);
  FFunction.Name := FunctionName;
  FFunction.Args := ArgumentsCount;
  FFunction.Aggregate := Aggregated;
  FFunction.Deterministic := Deterministic;
  FFunction.OnCalculate := OnCalculate;
  FFunction.OnFinalize := OnFinalize;
  FFunction.InstallAll;
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteCollation                                                            }
{-------------------------------------------------------------------------------}
constructor TFDSQLiteCollation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCollationKind := scCompareString;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteCollation.GetActualActive: Boolean;
begin
  Result := inherited GetActualActive and (CollationName <> '') and
    ((CollationKind = scCompareString) or Assigned(FOnCompare));
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.SetCollationKind(const AValue: TFDSQLiteCollationKind);
begin
  if FCollationKind <> AValue then begin
    Active := False;
    FCollationKind := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.SetCollationName(const AValue: String);
begin
  if FCollationName <> AValue then begin
    Active := False;
    FCollationName := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.SetFlags(const AValue: TFDSQLiteCollationFlags);
begin
  if FFlags <> AValue then begin
    Active := False;
    FFlags := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.SetLocaleName(const AValue: String);
var
  sPrev: String;
begin
  if FLocaleName <> AValue then begin
    Active := False;
    sPrev := FDStrReplace(LocaleName, '-', '_');
    FLocaleName := AValue;
    if (CollationName = '') or (sPrev = CollationName) then
      CollationName := FDStrReplace(LocaleName, '-', '_');
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.SetOnCompare(const AValue: TSQLiteCollationEvent);
begin
  if (TMethod(FOnCompare).Code <> TMethod(AValue).Code) or
     (TMethod(FOnCompare).Data <> TMethod(AValue).Data) then begin
    Active := False;
    FOnCompare := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.InternalInstall;
const
{$IFDEF MSWINDOWS}
  SORT_DIGITSASNUMBERS  = $00000008;
  LINGUISTIC_IGNORECASE = $00000010;
  LINGUISTIC_IGNOREDIACRITIC = $00000020;
  NORM_LINGUISTIC_CASING = $08000000;
{$ENDIF}
  C_Flags: array [TFDSQLiteCollationFlag] of LongWord = (
{$IFDEF MSWINDOWS}
    LINGUISTIC_IGNORECASE, LINGUISTIC_IGNOREDIACRITIC, NORM_IGNORECASE,
    NORM_IGNOREKANATYPE, NORM_IGNORENONSPACE, NORM_IGNORESYMBOLS,
    NORM_IGNOREWIDTH, NORM_LINGUISTIC_CASING, SORT_DIGITSASNUMBERS,
    SORT_STRINGSORT
{$ENDIF}
{$IFDEF MACOS}
    kCFCompareCaseInsensitive, kCFCompareDiacriticInsensitive, kCFCompareCaseInsensitive,
    0, 0, 0, kCFCompareWidthInsensitive, 0, kCFCompareNumerically, 0
{$ENDIF}
{$IF DEFINED(ANDROID) or DEFINED(LINUX)}
    1, 0, 1, 0, 0, 0, 0, 0, 0, 0
{$ENDIF}
    );
var
  eFlag: TFDSQLiteCollationFlag;
  oColCmp: TSQLiteCollationCompareString;
begin
  if CollationKind = scCompareString then begin
    oColCmp := TSQLiteCollationCompareString.Create(CliObj as TSQLiteLib);
    FCollation := oColCmp;
    oColCmp.OwningObj := Self;
    if LocaleName = '' then
      oColCmp.LocaleID := Languages.UserDefaultLocale
    else
      oColCmp.LocaleID := Languages.GetLocaleIDFromLocaleName(LocaleName);
    oColCmp.Flags := 0;
    for eFlag := Low(TFDSQLiteCollationFlag) to High(TFDSQLiteCollationFlag) do
      if eFlag in Flags then
        oColCmp.Flags := oColCmp.Flags or C_Flags[eFlag];
  end
  else begin
    FCollation := TSQLiteCollation.Create(CliObj as TSQLiteLib);
    FCollation.OwningObj := Self;
    FCollation.OnCompare := OnCompare;
    if CollationKind = scCustomUTF8 then
      FCollation.Encoding := SQLITE_UTF8
    else
      FCollation.Encoding := SQLITE_UTF16;
  end;
  FCollation.Name := CollationName;
  FCollation.InstallAll;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteCollation.InternalUninstall;
var
  oMan: IFDPhysManager;
begin
  oMan := FDPhysManager();
  if (oMan <> nil) and (oMan.State = dmsActive) and
     (DriverLink.DriverIntf.ConnectionCount > 0) then
    FCollation := nil
  else
    FDFreeAndNil(FCollation);
end;

{-------------------------------------------------------------------------------}
{ TFDSQLiteRTree                                                                }
{-------------------------------------------------------------------------------}
procedure TFDSQLiteRTree.SetRTreeName(const AValue: String);
begin
  if FRTreeName <> AValue then begin
    Active := False;
    FRTreeName := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteRTree.SetOnCalculate(const AValue: TSQLiteRTreeCalculateEvent);
begin
  if (TMethod(FOnCalculate).Code <> TMethod(AValue).Code) or
     (TMethod(FOnCalculate).Data <> TMethod(AValue).Data) then begin
    Active := False;
    FOnCalculate := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteRTree.SetOnFinalize(const AValue: TSQLiteRTreeFinalizeEvent);
begin
  if (TMethod(FOnFinalize).Code <> TMethod(AValue).Code) or
     (TMethod(FOnFinalize).Data <> TMethod(AValue).Data) then begin
    Active := False;
    FOnFinalize := AValue;
  end;
end;

{-------------------------------------------------------------------------------}
function TFDSQLiteRTree.GetActualActive: Boolean;
begin
  Result := inherited GetActualActive and Assigned(FOnCalculate);
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteRTree.InternalUninstall;
begin
  FDFreeAndNil(FRTree);
end;

{-------------------------------------------------------------------------------}
procedure TFDSQLiteRTree.InternalInstall;
begin
  FRTree := TSQLiteRTree.Create(CliObj as TSQLiteLib);
  FRTree.Name := RTreeName;
  FRTree.OnCalculate := OnCalculate;
  FRTree.OnFinalize := OnFinalize;
  FRTree.InstallAll;
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteDriver                                                           }
{-------------------------------------------------------------------------------}
constructor TFDPhysSQLiteDriver.Create(AManager: TFDPhysManager;
  const ADriverDef: IFDStanDefinition);
begin
  inherited Create(AManager, ADriverDef);
end;

{-------------------------------------------------------------------------------}
destructor TFDPhysSQLiteDriver.Destroy;
begin
  inherited Destroy;
  FDFreeAndNil(FLib);
end;

{-------------------------------------------------------------------------------}
class function TFDPhysSQLiteDriver.GetBaseDriverID: String;
begin
  Result := S_FD_SQLiteId;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysSQLiteDriver.GetBaseDriverDesc: String;
begin
  Result := 'SQLite database';
end;

{ ----------------------------------------------------------------------------- }
class function TFDPhysSQLiteDriver.GetRDBMSKind: TFDRDBMSKind;
begin
  Result := TFDRDBMSKinds.SQLite;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysSQLiteDriver.GetConnectionDefParamsClass: TFDConnectionDefParamsClass;
begin
  Result := TFDPhysSQLiteConnectionDefParams;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteDriver.InternalLoad;
var
  sHome, sLib, sLinkage, sSEEKey: String;
  eLinkage: TSQLiteEngineLinkage;
  oLibClass: TSQLiteLibClass;
begin
  sHome := '';
  sLib := '';
  sSEEKey := '';
  eLinkage := slDefault;
  GetVendorParams(sHome, sLib);
  if Params <> nil then begin
    if Params.OwnValue(S_FD_ConnParam_SQLite_EngineLinkage) then begin
      sLinkage := Params.AsString[S_FD_ConnParam_SQLite_EngineLinkage];
      if SameText(sLinkage, S_FD_Dynamic) then
        eLinkage := slDynamic
      else if SameText(sLinkage, S_FD_Static) then
        eLinkage := slStatic
      else if SameText(sLinkage, S_FD_SEEStatic) then
        eLinkage := slSEEStatic;
    end;
    if Params.OwnValue(S_FD_ConnParam_SQLite_SEEKey) then
      sSEEKey := Params.AsString[S_FD_ConnParam_SQLite_SEEKey];
  end;
  oLibClass := TSQLiteLib.GLibClasses[eLinkage];
  if oLibClass = nil then
    FDException(Self, [S_FD_LPhys, DriverID], er_FD_SQLiteLinkageNotSupported, [sLinkage]);
  FLib := oLibClass.Create(FDPhysManagerObj);
  FLib.Load(sHome, sLib);
  if sSEEKey <> '' then
    FLib.ActivateSEE(sSEEKey);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteDriver.InternalUnload;
begin
  FLib.Unload;
  FDFreeAndNil(FLib);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteDriver.InternalCreateConnection(
  AConnHost: TFDPhysConnectionHost): TFDPhysConnection;
begin
  Result := TFDPhysSQLiteConnection.Create(Self, AConnHost);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteDriver.GetCliObj: Pointer;
begin
  Result := FLib;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteDriver.GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable;
var
  oView: TFDDatSView;
begin
  Result := inherited GetConnParams(AKeys, AParams);
  oView := Result.Select('Name=''' + S_FD_ConnParam_Common_Database + '''');
  if oView.Rows.Count = 1 then begin
    oView.Rows[0].BeginEdit;
    oView.Rows[0].SetValues('Type', '@F:SQLite Database|*.sdb;*.db');
    oView.Rows[0].SetValues('LoginIndex', 0);
    oView.Rows[0].EndEdit;
  end;
  oView := Result.Select('Name=''' + S_FD_ConnParam_Common_UserName + '''');
  if oView.Rows.Count = 1 then begin
    oView.Rows[0].BeginEdit;
    oView.Rows[0].SetValues('LoginIndex', -1);
    oView.Rows[0].EndEdit;
  end;
  oView := Result.Select('Name=''' + S_FD_ConnParam_Common_Password + '''');
  if oView.Rows.Count = 1 then begin
    oView.Rows[0].BeginEdit;
    oView.Rows[0].SetValues('LoginIndex', 1);
    oView.Rows[0].EndEdit;
  end;

  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_OpenMode, S_FD_CreateUTF8 + ';' + S_FD_CreateUTF16 + ';' + S_FD_ReadWrite + ';' +
    S_FD_ReadOnly, S_FD_CreateUTF8, S_FD_ConnParam_SQLite_OpenMode, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_Encrypt, S_FD_No + ';' + FDCipherGetClasses(), S_FD_No, S_FD_ConnParam_SQLite_Encrypt, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_BusyTimeout, '@I', '10000', S_FD_ConnParam_SQLite_BusyTimeout, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_CacheSize, '@I', S_FD_CacheSize, S_FD_ConnParam_SQLite_CacheSize, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_SharedCache, '@L', S_FD_True, S_FD_ConnParam_SQLite_SharedCache, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_LockingMode, S_FD_Normal + ';' + S_FD_Exclusive, S_FD_Exclusive, S_FD_ConnParam_SQLite_LockingMode, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_Synchronous, S_FD_Full + ';' + S_FD_Normal + ';' + S_FD_Off, S_FD_Off, S_FD_ConnParam_SQLite_Synchronous, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_JournalMode, S_FD_Delete + ';' + S_FD_Truncate + ';' + S_FD_Persist + ';' +
    S_FD_Memory + ';' + S_FD_WAL + ';' + S_FD_Off, S_FD_Delete, S_FD_ConnParam_SQLite_JournalMode, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_ForeignKeys, S_FD_On + ';' + S_FD_Off, S_FD_On, S_FD_ConnParam_SQLite_ForeignKeys, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_StringFormat, S_FD_Choose + ';' + S_FD_Unicode + ';' + S_FD_ANSI, S_FD_Choose, S_FD_ConnParam_SQLite_StringFormat, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_GUIDFormat, S_FD_String + ';' + S_FD_Binary, S_FD_String, S_FD_ConnParam_SQLite_GUIDFormat, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_DateTimeFormat, S_FD_String + ';' + S_FD_Binary + ';' + S_FD_DateTime, S_FD_String, S_FD_ConnParam_SQLite_DateTimeFormat, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_Extensions, '@S', S_FD_False, S_FD_ConnParam_SQLite_Extensions, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_SQLite_SQLiteAdvanced, '@S', '', S_FD_ConnParam_SQLite_SQLiteAdvanced, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaDefCatalog, '@S', 'MAIN', S_FD_ConnParam_Common_MetaDefCatalog, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaCurCatalog, '@S', '', S_FD_ConnParam_Common_MetaCurCatalog, -1]);
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteConnection                                                       }
{-------------------------------------------------------------------------------}
constructor TFDPhysSQLiteConnection.Create(ADriverObj: TFDPhysDriver;
  AConnHost: TFDPhysConnectionHost);
begin
  inherited Create(ADriverObj, AConnHost);
end;

{-------------------------------------------------------------------------------}
destructor TFDPhysSQLiteConnection.Destroy;
begin
  inherited Destroy;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalCreateTransaction: TFDPhysTransaction;
begin
  Result := TFDPhysSQLiteTransaction.Create(Self);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalCreateEvent(const AEventKind: String): TFDPhysEventAlerter;
begin
  if CompareText(AEventKind, S_FD_EventKind_SQLite_Events) = 0 then
    Result := TFDPhysSQLiteEventAlerter.Create(Self, AEventKind)
  else
    Result := nil;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalCreateCommand: TFDPhysCommand;
begin
  Result := TFDPhysSQLiteCommand.Create(Self);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalCreateCommandGenerator(
  const ACommand: IFDPhysCommand): TFDPhysCommandGenerator;
begin
  if ACommand <> nil then
    Result := TFDPhysSQLiteCommandGenerator.Create(ACommand)
  else
    Result := TFDPhysSQLiteCommandGenerator.Create(Self);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalCreateMetadata: TObject;
var
  oLib: TSQLiteLib;
begin
  oLib := TFDPhysSQLiteDriver(DriverObj).FLib;
  Result := TFDPhysSQLiteMetadataEx.Create(Self, oLib.Brand, oLib.Version, oLib.Version,
    FStringFormat = etUString, Assigned(oLib.Fsqlite3_column_database_name));
end;

{-------------------------------------------------------------------------------}
{$IFDEF FireDAC_Monitor}
procedure TFDPhysSQLiteConnection.InternalTracingChanged;
begin
  if FDatabase <> nil then begin
    FDatabase.Monitor := FMonitor;
    FDatabase.Tracing := FTracing;
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.PreparePwd(const APwd: String): String;
var
  s: String;
begin
  Result := APwd;
  s := ConnectionDef.AsString[S_FD_ConnParam_SQLite_Encrypt];
  if (s <> '') and (CompareText(s, S_FD_No) <> 0) and
     (Result <> '') and (Pos(':', Result) = 0) then
    Result := s + ':' + Result;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalConnect;

  procedure FillList(AList: TStrings; const AParam, ADefVal: String);
  var
    sExt: String;
    i: Integer;
  begin
    AList.Clear;
    if ConnectionDef.HasValue(AParam) then begin
      sExt := ConnectionDef.AsString[AParam];
      i := 1;
      while i <= Length(sExt) do
        AList.Add(FDExtractFieldName(sExt, i));
    end
    else
      AList.Add(ADefVal);
  end;

  procedure SetPragma(const AParam, ADef, APragma: String);
  var
    s: String;
  begin
    if ConnectionDef.HasValue(AParam) then
      s := ConnectionDef.AsString[AParam]
    else
      s := ADef;
    InternalExecuteDirect('PRAGMA ' + APragma + ' = ' + s, nil);
  end;

var
  oParams: TFDPhysSQLiteConnectionDefParams;
  sDatabase, s: String;
  eSharedCache: TSQLiteSharedCache;
  eMode: TSQLiteDatabaseMode;
  eEncoding: TFDEncoding;
  i: Integer;
begin
  oParams := ConnectionDef.Params as TFDPhysSQLiteConnectionDefParams;
  sDatabase := oParams.ExpandedDatabase;
  if sDatabase = '' then
    sDatabase := ':memory:';
  eMode := smCreate;
  eEncoding := ecDefault;
  eSharedCache := scDefault;
  if ConnectionDef.HasValue(S_FD_ConnParam_SQLite_OpenMode) then
    case oParams.OpenMode of
    omCreateUTF8:  begin eMode := smCreate; eEncoding := ecUTF8; end;
    omCreateUTF16: begin eMode := smCreate; eEncoding := ecUTF16; end;
    omReadWrite:   eMode := smReadWrite;
    omReadOnly:    eMode := smReadOnly;
    end;
  if ConnectionDef.HasValue(S_FD_ConnParam_SQLite_SharedCache) then
    if oParams.SharedCache then
      eSharedCache := scShared
    else
      eSharedCache := scPrivate;
  FBusyTimeout := oParams.BusyTimeout;

  if InternalGetSharedCliHandle() <> nil then
    FDatabase := TSQLiteDatabase.CreateUsingHandle(TFDPhysSQLiteDriver(DriverObj).FLib,
      psqlite3(InternalGetSharedCliHandle()), Self)
  else
    FDatabase := TSQLiteDatabase.Create(TFDPhysSQLiteDriver(DriverObj).FLib, Self);
{$IFDEF FireDAC_MONITOR}
  InternalTracingChanged;
{$ENDIF}

  case oParams.StringFormat of
  sfChoose:  FStringFormat := etUnknown;
  sfUnicode: FStringFormat := etUString;
  sfANSI:    FStringFormat := etString;
  end;
  case oParams.GUIDFormat of
  guiString: FGuidFormat := etString;
  guiBinary: FGuidFormat := etBlob;
  end;
  case oParams.DateTimeFormat of
  dtfString:   FDateTimeFormat := etString;
  dtfBinary:   FDateTimeFormat := etInteger;
  dtfDateTime: FDateTimeFormat := etDateTime;
  end;
  FDatabase.DateTimeFormat := FDateTimeFormat;

  if InternalGetSharedCliHandle() = nil then begin
    FillList(FDatabase.Extensions, S_FD_ConnParam_SQLite_Extensions, S_FD_False);

    FDatabase.Open(sDatabase, eMode, eSharedCache);
    if ConnectionDef.HasValue(S_FD_ConnParam_Common_Password) then
      FDatabase.Key(PreparePwd(oParams.Password));

    case eEncoding of
    ecUTF8:  InternalExecuteDirect('PRAGMA encoding = "UTF-8"', nil);
    ecUTF16: InternalExecuteDirect('PRAGMA encoding = "UTF-16"', nil);
    end;

    SetPragma(S_FD_ConnParam_SQLite_CacheSize, S_FD_CacheSize, 'cache_size');
    SetPragma(S_FD_ConnParam_SQLite_LockingMode, S_FD_Exclusive, 'locking_mode');
    SetPragma(S_FD_ConnParam_SQLite_Synchronous, S_FD_Off, 'synchronous');
    if TFDPhysSQLiteDriver(DriverObj).FLib.Version >= svSQLite030700 then
      SetPragma(S_FD_ConnParam_SQLite_JournalMode, S_FD_Delete, 'journal_mode');
    if TFDPhysSQLiteDriver(DriverObj).FLib.Version >= svSQLite030619 then
      SetPragma(S_FD_ConnParam_SQLite_ForeignKeys, S_FD_On, 'foreign_keys');

    s := oParams.SQLiteAdvanced;
    i := 1;
    while i <= Length(s) do
      InternalExecuteDirect('PRAGMA ' + FDExpandStr(FDExtractFieldName(s, i)), nil);

    if ConnectionDef.IsSpecified(S_FD_ConnParam_Common_NewPassword) then
      FDatabase.ReKey(PreparePwd(oParams.NewPassword));
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalSetMeta;
begin
  inherited InternalSetMeta;
  if FDefaultCatalog = '' then
    FDefaultCatalog := 'MAIN';
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalDisconnect;
begin
  FDFreeAndNil(FDatabase);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalPing;
begin
  // nothing
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalExecuteDirect(const ASQL: String;
  ATransaction: TFDPhysTransaction);
var
  oStmt: TSQLiteStatement;
begin
  SetupForStmt(FOptions.UpdateOptions);
  oStmt := TSQLiteStatement.Create(FDatabase, Self);
  try
    oStmt.Prepare(ASQL);
    repeat
      oStmt.Execute;
    until not oStmt.PrepareNextCommand;
  finally
    FDFree(oStmt);
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.InternalChangePassword(const AUserName,
  AOldPassword, ANewPassword: String);
var
  oDB: TSQLiteDatabase;
begin
  if (FDatabase = nil) or (FDatabase.Handle = nil) then begin
    oDB := TSQLiteDatabase.Create(TFDPhysSQLiteDriver(DriverObj).FLib, Self);
    oDB.Open(ConnectionDef.Params.ExpandedDatabase, smReadWrite, scPrivate);
  end
  else
    oDB := FDatabase;
  try
    if AOldPassword <> '' then
      oDB.Key(PreparePwd(AOldPassword));
    oDB.ReKey(PreparePwd(ANewPassword));
  finally
    if FDatabase <> oDB then
      FDFree(oDB);
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.GetLastAutoGenValue(const AName: String): Variant;
begin
  if (FDatabase <> nil) and (AName = '') then
    Result := FDatabase.LastAutoGenValue
  else
    Result := inherited GetLastAutoGenValue(AName);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.GetItemCount: Integer;
begin
  Result := inherited GetItemCount;
  if DriverObj.State in [drsLoaded, drsActive] then begin
    Inc(Result, 3);
    if FDatabase <> nil then
      Inc(Result, 4);
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.GetItem(AIndex: Integer; out AName: String;
  out AValue: Variant; out AKind: TFDMoniAdapterItemKind);
var
  s, sDef: String;
  pOpt: PFDAnsiString;
  i, iLen: Integer;
begin
  if AIndex < inherited GetItemCount then
    inherited GetItem(AIndex, AName, AValue, AKind)
  else
    case AIndex - inherited GetItemCount of
    0:
      begin
        AName := 'DLL';
        AValue := TFDPhysSQLiteDriver(DriverObj).FLib.DLLName;
        AKind := ikClientInfo;
      end;
    1:
      begin
        AName := 'Client version';
        AValue := TFDEncoder.Deco(TFDPhysSQLiteDriver(DriverObj).FLib.Fsqlite3_libversion(), -1, ecANSI);
        AKind := ikClientInfo;
      end;
    2:
      begin
        if Assigned(TFDPhysSQLiteDriver(DriverObj).FLib.Fsqlite3_compileoption_get) then begin
          s := '';
          i := 0;
          iLen := 0;
          while True do begin
            pOpt := TFDPhysSQLiteDriver(DriverObj).FLib.Fsqlite3_compileoption_get(i);
            if pOpt = nil then
              Break;
            sDef := TFDEncoder.Deco(pOpt, -1, ecANSI);
            if iLen + Length(sDef) + 1 > 50 then begin
              s := s + C_FD_EOL + '  ';
              iLen := 0;
            end;
            s := s + sDef + ';';
            Inc(iLen, Length(sDef) + 1);
            Inc(i);
          end;
          s := Copy(s, 1, Length(s) - 1);
        end
        else
          s := '<unknown>';
        AName := 'Compile options';
        AValue := s;
        AKind := ikClientInfo;
      end;
    3:
      begin
        AName := 'Total changes';
        AValue := FDatabase.TotalChanges;
        AKind := ikSessionInfo;
      end;
    4:
      begin
        AName := 'Database encoding';
        AValue := FDatabase.CharacterSet;
        AKind := ikSessionInfo;
      end;
    5:
      begin
        AName := 'Encryption mode';
        AValue := FDatabase.Encryption;
        AKind := ikSessionInfo;
      end;
    6:
      begin
        AName := 'Cache size';
        AValue := FDatabase.CacheSize;
        AKind := ikSessionInfo;
      end;
    end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.GetMessages: EFDDBEngineException;
begin
  Result := nil;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.GetCliObj: Pointer;
begin
  Result := FDatabase;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalGetCliHandle: Pointer;
begin
  if FDatabase <> nil then
    Result := FDatabase.Handle
  else
    Result := nil;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteConnection.InternalGetCurrentCatalog: String;
begin
  Result := 'MAIN';
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteConnection.SetupForStmt(AUpdOptions: TFDUpdateOptions);
begin
  if (AUpdOptions <> nil) and AUpdOptions.LockWait then
    FDatabase.BusyTimeout := FBusyTimeout
  else
    FDatabase.BusyTimeout := 0;
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteTransaction                                                      }
{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalChanged;
var
  s: String;
begin
  if xoIsolation in GetOptions.Changed then begin
    if GetOptions.Isolation = xiDirtyRead then
      s := '1'
    else
      s := '0';
    TFDPhysSQLiteConnection(ConnectionObj).InternalExecuteDirect(
      'PRAGMA read_uncommitted = ' + s, Self);
  end;
  if xoReadOnly in GetOptions.Changed then begin
    if GetOptions.ReadOnly then
      s := '1'
    else
      s := '0';
    TFDPhysSQLiteConnection(ConnectionObj).InternalExecuteDirect(
      'PRAGMA query_only = ' + s, Self);
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalStartTransaction(ATxID: LongWord);
var
  sMode: String;
begin
  case GetOptions.Isolation of
  xiSnapshot:     sMode := 'IMMEDIATE';
  xiSerializible: sMode := 'EXCLUSIVE';
  else            sMode := 'DEFERRED';
  end;
  TFDPhysSQLiteConnection(ConnectionObj).InternalExecuteDirect(
    'BEGIN ' + sMode + ' TRANSACTION t_' + IntToStr(ATxID), Self);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalCommit(ATxID: LongWord);
begin
  TFDPhysSQLiteConnection(ConnectionObj).InternalExecuteDirect(
    'COMMIT TRANSACTION t_' + IntToStr(ATxID), Self);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalRollback(ATxID: LongWord);
begin
  DisconnectCommands(nil, dmRelease);
  TFDPhysSQLiteConnection(ConnectionObj).InternalExecuteDirect(
    'ROLLBACK TRANSACTION t_' + IntToStr(ATxID), Self);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalCheckState(ACommandObj: TFDPhysCommand;
  ASuccess: Boolean);
var
  lInTran: Boolean;
begin
  lInTran := TFDPhysSQLiteCommand(ACommandObj).SQLiteConnection.
    SQLiteDatabase.InTransaction;
  if GetActive <> lInTran then
    if lInTran then
      TransactionStarted
    else
      TransactionFinished;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteTransaction.InternalNotify(ANotification: TFDPhysTxNotification;
  ACommandObj: TFDPhysCommand);
begin
  if (ANotification = cpBeforeCmdExecute) and
     (TFDPhysSQLiteCommand(ACommandObj).GetCommandKind = skRollback) then
    DisconnectCommands(nil, dmRelease);
  inherited InternalNotify(ANotification, ACommandObj);
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteEventMessage                                                     }
{-------------------------------------------------------------------------------}
type
  TFDPhysSQLiteEventMessage = class(TFDPhysEventMessage)
  private
    FName: String;
    FParams: Variant;
  public
    constructor Create(const AName: String; const AParams: Variant);
  end;

{-------------------------------------------------------------------------------}
constructor TFDPhysSQLiteEventMessage.Create(const AName: String;
  const AParams: Variant);
begin
  inherited Create;
  FName := AName;
  FParams := AParams;
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLitePostEventFunc                                                    }
{-------------------------------------------------------------------------------}
constructor TFDPhysSQLitePostEventFunc.Create(ALib: TSQLiteLib);
begin
  inherited Create(ALib);
  Name := 'POST_EVENT';
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLitePostEventFunc.DoCalculate(AData: TSQLiteFunctionInstance);
var
  i, j: Integer;
  oConn: TFDPhysSQLiteConnection;
  sName: String;
  vParams, V: Variant;
  oInput: TSQLiteValue;
begin
  oConn := TFDPhysSQLiteConnection(AData.Database.OwningObj);
  sName := AData.Inputs.Inputs[0].AsString;
  vParams := Unassigned;
  for i := 0 to oConn.FEventList.Count - 1 do
    if TFDPhysSQLiteEventAlerter(oConn.FEventList[i]).GetNames.IndexOf(sName) >= 0 then begin
      if VarIsEmpty(vParams) then begin
        vParams := VarArrayCreate([0, AData.Inputs.Count - 2], varVariant);
        for j := 1 to AData.Inputs.Count - 1 do begin
          oInput := AData.Inputs[j];
          V := Unassigned;
          case AData.Inputs[j].ExtDataType of
          etUnknown,
          etString:   V := oInput.AsAnsiString;
          etUString:  V := oInput.AsWideString;
          etInteger:  V := oInput.AsInteger;
          etDouble:   V := oInput.AsFloat;
          etNumber:   V := VarFMTBcdCreate(oInput.AsNumber);
          etCurrency: V := oInput.AsCurrency;
          etBlob:     V := oInput.AsAnsiString;
          etBoolean:  V := oInput.AsBoolean;
          etDate:     V := oInput.AsDate;
          etTime:     V := oInput.AsTime;
          etDateTime: V := oInput.AsDateTime;
          end;
          vParams[j - 1] := V;
        end;
      end;
      if TThread.CurrentThread.ThreadID = MainThreadID then
        CheckSynchronize();
      TFDPhysSQLiteEventAlerter(oConn.FEventList[i]).FMsgThread.EnqueueMsg(
        TFDPhysSQLiteEventMessage.Create(sName, vParams));
    end;
end;

{-------------------------------------------------------------------------------}
class procedure TFDPhysSQLitePostEventFunc.Register(ALib: TSQLiteLib);
var
  i: Integer;
begin
  for i := 0 to 4 do
    TFDPhysSQLitePostEventFunc.Create(ALib).Args := 1 + i;
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteEventAlerter                                                     }
{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteEventAlerter.InternalHandle(AEventMessage: TFDPhysEventMessage);
var
  oMsg: TFDPhysSQLiteEventMessage;
begin
  oMsg := TFDPhysSQLiteEventMessage(AEventMessage);
  InternalHandleEvent(oMsg.FName, oMsg.FParams);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteEventAlerter.InternalSignal(const AEvent: String;
  const AArgument: Variant);
var
  sCmd: String;
  oCmd: IFDPhysCommand;
begin
  GetConnection.CreateCommand(oCmd);
  SetupCommand(oCmd);
  sCmd := 'SELECT POST_EVENT(' + QuotedStr(AEvent);
  if not VarIsEmpty(AArgument) then
    sCmd := sCmd + ', ' + QuotedStr(VarToStr(AArgument));
  sCmd := sCmd + ')';
  oCmd.Prepare(sCmd);
  oCmd.Open(True);
end;

{-------------------------------------------------------------------------------}
{ TFDPhysSQLiteCommand                                                          }
{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.GetConnection: TFDPhysSQLiteConnection;
begin
  Result := TFDPhysSQLiteConnection(FConnectionObj);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.GetCliObj: Pointer;
begin
  Result := FStmt;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.SetupStatement(AStmt: TSQLiteStatement);
var
  oFmtOpts: TFDFormatOptions;
begin
  oFmtOpts := FOptions.FormatOptions;
  if GetMetaInfoKind <> mkNone then begin
    AStmt.StrsTrim := True;
    AStmt.StrsEmpty2Null := True;
    AStmt.MaxStringSize := C_FD_DefMaxStrSize;
    AStmt.UseColumnMetadata := False;
  end
  else begin
    AStmt.StrsTrim := oFmtOpts.StrsTrim;
    AStmt.StrsEmpty2Null := oFmtOpts.StrsEmpty2Null;
    AStmt.MaxStringSize := oFmtOpts.MaxStringSize;
    // No need to control the UseColumnMetadata by a conndef option. The
    // sqlite3_table_column_metadata is faster, than mkPrimaryKeyFields.
    AStmt.UseColumnMetadata := fiMeta in FOptions.FetchOptions.Items;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.InternalPrepare;
var
  rName: TFDPhysParsedName;
begin
  FStatementProps := [];

  // generate metadata SQL command
  if GetMetaInfoKind <> FireDAC.Phys.Intf.mkNone then begin
    GetSelectMetaInfoParams(rName);
    GenerateSelectMetaInfo(rName);
    if FDbCommandText = '' then
      Exit;
  end

  // generate metadata SQL command
  else if GetCommandKind in [skStoredProc, skStoredProcWithCrs, skStoredProcNoCrs] then
    FDCapabilityNotSupported(Self, [S_FD_LPhys, S_FD_SQLiteId]);

  // adjust SQL command
  if GetMetaInfoKind = FireDAC.Phys.Intf.mkNone then
    GenerateLimitSelect();
  GenerateParamMarkers();

  FStmt := TSQLiteStatement.Create(SQLiteConnection.FDatabase, Self);
  SetupStatement(FStmt);
  FStmt.Prepare(FDbCommandText);
  if FStmt.MoreCommands then
    Include(FStatementProps, cpBatch)
  else
    // for a single command create cached parameter infos at prepare
    CreateParamInfos;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.InternalUnprepare;
begin
  if FStmt = nil then
    Exit;
  FPreparedBatchSize := 0;
  FStmt.Unprepare;
  DestroyColInfos;
  DestroyParamInfos;
  FDFreeAndNil(FStmt);
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.FD2SQLDataType(ADataType: TFDDataType): TSQLiteExtDataType;
begin
  if ADataType = dtGUID then
    Result := SQLiteConnection.FGuidFormat
  else
    Result := C_FD_Type2SQLDataType[ADataType];
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.SQL2FDDataType(ADataType: TSQLiteExtDataType;
  AUnsigned: Boolean): TFDDataType;
begin
  Result := C_FD_SQLDataType2Type[ADataType];
  if AUnsigned and (Result = dtInt64) then
    Result := dtUInt64;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.CreateParamInfos;
var
  i: Integer;
  oDef: TSQLiteValueDef;
  pInfo: PFDSQLiteVarInfoRec;
  oParams: TFDParams;
  oParam: TFDParam;
  oFmtOpts: TFDFormatOptions;
  eDestFldType: TFieldType;
begin
  oParams := GetParams;
  if (oParams.Count = 0) or (FStmt = nil) then
    Exit;

  oFmtOpts := FOptions.FormatOptions;

  SetLength(FParInfos, FStmt.ParamDefsCount);
  for i := 0 to Length(FParInfos) - 1 do begin
    oDef := FStmt.ParamDefs[i];
    pInfo := @FParInfos[i];
    try
      case GetParams.BindMode of
      pbByName:
        begin
          pInfo^.FName := oDef.Name;
          oParam := oParams.FindParam(Copy(pInfo^.FName, 2, Length(pInfo^.FName)));
        end;
      pbByNumber:
        begin
          pInfo^.FName := '';
          oParam := oParams.FindParam(FStmt.BaseParamIndex + oDef.Index + 1);
        end;
      else
        oParam := nil;
      end;
      if oParam = nil then begin
        pInfo^.FPos := -1;
        Continue;
      end;

      pInfo^.FPos := oParam.Index;

      if oParam.ParamType = ptUnknown then
        oParam.ParamType := ptInput;
      if not (oParam.ParamType in [ptUnknown, ptInput]) then
        FDCapabilityNotSupported(Self, [S_FD_LPhys, S_FD_SQLiteId]);
      pInfo^.FParamType := oParam.ParamType;

      pInfo^.FSrcFieldType := oParam.DataType;
      if oParam.DataType = ftUnknown then
        ParTypeUnknownError(oParam);
      oFmtOpts.ResolveFieldType('', oParam.DataTypeName, oParam.DataType,
        oParam.FDDataType, oParam.Size, oParam.Precision, oParam.NumericScale,
        eDestFldType, pInfo^.FSize, pInfo^.FPrec, pInfo^.FScale,
        pInfo^.FSrcDataType, pInfo^.FDestDataType, False);
      pInfo^.FOutSQLDataType := FD2SQLDataType(pInfo^.FDestDataType);
      pInfo^.FOutDataType := SQL2FDDataType(pInfo^.FOutSQLDataType,
        pInfo^.FDestDataType in C_FD_NumUnsignedTypes);

      pInfo^.FVar := TSQLiteBind.Create(FStmt.Params);
      pInfo^.FVar.ExtDataType := pInfo^.FOutSQLDataType;
    finally
      FDFree(oDef);
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.DestroyParamInfos;
begin
  SetLength(FParInfos, 0);
  if FStmt <> nil then
    FStmt.Params.Clear;
end;

{-------------------------------------------------------------------------------}
procedure FDSQLiteTypeName2ADDataType(const AOptions: IFDStanOptions;
  const AColName, ATypeName: String; out ABaseColName, ABaseTypeName: String;
  out AType: TFDDataType; out AAttrs: TFDDataAttributes; out ALen: LongWord;
  out APrec, AScale: Integer);
const
  C_TypeDelim = '::';
var
  i1, i2: Integer;
  sTypeName, sBaseColName, sArgs, sMod: String;
  oFmt: TFDFormatOptions;

  procedure SetPrecScale(ADefPrec, ADefScale: Integer);
  var
    sPrec, sScale: String;
    i: Integer;
  begin
    i := Pos(',', sArgs);
    if i = 0 then
      sPrec := sArgs
    else begin
      sPrec := Copy(sArgs, 1, i - 1);
      sScale := Copy(sArgs, i + 1, Length(sArgs));
    end;
    APrec := StrToIntDef(sPrec, ADefPrec);
    AScale := StrToIntDef(sScale, ADefScale);
  end;

  procedure SetLen(ADefLen: Integer; AAdjustUTF8: Boolean);
  begin
    ALen := StrToIntDef(sArgs, ADefLen);
  end;

begin
  AType := dtUnknown;
  AAttrs := [caSearchable];
  ALen := 0;
  APrec := 0;
  AScale := 0;

  i1 := Pos(C_TypeDelim, AColName);
  if i1 = 0 then begin
    sTypeName := ATypeName;
    ABaseColName := AColName;
  end
  else begin
    sTypeName := Copy(AColName, i1 + Length(C_TypeDelim), MAXINT);
    ABaseColName := Copy(AColName, 1, i1 - 1);
  end;

  i1 := Pos(C_FD_SysColumnPrefix, ABaseColName);
  if i1 <> 0 then
    sBaseColName := Copy(ABaseColName, Length(C_FD_SysColumnPrefix) + 1, MAXINT)
  else
    sBaseColName := ABaseColName;

  i1 := Pos('(', sTypeName);
  i2 := Pos(')', sTypeName);
  if i1 = 0 then begin
    ABaseTypeName := Trim(UpperCase(sTypeName));
    sArgs := '';
  end
  else begin
    ABaseTypeName := Trim(UpperCase(Copy(sTypeName, 1, i1 - 1)));
    sArgs := Trim(Copy(sTypeName, i1 + 1, i2 - i1 - 1));
  end;
  i1 := Pos(' ', ABaseTypeName);
  if i1 = 0 then
    sMod := ''
  else begin
    sMod := Trim(Copy(ABaseTypeName, i1 + 1, Length(ABaseTypeName)));
    ABaseTypeName := Copy(ABaseTypeName, 1, i1 - 1);
    if (ABaseTypeName = 'UNSIGNED') and (sMod <> '') then begin
      ABaseTypeName := sMod;
      sMod := 'UNSIGNED';
    end;
  end;

  if ((CompareText(sBaseColName, 'ROWID') = 0) or
      (CompareText(sBaseColName, '_ROWID_') = 0) or
      (CompareText(sBaseColName, 'OID') = 0)) and
     (ABaseTypeName = 'INTEGER') then begin
    AType := dtInt64;
    AAttrs := AAttrs + [caAllowNull, caROWID, caAutoInc];
  end
  else if (ABaseTypeName = 'BIT') or (ABaseTypeName = 'BOOL') or (ABaseTypeName = 'BOOLEAN') or
     (ABaseTypeName = 'LOGICAL') or (ABaseTypeName = 'YESNO') then
    AType := dtBoolean
  else if (ABaseTypeName = 'TINYINT') or (ABaseTypeName = 'SHORTINT') or (ABaseTypeName = 'INT8') then
    if sMod = 'UNSIGNED' then
      AType := dtByte
    else
      AType := dtSByte
  else if (ABaseTypeName = 'BYTE') or (ABaseTypeName = 'UINT8') then
    AType := dtByte
  else if (ABaseTypeName = 'SMALLINT') or (ABaseTypeName = 'INT16') then
    if sMod = 'UNSIGNED' then
      AType := dtUInt16
    else
      AType := dtInt16
  else if (ABaseTypeName = 'WORD') or (ABaseTypeName = 'UINT16') or (ABaseTypeName = 'YEAR') then
    AType := dtUInt16
  else if (ABaseTypeName = 'MEDIUMINT') or (ABaseTypeName = 'INTEGER') or (ABaseTypeName = 'INT') or (ABaseTypeName = 'INT32') then
    if sMod = 'UNSIGNED' then
      AType := dtUInt32
    else
      AType := dtInt32
  else if (ABaseTypeName = 'LONGWORD') or (ABaseTypeName = 'UINT32') then
    AType := dtUInt32
  else if (ABaseTypeName = 'BIGINT') or (ABaseTypeName = 'INT64') or
          (ABaseTypeName = 'COUNTER') or (ABaseTypeName = 'AUTOINCREMENT') or (ABaseTypeName = 'IDENTITY') then
    if sMod = 'UNSIGNED' then
      AType := dtUInt64
    else
      AType := dtInt64
  else if (ABaseTypeName = 'LONGLONGWORD') or (ABaseTypeName = 'UINT64') then
    AType := dtUInt64
  else if (ABaseTypeName = 'FLOAT') or (ABaseTypeName = 'REAL') or
          ((ABaseTypeName = 'DOUBLE') or (ABaseTypeName = 'SINGLE')) and ((sMod = '') or (sMod = 'PRECISION')) then begin
    SetPrecScale(0, 0);
    if APrec > 16 then begin
      oFmt := AOptions.FormatOptions;
      if oFmt.IsFmtBcd(APrec, AScale) then
        AType := dtFmtBCD
      else
        AType := dtBCD;
    end
    else if ABaseTypeName = 'SINGLE' then
      AType := dtSingle
    else
      AType := dtDouble;
  end
  else if (ABaseTypeName = 'DECIMAL') or (ABaseTypeName = 'DEC') or (ABaseTypeName = 'NUMERIC') or (ABaseTypeName = 'NUMBER') then begin
    SetPrecScale(10, 0);
    if AScale = 0 then
      if sMod = 'UNSIGNED' then begin
        if APrec <= 3 then
          AType := dtByte
        else if APrec <= 5 then
          AType := dtUInt16
        else if APrec <= 10 then
          AType := dtUInt32
        else if APrec <= 21 then
          AType := dtUInt64;
      end
      else begin
        if APrec <= 2 then
          AType := dtSByte
        else if APrec <= 4 then
          AType := dtInt16
        else if APrec <= 9 then
          AType := dtInt32
        else if APrec <= 20 then
          AType := dtInt64;
      end;
    if AType = dtUnknown then begin
      oFmt := AOptions.FormatOptions;
      if oFmt.IsFmtBcd(APrec, AScale) then
        AType := dtFmtBCD
      else
        AType := dtBCD;
    end;
  end
  else if (ABaseTypeName = 'MONEY') or (ABaseTypeName = 'SMALLMONEY') or (ABaseTypeName = 'CURRENCY') or
          (ABaseTypeName = 'FINANCIAL') then begin
    SetPrecScale(19, 4);
    AType := dtCurrency;
  end
  else if (ABaseTypeName = 'DATE') or (ABaseTypeName = 'SMALLDATE') then
    AType := dtDate
  else if (ABaseTypeName = 'DATETIME') or (ABaseTypeName = 'SMALLDATETIME') then
    AType := dtDateTime
  else if ABaseTypeName = 'TIMESTAMP' then
    AType := dtDateTimeStamp
  else if ABaseTypeName = 'TIME' then
    AType := dtTime
  else if ABaseTypeName = 'INTERVAL' then
    AType := dtTimeIntervalFull
  else if ((ABaseTypeName = 'CHAR') or (ABaseTypeName = 'CHARACTER')) and (sMod = '') then begin
    SetLen(AOptions.FormatOptions.MaxStringSize, False);
    AType := dtAnsiString;
    Include(AAttrs, caFixedLen);
  end
  else if (ABaseTypeName = 'VARCHAR') or (ABaseTypeName = 'VARCHAR2') or (ABaseTypeName = 'TYNITEXT') or
          ((ABaseTypeName = 'CHARACTER') or (ABaseTypeName = 'CHAR')) and (sMod = 'VARYING') then begin
    SetLen(AOptions.FormatOptions.MaxStringSize, False);
    AType := dtAnsiString;
  end
  else if (ABaseTypeName = 'NCHAR') or (ABaseTypeName = 'NATIONAL') and (
          (sMod = 'CHAR') or (sMod = 'CHARACTER')) then begin
    SetLen(1, True);
    AType := dtWideString;
    Include(AAttrs, caFixedLen);
  end
  else if (ABaseTypeName = 'NVARCHAR') or (ABaseTypeName = 'NVARCHAR2') or (ABaseTypeName = 'NATIONAL') and (
            (sMod = 'CHAR VARYING') or (sMod = 'CHARACTER VARYING') or
            (sMod = 'VARYING CHAR') or (sMod = 'VARYING CHARACTER')) or
          (ABaseTypeName = 'STRING') then begin
    SetLen(AOptions.FormatOptions.MaxStringSize, True);
    AType := dtWideString;
  end
  else if (ABaseTypeName = 'RAW') or (ABaseTypeName = 'TYNIBLOB') or (ABaseTypeName = 'VARBINARY') or
          (ABaseTypeName = 'BINARY') and ((sMod = '') or (sMod = 'VARYING')) then begin
    SetLen(AOptions.FormatOptions.MaxStringSize, False);
    AType := dtByteString;
    if (ABaseTypeName = 'BINARY') and (sMod = '') then
      Include(AAttrs, caFixedLen);
  end
  else if (ABaseTypeName = 'BLOB') or (ABaseTypeName = 'MEDIUMBLOB') or (ABaseTypeName = 'LONGBLOB') or
          (ABaseTypeName = 'GENERAL') or (ABaseTypeName = 'LONG') and ((sMod = 'BINARY') or (sMod = 'RAW')) or
          (ABaseTypeName = 'LONGVARBINARY') or (ABaseTypeName = 'OLEOBJECT') or (ABaseTypeName = 'TINYBLOB') or
          (ABaseTypeName = 'IMAGE') or (ABaseTypeName = 'GRAPHIC') or (ABaseTypeName = 'PICTURE') or
          (ABaseTypeName = 'PHOTO') then begin
    SetLen(0, False);
    if (ALen > 0) and (ALen < AOptions.FormatOptions.MaxStringSize) then
      AType := dtByteString
    else begin
      // SQLite allows to use BLOB in WHERE
      // Exclude(AAttrs, caSearchable);
      Include(AAttrs, caBlobData);
      AType := dtBlob;
    end;
  end
  else if (ABaseTypeName = 'MEDIUMTEXT') or (ABaseTypeName = 'LONGTEXT') or
          (ABaseTypeName = 'CLOB') or (ABaseTypeName = 'MEMO') or (ABaseTypeName = 'NOTE') or
          (ABaseTypeName = 'LONG') and ((sMod = '') or (sMod = 'TEXT')) or
          (ABaseTypeName = 'LONGCHAR') or (ABaseTypeName = 'LONGVARCHAR') or (ABaseTypeName = 'TINYTEXT') then begin
    SetLen(0, False);
    if (ALen > 0) and (ALen < AOptions.FormatOptions.MaxStringSize) then
      AType := dtAnsiString
    else begin
      // SQLite allows to use CLOB in WHERE
      // Exclude(AAttrs, caSearchable);
      Include(AAttrs, caBlobData);
      AType := dtMemo;
    end;
  end
  else if (ABaseTypeName = 'TEXT') or (ABaseTypeName = 'NTEXT') or (ABaseTypeName = 'WTEXT') or
          (ABaseTypeName = 'NCLOB') or (ABaseTypeName = 'NMEMO') or
          (ABaseTypeName = 'LONG') and ((sMod = 'NTEXT') or (sMod = 'WTEXT')) or
          (ABaseTypeName = 'NATIONAL') and (sMod = 'TEXT') or
          (ABaseTypeName = 'LONGWCHAR') or (ABaseTypeName = 'LONGWVARCHAR') or
          (ABaseTypeName = 'HTML') then begin
    SetLen(0, True);
    if (ALen > 0) and (ALen <= AOptions.FormatOptions.MaxStringSize) then
      AType := dtWideString
    else begin
      // SQLite allows to use NCLOB in WHERE
      // Exclude(AAttrs, caSearchable);
      Include(AAttrs, caBlobData);
      AType := dtWideMemo;
    end;
  end
  else if (ABaseTypeName = 'XMLDATA') or (ABaseTypeName = 'XMLTYPE') or (ABaseTypeName = 'XML') then begin
    // SQLite allows to use XML in WHERE
    // Exclude(AAttrs, caSearchable);
    Include(AAttrs, caBlobData);
    AType := dtXML;
  end
  else if (ABaseTypeName = 'GUID') or (ABaseTypeName = 'UNIQUEIDENTIFIER') then
    AType := dtGUID
  else begin
    SetLen(AOptions.FormatOptions.MaxStringSize, True);
    AType := dtWideString;
  end
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.TypeName2ADDataType(const AColName, ATypeName: String;
  out ABaseColName, ABaseTypeName: String; out AType: TFDDataType;
  out AAttrs: TFDDataAttributes; out ALen: LongWord; out APrec, AScale: Integer);
begin
  FDSQLiteTypeName2ADDataType(FOptions, AColName, ATypeName, ABaseColName,
    ABaseTypeName, AType, AAttrs, ALen, APrec, AScale);
  case SQLiteConnection.FStringFormat of
  etUString:
    case AType of
    dtAnsiString: AType := dtWideString;
    dtMemo:       AType := dtWideMemo;
    dtHMemo:      AType := dtWideHMemo;
    end;
  etString:
    case AType of
    dtWideString: AType := dtAnsiString;
    dtWideMemo:   AType := dtMemo;
    dtWideHMemo:  AType := dtHMemo;
    dtXML:        AType := dtMemo;
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.CreateColInfos;
var
  i: Integer;
  oDef: TSQLiteValueDef;
  pInfo: PFDSQLiteVarInfoRec;
  oFmtOpts: TFDFormatOptions;
  sName, sType: String;
begin
  oFmtOpts := FOptions.FormatOptions;
  SetLength(FColInfos, FStmt.ColumnDefsCount);
  for i := 0 to Length(FColInfos) - 1 do begin
    oDef := FStmt.ColumnDefs[i];
    pInfo := @FColInfos[i];
    try
      TypeName2ADDataType(oDef.Name, oDef.TypeName, sName, sType, pInfo^.FSrcDataType,
        pInfo^.FAttrs, pInfo^.FSize, pInfo^.FPrec, pInfo^.FScale);

      pInfo^.FName := sName;
      pInfo^.FOriginDBName := oDef.DBName;
      pInfo^.FOriginTabName := oDef.TabName;
      pInfo^.FOriginColName := oDef.ColName;
      pInfo^.FSrcTypeName := oDef.TypeName;
      pInfo^.FPos := i + 1;

      if not oDef.NotNull then
        Include(pInfo^.FAttrs, caAllowNull);
      if oDef.AutoInc then
        Include(pInfo^.FAttrs, caAutoInc);
      if oDef.InPrimaryKey then
        pInfo^.FOpts := [coInKey]
      else
        pInfo^.FOpts := [];

      // mapping data types
      if GetMetaInfoKind = mkNone then
        oFmtOpts.ResolveDataType(pInfo^.FName, pInfo^.FSrcTypeName,
          pInfo^.FSrcDataType, pInfo^.FSize, pInfo^.FPrec, pInfo^.FScale,
          pInfo^.FDestDataType, pInfo^.FSize, True)
      else
        pInfo^.FDestDataType := pInfo^.FSrcDataType;
      pInfo^.FOutSQLDataType := FD2SQLDataType(pInfo^.FDestDataType);
      pInfo^.FOutDataType := SQL2FDDataType(pInfo^.FOutSQLDataType,
        pInfo^.FDestDataType in C_FD_NumUnsignedTypes);

      if CheckFetchColumn(pInfo^.FSrcDataType, pInfo^.FAttrs) then begin
        pInfo^.FVar := TSQLiteColumn.Create(FStmt.Columns);
        pInfo^.FVar.ExtDataType := pInfo^.FOutSQLDataType;
        pInfo^.FVar.Index := oDef.Index;
      end
      else
        pInfo^.FVar := nil;
    finally
      FDFree(oDef);
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.DestroyColInfos;
begin
  SetLength(FColInfos, 0);
  if FStmt <> nil then
    FStmt.Columns.Clear;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalUseStandardMetadata: Boolean;
begin
  Result := not ((FStmt <> nil) and
    Assigned(FStmt.Lib.Fsqlite3_column_database_name) and
    Assigned(FStmt.Lib.Fsqlite3_table_column_metadata));
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean;
begin
  Result := OpenBlocked;
  if ATabInfo.FSourceID = -1 then begin
    ATabInfo.FSourceName := GetCommandText;
    ATabInfo.FSourceID := 1;
    FColumnIndex := 0;
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean;
var
  pColInfo: PFDSQLiteVarInfoRec;
begin
  if FColumnIndex < Length(FColInfos) then begin
    pColInfo := @FColInfos[FColumnIndex];
    AColInfo.FSourceName := pColInfo^.FName;
    AColInfo.FSourceID := pColInfo^.FPos;
    AColInfo.FSourceType := pColInfo^.FSrcDataType;
    AColInfo.FSourceTypeName := pColInfo^.FSrcTypeName;
    AColInfo.FOriginTabName.FCatalog := pColInfo^.FOriginDBName;
    AColInfo.FOriginTabName.FObject := pColInfo^.FOriginTabName;
    AColInfo.FOriginColName := pColInfo^.FOriginColName;
    AColInfo.FType := pColInfo^.FDestDataType;
    AColInfo.FLen := pColInfo^.FSize;
    AColInfo.FPrec := pColInfo^.FPrec;
    AColInfo.FScale := pColInfo^.FScale;
    AColInfo.FAttrs := pColInfo^.FAttrs;
    AColInfo.FForceAddOpts := pColInfo^.FOpts;
    Inc(FColumnIndex);
    Result := True;
  end
  else
    Result := False;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.SetParamValue(AFmtOpts: TFDFormatOptions;
  AParam: TFDParam; AVar: TSQLiteStmtVar; ApInfo: PFDSQLiteVarInfoRec;
  AParIndex: Integer);
var
  pData: PByte;
  iSize, iSrcSize: LongWord;
  oStr: TStream;
begin
  pData := nil;
  iSize := 0;

  // null
  if AParam.IsNulls[AParIndex] then
    AVar.SetData(nil, 0)

  // assign BLOB stream
  else if AParam.IsStreams[AParIndex] then begin
    oStr := AParam.AsStreams[AParIndex];
    if (oStr = nil) or (oStr.Size < 0) then
      UnsupParamObjError(AParam);
    iSize := oStr.Size;
    FBuffer.Check(iSize);
    oStr.Position := 0;
    oStr.Read(FBuffer.Ptr^, iSize);
    AVar.SetData(FBuffer.Ptr, iSize);
  end

  // conversion is not required
  else if ApInfo^.FOutDataType = ApInfo^.FSrcDataType then begin



    if ApInfo^.FOutSQLDataType in [{$IFNDEF NEXTGEN} etString, {$ENDIF} etUString, etBlob] then begin
      AParam.GetBlobRawData(iSize, pData, AParIndex);
      AVar.SetData(pData, iSize);
    end

    else begin
      iSize := AParam.GetDataLength(AParIndex);
      FBuffer.Check(iSize);
      AParam.GetData(FBuffer.Ptr, AParIndex);
      AVar.SetData(FBuffer.Ptr, iSize);
    end;
  end

  // conversion is required
  else begin
    // calculate buffer size to move param values
    iSrcSize := AParam.GetDataLength(AParIndex);
    FBuffer.Extend(iSrcSize, iSize, ApInfo^.FSrcDataType, ApInfo^.FOutDataType);

    // get, convert and set parameter value
    AParam.GetData(FBuffer.Ptr, AParIndex);
    AFmtOpts.ConvertRawData(ApInfo^.FSrcDataType, ApInfo^.FOutDataType,
      FBuffer.Ptr, iSrcSize, FBuffer.FBuffer, FBuffer.Size, iSize,
      SQLiteConnection.FDatabase.Encoder);

    AVar.SetData(FBuffer.Ptr, iSize);
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.SetParamValues(ABatchSize, AOffset: Integer);
var
  oParams: TFDParams;
  oFmtOpts: TFDFormatOptions;
  oParam: TFDParam;
  oSqParam: TSQLiteStmtVar;
  iParamsCount, i, j: Integer;
  pParInfo: PFDSQLiteVarInfoRec;
begin
  oParams := GetParams;
  if oParams.Count = 0 then
    Exit;

  oFmtOpts := GetOptions.FormatOptions;
  iParamsCount := Length(FParInfos);
  for i := 0 to Length(FParInfos) - 1 do begin
    pParInfo := @FParInfos[i];
    if pParInfo^.FPos <> -1 then begin
      oParam := oParams[pParInfo^.FPos];
      if (pParInfo^.FVar <> nil) and
         (oParam.DataType <> ftCursor) and
         (oParam.ParamType in [ptInput, ptInputOutput, ptUnknown]) then
        CheckParamMatching(oParam, pParInfo^.FSrcFieldType, pParInfo^.FParamType, 0);
        for j := 0 to ABatchSize - 1 do begin
          if j = 0 then
            oSqParam := pParInfo^.FVar
          else
            oSqParam := FStmt.Params[j * iParamsCount + pParInfo^.FPos];
          SetParamValue(oFmtOpts, oParam, oSqParam, pParInfo, j + AOffset);
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.ExecuteBatchInsert(ATimes, AOffset: Integer;
  var ACount: TFDCounter);
var
  sBatchSQL: String;
  iBatchSQLPos: Integer;

  procedure W(const AStr: String);
  var
    iLen: Integer;
  begin
    iLen := Length(AStr);
    if iBatchSQLPos + iLen > Length(sBatchSQL) then
      SetLength(sBatchSQL, Length(sBatchSQL) * 2);
    Move(PChar(AStr)^, (PChar(sBatchSQL) + iBatchSQLPos)^, iLen * SizeOf(Char));
    Inc(iBatchSQLPos, iLen);
  end;

  procedure C(AIndex, ACount: Integer);
  begin
    if iBatchSQLPos + ACount > Length(sBatchSQL) then
      SetLength(sBatchSQL, Length(sBatchSQL) * 2);
    Move((PChar(FDBCommandText) + AIndex)^, (PChar(sBatchSQL) + iBatchSQLPos)^, ACount * SizeOf(Char));
    Inc(iBatchSQLPos, ACount);
  end;

var
  oParams: TFDParams;
  iParamsCount: Integer;
  oSqParam: TSQLiteStmtVar;
  oSrcSqParam: TSQLiteStmtVar;
  i, j: Integer;
  lIsQuest: Boolean;
  lIsParam: Boolean;
  iQuestPos: Integer;
  aParamsPos: array of Integer;
  iBatchParamInd: Integer;
  iMaxSize, iBatchSize, iCurTimes, iCurOffset: Integer;
begin
  oParams := GetParams;
  iParamsCount := Length(FParInfos);

  iBatchSize := ATimes - AOffset;
  iMaxSize := SQLiteConnection.FDatabase.Limits[SQLITE_LIMIT_VARIABLE_NUMBER] div iParamsCount;
  if iBatchSize > iMaxSize then
    iBatchSize := iMaxSize;
  iMaxSize := GetOptions.ResourceOptions.ArrayDMLSize;
  if (iMaxSize <> $7FFFFFFF) and (iBatchSize > iMaxSize) then
    iBatchSize := iMaxSize;

  iCurOffset := AOffset;
  iCurTimes := AOffset + iBatchSize;
  while iCurOffset < ATimes do begin
    if iCurTimes > ATimes then begin
      iCurTimes := ATimes;
      iBatchSize := iCurTimes - iCurOffset;
    end;

    if not CheckArray(iBatchSize) then begin
      lIsQuest := False;
      lIsParam := False;
      iQuestPos := 1;
      i := FSQLValuesPos;
      j := 1;
      SetLength(aParamsPos, oParams.Count * 2 + 2);
      aParamsPos[0] := FSQLValuesPos + 5;
      while i <= FSQLValuesPosEnd do begin
        case FDBCommandText[i] of
        '?':
          begin
            lIsQuest := True;
            iQuestPos := i;
          end;
        '0'..'9':
          lIsParam := lIsQuest;
        else
          if lIsParam then begin
            aParamsPos[j] := iQuestPos - 2;
            aParamsPos[j + 1] := i - 1;
            Inc(j, 2);
          end;
          lIsQuest := False;
          lIsParam := False;
        end;
        Inc(i);
      end;
      ASSERT(j = Length(aParamsPos) - 1);
      aParamsPos[j] := FSQLValuesPosEnd - 1;

      iBatchSQLPos := 0;
      iBatchParamInd := 1;
      SetLength(sBatchSQL, 16384);
      C(0, FSQLValuesPos + 5);
      for j := 0 to iBatchSize - 1 do begin
        if j > 0 then
          W(',');
        C(aParamsPos[0], aParamsPos[1] - aParamsPos[0] + 1);
        for i := 1 to Length(aParamsPos) div 2 - 1 do begin
          W('?');
          W(IntToStr(iBatchParamInd));
          C(aParamsPos[i * 2], aParamsPos[i * 2 + 1] - aParamsPos[i * 2] + 1);
          Inc(iBatchParamInd);
        end;
      end;
      C(FSQLValuesPosEnd, Length(FDBCommandText) - FSQLValuesPosEnd);
      SetLength(sBatchSQL, iBatchSQLPos);

      FStmt.Unprepare;
      FStmt.Params.Clear(iParamsCount);
      for i := 1 to iBatchSize - 1 do
        for j := 0 to iParamsCount - 1 do begin
          oSrcSqParam := FStmt.Params[j];
          oSqParam := TSQLiteBind.Create(FStmt.Params);
          oSqParam.ExtDataType := oSrcSqParam.ExtDataType;
        end;
      FStmt.Prepare(sBatchSQL);
    end;

    FStmt.Rewind;
    SetParamValues(iBatchSize, iCurOffset);
    try
      FStmt.Execute;
    finally
      Inc(ACount, FStmt.Changes);
    end;

    Inc(iCurOffset, iBatchSize);
    Inc(iCurTimes, iBatchSize);
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.CheckArray(ASize: Integer): Boolean;
begin
  Result := (ASize = 1) and (FPreparedBatchSize <= 1) or
            (ASize = FPreparedBatchSize);
  if not Result then begin
    FStmt.Unprepare;
    FPreparedBatchSize := ASize;
    if ASize = 1 then begin
      FStmt.Params.Clear(Length(FParInfos));
      FStmt.Prepare(FDBCommandText);
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.InternalExecute(ATimes, AOffset: Integer;
  var ACount: TFDCounter);
var
  i, iChanges: Integer;
begin
  SQLiteConnection.SetupForStmt(FOptions.UpdateOptions);
  ACount := 0;
  try
    if (ATimes - AOffset > 1) and
       (TFDPhysSQLiteDriver(SQLiteConnection.DriverObj).FLib.Version >= svSQLite030711) and
       (GetCommandKind in [skInsert, skMerge]) and not (cpBatch in FStatementProps) and
       (FSQLValuesPos > 0) and (GetParams.BindMode = pbByNumber) then
      ExecuteBatchInsert(ATimes, AOffset, ACount)

    else begin
      CheckArray(1);
      for i := AOffset to ATimes - 1 do begin
        FStmt.Rewind;
        Exclude(FStatementProps, cpOnNextResult);
        if cpBatch in FStatementProps then begin
          DestroyColInfos;
          DestroyParamInfos;
          CreateParamInfos;
        end;
        SetParamValues(1, i);
        try
          try
            FStmt.Execute;
          finally
            iChanges := FStmt.Changes;
            Inc(ACount, iChanges);
          end;
          CheckExact(ATimes = 1, 1, 0, iChanges, False);
          if (cpBatch in FStatementProps) and (GetState <> csAborting) and
             (FStmt.ColumnDefsCount = 0) then begin
            Include(FStatementProps, cpOnNextResult);
            if GetCursor(i) then
              Include(FStatementProps, cpOnNextResultValue)
            else
              Exclude(FStatementProps, cpOnNextResultValue);
          end;
        except
          on E: EFDDBEngineException do begin
            E[0].RowIndex := i;
            raise;
          end;
        end;
      end;
    end;
  finally
    FStmt.Clear;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.InternalAbort;
begin
  if (FStmt <> nil) and (SQLiteConnection.SQLiteDatabase <> nil) then
    SQLiteConnection.SQLiteDatabase.Interrupt;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.GetCursor(AOffset: Integer): Boolean;
begin
  if cpBatch in FStatementProps then
    while (FStmt.ColumnDefsCount = 0) and
          (GetState <> csAborting) and
          FStmt.MoreCommands and FStmt.PrepareNextCommand do begin
      if FStmt.ParamDefsCount > 0 then begin
        DestroyParamInfos;
        CreateParamInfos;
        SetParamValues(1, AOffset);
      end;
      FStmt.Execute;
    end;
  Result := FStmt.ColumnDefsCount > 0;
  if Result and (FStmt.Columns.Count = 0) then
    CreateColInfos;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalOpen(var ACount: TFDCounter): Boolean;
begin
  ACount := 0;
  if (GetMetaInfoKind <> mkNone) and (FDbCommandText = '') then begin
    Result := False;
    Exit;
  end
  else if (FStmt <> nil) and not (FStmt.State in [ssInactive, ssPrepared,
                                                  ssRewinded, ssExecuted]) then begin
    Result := True;
    Exit;
  end
  else begin
    CheckArray(1);
    if GetNextRecordSet then
      FStmt.Reset
    else
      FStmt.Rewind;
    if cpBatch in FStatementProps then begin
      DestroyColInfos;
      DestroyParamInfos;
      CreateParamInfos;
    end;
    SetParamValues(1, 0);
    SQLiteConnection.SetupForStmt(FOptions.UpdateOptions);
    try
      FStmt.Execute;
    finally
      ACount := FStmt.Changes;
    end;
    Exclude(FStatementProps, cpOnNextResult);
    Result := GetCursor(0) or
      // PRAGMA's return empty column list, if there is no data
      (GetMetaInfoKind <> mkNone);
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalNextRecordSet: Boolean;
begin
  if FStmt.State = ssRewinded then
    Result := False
  else if cpOnNextResult in FStatementProps then begin
    Exclude(FStatementProps, cpOnNextResult);
    Result := cpOnNextResultValue in FStatementProps;
  end
  else begin
    Result := FStmt.MoreCommands;
    if Result then begin
      DestroyColInfos;
      Result := FStmt.PrepareNextCommand;
      if Result then begin
        SQLiteConnection.SetupForStmt(FOptions.UpdateOptions);
        FStmt.Execute;
        Result := GetCursor(0);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.InternalClose;
begin
  if FStmt <> nil then begin
    FStmt.Reset;
    if not GetNextRecordSet then
      FStmt.Rewind;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysSQLiteCommand.FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
var
  oRow: TFDDatSRow;
  [unsafe] oCol: TFDDatSColumn;
  oFmtOpts: TFDFormatOptions;
  pColInfo: PFDSQLiteVarInfoRec;
  j: Integer;
  lMetadata: Boolean;

  procedure ProcessColumn(AColIndex: Integer; ARow: TFDDatSRow;
    ApInfo: PFDSQLiteVarInfoRec);
  var
    pData, pDestData: Pointer;
    iSize: Integer;
    iDestSize: LongWord;
    lByRef: Boolean;
  begin
    pData := FBuffer.Check;
    iSize := 0;
    lByRef := ApInfo^.FOutSQLDataType in [etString, etUString, etBlob];

    // null
    if not ApInfo^.FVar.GetData(pData, iSize, lByRef) then
      ARow.SetData(AColIndex, nil, 0)

    // conversion is not required
    else if ApInfo^.FOutDataType = ApInfo^.FDestDataType then
      ARow.SetData(AColIndex, pData, iSize)

    // conversion is required
    else begin
      pDestData := FBuffer.Extend(iSize, iDestSize, ApInfo^.FOutDataType,
        ApInfo^.FDestDataType);
      iDestSize := 0;
      oFmtOpts.ConvertRawData(ApInfo^.FOutDataType, ApInfo^.FDestDataType,
        pData, iSize, pDestData, FBuffer.Size, iDestSize,
        SQLiteConnection.FDatabase.Encoder);
      ARow.SetData(AColIndex, pDestData, iDestSize);
    end;
  end;

  procedure ProcessMetaColumn(AColIndex: Integer; ARow: TFDDatSRow;
    ApInfo: PFDSQLiteVarInfoRec);
  begin
    if AColIndex = 0 then
      ARow.SetData(0, ATable.Rows.Count + 1)
    else begin
      ApInfo^.FDestDataType := ATable.Columns[AColIndex].DataType;
      ProcessColumn(AColIndex, ARow, ApInfo);
    end;
  end;

begin
  oFmtOpts := FOptions.FormatOptions;
  oRow := ATable.NewRow(False);
  lMetadata := GetMetaInfoKind <> mkNone;
  try
    for j := 0 to ATable.Columns.Count - 1 do begin
      oCol := ATable.Columns[j];
      if (oCol.SourceID > 0) and CheckFetchColumn(oCol.SourceDataType, oCol.Attributes) then begin
        pColInfo := @FColInfos[oCol.SourceID - 1];
        if pColInfo^.FVar <> nil then
          if lMetadata then
            ProcessMetaColumn(j, oRow, pColInfo)
          else
            ProcessColumn(j, oRow, pColInfo);
      end;
    end;
    if AParentRow <> nil then begin
      oRow.ParentRow := AParentRow;
      AParentRow.Fetched[ATable.Columns.ParentCol] := True;
    end;
    ATable.Rows.Add(oRow);
  except
    FDFree(oRow);
    raise;
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.FetchMetaRow(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARowNo: Longword): Boolean;

  function GetFKAction(const AAction: String): TFDPhysCascadeRuleKind;
  begin
    if (CompareText(AAction, 'NO ACTION') = 0) or
       (CompareText(AAction, 'RESTRICT') = 0) then
      Result := ckRestrict
    else if CompareText(AAction, 'CASCADE') = 0 then
      Result := ckCascade
    else if CompareText(AAction, 'SET DEFAULT') = 0 then
      Result := ckSetDefault
    else if CompareText(AAction, 'SET NULL') = 0 then
      Result := ckSetNull
    else
      Result := ckNone;
  end;

var
  oRow: TFDDatSRow;
  iRecNo: Integer;
  rName: TFDPhysParsedName;
  iLen: LongWord;
  iPrec, iScale: Integer;
  eType: TFDDataType;
  eAttrs: TFDDataAttributes;
  lDeleteRow: Boolean;
  oConnMeta: IFDPhysConnectionMetadata;
  sName, sTmp, sTypeName, sWildcard, sCollation: String;
  bNotNull, bInPK, bAutoInc: Boolean;
  sBaseName, sBaseTypeName: String;
begin
  lDeleteRow := False;
  sWildcard := GetWildcard;
  iRecNo := FRecordsFetched + Integer(ARowNo);
  oRow := ATable.NewRow(False);
  try
    FConnection.CreateMetadata(oConnMeta);
    oConnMeta.DecodeObjName(Trim(GetCommandText), rName, Self, [doNormalize, doUnquote]);
    case GetMetaInfoKind of
    mkCatalogs:
      begin
        oRow.SetData(0, iRecNo);
        sName := FStmt.Columns[1].AsString;
        if (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) then
          lDeleteRow := True
        else
          oRow.SetData(1, sName);
      end;
    mkTableFields:
      begin
        eAttrs := [];
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FObject);
        sName := FStmt.Columns[1].AsString;
        if (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) then
          lDeleteRow := True
        else begin
          oRow.SetData(4, sName);
          oRow.SetData(5, Integer(FStmt.Columns[0].AsInteger + 1));
          sTypeName := FStmt.Columns[2].AsString;
          FStmt.Database.DescribeColumn(rName.FCatalog, rName.FObject, sName,
            sTmp, sCollation, bNotNull, bInPK, bAutoInc, False);
          TypeName2ADDataType(sName, sTypeName, sBaseName, sBaseTypeName, eType,
            eAttrs, iLen, iPrec, iScale);
          Include(eAttrs, caBase);
          if (FStmt.Columns[3].AsInteger = 0) or not bNotNull then
            Include(eAttrs, caAllowNull);
          if FStmt.Columns[4].AsString <> '' then
            Include(eAttrs, caDefault);
          if bAutoInc then
            Include(eAttrs, caAutoInc);
          oRow.SetData(6, Smallint(eType));
          oRow.SetData(7, sBaseTypeName);
          oRow.SetData(8, PWord(@eAttrs)^);
          oRow.SetData(9, iPrec);
          oRow.SetData(10, iScale);
          oRow.SetData(11, iLen);
        end;
      end;
    mkIndexes:
      begin
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FObject);
        sName := FStmt.Columns[1].AsString;
        if (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) then
          lDeleteRow := True
        else begin
          oRow.SetData(4, sName);
          oRow.SetData(5, Null);
          if FStmt.Columns[2].AsInteger = 0 then
            oRow.SetData(6, Smallint(ikNonUnique))
          else
            oRow.SetData(6, Smallint(ikUnique));
        end;
      end;
    mkIndexFields:
      begin
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FBaseObject);
        oRow.SetData(4, rName.FObject);
        sName := FStmt.Columns[2].AsString;
        if (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) or
           (FStmt.Columns[1].AsInteger < 0) then
          lDeleteRow := True
        else begin
          oRow.SetData(5, sName);
          oRow.SetData(6, Integer(FStmt.Columns[0].AsInteger + 1));
          if (oConnMeta.ServerVersion < svSQLite030809) or (FStmt.Columns[3].AsInteger = 0) then
            oRow.SetData(7, 'A')
          else
            oRow.SetData(7, 'D');
          oRow.SetData(8, Null);
        end;
      end;
    mkPrimaryKey:
      begin
        lDeleteRow := iRecNo > 1;
        if not lDeleteRow then begin
          oRow.SetData(0, iRecNo);
          oRow.SetData(1, rName.FCatalog);
          oRow.SetData(2, Null);
          oRow.SetData(3, rName.FObject);
          if (FStmt.Columns[5].AsInteger = 0) or
             (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) then
            lDeleteRow := True
          else begin
            oRow.SetData(4, 'PRIMARY');
            oRow.SetData(5, 'PRIMARY');
            oRow.SetData(6, Smallint(ikPrimaryKey));
          end;
        end;
      end;
    mkPrimaryKeyFields:
      begin
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FBaseObject);
        oRow.SetData(4, 'PRIMARY');
        sName := FStmt.Columns[1].AsString;
        if (FStmt.Columns[5].AsInteger = 0) or
           (sWildcard <> '') and not FDStrLike(sName, sWildcard, True) then
          lDeleteRow := True
        else begin
          oRow.SetData(5, sName);
          oRow.SetData(6, iRecNo);
          oRow.SetData(7, 'A');
          oRow.SetData(8, Null);
        end;
      end;
    mkForeignKeys:
      if FStmt.Columns[1].AsInteger > 0 then
        lDeleteRow := True
      else begin
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FObject);
        oRow.SetData(4, 'FK_' + FStmt.Columns[0].AsString);
        oRow.SetData(5, rName.FCatalog);
        oRow.SetData(6, Null);
        oRow.SetData(7, FStmt.Columns[2].AsString);
        oRow.SetData(9, GetFKAction(FStmt.Columns[5].AsString));
        oRow.SetData(8, GetFKAction(FStmt.Columns[6].AsString));
      end;
    mkForeignKeyFields:
      if CompareText('FK_' + FStmt.Columns[0].AsString, rName.FObject) <> 0 then
        lDeleteRow := True
      else begin
        oRow.SetData(0, iRecNo);
        oRow.SetData(1, rName.FCatalog);
        oRow.SetData(2, Null);
        oRow.SetData(3, rName.FBaseObject);
        oRow.SetData(4, rName.FObject);
        oRow.SetData(5, FStmt.Columns[3].AsString);
        oRow.SetData(6, FStmt.Columns[4].AsString);
        oRow.SetData(7, Integer(FStmt.Columns[1].AsInteger + 1));
      end;
    end;
    if lDeleteRow then begin
      FDFree(oRow);
      Result := False;
    end
    else begin
      ATable.Rows.Add(oRow);
      Result := True;
    end;
  except
    FDFree(oRow);
    raise;
  end;
end;

{-------------------------------------------------------------------------------}
function TFDPhysSQLiteCommand.InternalFetchRowSet(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARowsetSize: LongWord): LongWord;
var
  i: LongWord;
begin
  Result := 0;
  if GetMetaInfoKind in [mkNone, mkTables] then
    for i := 1 to ARowsetSize do begin
      if not FStmt.Fetch then
        Break;
      FetchRow(ATable, AParentRow);
      Inc(Result);
    end
  else
    for i := 1 to ARowsetSize do begin
      if not FStmt.Fetch then
        Break;
      if FetchMetaRow(ATable, AParentRow, Result + 1) then
        Inc(Result);
    end;
end;

{ TFDPhysSQLiteMetadataEx }

function TFDPhysSQLiteMetadataEx.InternalGetSQLCommandKind(const ATokens: TStrings): TFDPhysCommandKind;
begin
  if (ATokens[0] = 'INSERT') and (ATokens[Pred(ATokens.Count)] = 'RETURNING') then
    Result := skSelectForLock
  else
    Result := inherited;
end;

{-----------------------------------------------------------------------------}
initialization
  FDRegisterDriverClass(TFDPhysSQLiteDriver);
  FDExtensionManager().AddExtension([TFDPhysSQLitePostEventFunc]);

finalization
  FDUnregisterDriverClass(TFDPhysSQLiteDriver);

end.
