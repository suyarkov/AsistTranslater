unit ChannelPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  jpeg;

type
  TMyPanel = class(TPanel)
    ChImage: TImage;
    ChName: TLabel;
    ChLang: TLabel;
    ButtonDel: TButton;
    chId  : TLabel;
  public
    constructor Create(AOwner: TComponent); overload; override;
    // constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; pPos, pN: integer; pChId, pChName, pChLang : string); reintroduce;
      overload; virtual;
  end;

implementation

constructor TMyPanel.Create(AOwner: TComponent);
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
  //Top := 8;
end;

constructor TMyPanel.Create(AOwner: TComponent;  pPos, pN: integer; pChId, pChName, pChLang : string);
begin
  Create(AOwner);
  Self.Top := 8 + pPos;
  //Self.Name := 'P' + IntToStr(pN);

  ChId := TLabel.Create(Self);
  with ChId do
  begin
    Parent := Self;
    Caption := pChId;
    Visible := false;
  end;

  ButtonDel := TButton.Create(Self);
  with ButtonDel do
  begin
    Parent := Self;
    Caption := 'Delete';
    name := 'D' + IntToStr(pN);
    Left := 500;
    Top := 10;
    Width := 60;
    Tag := 0;
    Visible := True;
  end;

  ChName := TLabel.Create(Self);
  with ChName do
  begin
    Parent := Self;
    Caption := pChName;
    Width := 449;
    Top:=  25;
    Height :=  21;
    left := 120;
    Font.Size := 12;
    Font.Style := [fsBold];
    Tag := 0;
    Visible := True;
  end;

  ChLang := TLabel.Create(Self);
  with ChLang do
  begin
    Parent := Self;
    Caption := pChLang;
    Height := 17;
    Left := 120;
    Top := 64;
    Width := 449;
    Font.Size := 10;
    Tag := 0;
    Visible := True;
  end;

  ChImage := TImage.Create(Self);
  with ChImage do
  begin
    Parent := Self;
    Height := 88;
    Left := 8;
    Top := 8;
    Width := 88;
    Tag := 0;
    ChImage.Picture.LoadFromFile('d:/tete.jpg');
    Visible := True;
  end;
end;

end.
