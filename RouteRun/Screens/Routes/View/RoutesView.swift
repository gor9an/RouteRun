//
//  RoutesView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import SwiftUI

struct RoutesView: View {
    let routes = [
        "Дорога 1", "Дорога 2", "Путь 3", "Дорога 4", "Тропа 5",
        "Путь 6", "Тропа 7", "Дорога 8", "Дорога 9", "Ручей 10"
    ]

    @State var searchedText: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(routes, id: \.self) { route in
                        //FIXME: Strange if
                        if route.lowercased().hasPrefix(searchedText.lowercased())
                            || route.lowercased().hasSuffix(searchedText.lowercased())
                            || searchedText == "" {
                            Text("\(route)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Маршруты")
        .searchable(text: $searchedText, prompt: "Введие ключевые слова")
    }
}

#Preview {
    RoutesView()
}
