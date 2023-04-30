unit VideoPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  jpeg, IdTCPConnection, IdTCPClient,
  System.Net.HTTPClient;

type
  TMyVideoPanel = class(TPanel)
    vdImage: TImage;
    vdUrlImage: TLabel;
    vdTitle: TLabel;
    vdDescription: TLabel;
    vdLang: TLabel;
//    ButtonDel: TButton;
    vdId  : TLabel;
    vdToken  : TLabel;
  public
    constructor Create(AOwner: TComponent); overload; override;
    // constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; pPosX, pPosY, pN: integer;
                pVideoId, pVideoToken, pVideoTitle, pVideoDescription, pVideoLang,
                pUrlImage : string); reintroduce;
      overload; virtual;
  end;

implementation

constructor TMyVideoPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//  Parent := AOwner;
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 585;
  Height := 105;
  Left := 8;
  ParentColor := false;
  StyleElements := [seFont,seBorder];
  BevelOuter :=  bvNone;
end;

constructor TMyVideoPanel.Create(AOwner: TComponent; pPosX, pPosY, pN: integer;
            pVideoId, pVideoToken, pVideoTitle, pVideoDescription, pVideoLang,
            pUrlImage : string);

var
  vS : string;
  AAPIUrl: String;
  FHTTPClient: THTTPClient;
  AResponce: IHTTPResponse;
  jpegimg: TJPEGImage;
begin
  Create(AOwner);
  Self.Top := 8 + pPosX;
  //Self.Name := 'P' + IntToStr(pN);
  Self.tag :=  pN;

  vdId := TLabel.Create(Self);
  with vdId do
  begin
    Parent := Self;
    Caption := pVideoId;
    Visible := false;
    tag :=  pN;
  end;

  vdToken := TLabel.Create(Self);
  with vdToken do
  begin
    Parent := Self;
    Caption := pVideoToken;
    Visible := false;
    tag :=  pN;
  end;

  vdTitle := TLabel.Create(Self);
  with vdTitle do
  begin
    Parent := Self;
    Caption := pVideoTitle;
    Name := 'N' + IntToStr(pN);
    Width := 449;
    Top:=  25;
    Height :=  21;
    left := 120;
    Font.Size := 12;
    Font.Style := [fsBold];
    Tag :=  pN;
    Visible := True;
  end;

  vdImage := TImage.Create(Self);
  with vdImage do
  begin
    Parent := Self;
    Height := 88;
    Left := 8;
    Top := 8;
    Width := 88;
    Tag :=  pN;{
      try

        vS := StringReplace(pUrlImage, #13, '', [rfReplaceAll, rfIgnoreCase]);
        AAPIUrl := StringReplace(vS, #10, '', [rfReplaceAll, rfIgnoreCase]);
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
        vdImage.Picture.Assign(jpegimg);
      except
      end;      }
    Visible := True;
  end;
end;

end.
