import GraphicalControlApp
import SwiftGUI

func openGuiControl(simulation: Simulation) {
  let app = GraphicalControlApp(contentView: DependencyProvider(provide: [Dependency(simulation)]) {
    MainView()
  })
  _ = app.onTick {
    simulation.tick(deltaTime: $0.deltaTime)
  }
  try! app.start()
}