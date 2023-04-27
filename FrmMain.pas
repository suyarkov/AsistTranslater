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
  Classes.channel, ChannelPanel,
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
    EdRefresh_token: TEdit;
    EdAccess_token: TEdit;
    ButtonGetChannel: TButton;
    ButtonGetChannel2: TButton;
    Memo1: TMemo;
    ButtonLoadChannels: TButton;
    Image1: TImage;
    Edit4: TEdit;
    Button1: TButton;
    Image2: TImage;
    Button2: TButton;
    Button3: TButton;
    ScrollBox1: TScrollBox;
    RefreshCannels: TButton;
    ButtEnd: TButton;
    procedure ButtonSignInClick(Sender: TObject);
    procedure ButtonStartStopServerClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure ButtonGetChannelClick(Sender: TObject);
    procedure ButtonGetChannel2Click(Sender: TObject);
    procedure ButtonLoadChannelsClick(Sender: TObject);
    procedure ButtonBuyClick(Sender: TObject);
    procedure DinButtonDeleteChannelClick(Sender: TObject);
    procedure DinPanelClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure DinPanelMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure RefreshCannelsClick(Sender: TObject);
  private
    { Private declarations }
    ShortChannels: TShortChannels;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  PanChannels: array [1 .. 20] of TMyPanel;
  lastPanel: TPanel;

implementation

{$R *.dfm}

procedure TFormMain.DinPanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  panel: TPanel;
begin
  panel := Sender as TPanel;
  if lastPanel <> nil then
    if lastPanel <> panel then
    begin
      lastPanel.Color := clBtnFace;
      lastPanel.Font.Color := clBlack;
      lastPanel := nil;
    end;

  begin
    panel.Color := clWhite; // clblack;
    // panel.Font.Color := clWhite;
    // запоминаем панельку, над которой изменили цвет,
    // чтобы когда произойдет движенье мышью над формой вернуть его обратно
    lastPanel := panel;
  end;
end;

procedure TFormMain.FormActivate(Sender: TObject);
begin
  // ButtonLoadChannelsClick(Sender);
  ButtonLoadChannels.OnClick(Sender);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  lastPanel := nil;
end;

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

procedure TFormMain.DinButtonDeleteChannelClick(Sender: TObject);
var
  strQuestionDelete, vIdChannel, vNameChannel: string;
  vNPanel : integer;
begin
  vNPanel :=   TButton(Sender).Tag;
  vIdChannel := PanChannels[vNPanel].chId.Caption;
  vNameChannel := PanChannels[vNPanel].chName.Caption;
  strQuestionDelete := 'Delete ' + vNameChannel  + ' ?';
  if MessageDlg(strQuestionDelete,
  mtConfirmation, [mbYes, mbNo], 0) = mrYes
  then
  begin
  SQLiteModule.DelChannel(vIdChannel);
  RefreshCannelsClick(FormMain);
  end;
end;


procedure TFormMain.DinPanelClick(Sender: TObject);
const
  tokenurl = 'https://accounts.google.com/o/oauth2/token';
  redirect_uri1 = 'http://127.0.0.1:1904';
var
  Params: TDictionary<String, String>;
  Response: string;
  Access_token: string;
  refresh_token: string;

  OAuth2: TOAuth;
  vString: string;

  strQuestionDelete, vIdChannel, vNameChannel: string;
  vNPanel : integer;
  vToken : string;

  vObj: Tchannel;
  res, i: Integer;
  urlget: string;
  AJsonString: string;
//  vChannel: TShortChannel;
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
  vNPanel :=   TButton(Sender).Tag;
  vIdChannel := PanChannels[vNPanel].chId.Caption;
  vToken := PanChannels[vNPanel].chToken.Caption;
  vNameChannel := PanChannels[vNPanel].chName.Caption;
  strQuestionDelete := 'Click ' + vNameChannel + ' !';

  showmessage(strQuestionDelete);

  // запрос видео

  OAuth2 := TOAuth.Create;
  OAuth2.ClientID :=
    '701561007019-tm4gfmequr8ihqbpqeui28rp343lpo8b.apps.googleusercontent.com';
  OAuth2.ClientSecret := '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';
//  OAuth2.ResponseCode := Edit1.Text;
  showmessage(vToken);
  OAuth2.refresh_token := vToken;
   {
  Access_token := OAuth2.GetAccessToken;
  refresh_token := OAuth2.refresh_token;
  EdRefresh_token.Text := refresh_token;
  EdAccess_token.Text := Access_token;
  }
  // подробней о канале
 // пока не нужно vString := OAuth2.MyChannels;
  // о видео
  vString :=  OAuth2.MyVideos(vIdChannel); // , NextToken: string = '' -- xfcnm cktle.ofz
  Memo1.Text := vString;
  OAuth2.Free;
  // разбор XML

  vObj.Create;
  vObj := TJson.JsonToObject<Tchannel>(Memo1.Text);

  for i := 0 to Length(vObj.Items) - 1 do
  begin
    vChannel.id_channel := vObj.Items[i].id;
    vChannel.name_channel := vObj.Items[i].snippet.title;
    vImgUrl := vObj.Items[i].snippet.thumbnails.default.URL;
    Edit4.Text := vImgUrl;
    try

      S := StringReplace(Edit4.Text, #13, '', [rfReplaceAll, rfIgnoreCase]);
      AAPIUrl := StringReplace(S, #10, '', [rfReplaceAll, rfIgnoreCase]);
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

      jpegimg := TJPEGImage.Create;
      jpegimg.LoadFromStream(AResponce.ContentStream);
      Image2.Picture.Assign(jpegimg);
      // Image2.Picture.LoadFromStream(SQLiteModule.LoadAnyImage(vImgUrl));
    except
    end;

    vChannel.refresh_token := EdRefresh_token.Text;
    vChannel.lang := vObj.Items[i].snippet.defaultLanguage;
    // vChannel.sel_lang := vObj.;
    vChannel.deleted := 0;
    res := SQLiteModule.InsRefreshToken(vChannel);
  end;

//  ButtonGetChannel2.OnClick(Sender);

  // отображение видео
//  RefreshCannelsClick(FormMain);
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  vSS: TStringStream;

  SS: TStringStream;
  g: TGraphic;

  S: AnsiString;
  vBlob: TBlobType;
begin
  vSS := TStringStream.Create();
  Image2.Picture.SaveToStream(vSS);
  S := vSS.DataString;
  SQLiteModule.SaveTestImage(S);
  vSS.Free;
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  http: TIdHTTP;
  str: TFileStream;
begin
  // Создим класс для закачки
  http := TIdHTTP.Create(nil);
  // каталог, куда файл положить
  ForceDirectories(ExtractFileDir('D:/tete.jpg'));
  // Поток для сохранения
  str := TFileStream.Create('D:/tete.jpg', fmCreate);
  try
    // Качаем
    http.Get('https://yt3.ggpht.com/dpKQdRtvoc1BOYxFDooMPWBmQ6rEBJUSo_KBJwBuRZMEXgyDjg8Ixxtqs61y7-xpWS5fIfElLg=s88-c-k-c0x00ffffff-no-rj',
      str);
  finally
    // Нас учили чистить за собой
    http.Free;
    str.Free;
    Image2.Picture.LoadFromFile('D:/tete.jpg');
  end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
var
  i: Integer;
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

  i := 0;

  // загружаю данные из локальной таблицы
  results := SQLiteModule.SelInfoChannels();

  // разбираю курсор по ячейкам, а хотелось бы сразу объект а не ячейки.
  for i := 1 to 50 do

  begin
    if results[i].id_channel <> '' then

    begin
      // StringGrid1.Cells[0, i - 1] := results[i].id_channel;
      // StringGrid1.Cells[1, i - 1] := results[i].name_channel;
      vBlob := results[i].img_channel;
      // vBlobF.;
      // vBlobF := TBlobField(vBlob);
      // vSS := TStringStream.Create();
      // Image2.Picture.SaveToStream(vSS);
      // vBlobF.SaveToStream(vSS);
      // S := vSS.DataString;
      // SQLiteModule.SaveTestImage(S);

      if i = 1 then
      begin
        // Image1.Picture.LoadFromStream(vSS);
      end;
      // Image1.Picture.

      // g := results[i].img_channel;
      // SQLQuery.Params[0].AsBlob := pSS3;
      // это рабочий вариант прямо с поля взять, не из таблицы!!
      // g.Assign(results[i].img_channel);
      // Image1.Picture.Assign(g);
      // g:TGraphic;
      // Image1.Picture.LoadFromStream(results.FieldByName('img_channel'),ftBlob)

      // StringGrid1.Cells[3, i - 1] := results[i].refresh_token;
      // StringGrid1.Cells[4, i - 1] := results[i].lang;
      // StringGrid1.Cells[5, i - 1] := results[i].sel_lang;
      // StringGrid1.Cells[6, i - 1] := IntToStr(results[i].deleted);

      // StringGrid1.RowCount := i;
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
      // showmessage('нет подключения');
    end;
    if Not Assigned(AResponce) then
    begin
      // showmessage('Пусто');
    end;

    try
      Memo1.Text := AResponce.StatusText;
      jpegimg := TJPEGImage.Create;
      jpegimg.LoadFromStream(AResponce.ContentStream);
      Image1.Picture.Assign(jpegimg);
    except
      // showmessage('Не Пусто1');
    end;
  end;
end;

procedure TFormMain.ButtonGetChannel2Click(Sender: TObject);
var
  vString: string;
  OAuth2: TOAuth;
  vObj: Tchannel;
  res, i: Integer;
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
    vImgUrl := vObj.Items[i].snippet.thumbnails.default.URL;
    Edit4.Text := vImgUrl;
    try

      S := StringReplace(Edit4.Text, #13, '', [rfReplaceAll, rfIgnoreCase]);
      AAPIUrl := StringReplace(S, #10, '', [rfReplaceAll, rfIgnoreCase]);
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

      jpegimg := TJPEGImage.Create;
      jpegimg.LoadFromStream(AResponce.ContentStream);
      Image2.Picture.Assign(jpegimg);
      // Image2.Picture.LoadFromStream(SQLiteModule.LoadAnyImage(vImgUrl));
    except
    end;

    vChannel.refresh_token := EdRefresh_token.Text;
    vChannel.lang := vObj.Items[i].snippet.defaultLanguage;
    // vChannel.sel_lang := vObj.;
    vChannel.deleted := 0;
    res := SQLiteModule.InsRefreshToken(vChannel);
  end;

end;

procedure TFormMain.ButtonGetChannelClick(Sender: TObject);
const
  tokenurl = 'https://accounts.google.com/o/oauth2/token';
  redirect_uri1 = 'http://127.0.0.1:1904';
var
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
  EdRefresh_token.Text := refresh_token;
  EdAccess_token.Text := Access_token;

  vString := OAuth2.MyChannels;
  Memo1.Text := vString;
  OAuth2.Free;
  ButtonGetChannel2.OnClick(Sender);
  RefreshCannelsClick(FormMain);
end;

procedure TFormMain.ButtonLoadChannelsClick(Sender: TObject);
var
  //
  i: Integer;
  results: TDataSet;
  g: TGraphic;
  vPos: Integer;
begin
  // g:=TJpegimage.Create;
  g := TPNGImage.Create;
  // g:=TBitmap.Create;

  i := 1;

  // загружаю данные из локальной таблицы
  results := SQLiteModule.SelRefreshToken();

  // разбираю курсор в объект
  if not results.IsEmpty then
  begin
    results.First;
    while not results.Eof do
    begin

      vPos := (i - 1) * 120;
      PanChannels[i] := TMyPanel.Create(ScrollBox1, vPos, i,
        results.FieldByName('id_channel').AsString,
        results.FieldByName('refresh_token').AsString,
        results.FieldByName('name_channel').AsString,
        results.FieldByName('lang').AsString);
      PanChannels[i].Parent := ScrollBox1;
      PanChannels[i].ButtonDel.OnClick := DinButtonDeleteChannelClick;
      PanChannels[i].OnMouseMove := DinPanelMouseMove;
      PanChannels[i].OnClick := DinPanelClick;//Type (sender, 'TPanel');
      PanChannels[i].ChImage.OnClick := DinPanelClick;
      PanChannels[i].ChName.OnClick := DinPanelClick;
      PanChannels[i].ChLang.OnClick := DinPanelClick;
      // это рабочий вариант прямо с поля взять, не из таблицы!!
      // g.Assign(results.FieldByName('img_channel'));
      // Image1.Picture.Assign(g);
      inc(i);
      results.Next;
    end;
  end;
end;

// Получение прав от пользователя на канал
procedure TFormMain.ButtonSignInClick(Sender: TObject);
begin
  EditStatusConnect.Text := 'Waiting for connection ...';
  // 1.Включить сервер
  if IdTCPServer1.Active = false then
  begin
    IdTCPServer1.Bindings.Add.Port := 1904;
    IdTCPServer1.Active := true;
  end;
  // 2. Открыть регистрацию
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
    IdTCPServer1.Active := true;
    showmessage('включил сервер');
  end;
  {
  if IdTCPServer1.Active then
  begin
    IdTCPServer1.Active := false;
    IdTCPServer1.Bindings.Add.Port := 1111;
    showmessage('ВЫключил сервер');
  end
  else
  begin
    IdTCPServer1.Active := true;
    showmessage('включил сервер');

  end;}
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

  vPath: string;
  vFullNameFile: string;
  vFileText: TStringList;

begin

  msgFromClient := AContext.Connection.IOHandler.ReadLn;

  PeerIP := AContext.Binding.PeerIP;
  PeerPort := AContext.Binding.PeerPort;

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
          // сохраняем
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
      ButtonGetChannel.OnClick(FormMain);
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

procedure TFormMain.RefreshCannelsClick(Sender: TObject);
var i : integer;
begin
  try
    for i := 1 to 20 do
      PanChannels[i].Free;
  finally
    lastPanel:= nil;
    ButtonLoadChannelsClick(sender);
  end;


end;

procedure TFormMain.ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if lastPanel <> nil then
  begin
    lastPanel.Color := clBtnFace;
    lastPanel.Font.Color := clBlack;
    lastPanel := nil;
  end;
end;

procedure TFormMain.ScrollBox1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox1.VertScrollBar do
    Position := Position + Increment;
end;

procedure TFormMain.ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox1.VertScrollBar do
    Position := Position - Increment;
end;

end.
