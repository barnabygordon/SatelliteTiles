//
//  LandsatScene.swift
//  LandsatSearch
//
//  Created by Barnaby Gordon on 30/04/2017.
//  Copyright © 2017 Barnaby Gordon. All rights reserved.
//

import Foundation
import Mapbox


class LandsatScene{
    var sceneID: String
    var productID: String
    var satellite: String
    var clouds: Double
    var date: String
    var year: String
    var month: String
    var day: String
    var thumbnail: URL
    var browseImage: URL
    var coordinates: [CLLocationCoordinate2D]
    var sensor: String
    var path: Int
    var row: Int
    var centerLongitude: Double
    var centerLatitude: Double
    var dayOrNight: String
    var sunElevation: Double
    var sunAzimuth: Double
    var imageQuality: Int
    var dataType: String
    var awsID: String
    
    init(
        sceneID:String, satellite:String, productID:String, clouds:Double, date:Date, thumbnail:URL, coordinates:NSArray, browseImage:URL, sensor:String, path:Int, row:Int, centerLongitude:Double, centerLatitude:Double, dayOrNight:String, sunElevation:Double, sunAzimuth:Double, imageQuality:Int, dataType: String) {
        self.sceneID = sceneID
        self.productID = productID
        self.satellite = satellite
        self.clouds = clouds
        self.date = String(describing: date).components(separatedBy: " ")[0]
        self.year = self.date.components(separatedBy: "-")[0]
        self.month = self.date.components(separatedBy: "-")[1]
        self.day = self.date.components(separatedBy: "-")[2]
        self.thumbnail = thumbnail
        self.browseImage = browseImage
        self.coordinates = parseCoordinates(coordinates: coordinates)
        self.sensor = sensor
        self.path = path
        self.row = row
        self.centerLongitude = centerLongitude
        self.centerLatitude = centerLatitude
        self.dayOrNight = dayOrNight
        self.sunAzimuth = sunAzimuth
        self.sunElevation = sunElevation
        self.imageQuality = imageQuality
        self.dataType = dataType
        self.awsID = getAWSID(sceneID:self.sceneID, date:self.date, productID:self.productID)
    }
}


func getAWSID(sceneID:String, date:String, productID:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD"
    let date: NSDate = dateFormatter.date(from: date)! as NSDate
    let landsatDate: NSDate = dateFormatter.date(from: "2017-05-01")! as NSDate
    let awsID: String
    
    if date.timeIntervalSince1970 > landsatDate.timeIntervalSince1970 {
        awsID = productID
    }
    else {
        awsID = sceneID.components(separatedBy: "LGN")[0] + "LGN00"
    }
    return awsID
}


func parseCoordinates(coordinates:NSArray) -> [CLLocationCoordinate2D] {
    var polygon: [CLLocationCoordinate2D] = []
    
    for point in coordinates[0] as! [NSArray] {
        let location = CLLocationCoordinate2D(
            latitude: point[1] as! Double,
            longitude: point[0] as! Double)
        polygon.append(location)
    }
        
    return polygon
}
