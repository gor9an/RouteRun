//
//  MapScreenView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 04.11.2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject private var viewModel = MapViewModel()
    @State private var isRecording = false
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)

    init() {
        viewModel.checkLocationIsEnable()
    }

    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }


            VStack {
                Spacer()
                if isRecording {
                    Button(action: {
                        viewModel.stopRecordingRoute()
                        isRecording = false
                    }) {
                        Text("Завершить")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                } else {
                    Button(action: {
                        viewModel.startRecordingRoute()
                        isRecording = true
                    }) {
                        Text("Начать")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}
