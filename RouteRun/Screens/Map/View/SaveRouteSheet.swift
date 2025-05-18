import SwiftUI


struct SaveRouteSheet: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var description: String

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название", text: $name)
                    TextField("Описание", text: $description)
                }
                Section {
                    Picker("Рельеф", selection: $viewModel.selectedTerrain) {
                        ForEach(Terrain.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Покрытие", selection: $viewModel.selectedSurface) {
                        ForEach(Surface.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Активность", selection: $viewModel.selectedActivity) {
                        ForEach(ActivityType.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section {
                    Button("Сохранить") {
                        viewModel.saveRoute(name: name, description: description)
                        isPresented = false
                    }.disabled(
                        name.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty || description.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty
                    )
                    Button("Отмена", role: .cancel) { isPresented = false }
                }
            }
            .navigationTitle("Сохранить маршрут")
        }
    }
}
