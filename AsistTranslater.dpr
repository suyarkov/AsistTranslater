program AsistTranslater;

uses
  Vcl.Forms,
  FrmMain in 'FrmMain.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles,
  OAuth2 in 'OAuth2.pas',
  FrmDataSQLite in 'FrmDataSQLite.pas' {SQLiteModule: TDataModule},
  Classes.shearche.id in 'Classes.shearche.id.pas',
  Classes.shearche.image in 'Classes.shearche.image.pas',
  Classes.shearche.item in 'Classes.shearche.item.pas',
  Classes.shearche.pageInfo in 'Classes.shearche.pageInfo.pas',
  Classes.shearche in 'Classes.shearche.pas',
  Classes.shearche.snippet in 'Classes.shearche.snippet.pas',
  Classes.shearche.thumbnails in 'Classes.shearche.thumbnails.pas',
  uTranslate in 'uTranslate.pas',
  Classes.channel.snippet in 'Classes.channel.snippet.pas',
  Classes.channel.item in 'Classes.channel.item.pas',
  Classes.channel.statistics in 'Classes.channel.statistics.pas',
  Classes.channel in 'Classes.channel.pas',
  ChannelPanel in 'ChannelPanel.pas',
  Unit1 in 'Unit1.pas' {Form1},
  Classes.video in 'Classes.video.pas',
  Classes.video.thumbnails in 'Classes.video.thumbnails.pas',
  Classes.video.snippet in 'Classes.video.snippet.pas',
  Classes.video.item in 'Classes.video.item.pas',
  VideoPanel in 'VideoPanel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Silver');
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TSQLiteModule, SQLiteModule);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
