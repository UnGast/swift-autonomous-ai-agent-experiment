import SwiftGUI

public class MainView: ComposedWidget {
  @Inject
  var simulation: Simulation

  override public init() {
    super.init()
  }

  override public func performBuild() {
    rootChild = SimulationDrawing(simulation: simulation)
  }
}