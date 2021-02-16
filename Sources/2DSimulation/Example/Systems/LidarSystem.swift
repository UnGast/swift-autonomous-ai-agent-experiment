import GfxMath

public class LidarSystem: SimulationSystem {
  typealias ColliderEntity = (SimulationEntity, RectCollider)

  var colliders = [ColliderEntity]()
  fileprivate var lineSegments = [LineSegment]()

  override public func tick() {
    let lidars = simulation.query(Lidar.self)
    if lidars.count == 0 {
      return
    }

    colliders = simulation.query(RectCollider.self)

    for (entity, lidar) in lidars {
      lineSegments = colliders.flatMap { $0.0 === entity ? [] : getLineSegments(colliderEntity: $0) }
      lidar.hits = castRays(origin: entity.position, count: lidar.rayCount)
    }
  }

  fileprivate func castRays(origin: DVec2, count: Int) -> [Lidar.Hit] {
    var hits = [Lidar.Hit]()

    for i in 0..<count {
      let angle = Double.pi * 2 * (Double(i) / Double(count))
      let x = cos(angle)
      let y = sin(angle)
      let direction = DVec2(x, y).normalized()
      hits.append(contentsOf: castRay(origin: origin, direction: direction))
    }

    return hits
  }

  fileprivate func castRay(origin: DVec2, direction: DVec2, onlyFirst: Bool = true) -> [Lidar.Hit] {
    var hits = [Lidar.Hit]()
    var shortestDistance = Double.infinity
    let rayLine = Line(origin: origin, direction: direction)

    for segment in lineSegments {
      if let intersection = rayLine.intersection(segment.line),
        !(intersection.x < min(segment.point1.x, segment.point2.x) ||
        intersection.x > max(segment.point1.x, segment.point2.x) ||
        intersection.y < min(segment.point1.y, segment.point2.y) ||
        intersection.y > max(segment.point1.y, segment.point2.y)) {

          if onlyFirst {
            let distance = (origin - intersection).magnitude
            if distance < shortestDistance {
              let hit = Lidar.Hit(position: intersection)
              if hits.count == 0 { hits.append(hit) }
              else { hits[0] = hit }
              shortestDistance = distance
            }
          } else {
            hits.append(Lidar.Hit(position: intersection))
          }
      }
    }

    return hits
  }

  fileprivate func getLineSegments(colliderEntity: ColliderEntity) -> [LineSegment] {
    let (entity, collider) = colliderEntity

    return [
      LineSegment(entity.position, entity.position + DVec2(collider.size.width, 0)),
      LineSegment(entity.position + DVec2(collider.size.width, 0), entity.position + DVec2(collider.size.width, collider.size.height)),
      LineSegment(entity.position, entity.position + DVec2(0, collider.size.height)),
      LineSegment(entity.position + DVec2(0, collider.size.height), entity.position + DVec2(collider.size.width, collider.size.height))
    ]
  }
}

public struct Line {
  // ax + by = c
  public let a: Double
  public let b: Double
  public let c: Double

  public init(point1: DVec2, point2: DVec2) {
    a = point2.y - point1.y
    b = point1.x - point2.x
    c = a * point1.x + b * point1.y
  }

  public init(origin: DVec2, direction: DVec2) {
    self.init(point1: origin, point2: origin + direction)
  }

  public func intersection(_ other: Line) -> DVec2? {
    let det = a * other.b - b * other.a
    if det == 0 {
      return nil
    }
    let x = (other.b * c - b * other.c) / det
    let y = (a * other.c - other.a * c) / det
    return DVec2(x, y)
  }
}

fileprivate struct LineSegment {
  public let point1: DVec2
  public let point2: DVec2
  public let line: Line

  public init(_ point1: DVec2, _ point2: DVec2) {
    self.point1 = point1
    self.point2 = point2
    self.line = Line(point1: point1, point2: point2)
  }
}