program AsistTranslater;

uses
  Vcl.Forms,
  FrmMain in 'FrmMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
