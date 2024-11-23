//
//  MetricsDashboardView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct MetricsDashboardView: View {
    let dogOwners: [DogOwner]
    let dailyRevenues: [DailyRevenue]

    // Calculate today's total revenue
    var totalRevenueToday: Double {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return dailyRevenues.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayStart) })?.amount ?? 0.0
    }

    // Calculate the total revenue for the current month
    var totalRevenueThisMonth: Double {
        let currentMonthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return dailyRevenues.filter { $0.date >= currentMonthStart }
            .reduce(0) { $0 + $1.amount }
    }

    // Get the top 3 most frequent customers
    var mostFrequentCustomers: [DogOwner] {
        dogOwners.sorted { $0.charges.count > $1.charges.count }.prefix(3).map { $0 }
    }

    // Get the counts of popular services
    var popularServices: [String: Int] {
        var serviceCounts: [String: Int] = [:]
        dogOwners.flatMap { $0.charges }.forEach { charge in
            serviceCounts[charge.type, default: 0] += 1
        }
        return serviceCounts
    }

    // Get appointment statistics
    var appointmentStats: (completed: Int, canceled: Int, upcoming: Int) {
        var completed = 0, canceled = 0, upcoming = 0
        let now = Date()
        dogOwners.flatMap { $0.appointments }.forEach { appointment in
            if appointment.date < now && !appointment.isCanceled {
                completed += 1
            } else if appointment.isCanceled {
                canceled += 1
            } else {
                upcoming += 1
            }
        }
        return (completed, canceled, upcoming)
    }

    var body: some View {
        NavigationView {
            List {
                // Revenue Statistics Section
                Section(header: Text("Revenue Statistics")) {
                    Text("Today's Revenue: $\(totalRevenueToday, specifier: "%.2f")")
                    Text("This Month's Revenue: $\(totalRevenueThisMonth, specifier: "%.2f")")
                }

                // Most Frequent Customers Section
                Section(header: Text("Most Frequent Customers")) {
                    ForEach(mostFrequentCustomers, id: \.id) { customer in
                        VStack(alignment: .leading) {
                            Text(customer.ownerName).font(.headline)
                            Text("Visits: \(customer.charges.count)")
                        }
                    }
                }

                // Popular Services Section
                Section(header: Text("Popular Services")) {
                    ForEach(Array(popularServices.keys), id: \.self) { service in
                        HStack {
                            Text(service)
                            Spacer()
                            Text("\(popularServices[service] ?? 0) times")
                        }
                    }
                }

                // Appointment Statistics Section
                Section(header: Text("Appointment Statistics")) {
                    Text("Completed: \(appointmentStats.completed)")
                    Text("Canceled: \(appointmentStats.canceled)")
                    Text("Upcoming: \(appointmentStats.upcoming)")
                }
            }
            .navigationTitle("Metrics Dashboard")
        }
    }
}
