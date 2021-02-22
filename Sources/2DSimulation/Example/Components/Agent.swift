import GfxMath

public class Agent: SimulationComponent {
    public struct Data {
        public var queuedActions: Set<Action> = []
    }

    var data: Data
    public var queuedActions: Set<Action> {
        get { data.queuedActions }
        set { data.queuedActions = newValue }
    }
    var goal: Goal
    var totalReward = 0.0
    var controller: Controller?

    public init(goal: Goal) {
        self.data = Data(queuedActions: [])
        self.goal = goal
    }

    public func queueAction(_ action: Action) {
        data.queuedActions.insert(action)
    }
}

extension Agent {
    public enum Action: Int {
        case moveLeft, moveForward, moveRight, moveBackward
    }

    public enum Controller {
        case player, ai(AI.Model)
    }
}