import GfxMath

fileprivate func getRectRadius(size: DSize2) -> Double {
  size.max() * 1.5
}

public func makeCollisionSystem() -> SimulationSystem {
  SimulationSystem(tick: {
    let colliders = $0.query(RectCollider.self)

    for (primaryEntity, primaryCollider) in colliders {
      var primaryBounds = DRect(min: primaryEntity.position, size: primaryCollider.size)
      // TODO: 
      let primaryRadius = getRectRadius(size: primaryCollider.size)

      for (secondaryEntity, secondaryCollider) in colliders {
        if primaryEntity === secondaryEntity { continue }

        let secondaryRadius = getRectRadius(size: secondaryCollider.size)
        let primaryCenter = primaryEntity.position + DVec2(primaryCollider.size) / 2
        let secondaryCenter = secondaryEntity.position + DVec2(secondaryCollider.size) / 2
        let centerDelta = secondaryCenter - primaryCenter
        if centerDelta.magnitude > primaryRadius + secondaryRadius {
          continue
        }

        let secondaryBounds = DRect(min: secondaryEntity.position, size: secondaryCollider.size)

        if primaryBounds.intersects(secondaryBounds, includeSharedEdge: false) {
          let reverseTranslation = -centerDelta / 3
          primaryEntity.position += reverseTranslation
          primaryBounds.min = primaryEntity.position
        }
      }
    }
  })
}