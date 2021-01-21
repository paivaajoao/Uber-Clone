//
//  requisicao.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 18/01/21.
//  Copyright © 2021 João Carlos Paiva. All rights reserved.
//

import UIKit
import MapKit

class Requisicao {
    
    var nome: String
    var latitude: Double
    var longitude: Double
    
    init(nome: String, latitude: Double, longitude: Double) {
        self.nome = nome
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
}
