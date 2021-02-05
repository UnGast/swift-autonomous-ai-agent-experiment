import SwiftGUI
import Simulation

public class VisualizationApp: WidgetsApp {
  public let simulation: Simulation
  private var controlledAgent: Agent {
    simulation.agents[0]
  }

  public init(simulation: Simulation) {
    self.simulation = simulation
    super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
  }

  override open func setup() {
    let guiRoot = WidgetGUI.Root(rootWidget: DependencyProvider(provide: [Dependency(simulation)]) {
      MainView()
    })
    guiRoot.renderObjectSystemEnabled = false

    let window = createWindow(guiRoot: guiRoot, options: Window.Options(background: Color(20, 36, 50, 255)), immediate: true)

    // TODO: expose a function on app or a flag to assume control over the simulation speed and the agents actions
    _ = baseApp.system.onTick { [unowned self] in
      if baseApp.system.keyStates[.ArrowUp] {
        controlledAgent.queueAction(.moveForward)
      }
      if baseApp.system.keyStates[.ArrowDown] {
        controlledAgent.queueAction(.moveBackward)
      }
      if baseApp.system.keyStates[.ArrowRight] {
        controlledAgent.queueAction(.moveRight)
      }
      if baseApp.system.keyStates[.ArrowLeft] {
        controlledAgent.queueAction(.moveLeft)
      }
      simulation.tick(deltaTime: $0.deltaTime)
    }
  }
}