//
//  SecondViewController.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/28.
//

import UIKit

class ThreadKeepAliveSceneViewController: UIViewController {
    
    private var threadOperator: KeepAliveThread?
    private var clickCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemYellow
        threadOperator = KeepAliveThread()
        threadOperator?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ViewController.isPresented = false
    }
    
    deinit {
        threadOperator = nil
        print("SecondViewController deinit......")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.threadOperator?.excute { [weak self] in
            guard let `self` = self else { return }
            self.clickCounter += 1
            print("execute task --> \(self.clickCounter) times")
            print("current thread ==> \(Thread.current) \n")
        }
    }
    
}
