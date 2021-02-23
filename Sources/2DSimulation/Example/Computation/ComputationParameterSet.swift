@propertyWrapper
public class ComputationParameterSet {
  private var _values: [Double]? = nil
  public var values: [Double] {
    get {
      _getValues()
    }
    set {
      _setValues(newValue)
    }
  }
  private var _getValues: () -> [Double]
  private var _setValues: ([Double]) -> ()

  public var wrappedValue: [Double] {
    get { _getValues() }
    set { _setValues(newValue) }
  }

  public init(getValues: @escaping () -> [Double], setValues: @escaping ([Double]) -> ()) {
    self._getValues = getValues
    self._setValues = setValues
  }

  public init(wrappedValue: [Double]) {
    _values = wrappedValue
    _getValues = { [] }
    _setValues = { _ in }
    _getValues = { [unowned self] in _values! }
    _setValues = { [unowned self] in self._values = $0 }
  }
}