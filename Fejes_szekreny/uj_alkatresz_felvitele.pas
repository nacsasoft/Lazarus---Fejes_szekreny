unit uj_alkatresz_felvitele;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, mySqliteDatabase,
  ExtCtrls;

type

  { TfrmUjAlkatreszFelvitel }

  TfrmUjAlkatreszFelvitel = class(TForm)
    btnAlkatreszFelvitel: TButton;
    chkAllHeadTypeOnOff: TCheckBox;
    CheckGroup1: TCheckGroup;
    edtMegnevezes: TEdit;
    edtRendelesiSzam: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnAlkatreszFelvitelClick(Sender: TObject);
    procedure CheckGroup1ItemClick(Sender: TObject; Index: integer);
    procedure chkAllHeadTypeOnOffChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmUjAlkatreszFelvitel: TfrmUjAlkatreszFelvitel;

implementation

{$R *.lfm}

{ TfrmUjAlkatreszFelvitel }

uses egyeb_alkatreszek;

procedure TfrmUjAlkatreszFelvitel.FormShow(Sender: TObject);
var
   i:          Integer;

begin
  edtMegnevezes.Text := '';
  edtRendelesiSzam.Text := '';

  chkAllHeadTypeOnOff.Checked := false;

  for i := 0 to CheckGroup1.ControlCount-1 do CheckGroup1.Checked[i] := false;

end;

procedure TfrmUjAlkatreszFelvitel.btnAlkatreszFelvitelClick(Sender: TObject);
var
   myDB : cSqliteDatabase;
   sMegnevezes, sRendelesiSzam : string;
   i, iKijelolesSzama : integer;

begin
  //új alkatrész felvitele az adatbázisba:
  sMegnevezes := edtMegnevezes.Text;
  sRendelesiSzam := edtRendelesiSzam.Text;

  if trim(sMegnevezes) = '' then
  begin
    ShowMessage('Megnevezés mező kitöltése kötelező!');
    edtMegnevezes.SetFocus;
    exit;
  end;

  if trim(sRendelesiSzam) = '' then
  begin
    ShowMessage('Rendelési szám mező kitöltése kötelező!');
    edtRendelesiSzam.SetFocus;
    exit;
  end;

  iKijelolesSzama := 0;
  for i := 0 to CheckGroup1.ControlCount-1 do if CheckGroup1.Checked[i] then inc(iKijelolesSzama);
  if iKijelolesSzama = 0 then
  begin
    ShowMessage('Legalább egy fej típust ki kell választani!');
    exit;
  end;

  //minden kijelölt fejtípushoz fel kell vinni az adatokat:
  myDB := cSqliteDatabase.Create('alkatreszek', 'SELECT * FROM alkatreszek ORDER BY id;', 'id');
  for i := 0 to CheckGroup1.ControlCount-1 do
    begin
      if CheckGroup1.Checked[i] then
      begin
        //fejtípus kijelölve, adatfelvitel:
        with myDB.pDataset do
        begin
            Insert;
            FieldByName('fej_tipus').AsInteger := i+1;
            FieldByName('rendelesi_szam').AsString := sRendelesiSzam;
            FieldByName('megnevezes').AsString := sMegnevezes;
            FieldByName('torolve').AsInteger := 0;
            Post;
        end;
      end;
    end;
  myDB.pDataset.ApplyUpdates;
  myDB.Terminate();

  for i := 0 to CheckGroup1.ControlCount-1 do CheckGroup1.Checked[i] := false;
  edtMegnevezes.Text := '';
  edtRendelesiSzam.Text := '';

  //Egyéb alkatrészek formon frissíteni kell a legördülőt :
  with frmEgyebAlkatreszek do
  begin
    cmbAlkatreszek.Clear;
    myDB := cSqliteDatabase.Create('alkatreszek','SELECT * FROM alkatreszek WHERE torolve = 0 GROUP BY rendelesi_szam ORDER BY rendelesi_szam;', 'id');
    Repeat
      cmbAlkatreszek.Items.AddObject(myDB.pDataset.FieldByName('rendelesi_szam').AsString + ' - ' +
         myDB.pDataset.FieldByName('megnevezes').AsString,
         TObject(myDB.pDataset.FieldByName('id').AsInteger));
      myDB.pDataset.Next;
    Until myDB.pDataset.Eof;
    myDB.pDataset.First;
    cmbAlkatreszek.ItemIndex := 0;
    myDB.Terminate();
  end;

  ShowMessage('Az új alkatrész felvitele megtörtént!');

end;

procedure TfrmUjAlkatreszFelvitel.CheckGroup1ItemClick(Sender: TObject;
  Index: integer);
begin

end;

procedure TfrmUjAlkatreszFelvitel.chkAllHeadTypeOnOffChange(Sender: TObject);
var
   i : integer;
begin
  if chkAllHeadTypeOnOff.Checked then
  begin
    //összes fejtípus kijelölése:
    for i := 0 to CheckGroup1.ControlCount-1 do CheckGroup1.Checked[i] := true;
  end
  else
  begin
    for i := 0 to CheckGroup1.ControlCount-1 do CheckGroup1.Checked[i] := false;
  end;
end;

procedure TfrmUjAlkatreszFelvitel.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmUjAlkatreszFelvitel.Hide;
  frmEgyebAlkatreszek.Show;
end;


end.

