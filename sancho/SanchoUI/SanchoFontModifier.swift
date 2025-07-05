import SwiftUICore

struct SanchoFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.custom("Inter-Medium", size: 16))
    }
}
