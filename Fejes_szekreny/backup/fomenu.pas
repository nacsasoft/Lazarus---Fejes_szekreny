unit fomenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, global, database, Sqlite3DS;

type

  { TfrmFomenu }

  TfrmFomenu = class(TForm)
    btnFejBe: TButton;
    btnPreventiveKarbantartas: TButton;
    btnFejKi: TButton;
    btnRiportok: TButton;
    btnSettings: TButton;
    btnAlkatreszek: TButton;
    edtAzonosito: TEdit;
    Label1: TLabel;
    Shape1: TShape;
    procedure btnAlkatreszekClick(Sender: TObject);
    procedure btnFejBeClick(Sender: TObject);
    procedure btnFejKiClick(Sender: TObject);
    procedure btnPreventiveKarbantartasClick(Sender: TObject);
    procedure btnRiportokClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    myDataset:          TSqlite3Dataset;

  public
    { public declarations }
  end;

var
  frmFomenu: TfrmFomenu;

implementation

{$R *.lfm}

{ TfrmFomenu }
uses main, fejkivetel, fejbehelyezes, settings, prevkarb, riportok, egyeb_alkatreszek;

procedure TfrmFomenu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmFomenu.Hide;
  frmMain.Show;
end;

procedure TfrmFomenu.FormActivate(Sender: TObject);
begin
     edtAzonosito.Text := userName;
     btnSettings.Enabled := false;
     //btnPreventiveKarbantartas.Enabled := false;
     //btnRiportok.Enabled := false;

     //if (iAdmin = 1) then btnRiportok.Enabled := true;
     if (iAdmin = 2) then
     begin
       btnSettings.Enabled := true;
       btnRiportok.Enabled := true;
       btnPreventiveKarbantartas.Enabled := true;
     end;
     //if (iAdmin = 3) then btnPreventiveKarbantartas.Enabled := true;

     //ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);
     //ShowWindow(FindWindowEx(0, 0, MAKEINTATOM($C017), 'Start'), SW_SHOW);
end;

procedure TfrmFomenu.btnFejKiClick(Sender: TObject);
var
  sql:           string;
  iRecNum:       integer;
begin
  //Fej kivétele a szekrényből...ha van benne....
  sql := 'SELECT * FROM fej WHERE hely=1 ORDER BY id;';

  myDataset := dbConnect('fej',sql,'id');
  iRecNum := myDataset.RecordCount;
  dbClose(myDataset);
  if iRecNum < 1 then
  begin
       ShowMessage('A fejes szekrény üres!');
       exit;
  end;
  frmFomenu.Hide;
  frmFejKivetel.Show;
end;

procedure TfrmFomenu.btnPreventiveKarbantartasClick(Sender: TObject);
begin
  //Preventív karbantartás bejegyzése,követése...
  frmFomenu.Hide;
  frmPrevKarb.Show;
end;

procedure TfrmFomenu.btnRiportokClick(Sender: TObject);
begin
  //riportok...
  frmFomenu.Hide;
  frmRiportok.Show;
end;

procedure TfrmFomenu.btnSettingsClick(Sender: TObject);
begin
  //beállítások...
  frmFomenu.Hide;
  frmSettings.Show;
end;

procedure TfrmFomenu.btnFejBeClick(Sender: TObject);
var
  sql:           string;
  iRecNum:       integer;
begin
  //Fej berakása a szekrénybe...ha van még hely...
  sql := 'SELECT * FROM fej WHERE hely=1 ORDER BY id;';

  myDataset := dbConnect('fej',sql,'id');
  iRecNum := myDataset.RecordCount;
  dbClose(myDataset);
  if iRecNum = ferohelyek then
  begin
       ShowMessage('A fejes szekrény tele van!');
       exit;
  end;
  frmFomenu.Hide;
  frmFejBehelyezes.Show;
end;

procedure TfrmFomenu.btnAlkatreszekClick(Sender: TObject);
begin
  //egyéb alkatrészek berakása/kivétele a szekrényből....
  frmFomenu.Hide;
  frmEgyebAlkatreszek.Show;
end;

end.

