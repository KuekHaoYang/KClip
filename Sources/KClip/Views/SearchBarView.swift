import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var activeKindFilter: ClipboardKind?
    @Binding var activeSourceFilter: String?
    var searchFocused: FocusState<Bool>.Binding

    let availableSources: [String]

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.7))

            if let activeKindFilter {
                filterToken(text: activeKindFilter.label) {
                    self.activeKindFilter = nil
                }
            }

            if let activeSourceFilter {
                filterToken(text: activeSourceFilter) {
                    self.activeSourceFilter = nil
                }
            }

            TextField("Search clipboard history", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .focused(searchFocused)

            Spacer(minLength: 12)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.white.opacity(0.72))
                }
                .buttonStyle(.plain)
            }

            Menu {
                Menu("Type") {
                    Button("All Types") {
                        activeKindFilter = nil
                    }

                    ForEach(ClipboardKind.allCases) { kind in
                        Button(kind.label) {
                            activeKindFilter = kind
                        }
                    }
                }

                Menu("Source App") {
                    Button("All Apps") {
                        activeSourceFilter = nil
                    }

                    ForEach(availableSources, id: \.self) { source in
                        Button(source) {
                            activeSourceFilter = source
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func filterToken(text: String, remove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .lineLimit(1)
            Button(action: remove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.16))
        )
    }
}
