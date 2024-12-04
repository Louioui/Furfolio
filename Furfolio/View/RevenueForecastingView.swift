//
//  RevenueForecastingView.swift
//
//  View folder
//
//

import SwiftUI
import Charts

struct RevenueForecastingView: View {
    @State private var forecastedRevenue: Double = 0.0
    @State private var revenueData: [MonthlyRevenueData] = []
    @State private var goal: Double = 5000.0  // Default goal value
    @State private var customGoal: String = ""  // For dynamic goal input
    
    // Sample data structure to represent monthly revenue
    struct MonthlyRevenueData: Identifiable {  // Conforming to Identifiable
        let id = UUID()  // Unique identifier for each entry
        let month: String
        let actualRevenue: Double
        let forecastedRevenue: Double
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title for the view
                    Text("Revenue Forecasting")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    // Dynamic Goal Input Section
                    goalSection
                    
                    // Display forecast
                    forecastSection
                    
                    // Revenue trend chart
                    revenueTrendChart
                    
                    // Revenue metrics
                    revenueMetrics
                }
                .padding()
            }
            .navigationTitle("Revenue Forecast")
            .onAppear {
                loadData()
                calculateForecast()
            }
        }
    }

    // MARK: - Goal Section (Dynamic Goal Input)
    private var goalSection: some View {
        VStack(alignment: .leading) {
            Text("Set Your Revenue Goal")
                .font(.headline)
            
            HStack {
                TextField("Enter Goal", text: $customGoal)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: setGoal) {
                    Text("Set Goal")
                        .bold()
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Forecast Section
    private var forecastSection: some View {
        VStack(alignment: .leading) {
            Text("Forecasted Revenue for Next Month")
                .font(.headline)
            Text("Estimated revenue: $\(forecastedRevenue, specifier: "%.2f")")
                .font(.title)
                .foregroundColor(.green)
                .bold()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Revenue Trend Chart
    private var revenueTrendChart: some View {
        VStack(alignment: .leading) {
            Text("Revenue Trends Over the Last Year")
                .font(.headline)

            if revenueData.isEmpty {
                Text("No data available for revenue trends.")
                    .foregroundColor(.gray)
            } else {
                Chart(revenueData) { data in
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Forecasted Revenue", data.forecastedRevenue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue)
                    
                    PointMark(
                        x: .value("Month", data.month),
                        y: .value("Actual Revenue", data.actualRevenue)
                    )
                    .foregroundStyle(Color.red)
                }
                .frame(height: 300)
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
        .cornerRadius(10)
    }

    // MARK: - Revenue Metrics
    private var revenueMetrics: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Revenue Metrics")
                .font(.headline)
            
            HStack {
                Text("Goal: $\(goal, specifier: "%.2f")")
                Spacer()
                Text("Achieved: $\(calculateTotalRevenue(), specifier: "%.2f")")
            }
            
            HStack {
                Text("Average Revenue Per Customer: $\(calculateAverageRevenuePerCustomer(), specifier: "%.2f")")
                Spacer()
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Helper Methods
    private func loadData() {
        // Simulating fetching revenue data. Replace this with actual data fetching logic
        revenueData = [
            MonthlyRevenueData(month: "Jan", actualRevenue: 4500, forecastedRevenue: 4700),
            MonthlyRevenueData(month: "Feb", actualRevenue: 4900, forecastedRevenue: 5100),
            MonthlyRevenueData(month: "Mar", actualRevenue: 5200, forecastedRevenue: 5300),
            MonthlyRevenueData(month: "Apr", actualRevenue: 5500, forecastedRevenue: 5600),
            MonthlyRevenueData(month: "May", actualRevenue: 5800, forecastedRevenue: 6000),
            MonthlyRevenueData(month: "Jun", actualRevenue: 6000, forecastedRevenue: 6200),
        ]
    }

    private func calculateForecast() {
        // Simple forecasting logic: Take the average of forecasted revenues and project next month's revenue
        let totalForecastedRevenue = revenueData.reduce(0.0) { $0 + $1.forecastedRevenue }
        let averageForecast = totalForecastedRevenue / Double(revenueData.count)
        forecastedRevenue = averageForecast
    }

    private func calculateTotalRevenue() -> Double {
        // Calculate the total revenue from the actual revenue data
        return revenueData.reduce(0.0) { $0 + $1.actualRevenue }
    }

    private func calculateAverageRevenuePerCustomer() -> Double {
        // Example calculation: Average revenue per customer (this could be more complex in reality)
        return calculateTotalRevenue() / Double(revenueData.count)
    }

    // MARK: - Dynamic Goal Handling
    private func setGoal() {
        if let newGoal = Double(customGoal) {
            goal = newGoal
            customGoal = ""  // Clear input field
        }
    }
}

struct RevenueForecastingView_Previews: PreviewProvider {
    static var previews: some View {
        RevenueForecastingView()
    }
}
