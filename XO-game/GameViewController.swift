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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    // MARK: - Game state
    
    private func goToFirstState() {
        let player = Player.first
        
        self.currentState = PlayerInputGameState(
            player: player,
            markPrototype: player.markViewPrototype,
            gameViewController: self,
            gameboard: self.gameboard,
            gameboardView: self.gameboardView
        )
    }
    
    private func goToNextState() {
        if let winner = self.referee.determineWinner() {
            self.currentState = WinnerGameState(winner: winner, gameViewController: self)
            return
        }
        
        if let playerInputState = self.currentState as? PlayerInputGameState {
            let nextPlayer = playerInputState.player.next
            self.currentState = PlayerInputGameState(
                player: nextPlayer,
                markPrototype: nextPlayer.markViewPrototype,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView
            )
        }
    }
}

