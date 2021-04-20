unit jelszomod;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  global, database, Sqlite3DS;

type

  { TfrmJelszomod }

  TfrmJelszomod = class(TForm)
    btnMegsem: TButton;
    btnModosit: TButton;
    edtUjJelszo: TEdit;
    edtRegiJelszo: TEdit;
    edtUjJelszoUjra: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnModositClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    { private declarations }
    myDataset:          TSqlite3Dataset;

  public
    { public declarations }
  end;

var
  frmJelszomod: TfrmJelszomod;

implementation

{$R *.lfm}

{ TfrmJelszomod }
uses main;

procedure TfrmJelszomod.btnModositClick(Sender: TObject);
var
   oldpass,newpass,newpass2,dbpass: string;
begin
     //Jelszómódosítás...
     oldpass := edtRegiJelszo.Text;
     newpass := edtUjJelszo.Text;
     newpass2 := edtUjJelszoUjra.Text;

     if (newpass <> newpass2) then
     begin
          ShowMessage('Az új jelszavak nem egyeznek !');
          exit;
     end;

     if ((Trim(oldpass) = '') or (Trim(newpass) = '') or (Trim(newpass2) = '')) then
     begin
          ShowMessage('A jelszó mezők nem lehetnek üresek !');
          exit;
     end;

     myDataset := dbConnect('felhasznalok','Select * from felhasznalok WHERE id=' + IntToStr(userDB_ID),'id');
     dbpass := myDataset.FieldByName('u_jelszo').AsString;
     if (dbpass <> oldpass) then
     begin
          dbClose(myDataset);
          ShowMessage('A beírt jelszó nem helyes !');
          edtRegiJelszo.Text := '';
          edtRegiJelszo.SetFocus;
          exit;
     end;
     //frissítés a db-be:
     myDataset.Edit;
     myDataset.FieldByName('u_jelszo').AsString := newpass;
     myDataset.Post;
     myDataset.ApplyUpdates;
     dbUpdate(myDataset,'Select * from felhasznalok Order By u_name;');
     dbClose(myDataset);
     ShowMessage('A jelszó módosítás sikerült !');
     frmJelszomod.Hide;
     frmMain.Show;
end;

procedure TfrmJelszomod.FormActivate(Sender: TObject);
begin
  edtRegiJelszo.Text:='';
  edtUjJelszo.Text:='';
  edtUjJelszoUjra.Text:='';
end;

procedure TfrmJelszomod.FormClose(Sender: TObject; var CloseAction: TCloseAction );
begin
     frmJelszomod.Hide;
     frmMain.Show;
end;

end.

