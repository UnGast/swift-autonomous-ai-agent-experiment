@propertyWrapper
public class Editable<T>: AnyEditable {
  public var value: T

  public var anyValue: Any {
    get {
      value
    }
    set {
      value = newValue as! T
    }
  }

  public var wrappedValue: T {
    get {
      value
    }
    set {
      value = newValue
    }
  }

  public init(wrappedValue: T) {
    self.value = wrappedValue
  }
}

public protocol AnyEditable: class {
  var anyValue: Any { get set }
}