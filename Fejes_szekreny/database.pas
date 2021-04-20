unit database;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqlite3ds, db, global, Dialogs;


function dbConnect(sTablaName: string; sSQL: string; sPrimaryKey: string):TSqlite3Dataset;
procedure dbClose(dbSQL3Dataset: TSqlite3Dataset);
procedure dbUpdate(dbSQL3Dataset: TSqlite3Dataset; sSQL: string);



var

   //dbSQL3Dataset:        TSqlite3Dataset;
   dbDatasource:         TDataSource;

implementation

function dbConnect(sTablaName: string; sSQL: string; sPrimaryKey: string) :TSqlite3Dataset;
var
   dbSQL3Dataset: TSqlite3Dataset;
begin
     dbSQL3Dataset := TSqlite3Dataset.Create(nil);
     try
       with dbSQL3Dataset do
       begin
            FileName:=dbPath;
            AutoIncrementKey:=true;
            PrimaryKey:=sPrimaryKey;
            SaveOnClose:=true;
            SaveOnRefetch:=true;
            TableName:=sTablaName;
            SQL:=sSQL;
            //Active:=true;
            Open;
            First;
       end; //end of with
       dbConnect := dbSQL3Dataset;
     except
       on Exception do ShowMessage('Dataset létrehozás hiba!!!');
     end;
end; //end of dbConnect function

procedure dbClose(dbSQL3Dataset: TSqlite3Dataset);
begin
  try
      dbSQL3Dataset.Close;
      dbSQL3Dataset.Free;
  except
       on Exception do ShowMessage('procedure dbClose(dbSQL3Dataset: TSqlite3Dataset); - Adatbázis bezárási hiba!!!');
  end;
end;

procedure dbUpdate(dbSQL3Dataset: TSqlite3Dataset; sSQL: string);
begin
  try
     dbSQL3Dataset.Close;
     dbSQL3Dataset.SQL:=sSQL;
     dbSQL3Dataset.Open;
     dbSQL3Dataset.First;
  except
       on Exception do ShowMessage('Adatbázis frissítési hiba!!!');
  end;
end;

end.
