import GfxMath

public class Map {
    public var size: ISize2
    public var tiles: [Int: TileType] = [:]

    public init(size: ISize2) {
        self.size = size
    }

    public subscript(_ position: IVec2) -> TileType {
        get {
            tiles[position.y * size.width + position.x] ?? .void
        }

        set {
            tiles[position.y * size.width + position.x] = newValue
        }
    }
}