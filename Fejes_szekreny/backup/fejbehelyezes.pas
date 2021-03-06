unit fejbehelyezes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LazSerial, Sqlite3DS, database, global;

type

  { TfrmFejBehelyezes }

  TfrmFejBehelyezes = class(TForm)
    btnFejBerakas: TButton;
    btnMegsem: TButton;
    chkSorrolJottLe: TCheckBox;
    chkUjFej: TCheckBox;
    cmbFejtipus: TComboBox;
    cmbFejallapot: TComboBox;
    cmbGeptipus: TComboBox;
    cmbPortal: TComboBox;
    cmbSor: TComboBox;
    cmbSorozatszam: TComboBox;
    edtDS7i: TEdit;
    edtZKorrekcio: TEdit;
    edtDKorrekcio: TEdit;
    edtSorozatszam: TEdit;
    edtSKorrekcio: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    memMegjegyzes: TMemo;
    Serial: TLazSerial;
    procedure btnFejBerakasClick(Sender: TObject);
    procedure btnMegsemClick(Sender: TObject);
    procedure chkSorrolJottLeChange(Sender: TObject);
    procedure chkUjFejChange(Sender: TObject);
    procedure cmbSorozatszamChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    myDataset:          TSqlite3Dataset;

  public
    { public declarations }
  end;

var
  frmFejBehelyezes: TfrmFejBehelyezes;

implementation

{$R *.lfm}

uses fomenu;

{ TfrmFejBehelyezes }

procedure TfrmFejBehelyezes.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmFejBehelyezes.Hide;
  frmFomenu.Show;
end;

procedure TfrmFejBehelyezes.FormActivate(Sender: TObject);
begin
  //combok feltöltése a db-ből :
  cmbFejtipus.Clear;
  myDataset := dbConnect('fej_tipus ','SELECT * FROM fej_tipus WHERE fej_torolve=0 ORDER BY id;','id');
  Repeat
    cmbFejtipus.Items.AddObject(myDataset.FieldByName('fej_tipus').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbFejtipus.Text:=myDataset.FieldByName('fej_tipus').AsString;

  //fej állapot
  cmbFejallapot.Clear;
  dbUpdate(myDataset,'SELECT * FROM fej_allapot WHERE fej_allapot_torolve=0 ORDER BY id;');
  Repeat
    cmbFejallapot.Items.AddObject(myDataset.FieldByName('fej_allapot').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbFejallapot.Text:=myDataset.FieldByName('fej_allapot').AsString;

  //sorozatszámok:
  //csak azok a fejek kerülnek a listába amik nincsenek a szekrényben és nincsenek törölve!!!
  cmbSorozatszam.Clear;
  dbUpdate(myDataset,'SELECT * FROM fej WHERE hely <> 1 AND torolve = 0 ORDER BY sorozatszam;');
  Repeat
    cmbSorozatszam.Items.AddObject(myDataset.FieldByName('sorozatszam').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbSorozatszam.Text:=myDataset.FieldByName('sorozatszam').AsString;


  dbClose(myDataset);

  edtDKorrekcio.Text := '0';
  edtSKorrekcio.Text := '0';
  edtSorozatszam.Text := '';
  edtZKorrekcio.Text := '0';
  memMegjegyzes.Text := '';

  {
  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          ShowMessage('Port megnyitása nem sikerült, próbáld meg újra!');
          exit;
       end;
  end;
  }

  chkUjFej.Visible := true;
  chkUjFej.Checked := false;
  chkUjFejChange(Sender);
  if (iAdmin <> 2) then chkUjFej.Visible := false;


  //chkSorrolJottLeChange(Sender);
  edtSorozatszam.Text := cmbSorozatszam.Text;
  cmbSorozatszamChange(Sender);
  edtDS7i.Text := '';

end;

procedure TfrmFejBehelyezes.btnMegsemClick(Sender: TObject);
begin
     frmFejBehelyezes.Hide;
     frmFomenu.Show;
end;

procedure TfrmFejBehelyezes.chkSorrolJottLeChange(Sender: TObject);
begin
  {
  //Ha be van kapcsolva akkor át kell másolni a sor/gép adatokat a fej táblából!!
  if (chkSorrolJottLe.Checked) then
  begin
      cmbSor.Enabled := true;
      cmbGeptipus.Enabled := true;
      cmbPortal.Enabled := true;
      edtDS7i.Enabled := true;
  end
  else
  begin
      cmbSor.Enabled := false;
      cmbGeptipus.Enabled := false;
      cmbPortal.Enabled := false;
      edtDS7i.Enabled := false;
  end;
  }
end;

procedure TfrmFejBehelyezes.chkUjFejChange(Sender: TObject);
begin
  if chkUjFej.Checked then
  begin
      //A fej még nem szerepel az adatbázisban:
      edtSorozatszam.Enabled := true;
      edtSorozatszam.Visible := true;
      cmbSorozatszam.Enabled := false;
      cmbSorozatszam.Visible := false;
      cmbFejtipus.Enabled := true;
      edtSorozatszam.Text := '';
      edtSorozatszam.SetFocus;
  end
  else
  begin
      edtSorozatszam.Enabled := false;
      edtSorozatszam.Visible := false;
      cmbSorozatszam.Enabled := true;
      cmbSorozatszam.Visible := true;
      cmbFejtipus.Enabled := false;
  end;
end;

procedure TfrmFejBehelyezes.cmbSorozatszamChange(Sender: TObject);
var
  iFej, iFejTipus:   integer;
begin
  //sorozatszám kiválasztásakor be kell állítani a fej típusát illetve a "régi" fejadatokat:
  iFej := integer(cmbSorozatszam.Items.Objects[cmbSorozatszam.ItemIndex]);

  myDataset := dbConnect('fej','SELECT * FROM fej WHERE id = ' + IntToStr(iFej) + ';','id');
  edtSKorrekcio.Text := myDataset.FieldByName('s_korr').AsString;
  edtZKorrekcio.Text := myDataset.FieldByName('z_korr').AsString;
  edtDKorrekcio.Text := myDataset.FieldByName('d_korr').AsString;

  iFejTipus := myDataset.FieldByName('fej_tipus').AsInteger;
  dbUpdate(myDataset,'SELECT * FROM fej_tipus WHERE id = ' + IntToStr(iFejTipus));
  cmbFejtipus.Text := myDataset.FieldByName('fej_tipus').AsString;

  dbClose(myDataset);

  edtSorozatszam.Text := cmbSorozatszam.Text;

end;

procedure TfrmFejBehelyezes.btnFejBerakasClick(Sender: TObject);
var
  iFejtipus_id,iAjto,iFejallapot_id,i,iUres_szekreny_szama,iFejAzonosito,iHely:                   Integer;
  iFelhasznaltSor,iFelhasznaltGep,iFelhasznaltPortal:                                             Integer;
  sql,sFelhasznaltGepDS7i:                                                                        string;

begin

  //fej berakása a szekrénybe:
  iFejtipus_id := integer(cmbFejtipus.Items.Objects[cmbFejtipus.ItemIndex]);
  iFejallapot_id := integer(cmbFejallapot.Items.Objects[cmbFejallapot.ItemIndex]);

  //kell keresni egy üres szekrényt(polcot)...
  iUres_szekreny_szama := -1;
  sql := 'SELECT fejberakas.be_ajto as ajto,fejberakas.be_datum,fejberakas.be_ido, fej.sorozatszam, fej_tipus.fej_tipus FROM fej '
          + 'JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id '
          + 'JOIN fejberakas ON fej.id = fejberakas.fej_id '
          + 'WHERE fej.hely=1 GROUP BY sorozatszam ORDER BY be_ajto, be_datum, be_ido;';
  myDataset := dbConnect('fej',sql,'id');
  if myDataset.RecordCount = 0 then iUres_szekreny_szama := 1;    //még nincs fej a szekrényben...
  if myDataset.RecordCount = ferohelyek then
  begin
      ShowMessage('A szekrénybe nem helyezhető több fej!');
      dbClose(myDataset);
      exit;
  end;
  if myDataset.RecordCount > 0 then
  begin
       for i := 1 to ferohelyek do
       begin
            if (i > myDataset.RecordCount) or (i <> myDataset.FieldByName('ajto').AsInteger) then
            begin
                 iUres_szekreny_szama := i;
                 break;
            end;
            myDataset.Next;
       end;
  end;

  if trim(edtSorozatszam.Text) = '' then
  begin
       ShowMessage('Sorozatszám mező kitöltése kötelező!');
       edtSorozatszam.SetFocus;
       //if COMPORT_VEZERLES = 1 then Serial.Close;
       exit;
  end;

  //Ha a fej alkatrészre vár akkor a megjegyzés rovatban fel kell tüntetni a
  //hiányzó alkatrészeket....azaz nem lehet üres a megj. mező!!
  if (iFejallapot_id = 7) and (Trim(memMegjegyzes.Text) = '') then
  begin
       ShowMessage('A hiányzó alkatrészeket fel kell vinni a "Megjegyzés" mezőbe!!');
       memMegjegyzes.SetFocus;
       exit;
  end;

  if trim(edtSKorrekcio.Text) = '' then edtSKorrekcio.Text := '0';
  if trim(edtDKorrekcio.Text) = '' then edtDKorrekcio.Text := '0';
  if trim(edtZKorrekcio.Text) = '' then edtZKorrekcio.Text := '0';

  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          ShowMessage('Port megnyitása nem sikerült, próbáld meg újra!');
          exit;
       end;
  end;
  Sleep(250);

  if chkUjFej.Checked then
      begin
           //Ha már van ilyen sorozatszámú fej akkor szólni kell:
           dbUpdate(myDataset,'select * from fej where sorozatszam = "' + UpperCase(edtSorozatszam.Text) +
                '" and torolve = 0;');
           if myDataset.RecordCount > 0 then
               begin
                    dbClose(myDataset);
                    if COMPORT_VEZERLES = 1 then Serial.Close;
                    ShowMessage('Ez a sorozatszámú fej már szerepel az adatbázisban!' + #10 +
                      'Sorozatszam : ' + edtSorozatszam.Text);
                    exit;
               end;
          //Ha az adatbázisban még nem szerepel a fej akkor fel kell vinni:
          dbUpdate(myDataset, 'select * from fej order by id;');
          with myDataset do
            begin
                Insert;
                FieldByName('fej_tipus').AsInteger := iFejtipus_id;
                FieldByName('sorozatszam').AsString := UpperCase(edtSorozatszam.Text);
                FieldByName('z_korr').AsInteger := StrToInt(edtZKorrekcio.Text);
                FieldByName('d_korr').AsInteger := StrToInt(edtDKorrekcio.Text);
                FieldByName('s_korr').AsInteger := StrToInt(edtSKorrekcio.Text);
                FieldByName('hely').AsInteger := 1;
                FieldByName('felh_sor_id').AsInteger := -1;
                FieldByName('felh_gep_id').AsInteger := -1;
                FieldByName('felh_gep_ds7i').AsString := '';
                FieldByName('felh_portal').AsInteger := -1;
                Post;
                ApplyUpdates;
            end;
          dbClose(myDataset);
          //utoljára berakott fej azonosítója:
          myDataset := dbConnect('fej','SELECT * FROM fej ORDER BY id;','id');
          myDataset.Last;
          iFejAzonosito := myDataset.FieldByName('id').AsInteger;
          dbClose(myDataset);
      end
  else
      begin
          //Már szerepel, "csak" frissíteni kell az adatokat...
          iFejAzonosito := integer(cmbSorozatszam.Items.Objects[cmbSorozatszam.ItemIndex]);
          dbUpdate(myDataset, 'SELECT * FROM fej WHERE id = ' + IntToStr(iFejAzonosito) + ';');
          iHely := myDataset.FieldByName('hely').AsInteger;
          if (iHely = 2) then
              begin
                  //sorról lett levéve a fej, kellenek az adotok későbbre a fejberakas tábla bővítésekor:
                  iFelhasznaltSor := myDataset.FieldByName('felh_sor_id').AsInteger;
                  iFelhasznaltGep := myDataset.FieldByName('felh_gep_id').AsInteger;
                  iFelhasznaltPortal := myDataset.FieldByName('felh_portal').AsInteger;
                  sFelhasznaltGepDS7i := myDataset.FieldByName('felh_gep_ds7i').AsString;
              end;
          with myDataset do
            begin
                Edit;
                FieldByName('z_korr').AsInteger := StrToInt(edtZKorrekcio.Text);
                FieldByName('d_korr').AsInteger := StrToInt(edtDKorrekcio.Text);
                FieldByName('s_korr').AsInteger := StrToInt(edtSKorrekcio.Text);
                FieldByName('hely').AsInteger := 1;
                FieldByName('felh_sor_id').AsInteger := -1;
                FieldByName('felh_gep_id').AsInteger := -1;
                FieldByName('felh_gep_ds7i').AsString := '';
                FieldByName('felh_portal').AsInteger := -1;
                Post;
                ApplyUpdates;
            end;
          dbClose(myDataset);
      end;

  //Fejberakás tábla bővítése:
  myDataset := dbConnect('fejberakas','select * from fejberakas order by id;','id');
  with myDataset do
    begin
        Insert;
        FieldByName('fej_id').AsInteger := iFejAzonosito;
        FieldByName('be_u_id').AsInteger := userDB_ID;
        FieldByName('be_datum').AsString := FormatDateTime('yyyy-mm-dd',Now);
        FieldByName('be_ido').AsString := FormatDateTime('hh-nn',Now);
        FieldByName('be_megj').AsString := memMegjegyzes.Text;
        FieldByName('be_ajto').AsInteger := iUres_szekreny_szama;                //ezt a számú szekrényajtót kell nyitni majd
        FieldByName('be_allapot').AsInteger := iFejallapot_id;
        //Ha sorról jött le a fej akkor át kell másolni a sor/gép adatokat a fej táblából!!
        if (chkSorrolJottLe.Checked) then
            begin
                FieldByName('sorrol_id').AsInteger := iFelhasznaltSor;
                FieldByName('geprol_id').AsInteger := iFelhasznaltGep;
                FieldByName('portalrol').AsInteger := iFelhasznaltPortal;
                FieldByName('geprol_ds7i').AsString := sFelhasznaltGepDS7i;
            end
        else
            begin
                FieldByName('sorrol_id').AsInteger := -1;
                FieldByName('geprol_id').AsInteger := -1;
                FieldByName('portalrol').AsInteger := -1;
                FieldByName('geprol_ds7i').AsString := '';
            end;
        Post;
        ApplyUpdates;
    end;
	dbClose(myDataset);

  if COMPORT_VEZERLES = 1 then
  begin
      //Ajtó kinyitása:
      //Sleep(100);
      Serial.WriteData('gpio set ' + chr(70 + iUres_szekreny_szama) + chr(13));
      //Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
      Sleep(10);
      ShowMessage('A(z) ' + IntToStr(iUres_szekreny_szama) + ' . számú ajtó nyitva a fej behelyezhető!!' + #10 + #10 +
                        'FIGYELEM!!' + #10 + #10 + 'Az OK-gomb megnyomására az ajtó bezárul!!');
      //Zár visszazárása:
      Serial.WriteData('gpio clear ' + chr(70 + iUres_szekreny_szama) + chr(13));
      //Sleep(1000);
      Serial.Close;
  end
  else
      ShowMessage('A(z) ' + IntToStr(iUres_szekreny_szama) + ' . számú ajtó nyitva a fej behelyezhető!!');

  frmFejBehelyezes.Hide;
  frmFomenu.Show;

end;

end.

