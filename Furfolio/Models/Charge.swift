//
//  Charge.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import Foundation
import SwiftData

@Model
final class Charge {
    let chargeDate: Date
    let chargeAmount: Double
    let isPaid: Bool
    let paymentMethod: String
    let serviceType: String // Add service type for revenue tracking

    init(chargeDate: Date, chargeAmount: Double, serviceType: String, isPaid: Bool = false, paymentMethod: String = "") {
        self.chargeDate = chargeDate
        self.chargeAmount = chargeAmount
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
        self.serviceType = serviceType // Initialize service type
    }
}


