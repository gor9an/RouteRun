import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State var showAlert = false
    var routesViewModel = RoutesViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Header
                Divider().padding(.horizontal)
                
                WeightChanger()
                
                Divider().padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView().padding()
                } else if !viewModel.likedRoutes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Понравившиеся маршруты")
                            .font(.title3)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.likedRoutes) { route in
                                NavigationLink(destination: RouteDetailView(routeId: route.id, viewModel: routesViewModel)) {
                                    RouteCard(route: route)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("У вас пока нет понравившихся маршрутов")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .onAppear {
                Task { await viewModel.loadUserAndRoutes() }
                routesViewModel.routes = viewModel.likedRoutes
            }
        }
    }
    
    private var Header: some View {
        VStack {
            HStack(spacing: 16) {
                if let imageURL = viewModel.user?.photoURL {
                    AsyncImage(url: imageURL){ image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    PlaceholderImage()
                }
                
                DisplayName()
                
                Spacer()
                
                ExitButton()
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func WeightChanger() -> some View {
        HStack {
            Text("Вес, кг:")
            Spacer()
            Stepper(
                value: Binding(
                    get: { viewModel.newWeight ?? viewModel.user?.weight ?? 70 },
                    set: { new in
                        Task { viewModel.newWeight = new }
                    }
                ),
                in: 30...200,
                step: 1
            ) {
                Text("\(Int(viewModel.newWeight ?? viewModel.user?.weight ?? 70))")
            }
            .frame(width: 150)
            
            Button(
                action: {
                    viewModel.updateWeight()
                }) {
                    Text("Сохранить")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.newWeight == nil || viewModel.newWeight == viewModel.user?.weight)
        }
        .padding(.horizontal)
    }
    
    private func PlaceholderImage() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
    }
    
    private func DisplayName() -> some View {
        Text(viewModel.getDisplayName())
            .lineLimit(1)
            .font(.headline)
            .bold()
    }
    
    private func ExitButton() -> some View {
        Button(
            action: {
                showAlert = true
            },
            label: {
                Image(systemName: "door.right.hand.open")
                    .resizable()
                    .frame(width: 35, height: 50)
                    .padding()
                    .tint(.red)
                
            }
        )
        .alert(
            isPresented: $showAlert
        ) {
            ExitAlert()
        }
    }
    
    private func ExitAlert() -> Alert {
        Alert(
            title: Text(
                "Выход"
            ),
            message: Text(
                "Вы точно хотите выйти?"
            ),
            primaryButton: .default(
                Text(
                    "Выйти"
                ),
                action: {
                    do {
                        try viewModel.logout()
                        showSignInView = true
                    } catch {}
                    showAlert = false
                }
            ),
            secondaryButton: .cancel(
                Text(
                    "Нет"
                ),
                action: {
                    showAlert = false
                }
            )
        )
    }
    
    private func RouteCard(route: Route) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RouteMapView(coordinates: route.coordinates)
                .frame(height: 120)
                .cornerRadius(8)
                .allowsHitTesting(false)
            
            Text(route.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(route.city)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
