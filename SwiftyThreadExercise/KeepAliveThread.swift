//
//  ThreadKeepAliveOperator.swift
//  SwiftyThreadExercise
//
//  Created by David硕 on 2021/6/26.
//

import UIKit

typealias KeepAliveThreadTask = () -> Void

class KeepAliveThread: NSObject {
    
    private var thread: Thread?
    private(set) var isStoped: Bool = true
    private var task: KeepAliveThreadTask?
    
    override init() {
        super.init()
        thread = Thread { [weak self] in
            RunLoop.current.add(Port(), forMode: RunLoop.Mode.default)
            while !(self?.isStoped ?? true) {
                RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
            }
        }
    }
    
    deinit {
        self.stop()
        print("keep alive thread deinit......")
    }

    func start() {
        guard let thread = self.thread, isStoped else { return }
        isStoped = false
        thread.name = "ai.studio.david.thread.runloop.keep.alive"
        thread.start()
    }
    
    func excute(task: @escaping KeepAliveThreadTask) {
        guard let thread = self.thread else { return }
        self.task = task
        self.perform(#selector(onExecutedTask), on: thread, with: nil, waitUntilDone: false)
    }
    
    func stop() {
        guard let thread = self.thread else { return }
        self.perform(#selector(onStopTask), on: thread, with: nil, waitUntilDone: true)
    }
    
    @objc private func onExecutedTask() {
        self.task?()
    }
    
    @objc private func onStopTask() {
        guard nil != thread else { return }
        self.isStoped = true
        CFRunLoopStop(CFRunLoopGetCurrent())
        thread = nil
    }

}
