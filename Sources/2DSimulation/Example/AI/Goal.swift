import GfxMath

public enum Goal {
  case reachPosition(DVec2)
}

extension Goal {
  public func calculateReward(agent: (SimulationEntity, Agent), state: Simulation) -> Double {
    switch self {
    case let .reachPosition(position):
      return 1 / (agent.0.position - position).magnitude
    }
  }
}