import GfxMath
import GraphicalControlApp
import SwiftGUI

let map = Map(size: ISize2(20, 20))
map[IVec2(10, 10)] = .solid

let mapEditor = MapEditor(map: map)
mapEditor.fill(IRect(min: IVec2(0, 0), max: IVec2(20, 5)), with: .solid)

let simulation = Simulation(
  map: map,
  entities: [
    SimulationEntity(RectCollider(size: DSize2(1, 1)), Agent())
  ])

simulation.addSystem(
  SimulationSystem(tick: {
    let colliders = $0.query(RectCollider.self)
  }))

simulation.addSystem(
  SimulationSystem(tick: {
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
        default:
          break
        }
      }
      agent.queuedActions = []
    }
  }))

let app = GraphicalControlApp(contentView: DependencyProvider(provide: [Dependency(simulation)]) {
  MainView()
})

_ = app.onTick {
  simulation.tick(deltaTime: $0.deltaTime)
}

simulation.system(tick: {
  let keyStates = app.baseApp.system.keyStates
  let (_, agent) = $0.query(Agent.self)[0]

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
})

try! app.start()