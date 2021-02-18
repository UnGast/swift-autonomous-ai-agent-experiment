import SwiftGUI 

public class MainView: ComposedWidget {

  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
    super.init()
  }

  override public func performBuild() {
    rootChild = Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
    }) { [unowned self] in 
      contentView.with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
      })

      DefaultTheme()
    }
  }
}