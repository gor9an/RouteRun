//
//  ProfileView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            HStack {
                //TODO: Changeable profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)

                Text("Nickname")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal)
                Spacer()

                Button(
                    action: {
                        //TODO: - Favorites action
                    },
                    label: {
                        Image(systemName: "bookmark.fill")
                            .resizable()
                            .frame(width: 35, height: 50)
                            .tint(.red)
                    })
            }
            .padding()

            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
