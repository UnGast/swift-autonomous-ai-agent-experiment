import SwiftGUI
import GraphicalControlApp

class EvolutionPolicyEditor: ComposedWidget {
  @Inject(key: "evolution")
  var evolution: EvolutionProtocol

  @MutableProperty
  var evolutionPolicy: EvolutionPolicy

  override public init() {
    super.init()
    _ = onDependenciesInjected(setup)
  }

  func setup() {
    evolutionPolicy = evolution.policy
  }

  override public func performBuild() {
    rootChild = Container { [unowned self] in
      ObjectEditor(mutableObject: $evolutionPolicy)
    }
  }
}