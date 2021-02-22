import GfxMath

public class SimulationEntity {
  public var position: DVec2
  public var fixed: Bool
  internal var components: [SimulationComponent]

  public init(_ components: SimulationComponent..., position: DVec2 = .zero, fixed: Bool = true) {
    self.components = components
    self.position = position
    self.fixed = fixed
  }

  public func query<C: SimulationComponent>(_ componentType: C.Type) -> C? {
    for component in components {
      if let component = component as? C {
        return component
      }
    }
    return nil
  }
}