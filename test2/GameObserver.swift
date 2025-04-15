//
//  GameObserver.swift
//  immersive office hours
//
//  Created by Patron on 4/9/25.
//


import TabletopKit
import RealityKit

class GameObserver: TabletopGame.Observer {
    let tabletop: TabletopGame
    let renderer: GameRenderer

    init(tabletop: TabletopGame, renderer: GameRenderer) {
        self.tabletop = tabletop
        self.renderer = renderer
    }

    func actionIsPending(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        // No special sounds/actions needed yet
    }

    func actionWasConfirmed(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        if let moveAction = action as? MoveEquipmentAction,
           let (card, _) = newSnapshot.equipment(of: MemoryCard.self, matching: moveAction.equipmentID) {
            print("Card \(card.id) was moved (should flip back)")
        }
/*
        if let updateAction = action as? UpdateEquipmentAction<>,
           let (card, _) = newSnapshot.equipment(of: MemoryCard.self, matching: updateAction.equipmentID),
           updateAction.setFaceUp == true {
            print("Card \(card.id) flipped face up")
        }
 */
    }

    func playerChangedSeats(_ player: Player, oldSeat: (any TableSeat)?, newSeat: (any TableSeat)?, snapshot: TableSnapshot) {
        if player.id == tabletop.localPlayer.id, newSeat == nil {
            tabletop.claimAnySeat()
        }
    }
}

