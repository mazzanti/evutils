object FPop: TFPop
  Left = 292
  Top = 197
  BorderStyle = bsToolWindow
  Caption = 'FPop'
  ClientHeight = 479
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object InfoLabel: TLabel
    Left = 170
    Top = 118
    Width = 45
    Height = 13
    Caption = 'InfoLabel'
  end
  object popusr: TEdit
    Left = 16
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'prova@evdomain'
  end
  object poppass: TEdit
    Left = 16
    Top = 75
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'prova'
  end
  object btnconnect: TButton
    Left = 62
    Top = 328
    Width = 75
    Height = 25
    Caption = 'btnconnect'
    TabOrder = 2
    OnClick = btnconnectClick
  end
  object pophost: TEdit
    Left = 16
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '127.0.0.1'
  end
  object DisplayMemo: TMemo
    Left = 332
    Top = 8
    Width = 469
    Height = 468
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 4
    WordWrap = False
  end
  object popport: TEdit
    Left = 152
    Top = 8
    Width = 53
    Height = 21
    TabOrder = 5
    Text = 'pop3'
  end
  object btnuser: TButton
    Left = 62
    Top = 366
    Width = 75
    Height = 25
    Caption = 'btnuser'
    TabOrder = 6
    OnClick = btnuserClick
  end
  object btnpass: TButton
    Left = 62
    Top = 397
    Width = 75
    Height = 25
    Caption = 'btnpass'
    TabOrder = 7
    OnClick = btnpassClick
  end
  object btnnext: TButton
    Left = 251
    Top = 145
    Width = 75
    Height = 25
    Caption = 'btnnext'
    TabOrder = 8
    OnClick = btnnextClick
  end
  object MsgNumEdit: TEdit
    Left = 8
    Top = 246
    Width = 25
    Height = 21
    TabOrder = 9
  end
  object SubjectEdit: TEdit
    Left = 8
    Top = 176
    Width = 318
    Height = 21
    TabOrder = 10
    Text = 'SubjectEdit'
  end
  object FromEdit: TEdit
    Left = 8
    Top = 203
    Width = 169
    Height = 21
    TabOrder = 11
    Text = 'FromEdit'
  end
  object ToEdit: TEdit
    Left = 183
    Top = 203
    Width = 143
    Height = 21
    TabOrder = 12
    Text = 'ToEdit'
  end
  object retr: TButton
    Left = 8
    Top = 144
    Width = 75
    Height = 25
    Caption = 'retr'
    TabOrder = 13
    OnClick = retrClick
  end
  object lstall: TButton
    Left = 89
    Top = 113
    Width = 75
    Height = 25
    Caption = 'lstall'
    TabOrder = 14
    OnClick = lstallClick
  end
  object list: TButton
    Left = 8
    Top = 113
    Width = 75
    Height = 25
    Caption = 'list'
    TabOrder = 15
    OnClick = listClick
  end
  object open: TButton
    Left = 143
    Top = 73
    Width = 75
    Height = 25
    Caption = 'open'
    TabOrder = 16
    OnClick = openClick
  end
  object getall: TButton
    Left = 112
    Top = 145
    Width = 133
    Height = 25
    Caption = 'Download all messages'
    TabOrder = 17
    OnClick = GetAllButtonClick
  end
  object Pop3Client: TPop3Cli
    Tag = 0
    LocalAddr = '0.0.0.0'
    Port = 'pop3'
    AuthType = popAuthNone
    MsgLines = 0
    MsgNum = 0
    OnDisplay = Pop3ClientDisplay
    OnMessageBegin = Pop3ClientMessageBegin
    OnMessageEnd = Pop3ClientMessageEnd
    OnMessageLine = Pop3ClientMessageLine
    OnListBegin = Pop3ClientListBegin
    OnListEnd = Pop3ClientListEnd
    OnListLine = Pop3ClientListLine
    OnUidlBegin = Pop3ClientUidlBegin
    OnUidlEnd = Pop3ClientUidlEnd
    OnUidlLine = Pop3ClientUidlLine
    OnHeaderEnd = Pop3ClientHeaderEnd
    Left = 8
    Top = 8
  end
end
