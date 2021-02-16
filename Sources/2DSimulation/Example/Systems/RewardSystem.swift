public class RewardSystem: SimulationSystem {
  override public func tick() {
    let agents = simulation.query(Agent.self)
    for agent in agents {
      agent.1.totalReward += agent.1.goal.calculateReward(agent: agent, state: simulation)
    }
  }
}