unit ClothDemo.Cloth;

interface

uses
  System.UITypes, System.Types, Vcl.Graphics, System.Generics.Collections;

type
  TMouseState = record
    Cut: integer;
    Influence: integer;
    IsDown: Boolean;
    Button: TMouseButton;
    Pos: TPoint;
    PrevPos: TPoint;
  end;

  TConstraint = class;

  TWorld = class
    Buffer: TBitmap;
    Mouse: TMouseState;
    Accuracy: integer;
    Gravity: double;
    Spacing: double;
    TearDist: double;
    Friction: double;
    Bounce: double;
    constructor Create;
    constructor CreateWithDefaults(aWidth,aHeight:Integer);
    constructor CreateWithZeroG(aWidth,aHeight:Integer);
    procedure InitWithDefaults;
  public
    destructor Destroy; override;
    procedure ClearCanvas;
  end;

  TClothPoint = class

    type TPointFHelper = record helper for TPointF
      function SquareDistance(const P2: TPointF): Double;
    end;
  var
    World: TWorld;
    Pos:TPointF;
    PrevPos:TPointF;
    Force:TPointF;
    PinPos:TPointF;
    isPinned:Boolean;
    Constraints: TObjectList<TConstraint>;
    constructor Create(aPoint: TPointF; aWorld: TWorld);
    procedure Update(const aRect: TRect; aDelta: double);
    procedure Draw(aColor:TColor);
    procedure Resolve;
    procedure Attach(aPoint: TClothPoint);
    procedure Free(aConstraint: TConstraint);
    procedure AddForce(const aForce:TPointF);
    procedure Pin;
  private
    procedure CalcBounce(const aRect: TRect);
  public
    destructor Destroy; override;
  end;

  TConstraint = class
    P1: TClothPoint;
    P2: TClothPoint;
    Length: double;
    World: TWorld;
    constructor Create(aP1, aP2: TClothPoint; aWorld: TWorld);
    procedure Resolve;
    procedure Draw(aCanvas: TCanvas; aCol:TColor);
  end;

  TCloth = class
    World: TWorld;
    Points: TObjectList<TClothPoint>;
    Color:TColor;
    procedure Offset(p:TPointF);
    constructor Create(aFree: Boolean; aWorld: TWorld; aXCount, aYCount: integer);
    procedure Update(aDelta: double);
    destructor Destroy; override;
  end;



implementation

{ TPoint }

uses Math;

constructor TClothPoint.Create(aPoint: TPointF; aWorld: TWorld);
begin
  World     := aWorld;
  Pos       := aPoint;
  PrevPos   := Pos;
  Force     := TPointF.Zero;
  PinPos    := TPointF.Zero;
  Constraints := TObjectList<TConstraint>.Create;
end;

destructor TClothPoint.Destroy;
begin
  Constraints.Free;
  inherited;
end;

procedure TClothPoint.Draw(aColor:TColor);
var
  i: integer;
begin
  World.Buffer.Canvas.Brush.Color := clBlue;
  if IsPinned then
    World.Buffer.Canvas.FillRect(Rectf(Pos.X-2,Pos.Y-2,Pos.X+2,Pos.Y+2).Truncate);

  for i := Constraints.Count-1 downto 0 do
    Constraints[i].Draw(World.Buffer.Canvas, aColor);
end;

procedure TClothPoint.Update(const aRect: TRect; aDelta: double);
var
  sqdist:Double;
  n:TPointF;
begin
  if isPinned then
    Exit;

  if World.Mouse.IsDown then
  begin
    sqdist := Pos.SquareDistance(World.Mouse.Pos);
    if (World.Mouse.Button = TMouseButton.mbLeft) and (sqdist < sqr(World.Mouse.Influence)) then
      PrevPos := Pos - (World.Mouse.Pos - World.Mouse.PrevPos)
    else if sqdist < sqr(World.Mouse.Cut) then
      Constraints.Clear;
  end;
  AddForce(PointF(0, World.Gravity));
  n       := Pos + (Pos - PrevPos) * World.Friction + Force * aDelta;
  PrevPos := Pos;
  Pos     := n;
  Force   := TPointF.Zero;
  CalcBounce(aRect);
end;

procedure TClothPoint.Resolve;
var
  i: integer;
begin
  if isPinned then
    Exit;

  for i := Constraints.Count-1 downto 0 do
    Constraints[i].Resolve;
end;

procedure TClothPoint.Attach(aPoint: TClothPoint);
begin
  Constraints.Add( TConstraint.Create(self, aPoint, World) );
end;

procedure TClothPoint.Free(aConstraint: TConstraint);
begin
  Constraints.Delete(Constraints.IndexOf(aConstraint));
end;

procedure TClothPoint.AddForce(const aForce:TPointF);
begin
  Force := Force + aForce;
end;

procedure TClothPoint.Pin;
begin
  isPinned := True;
  PinPos := Pos;
end;

procedure TClothPoint.CalcBounce(const aRect: TRect);
begin
  if Pos.X >= aRect.Width  then  begin PrevPos.X := aRect.Width  + (aRect.Width  - PrevPos.X) * World.Bounce;    Pos.X := aRect.Width;   end  else
  if Pos.X <= 0            then  begin PrevPos.X := PrevPos.X * (-1 * World.Bounce);    Pos.X := 0;  end;
  if Pos.Y >= aRect.height then  begin PrevPos.Y := aRect.height + (aRect.height - PrevPos.Y) * World.Bounce;    Pos.Y := aRect.height;  end  else
  if Pos.Y <= 0            then  begin PrevPos.Y := PrevPos.Y * (-1 * World.Bounce);    Pos.Y := 0;  end;
end;

{ TConstraint }

constructor TConstraint.Create(aP1, aP2: TClothPoint; aWorld: TWorld);
begin
  World  := aWorld;
  // note that we get p1 and p2 passed in, and we just keep the reference
  // don't free these when destroying the constraint
  P1     := aP1;
  P2     := aP2;
  Length := World.Spacing;
end;

procedure TConstraint.Resolve;
var
  d,p:TPointF;
  dist, diff, mul: double;
begin
  dist := P1.Pos.Distance(P2.Pos);
  if dist < Length then
    Exit;

  d := P1.Pos - P2.Pos;

  diff := (Length - dist) / dist;
  if dist > World.TearDist then
    P1.Free(self);

  mul := diff * 0.5 * (1 - Length / dist);
  p  := d * mul;

  if not P1.isPinned then
    P1.Pos := P1.Pos + p;

  if not P2.isPinned then
    P2.Pos := P2.Pos - p;
end;

procedure TConstraint.Draw(aCanvas: TCanvas; aCol:TColor);
begin
  aCanvas.Pen.Color := aCol;
  aCanvas.moveTo(Round(P1.Pos.x), Round(P1.Pos.y));
  aCanvas.lineTo(Round(P2.Pos.x), Round(P2.Pos.y));
end;

{ TCloth }

procedure TCloth.Offset(p: TPointF);
var i:integer;
begin
  for I := 0 to Points.Count - 1 do
  begin
    Points[I].Pos.Offset(p);
    Points[I].PrevPos.Offset(p);
    Points[I].Force.Offset(p);
    Points[I].PinPos.Offset(p);
  end;
end;

constructor TCloth.Create(aFree: Boolean; aWorld: TWorld; aXCount, aYCount: integer);
var
  startX: double;
  startY: double;
  y, x  : integer;
  point : TClothPoint;
begin
  World  := aWorld;
  Points := TObjectList<TClothPoint>.Create;
  startX := World.Buffer.Canvas.ClipRect.Width / 2 - aXCount * World.Spacing / 2;
  startY := 20;

  for y := 0 to aYCount do
  begin
    for x := 0 to aXCount do
    begin
      point := TClothPoint.Create(
        Tpointf.Create(
          startX + x * World.Spacing ,
          startY + y * World.Spacing
        ), World);


      if (not aFree) and (y = 0) and (x mod 5 = 0) then
        point.Pin;
      if x <> 0 then
        point.Attach(Points.Last);
      if y <> 0 then
        point.Attach(Points[x + (y - 1) * (aXCount + 1)]);
      Points.Add(point);
    end;
  end;
end;

procedure TCloth.Update(aDelta: double);
var
  a,p: integer;
begin
  for a := 0 to World.Accuracy-1 do
    for p := Points.Count-1 downto 0 do
        Points[p].Resolve;

  for p := 0 to Points.Count-1 do
  begin
    Points[p].Update(World.Buffer.Canvas.ClipRect, aDelta * aDelta);
    Points[p].Draw(Color);
  end;
end;

destructor TCloth.Destroy;
begin
  Points.Free;
  inherited;
end;

constructor TWorld.CreateWithDefaults(aWidth,aHeight:Integer);
begin
  Create;
  InitWithDefaults;
  self.Buffer.SetSize(aWidth,aHeight);
end;

{ TWorld }

procedure TWorld.ClearCanvas;
begin
  Buffer.Canvas.Brush.Color := $888888;
  Buffer.Canvas.FillRect(Buffer.Canvas.ClipRect);
end;

constructor TWorld.Create;
begin
  inherited;
  Buffer := TBitmap.Create;
end;

constructor TWorld.CreateWithZeroG(aWidth,aHeight:Integer);
begin
  CreateWithDefaults(aWidth,aHeight);
  Gravity := 0;
end;

destructor TWorld.Destroy;
begin
  Buffer.Free;
  inherited;
end;

procedure TWorld.InitWithDefaults;
begin
  Accuracy := 5;
  Gravity  := 400;
  Spacing  := 8;
  TearDist := 60;
  Friction := 0.99;
  Bounce   := 0.5;

  Mouse.Cut       := 4;
  Mouse.Influence := 36;
  Mouse.IsDown      := false;
  Mouse.Button    := TMouseButton.mbLeft;
  Mouse.Pos    := TPoint.Zero;
  Mouse.PrevPos:= TPoint.Zero;
end;


{ TClothPoint.TPointFHelper }

function TClothPoint.TPointFHelper.SquareDistance(const P2: TPointF): Double;
begin
  Result := Sqr(Self.X - P2.X) + Sqr(Self.Y - P2.Y);
end;

end.
