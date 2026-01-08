//
//  ExampleView.swift
//  StickyHeaderScrollView Examples
//
//  Demonstrates various usage patterns for StickyHeaderScrollView
//

import SwiftUI
import StickyHeaderScrollView

// MARK: - Example 1: E-commerce Product Categories

struct Product: Identifiable {
    let id: String
    let name: String
    let price: Double
    let image: String
    let category: String
}

struct CategoryHeader {
    let name: String
    let color: Color
    let icon: String
}

public struct EcommerceExample: View {
    let products = [
        Product(id: "1", name: "iPhone 15 Pro", price: 999, image: "iphone", category: "Electronics"),
        Product(id: "2", name: "AirPods Pro", price: 249, image: "airpods", category: "Electronics"),
        Product(id: "3", name: "iPad Air", price: 599, image: "ipad", category: "Electronics"),
        Product(id: "4", name: "Swift Programming", price: 39, image: "book", category: "Books"),
        Product(id: "5", name: "Design Patterns", price: 45, image: "book", category: "Books"),
        Product(id: "6", name: "Clean Code", price: 42, image: "book", category: "Books"),
        Product(id: "7", name: "Running Shoes", price: 120, image: "shoe", category: "Sports"),
        Product(id: "8", name: "Yoga Mat", price: 35, image: "mat", category: "Sports"),
    ]
    
    let headers: [String: CategoryHeader] = [
        "1": CategoryHeader(name: "Electronics", color: .blue, icon: "bolt.fill"),
        "4": CategoryHeader(name: "Books", color: .orange, icon: "book.fill"),
        "7": CategoryHeader(name: "Sports", color: .green, icon: "figure.run"),
    ]
    
    public init() {
        
    }
    
    public var body: some View {
        StickyHeaderScrollView(
            items: products,
            headers: headers
        ) { header in
            HStack(spacing: 8) {
                Image(systemName: header.icon)
                Text(header.name)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(header.color)
            .cornerRadius(20)
        } cellBuilder: { index, product in
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: product.image)
                    .font(.system(size: 50))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(Int(product.price))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(product.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 180)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 2)
        }
    }
}

// MARK: - Example 2: Timeline/Schedule View

struct TimelineEvent: Identifiable {
    let id: String
    let time: String
    let title: String
    let description: String
    let isHeader: Bool
}

struct TimeHeader {
    let time: String
    let period: String
}

public struct TimelineExample: View {
    let events = [
        TimelineEvent(id: "1", time: "9:00 AM", title: "Team Standup", description: "Daily sync", isHeader: true),
        TimelineEvent(id: "2", time: "9:30 AM", title: "Code Review", description: "PR #234", isHeader: false),
        TimelineEvent(id: "3", time: "11:00 AM", title: "Design Meeting", description: "New feature", isHeader: true),
        TimelineEvent(id: "4", time: "11:30 AM", title: "Break", description: "Coffee time", isHeader: false),
        TimelineEvent(id: "5", time: "2:00 PM", title: "Client Call", description: "Project update", isHeader: true),
        TimelineEvent(id: "6", time: "3:00 PM", title: "Development", description: "Sprint work", isHeader: false),
    ]
    
    var headers: [String: TimeHeader] {
        var result: [String: TimeHeader] = [:]
        for event in events where event.isHeader {
            result[event.id] = TimeHeader(
                time: event.time,
                period: event.time.contains("AM") ? "Morning" : "Afternoon"
            )
        }
        return result
    }
    
    public init() {
        
    }
    
    public var body: some View {
        StickyHeaderScrollView(
            items: events,
            headers: headers
        ) { header in
            VStack(alignment: .leading, spacing: 2) {
                Text(header.time)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(header.period)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.2))
            .cornerRadius(8)
        } cellBuilder: { index, event in
            HStack(spacing: 12) {
                Circle()
                    .fill(event.isHeader ? Color.purple : Color.gray)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(event.title)
                        .font(.headline)
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 220)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
}

// MARK: - Example 3: Photo Gallery by Date

struct Photo: Identifiable {
    let id: String
    let imageName: String
    let date: String
}

struct DateHeader {
    let date: String
    let photoCount: Int
}

public struct PhotoGalleryExample: View {
    let photos = [
        Photo(id: "1", imageName: "photo.fill", date: "Dec 10, 2025"),
        Photo(id: "2", imageName: "photo.fill", date: "Dec 10, 2025"),
        Photo(id: "3", imageName: "photo.fill", date: "Dec 10, 2025"),
        Photo(id: "4", imageName: "photo.fill", date: "Dec 9, 2025"),
        Photo(id: "5", imageName: "photo.fill", date: "Dec 9, 2025"),
        Photo(id: "6", imageName: "photo.fill", date: "Dec 8, 2025"),
        Photo(id: "7", imageName: "photo.fill", date: "Dec 8, 2025"),
        Photo(id: "8", imageName: "photo.fill", date: "Dec 8, 2025"),
    ]
    
    let headers: [String: DateHeader] = [
        "1": DateHeader(date: "Dec 10, 2025", photoCount: 3),
        "4": DateHeader(date: "Dec 9, 2025", photoCount: 2),
        "6": DateHeader(date: "Dec 8, 2025", photoCount: 3),
    ]
    
    
    public init() {
        
    }
    
    
    public var body: some View {
        StickyHeaderScrollView(
            items: photos,
            headers: headers
        ) { header in
            VStack(alignment: .leading, spacing: 2) {
                Text(header.date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(header.photoCount) photos")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        } cellBuilder: { index, photo in
            Image(systemName: photo.imageName)
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .frame(width: 150, height: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview("E-commerce") {
    EcommerceExample()
}

#Preview("Timeline") {
    TimelineExample()
}

#Preview("Photo Gallery") {
    PhotoGalleryExample()
}
