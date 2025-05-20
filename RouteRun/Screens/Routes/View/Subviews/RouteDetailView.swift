import SwiftUI
import MapKit

struct RouteDetailView: View {
    let routeId: String
    @ObservedObject var viewModel: RoutesViewModel
    @State var showAlert: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var route: Route? {
        (viewModel.recommendedRoutes + viewModel.routes + viewModel.searchResults)
            .first { $0.id == routeId }
    }
    
    var body: some View {
        if let route {
            ScrollView {
                VStack(spacing: 16) {
                    RouteMapView(coordinates: route.coordinates)
                        .frame(height: 250)
                        .cornerRadius(12)
                        .allowsHitTesting(false)

                    VStack(spacing: 8) {
                        OpenInMapsButton()
                        if let user = viewModel.currentUser, user.id == route.userId {
                            DeleteRouteButton()
                        }
                    }

                    RouteInfo(route: route)
                }
                .padding()
            }
            .navigationTitle(route.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ProgressView()
        }
    }
    
    private func OpenInMapsButton() -> some View {
        Button {
            guard let start = route?.coordinates.first,
                  let end = route?.coordinates.last else { return }
            
            let coordinates = [start, end].map { MKMapItem(placemark: MKPlacemark(coordinate: $0)) }
            
            MKMapItem.openMaps(with: coordinates, launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ])
        } label: {
            Label("Открыть маршрут в картах", systemImage: "play.fill")
                .padding()
                .font(.headline)
                .foregroundStyle(.white)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color(.blue).opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    private func RouteInfo(route: Route) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(route.name).font(.title2.bold())
            Text(route.description).font(.body).foregroundColor(.secondary)
            HStack {
                RouteDetailInfo(title: "Рельеф", value: route.terrain.rawValue)
                RouteDetailInfo(title: "Покрытие", value: route.surface.rawValue)
                RouteDetailInfo(title: "Активность", value: route.activityType.rawValue)
            }
            HStack {
                Label(route.city, systemImage: "mappin.and.ellipse")
                Spacer()
                
                Label(route.formattedDistance, systemImage: "map")
                Spacer()
                
                Label(route.formattedDuration, systemImage: "clock")
                Spacer()
                
                Button {
                    Task { await viewModel.toggleLike(route: route) }
                } label: {
                    HStack {
                        Image(systemName: viewModel.isLiked(route) ? "heart.fill" : "heart")
                    }
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
        }
        .padding(.horizontal)
    }
    
    private func RouteDetailInfo(title: String, value: String) -> some View {
        Text("\(title): \(value)")
            .font(.caption)
            .padding(4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
    }

    private func DeleteRouteButton() -> some View {
        Button(
            action: {
                Task {
                    do {
                        showAlert = true
                    } catch {
                        showAlert = true
                    }
                }
            },
            label: {
                Text("Удалить маршрут")
                    .padding()
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color(.red).opacity(0.8))
                    .cornerRadius(10)
            }
        ).alert(
            isPresented: $showAlert
        ) {
            DeleteAlert()
        }
    }

    private func DeleteAlert() -> Alert {
        Alert(
            title: Text(
                "Удаление"
            ),
            message: Text(
                "Вы точно хотите удалить маршрут?"
            ),
            primaryButton: .default(
                Text(
                    "Удалить"
                ),
                action: {
                    do {
                        try viewModel.deleteRoute(for: routeId)
                        dismiss()
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

}
