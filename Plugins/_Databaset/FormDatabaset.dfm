object FDatabase: TFDatabase
  Left = 189
  Top = 205
  Caption = 'FDatabase'
  ClientHeight = 321
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 44
    Height = 13
    Caption = 'Nome file'
  end
  object Label2: TLabel
    Left = 8
    Top = 69
    Width = 75
    Height = 13
    Caption = 'Nome database'
  end
  object Button1: TButton
    Left = 8
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Leggi DB'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Scrivi'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 168
    Top = 32
    Width = 75
    Height = 25
    Caption = 'CancellaLinea'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 88
    Width = 283
    Height = 201
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
    WantTabs = True
    WordWrap = False
  end
  object Edit1: TEdit
    Left = 56
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'dbtest.txt'
  end
  object Edit2: TEdit
    Left = 88
    Top = 63
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object Button4: TButton
    Left = 216
    Top = 64
    Width = 75
    Height = 20
    Caption = 'RinominaDB'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 248
    Top = 32
    Width = 75
    Height = 25
    Caption = 'NuovoDB'
    TabOrder = 7
  end
  object Button6: TButton
    Left = 328
    Top = 32
    Width = 75
    Height = 25
    Caption = 'ChiudiDB'
    TabOrder = 8
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 297
    Top = 120
    Width = 64
    Height = 25
    Caption = '-->'
    TabOrder = 9
    OnClick = Button7Click
  end
  object ListView1: TListView
    Left = 368
    Top = 88
    Width = 241
    Height = 201
    Columns = <
      item
        Caption = 'cosa'
        Width = 90
      end
      item
        Caption = 'achi'
        Width = 66
      end
      item
        Caption = 'restituito'
        Width = 68
      end>
    GridLines = True
    TabOrder = 10
    ViewStyle = vsReport
  end
end
