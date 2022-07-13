unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sqlite3DS, db, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, DBGrids, ExtCtrls, database, global, IniFiles;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnBelepes: TButton;
    btnJelszoMod: TButton;
    cmbUsers: TComboBox;
    DataSource1: TDataSource;
    edtJelszo: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape1: TShape;
    Sqlite3Dataset1: TSqlite3Dataset;
    stgHasznalhatoFejek: TStringGrid;
    stgNemHasznalhatoFejek: TStringGrid;
    procedure btnBelepesClick(Sender: TObject);
    procedure btnJelszoModClick(Sender: TObject);
    procedure edtJelszoKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure stgNemHasznalhatoFejekDrawCell(Sender: TObject; aCol,
      aRow: Integer; aRect: TRect; aState: TGridDrawState);

  private
    { private declarations }
    myDataset:          TSqlite3Dataset;


  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  IniFile: TIniFile;
  iNemHasznalhatoFejek : array of integer;

implementation

{$R *.lfm}

{ TfrmMain }
uses jelszomod,fomenu;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //IniFile.Free;
  Application.Terminate;

end;

procedure TfrmMain.stgNemHasznalhatoFejekDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);

begin
  if iNemHasznalhatoFejek[aRow] = 1 then stgNemHasznalhatoFejek.Canvas.Brush.Color := clRed;
  if iNemHasznalhatoFejek[aRow] = 2 then stgNemHasznalhatoFejek.Canvas.Brush.Color := clYellow;

  stgNemHasznalhatoFejek.Canvas.FillRect(aRect);
  stgNemHasznalhatoFejek.Canvas.TextRect(aRect,aRect.Left,aRect.Top,stgNemHasznalhatoFejek.Cells[ACol,ARow]);

end;

procedure TfrmMain.btnBelepesClick(Sender: TObject);
var
  pass,dbpass            :string;

begin
  if (cmbUsers.ItemIndex < 0) then
     begin
          ShowMessage('Egy felhasználót ki kell választani !');
          exit;
     end;
  //jelszó ell.:
  userDB_ID := integer(cmbUsers.Items.Objects[cmbUsers.ItemIndex]);
  userName := cmbUsers.Text;
  myDataset := dbConnect('felhasznalok ','Select * From felhasznalok where id = '+IntToStr(userDB_ID),'id');
  dbpass := myDataset.FieldByName('u_jelszo').AsString;
  //dbpass := myDataset.FieldByName('u_wdnum').AsString;
  iAdmin := myDataset.FieldByName('u_perm').AsInteger;
  dbClose(myDataset);

  pass := edtJelszo.Text;
  if (dbpass <> pass) then
  begin
      ShowMessage('A beírt azonosító nem helyes !');
      edtJelszo.Text:='';
      edtJelszo.SetFocus;
      exit;
  end;

  //belépés ok, mehet a főmenübe:
  Sqlite3Dataset1.Close;
  frmMain.Hide;
  frmFomenu.Show;
end;

procedure TfrmMain.btnJelszoModClick(Sender: TObject);
begin
  userDB_ID := integer(cmbUsers.Items.Objects[cmbUsers.ItemIndex]);
  userName := cmbUsers.Text;

  frmMain.Hide;
  frmJelszomod.Show;
end;

procedure TfrmMain.edtJelszoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then btnBelepesClick(Sender);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
var
  sql:  string;
  be_allapot,iJoFejek,iRosszFejek,i,j,iRecNum:  integer;

begin
  //beállítások beolvasása az ini fájlból:
  IniFile := TIniFile.Create(ExtractFilePath(Application.EXEName) + 'beallitasok.ini');

  if not FileExists(ExtractFilePath(Application.EXEName) + 'beallitasok.ini') then
      begin
          COM_port_name := 'COM7';
          ferohelyek := 8;
          COMPORT_VEZERLES := 1;
          IniFile.WriteString('Beallitasok', 'COM_port', 'COM7');
          IniFile.WriteString('Beallitasok', 'ferohelyek_szama', IntToStr(ferohelyek));
          IniFile.WriteString('Beallitasok', 'comport_vezerles', IntToStr(COMPORT_VEZERLES));
          ShowMessage('beallitasok.ini fájlt létrehoztam az alapértelmezett beállításokkal!');
      end
  else
      begin
           COM_port_name := IniFile.ReadString('Beallitasok', 'COM_port', 'COM7');
           ferohelyek := StrToInt(IniFile.ReadString('Beallitasok', 'ferohelyek_szama', '8'));
           COMPORT_VEZERLES := StrToInt(IniFile.ReadString('Beallitasok', 'comport_vezerles', '1'));
      end;
  IniFile.Free;

  //combo feltöltése a db-ből :
  cmbUsers.Clear;
  myDataset := dbConnect('felhasznalok','SELECT * FROM felhasznalok WHERE u_del=0 ORDER BY u_name;','id');
  if (myDataset.RecordCount > 0) then
  begin
      Repeat
            cmbUsers.Items.AddObject(myDataset.FieldByName('u_name').AsString,
            TObject(myDataset.FieldByName('id').AsInteger));
            myDataset.Next;
      Until myDataset.Eof;
      myDataset.First;
      cmbUsers.Text:=myDataset.FieldByName('u_name').AsString;
  end;

  //Szekrényekben lévő fejek:
  sql := 'select * from szekrenyben_levo_fejek;';   //sqlite3 view...

  dbUpdate(myDataset,sql);
  iJoFejek := 1;
  iRosszFejek := 1;
  {
  for i := 0 to stgHasznalhatoFejek.ColCount-1 do
    for j := 1 to stgHasznalhatoFejek.RowCount-1 do
        stgHasznalhatoFejek.Cells[i,j] := '';
  for i := 0 to stgNemHasznalhatoFejek.ColCount-1 do
    for j := 1 to stgNemHasznalhatoFejek.RowCount-1 do
        stgNemHasznalhatoFejek.Cells[i,j] := '';
        }

  iRecNum := myDataset.RecordCount;
  //ShowMessage(inttostr(iRecNum));
  SetLength(iNemHasznalhatoFejek, iRecNum + 1);
  stgHasznalhatoFejek.RowCount := 1;

  with myDataset do
  begin
    if (RecordCount > 0) then
      begin
          Repeat
                be_allapot := FieldByName('allapot_id').AsInteger;
                //felhasználható fejek:
                if (be_allapot = 1) or (be_allapot = 3) or (be_allapot = 9) then
                begin
                    stgHasznalhatoFejek.InsertRowWithValues(iJoFejek,[inttostr(FieldByName('be_ajto').AsInteger),FieldByName('be_datum').AsString,
                    FieldByName('ido').AsString,FieldByName('be_megj').AsString,FieldByName('sn').AsString,FieldByName('tip').AsString,FieldByName('allapot').AsString]);
                    iJoFejek += 1;
                end;

                //"rossz" fejek:
                if (be_allapot <> 1) and (be_allapot <> 3) and (be_allapot <> 9) then
                begin
                    stgNemHasznalhatoFejek.InsertRowWithValues(iRosszFejek,[inttostr(FieldByName('be_ajto').AsInteger),FieldByName('be_datum').AsString,
                    FieldByName('ido').AsString,FieldByName('be_megj').AsString,FieldByName('sn').AsString,FieldByName('tip').AsString,FieldByName('allapot').AsString]);
                    iNemHasznalhatoFejek[iRosszFejek] := 1;  //Rossz, pirossal kell jelölni a sort!
                    if (be_allapot = 2) or (be_allapot = 8) then
                       iNemHasznalhatoFejek[iRosszFejek] := 2;  //Nem tesztelt fej, sárgával kell jelölni
                    iRosszFejek += 1;
                end;

                myDataset.Next;
          Until myDataset.Eof;
      end;
  end;

  dbClose(myDataset);
  edtJelszo.Text := '';
  cmbUsers.SetFocus;

end;

end.

