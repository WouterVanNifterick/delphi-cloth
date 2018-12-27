unit Cloth.Main.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls, System.Generics.Collections,
  System.Types, ClothDemo.Cloth, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    PaintBox: TPaintBox;
    tmr1: TTimer;
    pnlTop: TPanel;
    btnReset: TButton;
    btnZeroG: TButton;
    procedure btnResetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; button: TMouseButton; Shift: TShiftState; x, y: integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; x, y: integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  public
    World: TWorld;
    Cloths: TObjectList<TCloth>;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses Math;

procedure TfrmMain.btnResetClick(Sender: TObject);
var i : Integer; Cloth:TCloth;
begin
  Cloths.Free;
  World := TWorld.CreateWithDefaults(PaintBox.Width, PaintBox.Height);

  Cloths := TObjectList<TCloth>.Create;

  for I := -1 to 1 do
  begin
    Cloth := TCloth.Create(False, World, 40, 40);
    Cloth.Add(PointF(I*200,0));
    Cloth.Color := Random(MaxInt);
    Cloths.Add(Cloth);
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Cloths.Free;
  World.Free;
end;

{ TCanvas }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  btnResetClick(Sender);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  World.Buffer.SetSize(PaintBox.Width, PaintBox.Height);
end;

procedure TfrmMain.PaintBoxMouseDown(Sender: TObject; button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  World.Mouse.Button := button;
  World.Mouse.IsDown   := true;
  World.Mouse.PrevPos := World.Mouse.Pos;
  World.Mouse.Pos := Point(x,y);
end;

procedure TfrmMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; x,
  y: integer);
begin
  World.Mouse.PrevPos := World.Mouse.Pos;
  World.Mouse.Pos := Point(x,y);
end;

procedure TfrmMain.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  World.Mouse.IsDown := false;
end;

procedure TfrmMain.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0, World.Buffer);
end;

procedure TfrmMain.tmr1Timer(Sender: TObject);
var i:integer;
begin
  World.Buffer.Canvas.Brush.Color := clWhite;
  World.Buffer.Canvas.FillRect(World.Buffer.Canvas.ClipRect);
  for i := 0 to Cloths.Count-1 do
    Cloths[i].update(0.016);

  PaintBox.Invalidate;
end;


end.
