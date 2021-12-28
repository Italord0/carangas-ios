//
//  Brand.swift
//  Carangas
//
//  Created by Douglas Frari on 12/18/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation

struct Brand: Codable {
    
    // baseado no servico da API: https://parallelum.com.br/fipe/api/v1/carros/marcas
    
    let codigo: String
    let nome: String
}
