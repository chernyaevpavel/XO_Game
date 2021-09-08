//
//  Analytics.swift
//  XO-game
//
//  Created by v.prusakov on 9/7/21.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

enum EventType {
    case turnPlayer(player: Player, position: GameboardPosition)
    case gameFinished(winner: Player?)
    case restartGame
}

class EventCommand {
    
    private var eventType: EventType
    
    init(eventType: EventType) {
        self.eventType = eventType
    }
    
    var eventMessage: String {
        switch eventType {
        case .turnPlayer(let player, let position):
            return "\(player) placed mark at \(position)"
        case .gameFinished(let winner):
            if let winner = winner {
                return "\(winner) win game"
            } else {
                return "game finished with no winner"
            }
            
        case .restartGame:
            return "game restarted"
        }
    }
}

class AnalyticsInvoker {
    
    static let shared = AnalyticsInvoker()
    
    private init() { }
    
    var batchSize = 10
    private var commands: [EventCommand] = []
    
    func addCommand(_ command: EventCommand) {
        self.commands.append(command)
        self.executeIfNeeded()
    }
    
    private func executeIfNeeded() {
        guard self.commands.count >= self.batchSize else {
            return
        }
        
        let json = self.commands.reduce("", { $0 + "\($1.eventMessage)\n"  })
        print(json)
        
        self.commands = []
    }
}

// helper func to record events to my best analytics manager
func recordEvent(_ event: EventType) {
    let command = EventCommand(eventType: event)
    AnalyticsInvoker.shared.addCommand(command)
}
