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
        if self.gameViewController.gameMode == .versusPC && player == .second { return }
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
    private let gameMode: GameMode
    
    init(winner: Player?, gameViewController: GameViewController?, gameMode: GameMode) {
        self.winner = winner
        self.gameViewController = gameViewController
        self.gameMode = gameMode
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
        case .second:
            var playerName: String
            switch self.gameMode {
            case .twoPlayers, .twoPlaersFiveMoves:
                playerName = "2nd player"
            case .versusPC:
                playerName = "PC"
            }
            return playerName
        }
    }
}

class PCInputGameState: GameState {
    
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
        guard let position = self.gameboard.getFreePositionIfNeeded() else { return }
        self.addMark(at: position)
    }
    
    func addMark(at position: GameboardPosition) {
        guard self.gameboardView.canPlaceMarkView(at: position) else { return }
        recordEvent(.turnPlayer(player: self.player, position: position))
        self.gameboard.setPlayer(self.player, at: position)
        self.gameboardView.placeMarkView(markPrototype.copy(), at: position)
        self.isCompleted = true
    }
}


class PlayerInputFiveMove: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    private let gameboardInvoker: GameboardInvoker
    private static let maxCountMove = 5
    private var currentCountMove = 0
    
    init(player: Player, markPrototype: MarkView, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, gameboardInvoker: GameboardInvoker) {
        self.player = player
        self.markPrototype = markPrototype
        self.gameboardView = gameboardView
        self.gameboard = gameboard
        self.gameViewController = gameViewController
        self.gameboardInvoker = gameboardInvoker
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
        let command = PlayerInputCommand(
            player: self.player,
            gameboardPosition: position,
            gameboard: self.gameboard,
            gameboardView: self.gameboardView,
            markPrototype: self.player.markViewPrototype,
            gameViewController: self.gameViewController)
        self.gameboardInvoker.addCommand(command: command)
        currentCountMove += 1
        if currentCountMove == Self.maxCountMove {
            self.isCompleted = true
        }
    }
}

class ExecutionGameFiveMove: GameState {
    var isCompleted: Bool = false
    private let gameboardInvoker: GameboardInvoker
    private unowned let gameViewController: GameViewController
    
    init(gameboardInvoker: GameboardInvoker, gameViewController: GameViewController) {
        self.gameboardInvoker = gameboardInvoker
        self.gameViewController = gameViewController
    }
    
    func begin() {
        self.gameboardInvoker.work {
            self.isCompleted = true
            self.gameViewController.checkWinner()
        }
    }
    
    func addMark(at position: GameboardPosition) { }
}
