//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    private lazy var referee = Referee(gameboard: self.gameboard)
    private let gameboard = Gameboard()
    private var currentState: GameState! {
        didSet {
            self.currentState.begin()
        }
    }
    var gameMode: GameMode?
    private lazy var gameboardInvoker = GameboardInvoker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gameMode = self.gameMode, gameMode == .versusPC {
            secondPlayerTurnLabel.text = "PC"
        }
        self.goToFirstState()
        
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isCompleted {
                self.goToNextState()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.gameboardView.clear()
        self.gameboard.clear()
        self.goToFirstState()
        recordEvent(.restartGame)
        
        if let gameMode = self.gameMode, gameMode == .twoPlaersFiveMoves {
            self.gameboardInvoker.clearCommands()
        }
    }
    
    // MARK: - Game state
    
    private func goToFirstState() {
        let player = Player.first
        guard let gameMode = self.gameMode else { return }
        switch gameMode {
        case .twoPlayers, .versusPC:
            self.currentState = PlayerInputGameState(
                player: player,
                markPrototype: player.markViewPrototype,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView
            )
        case .twoPlaersFiveMoves:
            self.currentState = PlayerInputFiveMove(
                player: player,
                markPrototype: player.markViewPrototype,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView,
                gameboardInvoker: self.gameboardInvoker)
        }
        
    }
    
    func checkWinner() -> Bool {
        guard let gameMode = self.gameMode else { return false}
        if gameMode == .twoPlaersFiveMoves && ((self.currentState as? PlayerInputFiveMove) != nil) {
            return false
        }
        if let winner = self.referee.determineWinner() {
            self.currentState = WinnerGameState(winner: winner, gameViewController: self, gameMode: gameMode)
            return true
        }
        return false
    }
    
    private func goToNextState() {
        guard let gameMode = self.gameMode else { return }
        if checkWinner() { return }
        var nextPlayer: Player?
        if let playerInputState = self.currentState as? PlayerInputGameState {
            nextPlayer = playerInputState.player.next
        }
        if let pcInputState = self.currentState as? PCInputGameState {
            nextPlayer = pcInputState.player.next
        }
        if let playerInputFiveMove = self.currentState as? PlayerInputFiveMove {
            nextPlayer = playerInputFiveMove.player.next
        }
        guard var nextPlayer = nextPlayer else { return }
        
        switch gameMode {
        case .versusPC:
            if nextPlayer == .second {
                self.currentState = PCInputGameState(
                    player: nextPlayer,
                    markPrototype: nextPlayer.markViewPrototype,
                    gameViewController: self,
                    gameboard: self.gameboard,
                    gameboardView: self.gameboardView)
                if checkWinner() { return }
                nextPlayer = nextPlayer.next
            }
            fallthrough
        case .twoPlayers:
            self.currentState = PlayerInputGameState(
                player: nextPlayer,
                markPrototype: nextPlayer.markViewPrototype,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView
            )
        case .twoPlaersFiveMoves:
            self.gameboardView.clear()
            self.gameboard.clear()
            if nextPlayer == .first {
                self.currentState = ExecutionGameFiveMove(gameboardInvoker: self.gameboardInvoker, gameViewController: self)
                checkWinner()
                return
            }
            self.currentState = PlayerInputFiveMove(
                player: nextPlayer,
                markPrototype: nextPlayer.markViewPrototype,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView,
                gameboardInvoker: self.gameboardInvoker)
        }
    }
}

