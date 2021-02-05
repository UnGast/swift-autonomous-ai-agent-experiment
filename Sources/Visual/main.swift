import Simulation
import GfxMath

let map = Map(size: ISize2(20, 20))
map[IVec2(10, 10)] = .solid

let mapEditor = MapEditor(map: map)
mapEditor.fill(IRect(min: IVec2(0, 0), max: IVec2(20, 5)), with: .solid)

let agent = Agent(position: DVec2(2, 2))

let simulation = Simulation(map: map, agents: [agent])

let app = VisualizationApp(simulation: simulation)

do {
  try app.start()
} catch {
  print("Error while running the app", error)
}