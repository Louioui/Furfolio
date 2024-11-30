//
//  MetricsDashboardView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI
import Charts

struct MetricsDashboardView: View {
    @State private var selectedDateRange: DateRange = .lastMonth
    let dailyRevenues: [DailyRevenue]
    let appointments: [Appointment]
    let charges: [Charge]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("Metrics Dashboard", comment: "Title for the metrics dashboard"))
                        .font(.largeTitle)
                        .bold()
                        .accessibilityAddTraits(.isHeader)

                    // Revenue Trends Chart
                    RevenueChartView(dailyRevenues: filteredRevenues(for: selectedDateRange))

                    // Total Revenue Summary
                    TotalRevenueView(revenue: totalRevenue(for: selectedDateRange))

                    // Revenue by Quarters
                    QuarterRevenueView(dailyRevenues: dailyRevenues)

                    // Upcoming Appointments
                    UpcomingAppointmentsView(appointments: upcomingAppointments())

                    // Charge Summary
                    ChargeSummaryView(charges: chargesSummary())

                    // Popular Services
                    PopularServicesView(charges: charges)

                    // Date Range Picker
                    DateRangePicker(selectedDateRange: $selectedDateRange)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("Dashboard", comment: "Navigation title for metrics dashboard"))
        }
    }

    // MARK: - Helper Methods

    private func filteredRevenues(for range: DateRange) -> [DailyRevenue] {
        let startDate: Date? = {
            switch range {
            case .lastWeek: return Calendar.current.date(byAdding: .day, value: -7, to: Date())
            case .lastMonth: return Calendar.current.date(byAdding: .month, value: -1, to: Date())
            case .custom: return nil
            }
        }()
        return dailyRevenues.filter { startDate == nil || $0.date >= startDate! }
    }

    private func totalRevenue(for range: DateRange) -> Double {
        charges.filter { charge in
            let calendar = Calendar.current
            guard let startDate: Date = {
                switch range {
                case .lastWeek:
                    return calendar.date(byAdding: .day, value: -7, to: Date())
                case .lastMonth:
                    return calendar.date(byAdding: .month, value: -1, to: Date())
                case .custom:
                    return nil
                }
            }() else { return true }
            return charge.date >= startDate
        }
        .reduce(0) { $0 + $1.amount }
    }

    private func upcomingAppointments() -> [Appointment] {
        let today = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
        return appointments.filter { $0.date > today && $0.date <= endDate }
    }

    private func chargesSummary() -> [String: Double] {
        let summary = Charge.totalByType(charges: charges)
        return summary.reduce(into: [String: Double]()) { result, item in
            result[item.key.rawValue] = item.value
        }
    }
}

// MARK: - Revenue Chart View

struct RevenueChartView: View {
    let dailyRevenues: [DailyRevenue]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Revenue Trends", comment: "Section title for revenue trends"))
                .font(.headline)
            if dailyRevenues.isEmpty {
                Text(NSLocalizedString("No revenue data available.", comment: "Message when no revenue data exists"))
                    .foregroundColor(.gray)
            } else {
                Chart(dailyRevenues) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Revenue", $0.totalAmount)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Total Revenue View

struct TotalRevenueView: View {
    let revenue: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Total Revenue", comment: "Section title for total revenue"))
                .font(.headline)
            Text(revenue.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                .font(.title2)
                .bold()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Quarter Revenue View

struct QuarterRevenueView: View {
    let dailyRevenues: [DailyRevenue]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Quarterly Revenue", comment: "Section title for quarterly revenue"))
                .font(.headline)
            let calendar = Calendar.current
            let groupedByQuarter = Dictionary(grouping: dailyRevenues) { revenue in
                let month = calendar.component(.month, from: revenue.date)
                return (month - 1) / 3 + 1 // Calculate the quarter
            }

            ForEach(groupedByQuarter.keys.sorted(), id: \.self) { quarter in
                let totalRevenue = groupedByQuarter[quarter]?.reduce(0) { $0 + $1.totalAmount } ?? 0
                HStack {
                    Text("Q\(quarter)")
                        .font(.subheadline)
                    Spacer()
                    Text(totalRevenue.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.teal.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Upcoming Appointments View

struct UpcomingAppointmentsView: View {
    let appointments: [Appointment]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Upcoming Appointments", comment: "Section title for upcoming appointments"))
                .font(.headline)
            if appointments.isEmpty {
                Text(NSLocalizedString("No upcoming appointments.", comment: "Message when no upcoming appointments exist"))
                    .foregroundColor(.gray)
            } else {
                ForEach(appointments) { appointment in
                    HStack {
                        Text(appointment.dogOwner.ownerName)
                            .font(.subheadline)
                        Spacer()
                        Text(appointment.date.formatted(.dateTime.month().day().hour().minute()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Charge Summary View

struct ChargeSummaryView: View {
    let charges: [String: Double]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Charge Summary", comment: "Section title for charge summary"))
                .font(.headline)
            if charges.isEmpty {
                Text(NSLocalizedString("No charges recorded.", comment: "Message when no charges exist"))
                    .foregroundColor(.gray)
            } else {
                ForEach(charges.keys.sorted(), id: \.self) { type in
                    HStack {
                        Text(type)
                            .font(.subheadline)
                        Spacer()
                        Text("\(charges[type] ?? 0, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Popular Services View

struct PopularServicesView: View {
    let charges: [Charge]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Popular Services", comment: "Section title for popular services"))
                .font(.headline)
            let serviceCounts = charges.reduce(into: [String: Int]()) { counts, charge in
                counts[charge.type.rawValue, default: 0] += 1
            }
            if serviceCounts.isEmpty {
                Text(NSLocalizedString("No services data available.", comment: "Message when no service data exists"))
                    .foregroundColor(.gray)
            } else {
                ForEach(serviceCounts.keys.sorted(), id: \.self) { type in
                    HStack {
                        Text(type)
                            .font(.subheadline)
                        Spacer()
                        Text("\(serviceCounts[type] ?? 0) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Date Range Picker

struct DateRangePicker: View {
    @Binding var selectedDateRange: DateRange

    var body: some View {
        Picker(NSLocalizedString("Date Range", comment: "Picker title for date range selection"), selection: $selectedDateRange) {
            Text(NSLocalizedString("Last Week", comment: "Last week date range option")).tag(DateRange.lastWeek)
            Text(NSLocalizedString("Last Month", comment: "Last month date range option")).tag(DateRange.lastMonth)
            Text(NSLocalizedString("Custom", comment: "Custom date range option")).tag(DateRange.custom)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.top)
    }
}

// MARK: - Date Range Enum

enum DateRange {
    case lastWeek, lastMonth, custom
}
