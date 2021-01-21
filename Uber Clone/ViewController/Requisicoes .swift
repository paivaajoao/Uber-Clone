//
//  Requisicoes .swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 20/01/21.
//  Copyright © 2021 João Carlos Paiva. All rights reserved.
//

import UIKit

class Requisicoes {
    var nome: String
    var email: String
    var latitude: Double
    var longitude: Double
    
    init(nome: String, email: String, latitude: Double, longitude: Double) {
        self.nome = nome
        self.email = email
        self.latitude = latitude
        self.longitude = longitude
        
    }
}
