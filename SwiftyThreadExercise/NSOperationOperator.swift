//
//  NSOperationOperator.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/23.
//

import UIKit
import Foundation

class NSOperationOperator: NSObject {
    
    func createBlockOperation() {
        
        let blockOperation = BlockOperation {
            print("operation1, block1, current thread = \(Thread.current)")
        }
        
        blockOperation.addExecutionBlock {
            print("operation1, block2, current thread = \(Thread.current)")
        }
        
        blockOperation.addExecutionBlock {
            print("operation1, block3, current thread = \(Thread.current)")
        }

        blockOperation.addExecutionBlock {
            print("operation1, block4, current thread = \(Thread.current)")
        }

        blockOperation.addExecutionBlock {
            print("operation1, block5, current thread = \(Thread.current)")
        }
        
        blockOperation.start()
    }
    
    func createBlockOperationQueue() {
        let operationQueue = OperationQueue()
        /// 最大并发数，不能为0 ，它有默认最大并发，其值根据当前系统换件决定。
        ///
        operationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        let blockOperation = BlockOperation {
            print("operation1, block1, current thread = \(Thread.current)")
        }
        
        operationQueue.addOperation(blockOperation)
    }
    
    func creatBlockOperationQueueWithDependency() {
        let operationQueue = OperationQueue()
        /// 最大并发数，不能为0 ，它有默认最大并发，其值根据当前系统换件决定。
        ///
        operationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        let blockOperation = BlockOperation {
            print("operation1, block1, current thread = \(Thread.current)")
        }
        blockOperation.addExecutionBlock {
            print("operation1, block2, current thread = \(Thread.current)")
        }
        blockOperation.addExecutionBlock {
            print("operation1, block3, current thread = \(Thread.current)")
        }
        blockOperation.addExecutionBlock {
            print("operation1, block4, current thread = \(Thread.current)")
        }
        blockOperation.addExecutionBlock {
            print("operation1, block5, current thread = \(Thread.current)")
        }
        
        let blockOperation2 = BlockOperation {
            print("operation2, block1, current thread = \(Thread.current)")
        }
        blockOperation2.addExecutionBlock {
            print("operation2, block2, current thread = \(Thread.current)")
        }
        blockOperation2.addExecutionBlock {
            print("operation2, block3, current thread = \(Thread.current)")
        }
        
        blockOperation.addDependency(blockOperation2)
        operationQueue.addOperation(blockOperation)
        operationQueue.addOperation(blockOperation2)
    }
    
    func createCustomOperation() {
        let operation = CustomOperation()
        operation.start()
    }

}

class CustomOperation: Operation {
    
    override func main() {
        var isRunning = true
        var autoincrement: Int = 0
        while isRunning {
            
            if isCancelled {
                isRunning = false
                break
            }
            
            if autoincrement >= 100 {
                isRunning = false
                break
            }
            print("current value = \(autoincrement), current thread = \(Thread.current)")
            autoincrement += 1
        }
    }
}
