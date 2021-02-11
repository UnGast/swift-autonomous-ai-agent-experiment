import SwiftGUI

public class GraphicalControlApp: WidgetsApp {
  private let contentView: Widget

  public init(contentView: Widget) {
    self.contentView = contentView
    super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
  }

  override open func setup() {
    let guiRoot = WidgetGUI.Root(rootWidget: MainView(contentView: contentView))
    guiRoot.renderObjectSystemEnabled = false

    let window = createWindow(guiRoot: guiRoot, options: Window.Options(background: Color(20, 36, 50, 255)), immediate: true)
  }
}