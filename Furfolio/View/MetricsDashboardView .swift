//
//  MetricsDashboardView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//
import SwiftUI

struct MetricsDashboardView: View {
    let dogOwners: [DogOwner]

    // Total revenue calculation
    var totalRevenue: Double {
        dogOwners.flatMap { $0.charges }.reduce(0) { $0 + $1.amount }
    }

    // Most frequent customers calculation based on number of charges
    var mostFrequentCustomers: [DogOwner] {
        dogOwners.sorted { $0.charges.count > $1.charges.count }.prefix(3).map { $0 }
    }

    // Popular services calculation (counting how often each service was performed)
    var popularServices: [String: Int] {
        var serviceCounts: [String: Int] = [:]
        dogOwners.flatMap { $0.charges }.forEach { charge in
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

        dogOwners.flatMap { $0.appointments }.forEach { appointment in
            if appointment.date < now {
                completed += 1
            } else {
                upcoming += 1
            }
        }
        return (completed, canceled, upcoming)
    }

    var body: some View {
        NavigationView {
            List {
                // Total Revenue
                Section(header: Text("Total Revenue")) {
                    Text("Total Revenue: $\(totalRevenue, specifier: "%.2f")")
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
                    Text("Upcoming: \(appointmentStats.upcoming)")
                }

                // Next Appointment for each Dog Owner
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


