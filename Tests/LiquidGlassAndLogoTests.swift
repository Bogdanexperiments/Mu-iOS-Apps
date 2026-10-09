import SwiftUI
import XCTest
@testable import SCPFoundationIOS

final class LiquidGlassAndLogoTests: XCTestCase {
    func testLiquidGlassModifierPreservesConfiguredCornerRadius() {
        let modifier = LiquidGlassModifier(cornerRadius: 28)

        XCTAssertEqual(modifier.cornerRadius, 28)
        XCTAssertFalse(String(describing: type(of: Text("content").modifier(modifier))).isEmpty)
    }

    func testLiquidGlassConvenienceModifierBuildsView() {
        let view = Text("SCP Foundation")
            .liquidGlass(cornerRadius: 24)

        XCTAssertFalse(String(describing: type(of: view)).isEmpty)
    }

    func testFoundationLogoUsesDefaultSize() {
        let logo = FoundationLogoView()

        XCTAssertEqual(logo.size, 100)
        XCTAssertFalse(String(describing: type(of: logo.body)).isEmpty)
    }

    func testFoundationLogoUsesCustomSize() {
        let logo = FoundationLogoView(size: 144)

        XCTAssertEqual(logo.size, 144)
        XCTAssertFalse(String(describing: type(of: logo.body)).isEmpty)
    }
}
