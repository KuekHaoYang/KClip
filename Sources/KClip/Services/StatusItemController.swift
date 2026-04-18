import AppKit

@MainActor
final class StatusItemController: NSObject {
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  private var toggleAction: () -> Void
  private var quitAction: () -> Void
  private lazy var statusMenu = makeMenu()

  init(toggleAction: @escaping () -> Void = {}, quitAction: @escaping () -> Void = {}) {
    self.toggleAction = toggleAction
    self.quitAction = quitAction
    super.init()
    configureButton()
  }

  func setToggleAction(_ toggleAction: @escaping () -> Void) {
    self.toggleAction = toggleAction
  }

  func setQuitAction(_ quitAction: @escaping () -> Void) {
    self.quitAction = quitAction
  }

  private func configureButton() {
    guard let button = statusItem.button else { return }
    button.image = NSImage(
      systemSymbolName: "paperclip.circle.fill",
      accessibilityDescription: "KClip"
    )
    button.target = self
    button.action = #selector(handleStatusItemClick)
    button.sendAction(on: [.leftMouseDown, .rightMouseDown])
  }

  @objc private func handleStatusItemClick() {
    guard NSApp.currentEvent?.type == .rightMouseDown else {
      toggleAction()
      return
    }
    statusItem.menu = statusMenu
    statusItem.button?.performClick(nil)
    statusItem.menu = nil
  }

  @objc private func quitApp() {
    quitAction()
  }

  private func makeMenu() -> NSMenu {
    let menu = NSMenu()
    let item = NSMenuItem(title: "Quit KClip", action: #selector(quitApp), keyEquivalent: "q")
    item.target = self
    menu.addItem(item)
    return menu
  }
}
