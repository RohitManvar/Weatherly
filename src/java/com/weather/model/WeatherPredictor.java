package com.weather.model;

import java.util.*;
import java.util.HashSet;
import java.util.Collections;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Random;

/**
 * Provides machine learning capabilities for weather prediction
 * - Regression for continuous values (temperature, humidity)
 * - Classification for categorical values (weather condition)
 * - 5-day forecast generation based on historical data patterns
 */
public class WeatherPredictor {
    // Data structures for our models
    private Map<String, List<WeatherRecord>> recordsByLocation;
    private Map<String, Map<String, Integer>> conditionFrequencyByLocation;
    private Map<String, Map<String, Double>> averagesByLocation;
    private boolean isModelTrained = false;

    public WeatherPredictor() {
        recordsByLocation = new HashMap<>();
        conditionFrequencyByLocation = new HashMap<>();
        averagesByLocation = new HashMap<>();
    }

    /**
     * Loads data from CSV file and trains the prediction models
     * @param csvFilePath Path to the CSV file relative to WEB-INF directory
     * @throws IOException If file cannot be read
     */
    public void trainModel(String csvFilePath) throws IOException {
        Path path = Paths.get(csvFilePath);
        try (BufferedReader br = new BufferedReader(new FileReader(path.toFile()))) {
            String line;
            boolean headerSkipped = false;
            
            while ((line = br.readLine()) != null) {
                // Skip header row
                if (!headerSkipped) {
                    headerSkipped = true;
                    continue;
                }
                
                // Parse CSV row
                String[] values = line.split(",");
                if (values.length >= 6) {
                    try {
                        String location = values[0].trim() + "," + values[1].trim(); // e.g., "Gujarat,Ahmedabad"
                        String date = values[2].trim(); // or Year if you want
                        double temperature = Double.parseDouble(values[6].trim()); // avgTemp
                        double humidity = Double.parseDouble(values[11].trim());   // Rainfall
                        double windSpeed = Double.parseDouble(values[8].trim());   // maxTemp
                        String condition = values[3].trim(); // Season or Crop (your choice)

                        WeatherRecord record = new WeatherRecord(location, date, temperature,
                                                                 humidity, windSpeed, condition);

                        recordsByLocation.putIfAbsent(location, new ArrayList<>());
                        recordsByLocation.get(location).add(record);
                    } catch (NumberFormatException e) {
                        System.err.println("Invalid number format in row: " + line);
                    }
                }
            }
            
            // Train the models once data is loaded
            buildClassificationModel();
            calculateAverages();
            isModelTrained = true;
        }
    }
    
    /**
     * Builds a frequency-based classification model for weather conditions
     */
    private void buildClassificationModel() {
        for (String location : recordsByLocation.keySet()) {
            Map<String, Integer> conditionCounts = new HashMap<>();
            
            // Count frequencies of each condition
            for (WeatherRecord record : recordsByLocation.get(location)) {
                String condition = record.getCondition();
                conditionCounts.put(condition, conditionCounts.getOrDefault(condition, 0) + 1);
            }
            
            conditionFrequencyByLocation.put(location, conditionCounts);
        }
    }
    
    /**
     * Calculates average values for regression predictions
     */
    private void calculateAverages() {
        for (String location : recordsByLocation.keySet()) {
            List<WeatherRecord> records = recordsByLocation.get(location);
            
            // Calculate averages for numeric fields
            double avgTemp = records.stream().mapToDouble(WeatherRecord::getTemperature).average().orElse(0);
            double avgHumidity = records.stream().mapToDouble(WeatherRecord::getHumidity).average().orElse(0);
            double avgWindSpeed = records.stream().mapToDouble(WeatherRecord::getWindSpeed).average().orElse(0);
            
            // Store averages
            Map<String, Double> locationAverages = new HashMap<>();
            locationAverages.put("temperature", avgTemp);
            locationAverages.put("humidity", avgHumidity);
            locationAverages.put("windSpeed", avgWindSpeed);
            
            averagesByLocation.put(location, locationAverages);
        }
    }
    
    /**
     * Predict weather condition for a location using classification model
     * @param location The location name
     * @return Most likely weather condition, or "Unknown" if not enough data
     */
    public String predictWeatherCondition(String location) {
        if (!isModelTrained) {
            return "Model not trained";
        }
        
        // Check if we have data for this location
        Map<String, Integer> conditionCounts = conditionFrequencyByLocation.get(location);
        if (conditionCounts == null || conditionCounts.isEmpty()) {
            return "Unknown";
        }
        
        // Find the most common condition
        String mostCommonCondition = null;
        int maxCount = 0;
        
        for (Map.Entry<String, Integer> entry : conditionCounts.entrySet()) {
            if (entry.getValue() > maxCount) {
                maxCount = entry.getValue();
                mostCommonCondition = entry.getKey();
            }
        }
        
        return mostCommonCondition != null ? mostCommonCondition : "Unknown";
    }
    
    /**
     * Get predicted temperature for a location
     * @param location The location name
     * @return Predicted temperature or NaN if no data
     */
    public double predictTemperature(String location) {
        if (!isModelTrained) {
            return Double.NaN;
        }
        
        Map<String, Double> averages = averagesByLocation.get(location);
        return averages != null ? averages.get("temperature") : Double.NaN;
    }
    
    /**
     * Get predicted humidity for a location
     * @param location The location name
     * @return Predicted humidity or NaN if no data
     */
    public double predictHumidity(String location) {
        if (!isModelTrained) {
            return Double.NaN;
        }
        
        Map<String, Double> averages = averagesByLocation.get(location);
        return averages != null ? averages.get("humidity") : Double.NaN;
    }
    
    /**
     * Get predicted wind speed for a location
     * @param location The location name
     * @return Predicted wind speed or NaN if no data
     */
    public double predictWindSpeed(String location) {
        if (!isModelTrained) {
            return Double.NaN;
        }
        
        Map<String, Double> averages = averagesByLocation.get(location);
        return averages != null ? averages.get("windSpeed") : Double.NaN;
    }
    
    /**
     * Get all available cities in the dataset
     * @return List of city names
     */
    public List<String> getAvailableLocations() {
        // In your sample dataset, it looks like location might be the state, not city
        // Let's adjust to extract unique cities from your dataset format
        Set<String> uniqueCities = new HashSet<>();
    
        for (String location : recordsByLocation.keySet()) {
            // If your data is in format "State,City" or contains city information
            // Extract just the city part
            String[] parts = location.split(",");
            if (parts.length >= 2) {
                uniqueCities.add(parts[1].trim());
            } else {
                // If it's just a single location name, use that
                uniqueCities.add(location.trim());
            }
        }
    
        // Return as sorted list
        List<String> sortedCities = new ArrayList<>(uniqueCities);
        Collections.sort(sortedCities);
        return sortedCities;
    }
    
    /**
     * Returns a map of date to temperature for the given city
     * Useful for temperature forecast chart
     * @param cityName The city to extract temperatures for
     * @return Map of date string to temperature value
     */
    public Map<String, Double> getTemperatureTrend(String cityName) {
        Map<String, Double> trendMap = new TreeMap<>(); // TreeMap to keep order

        for (String location : recordsByLocation.keySet()) {
            if (location.endsWith("," + cityName)) {
                for (WeatherRecord record : recordsByLocation.get(location)) {
                    trendMap.put(record.getDate(), record.getTemperature());
                }
            }
        }

        return trendMap;
    }

    /**
     * Generate a complete weather prediction for a location
     * @param cityName The city name
     * @return A WeatherPrediction object with all predictions
     */
    public WeatherPrediction generatePrediction(String cityName) {
        if (!isModelTrained) {
            return new WeatherPrediction(cityName, Double.NaN, Double.NaN, Double.NaN, "Model not trained");
        }

        // Try to match city name
        for (String location : recordsByLocation.keySet()) {
            if (location.endsWith("," + cityName)) {
                double temperature = predictTemperature(location);
                double humidity = predictHumidity(location);
                double windSpeed = predictWindSpeed(location);
                String condition = predictWeatherCondition(location);
                return new WeatherPrediction(cityName, temperature, humidity, windSpeed, condition);
            }
        }

        return new WeatherPrediction(cityName, Double.NaN, Double.NaN, Double.NaN, "Unknown");
    }
    
    /**
    * Generate a 5-day forecast for the specified city
    * @param cityName The city name
    * @return List of WeatherPrediction objects for the next 5 days
    */
   public List<WeatherPrediction> generate5DayForecast(String cityName) {
       List<WeatherPrediction> forecast = new ArrayList<>();

       if (!isModelTrained) {
           // Return empty list if model not trained
           return forecast;
       }

       // Find matching location
       String matchedLocation = null;
       for (String location : recordsByLocation.keySet()) {
           if (location.endsWith("," + cityName) || location.equals(cityName)) {
               matchedLocation = location;
               break;
           }
       }

       if (matchedLocation == null) {
           return forecast; // Return empty list if location not found
       }

       // Get base prediction
       double baseTemp = predictTemperature(matchedLocation);
       double baseHumidity = predictHumidity(matchedLocation);
       double baseWindSpeed = predictWindSpeed(matchedLocation);
       String baseCondition = predictWeatherCondition(matchedLocation);

       // Get seasonal patterns if available
       Map<String, Double> seasonalTempVariation = getSeasonalTemperatureVariation(matchedLocation);
       Map<String, Double> seasonalHumidityVariation = getSeasonalHumidityVariation(matchedLocation);

       // Get date formatter
       DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
       LocalDate currentDate = LocalDate.now();

       // Generate 5-day forecast with slight variations
       Random random = new Random();
       for (int i = 1; i <= 5; i++) {
           LocalDate forecastDate = currentDate.plus(i, ChronoUnit.DAYS);
           String dateString = forecastDate.format(formatter);

           // Apply seasonal variation and a small random factor for more realistic forecasts
           double tempVariation = getVariationForDate(seasonalTempVariation, forecastDate) + 
                                 (random.nextDouble() * 4.0 - 2.0); // +/- 2°C random variation
           double humidityVariation = getVariationForDate(seasonalHumidityVariation, forecastDate) + 
                                     (random.nextDouble() * 10.0 - 5.0); // +/- 5% random variation
           double windVariation = (random.nextDouble() * 6.0 - 3.0); // +/- 3km/h random variation

           // Calculate forecast values
           double forecastTemp = baseTemp + tempVariation;
           double forecastHumidity = Math.min(100, Math.max(0, baseHumidity + humidityVariation)); // Keep between 0-100%
           double forecastWindSpeed = Math.max(0, baseWindSpeed + windVariation); // Keep positive

           // Potentially change condition based on temperature change
           String forecastCondition = determineConditionFromTemp(baseTemp, forecastTemp, baseCondition);

           WeatherPrediction dayForecast = new WeatherPrediction(
               cityName, 
               forecastTemp, 
               forecastHumidity, 
               forecastWindSpeed, 
               forecastCondition
           );
           dayForecast.setDate(dateString);

           forecast.add(dayForecast);
       }

       return forecast;
   }

   /**
    * Determine weather condition based on temperature changes
    * @param baseTemp Base temperature
    * @param forecastTemp Forecast temperature
    * @param baseCondition Base condition
    * @return Predicted condition
    */
   private String determineConditionFromTemp(double baseTemp, double forecastTemp, String baseCondition) {
       double tempDifference = forecastTemp - baseTemp;

       // If temperature increases significantly, more likely to be sunny
       if (tempDifference > 5.0) {
           return "Sunny";
       }
       // If temperature drops significantly, more likely to be rainy or cloudy
       else if (tempDifference < -5.0) {
           return "Rainy";
       }
       // For moderate drops, cloudy
       else if (tempDifference < -2.0) {
           return "Cloudy";
       }
       // For slight increase, partly cloudy
       else if (tempDifference > 2.0) {
           return "Partly Cloudy";
       }

       // Default to base condition if no significant change
       return baseCondition;
   }

   /**
    * Get seasonal temperature variation for a location
    * @param location Location to analyze
    * @return Map of month to temperature variation
    */
   private Map<String, Double> getSeasonalTemperatureVariation(String location) {
       Map<String, Double> monthlyVariation = new HashMap<>();

       List<WeatherRecord> records = recordsByLocation.get(location);
       if (records == null || records.isEmpty()) {
           return monthlyVariation;
       }

       // Group records by month and calculate average temperature for each month
       Map<String, List<Double>> tempsByMonth = new HashMap<>();
       double overallAvg = records.stream().mapToDouble(WeatherRecord::getTemperature).average().orElse(0);

       for (WeatherRecord record : records) {
           try {
               String date = record.getDate();
               // Extract month from date (assuming format YYYY-MM-DD)
               if (date.contains("-") && date.length() >= 7) {
                   String month = date.substring(5, 7); // Get month part

                   tempsByMonth.putIfAbsent(month, new ArrayList<>());
                   tempsByMonth.get(month).add(record.getTemperature());
               }
           } catch (Exception e) {
               // Skip invalid dates
               continue;
           }
       }

       // Calculate average temperature deviation for each month
       for (Map.Entry<String, List<Double>> entry : tempsByMonth.entrySet()) {
           double monthAvg = entry.getValue().stream().mapToDouble(Double::doubleValue).average().orElse(0);
           monthlyVariation.put(entry.getKey(), monthAvg - overallAvg);
       }

       return monthlyVariation;
   }

   /**
    * Get seasonal humidity variation for a location
    * @param location Location to analyze
    * @return Map of month to humidity variation
    */
   private Map<String, Double> getSeasonalHumidityVariation(String location) {
       Map<String, Double> monthlyVariation = new HashMap<>();

       List<WeatherRecord> records = recordsByLocation.get(location);
       if (records == null || records.isEmpty()) {
           return monthlyVariation;
       }

       // Group records by month and calculate average humidity for each month
       Map<String, List<Double>> humidityByMonth = new HashMap<>();
       double overallAvg = records.stream().mapToDouble(WeatherRecord::getHumidity).average().orElse(0);

       for (WeatherRecord record : records) {
           try {
               String date = record.getDate();
               // Extract month from date (assuming format YYYY-MM-DD)
               if (date.contains("-") && date.length() >= 7) {
                   String month = date.substring(5, 7); // Get month part

                   humidityByMonth.putIfAbsent(month, new ArrayList<>());
                   humidityByMonth.get(month).add(record.getHumidity());
               }
           } catch (Exception e) {
               // Skip invalid dates
               continue;
           }
       }

       // Calculate average humidity deviation for each month
       for (Map.Entry<String, List<Double>> entry : humidityByMonth.entrySet()) {
           double monthAvg = entry.getValue().stream().mapToDouble(Double::doubleValue).average().orElse(0);
           monthlyVariation.put(entry.getKey(), monthAvg - overallAvg);
       }

       return monthlyVariation;
   }

   /**
    * Get variation for a specific date based on seasonal patterns
    * @param monthlyVariation Map of month to variation values
    * @param date The date to check
    * @return Variation value for the date
    */
   private double getVariationForDate(Map<String, Double> monthlyVariation, LocalDate date) {
       if (monthlyVariation.isEmpty()) {
           return 0.0;
       }

       String month = String.format("%02d", date.getMonthValue());
       return monthlyVariation.getOrDefault(month, 0.0);
   }

   /**
    * Get temperature trend data for a 5-day forecast
    * @param cityName The city name
    * @return Map of date to temperature for forecasted days
    */
   public Map<String, Double> get5DayTemperatureTrend(String cityName) {
       Map<String, Double> trendMap = new TreeMap<>(); // TreeMap to keep dates ordered

       List<WeatherPrediction> forecast = generate5DayForecast(cityName);
       for (WeatherPrediction prediction : forecast) {
           trendMap.put(prediction.getDate(), prediction.getTemperature());
       }

       return trendMap;
   }
}