//
//  MapViewController.swift
//  IOS_Tranining_Media
//
//  Created by Hoang Long on 12/07/2022.
//

import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManger = CLLocationManager()
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let coordinate2 = CLLocationCoordinate2D(latitude: 21.004370, longitude: 105.829529)
    let coordinate3 = CLLocationCoordinate2D(latitude: 21.005554, longitude: 105.843460)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setView()
    }
    func setView(){
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        mapView.delegate = self
        locationManger.delegate = self
    }

    private func addCustomPin(location: CLLocation){
        coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if CLLocationManager.authorizationStatus() == .denied {
            showSettingAlert(message: "Vao setting de cap quyen")
        } else {
            let pin = CustomPointAnnotation()
            pin.coordinate = coordinate
            pin.title = "nha 1"
            pin.image = "car"
            mapView.addAnnotation(pin)
            
            let pin2 = CustomPointAnnotation()
            pin2.coordinate = coordinate2
            pin2.title = "Benh vien 2"
            pin2.image = "tree"
            mapView.addAnnotation(pin2)
            
            let pin3 = CustomPointAnnotation()
            pin3.coordinate = coordinate3
            pin3.title = "Bach Khoa"
            pin3.image = "saucer"
            mapView.addAnnotation(pin3)
        }
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)), animated: true)
    }
    
}
//MARK: EXTENSION CLLOCATIONMANAGERDELEGATE
extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            addCustomPin(location: location)
        }
        
        
    }
}
//MARK: EXTENSION MKMAPVIEWDELEGATE
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        let image = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named: image.image)
        if image.image == "tree" {
            annotationView?.frame.size = CGSize(width: 75, height: 83)
            return annotationView
        } else if image.image == "saucer"{
            annotationView?.frame.size = CGSize(width: 75, height: 52)
            return annotationView
        }
        annotationView?.frame.size = CGSize(width: 75, height: 75)
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = UIColor(red: 17/255, green: 44/255, blue: 45/255, alpha: 1)
        render.lineWidth = 3
        return render
    }
}

//MARK: EXTENSION MAPVIEWCONTROLLER
extension MapViewController{
    func showSettingAlert(title: String = "Thông báo", message: String, acceptTitle: String = "Cài đặt", cancelTitle: String = "Hủy") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: acceptTitle, style: UIAlertAction.Style.cancel, handler: { (sender) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        let cancel = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.default, handler: { (sender) in
        })
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let image = view.annotation as! CustomPointAnnotation
        if image.image == "tree" {
            mapView.showRouteOnMap(pickupCoordinate: coordinate, destinationCoordinate: coordinate2)
        }
        if image.image == "saucer" {
            mapView.showRouteOnMap(pickupCoordinate: coordinate, destinationCoordinate: coordinate3)
        }
        mapView.showRouteOnMap(pickupCoordinate: coordinate, destinationCoordinate: coordinate)
    }
}

//MARK: EXTENSION MKMAPVIEW
extension MKMapView {
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D){
        let sourcePlacemarks = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemarks)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            for overlay in self.overlays {
                if overlay is MKPolyline {
                    self.removeOverlay(overlay)
                }
            }
            self.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}


