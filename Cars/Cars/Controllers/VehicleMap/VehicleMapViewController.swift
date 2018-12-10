//
//  VehicleMapViewController.swift
//  Cars
//
//  Created by Sasi M on 26/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let tag: Int
    
    init(coordinates location: CLLocationCoordinate2D, title: String, tag: Int) {
        self.coordinate = location
        self.title = title
        self.tag = tag
        super.init()
    }
}

class VehicleMapViewController: UIViewController {

    @IBOutlet weak var vehicleMapView: MKMapView!
    weak var vehicleViewModel: VehicleViewModel?
    
    private var selectedAnnotation: MapPin?
    private var isLaunching: Bool = true
    private var isVehicleReset: Bool = false
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nePoint:MKMapPoint  = MKMapPoint.init(defaultNECoordinate)
        let neRect:MKMapRect = MKMapRect.init(x: nePoint.x, y: nePoint.y, width: 0, height: 0)
        let swPoint:MKMapPoint = MKMapPoint.init(defaultSWCoordinate)
        let swRect:MKMapRect = MKMapRect.init(x: swPoint.x, y: swPoint.y, width: 0, height: 0)
        vehicleMapView.setVisibleMapRect(neRect.union(swRect), animated: true)
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(_:)))
        panRec.delegate = self
        vehicleMapView.addGestureRecognizer(panRec)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        resetVehicleSelection()
        vehicleMapView.removeAnnotations(vehicleMapView.annotations)
        let vehicleCount = vehicleViewModel!.getNumberOfVehicles()
        if (vehicleCount > 0) {
            for i in 0...vehicleCount-1 {
                let vehicleMapModel = vehicleViewModel?.getVehicleMapModel(at: i)
                if (CLLocationCoordinate2DIsValid(vehicleMapModel!.coordinate)) {
                    let vehiclePin = MapPin.init(coordinates: vehicleMapModel!.coordinate, title: "", tag: i+1)
                    vehicleMapView.addAnnotation(vehiclePin)
                }
            }
        }
    }
    
    func resetVehicleSelection() {
        if (selectedAnnotation != nil) {
            isVehicleReset = true
            vehicleMapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
    }
}

extension VehicleMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var vehiclePin = mapView.dequeueReusableAnnotationView(withIdentifier: "VehiclePin")
        if vehiclePin == nil {
            vehiclePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "VehiclePin")
            vehiclePin?.canShowCallout = true
        }
        
        let vehicleMapModel = vehicleViewModel?.getVehicleMapModel(at: (annotation as! MapPin).tag-1)
        vehiclePin?.annotation = annotation
        vehiclePin?.isEnabled = true
        vehiclePin?.image = vehicleMapModel!.annotationImage.imageRotatedByDegrees(degrees: CGFloat(vehicleMapModel!.heading), flip: false)
        configureVehicleDetailView(vehiclePin!, vehicleMapModel: vehicleMapModel!)
        return vehiclePin
    }
    
    func configureVehicleDetailView(_ annotationView: MKAnnotationView, vehicleMapModel: VehicleMapModel) {
        
        let vehicleView = UIView()
        let views = ["vehicleView": vehicleView]
        vehicleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[vehicleView(140)]", options: [], metrics: nil, views: views))
        vehicleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vehicleView(40)]", options: [], metrics: nil, views: views))
        
        let attriTitleString = NSAttributedString(string:"\(vehicleMapModel.id)" + "\n",
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        
        let attriIdString = NSAttributedString(string:"\(vehicleMapModel.title)" + "\n",
                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray,
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        
        let attriDetailString = NSMutableAttributedString()
        attriDetailString.append(attriTitleString)
        attriDetailString.append(attriIdString)
        
        let titleLabel = UILabel.init(frame: CGRect(x: 80, y: 0, width: 90, height: 40))
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.attributedText = attriDetailString
        vehicleView.addSubview(titleLabel)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 5, width: 70, height: 30))
        imageView.image = vehicleMapModel.vehicleImage
        imageView.contentMode = .scaleToFill
        vehicleView.addSubview(imageView)
        
        annotationView.detailCalloutAccessoryView = vehicleView
    }
    
    func regionChanged() {
        let mRect = vehicleMapView.visibleMapRect
        let neMapPoint: MKMapPoint = MKMapPoint.init(x: mRect.maxX, y: mRect.origin.y)
        let swMapPoint: MKMapPoint = MKMapPoint.init(x: mRect.origin.x, y: mRect.maxY)
        vehicleViewModel?.fetchVehicles(neMapPoint.coordinate, swCoordinate: swMapPoint.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
        if (vehicleViewModel?.canSelectVehicle == false) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            return
        }
        let vehicleMapModel = vehicleViewModel?.getVehicleMapModel(at: (view.annotation as! MapPin).tag-1)
        vehicleViewModel?.selectVehicle(withId: vehicleMapModel!.id)
        selectedAnnotation = view.annotation as? MapPin
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (selectedAnnotation != nil) {
            selectedAnnotation = nil
            perform(#selector(checkShouldResetVehicle), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func checkShouldResetVehicle() {
        if (isVehicleReset == true) {
            isVehicleReset = false
            return
        }
        if (selectedAnnotation == nil) {
            vehicleViewModel?.selectedVehicle = nil
        }
    }
}

extension VehicleMapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ gestureRecognizer: UIGestureRecognizer?) {
        
        if (gestureRecognizer == nil) {
            return
        }
        
        switch gestureRecognizer!.state {
        case .began:
            if (selectedAnnotation != nil) {
                vehicleMapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
            if (timer != nil) {
                timer?.invalidate()
                timer = nil
            }
            
        case .ended:
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (timer) in
                timer.invalidate()
                self?.regionChanged()
            })
            
        default:
            break
        }
    }
}



