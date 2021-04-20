program FejesSzekrenyVezerles;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LazSerialPort, laz_fpspreadsheet_visual, sqlite3laz, main, global,
  database, fomenu, jelszomod, fejkivetel, fejbehelyezes, settings, prevkarb,
  riportok, progress, egyeb_alkatreszek, uj_alkatresz_felvitele
  { you can add units after this };

{$R *.res}

begin
  Application.Title := 'ASMHeadPreventive';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmFomenu, frmFomenu);
  Application.CreateForm(TfrmJelszomod, frmJelszomod);
  Application.CreateForm(TfrmFejKivetel, frmFejKivetel);
  Application.CreateForm(TfrmFejBehelyezes, frmFejBehelyezes);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.CreateForm(TfrmPrevKarb, frmPrevKarb);
  Application.CreateForm(TfrmRiportok, frmRiportok);
  Application.CreateForm(TfrmProgress, frmProgress);
  Application.CreateForm(TfrmEgyebAlkatreszek, frmEgyebAlkatreszek);
  Application.CreateForm(TfrmUjAlkatreszFelvitel, frmUjAlkatreszFelvitel);
  Application.Run;
end.

