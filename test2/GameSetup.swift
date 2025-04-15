//
//  GameSetup.swift
//  immersive office hours
//
//  Created by Patron on 4/9/25.
//
import RealityFoundation
import TabletopKit
import SwiftUI
import RealityKit
import Spatial

enum GameMetrics {
    static let tableEdge: Float = 0.7
    static let tableThickness: Float = 0.025
    static let playerAreaDistanceFromCenter: Float = 0.29
    static let boardEdge: Float = 0.4
    static let smallHeight: Float = 0.001
    static let boardHeight: Float = 0.055
    static let playerAreaSize: SIMD2<Float> = SIMD2(0.4, 0.1)
    static let playerHandSize: SIMD2<Float> = SIMD2(0.2, 0.1)
    static let radius: Float = 0.35
    static let cardWidth: Float = 0.06
    static let cardHeight: Float = 0.09
    static let cardSpacing: Float = 0.07
}

@MainActor
class GameSetup {
    let root: Entity
    var setup: TableSetup
    var seats: [PlayerSeat] = []
    var memoryGameBoard: MemoryGameBoard?

    // This is an incrementing counter to generate unique IDs for each piece of equipment.
    struct IdentifierGenerator {
        private var count = 0

        mutating func newId() -> Int {
            count += 1
            return count
        }
    }
    var idGenerator = IdentifierGenerator()

    init(root: Entity) {
        self.root = root
        setup = TableSetup(tabletop: Table())

        let blockWidth: Double = 0.04
        /*
        // Optional: Code to add blocks can be uncommented if needed.
        for index in 0..<30 {
            let orientation: Float
            if (index / 3) % 2 == 0 {
                orientation = 0
            } else {
                orientation = Float.pi / 2
            }
            let row = index / 3
            let x: Double
            let z: Double

            if row % 2 == 0 {
                x = Double(index % 3) * blockWidth
                z = 0
            } else {
                x = blockWidth
                z = (Double(index % 3) * blockWidth) - blockWidth
            }
            let blockPosition = TableVisualState.Point2D(x: x, z: z)
            let block = Block(index: self.idGenerator.newId(), position: blockPosition, orientation: orientation)
            setup.add(equipment: block)
        }
        */
        
        // Adding player seats
        for (index, pose) in PlayerSeat.seatPoses.enumerated() {
            let seat = PlayerSeat(id: TableSeatIdentifier(index), pose: pose)
            seats.append(seat)
            setup.add(seat: seat)
        }
        setupMemoryGame()
    }
    
    func setupMemoryGame() {
            // Configure the board grid; for example, a 4x4 grid with 0.15 meters spacing.
            let board = MemoryGameBoard(id: EquipmentIdentifier(2000),
                                        rows: 4,
                                        columns: 4,
                                        cardSpacing: 0.1)
            self.memoryGameBoard = board
            
            // Add each card's entity as a child of the table entity
            // so that they are positioned relative to the table.
            for card in board.cards {
                setup.add(equipment: card)
            }
        }

}

extension Game {
    @MainActor
    func resetGame() {
        print("Reset game logic TODO")
    }
}

