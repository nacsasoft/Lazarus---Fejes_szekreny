unit fejkivetel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LazSerial, Sqlite3DS, database, global;

type

  { TfrmFejKivetel }

  TfrmFejKivetel = class(TForm)
    Bevel1: TBevel;
    btnKivetel: TButton;
    btnMegsem: TButton;
    cmbFejtipus: TComboBox;
    cmbPortal: TComboBox;
    cmbSor: TComboBox;
    cmbKivetelOka: TComboBox;
    cmbGeptipus: TComboBox;
    edtDKorrekcio: TEdit;
    edtSKorrekcio: TEdit;
    edtDS7i: TEdit;
    edtSorozatszam: TEdit;
    edtFejAllapota: TEdit;
    edtAjtoSzama: TEdit;
    edtZKorrekcio: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    memMegjegyzes: TMemo;
    memKiMegjegyzes: TMemo;
    Serial: TLazSerial;
    Timer1: TTimer;
    procedure btnKivetelClick(Sender: TObject);
    procedure btnMegsemClick(Sender: TObject);
    procedure cmbFejtipusChange(Sender: TObject);
    procedure cmbGeptipusChange(Sender: TObject);
    procedure cmbKivetelOkaChange(Sender: TObject);
    procedure cmbSorChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    myDataset:          TSqlite3Dataset;

  public
    { public declarations }
  end;

type r_fejadatok = record
     fejtipus                  :string;
     fej_id                    :integer;                  //fej azonosítója a db-ben
     gepekben_van              :array of string;          //ilyen típusú gépekben van ez a fej...
     ajto                      :integer;                  //ebben a szekrényben van a fej
     sn                        :string;                   //fej sorozatszáma
     allapot                   :string;                   //fej állapota (Új, javításra vár ...)
     s_korr                    :integer;
     z_korr                    :integer;
     d_korr                    :integer;
     megjegyzes                :string;
end;

var
  frmFejKivetel: TfrmFejKivetel;
  fejadatok : array of r_fejadatok;


implementation

{$R *.lfm}

uses fomenu;

{ TfrmFejKivetel }

procedure TfrmFejKivetel.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmFejKivetel.Hide;
  frmFomenu.Show;
end;

procedure TfrmFejKivetel.Timer1Timer(Sender: TObject);
var
  i       :integer;
begin
  //Ajtók bezárása....
  Timer1.Enabled := false;

  if COMPORT_VEZERLES = 1 then
  begin
       //Soros kommunikáció megnyitása...
       try
          Serial.Device := COM_port_name;
          Serial.Open;
       except
          ShowMessage('Port megnyitása nem sikerült, a szekrény automata zárása sikertelen!');
          exit;
       end;
  end;
  Sleep(500);

  for i := 1 to ferohelyek do
  begin
      if COMPORT_VEZERLES = 1 then Serial.WriteData('gpio clear ' + chr(70 + i) + chr(13));
      Sleep(250);
  end;
  Serial.Close;

end;

procedure TfrmFejKivetel.FormActivate(Sender: TObject);

var
  sql       :string;
  iRecNum,i      :integer;

begin
  //szekrényben lévő fejek feltöltése a db-ből :
  cmbFejtipus.Clear;

  sql := 'select * from szekrenyben_levo_fejek;';   //sqlite3 view...

  myDataset := dbConnect('fej',sql,'id');
  iRecNum := myDataset.RecordCount;

  SetLength(fejadatok, iRecNum + 1);
  i := 0;
  cmbFejtipus.Clear;
  Repeat
    cmbFejtipus.Items.AddObject(myDataset.FieldByName('tip').AsString,
    TObject(myDataset.FieldByName('tipus_id').AsInteger));

    fejadatok[i].fejtipus := myDataset.FieldByName('tip').AsString;
    fejadatok[i].fej_id := myDataset.FieldByName('fej_id').AsInteger;
    fejadatok[i].ajto := myDataset.FieldByName('be_ajto').AsInteger;
    fejadatok[i].sn := myDataset.FieldByName('sn').AsString;
    fejadatok[i].allapot := myDataset.FieldByName('allapot').AsString;
    fejadatok[i].s_korr := myDataset.FieldByName('s_korr').AsInteger;
    fejadatok[i].z_korr := myDataset.FieldByName('z_korr').AsInteger;
    fejadatok[i].d_korr := myDataset.FieldByName('d_korr').AsInteger;
    fejadatok[i].megjegyzes := myDataset.FieldByName('be_megj').AsString;
    i := i + 1;

    myDataset.Next;
  Until myDataset.Eof;

  myDataset.First;
  cmbFejtipus.Text := myDataset.FieldByName('tip').AsString;
  edtAjtoSzama.Text := IntToStr(myDataset.FieldByName('be_ajto').AsInteger);
  edtSorozatszam.Text := myDataset.FieldByName('sn').AsString;
  edtFejAllapota.Text := myDataset.FieldByName('allapot').AsString;
  edtSKorrekcio.Text := IntToStr(myDataset.FieldByName('s_korr').AsInteger);
  edtZKorrekcio.Text := IntToStr(myDataset.FieldByName('z_korr').AsInteger);
  edtDKorrekcio.Text := IntToStr(myDataset.FieldByName('d_korr').AsInteger);
  memMegjegyzes.Text := myDataset.FieldByName('be_megj').AsString;

  //kivétellel kapcsolatos mezők (legördülők) kitöltése:
  cmbKivetelOka.Clear;
  dbUpdate(myDataset,'SELECT * FROM ki_okok WHERE ki_torolve = 0 ORDER BY id;');
  Repeat
    cmbKivetelOka.Items.AddObject(myDataset.FieldByName('ki_ok').AsString,
    TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbKivetelOka.Text := myDataset.FieldByName('ki_ok').AsString;
  dbClose(myDataset);

  memKiMegjegyzes.Text := '';

  cmbSor.Enabled := true;
  cmbGeptipus.Enabled := true;
  cmbPortal.Enabled := true;
  cmbPortal.ItemIndex := 0;

  edtDS7i.Text := '';

  //sorok és géptípus beállítása az aktuális fejhez/sorhoz a kivétel oka szerint:
  cmbKivetelOkaChange(Sender);

end;

procedure TfrmFejKivetel.btnMegsemClick(Sender: TObject);
begin
     frmFejKivetel.Hide;
     frmFomenu.Show;
end;

procedure TfrmFejKivetel.btnKivetelClick(Sender: TObject);
var
  fejtipus,ajto,sql,ds7i                                  :string;
  fej_id,felh_sor_id,felh_gep_id,felh_portal_id,ki_ok    :integer;

begin

  //ShowMessage('Beállítások menüből lehet átmenetileg nyitni a szekrényeket!');
  //exit;
  ki_ok := integer(cmbKivetelOka.Items.Objects[cmbKivetelOka.ItemIndex]);

  ds7i := Trim(edtDS7i.Text);

  if ((ki_ok = 1) or (ki_ok = 3)) and (ds7i = '') then
  begin
      //csere / teszt
      ShowMessage('DS7i mező kitöltése kötelező!');
      exit;
  end;

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


  //kiválasztott fej "kiadása" (szekrény nyitása...)
  fejtipus := cmbFejtipus.Text;
  ajto := edtAjtoSzama.Text;
  if MessageDlg ('Beültetőfej kivétele a szekrényből...', fejtipus + ' típusú beültetőfej kivétele a szekrényből!' + #10 + #10 +
  							ajto + '. számú szekrényt nyithatom?',
                mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  fej_id := fejadatok[cmbFejtipus.ItemIndex].fej_id; //integer(cmbFejtipus.Items.Objects[cmbFejtipus.ItemIndex]);
  felh_sor_id := integer(cmbSor.Items.Objects[cmbSor.ItemIndex]);
  felh_gep_id := integer(cmbGeptipus.Items.Objects[cmbGeptipus.ItemIndex]);
  felh_portal_id := StrToInt(cmbPortal.Text);

  sql := 'SELECT * FROM fej WHERE id = ' + IntToStr(fej_id) + ';';

  myDataset := dbConnect('fej',sql,'id');
  myDataset.Edit;
      if (ki_ok = 1) or (ki_ok = 3) then                      //csere / teszt
         begin
         //sorra-gépre kerül a fej!
             myDataset.FieldByName('hely').AsInteger := 2;
             myDataset.FieldByName('felh_sor_id').AsInteger := felh_sor_id;
             myDataset.FieldByName('felh_gep_id').AsInteger := felh_gep_id;
             myDataset.FieldByName('felh_gep_ds7i').AsString := ds7i;
             myDataset.FieldByName('felh_portal').AsInteger := felh_portal_id;
         end
      else if (ki_ok = 2) or (ki_ok = 5) then                 //javítás / preventív
           myDataset.FieldByName('hely').AsInteger := 3       //preventívre/javításra kerül a fej
      else
          myDataset.FieldByName('hely').AsInteger := 0;
  myDataset.Post;
  myDataset.ApplyUpdates;
  dbClose(myDataset);

  //fejkivetel tábla bővítése :
  sql := 'SELECT * FROM fejkivetel ORDER BY id;';
  myDataset := dbConnect('fejkivetel',sql,'id');
  with myDataset do
    begin
        Insert;
         myDataset.FieldByName('fej_id').AsInteger := fej_id;
         myDataset.FieldByName('ki_u_id').AsInteger := userDB_ID;
         myDataset.FieldByName('ki_datum').AsString := FormatDateTime('yyyy-mm-dd',Now);
         myDataset.FieldByName('ki_ido').AsString := FormatDateTime('hh-nn',Now);
         //myDataset.FieldByName('ki_megj').AsString := '';                        //memKiMegjegyzes.Text;
         myDataset.FieldByName('ki_oka').AsInteger := ki_ok;
         myDataset.FieldByName('ki_ajto').AsInteger := StrToInt(ajto);

         if (ki_ok = 1) or (ki_ok = 3) then                      //csere / teszt
         begin
         //sorra-gépre kerül a fej!
             myDataset.FieldByName('sorra_id').AsInteger := felh_sor_id;
             myDataset.FieldByName('gepre_id').AsInteger := felh_gep_id;
             myDataset.FieldByName('gepre_ds7i').AsString := ds7i;
             myDataset.FieldByName('portalra').AsInteger := felh_portal_id;
         end
         else
         begin
              myDataset.FieldByName('sorra_id').AsInteger := -1;
              myDataset.FieldByName('gepre_id').AsInteger := -1;
              myDataset.FieldByName('gepre_ds7i').AsString := '';
              myDataset.FieldByName('portalra').AsInteger := -1;
         end;
        Post;
        ApplyUpdates;
    end;
	dbClose(myDataset);

  if COMPORT_VEZERLES = 1 then
  begin
      //Ajtó kinyitása:
      //Sleep(100);
      Serial.WriteData('gpio set ' + chr(70 + StrToInt(ajto)) + chr(13));
      //Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
      Sleep(10);
      ShowMessage('A(z) ' + ajto + ' . számú ajtó nyitva a fej kivehető!!');
      //Zár visszazárása:
      Serial.WriteData('gpio clear ' + chr(70 + StrToInt(ajto)) + chr(13));
      //Sleep(1000);
      Serial.Close;
      //30 sec után automatikusan be kell zárni az ajtó(kat):
      Timer1.Interval := 30000;
      Timer1.Enabled := True;
  end
  else
      ShowMessage('A(z) ' + ajto + ' . számú ajtó nyitva a fej kivehető!!');

  frmFejKivetel.Hide;
  frmFomenu.Show;

end;

procedure TfrmFejKivetel.cmbFejtipusChange(Sender: TObject);
var
  i       :integer;
begin
  //fejhez tartozó adatok frissítése:
  i := cmbFejtipus.ItemIndex;
  edtAjtoSzama.Text := IntToStr(fejadatok[i].ajto);
  edtSorozatszam.Text := fejadatok[i].sn;
  edtFejAllapota.Text := fejadatok[i].allapot;
  edtSKorrekcio.Text := IntToStr(fejadatok[i].s_korr);
  edtZKorrekcio.Text := IntToStr(fejadatok[i].z_korr);
  edtDKorrekcio.Text := IntToStr(fejadatok[i].d_korr);
  memMegjegyzes.Text := fejadatok[i].megjegyzes;

  cmbKivetelOkaChange(Sender);
  //cmbSorChange(Sender);

end;

procedure TfrmFejKivetel.cmbGeptipusChange(Sender: TObject);
var
  iGepAzonosito                                        :integer;
  sql                                                  :string;

begin
  // Géptípus változáskor frissíteni kell a géphez tartozó ds7i-t
  iGepAzonosito := integer(cmbGeptipus.Items.Objects[cmbGeptipus.ItemIndex]);
  sql := 'SELECT * FROM gep_infok WHERE id = ' + inttostr(iGepAzonosito);

  myDataset := dbConnect('gep_infok',sql,'id');

  edtDS7i.Text := myDataset.FieldByName('gep_ds7i').AsString;

  dbClose(myDataset);

end;

procedure TfrmFejKivetel.cmbKivetelOkaChange(Sender: TObject);
var
  sql           :string;
  okid,fej_tipus    :integer;

begin
  edtDS7i.Enabled := false;
  //Ha a kivétel oka = csere,teszt,alkatrész levétel  akkor csak azokat a gépeket és sorokat szabad megjeleníteni ahova fejet fel lehet rakni!!
  okid := integer(cmbKivetelOka.Items.Objects[cmbKivetelOka.ItemIndex]);
  if (okid = 1) or (okid = 3) or (okid = 4) then
     begin
         cmbSor.Enabled := true;
         cmbGeptipus.Enabled := true;
         cmbPortal.Enabled := true;
         cmbPortal.ItemIndex := 0;

         if (okid = 1) or (okid = 3) then edtDS7i.Enabled := true;

         fej_tipus := integer(cmbFejtipus.Items.Objects[cmbFejtipus.ItemIndex]);
         //sorok kigyüjtése:
         sql := 'SELECT gep_infok.*, sorok.sor_name as sorname FROM gep_infok '
                + 'JOIN sorok ON gep_infok.sorban = sorok.id '
                + 'WHERE (gep_infok.fej_tipus_1 = ' + IntToStr(fej_tipus) + ') OR (gep_infok.fej_tipus_2 = ' + IntToStr(fej_tipus) + ') OR '
                + '(gep_infok.fej_tipus_3 = ' + IntToStr(fej_tipus) + ') OR (gep_infok.fej_tipus_4 = ' + IntToStr(fej_tipus) + ') '
                + 'AND (sorok.sor_torolve = 0 AND gep_infok.gep_torolve = 0) '
                + 'GROUP BY sorok.sor_name ORDER BY sorok.sor_name;';

         myDataset := dbConnect('gep_infok',sql,'id');
         cmbSor.Clear;
         cmbSor.Refresh;
         Repeat
               cmbSor.Items.AddObject(myDataset.FieldByName('sorname').AsString,
               TObject(myDataset.FieldByName('sorban').AsInteger));
               myDataset.Next;
         Until myDataset.Eof;
         myDataset.First;
         cmbSor.Text := myDataset.FieldByName('sorname').AsString;
         dbClose(myDataset);
         cmbSorChange(sender);
         exit;
     end
  else
      begin
           cmbSor.Enabled := false;
           cmbGeptipus.Enabled := false;
           cmbPortal.Enabled := false;
      end;


end;

procedure TfrmFejKivetel.cmbSorChange(Sender: TObject);
var
  sql                                         :string;
  fej_tipus,sor_id                            :integer;
begin
  //a kiválasztott sorba való gép(ek) kigyüjtése:
  fej_tipus := integer(cmbFejtipus.Items.Objects[cmbFejtipus.ItemIndex]);
  sor_id := integer(cmbSor.Items.Objects[cmbSor.ItemIndex]);

  sql := 'SELECT gep_infok.*, sorok.sor_name as sorname, gepek.gep_tipus as gep FROM gep_infok '
          + 'JOIN gepek ON gep_infok.gep_tipus = gepek.id '
          + 'JOIN sorok ON gep_infok.sorban = sorok.id '
          + 'WHERE sorok.id = ' + IntToStr(sor_id) + ' AND ((gep_infok.fej_tipus_1 = ' + IntToStr(fej_tipus) + ') OR '
          + '(gep_infok.fej_tipus_2 = ' + IntToStr(fej_tipus) + ') OR '
          + '(gep_infok.fej_tipus_3 = ' + IntToStr(fej_tipus) + ') OR (gep_infok.fej_tipus_4 = ' + IntToStr(fej_tipus) + ')) '
          + 'AND ((sorok.sor_torolve = 0) AND (gep_infok.gep_torolve = 0) AND (gepek.gep_torolve = 0)) '
          + 'GROUP BY gep_infok.gep_ds7i ORDER BY sorok.sor_name;';

  //ShowMessage(sql);

  myDataset := dbConnect('gep_infok',sql,'id');

  ShowMessage(inttostr(myDataset.RecordCount));

  cmbGeptipus.Clear;
  cmbGeptipus.Refresh;
  Repeat
       cmbGeptipus.Items.AddObject(myDataset.FieldByName('gep').AsString,
       TObject(myDataset.FieldByName('gep_tipus').AsInteger));
       myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbGeptipus.Text := myDataset.FieldByName('gep').AsString;
  edtDS7i.Text := myDataset.FieldByName('gep_ds7i').AsString;
  dbClose(myDataset);

end;

end.

