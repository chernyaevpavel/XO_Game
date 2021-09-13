//
//  StartViewController.swift
//  XO-game
//
//  Created by Павел Черняев on 08.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifiere = segue.identifier else { return }
        var gameMode: GameMode
        switch identifiere {
        case "TwoPlayers":
            gameMode = .twoPlayers
        case "VersusPC":
            gameMode = .versusPC
        case "TwoPlaersFiveMoves":
            gameMode = .twoPlaersFiveMoves
        default:
            return
        }
        if let destinationVC = segue.destination as? GameViewController {
            destinationVC.gameMode = gameMode
        }
    }


}
