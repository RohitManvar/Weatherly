package com.weather.model;

/**
 * Class representing a weather prediction result.
 */
public class WeatherPrediction {
    private String location;
    private String date; // Added date field for forecast
    private double temperature;
    private double humidity;
    private double windSpeed;
    private String condition;

    /**
     * Constructor for WeatherPrediction (5 parameters - original)
     * Automatically sets date to "current".
     *
     * @param location   The location name
     * @param temperature Predicted temperature
     * @param humidity   Predicted humidity
     * @param windSpeed  Predicted wind speed
     * @param condition  Predicted weather condition
     */
    public WeatherPrediction(String location, double temperature, double humidity, double windSpeed, String condition) {
        this(location, "current", temperature, humidity, condition, windSpeed);
    }

    /**
     * Constructor for WeatherPrediction with date (6 parameters - recommended).
     *
     * @param location   The location name
     * @param date       The date/time of prediction
     * @param temperature Predicted temperature
     * @param humidity   Predicted humidity
     * @param condition  Predicted weather condition
     * @param windSpeed  Predicted wind speed
     */
    public WeatherPrediction(String location, String date, double temperature, double humidity, String condition, double windSpeed) {
        this.location = location;
        this.date = date;
        this.temperature = temperature;
        this.humidity = humidity;
        this.condition = condition;
        this.windSpeed = windSpeed;
    }

    // ===================== Getters & Setters =====================

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    // Alias for backward compatibility
    public String getCityName() {
        return location;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
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

    @Override
    public String toString() {
        return "WeatherPrediction{" +
                "location='" + location + '\'' +
                ", date='" + date + '\'' +
                ", temperature=" + temperature +
                ", humidity=" + humidity +
                ", windSpeed=" + windSpeed +
                ", condition='" + condition + '\'' +
                '}';
    }
}
