unit UnitMain;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math, BitmapPixels;

const
  DefaultWidth = 320;
  DefaultHeight = 240;
  DisplayScale = 4;
  ExpectedFps = 30;
  FadeSkip = 1;

type

  TParticle = record
    X, Y: Integer;
    DX, DY: Integer;
  end;

  { TFormMain }

  TFormMain = class(TForm)
    PaintBox: TPaintBox;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FBitmap: TBitmap;
    FParticle: TParticle;
    FFrameIndex: Integer;
    procedure ResetEffect();
    procedure PaintEffect(Data: TBitmapData);
  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // создаем битмап для эффекта
  FBitmap := TBitmap.Create();

  // настраиваем размер формы под дефолтные размеры
  ClientWidth := DefaultWidth * DisplayScale;
  ClientHeight := DefaultHeight * DisplayScale;

  // настраиваем таймер для fps
  Timer.Interval := 1000 div ExpectedFps;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  // уничтожаем битмап
  FBitmap.Free();
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  // настраиваем размер битмапа под размер экрана, с учетом скейла
  FBitmap.SetSize(PaintBox.Width div DisplayScale, PaintBox.Height div DisplayScale);
  // сбрасываем эффект
  ResetEffect();
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject);
var
  Data: TBitmapData;
begin
  // создаем Data для изменения пикселов битмапа
  Data.Map(FBitmap, TAccessMode.ReadWrite, False, clBlack);
  try
    // рисуем эффект
    PaintEffect(Data);
  finally
    // применяем изменения
    Data.Unmap();
  end;

  // рисуем битмап на экран
  PaintBox.Canvas.StretchDraw(
    TRect.Create(0, 0, (PaintBox.Width div DisplayScale) * DisplayScale, (PaintBox.Height div DisplayScale) * DisplayScale),
    FBitmap
  );
end;

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  // вызываем перерисовку PaintBox
  PaintBox.Invalidate();
end;

procedure TFormMain.ResetEffect();
begin
  // заливаем черным цветом
  FBitmap.Canvas.Brush.Color := clBlack;
  FBitmap.Canvas.FillRect(0, 0, FBitmap.Width, FBitmap.Height);

  FFrameIndex := 0;
  FParticle.X := FBitmap.Width div 2;
  FParticle.Y := FBitmap.Height div 2;
  FParticle.DX := 1;
  FParticle.DY := 1;
end;

procedure TFormMain.PaintEffect(Data: TBitmapData);
var
  X, Y: Integer;
  Pixel: TPixelRec;
  I: Integer;
begin
  // фейд
  FFrameIndex := FFrameIndex + 1;
  if FFrameIndex > FadeSkip then
  begin
    for Y := 0 to Data.Height - 1 do
    begin
      for X := 0 to Data.Width - 1 do
      begin
        Pixel := Data.GetPixel(X, Y);
        Pixel.R := Max(0, Pixel.R - 2);
        Pixel.G := Max(0, Pixel.G - 1);
        Pixel.B := Max(0, Pixel.B - 2);
        Data.SetPixel(X, Y, Pixel);
      end;
    end;
    FFrameIndex := 0;
  end;

  for I := 1 to 4000 do
  begin
    // рисуем точку
    Pixel := Data.GetPixel(FParticle.X, FParticle.Y);
    Pixel.R := Min(255, Pixel.R + 14);
    Pixel.G := Min(255, Pixel.G + 8);
    Pixel.B := Min(255, Pixel.B + 16);
    Data.SetPixel(FParticle.X, FParticle.Y, Pixel);

    // сдвигаем
    FParticle.X := FParticle.X + FParticle.DX;
    FParticle.Y := FParticle.Y + FParticle.DY;

    // новая дельта
    case Random(4) of
      0: FParticle.DX := 1;
      1: FParticle.DX := -1;
      2: FParticle.DY := 1;
      3: FParticle.DY := -1;
    end;

    // случайный редкий сдвиг "шахматки"
    if Random(40) = 0 then
    begin
      case Random(4) of
        0: FParticle.X := FParticle.X + 1;
        1: FParticle.X := FParticle.X - 1;
        2: FParticle.Y := FParticle.Y + 1;
        3: FParticle.Y := FParticle.Y - 1;
      end;
    end;

    // корректирем
    if FParticle.X < 0 then
      FParticle.X := Data.Width - 1;
    if FParticle.X >= Data.Width then
      FParticle.X := 0;
    if FParticle.Y < 0 then
      FParticle.Y := Data.Height - 1;
    if FParticle.Y >= Data.Height then
      FParticle.Y := 0;
  end;
end;

end.

