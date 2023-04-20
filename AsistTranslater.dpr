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
  Classes.shearche.items in 'Classes.shearche.items.pas',
  Classes.shearche.pageInfo in 'Classes.shearche.pageInfo.pas',
  Classes.shearche in 'Classes.shearche.pas',
  Classes.shearche.snippet in 'Classes.shearche.snippet.pas',
  Classes.shearche.thumbnails in 'Classes.shearche.thumbnails.pas',
  uTranslate in 'uTranslate.pas',
  Classes.channel.snippet in 'Classes.channel.snippet.pas',
  Classes.channel.item in 'Classes.channel.item.pas',
  Classes.channel.statistics in 'Classes.channel.statistics.pas',
  Classes.channel.items in 'Classes.channel.items.pas',
  Classes.channel in 'Classes.channel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Silver');
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TSQLiteModule, SQLiteModule);
  Application.Run;
end.
