object FMiniWeb: TFMiniWeb
  Left = 174
  Top = 51
  Caption = 'MiniWeb'
  ClientHeight = 613
  ClientWidth = 862
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object web: TWebBrowser
    Left = 0
    Top = 42
    Width = 862
    Height = 552
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 12
    ExplicitTop = 48
    ExplicitWidth = 661
    ExplicitHeight = 489
    ControlData = {
      4C000000175900000D3900000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 862
    Height = 42
    Align = alTop
    Caption = 'GroupBox1'
    TabOrder = 1
    object Edit1: TEdit
      Left = 12
      Top = 18
      Width = 433
      Height = 21
      TabOrder = 0
      Text = 'Edit1'
    end
    object Button1: TButton
      Left = 448
      Top = 18
      Width = 75
      Height = 21
      Caption = 'Button1'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 594
    Width = 862
    Height = 19
    Panels = <>
    ExplicitLeft = 20
    ExplicitTop = 568
    ExplicitWidth = 0
  end
end
