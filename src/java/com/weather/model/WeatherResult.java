package com.weather.model;

public class WeatherResult {
    private String city;
    private String condition;
    private double temperature;
    private double rainfall;

    // Constructors
    public WeatherResult() {}

    public WeatherResult(String city, String condition, double temperature, double rainfall) {
        this.city = city;
        this.condition = condition;
        this.temperature = temperature;
        this.rainfall = rainfall;
    }

    // Getters and Setters
    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }

    public double getTemperature() {
        return temperature;
    }

    public void setTemperature(double temperature) {
        this.temperature = temperature;
    }

    public double getRainfall() {
        return rainfall;
    }

    public void setRainfall(double rainfall) {
        this.rainfall = rainfall;
    }
}
