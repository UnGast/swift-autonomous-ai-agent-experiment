import SwiftGUI

public class MainView: ContentfulWidget {
  @Inject
  var simulation: Simulation

  override public init() {
    super.init()
  }

  @DirectContentBuilder override public var content: DirectContent {
    SimulationDrawing(simulation: simulation)
  }
}