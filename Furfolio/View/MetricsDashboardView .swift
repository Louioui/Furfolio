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
                    Text("Metrics Dashboard")
                        .font(.largeTitle)
                        .bold()

                    // Revenue Trends Chart
                    RevenueChartView(dailyRevenues: filteredRevenues(for: selectedDateRange))

                    // Total Revenue Summary
                    TotalRevenueView(revenue: totalRevenue(for: selectedDateRange))

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
            .navigationTitle("Dashboard")
        }
    }

    // MARK: - Helper Methods

    /// Filters revenue data based on the selected date range
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

    /// Calculates the total revenue for the selected date range
    private func totalRevenue(for range: DateRange) -> Double {
        filteredRevenues(for: range).reduce(0) { $0 + $1.totalAmount }
    }

    /// Gets the list of upcoming appointments within the next 7 days
    private func upcomingAppointments() -> [Appointment] {
        let today = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
        return appointments.filter { $0.date > today && $0.date <= endDate }
    }

    /// Summarizes charges by type
    private func chargesSummary() -> [String: Double] {
        Charge.totalByType(charges: charges)
    }
}

// MARK: - Revenue Chart View

struct RevenueChartView: View {
    let dailyRevenues: [DailyRevenue]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Revenue Trends")
                .font(.headline)
            if dailyRevenues.isEmpty {
                Text("No revenue data available.")
                    .foregroundColor(.gray)
            } else {
                Chart(dailyRevenues) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Revenue", $0.totalAmount)
                    )
                    .foregroundStyle(Color.blue)
                }
                .frame(height: 200)
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
            Text("Total Revenue")
                .font(.headline)
            Text("\(revenue, format: .currency(code: "USD"))")
                .font(.title2)
                .bold()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Upcoming Appointments View

struct UpcomingAppointmentsView: View {
    let appointments: [Appointment]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Upcoming Appointments")
                .font(.headline)
            if appointments.isEmpty {
                Text("No upcoming appointments.")
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
            Text("Charge Summary")
                .font(.headline)
            if charges.isEmpty {
                Text("No charges recorded.")
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
            Text("Popular Services")
                .font(.headline)
            let serviceCounts = charges.reduce(into: [String: Int]()) { counts, charge in
                counts[charge.type, default: 0] += 1
            }
            if serviceCounts.isEmpty {
                Text("No services data available.")
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
        Picker("Date Range", selection: $selectedDateRange) {
            Text("Last Week").tag(DateRange.lastWeek)
            Text("Last Month").tag(DateRange.lastMonth)
            Text("Custom").tag(DateRange.custom)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.top)
    }
}

// MARK: - Date Range Enum

enum DateRange {
    case lastWeek, lastMonth, custom
}


