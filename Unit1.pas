unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ChannelPanel;

type
  TForm1 = class(TForm)
    Button2: TButton;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
  private
    { Private declarations }
    i: Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  PanChannels: array [1 .. 20] of TMyPanel;
  lastPanel: TPanel;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  // для всех динамических кнопок, один обработчик.
  showmessage('Удалим канал из списка? ' + TButton(Sender).Name);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  vPos: Integer;
begin
  vPos := (i - 1) * 120;
  PanChannels[i] := TMyPanel.Create(ScrollBox1, vPos, i, 'dd' + IntToStr(i), 'MyName' + IntToStr(i),
    'Eng lkdj');
  PanChannels[i].Parent := ScrollBox1;
  PanChannels[i].ButtonDel.OnClick := Button1Click;
  PanChannels[i].OnMouseMove := Panel1MouseMove;
  inc(i);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  i := 1;
  lastPanel := nil;
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
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

procedure TForm1.ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if lastPanel <> nil then
  begin
    lastPanel.Color := clBtnFace;
    lastPanel.Font.Color := clBlack;
    lastPanel := nil;
  end;
end;

procedure TForm1.ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox1.VertScrollBar do
    Position := Position + Increment;
end;

procedure TForm1.ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox1.VertScrollBar do
    Position := Position - Increment;
end;

end.
