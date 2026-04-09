import Foundation

extension Date {
    func kclipRelativeString(reference: Date = .now) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: reference)
    }
}
