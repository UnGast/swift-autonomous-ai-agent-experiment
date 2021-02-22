import SwiftGUI 

public class MainView: ContentfulWidget {

  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
    super.init()
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
    }).withContent { [unowned self] in 
      contentView.with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
      })
    }
  }

  override public var style: Style? {
    Style("&") {
      FlatTheme(primaryColor: .red, secondaryColor: .green, backgroundColor: Color(10, 20, 40, 255)).styles
    }
  }
}