# To-Do List App iOS

Welcome to the **To-Do List App iOS**! This is a simple To-Do list app built with SwiftUI that fetches date and live weather data using the OpenWeatherMap API. You can add tasks, check them off, and see current weather information for your location.

---

## Features: 
- Add tasks to your to-do list 
- Check off tasks when completed
- Fetch current weather data from the OpenWeatherMap API
- Fetch current date 

---

## Setup Instructions

Before running this project locally, you need to add your **API Key** from **OpenWeatherMap**. Follow the steps below:

### 1. Get Your OpenWeatherMap API Key

1. Go to the [OpenWeatherMap website](https://openweathermap.org/api) and subscribe to the free API plan (limited to 1000 calls a day).
2. Check your email for your API key and instructions.
3. You can change your weather call location to your city. The current file default is Toronto

---

### 2. Add Your API Key to the Project

1. Open the `ContentView.swift` file in the project.
2. Find the line where the API Key is set. It should look something like this:

   ```swift
   private let apiKey = "API_KEY"
