import SwiftUI

struct SanchoAvatar: View {
    var body: some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(SanchoTheme.primaryColor)
    }
}

#Preview {
    SanchoAvatar()
}
