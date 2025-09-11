<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.weather.model.WeatherPredictor" %>
<%@ page import="com.weather.model.WeatherPrediction" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.File" %>
<%@ page import="utils.ForecastUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div style="display:none">
    Parameters received:
    lat: <%= request.getParameter("lat") %>
    lon: <%= request.getParameter("lon") %>
    location: <%= request.getParameter("location") %>
    city: <%= request.getParameter("city") %>
    name: <%= request.getParameter("name") %>
    
    Session values:
    lat: <%= session.getAttribute("lat") %>
    lon: <%= session.getAttribute("lon") %>
    selectedCity: <%= session.getAttribute("selectedCity") %>
</div>
<%
     String latParam = request.getParameter("lat");
    String lonParam = request.getParameter("lon");

    // Validate lat/lon inputs
    boolean isLatValid = latParam != null && !latParam.trim().equalsIgnoreCase("null") && !latParam.trim().isEmpty();
    boolean isLonValid = lonParam != null && !lonParam.trim().equalsIgnoreCase("null") && !lonParam.trim().isEmpty();

    String lat = isLatValid ? latParam : (String) session.getAttribute("lat");
    String lon = isLonValid ? lonParam : (String) session.getAttribute("lon");

    // Final fallback if session doesn't have values either
    if (lat == null || lon == null) {
        lat = "22.341719287521432"; 
        lon = "73.19475797806366";
    }

    // Save for future use
    session.setAttribute("lat", lat);
    session.setAttribute("lon", lon);
    // You may still use selectedCity logic if your model uses cities instead of lat/lon
    String selectedCity = request.getParameter("location");
    if (selectedCity == null || selectedCity.isEmpty()) {
        selectedCity = request.getParameter("name");
    }
    
    WeatherPredictor predictor = new WeatherPredictor();
    String dataDir = application.getRealPath("/WEB-INF/data");
    File dir = new File(dataDir);
    boolean setupRequired = false;
    
    if (!dir.exists()) {
        boolean dirCreated = dir.mkdirs();
        if (!dirCreated) {
            throw new RuntimeException("Failed to create data directory at: " + dataDir);
        }
        setupRequired = true;
    }

    String dataFilePath = dataDir + File.separator + "Final.csv";
    File dataFile = new File(dataFilePath);
    if (!dataFile.exists()) {
        setupRequired = true;
        request.setAttribute("setup", true);
        request.setAttribute("dataFilePath", dataFilePath);
    } else if (!dataFile.canRead()) {
        throw new RuntimeException("Data file exists but cannot be read: " + dataFilePath);
    } else {
        try {
            long startTime = System.currentTimeMillis();
            predictor.trainModel(dataFilePath);
            long trainingTime = System.currentTimeMillis() - startTime;
            System.out.println("Model training completed in " + trainingTime + "ms");

            // After loading cities list
            List<String> cities = predictor.getAvailableLocations();
            request.setAttribute("cities", cities);

            // Set default city to Vadodara
            String defaultCity = "Vadodara";

            selectedCity = request.getParameter("location");
            if (selectedCity == null || selectedCity.isEmpty()) {
                selectedCity = request.getParameter("city");
            }
            if (selectedCity == null || selectedCity.isEmpty()) {
                selectedCity = (String) session.getAttribute("selectedCity");
            }
            if (selectedCity == null || selectedCity.isEmpty()) {
                // First try to find Vadodara in the available cities
                boolean vadodaraExists = cities.stream().anyMatch(city -> 
                        city.equalsIgnoreCase(defaultCity));

                if (vadodaraExists) {
                    selectedCity = defaultCity;
                } else {
                    // If Vadodara is not in the list, use the first city
                    selectedCity = cities.isEmpty() ? defaultCity : cities.get(0);
                }
            }

            request.setAttribute("selectedCity", selectedCity);
            session.setAttribute("selectedCity", selectedCity);
            if (!selectedCity.isEmpty()) {
                List<WeatherPrediction> forecast = predictor.generate5DayForecast(selectedCity);
                request.setAttribute("forecast", forecast);

                Map<String, Double> tempTrend = predictor.get5DayTemperatureTrend(selectedCity);
                request.setAttribute("tempTrend", tempTrend);

                Map<String, Double> humidityTrend = new HashMap<>();
                Map<String, Double> precipTrend = new HashMap<>();
                Random random = new Random(System.currentTimeMillis());

                for (Map.Entry<String, Double> entry : tempTrend.entrySet()) {
                    double baseHumidity = 70.0;
                    double tempFactor = (25.0 - entry.getValue()) * 0.5;
                    double randomVariation = (random.nextDouble() - 0.5) * 15.0;
                    double humidity = Math.min(Math.max(baseHumidity + tempFactor + randomVariation, 30.0), 95.0);
                    humidityTrend.put(entry.getKey(), humidity);

                    double tempEffect = entry.getValue() > 28 ? -10.0 : entry.getValue() < 15 ? 15.0 : 0.0;
                    double humidityEffect = (humidity - 65.0) * 1.2;
                    double precipChance = Math.min(Math.max(30.0 + tempEffect + humidityEffect +
                            (random.nextDouble() - 0.5) * 20.0, 5.0), 95.0);
                    precipTrend.put(entry.getKey(), precipChance);
                }

                request.setAttribute("humidityTrend", humidityTrend);
                request.setAttribute("precipTrend", precipTrend);

                List<Map<String, Object>> hourlyForecast = ForecastUtil.generateHourlyForecast(forecast, precipTrend, random);
                request.setAttribute("hourlyForecast", hourlyForecast);

                session.setAttribute("cachedForecast_" + selectedCity, forecast);
                session.setAttribute("lastForecastTime", System.currentTimeMillis());
            }
        } catch (Exception e) {
            String errorMsg = "Error processing weather data: " + e.getMessage();
            request.setAttribute("error", errorMsg);
            System.err.println(errorMsg);
            e.printStackTrace();
            StringBuffer stackInfo = new StringBuffer();
            for (StackTraceElement element : e.getStackTrace()) {
                stackInfo.append(element.toString()).append("\n");
            }
            request.setAttribute("stackTrace", stackInfo.toString());
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather Forecast of <c:out value="${selectedCity}" /> | Weatherly</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="forcast.css" type="text/css">
</head>
<body>
    <!-- Include Navigation -->
    <jsp:include page="common-navbar.jsp" />

    <div class="page-header">
        <div class="container">
            <h1 class="page-title">Weather Forecast</h1>
            <p class="lead"><c:out value="${selectedCity}" /></p>
        </div>
    </div>

    <div class="container">
        <c:if test="${setup}">
            <div class="alert alert-info">
                <h3>Setup Required</h3>
                <p>To use this application, you need to set up the data directory and CSV file:</p>
                <ol>
                    <li>Create a directory at: <code>${pageContext.servletContext.getRealPath('/WEB-INF/data')}</code></li>
                    <li>Place your Final.csv file in this directory</li>
                </ol>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <h4>Error:</h4>
                <p>${error}</p>
            </div>
        </c:if>

        <c:if test="${not empty forecast}">
            <h3 class="section-heading">5-Day Forecast</h3>
            <div class="row">
                <c:forEach items="${forecast}" var="day" varStatus="loop">
                    <div class="col-md-4 mb-3">
                        <div class="weather-card">
                            <div class="forecast-header">
                                <h4>${day.date}</h4>
                                <div class="weather-icon">
                                    <c:choose>
                                        <c:when test="${day.condition == 'Sunny' || day.condition == 'Clear'}">
                                            <i class="fas fa-sun"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Cloudy' || day.condition == 'Partly Cloudy'}">
                                            <i class="fas fa-cloud"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Rain' || day.condition == 'Showers'}">
                                            <i class="fas fa-cloud-rain"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Thunderstorm'}">
                                            <i class="fas fa-bolt"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-cloud-sun"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <h5>${day.condition}</h5>
                            </div>
                            <div class="card-body">
                                <div class="temp-value">
                                    <fmt:formatNumber value="${day.temperature}" pattern="#0.0" />°C
                                </div>
                                <div class="weather-detail">
                                    <i class="fas fa-tint"></i>
                                    <span>Humidity: <fmt:formatNumber value="${day.humidity}" pattern="#0.0" />%</span>
                                </div>
                                <div class="weather-detail">
                                    <i class="fas fa-wind"></i>
                                    <span>Wind: <fmt:formatNumber value="${day.windSpeed}" pattern="#0.0" /> km/h</span>
                                </div>
                                <div class="weather-detail">
                                    <i class="fas fa-umbrella"></i>
                                    <span>Precipitation: <fmt:formatNumber value="${precipTrend[day.date]}" pattern="#0" />%</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="chart-container">
                <h3 class="section-heading">Temperature Trend</h3>
                <canvas id="temperatureChart"></canvas>
            </div>
            <br>
            <h3 class="section-heading">Hourly Forecast (Next 24 Hours)</h3>
                <c:if test="${not empty hourlyForecast}">
                    <div class="hourly-forecast">
                        <%-- Static time values for 24 hours --%>
                        <c:set var="hourLabels" value="00:00,01:00,02:00,03:00,04:00,05:00,06:00,07:00,08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00,18:00,19:00,20:00,21:00,22:00,23:00" />
                        <c:set var="hourLabelsArray" value="${fn:split(hourLabels, ',')}" />

                        <c:forEach var="hour" items="${hourlyForecast}" varStatus="status">
                            <div class="hour-card">
                                <div class="time-column">${hourLabelsArray[status.index % 24]}</div>
                                <div class="icon-column">
                                    <div class="weather-icon">
                                        <c:choose>
                                            <c:when test="${hour['condition'] == 'Sunny' || hour['condition'] == 'Clear'}">
                                                <i class="fas fa-sun"></i>
                                            </c:when>
                                            <c:when test="${hour['condition'] == 'Cloudy' || hour['condition'] == 'Partly Cloudy'}">
                                                <i class="fas fa-cloud"></i>
                                            </c:when>
                                            <c:when test="${hour['condition'] == 'Rain' || hour['condition'] == 'Showers'}">
                                                <i class="fas fa-cloud-rain"></i>
                                            </c:when>
                                            <c:when test="${hour['condition'] == 'Thunderstorm'}">
                                                <i class="fas fa-bolt"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-cloud-sun"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="temp-column"><fmt:formatNumber value="${hour['temperature']}" pattern="#0.0" />°C</div>
                                <div class="condition-column">${hour['condition']}</div>
                            </div>
                            <c:if test="${!status.last}">
                                <hr class="hour-separator">
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${empty hourlyForecast}">
                    <div class="alert alert-warning">No hourly forecast data available.</div>
                </c:if>
        </c:if>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

    <c:if test="${not empty forecast}">
        <script>
            const tempCtx = document.getElementById('temperatureChart').getContext('2d');
            const tempLabels = [
                <c:forEach items="${tempTrend}" var="entry" varStatus="status">
                    "${entry.key}"<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            const tempData = [
                <c:forEach items="${tempTrend}" var="entry" varStatus="status">
                    ${entry.value}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            const gradient = tempCtx.createLinearGradient(0, 0, 0, 400);
            gradient.addColorStop(0, 'rgba(52, 152, 219, 0.7)');
            gradient.addColorStop(1, 'rgba(52, 152, 219, 0.1)');

            new Chart(tempCtx, {
                type: 'line',
                data: {
                    labels: tempLabels,
                    datasets: [{
                        label: 'Temperature (°C)',
                        data: tempData,
                        borderColor: '#3498db',
                        backgroundColor: gradient,
                        borderWidth: 3,
                        fill: true,
                        pointBackgroundColor: '#2980b9',
                        pointBorderColor: '#fff',
                        pointRadius: 6,
                        pointHoverRadius: 8,
                        tension: 0.3
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: {
                                font: {
                                    size: 14
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0, 0, 0, 0.7)',
                            titleFont: {
                                size: 16
                            },
                            bodyFont: {
                                size: 14
                            },
                            padding: 12
                        }
                    },
                    scales: {
                        y: { 
                            beginAtZero: false,
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)'
                            },
                            ticks: {
                                font: {
                                    size: 12
                                }
                            }
                        },
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)'
                            },
                            ticks: {
                                font: {
                                    size: 12
                                }
                            }
                        }
                    },
                    layout: {
                        padding: {
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 55
                        }
                    }
                }
            });
        </script>
        <script>
            window.onload = function() {
                const urlParams = new URLSearchParams(window.location.search);
                const lat = urlParams.get('lat');
                const lon = urlParams.get('lon');
                
                // If parameters are null or missing, update the URL with the actual values
                if (lat === 'null' || lat === null || lon === 'null' || lon === null) {
                    const actualLat = "${lat}";
                    const actualLon = "${lon}";
                    const cityName = "${selectedCity}";
                    
                    // Update URL without refreshing the page
                    if (actualLat && actualLon) {
                        const newUrl = window.location.pathname + '?lat=' + actualLat + '&lon=' + actualLon + '&city=' + encodeURIComponent(cityName);
                        window.history.replaceState({}, document.title, newUrl);
                    }
                }
            };
        </script>
    </c:if>

    <footer>
        <div class="container text-center">
            <p class="mb-0">&copy; <%= java.time.Year.now().getValue() %> Weatherly. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>