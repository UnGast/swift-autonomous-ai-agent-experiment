import GraphicalControlApp
import SwiftGUI

func openGuiControl(_ evolution: Evolution<CellGrowthPolicy>) {
  let app = GraphicalControlApp(contentView: DependencyProvider(provide: [Dependency(evolution as! EvolutionProtocol, key: "evolution")]) {
    EvolutionPolicyEditor()
  })

  try! app.start()
}