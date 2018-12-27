object frmMain: TfrmMain
  Left = 0
  Top = 0
  Width = 809
  Height = 491
  AutoScroll = True
  Caption = 'Cloth'
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 0
    Top = 35
    Width = 793
    Height = 417
    HelpType = htKeyword
    Align = alClient
    Color = clBtnFace
    ParentColor = False
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnMouseUp = PaintBoxMouseUp
    OnPaint = PaintBoxPaint
    ExplicitLeft = 12
    ExplicitTop = 32
    ExplicitWidth = 700
    ExplicitHeight = 376
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 793
    Height = 35
    Align = alTop
    TabOrder = 0
    object btnReset: TButton
      Left = 8
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Reset'
      TabOrder = 0
      OnClick = btnResetClick
    end
    object btnZeroG: TButton
      Left = 89
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Zero G'
      TabOrder = 1
      OnClick = btnZeroGClick
    end
  end
  object tmr1: TTimer
    Interval = 1
    OnTimer = tmr1Timer
    Left = 352
    Top = 216
  end
end
