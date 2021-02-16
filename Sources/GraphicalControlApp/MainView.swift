import SwiftGUI 

public class MainView: SingleChildWidget {
  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
  }

  override public func buildChild() -> Widget {
    Experimental.Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
    }) { [unowned self] in 
      contentView.with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
      })

      Experimental.DefaultTheme()
    }
  }
}