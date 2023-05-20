object FormWait: TFormWait
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'FormWait'
  ClientHeight = 53
  ClientWidth = 217
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 55
    Height = 15
    Caption = 'Loading ...'
  end
  object Button1: TButton
    Left = 304
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
  end
  object TimerWait: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerWaitTimer
    Left = 80
  end
end
