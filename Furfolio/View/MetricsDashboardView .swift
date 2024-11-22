//
//  MetricsDashboardView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//
import SwiftUI
import _SwiftData_SwiftUI

struct MetricsDashboardView: View {
    let dogOwners: [DogOwner]
    let dailyRevenues: [DailyRevenue] // This is passed from ContentView
    
    // Total revenue calculation for today
    var totalRevenueToday: Double {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return dailyRevenues.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayStart) })?.amount ?? 0.0
    }

    // Total revenue calculation for the current month
    var totalRevenueThisMonth: Double {
        let currentMonthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return dailyRevenues.filter { $0.date >= currentMonthStart }
                             .reduce(0) { $0 + $1.amount }
    }

    // Most frequent customers based on the number of charges
    var mostFrequentCustomers: [DogOwner] {
        dogOwners.sorted { $0.charges.count > $1.charges.count }.prefix(3).map { $0 }
    }

    // Popular services based on the count of each service type performed
    var popularServices: [String: Int] {
        var serviceCounts: [String: Int] = [:]
        let allCharges = dogOwners.flatMap { $0.charges } // Collect all charges
        allCharges.forEach { charge in
            serviceCounts[charge.type, default: 0] += 1
        }
        return serviceCounts
    }

    // Appointment statistics: completed, canceled, and upcoming
    var appointmentStats: (completed: Int, canceled: Int, upcoming: Int) {
        var completed = 0
        var canceled = 0
        var upcoming = 0
        let now = Date()

        let allAppointments = dogOwners.flatMap { $0.appointments } // Collect all appointments
        allAppointments.forEach { appointment in
            if appointment.date < now {
                completed += 1
            } else {
                upcoming += 1
            }

            // Assuming you have a way to mark appointments as canceled
            if appointment.isCanceled {
                canceled += 1
            }
        }
        return (completed, canceled, upcoming)
    }

    var body: some View {
        NavigationView {
            List {
                // Total Revenue Today
                Section(header: Text("Total Revenue Today")) {
                    Text("Total Revenue: $\(totalRevenueToday, specifier: "%.2f")")
                }

                // Total Revenue This Month
                Section(header: Text("Total Revenue This Month")) {
                    Text("Total Revenue: $\(totalRevenueThisMonth, specifier: "%.2f")")
                }

                // Most Frequent Customers
                Section(header: Text("Most Frequent Customers")) {
                    ForEach(mostFrequentCustomers) { customer in
                        VStack(alignment: .leading) {
                            Text(customer.ownerName)
                                .font(.headline)
                            Text("Visits: \(customer.charges.count)")
                        }
                    }
                }

                // Popular Services
                Section(header: Text("Popular Services")) {
                    ForEach(Array(popularServices.keys), id: \.self) { service in
                        HStack {
                            Text(service)
                            Spacer()
                            Text("\(popularServices[service] ?? 0) times")
                        }
                    }
                }

                // Appointment Statistics
                Section(header: Text("Appointment Statistics")) {
                    Text("Completed: \(appointmentStats.completed)")
                    Text("Canceled: \(appointmentStats.canceled)")
                    Text("Upcoming: \(appointmentStats.upcoming)")
                }

                // Upcoming Appointments
                Section(header: Text("Upcoming Appointments")) {
                    ForEach(dogOwners) { owner in
                        if let nextAppointment = owner.nextAppointment {
                            VStack(alignment: .leading) {
                                Text("\(owner.ownerName)'s Next Appointment")
                                    .font(.headline)
                                Text("Date: \(nextAppointment.date, formatter: appointmentDateFormatter)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Metrics Dashboard")
        }
    }
}

// Custom date formatter for appointments
let appointmentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
