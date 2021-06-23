//
//  NSThreadExercise.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/22.
//

import UIKit
import Foundation

class NSThreadOperator: NSObject {
    
    private let defaultThreadName: String = "ai.david.studio.thread.1"
    
    var thread1: Thread?

    override init() {
        super.init()
    }
    
    func dynamicStart() {
        thread1 = Thread(target: self, selector: #selector(onThreadRun), object: nil)
        thread1?.name = defaultThreadName
        thread1?.start()
    }
    
    func quietStart() {
        // ① selector 方式
//        Thread.detachNewThreadSelector(#selector(onThreadEvent), toTarget: self, with: nil)
        
        // ② block 方式
        Thread.detachNewThread {
            self.onThreadRun()
        }
    }
    
    func impliedStart() {
        // ① 开启一个后台线程执行
        self.performSelector(inBackground: #selector(onThreadRun), with: nil)
        
        // ② 在主线程执行
//        self.performSelector(onMainThread: #selector(onThreadRun), with: nil, waitUntilDone: false)
        
        // ③ 指定一个线程执行
//        DispatchQueue.global().async {
//            self.perform(#selector(self.onThreadRun), on: Thread.current, with: nil, waitUntilDone: true)
//        }
    }
    
    @objc func onThreadRun() {
        let currentThread = Thread.current
        currentThread.name = defaultThreadName
        print(currentThread)
        thread1 = currentThread
        
        let mainThread = Thread.main
        print(mainThread)
        
        let isMainThread = Thread.isMainThread
        print("is main thread = \(isMainThread)")
        
        var isRunning: Bool = true
        var autoincrement = 0
        while isRunning {
            if autoincrement > 100 {
                isRunning = false
                break
            }
            print("current value = \(autoincrement)")
            autoincrement += 1
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
}
