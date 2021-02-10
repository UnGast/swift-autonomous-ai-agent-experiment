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

    public init() {
        self.data = Data(queuedActions: [])
    }

    public func queueAction(_ action: Action) {
        data.queuedActions.insert(action)
    }
}

extension Agent {
    public enum Action: Int {
        case moveLeft, moveForward, moveRight, moveBackward
    }
}