import SwiftUI

struct TrayFilterBarView: View {
  let tags: [ClipTag]
  @ObservedObject var interaction: TrayInteractionModel
  let resultLabel: String

  var body: some View {
    HStack(spacing: 12) {
      TrayTagStripView(tags: tags, interaction: interaction)
        .frame(width: interaction.isSearchPresented ? 0 : nil, alignment: .leading)
        .opacity(interaction.isSearchPresented ? 0 : 1)
        .offset(x: interaction.isSearchPresented ? -18 : 0)
        .clipped()
        .allowsHitTesting(interaction.isSearchPresented == false)
      Spacer(minLength: 0)
      TraySearchBarView(searchText: searchTextBinding, isPresented: searchPresentationBinding, resultLabel: resultLabel)
    }
    .animation(.spring(response: 0.30, dampingFraction: 0.84), value: interaction.isSearchPresented)
  }

  private var searchTextBinding: Binding<String> {
    Binding(get: { interaction.searchText }, set: { interaction.searchText = $0 })
  }

  private var searchPresentationBinding: Binding<Bool> {
    Binding(get: { interaction.isSearchPresented }, set: { interaction.setSearchPresented($0) })
  }
}
