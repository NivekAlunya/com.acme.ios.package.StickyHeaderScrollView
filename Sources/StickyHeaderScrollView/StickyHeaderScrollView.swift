//
//  StickyHeaderScrollView.swift
//  StickyHeaderScrollView
//
//  Created by Kevin Launay on 10/12/2025.
//

import SwiftUI

/// A horizontal scrolling view with sticky headers that remain visible at the left edge
/// and are pushed out by subsequent headers as the user scrolls.
///
/// This component displays a horizontally scrollable list of items where each item can have
/// an associated header. Headers "stick" to the left edge as their content scrolls past,
/// and are smoothly pushed out of view by the next header approaching from the right.
///
/// - Parameters:
///   - Item: The type of items in the scroll view, must conform to Identifiable
///   - Header: The type of header data associated with items
///   - HeaderContent: The SwiftUI view type for rendering headers
///   - CellContent: The SwiftUI view type for rendering cells
public struct StickyHeaderScrollView<Item: Identifiable, Header, HeaderContent: View, CellContent: View>: View {
    
    // MARK: - Cell Model
    
    /// Represents a cell in the scroll view with optional header information and positioning data
    struct Cell<T: Identifiable, H>: Identifiable, Sendable where T: Sendable, H: Sendable, T.ID: Sendable {
        /// Unique identifier derived from the wrapped item
        var id: T.ID { item.id }
        
        /// The actual data item to display
        let item: T
        
        /// Optional header data for this cell
        var header: H?
        
        /// Width of the header view in points (measured dynamically)
        var width: CGFloat
        
        /// X position of the cell in the scroll view's coordinate space
        var xPosition: CGFloat
        
        /// Horizontal offset for positioning the sticky header
        var stickyOffset: CGFloat = 0
        
        /// Opacity of the header (fades when being pushed off screen)
        var opacity: Double = 1.0
    }
    
    // MARK: - State Properties
    
    /// Internal state tracking all cells with their positioning data
    @State private var cells: [Cell<Item, Header>] = []
    
    // MARK: - Configuration Properties
    
    /// Array of items to display in the scroll view
    let items: [Item]
    
    /// Dictionary mapping item IDs to their header data
    let headers: [Item.ID: Header]
    
    /// ViewBuilder closure to create header views
    let headerBuilder: (Header) -> HeaderContent
    
    /// ViewBuilder closure to create cell views
    let cellBuilder: (Int, Item) -> CellContent
    
    /// Height reserved for sticky headers at the top
    let headerHeight: CGFloat = 40
    
    // MARK: - Initialization
    
    /// Initializes the sticky header scroll view with items and headers
    ///
    /// - Parameters:
    ///   - items: Array of items to display in the scroll view
    ///   - headers: Dictionary mapping item IDs to their corresponding header data
    ///   - headerBuilder: ViewBuilder closure that creates a view for each header
    ///   - cellBuilder: ViewBuilder closure that creates a view for each item (receives index and item)
    public init(
        items: [Item],
        headers: [Item.ID: Header],
        @ViewBuilder headerBuilder: @escaping (Header) -> HeaderContent,
        @ViewBuilder cellBuilder: @escaping (Int, Item) -> CellContent
    ) {
        self.items = items
        self.headers = headers
        self.headerBuilder = headerBuilder
        self.cellBuilder = cellBuilder
        
        // Initialize cells with their header data and default positioning
        let cells: [Cell<Item, Header>] = items.map { item in
            Cell(
                item: item,
                header: headers[item.id],
                width: 120, // Default width, will be updated dynamically
                xPosition: 0
            )
        }
        _cells = State(initialValue: initialCells)
    }
    
    // MARK: - Computed Properties
    
    /// Returns only cells that have associated headers
    var cellsWithHeaders: [Cell<Item, Header>] {
        cells.filter { $0.header != nil }
    }
    
    // MARK: - Position Update Methods
    
    /// Updates the X position of a cell when its geometry changes
    func updateCellPosition(cellId: Item.ID, frame: CGRect) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else { return }
        cells[index].xPosition = frame.minX
        computeStickyPositions()
    }
    
    /// Computes sticky positions and opacities for all headers based on current scroll state
    func computeStickyPositions() {
        let headersList = cellsWithHeaders
        
        for (headerIndex, cell) in headersList.enumerated() {
            guard let cellIndex = cells.firstIndex(where: { $0.item.id == cell.item.id }) else { continue }
            
            let cellX = cells[cellIndex].xPosition
            let headerWidth = cells[cellIndex].width
            
            var stickyX = max(0, cellX)
            
            // Collision detection: check if the next header is pushing this one
            if headerIndex + 1 < headersList.count {
                let nextCell = headersList[headerIndex + 1]
                let nextCellX = nextCell.xPosition
                let nextStickyX = max(0, nextCellX)
                
                let currentHeaderRightEdge = stickyX + headerWidth
                let nextHeaderLeftEdge = nextStickyX
                
                if currentHeaderRightEdge > nextHeaderLeftEdge {
                    stickyX = nextHeaderLeftEdge - headerWidth
                }
            }
            
            let opacity: Double
            if stickyX < 0 {
                let visibleWidth = headerWidth + stickyX
                opacity = max(0.0, visibleWidth / headerWidth)
            } else {
                opacity = 1.0
            }
            
            cells[cellIndex].stickyOffset = stickyX
            cells[cellIndex].opacity = opacity
        }
    }
    
    /// Updates the width of a header when its geometry changes
    func updateHeaderWidth(cellId: Item.ID, width: CGFloat) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else { return }
        cells[index].width = width
        computeStickyPositions()
    }

    private func syncCellsWithItems() {
        cells = items.enumerated().map { (offset, item) in
            let existing = cells.first(where: { $0.item.id == item.id })
            return Cell(
                item: item,
                position: offset,
                header: headers[item.id],
                width: existing?.width ?? 120,
                xPosition: existing?.xPosition ?? 0,
                stickyOffset: existing?.stickyOffset ?? 0,
                opacity: existing?.opacity ?? 1.0
            )
        }
        computeStickyPositions()
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { offset, item in
                    cellBuilder(offset, item)
                        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("scrollSpace")) }) { frame in
                            updateCellPosition(cellId: item.id, frame: frame)
                        }
                }
            }
        }
        .padding(.top, headerHeight) // Reserve space at top for sticky headers
        .coordinateSpace(name: "scrollSpace") // Named coordinate space for consistent positioning
        // Sticky headers overlay layer
        // Headers are positioned absolutely and overlay the scroll view
        .overlay(alignment: .topLeading) {
            ForEach(cellsWithHeaders) { cell in
                if let header = cell.header {
                    headerBuilder(header)
                        .opacity(cell.opacity)
                        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width in
                            updateHeaderWidth(cellId: cell.item.id, width: width)
                        }
                        .offset(x: cell.stickyOffset, y: 0)
                }
            }
        }
        .onChange(of: items.map(\.id)) { _, _ in
            syncCellsWithItems()
        }
    }
}
