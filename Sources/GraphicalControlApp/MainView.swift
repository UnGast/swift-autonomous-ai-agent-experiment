import SwiftGUI 

public class MainView: SingleChildWidget {
  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
  }

  override public func buildChild() -> Widget {
    Experimental.Container { [unowned self] in
      Experimental.DefaultTheme()

      contentView
    }
  }
}