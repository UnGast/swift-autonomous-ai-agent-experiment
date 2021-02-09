import SwiftGUI
import ExperimentalReactiveProperties

public class ObjectEditor<T: Equatable>: Experimental.ComposedWidget {
  @ExperimentalReactiveProperties.MutableProperty
  private var object: T

  public init(mutableObject: ExperimentalReactiveProperties.MutableProperty<T>) {
    super.init()
    self.$object.bindBidirectional(mutableObject)
  }

  override public func performBuild() {
    rootChild = Experimental.SimpleColumn {
      Experimental.Text("OBJECT EDITOR")
    }
  }
}