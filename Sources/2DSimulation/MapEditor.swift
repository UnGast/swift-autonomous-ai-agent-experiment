import GfxMath

public class MapEditor {
  public var map: Map

  public init(map: Map) {
    self.map = map
  }

  public func fill(_ bounds: IRect, with tileType: TileType) {
    for x in max(0, bounds.min.x)..<min(map.size.x, bounds.max.x) {
      for y in max(0, bounds.min.y)..<min(map.size.y, bounds.max.y) {
        map[IVec2(x, y)] = tileType
      }
    }
  }
}