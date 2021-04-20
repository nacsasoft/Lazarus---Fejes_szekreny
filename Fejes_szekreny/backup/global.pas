unit global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, windows, Dialogs, Forms;


var

   	iAdmin:           	integer; 	//0 = alap felh.
    															//1 = admin

   	userName:         	string;  	//Felhasználó teljes neve
   	userDB_ID:        	integer; 	//Felhasználó adatbázis id-je

    COM_port_name:      string;   //Beállításokból kiolvasott com port azonosító
    ferohelyek:         integer;  //max ennyi fejet tudunk tárolni...
    COMPORT_VEZERLES:   integer;  //ha = 1 akkor élesben kell használni a COM portot!!




const
	  dbPath = 'adatbazis/szekreny_new.db3';

    //Tab character
  	Delim = CHR(9);

    StatusWindowText = 'Ajtonyitas folyamatban...'  + #10 + 'Az ablak bezarasiag varjon!!';


type
  TStatusWindowHandle = type HWND;





//Globális függvények :
function IsStrANumber(const S: string): Boolean;
function CreateStatusWindow(const Text: AnsiString): TStatusWindowHandle;

procedure RemoveStatusWindow(StatusWindow: TStatusWindowHandle);



implementation


//a string szám ?
function IsStrANumber(const S: string): Boolean;
var
  P: PChar;
begin
  P      := PChar(S);
  Result := False;
  while P^ <> #0 do
  begin
    if not (P^ in ['0'..'9']) then Exit;
    Inc(P);
  end;
  Result := True;
end;


function CreateStatusWindow(const Text: AnsiString): TStatusWindowHandle;
var
  FormWidth,  FormHeight: integer;
begin
  FormWidth := 400;
  FormHeight := 164;
  result := CreateWindow('STATIC',
                         PChar(AnsiToUtf8(Text)),
                         WS_OVERLAPPED or WS_POPUPWINDOW or WS_THICKFRAME or SS_CENTER or SS_CENTERIMAGE or DS_MODALFRAME or ES_MULTILINE,
                         (Screen.Width - FormWidth) div 2,
                         (Screen.Height - FormHeight) div 2,
                         FormWidth,
                         FormHeight,
                         Application.MainForm.Handle,
                         0,
                         HInstance,
                         nil);
  ShowWindow(result, SW_SHOWNORMAL);
  UpdateWindow(result);
end;

procedure RemoveStatusWindow(StatusWindow: TStatusWindowHandle);
begin
  DestroyWindow(StatusWindow);
end;


end.


