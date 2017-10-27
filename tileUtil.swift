//
//  tileUtil.swift
//  LandsatSearch
//
//  Created by Barnaby Gordon on 19/10/2017.
//  Copyright © 2017 Barnaby Gordon. All rights reserved.
//

import Foundation
import Alamofire


class tileUtil {
    var apiRoot: String!
    
    init() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            
            if let dict = dictRoot {
                self.apiRoot = dict["TileAPIURLRoute"] as! String
                print(apiRoot)
            }
        }
    }

    func getUrl(awsID: String, pmin: Int, pmax: Int, redBand: String, greenBand: String, blueBand: String, tileSize: Int, pan: Bool, completionHandler: @escaping (String) -> Void) {
        querySceneMetaData(awsID: awsID, pmin: pmin, pmax: pmax) { (metaData) in
            completionHandler(self.generateTileURL(sceneMetadata: metaData, awsID: awsID, redBand: redBand, greenBand: greenBand, blueBand: blueBand, tileSize: tileSize, pan: pan))
        }
    }

    func querySceneMetaData(awsID: String, pmin: Int, pmax: Int, completionHandler: @escaping ([String: [Int]]) -> Void) {
        
        let search_url: String = "\(self.apiRoot)/production/landsat/metadata/\(awsID)?pmin=\(pmin)&pmax=\(pmax)"
        
        Alamofire.request(search_url).responseJSON {response in
            let json_result: [String: Any] = response.result.value as! [String : Any]
            
            guard let metaData: [String: [Int]] = json_result["rgbMinMax"] as? [String : [Int]] else {
                return
            }
            completionHandler(metaData)
        }
    }
    
    func generateTileURL(sceneMetadata: [String: [Int]], awsID: String, redBand: String, greenBand: String, blueBand: String, tileSize: Int, pan: Bool) -> String {
        
        guard let redMin: Int = sceneMetadata[redBand]?[0],
            let redMax: Int = sceneMetadata[redBand]?[1],
            let greenMin: Int = sceneMetadata[greenBand]?[0],
            let greenMax: Int = sceneMetadata[greenBand]?[1],
            let blueMin: Int = sceneMetadata[blueBand]?[0],
            let blueMax: Int = sceneMetadata[blueBand]?[1] else {
            return ""
        }

        return "\(self.apiRoot)/production/landsat/tiles/\(awsID)/{z}/{x}/{y}.png?rgb=\(redBand),\(greenBand),\(blueBand)&r_bds=\(redMin),\(redMax)&g_bds=\(greenMin),\(greenMax)&b_bds=\(blueMin),\(blueMax)&tile=\(tileSize)&pan=\(pan)"
    }
}
