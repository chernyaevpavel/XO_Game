//
//  GameboardInvoker.swift
//  XO-game
//
//  Created by Павел Черняев on 10.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class GameboardInvoker {
    private var commands: [PlayerInputCommand] = []
    
    func addCommand(command: PlayerInputCommand) {
        self.commands.append(command)
    }
    
    func work(completion: @escaping () -> ()) {
        let commandsFirstPlayer = commands.filter { $0.player == .first }
        let commandsSecondPlayer = commands.filter { $0.player == . second }
        self.commands = []
        for i in 0...4 {
            commands.append(commandsFirstPlayer[i])
            commands.append(commandsSecondPlayer[i])
        }
        var dispatchTime: Double = 1
        self.commands.forEach { command in
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTime ) {
                command.execute()
                if self.commands.last! === command {
                    completion()
                }
            }
            dispatchTime += 1
        }
    }
    
    func clearCommands() {
        self.commands = []
    }
}

