unit OAuth2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.StrUtils,
  //FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  JSON, Rest.Client, Rest.Types, Generics.Collections;

const
  redirect_uri = 'http://127.0.0.1:1904';

type
  TOAuth = class(TObject)//class
  private
    FClientID: string; // id клиента
    FClientSecret: string; // секретный ключ клиента приложения
    FScope: string;        // тип необходимых разрешения
    FExpires_in: TDateTime;
    FRefresh_token: string; // токен подключения
    FAccess_token: string;  // ключ доступа
    FFireBaseToken: string; // токен для складывания
    FResponseCode: string;  // точка доступа

    procedure SetClientID(const Value: string);
    procedure SetScope(const Value: string);

    function ParamValue(ParamName, JSONString: string): string;
    procedure SetAccess_token(const Value: string);      // установить ключ доступа
    procedure SetRefresh_token(const Value: string);     // установить токен длинный
    procedure SendRequest(URL: string; AFile: string); overload;  // перегруженная отправка
    function SendRequest(URL: string; Params: TDictionary<string, string>; Headers: TDictionary<string, string>; JSON: string; Method: TRESTRequestMethod; AFile: string = ''): string; overload;
    procedure SetResponseCode(const Value: string);
    procedure ServerResponseToFile(AResponse: TRestResponse; AFileName: string);

  public
    function SubtitleDelete(SubtitleID: string): string;
    function SubtitleList(VideoID: string): string;
    function SubtitleDownload(CaptionID, TargetLang: string): string;
    function SubtitleInsert(JSON: string; FileName: String): string;

    function Language: string;
    function GetTokenInfo: string;

    function VideoInfo(AVideoID: string): string;
    function VideoUpdate(JSON: string): string;
    function MyVideos(AChannelID: string; NextToken: string = ''): string;
    function MyChannels: string;
    function AccessURL: string;        // урл подключения
    function GetAccessToken: string;   // получить соединительный токен подключения
    function RefreshToken: string;     // постоянный ключ

    function FireBaseAuth: string;
    function FireBaseGet(ACollection: string): string;
    function FireBaseUpdate(ACollection, JSON: string): string;
    function FireBaseInsert(ACollection, ADocID, JSON: string): string;

    constructor Create;
    destructor destroy; override;

    property ClientID: string read FClientID write SetClientID;
    property Scope: string read FScope write SetScope;
    property ClientSecret: string read FClientSecret write FClientSecret;
    property Access_token: string read FAccess_token write SetAccess_token;
    property Refresh_token: string read FRefresh_token write SetRefresh_token;
    property ResponseCode: string read FResponseCode write SetResponseCode;
  end;

implementation

function TOAuth.AccessURL: string;
const
  oauth_url = 'https://accounts.google.com/o/oauth2/v2/auth?scope=%s&access_type=offline&include_granted_scopes=true&state=security_token&response_type=code&redirect_uri=%s&client_id=%s';
begin
  Result := Format(oauth_url, [Scope, redirect_uri, ClientID]);
end;

constructor TOAuth.Create;
begin
  inherited;
end;

destructor TOAuth.destroy;
begin
  inherited;
end;

procedure TOAuth.SetAccess_token(const Value: string);
begin
  FAccess_token := Value;
end;

procedure TOAuth.SetClientID(const Value: string);
begin
  FClientID := Value;
end;

procedure TOAuth.SetRefresh_token(const Value: string);
begin
  FRefresh_token := Value;
end;

procedure TOAuth.SetResponseCode(const Value: string);
begin
  FResponseCode := Value;
end;

procedure TOAuth.SetScope(const Value: string);
begin
  FScope := Value;
end;

procedure TOAuth.SendRequest(URL: string; AFile: string);
var
  FRest: TRestClient;
  FRequest: TRestrequest;
  FResponse: TRestResponse;
  i: integer;
  Key: String;
  LParam: TRESTRequestParameter;
  Boundary: string;
begin
  FRest := TRestClient.Create(URL);
  FResponse := TRestResponse.Create(nil);

  FRequest := TRestrequest.Create(nil);
  FRequest.Client := FRest;
  FRequest.Method := rmGet;
  FRequest.Response := FResponse;

  try

    FRequest.Execute;
    case FResponse.StatusCode of
      200:
        begin

          if Length(FResponse.RawBytes) <> 0 then
            ServerResponseToFile(FResponse, AFile);
        end;
    end;
  finally

  end;

end;

function TOAuth.SendRequest(URL: string; Params: TDictionary<string, string>; Headers: TDictionary<string, string>; JSON: string; Method: TRESTRequestMethod; AFile: string = ''): string;
var
  FRest: TRestClient;
  FRequest: TRestrequest;
  FResponse: TRestResponse;
  i: integer;
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
    end;
  finally

  end;

end;

procedure TOAuth.ServerResponseToFile(AResponse: TRestResponse; AFileName: string);
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

function TOAuth.GetAccessToken: string;
const
  tokenurl = 'https://oauth2.googleapis.com/token';
var
  Params: TDictionary<String, String>;
  Response: string;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('client_id', ClientID);
  Params.Add('client_secret', ClientSecret);
  Params.Add('code', StringReplace(ResponseCode, '%2F', '/', [rfReplaceAll]));
  Params.Add('redirect_uri', redirect_uri);
  Params.Add('grant_type', 'authorization_code');

  Response := SendRequest(tokenurl, Params, nil, '', rmPost);
  Access_token := TRIM(ParamValue('access_token', Response));
  Refresh_token := StringReplace(TRIM(ParamValue('refresh_token', Response)), '\', '', [rfReplaceAll]);
  Result := Access_token;
end;

function TOAuth.GetTokenInfo: string;
const
  tokenurl = 'https://www.googleapis.com/oauth2/v3/tokeninfo';
var
  Params: TDictionary<String, String>;
  Response: string;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('access_token', RefreshToken);

  Response := SendRequest(tokenurl, Params, nil, '', rmGet);
  Result := ParamValue('access_type', Response);
end;

// My channels
function TOAuth.MyChannels: string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/channels';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet,statistics');
  Params.Add('mine', 'true');

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmGet);

  Params.Free;
  Headers.Free
end;

// My videos
function TOAuth.MyVideos(AChannelID: string; NextToken: string = ''): string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/search';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet');
  Params.Add('forMine', 'true');
  Params.Add('maxResults', '10');
  Params.Add('type', 'video');

  if NextToken <> '' then
    Params.Add('pageToken', NextToken);

  if AChannelID <> '' then
    Params.Add('channelID', AChannelID);

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmGet);
end;

// Info video
function TOAuth.VideoInfo(AVideoID: string): string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/videos';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet');
  Params.Add('id', AVideoID);

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmGet);
end;

// Language
function TOAuth.Language: string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/i18nLanguages';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet');
  Params.Add('hl', 'en_US');

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmGet);
end;

// Update video
function TOAuth.VideoUpdate(JSON: string): string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/videos';
var
  Response: string;
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet,status,localizations');
  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Response := SendRequest(URL, Params, Headers, JSON, rmPUT);
  Result := TRIM(ParamValue('channelId', Response));
end;

// Subtitle list
function TOAuth.SubtitleList(VideoID: string): string;
const
  URL = 'https://www.googleapis.com/youtube/v3/captions';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet');
  Params.Add('videoId', VideoID);

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmGet);
end;

// Subtitle download
function TOAuth.SubtitleDownload(CaptionID, TargetLang: string): string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/captions/%s';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  // if TargetLang <> '' then
   Params.Add('tfmt', 'sbv');

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(Format(URL, [CaptionID]), Params, Headers, '', rmGet);
end;

// Subtitle delete
function TOAuth.SubtitleDelete(SubtitleID: string): string;
const
  URL = 'https://youtube.googleapis.com/youtube/v3/captions';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('id', SubtitleID);

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');

  Result := SendRequest(URL, Params, Headers, '', rmDelete, '');
end;

// Subtitle insert
function TOAuth.SubtitleInsert(JSON: string; FileName: String): string;
const
  URL = 'https://youtube.googleapis.com/upload/youtube/v3/captions';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('part', 'snippet');

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + RefreshToken);
  Headers.Add('Accept', 'application/json');
  Headers.Add('Content-Type', 'multipart/related; boundary=AUTO');

  Result := SendRequest(URL, Params, Headers, JSON, rmPost, FileName);
end;

// Firebase Auth
function TOAuth.FireBaseAuth(): string;
const
  URL = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
  Response: string;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('key', 'AIzaSyBGKt8Nd_XY6m-eEVdgHpZMNcG2WKwa6SA');

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Content-Type', 'application/json');

  Response := SendRequest(URL, Params, Headers, '{"returnSecureToken":true}', rmPost);
  FFireBaseToken := TRIM(ParamValue('idToken', Response));
  Result := FFireBaseToken;
end;

// Firebase get
function TOAuth.FireBaseGet(ACollection: string): string;
const
  URL = 'https://firestore.googleapis.com/v1/projects/samasiuk-autoclicker/databases/(default)/documents/';
var
  Headers: TDictionary<String, String>;
begin
  FireBaseAuth();
  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + FFireBaseToken);
  Headers.Add('Accept', 'application/json');
  Headers.Add('Content-Type', 'application/json');

  Result := SendRequest(URL + ACollection, nil, Headers, '', rmGet);
end;

// Firebase update
function TOAuth.FireBaseUpdate(ACollection, JSON: string): string;
const
  URL = 'https://firestore.googleapis.com/v1/projects/samasiuk-autoclicker/databases/(default)/documents/';
var
  Headers: TDictionary<String, String>;
begin
  FireBaseAuth();
  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + FFireBaseToken);
  Headers.Add('Accept', 'application/json');
  Headers.Add('Content-Type', 'application/json');
  StringReplace(JSON, '\', '', [rfReplaceAll]);
  Result := SendRequest(URL + ACollection, nil, Headers, JSON, rmPatch);
end;

// Firebase insert
function TOAuth.FireBaseInsert(ACollection, ADocID, JSON: string): string;
const
  URL = 'https://firestore.googleapis.com/v1/projects/samasiuk-autoclicker/databases/(default)/documents/';
var
  Params: TDictionary<String, String>;
  Headers: TDictionary<String, String>;
begin
  FireBaseAuth();

  Params := TDictionary<String, String>.Create;
  Params.Add('documentId', ADocID);

  Headers := TDictionary<String, String>.Create;
  Headers.Add('Authorization', 'Bearer ' + FFireBaseToken);
  Headers.Add('Accept', 'application/json');
  Headers.Add('Content-Type', 'application/json');

  StringReplace(JSON, '\', '', [rfReplaceAll]);

  Result := SendRequest(URL + ACollection, Params, Headers, JSON, rmPost);
end;

function TOAuth.ParamValue(ParamName, JSONString: string): string;
const
  StripChars: set of char = ['"', ':', ','];
var
  i, j: integer;
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

function TOAuth.RefreshToken: string;
const
  tokenurl = 'https://accounts.google.com/o/oauth2/token';
var
  Params: TDictionary<String, String>;
  Response: string;
begin
  Params := TDictionary<String, String>.Create;
  Params.Add('client_id', ClientID);
  Params.Add('client_secret', ClientSecret);
  Params.Add('refresh_token', Refresh_token);
  Params.Add('grant_type', 'refresh_token');

  Response := SendRequest(tokenurl, Params, nil, '', rmPost);
  Access_token := TRIM(ParamValue('access_token', Response));
  Result := Access_token;
end;

end.