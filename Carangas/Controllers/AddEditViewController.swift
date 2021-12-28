//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

enum CarOperationAction {
    case add_car
    case edit_car
    case get_brands
}

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
        // MARK: - Properties
    var car: Car!
    
    var brands: [Brand] = []
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    } ()
    

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        if car != nil {
            
            title = "Editar"
            
                // modo edicao
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }

        // 1 criamos uma toolbar e adicionamos como input do textview
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
        
        loadBrands()
    }
    
    func startLoadingAnimation() {
        self.btAddEdit.isEnabled = false
        self.btAddEdit.backgroundColor = .gray
        self.btAddEdit.alpha = 0.5
        self.loading.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.btAddEdit.isEnabled = true
        self.btAddEdit.backgroundColor = UIColor(named: "main")
        self.btAddEdit.alpha = 1
        self.loading.stopAnimating()
    }
    
    
    func loadBrands() {
        
        startLoadingAnimation()
        
        REST.loadBrands { (brands) in
            
            guard let brands = brands else {
                self.showAlert(withTitle: "Marcas de carros", withMessage: "Ocorreu um erro ao tentar obter as marcas de carros da tabela FIPE.", isTryAgain: true, operation: .get_brands)
                return
            }
            
                // ascending order
            self.brands = brands.sorted(by: {$0.nome < $1.nome})
            
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.pickerView.reloadAllComponents()
            }
            
        }
    }
    
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].nome
        cancel()
    }
    
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        
        if car == nil {
            // adicionar carro novo
            car = Car()
        }
        
        car.name = (tfName?.text)!
        car.brand = (tfBrand?.text)!
        if tfPrice.text!.isEmpty {
            tfPrice.text = "0"
        }
        car.price = Double(tfPrice.text!)!
        car.gasType = scGasType.selectedSegmentIndex
        
            // 1
        if car._id == nil {
                // new car
            self.salvar()
            
        } else {
                // 2 - edit current car
            self.editar()
        }
        
    }
    
    func salvar() {
        
        startLoadingAnimation()
        
        REST.save(car: car) { foiSalvoComSucesso in
            
            if foiSalvoComSucesso {
                    // foi salvo
                self.goBack()
            } else {
                    // nao foi salvo por algum motivo
                print("-problemas ao salva -> mostrar um alerta para o usuario <-")
                self.showAlert(withTitle: "Savar", withMessage: "Ocorreu um erro ao tentar salvar.", isTryAgain: true, operation: .add_car)
            }
        }
    }
    
    func editar() {
        
        startLoadingAnimation()
        
        REST.update(car: car) { foiEditadoComSucesso in
            
            if foiEditadoComSucesso {
                self.goBack()
            } else {
                print("-problemas ao EDITAR -> mostrar um alerta para o usuario <-")
                self.showAlert(withTitle: "Editar", withMessage: "Ocorreu um erro ao tentar Editar esse carro.", isTryAgain: true, operation: .edit_car)
            }
        }
    }
    
    
    func goBack() {
        
        DispatchQueue.main.async {
            // para garantir de executar esse código na main UI
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
        
        
        DispatchQueue.main.async {
            self.stopLoadingAnimation()
        }
        
        
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
        
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
                
                switch oper {
                    case .add_car:
                        self.salvar()
                    case .edit_car:
                        self.editar()
                    case .get_brands:
                        self.loadBrands()
                }
                
            })
            alert.addAction(tryAgainAction)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                // self.goBack()
                // A acao de cancelar é interessante deixar sem redirecinar a tela porque o usuario
                // pode querer editar algum campo que percebeu que esta errado.
            })
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
} // fim da classe



extension AddEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
        // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let brand = brands[row]
        return brand.nome
    }
    
    
        // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}
