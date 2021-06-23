//
//  GCDOperator.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/23.
//

import UIKit

class GCDOperator: NSObject {

    private let defaultQueueLabel: String = "ai.studio.david.queue.1"
    
    func executeDispatchQueueOnMain() {
        print("main dispatch queue before......")
        var isRunning: Bool = true
        var autoincrement = 0
        DispatchQueue.main.async {
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
        print("main dispatch queue after......")
    }
    
    func executeDispatchQueueOnGlobal() {
        print("global dispatch queue before......")
        DispatchQueue.global().async {
            print("global async start \(Thread.current)")
            DispatchQueue.global().sync {
                (0..<5).forEach {
                    print("roop\($0) \(Thread.current)")
                    Thread.sleep(forTimeInterval: 0.2)
                }
            }
            print("global async end \(Thread.current)")
        }
        print("global dispatch queue after......")
    }
    
    func executeDispatchQueueInSerialSync() {
        /// 默认即是串行队列
        let queue = DispatchQueue(label: defaultQueueLabel)
        
        print("queue execute before, current thread = \(Thread.current)")
        
        queue.sync {
            (0...5).forEach {
                print("queue 1, index = \($0), current thread = \(Thread.current)")
            }
        }
        
        queue.sync {
            (0...5).forEach {
                print("queue 2,index = \($0), current thread = \(Thread.current)")
            }
        }
        
        print("queue execute after, current thread = \(Thread.current)")
    }
    
    func executeDispatchQueueInSerialAsync() {
        
        /// 默认即是串行队列
        let queue = DispatchQueue(label: defaultQueueLabel)
        
        print("queue execute before, current thread = \(Thread.current)")
        
        queue.async {
            (0...5).forEach {
                print("queue 1, index = \($0), current thread = \(Thread.current)")
            }
        }
        
        queue.async {
            (0...5).forEach {
                print("queue 2,index = \($0), current thread = \(Thread.current)")
            }
        }
        
        print("queue execute after, current thread = \(Thread.current)")
    }
    
    func executeDispatchQueueInConcurrentSync() {
        let queue = DispatchQueue(label: defaultQueueLabel, attributes: .concurrent)
        
        print("queue execute before, current thread = \(Thread.current)")
        
        queue.sync {
            (0...5).forEach {
                print("queue 1, index = \($0), current thread = \(Thread.current)")
                Thread.sleep(forTimeInterval: 0.2)
            }
        }
        
        print("queue execute middle, current thread = \(Thread.current)")
        
        queue.sync {
            (0...5).forEach {
                print("queue 2,index = \($0), current thread = \(Thread.current)")
            }
        }
        
        print("queue execute after, current thread = \(Thread.current)")
        
    }
    
    func executeDispatchQueueInConcurrentAsync() {
        
        let queue = DispatchQueue(label: defaultQueueLabel, attributes: .concurrent)
        
        print("queue execute before, current thread = \(Thread.current)")
        (0..<1000).forEach {
            print("index = \($0), current thread = \(Thread.current)")
        }
        
        queue.async { print("task1, current thread = \(Thread.current)") }
        queue.async { print("task2, current thread = \(Thread.current)") }
        queue.async { print("task3, current thread = \(Thread.current)") }
        queue.async { print("task4, current thread = \(Thread.current)") }
        queue.async { print("task5, current thread = \(Thread.current)") }
        
        print("queue execute after, current thread = \(Thread.current)")
    }
    
    func delayExecute() {
        print(Date.timestamp)
        print("execute before...")
//        self.perform(#selector(onDelayHandler), with: nil, afterDelay: 2)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            print("current thread = \(Thread.current)")
//            print(Date.timestamp)
//        }
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            print("current thread = \(Thread.current)")
//            print(Date.timestamp)
//        }
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(onDelayHandler), userInfo: nil, repeats: true)
        
        print("execute after...")
    }
    
    @objc func onDelayHandler() {
        print("current thread = \(Thread.current)")
        print(Date.timestamp)
    }
    
    func applyIterationHandler(){
        print("execute before...")
        DispatchQueue.concurrentPerform(iterations: 10) { index in
            print("current thread = \(Thread.current)")
            print("index = \(index)")
            print("concurrentPerform....")
        }
        print("execute after...")
    }
    
}

extension Date {

    static var timestamp: Int {
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        return Int(timeInterval)
    }
    
}
