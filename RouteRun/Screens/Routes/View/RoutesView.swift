import SwiftUI
import MapKit

struct RoutesView: View {
    @StateObject private var viewModel = RoutesViewModel()
    @State private var searchText = ""
    @State private var selected: Route?
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Маршруты")
                .searchable(text: $searchText, prompt: "Поиск")
                .onChange(of: searchText) { newValue in
                    Task { await viewModel.searchRoutes(query: newValue) }
                }
                .task { await viewModel.loadAll() }
                .sheet(item: $selected) { RouteDetailView(routeId: $0.id, viewModel: viewModel) }
                .alert("Ошибка", isPresented: .constant(viewModel.error != nil)) {
                    Button("OK") { viewModel.error = nil }
                } message: {
                    Text(viewModel.error?.localizedDescription ?? "")
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.recommendedRoutes.isEmpty {
            ProgressView()
        } else {
            RouteList()
        }
    }
    
    private func RouteList() -> some View {
        List {
            if !searchText.isEmpty {
                SearchSection()
            } else {
                RecommendedSection()
                AllRoutesSection()
            }
        }
        .listStyle(.plain)
    }
    
    private func SearchSection() -> some View {
        Section("Результаты поиска") {
            ForEach(viewModel.searchResults) { route in
                RouteCardView(route: route, viewModel: viewModel)
                    .onTapGesture { selected = route }
            }
        }
    }
    
    private func RecommendedSection() -> some View {
        Section("Рекомендуем") {
            ForEach(viewModel.recommendedRoutes) { route in
                RouteCardView(route: route, viewModel: viewModel)
                    .onTapGesture { selected = route }
            }
        }
    }
    
    private func AllRoutesSection() -> some View {
        Section("Все маршруты") {
            ForEach(viewModel.routes) { route in
                RouteCardView(route: route, viewModel: viewModel)
                    .onTapGesture { selected = route }
            }
        }
    }
}
