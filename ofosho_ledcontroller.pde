/**
 * This is the "main" file.
 */

// Set this to false to disable opening the Simulation window. This window is not
// necessary when running on the Raspberry Pi, it just consumes more CPU.
final boolean IS_SIMULATION_ENABLED = true;
final String FADECANDY_HOST = "192.168.1.5";
final int FADECANDY_PORT = 7890;
final int CANVAS_WIDTH = 640;
final int CANVAS_HEIGHT = 200;

boolean is_window_positioned = false;  // Have we moved the main canvas window to its correct location on screen yet?
EffectController effect_controller;


void settings() {
  size(CANVAS_WIDTH, CANVAS_HEIGHT);
}


void setup()
{
  // This is commented out as it's not normally supposed to be run. We add it in here just for convenience because
  // Processing makes it harder to make multiple application entry points. If it's uncommented, it just generates
  // a basic shapes_description.json file and exits immediately.
  // genShapeFile();

  colorMode(RGB, 255, 255, 255);

  Shapes shapes = (new InitShapes()).initializeShapes();

  // Initialize the thread that sends LED pixel colors to the FadeCandy server
  OPC opc = new OPC(this, FADECANDY_HOST, FADECANDY_PORT);
  // Register each LED's canvas location with OPC.
  for(Shape shape: shapes.shapes) {
    for(LedPixel led_pixel: shape.leds) {
      opc.led(
        led_pixel.opc_index,
        (int)led_pixel.canvas_position.x,
        (int)led_pixel.canvas_position.y
      );
    }
  }
  PlasticMask plastic_mask = new PlasticMask(shapes);

  Plasma plasma = new Plasma(CANVAS_WIDTH, CANVAS_HEIGHT);
  Fire fire = new Fire(CANVAS_WIDTH, CANVAS_HEIGHT);

  List<IEffect> effects = new ArrayList<IEffect>();
  effects.add(new BlobEffect());
  effects.add(new FireCanvasEffect(fire));
  effects.add(new FirePointEffect(fire));
  effects.add(new BulbChaser());
  effects.add(new LetterWriter());
  effects.add(new LetterCycleEffect());
  effects.add(new PlasmaPointEffect(plasma));
  effects.add(new PlasmaCanvasEffect(plasma));
  effects.add(new Rainbow());
  effects.add(new RotatingRainbow());
  effects.add(new MouseDot());

  effect_controller = new EffectController(this, shapes, effects, plastic_mask);
  
  if (IS_SIMULATION_ENABLED) {
    Simulation simulation = new Simulation(shapes, CANVAS_WIDTH, CANVAS_HEIGHT, plastic_mask);
    simulation.start();
  }
}


/*
 Standard Processing function, called every animation frame.
*/
void draw()
{
  if(!is_window_positioned) {
    // Move the main window to a specific location on the screen.
    // We only want to do this once, but for technical reasons this code needs to be in draw(), not setup().
    surface.setLocation(0, 200);
    is_window_positioned = true;
  }

  effect_controller.renderEffects();
}

void mousePressed() {
  effect_controller.cycleToNextEffect();
}
