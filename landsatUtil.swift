//
//  landsatUtil.swift
//  LandsatSearch
//
//  Created by Barnaby Gordon on 30/04/2017.
//  Copyright © 2017 Barnaby Gordon. All rights reserved.
//

import Foundation
import Alamofire


class landsatUtil {
    var API_URL: String
    var sceneList: [LandsatScene] = []
    
    init() {
        self.API_URL = "https://api.developmentseed.org/satellites/landsat"
    }
    
    func searchPoint(longitude: Double, latitude: Double, start_date: String, end_date: String, cloud_min: String, cloud_max: String, limit: Int, completionHandler: @escaping ([LandsatScene]) -> Void) {
        
        self.sceneList = []
        let search_url = self.queryBuilder(longitude: longitude, latitude: latitude, start_date: start_date, end_date: end_date, cloud_min: cloud_min, cloud_max: cloud_max, limit: limit)
        
        Alamofire.request(search_url).responseJSON {response in
            let output = response.result.value as? [String: Any]
            let results = output?["results"] as? [[String: Any]]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            
            for item in results! {
                let sceneID = item["scene_id"] as! String
                let satellite = item["satellite_name"] as! String
                let clouds = item["cloud_coverage"] as! Double
                let date = dateFormatter.date(from: item["date"] as! String)!
                let thumbnail = URL(string: (item["thumbnail"] as! String))!
                let geometry = item["data_geometry"] as? [String: Any]
                let coordinates = geometry?["coordinates"] as! NSArray
                let browseImage = URL(string: (item["browseURL"] as! String))!
                let sensor = item["sensor"] as! String
                let path = item["path"] as! Int
                let row = item["row"] as! Int
                let centerLongitude = item["sceneCenterLongitude"] as! Double
                let centerLatitude = item["sceneCenterLatitude"] as! Double
                let dayOrNight = item["dayOrNight"] as! String
                let sunElevation = item["sunElevation"] as! Double
                let sunAzimuth = item["sunAzimuth"] as! Double
                let imageQuality = item["imageQuality1"] as! Int
                let dataType = item["DATA_TYPE_L1"] as! String
                let productID = item["LANDSAT_PRODUCT_ID"] as! String
                
                let scene = LandsatScene(sceneID: sceneID, satellite: satellite, productID: productID, clouds: clouds, date: date, thumbnail: thumbnail, coordinates: coordinates, browseImage: browseImage, sensor: sensor, path: path, row: row, centerLongitude: centerLongitude, centerLatitude: centerLatitude, dayOrNight: dayOrNight, sunElevation: sunElevation, sunAzimuth: sunAzimuth, imageQuality: imageQuality, dataType: dataType)
                
                self.sceneList.append(scene)
            }
            completionHandler(self.sceneList)
        }
    }
    
    
    func queryBuilder(longitude: Double, latitude: Double, start_date: String, end_date: String, cloud_min: String, cloud_max: String, limit: Int) -> String {
        
        let date_query = "acquisitionDate:[\(start_date)+TO+\(end_date)]"
        let cloud_query = "cloudCoverFull:[\(cloud_min)+TO+\(cloud_max)]"
        let location_query = "upperLeftCornerLatitude:[\(latitude)+TO+1000]+AND+lowerRightCornerLatitude:[-1000+TO+\(latitude)]+AND+lowerLeftCornerLongitude:[-1000+TO+\(longitude)]+AND+upperRightCornerLongitude:[\(longitude)+TO+1000]"
        
        let search_query = "\(location_query)+AND+\(cloud_query)+AND+\(date_query)"
        
        let search_url = "\(self.API_URL)?search=\(search_query)&limit=\(limit)"
        
        return search_url
        
    }
}
