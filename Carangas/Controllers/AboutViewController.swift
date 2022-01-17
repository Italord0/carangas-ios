//
//  AboutViewController.swift
//  Carangas
//
//  Created by Aluno on 28/12/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import UIKit
import SideMenu

class AboutViewController: UIViewController {

    @IBOutlet weak var lbDevInfo: UILabel!
    @IBOutlet weak var lbAppInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        // Updated
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: SideMenuManager.PresentDirection.left)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        lbAppInfo.text = appVersion
        lbDevInfo.text = "Aluno : Italo Melo"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
