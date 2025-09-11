package utils;

import java.util.*;
import com.weather.model.WeatherPrediction;
public class ForecastUtil {

    public static List<Map<String, Object>> generateHourlyForecast(
            List<WeatherPrediction> forecast,
            Map<String, Double> precipTrend,
            Random random) {

        List<Map<String, Object>> hourlyForecast = new ArrayList<>();
        Calendar cal = Calendar.getInstance();

        for (int i = 0; i < 24; i++) {
            Map<String, Object> hourData = new HashMap<>();

            cal.add(Calendar.HOUR_OF_DAY, 1);
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            hourData.put("hour", hour);

            double temp = 15 + random.nextDouble() * 10; // Simulated temp
            hourData.put("temperature", Math.round(temp * 10.0) / 10.0);

            String condition = (random.nextDouble() < 0.3) ? "Rain" : "Clear";
            hourData.put("condition", condition);

            hourlyForecast.add(hourData);
        }

        return hourlyForecast;
    }
}
