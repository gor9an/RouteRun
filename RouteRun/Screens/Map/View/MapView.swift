import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject private var viewModel = MapViewModel()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showingSaveAlert = false
    @State private var showingResetAlert = false
    @State private var showErrorAlert = false
    @State private var errorDescription = ""
    @State private var routeName = ""
    @State private var routeDescription = ""
    
    init() {
        viewModel.checkLocationIsEnable()
    }
    
    var body: some View {
        ZStack {
            MapView()
            
            VStack {
                HStack {
                    RouteData()
                    Spacer()
                }
                
                Spacer()
                
                ControlPanel()
                
            }.alert("Ошибка", isPresented: $showErrorAlert) {
                Button("Хорошо", role: .cancel) {
                    errorDescription = ""
                }
            } message: {
                Text("\(errorDescription != "" ? errorDescription : "Неизвестная ошибка").")
            }
        }
        .onAppear {
            position = .userLocation(fallback: .automatic)
        }
    }
}

private extension MapView {
    private func MapView() -> some View {
        Map(position: $position) {
            UserAnnotation()
            
            if let routeLine = viewModel.routeLine {
                MapPolyline(routeLine)
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .sheet(isPresented: $showingSaveAlert) {
            SaveRouteSheet(
                viewModel: viewModel,
                isPresented: $showingSaveAlert,
                name: $routeName,
                description: $routeDescription
            )
        }
        .alert("Сбросить запись?", isPresented: $showingResetAlert) {
            Button("Сбросить", role: .destructive) {
                viewModel.resetRecording()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите сбросить текущую запись? Все данные будут потеряны.")
        }
    }
    
    private func RouteData() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.formattedTime)
                .font(.title)
                .padding()
                .background(Color.secondary.opacity(0.4))
                .cornerRadius(10)
            
            Text(viewModel.formattedSpeed)
                .font(.headline)
                .padding()
                .background(Color.secondary.opacity(0.4))
                .cornerRadius(10)
            
            Text(viewModel.formattedDistance)
                .font(.headline)
                .padding()
                .background(Color.secondary.opacity(0.4))
                .cornerRadius(10)
            
            Text(viewModel.formattedCalories)
                .font(.headline)
                .padding()
                .background(Color.secondary.opacity(0.4))
                .cornerRadius(10)
        }
        .padding(8)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(10)
        .padding(8)
    }
    
    private func ControlPanel() -> some View {
        HStack(spacing: 20) {
            if viewModel.isRecording {
                PauseButton()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                StopButton()
                    .transition(.scale.combined(with: .opacity))
                
                ResetButton()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                ResumeButton()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.bottom, 30)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isRecording)
    }
    
    private func PauseButton() -> some View {
        Button(action: {
            viewModel.pauseRecording()
        }) {
            Image(systemName: "pause.fill")
                .symbolEffect(.bounce, options: .speed(2), value: viewModel.isRecording)
                .foregroundColor(.white)
                .padding(20)
                .background {
                    Circle()
                        .fill(Color.orange.gradient)
                        .shadow(radius: 5)
                }
                .overlay {
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .scaleEffect(1.1)
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func StopButton() -> some View {
        Button(action: {
            do {
                try viewModel.stopRecordingRoute()
                showingSaveAlert = true
            } catch {
                showErrorAlert = true
                errorDescription = error.localizedDescription
            }
        }) {
            Image(systemName: "stop.fill")
                .foregroundColor(.white)
                .padding(20)
                .background {
                    Circle()
                        .fill(Color.red.gradient)
                        .shadow(radius: 5)
                        .scaleEffect(1.1)
                        .opacity(0.8)
                }
                .overlay {
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                        .scaleEffect(1.3)
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func ResetButton() -> some View {
        Button(action: {
            showingResetAlert = true
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding(20)
                .background {
                    Circle()
                        .fill(Color.gray.gradient)
                        .shadow(radius: 3)
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func ResumeButton() -> some View {
        Button(action: {
            viewModel.startRecordingRoute()
        }) {
            Image(systemName: viewModel.elapsedTime > 0 ? "play.fill" : "record.circle.fill")
                .symbolEffect(.bounce, options: .speed(2), value: viewModel.isRecording)
                .foregroundColor(.white)
                .padding(20)
                .background {
                    Circle()
                        .fill(
                            viewModel.elapsedTime > 0 ?
                            Color.blue.gradient :
                                Color.green.gradient
                        )
                        .shadow(radius: 5)
                }
                .overlay {
                    if !viewModel.isRecording && viewModel.elapsedTime == 0 {
                        Circle()
                            .stroke(Color.green, lineWidth: 2)
                            .scaleEffect(1.2)
                            .opacity(0.8)
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
