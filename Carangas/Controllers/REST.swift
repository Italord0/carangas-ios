    //
    //  REST.swift
    //  Carangas
    //
    //  Created by Douglas Frari on 12/17/21.
    //  Copyright © 2021 Eric Brito. All rights reserved.
    //

import Foundation


enum CarError {
    case url
    case taskError(error: Error?)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    
    // baseada no servico: https://deividfortuna.github.io/fipe/
    private static let urlFipe = "https://parallelum.com.br/fipe/api/v1/carros/marcas"
    
    
    private static let session = URLSession(configuration: configuration)
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 15
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    
    static func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            // a resposta chegara aqui assincrona apos o servidor responder ou quando ocorrer algum erro
            
                // 1
            if error == nil {
                    // 2
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                
                if response.statusCode == 200 {
                    
                    // servidor respondeu com sucesso :)
                    // 3
                    
                    // obter o valor de data
                    guard let data = data else {
                        onError(.noData)
                        return
                    }
                    
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                        
                    } catch {
                        // algum erro ocorreu com os dados                        
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                    
                    
                } else {
                    print("Algum status inválido(-> \(response.statusCode) <-) pelo servidor!! ")
                    onError(.responseStatusCode(code: response.statusCode))
                }
                
            } else {
                print(error.debugDescription)
                onError(.taskError(error: error))
            }
            
        }.resume()
        
    }
    
    static func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    static func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    static func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    static func loadBrands(onComplete: @escaping ([Brand]?) -> Void) {
        
        // 1 - copie o código de loadCars e cole aqui
        
        guard let url = URL(string: urlFipe) else {
            onComplete(nil)
            return
        }
            // tarefa criada, mas nao processada
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                if response.statusCode == 200 {
                        // obter o valor de data
                    guard let data = data else {
                        onComplete(nil)
                        return
                    }
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                            // algum erro ocorreu com os dados
                        onComplete(nil)
                    }
                } else {
                    onComplete(nil)
                }
            } else {
                onComplete(nil)
            }
        }
            // start request
        dataTask.resume()
        
    }
    
    
    
    
    private static func applyOperation(car: Car, operation: RESTOperation , onComplete: @escaping (Bool) -> Void ) {
                
        // o endpoint do servidor para update/delete é: URL/id
        // quando nao existir id vamos assumir que sera uma requicao de criacao (save)
        let urlString = basePath + "/" + (car._id ?? "")
        
        
        // 2 -- usar a urlString ao invés da basePath
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        var httpMethod: String = ""
            
        // 3
        switch operation {
            case .delete:
                httpMethod = "DELETE"
            case .save:
                httpMethod = "POST"
            case .update:
                httpMethod = "PUT"
        }
        request.httpMethod = httpMethod
        
            // 4 - transformar Objeto para JSON para enviar na requisito
            // transformar objeto para um JSON, processo contrario do decoder -> Encoder
        guard let jsonData = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpBody = jsonData
        
            // 5 - requisição propriamente dita como uma CLOSURE
        let dataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
                // 6 verifica resposta do servidor e retorna SUCESSO
            if error == nil {
                
                    // verificar e desembrulhar em uma unica vez
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                
                    // sucesso
                onComplete(true)
                
            } else {
                onComplete(false)
            }
            
        }
        dataTask.resume()
        
    }
    
}
