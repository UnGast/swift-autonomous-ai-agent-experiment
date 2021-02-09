import GfxMath

public class Agent {
    public var position: DVec2
    public var queuedActions: Set<Action> = []

    public init(position: DVec2) {
        self.position = position
    }

    public func queueAction(_ action: Action) {
        queuedActions.insert(action)
    }
}

extension Agent {
    public enum Action: Int {
        case moveLeft, moveForward, moveRight, moveBackward
    }
}