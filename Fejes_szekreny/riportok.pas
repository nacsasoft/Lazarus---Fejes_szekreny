unit riportok;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, global, database, Sqlite3DS, db, comobj;

type

  { TfrmRiportok }

  TfrmRiportok = class(TForm)
    btnHasznalatbanLevoFejek: TButton;
    btnFejcserek: TButton;
    btnSzekrenybenLevoFejek: TButton;
    edtTol: TEdit;
    edtIg: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnFejcserekClick(Sender: TObject);
    procedure btnHasznalatbanLevoFejekClick(Sender: TObject);
    procedure btnSzekrenybenLevoFejekClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    myDataset           :TSqlite3Dataset;

    procedure ReportToExcel(sExcelLapCim: string; sQuerySQL: string; sTabla: string);
    procedure ReportPasteToExcel();

  public
    { public declarations }
  end;

var
  frmRiportok: TfrmRiportok;

implementation

uses fomenu;

{$R *.lfm}

{ TfrmRiportok }

procedure TfrmRiportok.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  frmRiportok.Hide;
  frmFomenu.Show;
end;

procedure TfrmRiportok.btnHasznalatbanLevoFejekClick(Sender: TObject);
Var
      sSql  :string;
begin
    //Használatban lévő fejek:
    sSql := 'SELECT fej.felh_gep_ds7i, fej.sorozatszam, gepek.gep_tipus, fej_tipus.fej_tipus, sorok.sor_name, fej.felh_portal as Portál from fej '
            + 'JOIN gepek ON fej.felh_gep_id = gepek.id '
            + 'JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id '
            + 'JOIN sorok ON fej.felh_sor_id = sorok.id '
            + 'WHERE fej.hely=2 ORDER BY sorok.sor_name;';
    ReportToExcel('Használatban lévő fejek',sSql,'fej');
end;

procedure TfrmRiportok.btnFejcserekClick(Sender: TObject);
var
  sSQL : ansistring;
begin
    //Adott időszakban történt fejcserék:
    sSQL := 'SELECT felhasznalok.u_name as Név, fejkivetel.ki_datum, fej.sorozatszam, fej_tipus.fej_tipus, ' +
            'sorok.sor_name as Sor, fej.felh_gep_ds7i as DS7i, gepek.gep_tipus, fej.felh_portal FROM fej ' +
            'JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id ' +
            'JOIN felhasznalok ON fejkivetel.ki_u_id = felhasznalok.id ' +
            'JOIN fejkivetel ON fej.id = fejkivetel.fej_id ' +
            'JOIN sorok ON fej.felh_sor_id = sorok.id ' +
            'JOIN gepek ON fej.felh_gep_id = gepek.id ' +
            'WHERE hely <> 1 AND ki_datum >= "' + edtTol.Text + '" AND ki_datum <= "' + edtIg.Text + '" AND gepre_ds7i <> "" ' +
            'AND (fejkivetel.ki_oka = 1) ORDER BY ki_datum,Sor';
    ReportToExcel('Fejcserék',sSql,'fej');
end;

procedure TfrmRiportok.btnSzekrenybenLevoFejekClick(Sender: TObject);
Var
      sSql  :string;
begin
  //Szekrényben lévő fejek:
  sSql := 'SELECT * FROM szekrenyben_levo_fejek;';
  ReportToExcel('Szekrényben lévő fejek',sSql,'fejberakas');
end;

procedure TfrmRiportok.FormActivate(Sender: TObject);
var
      sDate,sTol:	string;
begin
   sDate := FormatDateTime('YYYY-MM-DD',Now);
   sTol := FormatDateTime('YYYY-MM-',Now)+'01';

   edtTol.Text := sTol;
   edtIg.Text := sDate;



end;

procedure TfrmRiportok.ReportPasteToExcel();
//Vágólapon lévő adatok (riport a Memo1-ből) beillesztése az excelbe....
var
    XLApp,munkalap       :OLEVariant;
    aName                 :Variant;
begin
  XLApp := CreateOleObject('Excel.Application');
      try
       XLApp.Visible := true;
       XLApp.DisplayAlerts := true;

       XLApp.Workbooks.Add;
       munkalap := XLApp.Workbooks[1].WorkSheets[1];
       aName := 'Riport';
       munkalap.Name := aName;

       munkalap.Paste;

       //oszlopok szélességének beállítása:
       munkalap.Range['A1:Z1'].EntireColumn.AutoFit;

     finally
       //XLApp.Quit;
       //XLAPP := Unassigned;
	    end;
end;

procedure TfrmRiportok.ReportToExcel(sExcelLapCim: string; sQuerySQL: ansistring; sTabla: string);
//Átvett dataset kiírása excel-be:
var
   XLApp,munkalap       :OLEVariant;
   aData,aName,aRange   :Variant;
   i,x,y                :integer;
   reportDataset        :TSqlite3Dataset;

begin
     XLApp := CreateOleObject('Excel.Application');
  try
      reportDataset := dbConnect(sTabla,sQuerySQL,'id');
      if (reportDataset.RecordCount < 1) then
      begin
        dbClose(reportDataset);
        ShowMessage('A lekérdezés nem adott vissza adatot!');
        exit;
      end;

      XLApp.Visible := true;
      XLApp.DisplayAlerts := true;

      XLApp.Workbooks.Add;
      munkalap := XLApp.Workbooks[1].WorkSheets[1];
      aName := sExcelLapCim;
      munkalap.Name := aName;
      //sleep(1500);

      aRange := 'A1:Z'+IntToStr(reportDataset.RecordCount+2);
      aData := '@'; //Mezők Text formátumra való beállítása.... (az idő miatt kell!!)
      munkalap.Range[aRange].NumberFormat := aData;

      //fejléc kiírása:
      for i := 0 to reportDataset.FieldCount - 1 do
      begin
            aData := reportDataset.Fields[i].FieldName;
            munkalap.Cells[1,i+1].Value := aData;
      end;
      //adatok...
      y := 0;
      repeat
         for x := 0 to reportDataset.FieldCount - 1 do
         begin
              aData := reportDataset.Fields[x].AsString;
              munkalap.Cells[y+2, x+1].Value := aData;
         end;
         y += 1;
         reportDataset.Next;
      until reportDataset.EOF;
      //oszlopok szélességének beállítása:
      munkalap.Range['A1:Z1'].EntireColumn.AutoFit;

      finally
        //XLApp.Quit;
        //XLAPP := Unassigned;
	    end;
      dbClose(reportDataset);
end;

end.

