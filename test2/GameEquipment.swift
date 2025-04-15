//
//  GameEquipment.swift
//  immersive office hours
//
//  Created by Patron on 4/9/25.
//
import TabletopKit
import RealityKit
import Spatial
import TabletopGameSampleContent


extension EquipmentIdentifier {
    static var tableID: Self { .init(0) }
}

struct Table: EntityTabletop {
    
    var shape: TabletopShape
    var entity: Entity
    var id: EquipmentIdentifier

    init() {
        // Define rectangular dimensions for the table.
        let width: Float = 0.6     // x-axis (long side)
        let height: Float = 0.4    // z-axis (short side)
        let thickness: Float = 0.05

        let tableMesh = MeshResource.generateBox(size: [width, thickness, height])
        let tableMaterial = SimpleMaterial(color: .brown, isMetallic: false)
        let newTableEntity = ModelEntity(mesh: tableMesh, materials: [tableMaterial])
        newTableEntity.name = "table"
        newTableEntity.position.y = thickness / 2 // Ensure the table rests on the ground

        self.entity = newTableEntity
        self.shape = .rectangular(entity: newTableEntity)
        self.id = .tableID
    }
    
}

struct Block: EntityEquipment {
   var id: EquipmentIdentifier
   var entity: Entity
   var initialState: BaseEquipmentState

   @MainActor
   init(index: Int = 0, position: TableVisualState.Point2D, orientation: Float = 0) {
       id = EquipmentIdentifier(index)

       let newEntity = generateBlock()
       newEntity.name = "Block-\(index)"
       let rotation = Angle2D(radians: orientation)
       initialState = State(
           parentID: .tableID,
           pose: .init(position: position, rotation: rotation),
           entity: newEntity
       )
       entity = newEntity
   }
}

struct PlayerSeat: TableSeat {
    let id: ID
    var initialState: TableSeatState

    @MainActor static let seatPoses: [TableVisualState.Pose2D] = [
        .init(position: .init(x: 0, z: Double(GameMetrics.tableEdge)), rotation: .degrees(0)),
        .init(position: .init(x: -Double(GameMetrics.tableEdge), z: 0), rotation: .degrees(-90)),
        .init(position: .init(x: Double(GameMetrics.tableEdge), z: 0), rotation: .degrees(90))
    ]

    init(id: TableSeatIdentifier, pose: TableVisualState.Pose2D) {
        self.id = id
        let spatialSeatPose: TableVisualState.Pose2D =
            .init(position: pose.position, rotation: pose.rotation)
        initialState = .init(pose: spatialSeatPose)
    }
}

struct MemoryCard: EntityEquipment {
    let id: EquipmentIdentifier
    let entity: Entity
    let initialState: BaseEquipmentState
    
    @MainActor
    init(id: EquipmentIdentifier, position: TableVisualState.Point2D) {
        self.id = id
        // You can use one of the sample assets – here we use "card_back_assembly"
        // Change the asset name to use a different card face if needed.
        self.entity = try! ModelEntity.load(named: "card_arm_01_assembly", in: tabletopGameSampleContentBundle)
        self.entity.name = "MemoryCard_\(id)"
        // Place the card at the provided 2D position (relative to the table)
        self.initialState = BaseEquipmentState(
            parentID: .tableID,
            pose: .init(position: position, rotation: .zero),
            entity: self.entity
        )
    }
}

/// A memory game board equipment that arranges a grid of MemoryCard instances.
/// The board itself is an equipment container that parents all the card entities.
struct MemoryGameBoard: Equipment {
    let id: EquipmentIdentifier
    let cards: [MemoryCard]
    let initialState: BaseEquipmentState

    @MainActor
    init(id: EquipmentIdentifier, rows: Int, columns: Int, cardSpacing: Float) {
        self.id = id

        // Define table half-dimensions based on the Table struct.
        // Table dimensions: width = 0.6, height = 0.4
        let tableHalfWidth: Float = 0.6 / 2.0   // 0.3
        let tableHalfDepth: Float = 0.4 / 2.0     // 0.2

        // Retrieve card dimensions from GameMetrics.
        let halfCardWidth = GameMetrics.cardWidth / 2.0  // e.g., 0.03
        let halfCardHeight = GameMetrics.cardHeight / 2.0  // e.g., 0.045

        // Calculate the overall grid half-dimensions, including half the card sizes.
        // The grid is centered at (0, 0), so its left-most and bottom-most edges are offset by gridHalfWidth/gridHalfDepth.
        let gridHalfWidth = (Float(columns - 1) * cardSpacing) / 2.0 + halfCardWidth
        let gridHalfDepth = (Float(rows - 1) * cardSpacing) / 2.0 + halfCardHeight

        // Verify that the entire grid will lie on the table.
        guard gridHalfWidth <= tableHalfWidth, gridHalfDepth <= tableHalfDepth else {
            print("Grid does not fit on table. Skipping card spawn.")
            self.cards = []
            self.initialState = BaseEquipmentState(
                parentID: .tableID,
                pose: .init(position: .init(x: 0, z: 0), rotation: .zero)
            )
            return
        }

        // The grid fits, so continue to create the cards.
        var tempCards: [MemoryCard] = []
        // Calculate the total extent of the grid (not including the margin)
        let totalWidth = Float(columns - 1) * cardSpacing
        let totalDepth = Float(rows - 1) * cardSpacing

        // Create a centered grid of cards.
        for row in 0..<rows {
            for col in 0..<columns {
                // Calculate positions so that the grid is centered at (0, 0)
                let x = -totalWidth / 2.0 + Float(col) * cardSpacing
                let z = -totalDepth / 2.0 + Float(row) * cardSpacing
                let position = TableVisualState.Point2D(x: Double(x), z: Double(z))
                // Generate an ID to avoid conflicts.
                let cardId = EquipmentIdentifier(row * columns + col + 1000)
                let card = MemoryCard(id: cardId, position: position)
                tempCards.append(card)
            }
        }
        self.cards = tempCards

        // Position the memory board relative to the table.
        self.initialState = BaseEquipmentState(
            parentID: .tableID,
            pose: .init(position: .init(x: 0, z: 0), rotation: .zero)
        )
    }
}


