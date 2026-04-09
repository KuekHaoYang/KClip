import Carbon.HIToolbox
import Foundation

@MainActor
final class HotKeyCenter {
    fileprivate static var handlers: [UInt32: () -> Void] = [:]
    fileprivate static var eventHandler: EventHandlerRef?
    private var hotKeyReferences: [EventHotKeyRef] = []

    init(store: KClipStore, coordinator: WindowCoordinator) {
        Self.installHandlerIfNeeded()

        register(identifier: 1, keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey)) {
            coordinator.toggleOverlay()
        }

        register(identifier: 2, keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey | shiftKey)) {
            store.toggleStackCollection()
        }

        register(identifier: 3, keyCode: UInt32(kVK_ANSI_T), modifiers: UInt32(cmdKey)) {
            store.togglePause()
        }
    }

    private func register(identifier: UInt32, keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        var hotKeyReference: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: FourCharCode("KCLP"), id: identifier)

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyReference)

        if let hotKeyReference {
            hotKeyReferences.append(hotKeyReference)
        }

        Self.handlers[identifier] = action
    }

    private static func installHandlerIfNeeded() {
        guard eventHandler == nil else {
            return
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,
            1,
            &eventType,
            nil,
            &eventHandler
        )
    }
}

private let hotKeyEventHandler: EventHandlerUPP = { _, event, _ in
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    guard status == noErr else {
        return OSStatus(status)
    }

    Task { @MainActor in
        HotKeyCenter.handlers[hotKeyID.id]?()
    }
    return noErr
}

private extension FourCharCode {
    init(_ string: StaticString) {
        self = string.withUTF8Buffer { buffer in
            buffer.reduce(0) { partialResult, byte in
                (partialResult << 8) | FourCharCode(byte)
            }
        }
    }
}
