//
//  OnboardingViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 28/08/22.
//

import UIKit

class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var myControllers = [UIViewController]()
    var noBucleVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
    }
    
    func configureVC() {
        let vc  = PageOneViewController()
        myControllers.append(vc)
        
        let vc1  = PageTwoViewController()
        myControllers.append(vc1)
        
        let vc2  = PageThreeViewController()
        myControllers.append(vc2)
        vc2.setDelegateTo(delegate: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !noBucleVC {
            noBucleVC = true
            self.presentPageVC()
        }
    }
    
    func presentPageVC() {
        guard let first = myControllers.first else {
            return
        }
        
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        vc.delegate = self
        vc.dataSource = self
        vc.setViewControllers([first], direction: .forward, animated: true, completion: nil)
                
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = myControllers.firstIndex(of: viewController),
                index > 0 else {
            return nil
        }
        
        let before = index - 1
        
        return myControllers[before]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = myControllers.firstIndex(of: viewController),
              index < (myControllers.count - 1) else {
            return nil
        }
        
        let after = index + 1
        
        return myControllers[after]
    }
}

extension OnboardingViewController: Dismiss {
    func dismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
