//
//  ViewController.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/22.
//

import UIKit

class ViewController: UIViewController {

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
//        let gcdOperator = GCDOperator()
//        gcdOperator.applyIterationHandler()
        
        /// Operation & OperationQueue
        let operationOperator = NSOperationOperator()
        operationOperator.createCustomOperation()
    }
    
}

