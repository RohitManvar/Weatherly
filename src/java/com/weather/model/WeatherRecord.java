package com.weather.model;

/**
 * Represents a weather record with current conditions and forecasted data
 */
public class WeatherRecord {
    private String city;
    private String date;
    private double temperature;
    private double humidity;
    private String condition;
    private double precipitation;
    private double windSpeed;
    private double pressure;

    /**
     * Creates a weather record with all parameters
     */
    public WeatherRecord(String city, String date, double temperature, double humidity,
                         String condition, double precipitation, double windSpeed, double pressure) {
        this.city = city;
        this.date = date;
        this.temperature = temperature;
        this.humidity = humidity;
        this.condition = condition;
        this.precipitation = precipitation;
        this.windSpeed = windSpeed;
        this.pressure = pressure;
    }
    
    /**
     * Simplified constructor for ML prediction data that might not have all fields
     */
    public WeatherRecord(String city, String date, double temperature, double humidity,
                         double windSpeed, String condition) {
        this.city = city;
        this.date = date;
        this.temperature = temperature;
        this.humidity = humidity;
        this.windSpeed = windSpeed;
        this.condition = condition;
        this.precipitation = 0.0; // Default value
        this.pressure = 0.0; // Default value
    }
    
    /**
     * Constructor that creates a WeatherRecord from a WeatherPrediction
     */
    public WeatherRecord(WeatherPrediction prediction) {
        this.city = prediction.getLocation();
        this.date = "Prediction"; // Indicating this is a prediction
        this.temperature = prediction.getTemperature();
        this.humidity = prediction.getHumidity();
        this.windSpeed = prediction.getWindSpeed();
        this.condition = prediction.getCondition();
        this.precipitation = 0.0; // Default since prediction doesn't have this
        this.pressure = 0.0; // Default since prediction doesn't have this
    }

    // Getters
    public String getCity() {
        return city;
    }
    
    public String getDate() {
        return date;
    }
    
    public double getTemperature() {
        return temperature;
    }
    
    public double getHumidity() {
        return humidity;
    }
    
    public String getCondition() {
        return condition;
    }
    
    public double getPrecipitation() {
        return precipitation;
    }
    
    public double getWindSpeed() {
        return windSpeed;
    }
    
    public double getPressure() {
        return pressure;
    }

    // Setters
    public void setCity(String city) {
        this.city = city;
    }
    
    public void setDate(String date) {
        this.date = date;
    }
    
    public void setTemperature(double temperature) {
        this.temperature = temperature;
    }
    
    public void setHumidity(double humidity) {
        this.humidity = humidity;
    }
    
    public void setCondition(String condition) {
        this.condition = condition;
    }
    
    public void setPrecipitation(double precipitation) {
        this.precipitation = precipitation;
    }
    
    public void setWindSpeed(double windSpeed) {
        this.windSpeed = windSpeed;
    }
    
    public void setPressure(double pressure) {
        this.pressure = pressure;
    }

    // toString for debugging
    @Override
    public String toString() {
        return "WeatherRecord{" +
                "city='" + city + '\'' +
                ", date='" + date + '\'' +
                ", temperature=" + temperature +
                ", humidity=" + humidity +
                ", condition='" + condition + '\'' +
                ", precipitation=" + precipitation +
                ", windSpeed=" + windSpeed +
                ", pressure=" + pressure +
                '}';
    }
}