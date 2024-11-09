namespace FractalPlasmEffect
{
    public partial class Form1 : Form
    {
        private const int DefaultWidth = 320;
        private const int DefaultHeight = 240;
        private const int DisplayScale = 4;
        private const int ExpectedFps = 30;
        private const int FadeSkip = 1;

        private Bitmap? _bitmap;
        private Particle? _particle;
        private int _frameIndex;

        public Form1()
        {
            InitializeComponent();
            this.DoubleBuffered = true;         //Double buffering without which the image flickers.
            this.ClientSize = new Size(DefaultWidth * DisplayScale, DefaultHeight * DisplayScale);
            System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer { Interval = 1000 / ExpectedFps };
            timer.Tick += TimerTick!;
            timer.Start();
            this.Paint += FormPaint!;
            this.Resize += FormResize!;
            InitializeEffect();
        }

        private void Form1_Load(object sender, EventArgs e) { }

        private void InitializeEffect()
        {
            _bitmap = new Bitmap(ClientSize.Width / DisplayScale, ClientSize.Height / DisplayScale);
            ResetEffect();
        }

        private void ResetEffect()
        {
            using (Graphics g = Graphics.FromImage(_bitmap!))
            {
                g.Clear(Color.Black);
            }
            _frameIndex = 0;
            _particle = new Particle
            {
                X = _bitmap!.Width / 2,
                Y = _bitmap!.Height / 2,
                DX = 1,
                DY = 1
            };
        }

        private void FormResize(object sender, EventArgs e)
        {
            //fix minimize window
            int width = Math.Max(ClientSize.Width / DisplayScale, 1);
            int height = Math.Max(ClientSize.Height / DisplayScale, 1);

            _bitmap = new Bitmap(width, height);

            //_bitmap = new Bitmap(ClientSize.Width / DisplayScale, ClientSize.Height / DisplayScale);
            ResetEffect();
        }

        private void TimerTick(object sender, EventArgs e)
        {
            Invalidate();
        }

        private void FormPaint(object sender, PaintEventArgs e)
        {
            using (Graphics g = Graphics.FromImage(_bitmap!))
            {
                PaintEffect(g);
            }

            // Scale up the bitmap for display
            e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            e.Graphics.DrawImage(_bitmap!, 0, 0, _bitmap!.Width * DisplayScale, _bitmap!.Height * DisplayScale);
        }

        private void PaintEffect(Graphics g)
        {
            _frameIndex++;

            // Fade effect
            if (_frameIndex > FadeSkip)
            {
                for (int y = 0; y < _bitmap!.Height; y++)
                {
                    for (int x = 0; x < _bitmap.Width; x++)
                    {
                        Color pixelColor = _bitmap.GetPixel(x, y);
                        Color fadedColor = Color.FromArgb(
                            Math.Max(0, pixelColor.R - 2),
                            Math.Max(0, pixelColor.G - 1),
                            Math.Max(0, pixelColor.B - 2));
                        _bitmap.SetPixel(x, y, fadedColor);
                    }
                }
                _frameIndex = 0;
            }

            Random rand = new Random();
            for (int i = 0; i < 4000; i++)
            {
                Color currentColor = _bitmap!.GetPixel(_particle!.X, _particle.Y);
                Color newColor = Color.FromArgb(
                    Math.Min(255, currentColor.R + 14),
                    Math.Min(255, currentColor.G + 8),
                    Math.Min(255, currentColor.B + 16));
                _bitmap.SetPixel(_particle.X, _particle.Y, newColor);

                // Move particle
                _particle.X += _particle.DX;
                _particle.Y += _particle.DY;

                // Randomize direction
                switch (rand.Next(4))
                {
                    case 0: _particle.DX = 1; break;
                    case 1: _particle.DX = -1; break;
                    case 2: _particle.DY = 1; break;
                    case 3: _particle.DY = -1; break;
                }

                // Random rare move
                if (rand.Next(40) == 0)
                {
                    switch (rand.Next(4))
                    {
                        case 0: _particle.X++; break;
                        case 1: _particle.X--; break;
                        case 2: _particle.Y++; break;
                        case 3: _particle.Y--; break;
                    }
                }

                // Wrap around edges
                if (_particle.X < 0) _particle.X = _bitmap.Width - 1;
                if (_particle.X >= _bitmap.Width) _particle.X = 0;
                if (_particle.Y < 0) _particle.Y = _bitmap.Height - 1;
                if (_particle.Y >= _bitmap.Height) _particle.Y = 0;
            }
        }
    }
}
