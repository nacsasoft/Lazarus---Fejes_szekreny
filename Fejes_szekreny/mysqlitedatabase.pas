unit mySqliteDatabase;

{$mode objfpc} // directive to be used for defining classes
{$m+}		   // directive to be used for using constructor


interface

uses
  Classes, SysUtils,sqldb, sqlite3conn, db, sqlite3ds, Dialogs;

type
  cSqliteDatabase = class
  private
    pDatasource : TDataSource;

  public
    pDataset : TSqlite3Dataset;

    constructor Create(sTablaName: string; sSQL: string; sPrimaryKey: string);
    procedure RunSQL(sSQL: string);
    procedure Terminate();

    function GetRecordCount() : integer;


  end;

implementation


constructor cSqliteDatabase.Create(sTablaName: string; sSQL: string; sPrimaryKey: string);
var
  dbPath : string;
begin

    pDataset := TSqlite3Dataset.Create(nil);
    dbPath := 'adatbazis/szekreny_new.db3';

     try
       with pDataset do
       begin
            FileName:=dbPath;
            AutoIncrementKey:=true;
            PrimaryKey:=sPrimaryKey;
            SaveOnClose:=true;
            SaveOnRefetch:=true;
            TableName:=sTablaName;
            SQL:=sSQL;
            Open;
            First;
       end;
     except
          on E: Exception do
              ShowMessage('SQLITE3 adatbázis kapcsolódási hiba: ' + #10 + E.ClassName + ' / ' + E.Message);
     end;
end;

procedure cSqliteDatabase.RunSQL(sSQL : string);
begin
  try
     pDataset.Close;
     pDataset.SQL:=sSQL;
     pDataset.Open;
     pDataset.First;
  except
       on Exception do ShowMessage('SQLITE3 lekérdezés hiba!' + #10 + 'SQL : ' + sSQL);
  end;
end;

function cSqliteDatabase.GetRecordCount() : integer;
begin
  result := pDataset.RecordCount;
end;

procedure cSqliteDatabase.Terminate();
begin
  try
      pDataset.Close;
      pDataset.Free;
  except
       on Exception do ShowMessage('procedure dbClose(dbSQL3Dataset: TSqlite3Dataset); - Adatbázis bezárási hiba!!!');
  end;
end;

end.

