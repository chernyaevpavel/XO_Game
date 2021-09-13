//
//  PlayerInputCommand.swift
//  XO-game
//
//  Created by Павел Черняев on 10.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol Command {
    func execute()
}

class PlayerInputCommand: Command {
    let player: Player
    let position: GameboardPosition
    private let gameboard: Gameboard
    let gameboardView: GameboardView
    private let markPrototype: MarkView
    private unowned let gameViewController: GameViewController
    
    init(player: Player, gameboardPosition: GameboardPosition, gameboard: Gameboard, gameboardView: GameboardView, markPrototype: MarkView, gameViewController: GameViewController) {
        self.player = player
        self.position = gameboardPosition
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.markPrototype = markPrototype
        self.gameViewController = gameViewController
    }
    
    func execute() {
        if !self.gameboardView.canPlaceMarkView(at: self.position) {
            self.gameboardView.removeMarkView(at: self.position)
        }
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        recordEvent(.turnPlayer(player: self.player, position: self.position))
        self.gameboard.setPlayer(self.player, at: position)
        self.gameboardView.placeMarkView(markPrototype.copy(), at: position)
    }
}

