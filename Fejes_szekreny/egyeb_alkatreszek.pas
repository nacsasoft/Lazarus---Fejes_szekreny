unit egyeb_alkatreszek;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, ExtCtrls, Grids, LazSerial, mySqliteDatabase, global;

type

  { TfrmEgyebAlkatreszek }

  TfrmEgyebAlkatreszek = class(TForm)
    btnAlkatreszBerakas: TButton;
    btnUjAlkatresz: TButton;
    btnNyitas: TButton;
    btnZaras: TButton;
    btnAlkatreszKivetele: TButton;
    cmbAlkatreszek: TComboBox;
    cmbSzekrenyszam: TComboBox;
    edtBeDarabszam: TEdit;
    edtMegnevezes: TEdit;
    edtRendelesiSzam: TEdit;
    edtKiDarabszam: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    memMegjegyzes: TMemo;
    Panel1: TPanel;
    rdgSzekrenyek: TRadioGroup;
    Serial: TLazSerial;
    stgEgyebAlkatreszek: TStringGrid;
    procedure btnAlkatreszBerakasClick(Sender: TObject);
    procedure btnAlkatreszKiveteleClick(Sender: TObject);
    procedure btnNyitasClick(Sender: TObject);
    procedure btnUjAlkatreszClick(Sender: TObject);
    procedure btnZarasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure stgEgyebAlkatreszekSelection(Sender: TObject; aCol, aRow: Integer);

  private
    procedure AlkatreszlistaFrissitese();

  public


  end;

var
  frmEgyebAlkatreszek: TfrmEgyebAlkatreszek;

implementation

{$R *.lfm}

{ TfrmEgyebAlkatreszek }

uses main, progress, uj_alkatresz_felvitele, fomenu;

procedure TfrmEgyebAlkatreszek.FormShow(Sender: TObject);
var
  mySqlite3 : cSqliteDatabase;

begin
  //vezérlők beállítása:
  rdgSzekrenyek.ItemIndex := 0;
  edtBeDarabszam.Text := '';
  //edtBeSzekrenyszam.Text := '';
  memMegjegyzes.Clear;

  //szekrényben lévő alkatrészek a db gridbe:
  AlkatreszlistaFrissitese();

  //Alkatrészlista feltöltése:
  cmbAlkatreszek.Clear;
  mySqlite3 := cSqliteDatabase.Create('alkatreszek','SELECT * FROM alkatreszek WHERE torolve = 0 GROUP BY rendelesi_szam ORDER BY rendelesi_szam;', 'id');
  Repeat
    cmbAlkatreszek.Items.AddObject(mySqlite3.pDataset.FieldByName('rendelesi_szam').AsString + ' - ' +
       mySqlite3.pDataset.FieldByName('megnevezes').AsString,
       TObject(mySqlite3.pDataset.FieldByName('id').AsInteger));
    mySqlite3.pDataset.Next;
  Until mySqlite3.pDataset.Eof;
  mySqlite3.pDataset.First;
  cmbAlkatreszek.ItemIndex := 0;
  mySqlite3.Terminate();



end;

procedure TfrmEgyebAlkatreszek.stgEgyebAlkatreszekSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  //kiválasztott alkatrész adatainak megjelenítése:
  edtMegnevezes.Text := stgEgyebAlkatreszek.Cells[2, aRow];
  edtRendelesiSzam.Text := stgEgyebAlkatreszek.Cells[1, aRow];
  edtKiDarabszam.Text := '0'; // stgEgyebAlkatreszek.Cells[3, aRow];  // Horsa Cs. kérésére módosítva 2022.03.24.
end;

procedure TfrmEgyebAlkatreszek.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmEgyebAlkatreszek.Hide;
  //frmMain.Show;
  frmFomenu.Show;
end;

procedure TfrmEgyebAlkatreszek.btnAlkatreszKiveteleClick(Sender: TObject);
var
  iSzekreny, iDarab, iKiDarab, iKivalasztottSor, iAlkId, iEgyebAlkId : integer;
  mySqlite3 : cSqliteDatabase;
begin
  //kiválasztott alkatrész kivétele...
  iKivalasztottSor := stgEgyebAlkatreszek.Row;
  iDarab := strtoint(stgEgyebAlkatreszek.Cells[3, iKivalasztottSor]);
  iKiDarab := strtoint(trim(edtKiDarabszam.Text));
  iSzekreny := strtoint(stgEgyebAlkatreszek.Cells[0, iKivalasztottSor]);
  iEgyebAlkId := strtoint(stgEgyebAlkatreszek.Cells[5, iKivalasztottSor]);  //rejtett oszlop a gridben...
  iAlkId := strtoint(stgEgyebAlkatreszek.Cells[6, iKivalasztottSor]);       //rejtett oszlop a gridben...

  if iKiDarab > iDarab then
  begin
    ShowMessage('A kivenni kívánt darabszám több mint amennyi a szekrényben van!');
    exit;
  end;

  //ajtó nyitás/zárás:
  frmProgress.Caption := 'Egyéb alkatrészek - Ajtó nyitása';
  frmProgress.lblMessage.Caption := 'Ajtó nyitása folyamatban...';
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
  if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio set ' + chr(70 + iSzekreny) + chr(13));
  frmProgress.Close;
  Sleep(250);
  ShowMessage('A ' + inttostr(iSzekreny) + '. szekrény nyitva, az alkatrész kivehető!' + #10 +
    'az OK -gombra kattintva az ajtó bezár!');
  if COMPORT_VEZERLES = 1 then
      begin
        Serial.WriteData('gpio clear ' + chr(70 + iSzekreny) + chr(13));
        Serial.Close;
      end;
  Sleep(250);

  mySqlite3 := cSqliteDatabase.Create('egyeb_alkatreszek', 'SELECT * FROM egyeb_alkatreszek ORDER BY id;', 'id');

  // új darabszám
  iDarab := iDarab - iKiDarab;
  if iDarab = 0 then
    begin
      //törölni kell a szekrényből az alkatrészt:
      mySqlite3.RunSQL('DELETE FROM egyeb_alkatreszek WHERE id = ' + inttostr(iEgyebAlkId) + ';');
      mySqlite3.Terminate();
      //AlkatreszlistaFrissitese();
      //ShowMessage('A kiválasztott alkatrész törölve lett a ' + inttostr(iSzekreny) + ' -szekrényből!');
      //exit;
    end
  else
    begin
      //darabszám frissítése:
      mySqlite3.RunSQL('SELECT * FROM egyeb_alkatreszek WHERE id = ' + inttostr(iEgyebAlkId) + ';');
      with mySqlite3.pDataset do
      begin
        Edit;
        FieldByName('darabszam').AsInteger := iDarab;
        Post;
        ApplyUpdates;
      end;
      mySqlite3.Terminate();
    end;

  //az 'egyeb_alkatrész_kivetel' táblába fel kell vinni a kivételt:
  mySqlite3 := cSqliteDatabase.Create('egyeb_alkatresz_kivetel', 'SELECT * FROM egyeb_alkatresz_kivetel ORDER BY id;', 'id');
  with mySqlite3.pDataset do
  begin
    Insert;
    FieldByName('egyeb_u_id').AsInteger := userDB_ID;
    FieldByName('egyeb_datum').AsString := FormatDateTime('yyyy-mm-dd',Now);
    FieldByName('egyeb_ido').AsString := FormatDateTime('hh-nn',Now);
    FieldByName('alkatresz_id').AsInteger := iAlkId;
    FieldByName('egyeb_kivett_darab').AsInteger := iKiDarab;
    Post;
    ApplyUpdates;
  end;
  mySqlite3.Terminate();

  AlkatreszlistaFrissitese();

end;

procedure TfrmEgyebAlkatreszek.btnNyitasClick(Sender: TObject);
var
  iSzekreny : integer;
begin

  iSzekreny := strtoint(rdgSzekrenyek.Controls[rdgSzekrenyek.ItemIndex].Caption);

  //ajtó nyitás:
  frmProgress.Caption := 'Egyéb alkatrészek - Ajtó nyitása';
  frmProgress.lblMessage.Caption := 'Ajtó nyitása folyamatban...';
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
  if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio set ' + chr(70 + iSzekreny) + chr(13));
  Serial.Close;
  frmProgress.Close;
  Sleep(250);
  ShowMessage('A ' + inttostr(iSzekreny) + '. szekrény nyitva, alkatrész berakható!');

end;

procedure TfrmEgyebAlkatreszek.btnUjAlkatreszClick(Sender: TObject);
begin
  frmUjAlkatreszFelvitel.ShowModal;
end;

procedure TfrmEgyebAlkatreszek.btnZarasClick(Sender: TObject);
var
  iSzekreny : integer;

begin
  iSzekreny := strtoint(rdgSzekrenyek.Controls[rdgSzekrenyek.ItemIndex].Caption);

  //ajtó zárás:
  frmProgress.Caption := 'Egyéb alkatrészek - Ajtó zárása';
  frmProgress.lblMessage.Caption := 'Ajtó zárása folyamatban...';
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
  if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio clear ' + chr(70 + iSzekreny) + chr(13));
  Serial.Close;
  frmProgress.Close;
  Sleep(250);
  ShowMessage('A ' + inttostr(iSzekreny) + '. szekrény bezárva!');

end;

procedure TfrmEgyebAlkatreszek.btnAlkatreszBerakasClick(Sender: TObject);
var
  iAlkId, iDarab, iSzekreny : integer;
  mySqlite3 : cSqliteDatabase;

begin
  //listából kiválasztott alkatrész berakása a szekrénybe:
  iAlkId := integer(cmbAlkatreszek.Items.Objects[cmbAlkatreszek.ItemIndex]);
  iDarab := strtoint(trim(edtBeDarabszam.Text));
  iSzekreny := strtoint(cmbSzekrenyszam.Text);

  if iDarab <= 0 then
  begin
    ShowMessage('A megadott darabszám nem megfelelő!');
    edtBeDarabszam.SetFocus;
    exit;
  end;

  {*if (iSzekreny < 14) or (iSzekreny > 16) then
  begin
    ShowMessage('Csak a 13, 14, 15, 16 -os szekrényekben tárolható egyéb alkatrész!');
    edtBeSzekrenyszam.SetFocus;
    exit;
  end; *}

  //ajtó nyitás/zárás:
  frmProgress.Caption := 'Egyéb alkatrészek - Ajtó nyitása';
  frmProgress.lblMessage.Caption := 'Ajtó nyitása folyamatban...';
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
  if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio set ' + chr(70 + iSzekreny) + chr(13));
  frmProgress.Close;
  Sleep(250);
  ShowMessage('A ' + inttostr(iSzekreny) + '. szekrény nyitva, alkatrész berakható!' + #10 +
    'az OK -gombra kattintva az ajtó bezár!');
  if COMPORT_VEZERLES = 1 then
      begin
        Serial.WriteData('gpio clear ' + chr(70 + iSzekreny) + chr(13));
        Serial.Close;
      end;
  Sleep(250);

  //ha van már ebből az alkatrészből egy másik szekrényben akkor jelezni kell:
  mySqlite3 := cSqliteDatabase.Create('egyeb_alkatreszek','SELECT * FROM egyeb_alkatreszek ' +
      'WHERE szekreny_szama <> ' + inttostr(iSzekreny) + ' AND alkatresz_id = ' + inttostr(iAlkId) + ';','id');
  if mySqlite3.GetRecordCount() > 0 then
  begin
    if MessageDlg('Alkatrész berakása a szekrénybe...', 'Ez az alkatrész már bent van a következő szekrényben : ' +
        inttostr(mySqlite3.pDataset.FieldByName('szekreny_szama').AsInteger) + ' !!' + #10 +
        'Biztos hogy egy másik szekrénybe szeretnéd elhelyezni az alkatrészt?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        begin
          iSzekreny := mySqlite3.pDataset.FieldByName('szekreny_szama').AsInteger;
        end;
  end;

  //ha van már ebből az alkatrészből a megadott szekrényben akkor csak a darabszámot kell frissíteni:
  mySqlite3.RunSQL('SELECT * FROM egyeb_alkatreszek WHERE szekreny_szama = ' + inttostr(iSzekreny) +
        ' AND alkatresz_id = ' + inttostr(iAlkId) + ';');
  if mySqlite3.GetRecordCount() > 0 then
      begin
        //ebben a szekrényben már van ebből az alkatrészből....
        iDarab := iDarab + mySqlite3.pDataset.FieldByName('darabszam').AsInteger;
        with mySqlite3.pDataset do
          begin
            Edit;
            FieldByName('darabszam').AsInteger := iDarab;
            Post;
            ApplyUpdates;
          end;
      end
  else
      begin
        //ez az alkatrész nincs ebben a szekrényben:
        with mySqlite3.pDataset do
          begin
            Insert;
            FieldByName('szekreny_szama').AsInteger := iSzekreny;
            FieldByName('alkatresz_id').AsInteger := iAlkId;
            FieldByName('darabszam').AsInteger := iDarab;
            FieldByName('megjegyzes').AsString := memMegjegyzes.Text;
            Post;
            ApplyUpdates;
          end;
      end;
  mySqlite3.Terminate();

  //edtBeSzekrenyszam.Text := '';
  edtBeDarabszam.Text := '';
  memMegjegyzes.Clear;

  AlkatreszlistaFrissitese();

  ShowMessage('Az alkatrész felvitele megtörtént!');
end;

procedure TfrmEgyebAlkatreszek.AlkatreszlistaFrissitese();
var
  mySqlite3 : cSqliteDatabase;
  iRowID : integer;
begin
  //szekrényben lévő alkatrészek a db gridbe:
  mySqlite3 := cSqliteDatabase.Create('egyeb_alkatreszek', 'SELECT * FROM egyeb_alkatreszek ' +
                'JOIN alkatreszek ON alkatreszek.id = egyeb_alkatreszek.alkatresz_id ' +
                'ORDER BY egyeb_alkatreszek.szekreny_szama;', 'id');
  iRowID := 1;
  stgEgyebAlkatreszek.Clear;
  stgEgyebAlkatreszek.RowCount := 2;
  repeat
    stgEgyebAlkatreszek.InsertRowWithValues(iRowID,[
            inttostr(mySqlite3.pDataset.FieldByName('szekreny_szama').AsInteger),
            mySqlite3.pDataset.FieldByName('rendelesi_szam').AsString ,
            mySqlite3.pDataset.FieldByName('megnevezes').AsString,
            inttostr(mySqlite3.pDataset.FieldByName('darabszam').AsInteger),
            mySqlite3.pDataset.FieldByName('megjegyzes').AsString,
            inttostr(mySqlite3.pDataset.FieldByName('id').AsInteger),
            inttostr(mySqlite3.pDataset.FieldByName('alkatresz_id').AsInteger)]);

    Inc(iRowID);
    mySqlite3.pDataset.Next;
  until mySqlite3.pDataset.EOF;
  mySqlite3.Terminate();
  stgEgyebAlkatreszek.Row := 1;
end;

end.

