//
//  SceneScrollViewController.swift
//  LandsatSearch
//
//  Created by Barnaby Gordon on 23/10/2017.
//  Copyright © 2017 Barnaby Gordon. All rights reserved.
//

import UIKit
import Mapbox
import SDWebImage


class SceneScrollViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MGLMapViewDelegate{

    @IBOutlet weak var menuView: UICollectionView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MGLMapView!

    var menuShowing: Bool = true
    var sceneList: [LandsatScene] = []
    let reuseIdentifier = "sceneCell"
    let blackView = UIView()
    var rasterLayer: MGLRasterStyleLayer?
    var source: MGLSource?
    var tileAPI: tileUtil = tileUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        Loading.stop()
        
        menuView.layer.masksToBounds = false
        menuView.clipsToBounds = false
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
    }
    
    
    func closeMenu() {
        if (self.menuShowing == true) {
            leadingConstraint.constant = -270
            self.menuShowing = false
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if (self.menuShowing == false) {
            
            leadingConstraint.constant = 0
            self.menuShowing = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }

    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                
                if (self.menuShowing == true) {closeMenu()}

            default:
                break
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sceneList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SceneCollectionViewCell
        
        let scene = sceneList[indexPath.row]
        
        cell.sceneLabel.text = scene.date
        cell.sceneImage.sd_setImage(with: scene.thumbnail)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let scene = sceneList[indexPath.row]
        
        showTiles(scene: scene)
        updateMapLocationTo(scene: scene)
        closeMenu()
    }
    
    func updateMapLocationTo(scene: LandsatScene) {
        let shape = MGLPolygon(
            coordinates: scene.coordinates,
            count: UInt(scene.coordinates.count))

        mapView.setVisibleCoordinateBounds(shape.overlayBounds, animated: true)
    }
    
    
    func showTiles(scene: LandsatScene) {

        if let rasterLayer = rasterLayer, let source = source {
            mapView.style?.removeLayer(rasterLayer)
            mapView.style?.removeSource(source)
        }
        
        tileAPI.getUrl(awsID: scene.awsID, pmin: 5, pmax: 95, redBand: "7", greenBand: "4", blueBand: "2", tileSize: 512, pan: false) { tileURL in
            
            let source = MGLRasterSource(
                identifier: "landsat-tiles",
                tileURLTemplates: [tileURL],
                options: [ .tileSize: 256])
            
            let rasterLayer = MGLRasterStyleLayer(identifier: "landsat-tiles", source: source)
            self.mapView.style?.addSource(source)
            self.mapView.style?.addLayer(rasterLayer)
            
            self.rasterLayer = rasterLayer
            self.source = source
        }
    }
}

