//
//  RoutesView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import SwiftUI

struct RoutesView: View {
    private var routes = [Route]()
    private var viewModel: RoutesViewModel
    @State var searchedText: String = ""

    init(viewModel: RoutesViewModel) {
        self.viewModel = viewModel
        self.routes = viewModel.routes
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(routes.map { $0.title }, id: \.self) { route in
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
    RoutesView(viewModel: RoutesViewModel())
}
