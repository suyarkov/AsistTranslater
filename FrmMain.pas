unit FrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer,
  Vcl.Grids, IdHttp, jpeg,
  IdTCPConnection, IdTCPClient,
  System.Net.HTTPClient,
  System.NetEncoding,
  System.Types, System.UITypes,
  Winapi.ShellAPI, IdContext, OAuth2, System.Generics.Collections,
  REST.Client, REST.Types,
  System.ImageList, Vcl.ImgList,
  FrmDataSQLite, Vcl.DBCtrls,
  FireDAC.Comp.DataSet, Data.FMTBcd, Data.DB, Data.SqlExpr, Vcl.Menus,
  Classes.channel,
  REST.JSON, PNGImage;

type
  TFormMain = class(TForm)
    PanelButton: TPanel;
    ImageSignIn: TImage;
    PanelChannels: TPanel;
    LabelYourChannels: TLabel;
    ProgressBarTranslater: TProgressBar;
    ButtonSignIn: TButton;
    ButtonBuy: TButton;
    EditStatusConnect: TEdit;
    IdTCPServer1: TIdTCPServer;
    ButtonStartStopServer: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    ButtonGetChannel: TButton;
    ButtonGetChannel2: TButton;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    ButtonLoadChannels: TButton;
    Image1: TImage;
    Edit4: TEdit;
    Button1: TButton;
    Image2: TImage;
    Button2: TButton;
    Button3: TButton;
    procedure ButtonSignInClick(Sender: TObject);
    procedure ButtonStartStopServerClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure ButtonGetChannelClick(Sender: TObject);
    procedure ButtonGetChannel2Click(Sender: TObject);
    procedure ButtonLoadChannelsClick(Sender: TObject);
    procedure ButtonBuyClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    ShortChannels: TShortChannels;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

function ParamValue(ParamName, JSONString: string): string;
const
  StripChars: set of char = ['"', ':', ','];
var
  i, j: Integer;
begin
  i := Pos(LowerCase(ParamName), LowerCase(JSONString));
  if i > 0 then
  begin
    for j := i + Length(ParamName) to Length(JSONString) - 1 do
      if not(JSONString[j] in StripChars) then
        Result := Result + JSONString[j]
      else if JSONString[j] = ',' then
        break;
  end
  else
    Result := '';
end;

procedure ServerResponseToFile(AResponse: TRestResponse; AFileName: string);
var
  SomeStream: TMemoryStream;
  local_filename: string;
begin
{$IF DEFINED(MsWindows)}
  local_filename := ExtractFilePath(ParamStr(0)) + AFileName;
{$ENDIF}
  SomeStream := TMemoryStream.Create;
  SomeStream.WriteData(AResponse.RawBytes, Length(AResponse.RawBytes));
  SomeStream.SaveToFile(local_filename);
  SomeStream.Free;
end;

function SendRequest2(URL: string; Params: TDictionary<string, string>;
  Headers: TDictionary<string, string>; JSON: string;
  Method: TRESTRequestMethod; AFile: string = ''): string;
var
  FRest: TRestClient;
  FRequest: TRestrequest;
  FResponse: TRestResponse;
  i: Integer;
  Key: String;
  LParam: TRESTRequestParameter;
  Boundary: string;
begin
  FRest := TRestClient.Create(URL);
  FResponse := TRestResponse.Create(nil);

  FRequest := TRestrequest.Create(nil);
  FRequest.Client := FRest;
  FRequest.Method := Method;
  FRequest.Response := FResponse;

  if Headers <> nil then
    for Key in Headers.Keys do
      if NOT FRequest.Params.ContainsParameter(Key) then
      begin
        with FRequest.Params.AddHeader(Key, Headers.Items[Key]) do
          Options := Options + [poDoNotEncode];
      end;

  if Params <> nil then
    for Key in Params.Keys do
      if NOT FRequest.Params.ContainsParameter(Key) then
        FRequest.Params.AddItem(Key, Params.Items[Key]);

  if JSON <> '' then
  begin
    FRequest.AddBody(JSON, 'application/json');
    if AFile <> '' then
    begin
      FRequest.AddFile('file', AFile, ctAPPLICATION_OCTET_STREAM);
    end;
  end;
  try

    FRequest.Execute;
    case FResponse.StatusCode of
      200:
        begin

          if Pos('captions/', URL) <> 0 then
            if Length(FResponse.RawBytes) <> 0 then
              ServerResponseToFile(FResponse, 'default.sbv');
          Result := FResponse.JSONText;

        end;
      403:
        begin
          Result := FResponse.JSONText;
        end;
      400:
        begin
          Result := FResponse.JSONText + ' :: ' + FRequest.Params.ToString;
        end;
    end;
  finally

  end;

end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  vSS: TStringStream;

  SS: TStringStream;
  g: TGraphic;

  S: AnsiString;
  vBlob: TBlobType;
begin
  // UCcD7KQCDJBAJovCngaAdObA
  // vBlob := TBlobType.Create;
  vSS := TStringStream.Create();
  Image2.Picture.SaveToStream(vSS);
  // Image1.Picture.SaveToFile('D:\GitClicker\AsistTranslater\temp.png');
  S := vSS.DataString;
  SQLiteModule.SaveTestImage(S);
  // g := TPNGImage.Create;
  // SS := TStringStream.Create(S);
  // vBlob := TBlobType(vSS.DataString);
  // g.LoadFromStream(SS);
  // Image2.Picture.Assign(g);
  // SS.Free;
  vSS.Free;
  // g.Free;

end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  http: TIdHTTP;
  str: TFileStream;
begin
  // —оздим класс дл€ закачки
  http := TIdHTTP.Create(nil);
  // каталог, куда файл положить
  ForceDirectories(ExtractFileDir('D:/tete.jpg'));
  // ѕоток дл€ сохранени€
  str := TFileStream.Create('D:/tete.jpg', fmCreate);
  try
    //  ачаем
    http.Get('https://yt3.ggpht.com/dpKQdRtvoc1BOYxFDooMPWBmQ6rEBJUSo_KBJwBuRZMEXgyDjg8Ixxtqs61y7-xpWS5fIfElLg=s88-c-k-c0x00ffffff-no-rj',
      str);
  finally
    // Ќас учили чистить за собой
    http.Free;
    str.Free;
    Image2.Picture.LoadFromFile('D:/tete.jpg');
  end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
var
  //
  i: Integer;
  // results: TDataSet;
  g: TGraphic;
  results: TShortChannels;

  vSS: TStringStream;
  SS: TStringStream;

  S: AnsiString;
  vBlob: TBlobType;
  vBlobF: TBlobField;

begin

  // g:=TJpegimage.Create;
  g := TPNGImage.Create;
  // g:=TBitmap.Create;

  // очищаю грид
  for i := 0 to 1000 do
    StringGrid1.Rows[i].Clear;

  StringGrid1.ColCount := 7;
  StringGrid1.RowCount := 0;
  i := 0;

  // загружаю данные из локальной таблицы
  results := SQLiteModule.SelInfoChannels();

  // разбираю курсор по €чейкам, а хотелось бы сразу объект а не €чейки.
  for i := 1 to 50 do

  begin
    if results[i].id_channel <> '' then

    begin
      StringGrid1.Cells[0, i - 1] := results[i].id_channel;
      StringGrid1.Cells[1, i - 1] := results[i].name_channel;
      // StringGrid1.Cells[2, i - 1] := String(results[i].img_channel);
      // .AsString;
      vBlob := results[i].img_channel;
      //vBlobF.;
      //vBlobF := TBlobField(vBlob);
      //vSS := TStringStream.Create();
//        Image2.Picture.SaveToStream(vSS);
      //vBlobF.SaveToStream(vSS);
      //S := vSS.DataString;
      //  SQLiteModule.SaveTestImage(S);


      if i = 1 then
      begin
        //Image1.Picture.LoadFromStream(vSS);
      end;
      // Image1.Picture.

      // g := results[i].img_channel;
      // SQLQuery.Params[0].AsBlob := pSS3;
      // это рабочий вариант пр€мо с пол€ вз€ть, не из таблицы!!
      // g.Assign(results[i].img_channel);
      // Image1.Picture.Assign(g);
      // g:TGraphic;
      // Image1.Picture.LoadFromStream(results.FieldByName('img_channel'),ftBlob)

      StringGrid1.Cells[3, i - 1] := results[i].refresh_token;
      StringGrid1.Cells[4, i - 1] := results[i].lang;
      StringGrid1.Cells[5, i - 1] := results[i].sel_lang;
      StringGrid1.Cells[6, i - 1] := IntToStr(results[i].deleted);

      StringGrid1.RowCount := i;
    end;
    ShortChannels := results;
  end;
end;

procedure TFormMain.ButtonBuyClick(Sender: TObject);
var
  AValue, ConstSourceLang, ConstTargetLang: String;
  AResponce: IHTTPResponse;
  FHTTPClient: THTTPClient;
  AAPIUrl: String;
  j: Integer;
  jpegimg: TJPEGImage;
  S: string;
begin
  begin
    S := StringReplace(Edit4.Text, #13, '', [rfReplaceAll, rfIgnoreCase]);
    AAPIUrl := StringReplace(S, #10, '', [rfReplaceAll, rfIgnoreCase]);
    Edit4.Text := AAPIUrl;
    FHTTPClient := THTTPClient.Create;
    FHTTPClient.UserAgent :=
      'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru-RU) Gecko/20100625 Firefox/3.6.6';
    try
      AResponce := FHTTPClient.Get(AAPIUrl);
    except
      // showmessage('нет подключени€');
    end;
    if Not Assigned(AResponce) then
    begin
      // showmessage('ѕусто');
    end;

    try
      Memo1.Text := AResponce.StatusText;
      jpegimg := TJPEGImage.Create;
      jpegimg.LoadFromStream(AResponce.ContentStream);
      Image1.Picture.Assign(jpegimg);
    except
      // showmessage('Ќе ѕусто1');
    end;
  end;
end;

procedure TFormMain.ButtonGetChannel2Click(Sender: TObject);
var
  vString: string;
  OAuth2: TOAuth;
  vObj: Tchannel;
  i: Integer;
  urlget: string;
  AJsonString: string;
  vChannel: TShortChannel;
  vImgUrl: string;
  g: TGraphic;
  ssimg: TStringStream;
  vSS: TStringStream;
  SS: TStringStream;
  // S: AnsiString;
  jpegimg: TJPEGImage;
  S: string;
  AAPIUrl: String;
  FHTTPClient: THTTPClient;
  AResponce: IHTTPResponse;
begin
  vObj.Create;
  vObj := TJson.JsonToObject<Tchannel>(Memo1.Text);

  for i := 0 to Length(vObj.Items) - 1 do
  begin
    vChannel.id_channel := vObj.Items[i].id;
    vChannel.name_channel := vObj.Items[i].snippet.title;
    // vChannel.img_channel
    vImgUrl := vObj.Items[i].snippet.thumbnails.default.URL;
    Edit4.Text := vImgUrl;
    // ssimg := SQLiteModule.LoadAnyImage(vImgUrl);
    // vChannel.img_channel := TBlobType(SQLiteModule.LoadAnyImage(vImgUrl));
    try

      S := StringReplace(Edit4.Text, #13, '', [rfReplaceAll, rfIgnoreCase]);
      AAPIUrl := StringReplace(S, #10, '', [rfReplaceAll, rfIgnoreCase]);
      FHTTPClient := THTTPClient.Create;
      FHTTPClient.UserAgent :=
        'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru-RU) Gecko/20100625 Firefox/3.6.6';
      try
        AResponce := FHTTPClient.Get(AAPIUrl);
      except
        showmessage('нет подключени€');
      end;
      if Not Assigned(AResponce) then
      begin
        showmessage('ѕусто');
      end;

      // g := TPNGImage.Create;
      // SS := TStringStream.Create(S);
      // showmessage('ѕусто 9');
      // g.LoadFromStream(SQLiteModule.LoadAnyImage(vImgUrl));
      showmessage('ѕусто 10');
      // Image2.Picture.Assign(g);

      jpegimg := TJPEGImage.Create;
      // memo1.Text := SQLiteModule.LoadAnyImage(vImgUrl);
      jpegimg.LoadFromStream(AResponce.ContentStream);
      showmessage('ѕусто 111');
      Image2.Picture.Assign(jpegimg);
      showmessage('ѕусто 112');
      // Image2.Picture.LoadFromStream(SQLiteModule.LoadAnyImage(vImgUrl));
      showmessage('ѕусто 11');

      // vSS := SQLiteModule.LoadAnyImage(vImgUrl);
      // jpegimg := TJPEGImage.Create;
      // jpegimg.LoadFromStream(AResponce.ContentStream);
      // jpegimg.SaveToStream(Ss);
      // Result.Assign(jpegimg);
      // Image2.Picture.Assign(jpegimg);
    except
      showmessage('ѕусто 1');
    end;
    // vSS := SQLiteModule.LoadAnyImage(vImgUrl);
    // S := vSS.DataString;
    // SQLiteModule.SaveTestImage(S);

    // Image2.
    // vChannel.img_channel := TBlobType(ssimg);

    vChannel.refresh_token := Edit2.Text;
    vChannel.lang := vObj.Items[i].snippet.defaultLanguage;
    vChannel.sel_lang := 'ru';
    vChannel.deleted := 1;
    // showmessage(vObj.items[i].snippet.title);
  end;

  i := SQLiteModule.InsRefreshToken(vChannel);
end;

procedure TFormMain.ButtonGetChannelClick(Sender: TObject);
const
  tokenurl = 'https://accounts.google.com/o/oauth2/token';
  redirect_uri1 = 'http://127.0.0.1:1904';
var
  // vOAuth: TOAuth;
  Params: TDictionary<String, String>;
  Response: string;
  Access_token: string;
  refresh_token: string;

  OAuth2: TOAuth;
  vString: string;

begin

  OAuth2 := TOAuth.Create;
  OAuth2.ClientID :=
    '701561007019-tm4gfmequr8ihqbpqeui28rp343lpo8b.apps.googleusercontent.com';
  OAuth2.ClientSecret := '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';
  OAuth2.ResponseCode := Edit1.Text;

  Access_token := OAuth2.GetAccessToken;
  refresh_token := OAuth2.refresh_token;
  Edit2.Text := refresh_token;
  Edit3.Text := Access_token;

  vString := OAuth2.MyChannels;
  Memo1.Text := vString;
  OAuth2.Free;

end;

procedure TFormMain.ButtonLoadChannelsClick(Sender: TObject);
var
  //
  i: Integer;
  results: TDataSet;
  g: TGraphic;
begin

  // g:=TJpegimage.Create;
  g := TPNGImage.Create;
  // g:=TBitmap.Create;

  // очищаю грид
  for i := 0 to 1000 do
    StringGrid1.Rows[i].Clear;

  StringGrid1.ColCount := 7;
  StringGrid1.RowCount := 0;
  i := 0;

  // загружаю данные из локальной таблицы
  results := SQLiteModule.SelRefreshToken();

  // разбираю курсор по €чейкам, а хотелось бы сразу объект а не €чейки.
  if not results.IsEmpty then
  begin
    results.First;
    // EditStatusConnect.Text := 'result Exists ' + IntToStr(StringGrid1.RowCount );
    while not results.Eof do
    begin
      inc(i);
      // EditStatusConnect.Text := 'result Exists';
      // EditStatusConnect.Text := 'result Exists ' + IntToStr(StringGrid1.RowCount - 1);
      StringGrid1.Cells[0, i - 1] := results.FieldByName('id_channel').AsString;
      StringGrid1.Cells[1, i - 1] :=
        results.FieldByName('name_channel').AsString;
      // StringGrid1.Cells[2, i - 1] := results.FieldByName('img_channel')
      // .AsString;
      if i = 1 then
      begin
        // это рабочий вариант пр€мо с пол€ вз€ть, не из таблицы!!
        g.Assign(results.FieldByName('img_channel'));
        Image1.Picture.Assign(g);
        // g:TGraphic;
        // Image1.Picture.LoadFromStream(results.FieldByName('img_channel'),ftBlob)
      end;
      StringGrid1.Cells[3, i - 1] :=
        results.FieldByName('refresh_token').AsString;
      StringGrid1.Cells[4, i - 1] := results.FieldByName('lang').AsString;
      StringGrid1.Cells[5, i - 1] := results.FieldByName('sel_lang').AsString;
      StringGrid1.Cells[6, i - 1] := results.FieldByName('deleted').AsString;

      // EditStatusConnect.Text := 'result Exists ' + IntToStr(StringGrid1.RowCount - 1);
      StringGrid1.RowCount := i;
      results.Next;
    end;
    StringGrid1.RowCount := i;
  end;
  {
    if SQLiteModule.ClickConnection.Messages <> nil then
    for i := 0 to SQLiteModule.ClickConnection.Messages.ErrorCount - 1 do
    begin
    ListBox1.Items.Add(SQLiteModule.ClickConnection.Messages[i].Message);
    end;
    // Memo1.Lines.Add(FDConnection1.Messages[i].Message); }
end;

procedure TFormMain.ButtonSignInClick(Sender: TObject);
begin
  EditStatusConnect.Text := 'Waiting for connection ...';
  // 1.¬ключить сервер
  if IdTCPServer1.Active = false then
  begin
    IdTCPServer1.Bindings.Add.Port := 1904;
    IdTCPServer1.Active := true;
  end;
  // 2. ќткрыть регистрацию
  ShellExecute(Handle, 'open',
    PChar('https://accounts.google.com/o/oauth2/v2/auth?' +
    'scope=https://www.googleapis.com/auth/youtube.force-ssl&' +
    'access_type=offline&include_granted_scopes=true' + '&state=security_token'
    + '&response_type=code' + '&redirect_uri=http://127.0.0.1:1904' +
    '&client_id=701561007019-tm4gfmequr8ihqbpqeui28rp343lpo8b.apps.googleusercontent.com'
    + '&service=lso&o2v=2&flowName=GeneralOAuthFlow'), nil, nil, SW_SHOWNORMAL);

end;

procedure TFormMain.ButtonStartStopServerClick(Sender: TObject);
begin
  if IdTCPServer1.Active = false then
  begin
    IdTCPServer1.Bindings.Add.Port := 1904;
  end;
  if IdTCPServer1.Active then
  begin
    IdTCPServer1.Active := false;
    IdTCPServer1.Bindings.Add.Port := 1111;
    showmessage('¬џключил сервер');
  end
  else
  begin
    IdTCPServer1.Active := true;
    showmessage('включил сервер');

  end;
end;

procedure TFormMain.IdTCPServer1Execute(AContext: TIdContext);
const
  cNameFile: string = 'AccessCode';
var
  Port: Integer;
  PeerPort: Integer;
  PeerIP: string;

  msgFromClient: string;
  vPosBegin, vPosEnd: Integer;
  vAccessCode: string;

  // vProfile: TProfile;
  vPath: string;
  vFullNameFile: string;
  vFileText: TStringList;

begin

  msgFromClient := AContext.Connection.IOHandler.ReadLn;

  PeerIP := AContext.Binding.PeerIP;
  PeerPort := AContext.Binding.PeerPort;

  // AContext.Connection.IOHandler.WriteLn('... message sent from server :)');
  if Pos('GET', msgFromClient) > 0 then
  begin
    if Pos('error=', msgFromClient) = 0 then
    begin
      vPosBegin := Pos('code=', msgFromClient);
      vPosEnd := Pos('scope=', msgFromClient);
      if (vPosBegin > 0) and (vPosEnd > 0) then
      begin
        vPosBegin := vPosBegin + 5;
        vAccessCode := copy(msgFromClient, vPosBegin, vPosEnd - vPosBegin - 1);
        Edit1.Text := vAccessCode;
        if vAccessCode <> '' then
        begin
          vPath := GetCurrentDir();
          vFullNameFile := vPath + '/' + cNameFile;
          vFileText := TStringList.Create;
          vFileText.Add(vAccessCode);
          // сохран€ем
          vFileText.SaveToFile(vFullNameFile);
        end;
      end;
      AContext.Connection.IOHandler.WriteLn('HTTP/1.0 200 OK');
      AContext.Connection.IOHandler.WriteLn('Content-Type: text/html');
      AContext.Connection.IOHandler.WriteLn('Connection: close');
      AContext.Connection.IOHandler.WriteLn;
      AContext.Connection.IOHandler.write('<html>');
      AContext.Connection.IOHandler.write('<head>');
      AContext.Connection.IOHandler.
        write('<meta HTTP-EQUIV="Content-Type" Content="text-html; charset=windows-1251">');
      AContext.Connection.IOHandler.
        write('<title>"AsistTranslaterYT connected!</title>');
      AContext.Connection.IOHandler.write('</head>');

      AContext.Connection.IOHandler.write('<body bgcolor="white">');
      AContext.Connection.IOHandler.write(' <p>&nbsp;</p>');
      AContext.Connection.IOHandler.
        write('<h3 style="text-align: center; color: #ff2a2;">Everything ended successfully. You can close this window.</h3>');
      AContext.Connection.IOHandler.
        write('<p style="text-align: center;"><img style="text-align: center;" src="http://suyarkov.com/wp-content/uploads/2023/04/AssistTranslateYT_240.jpg" />');
      // write('<p style="text-align: center;"><img style="text-align: center;" src="https://play-lh.googleusercontent.com/-v_3PwP5PejV308DBx8VRtOWp2W_nkgIBZOt1X536YwGD7ytPPI2of2h3hG_uk7siAuh=w240-h480-rw" />');

      AContext.Connection.IOHandler.write('</p>');
      AContext.Connection.IOHandler.
        write('<h3 style="text-align: center; color: #ff2a2;">Thank you for being with us. Team "AsistTranslaterYT "</h3>');
      AContext.Connection.IOHandler.write('</body>');

      AContext.Connection.IOHandler.write('</html>');
      AContext.Connection.IOHandler.WriteLn;
    end
    else
    begin
      AContext.Connection.IOHandler.WriteLn('HTTP/1.0 200 OK');
      AContext.Connection.IOHandler.WriteLn('Content-Type: text/html');
      AContext.Connection.IOHandler.WriteLn('Connection: close');
      AContext.Connection.IOHandler.WriteLn;
      AContext.Connection.IOHandler.write('<html>');
      AContext.Connection.IOHandler.write('<head>');
      AContext.Connection.IOHandler.
        write('<meta HTTP-EQUIV="Content-Type" Content="text-html; charset=windows-1251">');
      AContext.Connection.IOHandler.
        write('<title>AsistTranslater connected!</title>');
      AContext.Connection.IOHandler.write('</head>');

      AContext.Connection.IOHandler.write('<body bgcolor="white">');
      AContext.Connection.IOHandler.write(' <p>&nbsp;</p>');
      AContext.Connection.IOHandler.
        write('<h3 style="text-align: center; color: #ff2a2;">Not connected. You can close this window.</h3>');
      AContext.Connection.IOHandler.
        write('<p style="text-align: center;"><img style="text-align: center;" src="http://suyarkov.com/wp-content/uploads/2023/04/AssistTranslateYT_240.jpg" />');
      // write('<p style="text-align: center;"><img style="text-align: center;" src="https://play-lh.googleusercontent.com/-v_3PwP5PejV308DBx8VRtOWp2W_nkgIBZOt1X536YwGD7ytPPI2of2h3hG_uk7siAuh=w240-h480-rw" />');

      AContext.Connection.IOHandler.write('</p>');
      AContext.Connection.IOHandler.
        write('<h3 style="text-align: center; color: #ff2a2;">What a pity. Team "AsistTranslaterYT "</h3>');
      AContext.Connection.IOHandler.write('</body>');

      AContext.Connection.IOHandler.write('</html>');
      AContext.Connection.IOHandler.WriteLn;
    end;
    // IdTCPServer1.Active := false;
  end;

  AContext.Connection.IOHandler.CloseGracefully;
  AContext.Connection.Socket.CloseGracefully;
  AContext.Connection.Socket.Close;
end;

procedure TFormMain.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  img: TPicture;
begin
  {
    vRect.Create(Rect.Left+2,Rect.Top+2,Rect.Left+20,Rect.Top+20);
    if (ACol = 4) then
    begin
    if (LanguagesGrid.Cells[4, ARow] = '1') then
    begin
    LanguagesGrid.Canvas.StretchDraw(vRect, Image1.Picture.Graphic);
    end
    else
    begin
    LanguagesGrid.Canvas.StretchDraw(vRect, Image2.Picture.Graphic);
    end;
    end; }

  // создание графического объекта
  img := TPicture.Create;

  // загрузка в графическую переменную изображени€ из внешнего файла
  // img.LoadFromFile('001.bmp');

  // условие, определ€ющее нужную €чейку
  if ((ACol = 3) and (ARow = 1)) then
  begin

    // назначение размера €чейки по ширине и высоте
    StringGrid1.ColWidths[ACol] := img.Width;
    StringGrid1.RowHeights[ARow] := img.Height;

    // вывод рисунка в текущей €чейке
    StringGrid1.Canvas.StretchDraw(Rect, img.Graphic);
  end;

end;

end.
