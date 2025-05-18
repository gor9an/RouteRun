import SwiftUI

struct RouteCardView: View {
    let route: Route
    @ObservedObject var viewModel: RoutesViewModel
    
    var body: some View {
        VStack() {
            RouteHeader()
            
            RouteInfo()
            
            RouteMapView(coordinates: route.coordinates)
                .frame(height: 120)
                .cornerRadius(8)
                .allowsHitTesting(false)
        }
        .padding(.vertical, 8)
    }
    
    private func RouteHeader() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.name).font(.headline)
                
                Spacer()
                
                Button {
                    Task { await viewModel.toggleLike(route: route) }
                } label: {
                    Text("\(route.likesCount)")
                    Image(systemName: viewModel.isLiked(route) ? "heart.fill" : "heart")
                }
                .buttonStyle(.plain)
            }
            Text(route.description).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
            
            if let user = viewModel.currentUser, user.id != route.userId {
                UserInfo(user: user)
            }
        }
        .padding(.bottom, 8)
    }
    
    private func UserInfo(user: RouteUser) -> some View {
        HStack(spacing: 8) {
            if let url = user.photoURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            }
            Text("Ваш маршрут")
                .font(.caption)
                .foregroundColor(.secondary)
                .bold()
        }
    }
    
    private func RouteInfo() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.terrain.rawValue).font(.caption).padding(4).background(Color.gray.opacity(0.2)).cornerRadius(4)
                Text(route.surface.rawValue).font(.caption).padding(4).background(Color.gray.opacity(0.2)).cornerRadius(4)
                Text(route.activityType.rawValue).font(.caption).padding(4).background(Color.gray.opacity(0.2)).cornerRadius(4)
            }

            HStack {
                Label(route.city, systemImage: "mappin.and.ellipse")
                Spacer()

                Label(route.formattedDistance, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                Spacer()

                Label(route.formattedDuration, systemImage: "clock")
            }
            .font(.caption)
        }
    }
}
