//
//  AppCordinator.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = APODTableViewController.instantiate()
        vc.didTapAPODItem = { apod in
            self.showAPODDetail(apod)
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAPODDetail(_ apod: APOD) {
        let vc = APODDetailViewController.instantiate()
        vc.apod = apod
        navigationController.pushViewController(vc, animated: true)
    }
}
