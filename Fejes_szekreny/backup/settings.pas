unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LazSerial, IniFiles, global, LazSynaSer, database, Sqlite3DS;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnMentes: TButton;
    btnMegsem: TButton;
    btnNyitas: TButton;
    btnZaras: TButton;
    btnTorles: TButton;
    chkCOMPORT_VEZERLES: TCheckBox;
    chgAjtokNyitasaZarasa: TCheckGroup;
    cmbCOM: TComboBox;
    cmbFejSorozatszam: TComboBox;
    edtFerohelyek_szama: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Serial: TLazSerial;
    Shape1: TShape;
    Shape2: TShape;
    Timer1: TTimer;
    procedure btnMegsemClick(Sender: TObject);
    procedure btnMentesClick(Sender: TObject);
    procedure btnNyitasClick(Sender: TObject);
    procedure btnTorlesClick(Sender: TObject);
    procedure btnZarasClick(Sender: TObject);
    procedure chkCOMPORT_VEZERLESChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSettings:            TfrmSettings;
  IniFile:                TiniFile;


implementation

{$R *.lfm}

uses fomenu,progress;

{ TfrmSettings }


procedure TfrmSettings.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  //Ha a timer engedélyzeva van akkor nem lehet bezárni az ablakot!!
  if Timer1.Enabled = true then
  begin
       ShowMessage('Az ablakot csak akkor lehet bezárni ha az összes ajtó zárva van!');
       CanClose := false;
       exit;
  end;
  CanClose := true;
  //ShowMessage('OK');
  //IniFile.Free;
  //frmSettings.Hide;
  frmFomenu.Show;

end;

procedure TfrmSettings.Timer1Timer(Sender: TObject);
var
  i,ajto_szam       :integer;

begin
  //Kiválasztott ajtó(k) bezárása:
  Timer1.Enabled := false;

  frmProgress.Caption := 'Timer1: Ajtó(k) bezárása';
  frmProgress.lblMessage.Caption := 'Ajtó(k) bezárása folyamatban...';
  frmProgress.Show;
  frmProgress.Refresh;

  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          frmProgress.Close;
          ShowMessage('Port megnyitása nem sikerült, használd a "Zárás" gombot!');
          exit;
       end;
  end;
  Sleep(500);

  for i := 0 to chgAjtokNyitasaZarasa.ControlCount - 1 do
  begin
      if (chgAjtokNyitasaZarasa.Checked[i]) then
      begin
           ajto_szam := StrToInt(chgAjtokNyitasaZarasa.Controls[i].Caption);
           if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio clear ' + chr(70 + ajto_szam) + chr(13));
           Sleep(250);
      end;
  end;
  Serial.Close;

  frmProgress.Close;

  ShowMessage('Ajtók bezárva!!');

end;

procedure TfrmSettings.btnMegsemClick(Sender: TObject);
begin
  frmSettings.Hide;
  frmFomenu.Show;
end;

procedure TfrmSettings.btnMentesClick(Sender: TObject);
begin
  if MessageDlg ('Adatok mentése...', 'Biztos hogy módosítod a beállításokat ?',
                mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  COMPORT_VEZERLES := 0;
  if (chkCOMPORT_VEZERLES.Checked) then COMPORT_VEZERLES := 1;
  COM_port_name := cmbCOM.Text;
  ferohelyek := StrToInt(edtFerohelyek_szama.Text);

  IniFile := TIniFile.Create(ExtractFilePath(Application.EXEName) + 'beallitasok.ini');
          IniFile.WriteString('Beallitasok', 'COM_port', cmbCOM.Text);
          IniFile.WriteString('Beallitasok', 'ferohelyek_szama', Trim(edtFerohelyek_szama.Text));
          IniFile.WriteString('Beallitasok', 'comport_vezerles', IntToStr(COMPORT_VEZERLES));
  IniFile.Free;

  ShowMessage('Beállítások mentése és frissítése megtörtént!');
end;

procedure TfrmSettings.btnNyitasClick(Sender: TObject);
var
  i,ajto_szam       :integer;

begin
  //Kijelölt ajtók nyitása:

  frmProgress.Caption := 'Beállítások - Ajtó(k) nyitása';
  frmProgress.lblMessage.Caption := 'Ajtó(k) nyitása folyamatban...';
  frmProgress.Show;
  frmProgress.Refresh;

  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          frmProgress.Close;
          ShowMessage('Port megnyitása nem sikerült, próbáld meg újra!');
          exit;
       end;
  end;
  Sleep(500);

  for i := 0 to chgAjtokNyitasaZarasa.ControlCount - 1 do
  begin
      if (chgAjtokNyitasaZarasa.Checked[i]) then
      begin
           ajto_szam := StrToInt(chgAjtokNyitasaZarasa.Controls[i].Caption);
           if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio set ' + chr(70 + ajto_szam) + chr(13));
           Sleep(250);
      end;
  end;
  Serial.Close;

  frmProgress.Close;

  ShowMessage('A kiválasztott ajtó(k) 10 másodperc múlva automatikusan bezárúl(nak)!');
  Timer1.Interval := 10000;
  Timer1.Enabled := true;
end;

procedure TfrmSettings.btnTorlesClick(Sender: TObject);
var
  iFej : integer;
  myDataset : TSqlite3Dataset;
begin
  //Kiválasztott fej "törlése":
  iFej := integer(cmbFejSorozatszam.Items.Objects[cmbFejSorozatszam.ItemIndex]);
  myDataset := dbConnect('fej','select * from fej where id = ' + inttostr(ifej) + ';','id');

  myDataset.Edit;
  myDataset.FieldByName('torolve').AsInteger := 1;
  myDataset.Post;
  myDataset.ApplyUpdates;

  //fejek legördülő frissítése:
  cmbFejSorozatszam.Clear;
  dbUpdate(myDataset, 'select * from fej where torolve = 0 order by sorozatszam;');
  Repeat
    cmbFejSorozatszam.Items.AddObject(myDataset.FieldByName('sorozatszam').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbFejSorozatszam.Text:=myDataset.FieldByName('sorozatszam').AsString;
  dbClose(myDataset);

end;

procedure TfrmSettings.btnZarasClick(Sender: TObject);
var
  i,ajto_szam       :integer;

begin
  //Kijelölt ajtók zárása:

  frmProgress.Caption := 'Beállítások - Ajtó(k) bezárása';
  frmProgress.lblMessage.Caption := 'Ajtó(k) bezárása folyamatban...';
  frmProgress.Show;
  frmProgress.Refresh;


  //Timer leállítása ha menne...:
  if (Timer1.Enabled = true) then Timer1.Enabled := false;

  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          frmProgress.Close;
          ShowMessage('Port megnyitása nem sikerült, próbáld meg újra!');
          exit;
       end;
  end;
  Sleep(500);

  for i := 0 to chgAjtokNyitasaZarasa.ControlCount - 1 do
  begin
      if (chgAjtokNyitasaZarasa.Checked[i]) then
      begin
           ajto_szam := StrToInt(chgAjtokNyitasaZarasa.Controls[i].Caption);
           if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio clear ' + chr(70 + ajto_szam) + chr(13));
           Sleep(250);
      end;
  end;
  Serial.Close;

  frmProgress.Close;

end;

procedure TfrmSettings.chkCOMPORT_VEZERLESChange(Sender: TObject);
begin

end;

procedure TfrmSettings.FormActivate(Sender: TObject);
var
  i       :integer;
  myDataset : TSqlite3Dataset;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.EXEName) + 'beallitasok.ini');
          cmbCOM.Text := IniFile.ReadString('Beallitasok', 'COM_port', 'COM7');
          edtFerohelyek_szama.Text := IniFile.ReadString('Beallitasok', 'ferohelyek_szama', '8');
          COMPORT_VEZERLES := StrToInt(IniFile.ReadString('Beallitasok', 'comport_vezerles', '1'));
  IniFile.Free;

  if (COMPORT_VEZERLES = 1) then
     chkCOMPORT_VEZERLES.Checked := true
  else
    chkCOMPORT_VEZERLES.Checked := false;

  for i := 0 to chgAjtokNyitasaZarasa.ControlCount - 1 do
      chgAjtokNyitasaZarasa.Checked[i] := false;

  cmbCOM.Clear;
  cmbCOM.Items.CommaText := GetSerialPortNames();

  cmbFejSorozatszam.Clear;
  myDataset := dbConnect('fej', 'select * from fej where torolve = 0 order by sorozatszam;','id');
  Repeat
    cmbFejSorozatszam.Items.AddObject(myDataset.FieldByName('sorozatszam').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbFejSorozatszam.Text:=myDataset.FieldByName('sorozatszam').AsString;
  dbClose(myDataset);


end;

end.

