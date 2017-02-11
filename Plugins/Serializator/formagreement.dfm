object FSAgreement: TFSAgreement
  Left = 174
  Top = 55
  BorderStyle = bsToolWindow
  Caption = 'Agreement'
  ClientHeight = 163
  ClientWidth = 264
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 249
    Height = 121
    AutoSize = False
    Caption = 
      'This program doesn'#39't crack programs. ReVolt Crew doesn'#39't suggest' +
      ' pirating software or cracking applications. This plugin provide' +
      's to simplify and reducing time into the process of compiling se' +
      'rial numbers forms for games or other NONcorporate applications.' +
      ' Please don'#39't use pirate software or software will dies.'
    Transparent = True
    WordWrap = True
  end
  object btnokay: TButton
    Left = 184
    Top = 135
    Width = 75
    Height = 25
    Caption = 'Okay'
    TabOrder = 0
    OnClick = btnokayClick
  end
end
