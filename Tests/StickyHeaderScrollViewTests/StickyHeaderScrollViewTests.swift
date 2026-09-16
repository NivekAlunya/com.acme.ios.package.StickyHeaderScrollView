//
//  StickyHeaderScrollViewTests.swift
//  StickyHeaderScrollViewTests
//
//  Created by Kevin Launay on 10/12/2025.
//

import Testing
import SwiftUI
@testable import StickyHeaderScrollView

private struct TestItem: Identifiable, Sendable {
    let id: String
    let title: String
}

private struct TestHeader: Sendable {
    let name: String
}

@Suite("StickyHeaderScrollView Tests")
struct StickyHeaderScrollViewTests {

    @Test("Initialization and header association")
    func testInitialization() {
        let items = [
            TestItem(id: "1", title: "First"),
            TestItem(id: "2", title: "Second"),
            TestItem(id: "3", title: "Third")
        ]
        let headers = [
            "1": TestHeader(name: "Header 1"),
            "3": TestHeader(name: "Header 3")
        ]

        let scrollView = StickyHeaderScrollView(
            items: items,
            headers: headers
        ) { header in
            Text(header.name)
        } cellBuilder: { _, item in
            Text(item.title)
        }

        #expect(scrollView.items.count == 3)
        #expect(scrollView.headers.count == 2)
        #expect(scrollView.headerHeight == 40)
    }

    @Test("Cells with headers filtering")
    func testCellsWithHeaders() {
        let items = [
            TestItem(id: "A", title: "Item A"),
            TestItem(id: "B", title: "Item B")
        ]
        let headers = ["A": TestHeader(name: "Section A")]

        let view = StickyHeaderScrollView(
            items: items,
            headers: headers
        ) { header in
            Text(header.name)
        } cellBuilder: { _, item in
            Text(item.title)
        }

        #expect(view.cellsWithHeaders.count == 1)
        #expect(view.cellsWithHeaders.first?.header?.name == "Section A")
    }
}
