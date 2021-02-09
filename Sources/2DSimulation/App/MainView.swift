import SwiftGUI

public class MainView: Experimental.ComposedWidget {
  @Inject
  var simulation: Simulation

  override public init() {
    super.init()
  }

  override public func performBuild() {
    rootChild = SimulationDrawing(simulation: simulation)
  }
}