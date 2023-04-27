object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 457
  ClientWidth = 735
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Button2: TButton
    Left = 682
    Top = 295
    Width = 49
    Height = 25
    Caption = 'Button2'
    TabOrder = 0
    OnClick = Button2Click
  end
  object ScrollBox1: TScrollBox
    Left = 72
    Top = 1
    Width = 569
    Height = 408
    HorzScrollBar.ButtonSize = 10
    HorzScrollBar.Visible = False
    VertScrollBar.ButtonSize = 12
    BorderStyle = bsNone
    TabOrder = 1
    OnMouseMove = ScrollBox1MouseMove
    OnMouseWheelDown = ScrollBox1MouseWheelDown
    OnMouseWheelUp = ScrollBox1MouseWheelUp
  end
  object Panel1: TPanel
    Left = 88
    Top = 424
    Width = 145
    Height = 33
    Caption = 'Panel1'
    Ctl3D = False
    ParentBackground = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 2
    StyleElements = []
  end
end
