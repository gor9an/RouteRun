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
            RoundedRectangle(cornerRadius: 25)
                .tabItem {
                    Label("Маршруты", systemImage: "road.lanes.curved.right")
                }
            RoundedRectangle(cornerRadius: 25)
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
