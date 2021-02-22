import SwiftGUI

public class ObjectEditor<T: Equatable>: ComposedWidget {
  @MutableProperty
  var object: T

  typealias Property = (String, AnyEditable)
  var objectProperties: [Property] = []

  public init(mutableObject: MutableProperty<T>) {
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
    rootChild = Container().with(styleProperties: { _ in
      //($0.background, Color.white)
    }).withContent { [unowned self] in

      Container().withContent {

        Space(.zero)

        /*objectProperties.map {
          buildProperty($0)
        }*/
      }
    }
  }

  func buildProperty(_ property: Property) -> Widget {
    Container().withContent { [unowned self] in
      Text(styleProperties: {
        ($0.foreground, Color.white)
      }, "\(property.0)")

      switch ObjectIdentifier(type(of: property.1.anyValue)) {
      case ObjectIdentifier(String.self):
        Text("STRING PROPERTY")
      case ObjectIdentifier(Int.self):
        buildIntProperty(property)
      default:
        Space(.zero)
      }
    }
  }

  func buildIntProperty(_ property: Property) -> Widget {
    let reactive = MutableComputedProperty(compute: {
      String(describing: property.1.anyValue)
    }, apply: {
      property.1.anyValue = Int($0)
    }, dependencies: [])

    return TextInput(mutableText: reactive)
  }
}