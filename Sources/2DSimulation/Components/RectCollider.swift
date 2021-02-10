import GfxMath

public class RectCollider: SimulationComponent {
  public struct Data {
    var size: DSize2 
  }

  var data: Data
  public var size: DSize2 {
    get { data.size }
    set { data.size = newValue }
  }

  public init(size: DSize2) {
    data = Data(size: size)
  }
}