// See https://github.com/woocommerce/woocommerce-ios/blob/ed0d71d7dd4a40802a0d38d82cf2eb0e8cc45cd4/WooCommerce/WooCommerceUITests/Utils/XCTest%2BExtensions.swift
import XCTest

extension XCTest {

    var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            return UIViewController().traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}
