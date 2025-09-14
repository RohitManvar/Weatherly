package com.weather.model;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Utility class for loading weather data from a dataset and performing basic prediction.
 */
public class WeatherDataset {
    private Map<String, List<WeatherRecord>> dataByCity;

    public WeatherDataset(String datasetPath) throws IOException {
        dataByCity = new HashMap<>();
        loadDataset(datasetPath);
    }

    /**
     * Loads the CSV weather dataset and stores it grouped by city.
     */
    private void loadDataset(String path) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(path));
        String line;

        // Skip header
        reader.readLine();

        while ((line = reader.readLine()) != null) {
            String[] parts = line.split(",");
            if (parts.length >= 8) {
                try {
                    String city = parts[0].trim();
                    String date = parts[1].trim();
                    double temperature = Double.parseDouble(parts[2].trim());
                    double humidity = Double.parseDouble(parts[3].trim());
                    String condition = parts[4].trim();
                    double precipitation = Double.parseDouble(parts[5].trim());
                    double windSpeed = Double.parseDouble(parts[6].trim());
                    double pressure = Double.parseDouble(parts[7].trim());

                    WeatherRecord record = new WeatherRecord(city, date, temperature, humidity, condition, precipitation);
                    dataByCity.computeIfAbsent(city, k -> new ArrayList<>()).add(record);
                } catch (NumberFormatException e) {
                    // Skip malformed rows
                    e.printStackTrace();
                }
            }
        }
        reader.close();
    }

    /**
     * Predicts the weather for a given city and date using a simple average of recent records.
     */
    public WeatherPrediction predictWeather(String city, String date) {
        if (!dataByCity.containsKey(city)) {
            return new WeatherPrediction(city, Double.NaN, Double.NaN, Double.NaN, "Unknown");
        }

        List<WeatherRecord> cityData = dataByCity.get(city);
        if (cityData.isEmpty()) {
            return new WeatherPrediction(city, Double.NaN, Double.NaN, Double.NaN, "Unknown");
        }

        int recordsToUse = Math.min(3, cityData.size());
        double tempSum = 0, humiditySum = 0, precipSum = 0, windSpeedSum = 0;
        Map<String, Integer> conditionCount = new HashMap<>();

        for (int i = cityData.size() - recordsToUse; i < cityData.size(); i++) {
            WeatherRecord record = cityData.get(i);
            tempSum += record.getTemperature();
            humiditySum += record.getHumidity();
            precipSum += record.getPrecipitation();
            windSpeedSum += record.getWindSpeed();

            conditionCount.put(record.getCondition(),
                    conditionCount.getOrDefault(record.getCondition(), 0) + 1);
        }

        double avgTemp = tempSum / recordsToUse;
        double avgHumidity = humiditySum / recordsToUse;
        double avgPrecip = precipSum / recordsToUse;
        double avgWindSpeed = windSpeedSum / recordsToUse;

        // Determine the most frequent condition
        String predictedCondition = "Sunny";
        int maxCount = 0;
        for (Map.Entry<String, Integer> entry : conditionCount.entrySet()) {
            if (entry.getValue() > maxCount) {
                maxCount = entry.getValue();
                predictedCondition = entry.getKey();
            }
        }

        // Seasonal adjustment
        try {
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
            Date predictDate = format.parse(date);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(predictDate);
            int month = calendar.get(Calendar.MONTH);

            if (month >= 5 && month <= 7) { // Summer
                avgTemp += 2.0;
                avgPrecip -= 0.05;
            } else if (month >= 11 || month <= 1) { // Winter
                avgTemp -= 2.0;
                avgPrecip += 0.1;
            }

            // Adjust condition based on precipitation
            if (avgPrecip > 0.5) {
                predictedCondition = "Rainy";
            } else if (avgPrecip > 0.1) {
                predictedCondition = "Cloudy";
            }

        } catch (Exception e) {
            // Ignore date parsing errors
        }

        return new WeatherPrediction(city, avgTemp, avgHumidity, avgWindSpeed, predictedCondition);
    }
}
