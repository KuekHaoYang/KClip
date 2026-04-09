import AppKit

final class LocalEventMonitor {
    private var monitor: Any?

    func start(handler: @escaping (NSEvent) -> Bool) {
        stop()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            handler(event) ? nil : event
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    deinit {
        stop()
    }
}
