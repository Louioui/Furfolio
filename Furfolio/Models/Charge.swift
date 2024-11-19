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

    init(chargeDate: Date, chargeAmount: Double, isPaid: Bool = false, paymentMethod: String = "") {
        self.chargeDate = chargeDate
        self.chargeAmount = chargeAmount
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
    }
}

