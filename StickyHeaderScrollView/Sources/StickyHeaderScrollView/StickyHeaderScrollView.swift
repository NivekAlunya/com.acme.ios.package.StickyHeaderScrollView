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
/// - Parameters:
///   - Item: The type of items in the scroll view, must conform to Identifiable
///   - Header: The type of header data associated with items
///   - HeaderContent: The SwiftUI view type for rendering headers
///   - CellContent: The SwiftUI view type for rendering cells
public struct StickyHeaderScrollView<Item: Identifiable, Header, HeaderContent: View, CellContent: View>: View {
    
    // MARK: - Constants
    
    /// Default width for headers when not explicitly measured
    private static var defaultHeaderWidth: Int { 120 }
    /// Vertical position of headers from the top edge
    private static var headerYPosition: CGFloat { 20 }
    /// Height of the header container area
    private static var headerContainerHeight: CGFloat { 40 }
    
    /// Represents a cell in the scroll view with optional header information
    struct Cell<T: Identifiable, H>: Identifiable {
        /// Unique identifier derived from the wrapped item
        var id: T.ID { item.id }
        /// The actual data item
        let item: T
        /// Position index in the scroll view
        var position: Int
        /// Optional header data for this cell
        var header: H?
        /// Width of the header view in points
        var width: Int
        /// Horizontal offset for positioning the header (center point)
        var offset: Int
        /// Opacity of the header (fades when being pushed out)
        var opacity: Double = 1.0
    }
    
    /// Internal state tracking all cells
    @State private var cells: [Cell<Item, Header>] = []
    /// Cached array of cells that have headers, updated when cells change
    @State private var cachedCellsWithHeaders: [Cell<Item, Header>] = []
    /// Scroll position state
    @State private var scrollPosition: ScrollPosition = .init(point: CGPoint(x: 0, y: 0))
    
    /// Array of items to display in the scroll view
    let items: [Item]
    /// Dictionary mapping item IDs to their header data
    let headers: [Item.ID: Header]
    /// ViewBuilder closure to create header views
    let headerBuilder: (Header) -> HeaderContent
    /// ViewBuilder closure to create cell views
    let cellBuilder: (Int, Item) -> CellContent
    
    /// Initializes the sticky header scroll view
    /// - Parameters:
    ///   - items: Array of items to display
    ///   - headers: Dictionary mapping item IDs to header data
    ///   - headerBuilder: ViewBuilder to create header views
    ///   - cellBuilder: ViewBuilder to create cell views
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
        
        // Initialize cells with their header data
        let cells: [Cell<Item, Header>] = items.enumerated().map { (offset, item) in
            Cell(
                item: item,
                position: offset,
                header: headers[item.id],
                width: Self.defaultHeaderWidth,
                offset: 0
            )
        }
        _cells = State(initialValue: cells)
        _cachedCellsWithHeaders = State(initialValue: cells.filter { $0.header != nil })
    }
    
    /// Returns only cells that have associated headers
    var cellsWithHeaders: [Cell<Item, Header>] {
        cachedCellsWithHeaders
    }
    
    /// Computes the sticky position and opacity for a header based on scroll position
    /// - Parameters:
    ///   - cellId: The ID of the cell whose header position should be computed
    ///   - position: The current frame of the cell in global coordinates
    func computePosition(cellId: Item.ID, position: CGRect) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }),
              cells[index].header != nil else { return }
        
        var cell = cells[index]
        let x = Int(position.minX)
        
        // Calculate offset: position() uses center point, so offset is center of header
        // Stick to left edge when cell scrolls past (minimum offset is width/2)
        var targetOffset = max(cell.width / 2, x + cell.width / 2)
        
        // Check collision with next header - if it's approaching, push current header left
        let headersWithIndex = cellsWithHeaders
        if let currentHeaderIndex = headersWithIndex.firstIndex(where: { $0.item.id == cellId }),
           currentHeaderIndex + 1 < headersWithIndex.count {
            let nextCell = headersWithIndex[currentHeaderIndex + 1]
            
            // Calculate edges: .position() positions by center, so we need to account for that
            // Next header's left edge = nextCell.offset - nextCell.width / 2
            // Current header's right edge = targetOffset + cell.width / 2
            let nextHeaderLeftEdge = nextCell.offset - nextCell.width / 2
            let currentHeaderRightEdge = targetOffset + cell.width / 2
            
            // If headers would overlap, push current header to the left
            if nextHeaderLeftEdge < currentHeaderRightEdge {
                targetOffset = nextHeaderLeftEdge - cell.width / 2
            }
        }
        
        cell.offset = targetOffset
        
        // Compute opacity based on visibility
        // When header is pushed beyond the left edge, fade it out proportionally
        let leftEdge = cell.offset - cell.width / 2
        if leftEdge < 0 {
            let visibleWidth = cell.width + leftEdge
            cell.opacity = max(0.0, Double(visibleWidth) / Double(cell.width))
        } else {
            cell.opacity = 1.0
        }
        
        cells[index] = cell
    }
    
    /// Updates the width of a header when its geometry changes
    /// - Parameters:
    ///   - cellId: The ID of the cell whose header width should be updated
    ///   - width: The new width in points
    func setWidth(for cellId: Item.ID, width: Int) {
        guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else { return }
        cells[index].width = width
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Sticky header overlay
            ZStack(alignment: .topLeading) {
                ForEach(cellsWithHeaders) { cell in
                    if let header = cell.header {
                        headerBuilder(header)
                            .opacity(cell.opacity)
                            .onGeometryChange(for: CGSize.self, of: { $0.size }) { newValue in
                                setWidth(for: cell.item.id, width: Int(newValue.width))
                            }
                            .position(x: CGFloat(cell.offset), y: Self.headerYPosition)
                    }
                }
            }
            .frame(height: Self.headerContainerHeight)
            
            // Scrollable content
            ScrollView(.horizontal) {
                HStack {
                    ForEach(items.enumerated().map({ ($0.offset, $0.element) }), id: \.1.id) { offset, item in
                        cellBuilder(offset, item)
                            .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }) { newValue in
                                computePosition(cellId: item.id, position: newValue)
                            }
                    }
                }
            }
            .scrollPosition($scrollPosition)
        }
        .onAppear {
            // Use a non-zero initial x position to trigger initial scroll/geometry calculations,
            // ensuring header positions are computed correctly on first appearance.
            scrollPosition = .init(point: CGPoint(x: 1, y: 0))
        }
    }
}

// MARK: - Example Usage

struct ColorItem: Identifiable {
    let id: String
    let name: String
    let color: Color
    let description: String
    let isCategory: Bool
}

struct HeaderData {
    let title: String
    let color: Color
}

let items = [
    ColorItem(id: "red", name: "Red", color: .red, description: "Warm color", isCategory: true),
    ColorItem(id: "pink", name: "Pink", color: .pink, description: "Light red", isCategory: false),
    ColorItem(id: "green", name: "Green", color: .green, description: "Nature color", isCategory: true),
    ColorItem(id: "mint", name: "Mint", color: .mint, description: "Light green", isCategory: false),
    ColorItem(id: "blue", name: "Blue", color: .blue, description: "Cool color", isCategory: true),
    ColorItem(id: "cyan", name: "Cyan", color: .cyan, description: "Light blue", isCategory: false),
]

let headers: [String: HeaderData] = [
    "red": HeaderData(title: "Red", color: .red),
    "green": HeaderData(title: "Green", color: .green),
    "blue": HeaderData(title: "Blue", color: .blue),
]

#Preview {
   
    
    return StickyHeaderScrollView(
        items: items,
        headers: headers
    ) { header in
        // Header view
        Text(header.title)
            .padding(8)
            .background(header.color)
            .cornerRadius(6)
    } cellBuilder: { index, item in
        // Cell view
        HStack {
            Rectangle()
                .fill(item.color)
                .frame(width: 50, height: 50)
                .border(Color.black, width: 1)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.description)
                    .font(.caption)
                Text("Position: \(index)")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 200)
    }
}
