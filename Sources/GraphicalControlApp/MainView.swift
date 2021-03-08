import SwiftGUI 

public class MainView: ContentfulWidget {

  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
    super.init()
  }

  @DirectContentBuilder override public var content: DirectContent {
    Container().with(styleProperties: {
      (\.$alignContent, .stretch)
    }).withContent { [unowned self] in 
      contentView.with(styleProperties: {
        (\.$grow, 1)
      })
    }
  }

  override public var style: Style? {
    Style("&") {} nested: {
      FlatTheme(primaryColor: .red, secondaryColor: .green, backgroundColor: Color(10, 20, 40, 255)).styles
    }
  }
}