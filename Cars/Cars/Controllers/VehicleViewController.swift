//
//  VehicleViewController.swift
//  Cars
//
//  Created by Sasi M on 25/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import UIKit

enum InterfaceType {
    case List,
    Map
}

class VehicleViewController: UIViewController {

    @IBOutlet private weak var mapInterfaceView: UIView!
    @IBOutlet private weak var listInterfaceView: UIView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var filterButtonsStackView: UIStackView!
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var bookingView: UIView!
    @IBOutlet private weak var launchLogoImageView: UIImageView!
    @IBOutlet private weak var interfaceButton: UIButton!
    
    // MARK: Constraints to transit views
    @IBOutlet private weak var listCenter: NSLayoutConstraint!
    @IBOutlet private weak var mapCenter: NSLayoutConstraint!
    @IBOutlet private weak var filterViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var filterViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var interfaceTrailing: NSLayoutConstraint!
    
    private let vehicleViewModel: VehicleViewModel = VehicleViewModel()
    private let vehicleType: VehicleType = .All
    
    private var listController: VehicleListController?
    private var mapController: VehicleMapViewController?
    private var slideToAcceptControl : SlideToAcceptControl?
    private var interface: InterfaceType = .Map
    
    // MARK: Flags to handle transitions
    private var isAnimatingInterface = false
    private var isAnimatingBookingTab = false
    private var isFiltering = false
    private var isBookingTabVisible = false
    
    // MARK: View Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        interfaceButton.layer.cornerRadius = interfaceButton.frame.size.width/2
        interfaceButton.backgroundColor = UIColor.white
        interfaceButton.setDropShadow()
        
        highlightView.backgroundColor = UIColor.init(red: 200.0/255.0, green: 221.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        highlightView.layer.cornerRadius = 20.0;
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor.clear
        view.addSubview(statusBarView)
        
        filterView.addHorizontalDropShadow()
        bookingView.addHorizontalDropShadow()
        
        vehicleViewModel.addObserver(self)
        loadSlideControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterViewBottom.constant = -(filterView.frame.size.height + 40)
        listCenter.constant = -(listInterfaceView.frame.size.width + 20)
        interfaceTrailing.constant = listInterfaceView.frame.size.width + 80
        if (isIPhoneX() == true) {
            filterViewHeight.constant = 120
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.launchLogoImageView.alpha == 0) {
            return
        }
        // Animate launch image with scale transfermation
        // Present filter view from bottom and interface button from right with animation
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .beginFromCurrentState, animations: {
            self.launchLogoImageView.transform = CGAffineTransform(scaleX: 3, y: 3)
            self.launchLogoImageView.alpha = 0
        }) { [unowned self] (finished) in
            self.launchLogoImageView.removeFromSuperview()
            self.loadVehicleMapInterface()
            self.view.backgroundColor = UIColor.white
            self.vehicleViewModel.fetchVehicles()
        }
    }
    
    // MARK: Button actions
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        if (isFiltering == true ||
            isAnimatingBookingTab == true) {
            return
        }
        isFiltering = true
        vehicleViewModel.vehicleType = VehicleType(rawValue: sender.tag)!
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.highlightView.center = self.filterButtonsStackView.convert(sender.center, to: self.filterView)
        }) { [weak self] (finished) in
            self?.isFiltering = false
        }
    }
    
    @IBAction func interfaceButtonTapped(_ sender: UIButton) {
        if isAnimatingInterface == true {
            return
        }
        isAnimatingInterface = true
        let center = listInterfaceView.frame.size.width + 20
        switch interface {
        case .List:
            loadVehicleMapInterface()
            mapCenter.constant = 0
            interfaceTrailing.constant = center
            listCenter.constant = -center
            interface = .Map
            sender.setImage(UIImage.init(named: "ListView"), for: .normal)
            interfaceButton.backgroundColor = UIColor.white
            interfaceButton.setDropShadow()
            break
            
        case .Map:
            loadVehicleListInterface()
            mapCenter.constant = center
            interfaceTrailing.constant = 0
            listCenter.constant = 0
            interface = .List
            sender.setImage(UIImage.init(named: "MapView"), for: .normal)
            interfaceButton.backgroundColor = UIColor.init(red: 200.0/255.0, green: 221.0/255.0, blue: 87.0/255.0, alpha: 1.0)
            interfaceButton.removeDropShadow()
            break
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { [weak self] (finished) in
            self?.reloadVehicleData()
            self?.isAnimatingInterface = false
        }
    }
    
    // MARK: Vehicle interface methods
    func loadVehicleListInterface() {
        if (listController == nil) {
            listController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VehicleListController") as? VehicleListController
            listController?.view.frame = listInterfaceView.bounds
            addChild(listController!)
            listController?.didMove(toParent: self)
            listInterfaceView.addSubview(listController!.view)
        }
    }
    
    func loadVehicleMapInterface() {
        if (mapController == nil) {
            mapController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VehicleMapViewController") as? VehicleMapViewController
            mapController?.vehicleViewModel = vehicleViewModel
            mapController?.view.frame = mapInterfaceView.bounds
            addChild(mapController!)
            mapController?.didMove(toParent: self)
            mapInterfaceView.addSubview(mapController!.view)
        }
    }
    
    func isIPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                return true
            default:
                return false
            }
        }
        return false
    }
}

extension VehicleViewController: VehicleViewModelObserver {
    
    // MARK: Vehicle ViewModel observer medhods and delegate
    func reloadVehicleData() {
        slideDidCancel()
        if (filterViewBottom.constant != 0) {
            let allButton = filterView.viewWithTag(VehicleType.All.rawValue)
            highlightView.center = filterButtonsStackView.convert(allButton!.center, to: filterView)
            filterViewBottom.constant = 0
            interfaceTrailing.constant -= 60
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        switch interface {
        case .List:
            listController!.vehicleViewModel = vehicleViewModel
            listController!.reloadData()
            break
            
        case .Map:
            mapController!.vehicleViewModel = vehicleViewModel
            mapController!.reloadData()
            break
        }
    }
    
    func displayBookingTab(forVehicle vehicle: Vehicle) {
        if (isBookingTabVisible == true ||
            isAnimatingBookingTab == true) {
            return
        }
        isAnimatingBookingTab = true
        let cubeTranstion:CubeTransition = CubeTransition()
        cubeTranstion.delegate = self
        cubeTranstion.translateView(faceView: filterView,
                                    withView: bookingView,
                                    toDirection: .Up,
                                    withDuration: 0.5)
    }
    
    func displayWarning(message: String) {
        WarningManager.createAndPushWarning(message: message, cancel: "Ok")
    }
    
    func hideBookingTab() {
        slideDidCancel()
    }
}

extension VehicleViewController: SlideControlDelegate {
    
    // MARK: SlideControl medhods and delegate
    func loadSlideControl() {
        if (slideToAcceptControl == nil) {
            let x: CGFloat = (bookingView.frame.size.width - 276) / 2
            slideToAcceptControl = SlideToAcceptControl.init(withDelegate: self)
            slideToAcceptControl!.view.frame = CGRect.init(origin: .init(x: x, y: 10), size: .init(width: 276, height: 45))
            bookingView.addSubview(slideToAcceptControl!.view)
        }
    }
    
    func slideComplete() {
        let fleetType = vehicleViewModel.selectedVehicle?.carType ?? ""
        WarningManager.createAndPushWarning(message: "Booking confirmed (" + fleetType + " " + "\(vehicleViewModel.selectedVehicle!.id)" + "). Enjoy your ride!", cancel: "Ok")
        slideDidCancel()
        slideToAcceptControl?.resetSlider()
    }
    
    func slideDidCancel() {
        if (isBookingTabVisible == false ||
            isAnimatingBookingTab == true) {
            return
        }
        isAnimatingBookingTab = true
        vehicleViewModel.canSelectVehicle = false
        listController?.resetVehicleSelection()
        mapController?.resetVehicleSelection()
        let cubeTranstion:CubeTransition = CubeTransition()
        cubeTranstion.delegate = self
        cubeTranstion.translateView(faceView: bookingView,
                                    withView: filterView,
                                    toDirection: .Down,
                                    withDuration: 0.5)
    }
}

extension VehicleViewController: CubeTransitionDelegate {
    
    // MARK: Cube transition medhods and delegate
    func animationDidFinishWithView(displayView: UIView) {
        isAnimatingBookingTab = false
        if (displayView == filterView) {
            isBookingTabVisible = false
            filterView.backgroundColor = UIColor.white
            bookingView.superview!.insertSubview(bookingView, at: 0)
        } else if (displayView == bookingView) {
            isBookingTabVisible = true
            bookingView.backgroundColor = UIColor.white
            filterView.superview!.insertSubview(filterView, at: 0)
        }
        vehicleViewModel.canSelectVehicle = true
    }
}


