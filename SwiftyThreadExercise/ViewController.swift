//
//  ViewController.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/22.
//

import UIKit

class ViewController: UIViewController {

    static var isPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBlue
        
        /// NSThread exercise
//        let threadOperator = NSThreadOperator()
//        threadOperator.impliedStart()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
//            print(threadOperator.thread1?.isExecuting ?? "nil")
//        }
        
        /// CGD exercise
        let gcdOperator = GCDOperator()
//        gcdOperator.applyIterationHandler()
        gcdOperator.executeGroup()
        
        /// Operation & OperationQueue
//        let operationOperator = NSOperationOperator()
//        operationOperator.createCustomOperation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ViewController.isPresented { return }
        let secondViewController = ThreadKeepAliveSceneViewController()
        self.present(secondViewController, animated: true) {
            ViewController.isPresented = true
        }
    }
    
}

