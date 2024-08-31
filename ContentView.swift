//
//  ContentView.swift
//  To-Do List CRUD App
//
//  Created by Cathy Guo on 2024-08-26.
//

import SwiftUI

struct ContentView: View {
    @State private var tasks: [String] = UserDefaults.standard.stringArray(forKey: "tasks") ?? []
    @State private var newTask: String = ""
    @State private var editingTaskIndex: Int? = nil
    @FocusState private var isTaskEditingFocused: Bool
    @State private var weatherInfo: WeatherInfo? = nil

    private let apiKey = "79125d2117474e236fa65575fb76d8a1"

    private var currentDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFEBEE").edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    Text(currentDayString)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(currentDateString)
                        .font(.system(size: 35, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                    if let weather = weatherInfo {
                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#cdbda7"))
                                    .frame(width: 60, height: 60)
                                Text("\(weather.temperature)°C")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }

                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#cdbda7"))
                                    .frame(width: 60, height: 60)
                                Image(systemName: weather.iconSystemName)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    }

                    Text("To-Do:")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)

                    HStack {
                        TextField("New Task", text: $newTask)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: addTask) {
                            Image(systemName: "plus")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)

                    List {
                        ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                            HStack {
                                if editingTaskIndex == index {
                                    TextField("Edit Task", text: Binding(                                        get: { tasks[index] },
                                        set: { tasks[index] = $0 }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($isTaskEditingFocused)
                                    .onSubmit {
                                        editingTaskIndex = nil
                                        saveTasks()
                                    }
                                } else {
                                    Text(task)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .onTapGesture {
                                            editingTaskIndex = index
                                            isTaskEditingFocused = true
                                        }
                                }

                                Spacer()

                                Button(action: {
                                    deleteTask(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .padding()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .onAppear(perform: fetchWeather)
    }

    func fetchWeather() {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Toronto&units=metric&appid=\(apiKey)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let decoder = JSONDecoder()
            if let weatherData = try? decoder.decode(WeatherData.self, from: data) {
                DispatchQueue.main.async {
                    weatherInfo = WeatherInfo(from: weatherData)
                }
            } else {
                print("Failed to decode weather data")
            }
        }.resume()
    }

    func addTask() {
        if !newTask.isEmpty {
            tasks.append(newTask)
            saveTasks()
            newTask = ""
        }
    }

    func deleteTask(at index: Int) {
        tasks.remove(at: index)
        saveTasks()
    }

    func saveTasks() {
        UserDefaults.standard.set(tasks, forKey: "tasks")
    }
}

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]

    struct Main: Codable {
        let temp: Double
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }
}

struct WeatherInfo {
    let temperature: String
    let iconSystemName: String

    init(from weatherData: WeatherData) {
        self.temperature = String(format: "%.0f", weatherData.main.temp)
        self.iconSystemName = WeatherInfo.convertIconCodeToSystemName(icon: weatherData.weather.first?.icon ?? "01d")
    }

    static func convertIconCodeToSystemName(icon: String) -> String {
        switch icon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snowflake"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud"
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}

