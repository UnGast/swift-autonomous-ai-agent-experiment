import SwiftGUI
import ExperimentalReactiveProperties

public class ObjectEditor<T: Equatable>: Experimental.ComposedWidget {
  @ExperimentalReactiveProperties.MutableProperty
  var object: T

  typealias Property = (String, AnyEditable)
  var objectProperties: [Property] = []

  public init(mutableObject: ExperimentalReactiveProperties.MutableProperty<T>) {
    super.init()

    self.$object.bindBidirectional(mutableObject)
    if $object.hasValue {
      setupObjectProperties()
    } else {
      _ = self.$object.onHasValueChanged { [unowned self] in
        setupObjectProperties()
      }
    }
  }

  func setupObjectProperties() {
    let mirror = Mirror(reflecting: object)
    for child in mirror.children {
      if let editable = child.value as? AnyEditable {
        objectProperties.append((child.label ?? "", editable))
      }
    }
  }

  override public func performBuild() {
    rootChild = Experimental.Container(styleProperties: { _ in
      //($0.background, Color.white)
    }) { [unowned self] in

      Experimental.SimpleColumn {

        objectProperties.map {
          buildProperty($0)
        }
      }
    }
  }

  func buildProperty(_ property: Property) -> Widget {
    Experimental.SimpleRow { [unowned self] in
      Experimental.Text(styleProperties: {
        ($0.textColor, Color.white)
      }, "\(property.0)")

      switch ObjectIdentifier(type(of: property.1.anyValue)) {
      case ObjectIdentifier(String.self):
        Experimental.Text("STRING PROPERTY")
      case ObjectIdentifier(Int.self):
        buildIntProperty(property)
      default:
        Space(.zero)
      }
    }
  }

  func buildIntProperty(_ property: Property) -> Widget {
    let reactive = ExperimentalReactiveProperties.MutableComputedProperty(compute: {
      String(describing: property.1.anyValue)
    }, apply: {
      property.1.anyValue = Int($0)
    }, dependencies: [])

    return Experimental.TextInput(mutableText: reactive)
  }
}