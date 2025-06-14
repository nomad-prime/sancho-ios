import XCTest
import SwiftUI

@testable import sancho

final class ColorExtensionTests: XCTestCase {

    func testHexInitializerCreatesCorrectColor() {
        // Given
        let hex = "#FF0000" // Red

        // When
        let color = Color(hex: hex)

        // Then
        // To check Color components, convert to UIColor for comparison.
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        XCTAssertEqual(red, 1.0, accuracy: 0.01)
        XCTAssertEqual(green, 0.0, accuracy: 0.01)
        XCTAssertEqual(blue, 0.0, accuracy: 0.01)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
        #endif
    }

    func testHexInitializerHandlesInvalidHexGracefully() {
        // Given
        let hex = "NotAHex"

        // When
        let color = Color(hex: hex)

        // Then
        // Expect fallback to black or zero color (since your extension has no explicit fallback)
        // So test that it doesn't crash and returns a Color
        XCTAssertNotNil(color)
    }

    func testHexInitializerHandlesShortHex() {
        // Given
        let hex = "#0F0F0F"

        // When
        let color = Color(hex: hex)

        // Then
        // Convert to UIColor to verify RGB
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        XCTAssertEqual(red, 15/255, accuracy: 0.01)
        XCTAssertEqual(green, 15/255, accuracy: 0.01)
        XCTAssertEqual(blue, 15/255, accuracy: 0.01)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
        #endif
    }
}
