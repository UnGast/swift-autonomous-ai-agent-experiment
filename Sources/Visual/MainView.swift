import SwiftGUI 
import Simulation

public class MainView: SingleChildWidget {
  @Inject
  private var simulation: Simulation

  override public func buildChild() -> Widget {
    Experimental.Container { [unowned self] in
      Experimental.DefaultTheme()

      SimulationDrawing(simulation: simulation)
    }
  }
}