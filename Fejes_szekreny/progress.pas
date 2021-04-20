unit progress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls;

type

  { TfrmProgress }

  TfrmProgress = class(TForm)
    lblFixMessage: TLabel;
    lblMessage: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.lfm}

{ TfrmProgress }

procedure TfrmProgress.FormActivate(Sender: TObject);
begin

end;

procedure TfrmProgress.FormShow(Sender: TObject);
begin

end;

end.

