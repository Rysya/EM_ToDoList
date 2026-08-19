import SwiftUI

struct TodoFooter: View {
    let count: Int
    let onAdd: () -> Void
    var body: some View {
        ZStack {
            Text("\(count) Задач")
                .font(.system(size: 12))
                .foregroundStyle(.white)
            HStack {
                Spacer()
                Button {
                    onAdd()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 26, weight: .thin))
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 49)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.14, green: 0.14, blue: 0.15))
    }
}
