unit prevkarb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  { TfrmPrevKarb }

  TfrmPrevKarb = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmPrevKarb: TfrmPrevKarb;

implementation

{$R *.lfm}

uses fomenu;

{ TfrmPrevKarb }

procedure TfrmPrevKarb.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     frmPrevKarb.Hide;
     frmFomenu.Show;
end;

end.

