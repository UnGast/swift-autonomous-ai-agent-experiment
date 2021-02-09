import SwiftGUI
import ExperimentalReactiveProperties
import GraphicalControlApp

class EvolutionPolicyEditor: Experimental.ComposedWidget {
  @Inject(key: "evolution")
  var evolution: EvolutionProtocol

  @ExperimentalReactiveProperties.MutableProperty
  var evolutionPolicy: EvolutionPolicy

  override public init() {
    super.init()
    _ = onDependenciesInjected(setup)
  }

  func setup() {
    evolutionPolicy = evolution.policy
  }

  override public func performBuild() {
    rootChild = Experimental.Container { [unowned self] in
      ObjectEditor(mutableObject: $evolutionPolicy)
    }
  }
}