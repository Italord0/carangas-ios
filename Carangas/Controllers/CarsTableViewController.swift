//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import SideMenu

class CarsTableViewController: UITableViewController {
    
    var cars: [Car] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        label.text = "Carregando dados..."
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadCars), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        // Updated
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: SideMenuManager.PresentDirection.left)
        
    }
    
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "main")
        label.numberOfLines = 0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCars()
    }
    
    
    @objc func loadCars() {
        REST.loadCars { cars in
            
            self.cars = cars
            
            // precisa recarregar a tableview usando a main UI thread
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
        } onError: { error in
            // se tiver erro
            
            
            var response: String = ""
            
            switch error {
            case .invalidJSON:
                response = "invalidJSON"
            case .noData:
                response = "noData"
            case .noResponse:
                response = "noResponse"
            case .url:
                response = "JSON inválido"
            case .taskError(let error):
                response = "\(error?.localizedDescription ?? "Erro genérico!")"
            case .responseStatusCode(let code):
                if code != 200 {
                    response = "Algum problema com o servidor. :( \nError:\(code)"
                }
            }
            // TODO utilizar um alerta para mostrar o erro
            print(response)
            
            DispatchQueue.main.async {
                self.label.text = "Algo deu errado! \n\n\(response)"
                self.tableView.backgroundView = self.label
            }
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = cars.count
        
        if count == 0 {
            // mostrar mensagem padrao
            self.tableView.backgroundView = self.label
        } else {
            self.label.text = ""
            self.tableView.backgroundView = nil
        }
        
        return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        let car = cars[indexPath.row]
        // Configure the cell...
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // 1
            let car = cars[indexPath.row]
            REST.delete(car: car) { (success) in
                if success {
                    
                    // ATENCAO nao esquecer disso
                    // removendo o objeto da estrutura
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    
                    // PODE_SE chamar o loadCars() para nao precisar usar as linhas acima
                    // o lado ruim de chamar o loadCars é que iremos fazer uma nova requisicao
                    // para o servidor
                }
            }
            
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? CarViewController {
            let car = cars[tableView.indexPathForSelectedRow!.row]
            vc.car = car
        }
        
    }
    
    
}
