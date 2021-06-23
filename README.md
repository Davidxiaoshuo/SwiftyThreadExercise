---
title: iOS 线程使用总结 1
date: 2021-06-19 19:15:37
categories: iOS
tags: swift，Objective-C
---

> 前言：下面出现的练习 code 在 [SwiftyThreadExercise](https://github.com/Davidxiaoshuo/SwiftyThreadExercise)

### 一些基本概念

- 进程：在系统中运行的一个应用程序，每个进程间是独立的。每个进程均运行在其专有的且受保护的内存空间中。
- 线程：一个进程「程序」的所有任务都是在线程中执行的，每个进程至少有一个线程「主线程」。
- 主线程：一个 iOS 程序运行后，会默认开启一条线程，称之为“主线程” 或 "UI 线程"。主线程用来处理 UI 事件（如：点击，滚动，拖拽等事件），也是用来显示/刷新 UI 界面。
- 多线程：一个进程可以开启多条线程，多条线程可以并行「同时」执行不同的任务，多线程并发「同时」执行，其实就是 CPU 快速的在多条线程间调度「切换」。
- 同步：在当前线程，按照先后顺序执行，不开启新的线程。
- 异步：在当前线程，开启一个或多个线程，可不按照顺序执行。
- 队列：承载线程任务的一个容器。
- 并发：线程可以同时一起执行。
- 串行：线程执行顺序，只能按照先后顺序，依次执行。

### iOS 中线程实现方案

- `pthread`: 跨平台/可移植；线程生命周期需要人为管理。 ***Note: 暂不讨论, 理由：几乎用不到***
- `NSThread`: 使用面向对象；相比 `pthread` 更加直观操作线程对象；线程生命周期需要人为管理。
- `CCD`: Grand Central Dispatch, 充分利用多核，允许多任务在队列总串行或并行的执行。自动线程的生命周期。旨在替代 NSThread。
- `NSOperation`: 基于 `CGD`，比 GCD 多了一些实用功能；更加面向对象；线程生命周期需要人为管理。

#### NSThread

> NSThread 有以下几种状态：
> - 新建「创建」：进入就绪状态 -> 运行状态。 当线程任务执行完毕，自动进入死亡状态。
> - 就绪状态 runnable。
> - 强制停止线程，cancel。
> - 运行，running。
> - 阻塞状态。
> - 死亡状态。exit, 一旦线程停止「死亡」，就不能再次开启任务了。

```swift

/// NSThread 启动方式

/// 动态启动，创建之后需要手动调用 start 方法
let thread1 = Thread(target: self, selector: #selector(onThreadRun), object: nil)
thread1.start()

/// 静态启动，创建之后自动启动线程。
/// ①：通过 selector 方式实现
Thread.detachNewThreadSelector(#selector(onThreadRun), toTarget: self, with: nil)

/// ②：通过 block 方式实现
Thread.detachNewThread { }

/// 隐式开启，`performSelector` 是 NSThread 针对 NSObject 的一个扩展方法。
/// ①：开启一个后台线程执行
self.performSelector(inBackground: #selector(onThreadRun), with: nil)
/// ②：在主线程执行
self.performSelector(onMainThread: #selector(onThreadRun), with: nil, waitUntilDone: false)
/// ③：在指定线程执行
self.perform(#selector(onThreadRun), on: thread, with: nil, waitUntilDone: true)

/// NSThread 中常用的方法

/// 获取当前线程
let currentThread = Thread.current

/// 获取主线程
let mainThread= Thread.main

/// 是否为主线程
let isMainThread = Thread.isMainThread

/// 线程是否在运行中
Thread.current.isExecuting

/// 退出线程
Thread.exit()

```

#### GCD

> GCD 全称 Grand Central Dispatch, 其有如下优势：
> - 多核并行运算的解决方案
> - 自动利用更多的 CPU 内核（如双核、四核）
> - 自动管理线程的生命周期
> - 程序员只需要告诉 GCD 想要执行什么任务，不需要编写任何线程管理代码

![](https://camo.githubusercontent.com/12f06e73fb26ab70b3caf2021ba8087e8f0186ef57190767355cd3d3ba6bfaa9/68747470733a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f313637383133352d343835663938643131366235373430392e6a70673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

##### 任务 & 队列

- 任务，就是要执行指定需求的代码块。它有两种执行方式：
    - 同步执行「sync」: 在当前线程执行任务，不会开启新的线程，必须等到任务执行完毕，dispatch 才会返回，才可以继续往下执行。
    - 异步执行「async」： 可以在新的线程中执行任务「不一定会开启新的线程」。dispatch 会立即返回，继续往下执行，任务代码块在后台异步执行。

- 队列，任务的管理方式。分为串行对列 & 并行队列两种，都是按照 FIFO 「先进先出」原则依次触发任务。
    - 串行队列，所有任务都在同一个线程中执行，一个任务执行完毕后，才开始执行下一个任务。
    - 并行队列，可以在多条线程执行任务，当一个任务放到指定的线程开始执行时，下一个任务就可以开始执行了。

- 队列有以下几种类型：
    - 同步并发：没有开启新线程，串行执行任务
    - 同步串行：没有开启新线程，串行执行任务
    - 同步主队列：没有开启新线程，串行执行任务
    - 异步并发：开启新线程，并发执行任务
    - 异步串行：开启新线程，串行执行任务
    - 异步主队列：没有开启新线程，串行执行任务

##### 特有队列

```swift

/// DispatchQueue.main 特殊串行主队列，无论是同步「sync」还是异步「async」，都是执行在主线程，async 虽然不阻塞主线程，但由于在一个队列上，DispatchQueue.main 只有在执行完当前任务后，才会执行下一个任务「async」。
/// Note: 一定要在主线程执行和 UI 有关的操作。

/// 异步主队列，串行执行任务，不阻塞当前线程
DispatchQueue.main.async { }

/// 同步主队列，串行执行任务，阻塞当前线程。嵌套 sync {} ，可能会导致死锁。
DispatchQueue.main.sync { }


/// DispatchQueue.global(), 全局并发队列, 全局只有一个。

/// 异步全局队列, 串行执行任务，不阻塞当前线程
DispatchQueue.global().async { }

/// 同步全局队列，串行执行任务，阻塞当前线程。
DispatchQueue.global().sync { }

```

##### 串行队列

```swift
/// 同步：
/// 默认即是串行队列
let queue = DispatchQueue(label: "ai.studio.david.queue.1")

print("queue execute before, current thread = \(Thread.current)")

queue.sync {
    (0...5).forEach {
        print("index = \($0), current thread = \(Thread.current)")
    }
}

queue.sync {
    (0...5).forEach {
        print("index = \($0), current thread = \(Thread.current)")
    }
}

print("queue execute after, current thread = \(Thread.current)")

// queue execute before, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 0, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 1, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 2, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 3, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 4, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 1, index = 5, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 0, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 1, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 2, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 3, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 4, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue 2,index = 5, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}
// queue execute after, current thread = <NSThread: 0x600000b6c600>{number = 1, name = main}

/// 分析：
/// `sync`,同步执行，阻塞当前线程。
/// 结果按照顺序一个一个执行，同步执行会一直等待，等一个任务执行在执行下一个任务。
/// 注意：主线程中的 `before` & `after` 两个打印，线程信息结果跟串行队列中的是相同的。这说明，队列中的同步任务在执行时，系统给他们分配的线程是主线程。


/// 异步：
/// 默认即是串行队列
let queue = DispatchQueue(label: "ai.studio.david.queue.1")

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

// queue execute before, current thread = <NSThread: 0x600003cbc540>{number = 1, name = main}
// queue execute after, current thread = <NSThread: 0x600003cbc540>{number = 1, name = main}
// queue 1, index = 0, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 1, index = 1, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 1, index = 2, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 1, index = 3, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 1, index = 4, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 1, index = 5, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 0, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 1, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 2, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 3, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 4, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}
// queue 2,index = 5, current thread = <NSThread: 0x600003cb2380>{number = 5, name = (null)}

/// 分析：`async`, 异步不阻塞当前线程
/// 由于是串行队列，任务按照 FIFO 原则，依次执行。
/// Note: 创建队列时的 `label` 参数，不等同于 NSThread 中的 name 属性，`label` 用于在调试工具(如Instruments、样本、stackshots和崩溃报告)中惟一地标识队列。命名风格采用反向 DNS 命名风格(com.example.myqueue)。

```

##### 并发队列

```swift

/// 同步，并发队列

let queue = DispatchQueue(label: defaultQueueLabel, attributes: .concurrent)

print("queue execute before, current thread = \(Thread.current)")

queue.sync {
    (0...5).forEach {
        print("queue 1, index = \($0), current thread = \(Thread.current)")
    }
}

print("queue execute middle, current thread = \(Thread.current)")

queue.sync {
    (0...5).forEach {
        print("queue 2,index = \($0), current thread = \(Thread.current)")
    }
}

print("queue execute after, current thread = \(Thread.current)")


// queue execute before, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 0, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 1, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 2, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 3, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 4, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 1, index = 5, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue execute middle, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 0, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 1, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 2, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 3, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 4, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue 2,index = 5, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}
// queue execute after, current thread = <NSThread: 0x60000315c340>{number = 1, name = main}

/// 分析：
/// 并发队列执行同步任务和在主线程执行操作没有区别。`sync` 会将当前线程固定住，让当前线程等待执行完成后才能执行后面的任务。


/// 异步，并发队列

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

 
// queue execute before, current thread = <NSThread: 0x600000e80540>{number = 1, name = main}
// index = 0, current thread = <NSThread: 0x600000e80540>{number = 1, name = main}
// ···
// index = 999, current thread = <NSThread: 0x600000e80540>{number = 1, name = main}
// task1, current thread = <NSThread: 0x6000002e10c0>{number = 7, name = (null)}
// queue execute after, current thread = <NSThread: 0x600000e80540>{number = 1, name = main}
// task2, current thread = <NSThread: 0x6000002fc300>{number = 6, name = (null)}
// task3, current thread = <NSThread: 0x6000002e02c0>{number = 8, name = (null)}
// task5, current thread = <NSThread: 0x6000002e10c0>{number = 7, name = (null)}
// task4, current thread = <NSThread: 0x6000002a9480>{number = 5, name = (null)}

/// 分析：
/// 异步并发队列，不阻塞当前线程. 异步任务是否开启线程，根据系统资源和任务完成时间决定是否重用线程。
/// 虽然异步并发队列不阻塞当前线程，但是异步队列任务开始执行有可能会优先于当前线程的任务执行。

```

##### 其他方法

```swift

/// 延迟执行

/// 当前线程延迟 2s 后执行任务
self.perform(#selector(onDelayHandler), with: nil, afterDelay: 2)

/// 主线程延迟 2s 后执行任务
DispatchQueue.main.asyncAfter(deadline: .now() + 2) { }

/// 全局队列延迟 2s 后执行任务
DispatchQueue.global().asyncAfter(deadline: .now() + 2) { }

/// 通过 timer 延迟 2s 后执行任务
Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(onDelayHandler), userInfo: nil, repeats: false)

/// 快速迭代遍历，阻塞当前线程，index 是无序的
DispatchQueue.concurrentPerform(iterations: 10) { index in }

```

#### NSOperation & NSOperationQueue

> - NSOperation & NSOperationQueue 是苹果对 GCD 的封装
> - NSOperation & NSOperationQueue 分别相当于 GCD 的任务和队列
> - NSOperation 是一个抽象类，可以使用其子类 `BlockOperation`, 当然也可以自定义子类
> - NSOperationQueue 支持 `暂停`、`恢复`、`取消`操作。这些操作，都是对后面未执行的任务进行操作，不会影响当前正在进行的任务，且 `取消` 不可以恢复。

##### NSOperation 实现多线程步骤

- 创建操作：先将需要执行的操作封装到一个 NSOperation 对象中。
- 创建队列：创建 NSOperationQueue 对象。
- 将操作加入到队列中：将 NSOperation 对象添加到NSOperationQueue 对象中。
- 之后，系统就会自动将 NSOperationQueue 中的 NSOperation 取出来，在新线程中执行操作。

##### BlockOperation 的使用

```swift

let blockOperation = BlockOperation {
    print("operation1, block1, current thread = \(Thread.current)")
}

blockOperation.start()

// operation1, block1, current thread = <NSThread: 0x600003e303c0>{number = 1, name = main}

/// 分析：
/// 在仅使用 BlockOperation，不将其加入到 OperationQueue 时，block 可能会直接当前线程运行，是否开启新的线程，由系统资源决定。

// -----------------------------------------------------------------------------------------------------

/// BlockOperation 还提供了 addExecutionBlock 的方法

let blockOperation = BlockOperation {
    print("operation1, block1, current thread = \(Thread.current)")
}

blockOperation.addExecutionBlock {
    print("operation1, block2, current thread = \(Thread.current)")
}

blockOperation.addExecutionBlock {
    print("operation1, block3, current thread = \(Thread.current)")
}

blockOperation.start()

// operation1, block1, current thread = <NSThread: 0x6000034a0680>{number = 1, name = main}
// operation1, block2, current thread = <NSThread: 0x6000034ad2c0>{number = 6, name = (null)}
// operation1, block5, current thread = <NSThread: 0x6000034a84c0>{number = 5, name = (null)}
// operation1, block3, current thread = <NSThread: 0x6000034fc0c0>{number = 7, name = (null)}
// operation1, block4, current thread = <NSThread: 0x6000034ad2c0>{number = 6, name = (null)}

/// 分析：
/// addExecutionBlock 添加的任务，是否开启新线程，由系统决定，每次执行结果可能不太一样。
/// 任务的执行顺序也是不确定的

```

##### NSOperation 自定义子类

> 可以通过实现 main 方法来自定义实现一个 NSOperation 的子类。

```swift

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

```

##### NSOperationQueue

NSOperationQueue 有两种队列形式：主队列 & 自定义队列

- 主队列：凡是添加到主队列中的操作，都会放到主线程中执行
- 自定义队列：操作自动放到子线程中执行，同时包含了：串行、并发功能。

```swift

let mainQueue = OperationQueue.main

let customQueue = OperationQueue()

```

添加任务到队列中

```swift

let operationQueue = OperationQueue()
/// 最大并发数，它有默认最大并发，其值根据当前系统换件决定。
/// 当 maxConcurrentOperationCount = 1 时，是串行，
operationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount

let blockOperation = BlockOperation {
    print("operation1, block1, current thread = \(Thread.current)")
}

operationQueue.addOperation(blockOperation)

/// 分析：
/// 将 BlockOperation 添加到 OperationQueue 中后，系统将不在当前线程执行，而是开启新的线程

// -----------------------------------------------------------------------------------------------------

/// 通过 addDependency 设置依赖关系，保证执行顺序
blockOperation.addDependency(blockOperation2)
operationQueue.addOperation(blockOperation)
operationQueue.addOperation(blockOperation2)

/// 分析：先执行 blockOperation2，再执行 blockOperation

```