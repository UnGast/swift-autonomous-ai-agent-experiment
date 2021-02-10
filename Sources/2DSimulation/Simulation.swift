import Foundation

public class Simulation {
    public var map: Map
    public var entities: [SimulationEntity]
    var systems: [SimulationSystem] = []
    var deltaTime = 0.0

    public init(map: Map, entities: [SimulationEntity]) {
        self.map = map
        self.entities = entities
    }

    public func addSystem(_ system: SimulationSystem) {
        systems.append(system)
    }

    public func system(tick: ((Simulation) -> ())? = nil) {
        addSystem(SimulationSystem(tick: tick))
    }

    public func query<C1: SimulationComponent>(_ queryComponent: C1.Type) -> [(SimulationEntity, C1)] {
        var result = [(SimulationEntity, C1)]()

        for entity in entities {
            for component in entity.components {
                if ObjectIdentifier(type(of: component)) == ObjectIdentifier(queryComponent) {
                result.append((entity, component as! C1))
                }
            }
        }

        return result
    }

    public func tick(deltaTime: Double) {
        self.deltaTime = deltaTime
        for system in systems {
            if let tick = system.tick {
                var startTime = Date.timeIntervalSinceReferenceDate
                tick(self)
                print("system took", Date.timeIntervalSinceReferenceDate - startTime)
            }
        }
    }
}