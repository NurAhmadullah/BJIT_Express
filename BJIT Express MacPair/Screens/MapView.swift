//
//  MapView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 12/5/23.
//

import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationString: String = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude

            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    DispatchQueue.main.async {
                        self.locationString = "\(placemark.locality ?? ""), \(placemark.country ?? "")"
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}






struct Map: UIViewRepresentable {
    let sourceLocation: CLLocationCoordinate2D
    let destinationLocation: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)
        
        // Add a polyline overlay between source and destination
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else { return }
            mapView.addOverlay(route.polyline)
            
            let distance = route.distance / 1000 // Convert distance to kilometers
            let distanceString = String(format: "%.2f km", distance)
            
            let distanceAnnotation = MKPointAnnotation()
            distanceAnnotation.title = "Distance"
            distanceAnnotation.subtitle = distanceString
            distanceAnnotation.coordinate = CLLocationCoordinate2D(latitude: (self.sourceLocation.latitude + self.destinationLocation.latitude) / 2,
                                                                  longitude: (self.sourceLocation.longitude + self.destinationLocation.longitude) / 2)
            
            mapView.addAnnotation(distanceAnnotation)
        }
        
        // Set the region to show both source and destination
        let centerCoordinate = CLLocationCoordinate2D(latitude: (sourceLocation.latitude + destinationLocation.latitude) / 2,
                                                      longitude: (sourceLocation.longitude + destinationLocation.longitude) / 2)
        let span = MKCoordinateSpan(latitudeDelta: abs(sourceLocation.latitude - destinationLocation.latitude) * 2,
                                    longitudeDelta: abs(sourceLocation.longitude - destinationLocation.longitude) * 2)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: Map
        
        init(_ parent: Map) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}











struct MapView: View {
   
    @StateObject private var locationProvider = LocationManager()
    
    var body: some View {
        VStack {
   
            Spacer()
          
            Button("Get Your Current Location") {
                locationProvider.requestLocation()
            }
            
            HStack {
                Text("Latitude: \(locationProvider.latitude)")
                    
                Text("Longitude: \(locationProvider.longitude)")
                    .padding()
            }
            
           Spacer()
            
            VStack {
                
                //Current destination location is -  New York City, USA
                
            Map(sourceLocation: CLLocationCoordinate2D(latitude: locationProvider.latitude, longitude: locationProvider.longitude), destinationLocation: CLLocationCoordinate2D(latitude: 40.7128 , longitude: -74.0060))
            }
            
            
            
            
            
        }
        .onAppear {
            locationProvider.requestLocation()
        }
}
}




