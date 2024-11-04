//
//  MapScreenViewModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 04.11.2024.
//

import MapKit

final class MapViewModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager?
    private var routePoints: [CLLocationCoordinate2D] = []

    func checkLocationIsEnable() {
        DispatchQueue.global().async { [weak self] in
            if let self,
               CLLocationManager.locationServicesEnabled() {
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                checkLocationAuthorization()

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
        default:
            break
        }
    }

    func startRecordingRoute() {
        routePoints.removeAll() // Начинаем новый маршрут
        locationManager?.startUpdatingLocation()
    }

    func stopRecordingRoute() {
        locationManager?.stopUpdatingLocation()
        // Сохраните маршрут или добавьте дальнейшую обработку данных
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePoints.append(location.coordinate)
    }
}
