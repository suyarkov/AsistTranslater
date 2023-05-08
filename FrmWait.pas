unit FrmWait;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TFormWait = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWait: TFormWait;
  Pan: array [1 .. 7] of TPanel;

implementation

{$R *.dfm}

procedure TFormWait.FormCreate(Sender: TObject);
var
  i: integer;
begin
   for I := 1 to 7 do
     begin
      Pan[i] := TPanel.Create(FormWait);
      Pan[i].Parent := FormWait;
      Pan[i].Left := i * 25;
      Pan[i].Top := 8;
      Pan[i].width := 22;
      Pan[i].Height := 15;
     end;
end;

end.
