//
//  StickyHeaderScrollView.swift
//  HScrollHeader
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
///
/// ## Example Usage
/// ```swift
/// StickyHeaderScrollView(
///     items: myItems,
///     headers: myHeadersDictionary,
///     headerBuilder: { header in
///         Text(header.title)
///             .padding()
///             .background(Color.blue)
///     },
///     cellBuilder: { index, item in
///         ItemView(item: item)
///     }
/// )
/// ```
public struct StickyHeaderScrollView<Item: Identifiable, Header, HeaderContent: View, CellContent: View>: View {
    
    // MARK: - Cell Model
    
    /// Represents a cell in the scroll view with optional header information and positioning data
    struct Cell<T: Identifiable, H>: Identifiable {
        /// Unique identifier derived from the wrapped item
        var id: T.ID { item.id }
        
        /// The actual data item to display
        let item: T
        
        /// Position index in the scroll view (0-based)
        var position: Int
        
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
    
    /// Size of the scroll view container
    @State private var scrollViewSize: CGSize = .zero
    
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
        let cells: [Cell<Item, Header>] = items.enumerated().map { (offset, item) in
            Cell(
                item: item,
                position: offset,
                header: headers[item.id],
                width: 120, // Default width, will be updated dynamically
                xPosition: 0
            )
        }
        _cells = State(initialValue: cells)
    }
    
    // MARK: - Computed Properties
    
    /// Returns only cells that have associated headers
    var cellsWithHeaders: [Cell<Item, Header>] {
        cells.filter { $0.header != nil }
    }
    
    // MARK: - Position Update Methods
    
    /// Updates the X position of a cell when its geometry changes
    ///
    /// This is called by the geometry observer on each cell as the user scrolls.
    /// After updating the position, it triggers a recalculation of all sticky header positions.
    ///
    /// - Parameters:
    ///   - cellId: The ID of the cell whose position should be updated
    ///   - frame: The new frame of the cell in the scroll view's coordinate space
    func updateCellPosition(cellId: Item.ID, frame: CGRect) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else { return }
        
        // Store the cell's X position (left edge)
        cells[index].xPosition = frame.minX
        
        // Recalculate all sticky positions based on new cell positions
        computeStickyPositions()
    }
    
    /// Computes sticky positions and opacities for all headers based on current scroll state
    ///
    /// This method implements the sticky header logic:
    /// 1. Headers stick to the left edge (x=0) when their cell scrolls past
    /// 2. When the next header approaches, it pushes the current header to the left
    /// 3. Headers fade out as they're pushed off the left edge
    func computeStickyPositions() {
        // Get all cells with headers, maintaining their order
        let headersWithIndex = cellsWithHeaders.enumerated().map { ($0.offset, $0.element) }
        
        for (headerIndex, cell) in headersWithIndex {
            guard let cellIndex = cells.firstIndex(where: { $0.item.id == cell.item.id }) else { continue }
            
            let cellX = cells[cellIndex].xPosition
            let headerWidth = cells[cellIndex].width
            
            // Basic sticky logic: header sticks to left edge (0) when cell scrolls past
            // Otherwise, header follows its cell position
            var stickyX = max(0, cellX)
            
            // Collision detection: check if the next header is pushing this one
            if headerIndex + 1 < headersWithIndex.count {
                let nextCell = headersWithIndex[headerIndex + 1].1
                let nextCellX = nextCell.xPosition
                
                // Calculate where the next header will be positioned
                let nextStickyX = max(0, nextCellX)
                
                // Calculate the edges of both headers
                let currentHeaderRightEdge = stickyX + headerWidth
                let nextHeaderLeftEdge = nextStickyX
                
                // If headers would overlap, push current header to the left
                // to make room for the approaching next header
                if currentHeaderRightEdge > nextHeaderLeftEdge {
                    stickyX = nextHeaderLeftEdge - headerWidth
                }
            }
            
            // Calculate opacity based on how much of the header is visible
            let opacity: Double
            if stickyX < 0 {
                // Header is being pushed off the left edge
                // Calculate what portion is still visible
                let visibleWidth = headerWidth + stickyX
                opacity = max(0.0, visibleWidth / headerWidth)
            } else {
                // Header is fully visible
                opacity = 1.0
            }
            
            // Update the cell with new sticky position and opacity
            cells[cellIndex].stickyOffset = stickyX
            cells[cellIndex].opacity = opacity
        }
    }
    
    /// Updates the width of a header when its geometry changes
    ///
    /// Called when a header is first rendered or when its size changes.
    /// Triggers a recalculation of sticky positions since header width affects collision detection.
    ///
    /// - Parameters:
    ///   - cellId: The ID of the cell whose header width should be updated
    ///   - width: The new width of the header in points
    func updateHeaderWidth(cellId: Item.ID, width: CGFloat) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else { return }
        
        // Update the stored width
        cells[index].width = width
        
        // Recalculate positions since collision detection depends on header width
        computeStickyPositions()
    }
    
    // MARK: - Body
    
    public var body: some View {
        // Scrollable content layer
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                ForEach(items.enumerated().map({ ($0.offset, $0.element) }), id: \.1.id) { offset, item in
                    cellBuilder(offset, item)
                        // Track cell position as it scrolls
                        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("scrollSpace")) }) { frame in
                            updateCellPosition(cellId: item.id, frame: frame)
                        }
                }
            }
        }
        .padding(.top, headerHeight) // Reserve space at top for sticky headers
        .coordinateSpace(name: "scrollSpace") // Named coordinate space for consistent positioning
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
            scrollViewSize = size
        }
        // Sticky headers overlay layer
        // Headers are positioned absolutely and overlay the scroll view
        .overlay(alignment: .topLeading) {
            ForEach(cellsWithHeaders) { cell in
                if let header = cell.header {
                    headerBuilder(header)
                        .opacity(cell.opacity) // Apply calculated opacity
                        // Measure header width dynamically
                        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width in
                            updateHeaderWidth(cellId: cell.item.id, width: width)
                        }
                        .offset(x: cell.stickyOffset, y: 0) // Apply calculated horizontal offset
                }
            }
        }
    }
}
