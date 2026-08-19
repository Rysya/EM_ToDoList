import SwiftUI

struct TodoRow: View {
    let todo: Todo
    let presenter: TodoListPresenter
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                presenter.toggle(todo)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(todo.isCompleted ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
//            Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
//                .font(.system(size: 28, weight: .thin))
//                .foregroundStyle(todo.isCompleted ? .yellow : .secondary)
            VStack(alignment: .leading, spacing: 5) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                if !todo.description.isEmpty { Text(todo.description).font(.subheadline).foregroundStyle(.secondary) }
                Text(todo.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}
