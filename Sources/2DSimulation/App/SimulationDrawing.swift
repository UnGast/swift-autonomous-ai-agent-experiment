import SwiftGUI

public class SimulationDrawing: LeafWidget {
  let simulation: Simulation

  private var tileEdgeLength: Double {
    (DVec2(bounds.size) / DVec2(simulation.map.size)).elements.min()!
  }
  private var mapDrawingSize: DSize2 {
    DSize2(simulation.map.size) * tileEdgeLength
  }
  private var mapDrawingPos: DVec2 {
    DVec2(bounds.size) / 2 - tileEdgeLength * DVec2(simulation.map.size) / 2
  }

  public init(simulation: Simulation) {
    self.simulation = simulation
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(DSize2(40, 40))
  }

  override public func draw(_ drawingContext: DrawingContext) {
    drawingContext.transform(.translate(mapDrawingPos))
    drawingContext.transform(
      .scale(DVec2(1, -1), origin: mapDrawingPos + DVec2(mapDrawingSize) / 2))
    drawMap(drawingContext)
    drawGrid(drawingContext)

    let agents = simulation.query(Agent.self)
    drawAgents(agents, drawingContext)

    for agent in agents {
      drawGoal(agent.1.goal, drawingContext)
    }

    let (_, lidar) = simulation.query(Lidar.self)[0]
    drawLidarResults(lidar, drawingContext)
  }

  private func drawMap(_ drawingContext: DrawingContext) {
    for x in 0..<simulation.map.size.x {
      for y in 0..<simulation.map.size.y {
        let tileType = simulation.map[IVec2(x, y)]
        if tileType != .void {
          let tileBounds = DRect(
            min: DVec2(tileEdgeLength * Double(x), tileEdgeLength * Double(y)),
            max: DVec2((tileEdgeLength) * Double(x + 1), (tileEdgeLength) * Double(y + 1)))
          drawingContext.drawRect(rect: tileBounds, paint: Paint(color: Color(120, 160, 255, 255)))
        }
      }
    }
  }

  private func drawGrid(_ drawingContext: DrawingContext) {
    for x in 0..<simulation.map.size.x + 1 {
      drawingContext.drawLine(
        from: DVec2(Double(x) * tileEdgeLength, 0),
        to: DVec2(Double(x) * tileEdgeLength, mapDrawingSize.height),
        paint: Paint(strokeWidth: 0.5, strokeColor: .grey))
    }
    for y in 0..<simulation.map.size.y + 1 {
      drawingContext.drawLine(
        from: DVec2(0, Double(y) * tileEdgeLength),
        to: DVec2(mapDrawingSize.width, Double(y) * tileEdgeLength),
        paint: Paint(strokeWidth: 0.5, strokeColor: .grey))
    }
  }

  private func drawAgents(_ agents: [(SimulationEntity, Agent)], _ drawingContext: DrawingContext) {
    for (entity, agent) in agents {
      let bounds = DRect(
        min: DVec2(entity.position) * tileEdgeLength,
        max: DVec2(entity.position + 1) * tileEdgeLength)
      drawingContext.drawRect(rect: bounds, paint: Paint(color: Color.yellow))
      drawingContext.drawText(
        text: "reward: \(String(format: "%.2f", agent.totalReward))", position: entity.position * tileEdgeLength,
        paint: TextPaint(
          fontConfig: FontConfig(
            family: defaultFontFamily,
            size: 16.0,
            weight: .regular,
            style: .normal
          ), color: .black))
    }
  }

  private func drawGoal(_ goal: Goal, _ drawingContext: DrawingContext) {
    switch goal {
    case let .reachPosition(position):
      drawingContext.drawRect(
        rect: DRect(min: position * tileEdgeLength, size: DSize2(tileEdgeLength, tileEdgeLength)),
        paint: Paint(color: .red))
    }
  }

  private func drawLidarResults(_ lidar: Lidar, _ drawingContext: DrawingContext) {
    let points = lidar.hits.map { $0.position }
    for point in points {
      drawingContext.drawCircle(
        center: point * tileEdgeLength, radius: 5.0, paint: Paint(color: .yellow))
    }
  }
}
