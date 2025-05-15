import SwiftUI
import MapKit

struct RouteDetailView: View {
    let routeId: String
    @ObservedObject var viewModel: RoutesViewModel
    
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
                    
                    OpenInMapsButton()
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
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private func RouteInfo(route: Route) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(route.name).font(.title2.bold())
            Text(route.description).font(.body).foregroundColor(.secondary)
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
}
