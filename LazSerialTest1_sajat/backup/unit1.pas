unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LazSerial;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnWriteData: TButton;
    btnOpenPort: TButton;
    btnClosePort: TButton;
    btnCsatornaKI: TButton;
    btnCsatornaBE: TButton;
    btnReadDatas: TButton;
    cmbCsatornaSzama: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    Serial: TLazSerial;
    procedure btnClosePortClick(Sender: TObject);
    procedure btnCsatornaBEClick(Sender: TObject);
    procedure btnCsatornaKIClick(Sender: TObject);
    procedure btnOpenPortClick(Sender: TObject);
    procedure btnReadDatasClick(Sender: TObject);
    procedure btnWriteDataClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnWriteDataClick(Sender: TObject);
begin
     Serial.WriteData('ver'+chr(13));    //firmware verzió lekérése...

      //While Serial.SynSer.WaitingData < 6 do
        // begin
           //Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
           Sleep(1500);
         //end;
     Memo1.Text := Memo1.Text + Serial.ReadData;
end;

procedure TForm1.btnOpenPortClick(Sender: TObject);
begin
     Serial.Device := 'COM8';
     Serial.Open;
end;

procedure TForm1.btnReadDatasClick(Sender: TObject);
begin
     Serial.SynSer.LineBuffer := '';
     Serial.WriteData('gpio read ' + cmbCsatornaSzama.Text + chr(13));
     Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
     Sleep(500);
     Memo1.Text := Memo1.Text + Serial.ReadData;

end;

procedure TForm1.btnClosePortClick(Sender: TObject);
begin
     Serial.Close;
end;

procedure TForm1.btnCsatornaBEClick(Sender: TObject);
begin
     //Serial.WriteData('gpio set ' + cmbCsatornaSzama.Text + chr(13));
     Serial.WriteData('relay on ' + cmbCsatornaSzama.Text + chr(13));
     Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
     Sleep(500);
     Memo1.Text := Memo1.Text + Serial.ReadData;
end;

procedure TForm1.btnCsatornaKIClick(Sender: TObject);
begin
     //Serial.WriteData('gpio clear ' + cmbCsatornaSzama.Text + chr(13));
     Serial.WriteData('relay off ' + cmbCsatornaSzama.Text + chr(13));
     Application.ProcessMessages; //többi alkalmazás folyamatok fussanak.......
     Sleep(500);
     Memo1.Text := Memo1.Text + Serial.ReadData;
end;

end.

