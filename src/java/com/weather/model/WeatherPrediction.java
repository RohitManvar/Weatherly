package com.weather.model;

/**
 * Class representing a weather prediction result
 */
public class WeatherPrediction {
    private String location;
    private double temperature;
    private double humidity;
    private double windSpeed;
    private String condition;
    private String date; // Added date field for forecast

    /**
     * Constructor for WeatherPrediction
     * @param location The location name
     * @param temperature Predicted temperature
     * @param humidity Predicted humidity
     * @param windSpeed Predicted wind speed
     * @param condition Predicted weather condition
     */
    public WeatherPrediction(String location, double temperature, double humidity, double windSpeed, String condition) {
        this.location = location;
        this.temperature = temperature;
        this.humidity = humidity;
        this.windSpeed = windSpeed;
        this.condition = condition;
    }

    // Getters and setters
    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public double getTemperature() {
        return temperature;
    }

    public void setTemperature(double temperature) {
        this.temperature = temperature;
    }

    public double getHumidity() {
        return humidity;
    }

    public void setHumidity(double humidity) {
        this.humidity = humidity;
    }

    public double getWindSpeed() {
        return windSpeed;
    }

    public void setWindSpeed(double windSpeed) {
        this.windSpeed = windSpeed;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }
    
    public String getDate() {
        return date;
    }
    
    public void setDate(String date) {
        this.date = date;
    }
    

    @Override
    public String toString() {
        return "WeatherPrediction{" +
                "location='" + location + '\'' +
                ", temperature=" + temperature +
                ", humidity=" + humidity +
                ", windSpeed=" + windSpeed +
                ", condition='" + condition + '\'' +
                ", date='" + date + '\'' +
                '}';
    }
}