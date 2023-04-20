object SQLiteModule: TSQLiteModule
  OnCreate = DataModuleCreate
  Height = 114
  Width = 192
  object SQL: TFDConnection
    Params.Strings = (
      'ConnectionDef=Click'
      'Database=D:\GitClicker\AsistTranslater\libast.dll')
    LoginPrompt = False
    Left = 43
    Top = 15
  end
end
