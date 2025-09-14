package com.weather.model;

/**
 * Represents a weather record with current conditions and forecasted data.
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
     * Creates a weather record with all parameters.
     *
     * @param city          City name
     * @param date          Date or timestamp of the record
     * @param temperature   Temperature value
     * @param humidity      Humidity value
     * @param condition     Weather condition (e.g., "Clear", "Rain")
     * @param precipitation Precipitation amount
     * @param windSpeed     Wind speed
     * @param pressure      Atmospheric pressure
     */
    public WeatherRecord(String city, String date, double temperature, double humidity, String condition, double precipitation) {
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
     * Simplified constructor for ML prediction data that might not have all fields.
     *
     * @param city        City name
     * @param date        Date or timestamp of the record
     * @param temperature Temperature value
     * @param humidity    Humidity value
     * @param windSpeed   Wind speed
     * @param condition   Weather condition
     */
    public WeatherRecord(String city, String date, double temperature, double humidity,
                         double windSpeed, String condition) {
        this(city, date, temperature, humidity, condition, 0.0);
    }

    /**
     * Constructor that creates a WeatherRecord from a WeatherPrediction.
     *
     * @param prediction A WeatherPrediction object
     */
    public WeatherRecord(WeatherPrediction prediction) {
        this(prediction.getLocation(),
             prediction.getDate() != null ? prediction.getDate() : "Prediction",
             prediction.getTemperature(),
             prediction.getHumidity(),
             prediction.getCondition(),
             0.0);
    }

    // ===================== Getters =====================

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

    // ===================== Setters =====================

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

    // ===================== Utility =====================

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
