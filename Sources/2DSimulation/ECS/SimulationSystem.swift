open class SimulationSystem {
  var tick: ((Simulation) -> ())?

  public init(tick: ((Simulation) -> ())? = nil) {
    self.tick = tick
  }
}