//
//  ApnsPayload.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 5/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Foundation

struct ApnsPayload: Decodable {
    let aps: Aps
    struct Aps: Decodable {
        let alert: Alert
        struct Alert: Decodable {
            let title: String
            let body: String
            var subtitle: String?
            var badge: Int?
            var sound: String?
        }
    }
    static func getPayload(from jsonString: String) -> ApnsPayload? {
        if let jsonData = jsonString.data(using: .utf8),
            let pl = try? JSONDecoder().decode(ApnsPayload.self, from: jsonData) {
            return pl
        }
        return nil
    }
}






