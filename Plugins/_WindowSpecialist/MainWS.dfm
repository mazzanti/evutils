object FWindowSpecialist: TFWindowSpecialist
  Left = 420
  Top = 285
  BorderStyle = bsToolWindow
  Caption = 'WindowSpecialist'
  ClientHeight = 446
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 240
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Get Handle'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 328
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Get Caption'
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 48
    Width = 393
    Height = 359
    Caption = 'Posizioni preferite'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 22
      Height = 13
      Caption = 'Titoli'
    end
    object Label2: TLabel
      Left = 208
      Top = 24
      Width = 44
      Height = 13
      Caption = 'Proprieta'
    end
    object Label3: TLabel
      Left = 305
      Top = 51
      Width = 18
      Height = 13
      Caption = 'Top'
    end
    object Label4: TLabel
      Left = 220
      Top = 51
      Width = 19
      Height = 13
      Caption = 'Left'
    end
    object Label5: TLabel
      Left = 220
      Top = 96
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object Label6: TLabel
      Left = 305
      Top = 96
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object ListBox1: TListBox
      Left = 16
      Top = 43
      Width = 175
      Height = 150
      ItemHeight = 13
      TabOrder = 0
    end
    object txtleft: TEdit
      Left = 224
      Top = 72
      Width = 57
      Height = 21
      TabOrder = 1
      Text = '0'
    end
    object txttop: TEdit
      Left = 312
      Top = 70
      Width = 57
      Height = 21
      TabOrder = 2
      Text = '0'
    end
    object txtwidth: TEdit
      Left = 224
      Top = 115
      Width = 57
      Height = 21
      TabOrder = 3
      Text = '0'
    end
    object txtheight: TEdit
      Left = 312
      Top = 115
      Width = 57
      Height = 21
      TabOrder = 4
      Text = '0'
    end
    object Button4: TButton
      Left = 16
      Top = 199
      Width = 81
      Height = 25
      Caption = 'Aggiungi...'
      TabOrder = 5
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 112
      Top = 199
      Width = 79
      Height = 25
      Caption = 'Togli'
      TabOrder = 6
      OnClick = Button5Click
    end
    object Button9: TButton
      Left = 208
      Top = 144
      Width = 75
      Height = 25
      Caption = 'Disabilita'
      TabOrder = 7
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 289
      Top = 144
      Width = 75
      Height = 25
      Caption = 'Abilita'
      TabOrder = 8
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 208
      Top = 175
      Width = 75
      Height = 25
      Caption = 'Nascondi'
      TabOrder = 9
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 289
      Top = 175
      Width = 75
      Height = 25
      Caption = 'Mostra'
      TabOrder = 10
      OnClick = Button12Click
    end
    object Button13: TButton
      Left = 208
      Top = 205
      Width = 75
      Height = 25
      Caption = 'Massimizza'
      TabOrder = 11
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 289
      Top = 205
      Width = 75
      Height = 25
      Caption = 'Minimizza'
      TabOrder = 12
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 208
      Top = 236
      Width = 75
      Height = 25
      Caption = 'Ripristina'
      TabOrder = 13
      OnClick = Button15Click
    end
    object Button17: TButton
      Left = 289
      Top = 236
      Width = 75
      Height = 25
      Caption = 'Chiudi'
      TabOrder = 14
      OnClick = Button17Click
    end
    object Button19: TButton
      Left = 208
      Top = 267
      Width = 75
      Height = 25
      Caption = 'No taskbar'
      TabOrder = 15
      OnClick = Button19Click
    end
    object Button20: TButton
      Left = 289
      Top = 267
      Width = 75
      Height = 25
      Caption = 'In Taskbar'
      TabOrder = 16
      OnClick = Button20Click
    end
    object Button21: TButton
      Left = 208
      Top = 298
      Width = 75
      Height = 25
      Caption = 'On Top'
      TabOrder = 17
      OnClick = Button21Click
    end
    object Button22: TButton
      Left = 289
      Top = 298
      Width = 75
      Height = 25
      Caption = 'Not Top'
      TabOrder = 18
      OnClick = Button22Click
    end
  end
  object Button6: TButton
    Left = 8
    Top = 413
    Width = 393
    Height = 25
    Caption = 'Salva impostazioni'
    TabOrder = 3
    OnClick = Button6Click
  end
  object Button3: TButton
    Left = 8
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Setta posizioni'
    TabOrder = 4
    OnClick = Button3Click
  end
  object GroupBox2: TGroupBox
    Left = 407
    Top = 48
    Width = 266
    Height = 261
    Caption = 'Finestre attive correnti'
    TabOrder = 5
    object ListBox2: TListBox
      Left = 8
      Top = 47
      Width = 249
      Height = 170
      ItemHeight = 13
      TabOrder = 0
    end
    object Button7: TButton
      Left = 8
      Top = 20
      Width = 249
      Height = 25
      Caption = 'Get / Refresh'
      TabOrder = 1
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 8
      Top = 222
      Width = 75
      Height = 25
      Caption = '<< Add'
      TabOrder = 2
      OnClick = Button8Click
    end
  end
  object CheckBox1: TCheckBox
    Left = 408
    Top = 344
    Width = 97
    Height = 17
    Caption = 'Autoposition'
    TabOrder = 6
  end
  object tautopos: TTimer
    Enabled = False
    Interval = 500
    Left = 472
    Top = 352
  end
end
