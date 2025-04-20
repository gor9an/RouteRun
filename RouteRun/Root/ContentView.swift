//
//  ContentView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 04.11.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
            RoutesView(viewModel: RoutesViewModel())
                .tabItem {
                    Label("Маршруты", systemImage: "road.lanes.curved.right")
                }
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
