open class SimulationSystem {
  internal var _simulation: Simulation?
  public var simulation: Simulation {
    _simulation!
  }

  private var _tick: ((Simulation) -> ())?

  public init(tick: ((Simulation) -> ())? = nil) {
    self._tick = tick
  }

  open func tick() {
    _tick!(simulation)
  }
}