package com.weather.servlet;

import com.weather.model.WeatherPredictor;
import com.weather.model.WeatherPrediction;
import com.weather.model.CurrentWeather;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ForecastUtil;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collections;
import java.util.Random;

import org.json.JSONArray;
import org.json.JSONObject;

public class WeatherServlet extends HttpServlet {
    private WeatherPredictor predictor;
    private final String API_KEY = "c971764fb766f7bba0bbccd5e4a182ab"; // OpenWeatherMap API key
    private Map<String, Integer> locationSearchCount = new HashMap<>();

    @Override
    public void init() throws ServletException {
        super.init();
        predictor = new WeatherPredictor();
        String csvPath = null;
        try {
            csvPath = getServletContext().getRealPath("/WEB-INF/data/Final.csv");
            if (csvPath == null) {
                throw new IOException("Could not locate the CSV file path");
            }
            predictor.trainModel(csvPath);

            List<String> locations = predictor.getAvailableLocations();
            if (locations == null || locations.isEmpty()) {
                throw new ServletException("No location data was loaded from the CSV file");
            }

            log("Weather prediction model trained successfully with data from: " + csvPath);
            log("Available locations: " + locations.size());
        } catch (IOException e) {
            log("Failed to train weather prediction model from: " + csvPath, e);
            throw new ServletException("Failed to train weather prediction model", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String servletPath = request.getServletPath();

        // Handle radar request
        if ("/radar".equals(servletPath)) {
            request.getRequestDispatcher("/radar.jsp").forward(request, response);
            return;
        }

        String location = request.getParameter("location");
        String lat = request.getParameter("lat");
        String lon = request.getParameter("lon");

        // Default to Vadodara if no location or coordinates are provided
        if (location == null || location.trim().isEmpty()) {
            location = "Vadodara"; // Set default location
        }

        // Handle reverse geocoding if coordinates are provided
        if (lat != null && lon != null) {
            location = getLocationByCoordinates(lat, lon); // Get city from lat/lon
            log("Reverse geocoded city from (" + lat + "," + lon + "): " + location);
        }

        // Handle current weather
        if (location != null && !location.trim().isEmpty()) {
            location = location.trim();
            if (!predictor.getAvailableLocations().contains(location)) {
                request.setAttribute("error", "Location not found in our database: " + location);
                request.getRequestDispatcher("/index.jsp").forward(request, response);
                return;
            }

            // Add to recent searches
            addRecentSearch(request, location);

            // Set location to session for consistent reference
            request.getSession().setAttribute("location", location);

            WeatherPrediction prediction = predictor.generatePrediction(location);
            CurrentWeather currentWeather = fetchCurrentWeather(location);
            List<WeatherPrediction> fiveDayForecast = predictor.generate5DayForecast(location);

            if (prediction != null && currentWeather != null) {
                Map<String, Double> trendMap = predictor.getTemperatureTrend(location);
                Map<String, Double> forecastTrend = predictor.get5DayTemperatureTrend(location);
                List<Map<String, Object>> hourlyForecast = ForecastUtil.generateHourlyForecast(
                        fiveDayForecast, forecastTrend, new Random());

                request.setAttribute("location", location);
                request.setAttribute("prediction", prediction);
                request.setAttribute("current", currentWeather);
                request.setAttribute("trendMap", trendMap);
                request.setAttribute("forecast", fiveDayForecast);
                request.setAttribute("forecastTrend", forecastTrend);
                request.setAttribute("hourlyForecast", hourlyForecast);

                List<String> allLocations = predictor.getAvailableLocations();
                request.setAttribute("availableLocations", allLocations);

                request.getRequestDispatcher("/Weather.jsp").forward(request, response);
                return;
            } else {
                request.setAttribute("error", "Could not retrieve full weather information.");
                request.getRequestDispatcher("/index.jsp").forward(request, response);
                return;
            }
        } else {
            request.setAttribute("error", "Please enter a valid location.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }
    }

    // Handle POST requests by reusing doGet()
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void addRecentSearch(HttpServletRequest request, String location) {
        List<String> recentSearches = (List<String>) request.getSession().getAttribute("recentSearches");
        if (recentSearches == null) {
            recentSearches = new ArrayList<>();
        }

        if (!recentSearches.contains(location)) {
            recentSearches.add(0, location);
            if (recentSearches.size() > 5) {
                recentSearches.remove(5);
            }
        }

        request.getSession().setAttribute("recentSearches", recentSearches);
    }

    private CurrentWeather fetchCurrentWeather(String city) throws IOException {
        String apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=" +
                URLEncoder.encode(city, "UTF-8") + "&units=metric&appid=" + API_KEY;

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        if (conn.getResponseCode() != 200) {
            throw new IOException("OpenWeatherMap API returned status: " + conn.getResponseCode());
        }

        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder jsonResponse = new StringBuilder();
        String line;
        while ((line = in.readLine()) != null) {
            jsonResponse.append(line);
        }
        in.close();

        JSONObject obj = new JSONObject(jsonResponse.toString());

        CurrentWeather current = new CurrentWeather();
        current.setCity(obj.getString("name"));
        current.setTemperature(obj.getJSONObject("main").getDouble("temp"));
        current.setFeelsLike(obj.getJSONObject("main").getDouble("feels_like"));
        current.setHumidity(obj.getJSONObject("main").getDouble("humidity"));
        current.setPressure(obj.getJSONObject("main").getDouble("pressure"));
        current.setWindSpeed(obj.getJSONObject("wind").getDouble("speed"));
        current.setWindGust(obj.getJSONObject("wind").optDouble("gust", 0));
        current.setCondition(obj.getJSONArray("weather").getJSONObject(0).getString("main"));
        current.setDescription(obj.getJSONArray("weather").getJSONObject(0).getString("description"));
        current.setLatitude(obj.getJSONObject("coord").getDouble("lat"));
        current.setLongitude(obj.getJSONObject("coord").getDouble("lon"));
        current.setSunrise(obj.getJSONObject("sys").getLong("sunrise"));
        current.setSunset(obj.getJSONObject("sys").getLong("sunset"));
        current.setDate(java.time.LocalDate.now().toString());

        return current;
    }

    private String getLocationByCoordinates(String lat, String lon) {
        String cityName = "Unknown";
        try {
            String apiUrl = "https://api.openweathermap.org/geo/1.0/reverse?lat=" +
                    URLEncoder.encode(lat, "UTF-8") +
                    "&lon=" + URLEncoder.encode(lon, "UTF-8") +
                    "&limit=1&appid=" + API_KEY;

            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            if (conn.getResponseCode() == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder jsonResponse = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    jsonResponse.append(line);
                }
                in.close();

                JSONArray arr = new JSONArray(jsonResponse.toString());
                if (arr.length() > 0) {
                    JSONObject obj = arr.getJSONObject(0);
                    cityName = obj.getString("name");
                }
            } else {
                log("Failed reverse geocoding: " + conn.getResponseCode());
            }
        } catch (Exception e) {
            log("Error during reverse geocoding", e);
        }

        return cityName;
    }
}
