//
//  MapScreenViewModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 04.11.2024.
//

import MapKit
import Firebase
import FirebaseFirestore

final class MapViewModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager?
    private var routePoints: [CLLocationCoordinate2D] = []
    private var startDate: Date?
    private var lastLocation: CLLocation?
    private var timer: Timer?

    @Published var currentRoute: Route?
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var routeLine: MKPolyline?
    @Published var routeDescription = ""

    private let geocoder = CLGeocoder()
    @Published var currentCity: String = "Unknown"

    private let db = Firestore.firestore()

    func checkLocationIsEnable() {
        DispatchQueue.global().async { [weak self] in
            if let self,
               CLLocationManager.locationServicesEnabled() {
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.activityType = .fitness
                self.checkLocationAuthorization()
            } else {
                print("location services disabled")
            }
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("ограничен")
        case .denied:
            print("отключены")
        case .authorizedAlways, .authorizedWhenInUse:
            print("ok")
        @unknown default:
            break
        }
    }

    func startRecordingRoute() {
        guard !isRecording else { return }

        // Если это продолжение записи
        if elapsedTime > 0 {
            isRecording = true
            startDate = Date().addingTimeInterval(-elapsedTime)
            locationManager?.startUpdatingLocation()

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.elapsedTime += 1
            }
            return
        }

        // Новая запись
        resetRecording()
        isRecording = true
        startDate = Date()
        lastLocation = nil
        locationManager?.startUpdatingLocation()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    func pauseRecording() {
        isRecording = false
        locationManager?.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    private func determineCity(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.currentCity = city
                }
            }
        }
    }

    func stopRecordingRoute() throws {
        guard isRecording else { return }

        pauseRecording()

        var userId = ""

        do {
            userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
        } catch {
            print("No user logged in")
            throw MapError.unAuthorized
        }

        if let startDate = startDate, let firstLocation = routePoints.first {
            let location = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
            determineCity(for: location)

            currentRoute = Route(
                name: "",
                description: routeDescription,
                date: startDate,
                coordinates: routePoints,
                distance: distance,
                duration: elapsedTime,
                userId: userId,
                city: currentCity
            )
        } else {
            throw MapError.distanceZero
        }
    }

    func saveRoute(name: String, description: String) {
        guard var route = currentRoute else { return }
        route.name = name
        route.description = description
        route.city = currentCity

        do {
            try db.collection("routes").document(route.id).setData(from: route)
            resetRecording()
        } catch {
            print("Error saving route: \(error.localizedDescription)")
        }
    }

    func resetRecording() {
        isRecording = false
        routePoints.removeAll()
        distance = 0
        elapsedTime = 0
        startDate = nil
        lastLocation = nil
        routeLine = nil
        currentRoute = nil
        routeDescription = ""
        timer?.invalidate()
        timer = nil
    }

    private func updateRouteLine() {
        guard !routePoints.isEmpty else {
            routeLine = nil
            return
        }

        let coordinates = routePoints
        routeLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, isRecording else { return }

        guard newLocation.horizontalAccuracy <= 50 else { return }

        if routePoints.isEmpty {
            determineCity(for: newLocation)
        }

        let coordinate = newLocation.coordinate
        routePoints.append(coordinate)

        // Рассчитываем расстояние
        if let lastLocation = lastLocation {
            distance += newLocation.distance(from: lastLocation)
        }
        lastLocation = newLocation

        // Обновляем линию маршрута
        updateRouteLine()
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapViewModel {
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: elapsedTime) ?? "00:00:00"
    }

    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f км", distance / 1000)
        } else {
            return String(format: "%.0f м", distance)
        }
    }
}
