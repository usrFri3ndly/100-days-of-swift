//
//  petition.swift
//  project7
//
//  Created by Sc0tt on 29/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import Foundation

// create decodable struct
struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
