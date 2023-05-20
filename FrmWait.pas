unit FrmWait;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormWait = class(TForm)
    TimerWait: TTimer;
    Label1: TLabel;
    Button1: TButton;
    procedure TimerWaitTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWait: TFormWait;
  Pan: array [1 .. 7] of TPanel;
  vPre : integer;

implementation

{$R *.dfm}

procedure TFormWait.FormActivate(Sender: TObject);

var
  i: integer;
//  vActiv
//  RGB(249,126,10);

begin
  TimerWait.Enabled := false;
//  showmessage('tut');
   vPre := 1;
   for I := 1 to 7 do
     begin
{      Pan[i] := TPanel.Create(FormWait);
      Pan[i].Parent := FormWait;
      Pan[i].Left := i * 25;
      Pan[i].Top := 8;
      Pan[i].width := 22;
      Pan[i].Height := 15;
      Pan[i].Color := clRed;}
      if i <> 1 then
        begin
        FormWait.Canvas.Brush.Color :=  RGB(97,114,152);
        FormWait.Canvas.Pen.Color := FormWait.Canvas.Brush.Color;
        end
      else
        begin
        FormWait.Canvas.Brush.Color :=  RGB(249,126,10);
        FormWait.Canvas.Pen.Color := FormWait.Canvas.Brush.Color;
        end;

       FormWait.Canvas.RoundRect( i*32-14, 25, i*32 + 30-14,  25+10, 6 ,6);
     end;
     Label1.Left := 14;
    TimerWait.Enabled := true;
end;

procedure TFormWait.TimerWaitTimer(Sender: TObject);
var
  vNow : integer;
begin
//  showmessage('tu2t');
//  Label1.Caption := IntToStr(vPre);
  vNow := vPre + 1;
  if vNow > 7 then
    vNow := 1;
//  Pan[vNow].Color := clGreen;
//  Pan[vPre].Color := clSkyBlue;
  FormWait.Canvas.Brush.Color := RGB(249,126,10);
  FormWait.Canvas.Pen.Color := FormWait.Canvas.Brush.Color;
  FormWait.Canvas.RoundRect( vNow*28-14, 25, vNow*28 + 26-14, 25+10, 6, 6);
  FormWait.Canvas.Brush.Color := RGB(97,114,152);
  FormWait.Canvas.Pen.Color := FormWait.Canvas.Brush.Color;
  FormWait.Canvas.RoundRect( vPre*28-14, 25, vPre*28 + 26-14, 25+10, 6, 6);
  vPre := vNow;
end;

end.
