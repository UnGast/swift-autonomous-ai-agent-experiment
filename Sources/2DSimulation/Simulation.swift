import Foundation

public class Simulation {
    public var entities: [SimulationEntity]
    var systems: [SimulationSystem] = []
    var map: Map
    var deltaTime = 0.0

    public init(map: Map, entities: [SimulationEntity]) {
        self.map = map
        self.entities = entities
    }

    public func addSystem(_ system: SimulationSystem) {
        systems.append(system)
        system._simulation = self
    }

    public func system(tick: ((Simulation) -> ())? = nil) {
        addSystem(SimulationSystem(tick: tick))
    }

    public func query<C1: SimulationComponent>(_ queryComponent: C1.Type) -> [(SimulationEntity, C1)] {
        var result = [(SimulationEntity, C1)]()

        for entity in entities {
            for component in entity.components {
                if let component = component as? C1 {
                    result.append((entity, component))
                }
            }
        }

        return result
    }

    public func tick(deltaTime: Double) {
        self.deltaTime = deltaTime
        for system in systems {
            let startTime = Date.timeIntervalSinceReferenceDate
            system.tick()
            print("system took", Date.timeIntervalSinceReferenceDate - startTime)
        }
    }
}