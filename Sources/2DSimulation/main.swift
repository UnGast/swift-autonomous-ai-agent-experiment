import GfxMath
import GraphicalControlApp
import SwiftGUI

let map = Map(size: ISize2(20, 20))
map[IVec2(10, 10)] = .solid

let mapEditor = MapEditor(map: map)
mapEditor.fill(IRect(min: IVec2(0, 0), max: IVec2(20, 5)), with: .solid)

func mapToEntities(_ map: Map) -> [SimulationEntity] {
  var entities = [SimulationEntity]()

  for x in 0..<map.size.x {
    for y in 0..<map.size.y {
      let type = map[IVec2(x, y)]
      if type != .void {
        entities.append(SimulationEntity(RectCollider(size: DSize2(1, 1)), Tile(type: type), position: DVec2(Double(x), Double(y))))
      }
    }
  }

  return entities
}

let goal = Goal.reachPosition(DVec2(19, 19))

let agent = Agent(goal: goal)
agent.controller = .ai(AI.Model())

let simulation = Simulation(
  map: map,
  entities: [
    SimulationEntity(RectCollider(size: DSize2(1, 1)), Lidar(rayCount: 10), agent, position: DVec2(4, 10), fixed: false)
  ] + mapToEntities(map))

simulation.addSystem(makeCollisionSystem())

simulation.addSystem(LidarSystem())

simulation.addSystem(RewardSystem())

let app = GraphicalControlApp(contentView: Container().withContent {
  MainView().with(styleProperties: { _ in
    (SimpleLinearLayout.ChildKeys.grow, 1.0)
    (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
  })
}.provide(dependencies: simulation))

simulation.system(tick: {
  let keyStates = app.baseApp.system.keyStates
  let agents = $0.query(Agent.self)

  for (entity, agent) in agents {
    switch agent.controller {
    case .player:
      if keyStates[.ArrowUp] {
        agent.queueAction(.moveForward)
      }
      if keyStates[.ArrowDown] {
        agent.queueAction(.moveBackward)
      }
      if keyStates[.ArrowRight] {
        agent.queueAction(.moveRight)
      }
      if keyStates[.ArrowLeft] {
        agent.queueAction(.moveLeft)
      }
    case let .ai(model):
      let lidar = entity.query(Lidar.self)!
      let lidarHitDistances = lidar.hits.map { ($0.position - entity.position).magnitude }
      agent.queueAction(model.getAction(for: AI.InputObservations(lidarHitDistances: lidarHitDistances)))
      print("IMPLEMENT AGENT AI CONTROL")
    default:
      break
    }
  }
})

simulation.system(tick: {
  let agents = $0.query(Agent.self)

  for (entity, agent) in agents {
    let speed = 2.0
    for action in agent.queuedActions {
      switch action {
      case .moveForward:
        entity.position.y += speed * $0.deltaTime
      case .moveBackward:
        entity.position.y -= speed * $0.deltaTime
      case .moveRight:
        entity.position.x += speed * $0.deltaTime
      case .moveLeft:
        entity.position.x -= speed * $0.deltaTime
      }
    }
    agent.queuedActions = []
  }
})

// simulation tick should run after user events have been processed, before new frame is generated
_ = app.onTick {
  simulation.tick(deltaTime: $0.deltaTime)
}

try! app.start()