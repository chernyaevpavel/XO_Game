//
//  GameState.swift
//  XO-game
//
//  Created by v.prusakov on 9/7/21.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation
import UIKit

protocol GameState {
    var isCompleted: Bool { get }
    
    func begin()
    
    func addMark(at position: GameboardPosition)
}

class PlayerInputGameState: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    
    init(player: Player, markPrototype: MarkView, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.player = player
        self.markPrototype = markPrototype
        self.gameboardView = gameboardView
        self.gameboard = gameboard
        self.gameViewController = gameViewController
    }
    
    func begin() {
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        guard self.gameboardView.canPlaceMarkView(at: position) else { return }
        
        recordEvent(.turnPlayer(player: self.player, position: position))
        
        self.gameboard.setPlayer(self.player, at: position)
        self.gameboardView.placeMarkView(markPrototype.copy(), at: position)
        
        self.isCompleted = true
    }
    
}

class WinnerGameState: GameState {
    
    var isCompleted: Bool = false
    
    private let winner: Player?
    private unowned let gameViewController: GameViewController?
    
    init(winner: Player?, gameViewController: GameViewController?) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    func begin() {
        self.gameViewController?.winnerLabel.isHidden = false
        
        self.gameViewController?.firstPlayerTurnLabel.isHidden = true
        self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        
        recordEvent(.gameFinished(winner: self.winner))
        
        if let winner = self.winner {
            self.gameViewController?.winnerLabel.text = self.winnerPlayerName(for: winner) + " win"
        } else {
            self.gameViewController?.winnerLabel.text = "No winner"
        }
    }
    
    func addMark(at position: GameboardPosition) { }
    
    private func winnerPlayerName(for winner: Player) -> String {
        switch winner {
        case .first: return "1st player"
        case .second: return "2nd player"
        }
    }
}
