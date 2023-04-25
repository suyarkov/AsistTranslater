unit FrmDataSQLite;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Vcl.Dialogs, Vcl.Graphics, Vcl.ImgList,
  IdTCPClient, System.Net.HTTPClient,
  System.NetEncoding,
  System.Types, System.UITypes,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls,
  PNGImage;

type
  TShortChannel = record
    id_channel: string;
    name_channel: string;
    img_channel: TBlobType;//tfGraphic;//TBlobType;
    refresh_token: string;
    lang: string;
    sel_lang: string;
    deleted: integer;
  end;

Type
  TShortChannels = Array [1 .. 50] of TShortChannel; // ограничим 50 каналами

type
  TSQLiteModule = class(TDataModule)
    SQL: TFDConnection;
    SQLQuery: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function SelRefreshToken(): tDataSet;
    function SelInfoChannels(): TShortChannels;
    function InsRefreshToken(pShortChanel: TShortChannel): integer;
    function LoadAnyImage(pUrl: string): TStream;
    procedure SaveTestImage(pSS3: AnsiString);
  end;

var
  SQLiteModule: TSQLiteModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TSQLiteModule.SelRefreshToken(): tDataSet;
var
  i: integer;
  results: tDataSet;
  Channel: Array [1 .. 1000] of TShortChannel;
begin
  try
    SQLiteModule.SQL.ExecSQL('select * from refresh_token', nil, results);
  except
    on E: Exception do
      showmessage('Exception raised with message: ' + E.Message);
  end;
  if not results.IsEmpty then
  begin
    results.First;
    i := 0;
    while not results.Eof do
    begin
      inc(i);

      Channel[i].id_channel := results.FieldByName('id_channel').AsString;
      Channel[i].name_channel := results.FieldByName('name_channel').AsString;
      Channel[i].img_channel := TBlobType(results.FieldByName('img_channel'));
      Channel[i].refresh_token := results.FieldByName('refresh_token').AsString;
      Channel[i].lang := results.FieldByName('lang').AsString;
      Channel[i].sel_lang := results.FieldByName('sel_lang').AsString;
      Channel[i].deleted := results.FieldByName('deleted').AsInteger;
      results.Next;
    end;
  end;

  Result := results;
end;

function TSQLiteModule.SelInfoChannels(): TShortChannels;
var
  i: integer;
  results: tDataSet;
  Channels: TShortChannels;
begin
  try
    SQLiteModule.SQL.ExecSQL('select * from refresh_token', nil, results);
  except
    on E: Exception do
      showmessage('Exception raised with message: ' + E.Message);
  end;
  if not results.IsEmpty then
  begin
    results.First;
    i := 0;
    while not results.Eof do
    begin
      inc(i);

      Channels[i].id_channel := results.FieldByName('id_channel').AsString;
      Channels[i].name_channel := results.FieldByName('name_channel').AsString;
      Channels[i].img_channel := TBlobType(results.FieldByName('img_channel'));
      Channels[i].refresh_token := results.FieldByName('refresh_token').AsString;
      Channels[i].lang := results.FieldByName('lang').AsString;
      Channels[i].sel_lang := results.FieldByName('sel_lang').AsString;
      Channels[i].deleted := results.FieldByName('deleted').AsInteger;
      results.Next;
    end;
  end;

  Result := Channels;
end;

function TSQLiteModule.InsRefreshToken(pShortChanel: TShortChannel): integer;
var
  i: integer;
  results: tDataSet;
begin
  try
    SQLiteModule.SQL.ExecSQL
      ('delete from refresh_token where id_channel = :id_channel',
      [pShortChanel.id_channel]);
    SQLiteModule.SQL.ExecSQL
      ('insert into refresh_token ( id_channel,name_channel,' +
      'img_channel,refresh_token,lang, sel_lang, deleted )' +
      'values(:id_channel, :name_channel,:img_channel,:refresh_token,:lang,:sel_lang,:deleted )',
      [pShortChanel.id_channel, pShortChanel.name_channel,
      pShortChanel.img_channel, pShortChanel.refresh_token, pShortChanel.lang,
      pShortChanel.sel_lang, pShortChanel.deleted]);

    // проапдейтим рисунок

  except
    on E: Exception do
    begin
      SQLiteModule.SQL.Rollback;
      showmessage('Exception raised with message: ' + E.Message);
    end;
  end;

  SQLiteModule.SQL.Commit;
  Result := 1;
end;

procedure TSQLiteModule.DataModuleCreate(Sender: TObject);
begin
  {
    ClickConnection.Params.Add('Database='+mydir+'database.db');
    try
    ClickConnection.Connected := true;
    except
    on E: EDatabaseError do
    ShowMessage('Exception raised with message' + E.Message);
    end;
  }
end;

function TSQLiteModule.LoadAnyImage(pUrl: string): TStream; // TPicture;
var
  AValue, ConstSourceLang, ConstTargetLang: String;
  AResponce: IHTTPResponse;
  FHTTPClient: THTTPClient;
  AAPIUrl: String;
  jpegimg: TJPEGImage;
  s: string;
  Ss: TStringStream;
begin
  begin
    s := StringReplace(pUrl, #13, '', [rfReplaceAll, rfIgnoreCase]);
    AAPIUrl := StringReplace(s, #10, '', [rfReplaceAll, rfIgnoreCase]);
    FHTTPClient := THTTPClient.Create;
    FHTTPClient.UserAgent :=
      'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru-RU) Gecko/20100625 Firefox/3.6.6';
    try
      AResponce := FHTTPClient.Get(AAPIUrl);
    except
      showmessage('нет подключения');
    end;
    if Not Assigned(AResponce) then
    begin
      showmessage('Пусто');
    end;

    try
      // jpegimg := TJPEGImage.Create;
      // jpegimg.LoadFromStream(AResponce.ContentStream);
      // jpegimg.SaveToStream(Ss);
      // Result.Assign(jpegimg);
      // Image2.Picture.Assign(jpegimg);
      // Result.Assign(jpegimg);
      // Ss := TStringStream.Create(st);
      // Image1.Picture.Bitmap.SaveToStream(   (Ss);
    except
      // showmessage('Не Пусто1');
    end;
  end;
  Result := AResponce.ContentStream; // SS
end;

procedure TSQLiteModule.SaveTestImage(pSS3: AnsiString); // TPicture;
begin
  begin
    SQLQuery.SQL.Text :=
      'update refresh_token set img_channel= :photo where id_channel = "UCcD7KQCDJBAJovCngaAdObA";';
    SQLQuery.Params[0].AsBlob := pSS3;
    SQLQuery.ExecSQL;
    SQLiteModule.SQL.Commit;
  end;
end;

end.
