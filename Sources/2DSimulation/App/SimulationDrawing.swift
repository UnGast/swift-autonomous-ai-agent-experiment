import SwiftGUI
import Simulation

public class SimulationDrawing: Widget, LeafWidget {
  let simulation: Simulation
  var controlledAgent: Agent {
    simulation.agents[0]
  }

  private var tileEdgeLength: Double {
    (DVec2(size) / DVec2(simulation.map.size)).elements.min()!
  }

  public init(simulation: Simulation) {
    self.simulation = simulation
    super.init()
    _ = self.onTick(processTick)
  }

  func processTick(_ tick: Tick) {
    if context.keyStates[.ArrowUp] {
      controlledAgent.queueAction(.moveForward)
    }
    if context.keyStates[.ArrowDown] {
      controlledAgent.queueAction(.moveBackward)
    }
    if context.keyStates[.ArrowRight] {
      controlledAgent.queueAction(.moveRight)
    }
    if context.keyStates[.ArrowLeft] {
      controlledAgent.queueAction(.moveLeft)
    }
  }

  override public func getContentBoxConfig() -> BoxConfig {
    BoxConfig(preferredSize: DSize2(20, 20))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(boxConfig.preferredSize)
  }

  public func draw(_ drawingContext: DrawingContext) {
    drawMap(drawingContext)
    drawGrid(drawingContext)
    drawAgents(drawingContext)
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
    for x in 0..<simulation.map.size.x - 1 {
      drawingContext.drawLine(from: DVec2(Double(x + 1) * tileEdgeLength, 0), to: DVec2(Double(x + 1) * tileEdgeLength, height), paint: Paint(strokeWidth: 0.5, strokeColor: .grey)) 
    }
    for y in 0..<simulation.map.size.y - 1 {
      drawingContext.drawLine(from: DVec2(0, Double(y + 1) * tileEdgeLength), to: DVec2(width, Double(y + 1) * tileEdgeLength), paint: Paint(strokeWidth: 0.5, strokeColor: .grey)) 
    }
  }

  private func drawAgents(_ drawingContext: DrawingContext) {
    for agent in simulation.agents {
      let bounds = DRect(min: DVec2(agent.position) * tileEdgeLength, max: DVec2(agent.position + 1) * tileEdgeLength)
      drawingContext.drawRect(rect: bounds, paint: Paint(color: Color.yellow))
    }
  }
}