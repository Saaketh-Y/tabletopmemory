//
//  GameInteraction.swift
//  immersive office hours
//
//  Created by Patron on 4/9/25.
//

import RealityKit
import TabletopKit

import RealityKit
import TabletopKit

struct GameInteraction: TabletopInteraction.Delegate {
    let game: Game

    mutating func update(interaction: TabletopInteraction) {
        if interaction.value.phase == .started {
            onPhaseStarted(interaction: interaction)
        }

        if interaction.value.phase == .ended {
            onPhaseEnded(interaction: interaction)
        }
    }

    func onPhaseStarted(interaction: TabletopInteraction) {
        if let card = game.tabletopGame.equipment(of: MemoryCard.self, matching: interaction.value.startingEquipmentID) {
            // Mark card as flippable
            //interaction.setAllowedDestinations(.restricted([]))
            //interaction.addAction(.updateEquipment(card, faceUp: true, seatControl: .restricted([])))
        }
    }

    func onPhaseEnded(interaction: TabletopInteraction) {
        guard let card = game.tabletopGame.equipment(of: MemoryCard.self, matching: interaction.value.startingEquipmentID) else {
            return
        }

        // Always move the card back to its original position
        interaction.addAction(
            .moveEquipment(
                matching: card.id,
                childOf: .tableID,
                pose: card.initialState.pose
            )
        )
    }
}
