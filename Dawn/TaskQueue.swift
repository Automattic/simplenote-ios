//
//  TaskQueue.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 01/09/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


class TaskQueue {
    private let taskQueueActor = TaskQueueActor()

    func dispatch(block: @escaping () async -> Void){
        Task {
            await taskQueueActor.addBlock(block: block)
        }
    }
}


private actor TaskQueueActor {
    private var blocks: [() async -> Void] = []
    private var currentTask: Task<Void,Never>? = nil

    func addBlock(block:@escaping () async -> Void){
        blocks.append(block)
        next()
    }

    func next() {
        if currentTask != nil {
            return
        }

        if blocks.isEmpty {
            return
        }

        let block = blocks.removeFirst()
        currentTask = Task {
            await block()
            currentTask = nil
            next()
        }
    }
}
