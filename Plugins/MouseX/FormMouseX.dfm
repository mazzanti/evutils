object FMouseX: TFMouseX
  Left = 563
  Top = 423
  BorderStyle = bsToolWindow
  Caption = 'MouseX'
  ClientHeight = 192
  ClientWidth = 206
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 159
    Width = 113
    Height = 25
    Caption = 'Salva'
    TabOrder = 0
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 42
    Width = 174
    Height = 17
    Caption = 'MouseX Autostart'
    TabOrder = 1
    OnClick = CheckBox1Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 73
    Width = 190
    Height = 80
    Caption = 'Tremulo'
    TabOrder = 2
    object Label2: TLabel
      Left = 16
      Top = 22
      Width = 36
      Height = 13
      Caption = 'Fattore'
    end
    object Label3: TLabel
      Left = 16
      Top = 54
      Width = 37
      Height = 13
      Caption = 'Velocit'#224
    end
    object txtfattore: TEdit
      Left = 72
      Top = 19
      Width = 73
      Height = 21
      TabOrder = 0
      Text = '5'
    end
    object txtvelocita: TEdit
      Left = 72
      Top = 51
      Width = 73
      Height = 21
      TabOrder = 1
      Text = '10'
    end
  end
  object Button2: TButton
    Left = 127
    Top = 159
    Width = 71
    Height = 25
    Caption = 'Esci'
    TabOrder = 3
    OnClick = Button2Click
  end
  object btnmx: TButton
    Left = 8
    Top = 8
    Width = 190
    Height = 25
    Caption = 'MouseX On'
    TabOrder = 4
    OnClick = btnmxClick
  end
  object timr: TTimer
    Enabled = False
    Interval = 100
    OnTimer = timrTimer
    Left = 170
    Top = 6
  end
  object ttremulo: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ttremuloTimer
    Left = 168
    Top = 40
  end
end
