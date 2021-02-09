public class Simulation {
    public var map: Map
    public var agents: [Agent]

    public init(map: Map, agents: [Agent]) {
        self.map = map
        self.agents = agents
    }

    public func tick(deltaTime: Double) {
        for agent in agents {
            let speed = 2.0
            for action in agent.queuedActions {
                switch action {
                case .moveForward:
                    agent.position.y += speed * deltaTime
                case .moveBackward:
                    agent.position.y -= speed * deltaTime
                case .moveRight:
                    agent.position.x += speed * deltaTime
                case .moveLeft:
                    agent.position.x -= speed * deltaTime
                default:
                    break
                }
            }
            agent.queuedActions = []
        }
    }
}