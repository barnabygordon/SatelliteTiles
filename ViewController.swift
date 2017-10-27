//
//  ViewController.swift
//  LandsatSearch
//
//  Created by Barnaby Gordon on 30/04/2017.
//  Copyright © 2017 Barnaby Gordon. All rights reserved.
//

import UIKit
import DatePickerDialog
import Mapbox


class ViewController: UIViewController, MGLMapViewDelegate {
    
    let landsatSearcher = landsatUtil()
    var sceneList: [LandsatScene] = []
    let centerMarker = MGLPointAnnotation()

    @IBOutlet var mapView: MGLMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        updateCrossHair()
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        updateCrossHair()
    }
    
    func updateCrossHair() {
        let mapCenter = mapView.centerCoordinate
        self.centerMarker.coordinate = CLLocationCoordinate2D(
            latitude: mapCenter.latitude,
            longitude: mapCenter.longitude)
        mapView.addAnnotation(self.centerMarker)
    }

    
    @IBAction func searchAction(_ sender: Any) {
        let centerCoordinate = mapView.centerCoordinate
        
        Loading.start()
        
        landsatSearcher.searchPoint(
            longitude:centerCoordinate.longitude,
            latitude:centerCoordinate.latitude,
            start_date:"1999-07-15",
            end_date:"2018-01-01",
            cloud_min:"0",
            cloud_max:"100",
            limit:100,
            completionHandler: { result in
                self.sceneList = result
                if self.sceneList.count > 0 {
                    self.performSegue(withIdentifier: "showSceneScroll", sender: self)
                    return
                }
                Loading.stop()
                let alert = UIAlertController(title: "No Images Found!", message: "Try a different location", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: nil, action: nil)
        guard let identifier = segue.identifier,
            identifier == "showSceneScroll",
            let vc = segue.destination as? SceneScrollViewController else {
            return
        }
        vc.sceneList = sceneList
    }

}

