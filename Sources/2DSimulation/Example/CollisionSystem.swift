import GfxMath

fileprivate func getRectRadius(size: DSize2) -> Double {
  size.max() * 1.5
}

public func makeCollisionSystem() -> SimulationSystem {
  SimulationSystem(tick: {
    let colliders = $0.query(RectCollider.self)

    for (primaryEntity, primaryCollider) in colliders {
      if primaryEntity.fixed { continue }

      var primaryBounds = DRect(min: primaryEntity.position, size: primaryCollider.size)
      // TODO: 
      let primaryRadius = getRectRadius(size: primaryCollider.size)

      for (secondaryEntity, secondaryCollider) in colliders {
        if primaryEntity === secondaryEntity { continue }

        let secondaryRadius = getRectRadius(size: secondaryCollider.size)
        let primaryCenter = primaryEntity.position + primaryCollider.size / 2
        let secondaryCenter = secondaryEntity.position + secondaryCollider.size / 2
        let centerDelta = primaryCenter - secondaryCenter
        if centerDelta.magnitude > primaryRadius + secondaryRadius {
          continue
        }

        let secondaryBounds = DRect(min: secondaryEntity.position, size: secondaryCollider.size)

        if let intersection = primaryBounds.intersection(with: secondaryBounds) {
          if abs(centerDelta.x) > abs(centerDelta.y) {
            primaryEntity.position.x += intersection.size.width * (centerDelta.x.sign == .plus ? 1 : -1)
          } else {
            primaryEntity.position.y += intersection.size.height * (centerDelta.y.sign == .plus ? 1 : -1)
          }
          primaryBounds.min = primaryEntity.position
        }
      }
    }
  })
}