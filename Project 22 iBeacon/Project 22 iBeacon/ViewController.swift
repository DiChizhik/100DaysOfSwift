//
//  ViewController.swift
//  Project 22 iBeacon
//
//  Created by Diana Chizhik on 20/06/2022.
//
import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    var locationManager: CLLocationManager?
    var beaconDetected = false
    
    var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 128
        view.layer.masksToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 256),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beacon = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "myBeacon")
        
        locationManager?.startMonitoring(for: beacon)
//        locationManager?.startRangingBeacons(in: beacon)
        locationManager?.startRangingBeacons(satisfying: beacon.beaconIdentityConstraint)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .immediate:
                self.view.backgroundColor = .green
                self.distanceReading.text = "RIGHT HERE"
                self.imageView.transform = .identity
            case .near:
                self.view.backgroundColor = .yellow
                self.distanceReading.text = "NEAR"
                self.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            case .far:
                self.view.backgroundColor = .red
                self.distanceReading.text = "FAR"
                self.imageView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.imageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if beaconDetected == false {
            beaconDetected.toggle()
            let ac = UIAlertController(title: "Beacon detected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

}

