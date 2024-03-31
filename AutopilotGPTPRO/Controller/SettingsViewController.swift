//
//  SettingsViewController.swift
//  AutopilotGPTPRO
//
//  Created by Sergey on 3/29/24.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func setup() {
        
        view.backgroundColor = .systemBackground
        let screenTitle = ScreenTitleLabel(withText: "Settings")
        
        view.addSubview(screenTitle)
        screenTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        screenTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
    }
    
}

extension SettingsViewController: TabBarDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        setup()
    }
    
    
}
