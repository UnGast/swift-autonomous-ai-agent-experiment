import GfxMath

public class Lidar: SimulationComponent {
  public let rayCount: Int
  public var hits: [Hit] = []

  public init(rayCount: Int) {
    self.rayCount = rayCount
  }
}

extension Lidar {
  public struct Hit {
    public var position: DVec2
  }
}
