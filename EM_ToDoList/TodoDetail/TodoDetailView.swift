import SwiftUI

struct TodoDetailView: View {
    @StateObject private var presenter: TodoDetailPresenter
    @FocusState private var focused: Field?

    enum Field { case title, description }

    init(presenter: TodoDetailPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        Form {
            Section("Задача") {
                TextField("Название", text: $presenter.title)
                    .focused($focused, equals: .title)
                ZStack(alignment: .topLeading) {
                    if presenter.description.isEmpty {
                        Text("Описание")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $presenter.description)
                        .frame(minHeight: 140)
                        .focused($focused, equals: .description)
                }
            }

            if let todo = presenter.todo {
                Section("Информация") {
                    LabeledContent("Создана", value: todo.createdAt.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Статус", value: todo.isCompleted ? "Выполнена" : "Не выполнена")
                }
            }

            Section {
                Button("Сохранить") { presenter.save() }
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(presenter.todo == nil ? "Новая задача" : "Редактирование")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Ошибка", isPresented: Binding(get: { presenter.errorMessage != nil }, set: { if !$0 { presenter.errorMessage = nil } })) {
            Button("OK") { presenter.errorMessage = nil }
        } message: {
            Text(presenter.errorMessage ?? "")
        }
    }
}
