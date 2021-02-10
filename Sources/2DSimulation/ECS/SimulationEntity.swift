import GfxMath

public class SimulationEntity {
  public var position: DVec2
  internal var components: [SimulationComponent]

  public init(_ components: SimulationComponent..., position: DVec2 = .zero) {
    self.components = components
    self.position = position
  }
}