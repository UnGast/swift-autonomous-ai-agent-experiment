import SwiftGUI

public class SimulationDrawing: Widget, LeafWidget {
  let simulation: Simulation

  private var tileEdgeLength: Double {
    (DVec2(size) / DVec2(simulation.map.size)).elements.min()!
  }
  private var mapDrawingSize: DSize2 {
    DSize2(simulation.map.size) * tileEdgeLength
  }
  private var mapDrawingPos: DVec2 {
    DVec2(size) / 2 - tileEdgeLength * DVec2(simulation.map.size) / 2
  }

  public init(simulation: Simulation) {
    self.simulation = simulation
  }

  override public func getContentBoxConfig() -> BoxConfig {
    BoxConfig(preferredSize: DSize2(20, 20))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(boxConfig.preferredSize)
  }

  public func draw(_ drawingContext: DrawingContext) {
    drawingContext.transform(.translate(mapDrawingPos))
    drawingContext.transform(.scale(DVec2(1, -1), origin: mapDrawingPos + DVec2(mapDrawingSize) / 2))
    drawMap(drawingContext)
    drawGrid(drawingContext)

    let agents = simulation.query(Agent.self)
    drawAgents(agents, drawingContext)
  }

  private func drawMap(_ drawingContext: DrawingContext) {
    for x in 0..<simulation.map.size.x {
      for y in 0..<simulation.map.size.y {
        let tileType = simulation.map[IVec2(x, y)]
        if tileType != .void {
          let tileBounds = DRect(min: DVec2(tileEdgeLength * Double(x), tileEdgeLength * Double(y)), max: DVec2((tileEdgeLength) * Double(x + 1), (tileEdgeLength) * Double(y + 1)))
          drawingContext.drawRect(rect: tileBounds, paint: Paint(color: Color(120, 160, 255, 255)))
        }
      }
    }
  }

  private func drawGrid(_ drawingContext: DrawingContext) {
    for x in 0..<simulation.map.size.x + 1 {
      drawingContext.drawLine(from: DVec2(Double(x) * tileEdgeLength, 0), to: DVec2(Double(x) * tileEdgeLength, mapDrawingSize.height), paint: Paint(strokeWidth: 0.5, strokeColor: .grey)) 
    }
    for y in 0..<simulation.map.size.y + 1 {
      drawingContext.drawLine(from: DVec2(0, Double(y) * tileEdgeLength), to: DVec2(mapDrawingSize.width, Double(y) * tileEdgeLength), paint: Paint(strokeWidth: 0.5, strokeColor: .grey)) 
    }
  }

  private func drawAgents(_ agents: [(SimulationEntity, Agent)], _ drawingContext: DrawingContext) {
    for (entity, agent) in agents {
      let bounds = DRect(min: DVec2(entity.position) * tileEdgeLength, max: DVec2(entity.position + 1) * tileEdgeLength)
      drawingContext.drawRect(rect: bounds, paint: Paint(color: Color.yellow))
    }
  }
}