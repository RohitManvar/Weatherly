<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="com.weather.model.CurrentWeather" %>
<% 
    // Retrieve lat, lon, and location from request/session attributes
    String lat = (String) request.getAttribute("lat");
    String lon = (String) request.getAttribute("lon");
    String location = (String) request.getAttribute("location");

    // If the location is not available in the request, fallback to session
    if (location == null || location.isEmpty()) {
        location = "Vadodara"; // Default fallback location
    }

    // If lat and lon are still null, retrieve them from session
    if (lat == null || lon == null) {
        lat = (String) session.getAttribute("lat");
        lon = (String) session.getAttribute("lon");
    }

    // Set default coordinates if no lat/lon are available
    if (lat == null || lon == null) {
        lat = "22.341719287521432";  // Vadodara latitude
        lon = "73.19475797806366";   // Vadodara longitude
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <c:if test="${empty location}">
    <c:set var="location" value="Vadodara" scope="request" />
    </c:if>
    <title>Weather in ${location} | Weatherly</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="weather.css" type="text/css">
</head>
<body>
    <!-- Include Navigation -->
    <jsp:include page="common-navbar.jsp" />
    
    <div class="page-header">
        <div class="container">
            <h1 class="page-title">Weather in ${location}</h1>
            <p class="lead">Get accurate forecasts and current conditions</p>
        </div>
    </div>
    
    <div class="container mb-5">
        <div class="mb-4 d-flex justify-content-between align-items-center">
            <h2 class="section-heading">Current Conditions</h2>
            <div>
                <span class="text-muted">
                    Last updated: <fmt:formatDate value="${requestScope.lastUpdated}" pattern="HH:mm:ss" />
                </span>
                <form action="weather" method="get" class="d-inline ml-2">
                    <input type="hidden" name="location" value="${location}">
                    <button type="submit" class="btn btn-sm btn-primary">Refresh</button>
                </form>
            </div>
        </div>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>
        
        <div class="row">
            <!-- Current Weather Card -->
            <div class="col-md-6 mb-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Current Weather</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h2 class="text-primary">${current.temperature}°C</h2>
                            <h4>${current.condition}</h4>
                            <p class="text-muted">
                                <jsp:useBean id="currentDate" class="java.util.Date" />
                                <fmt:formatDate value="${currentDate}" pattern="EEEE, MMMM d, yyyy" />
                            </p>
                        </div>
                        
                        <hr>
                        
                        <div class="row">
                            <div class="col-6 col-md-4 mb-3">
                                <div>
                                    <span>Humidity</span>
                                    <h6><i class="fas fa-tint text-primary mr-2"></i>${current.humidity}%</h6>
                                </div>
                            </div>
                            <div class="col-6 col-md-4 mb-3">
                                <div>
                                    <span>Wind</span>
                                    <h6><i class="fas fa-wind text-primary mr-2"></i>${current.windSpeed} km/h</h6>
                                </div>
                            </div>
                            <div class="col-6 col-md-4 mb-3">
                                <div>
                                    <span>Pressure</span>
                                    <h6><i class="fas fa-compress-alt text-primary mr-2"></i>${current.pressure} hPa</h6>
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <p class="mb-0 text-muted">
                                    <c:choose>
                                        <c:when test="${current.temperature > 30}">
                                            <strong>Hot weather alert:</strong> Stay hydrated and avoid direct sun exposure.
                                        </c:when>
                                        <c:when test="${current.temperature < 5}">
                                            <strong>Cold weather alert:</strong> Bundle up and watch for icy conditions.
                                        </c:when>
                                        <c:when test="${fn:contains(current.condition, 'Rain')}">
                                            <strong>Rain alert:</strong> Don't forget your umbrella!
                                        </c:when>
                                    </c:choose>
                                </p>
                            </div>
                                
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Weather Forecast Summary -->
            <div class="col-md-6 mb-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Weather Analysis</h5>
                    </div>
                    <div class="card-body">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Parameter</th>
                                    <th>Value</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Temperature</td>
                                    <td>${current.temperature}°C</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${current.temperature > 30}">
                                                <span class="text-danger">High</span>
                                            </c:when>
                                            <c:when test="${current.temperature < 10}">
                                                <span class="text-primary">Low</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-success">Normal</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Humidity</td>
                                    <td>${current.humidity}%</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${current.humidity > 80}">
                                                <span class="text-warning">High</span>
                                            </c:when>
                                            <c:when test="${current.humidity < 30}">
                                                <span class="text-warning">Low</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-success">Normal</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Wind Speed</td>
                                    <td>${current.windSpeed} km/h</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${current.windSpeed > 50}">
                                                <span class="text-danger">Strong</span>
                                            </c:when>
                                            <c:when test="${current.windSpeed > 20}">
                                                <span class="text-warning">Moderate</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-success">Light</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        
                        <div class="mt-3">
                            <p><strong>Weather Summary:</strong> 
                                <%-- Replace JSP expression with scriptlet for dynamic weather summary --%>
                                <%
                                   try {
                                       String condition = (String) request.getAttribute("current.condition");
                                       if (condition == null) condition = "unknown";

                                       Object tempObj = request.getAttribute("current.temperature");
                                       double temp = 0;
                                       if (tempObj != null) {
                                           try {
                                               temp = Double.parseDouble(tempObj.toString());
                                           } catch (NumberFormatException e) {
                                               temp = 0;  
                                            }
                                       }

                                       Object humidityObj = request.getAttribute("current.humidity");
                                       int humidity = 0;
                                       if (humidityObj != null) {
                                           try {
                                               humidity = Integer.parseInt(humidityObj.toString());
                                           } catch (NumberFormatException e) {
                                               humidity = 0;  
                                           }
                                       }

                                       StringBuilder summary = new StringBuilder("Weather Summary: Today is ");
                                       summary.append(condition.toLowerCase()).append(" with ");
                                       summary.append("a temperature of ").append(temp).append("°C");

                                       if (temp > 30) {
                                           summary.append(". It's quite hot today.");
                                       } else if (temp < 10) {
                                           summary.append(". It's quite cold today.");
                                       } else {
                                           summary.append(". Temperature is comfortable.");
                                       }

                                       if (humidity > 80) {
                                           summary.append(" Humidity is high.");
                                       }

                                       out.print(summary.toString());
                                   } catch (Exception e) {
                                       out.print("Weather data currently unavailable");
                                   }
                               %>

                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Temperature Trend Section -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Temperature Trend</h5>
            </div>
            <div class="card-body">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>Temperature (°C)</th>
                            <th>Trend</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${trendMap}" var="entry" varStatus="status">
                            <tr>
                                <td>${entry.key}</td>
                                <td>${entry.value}°C</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${status.index > 0 && entry.value > previousTemp}">
                                            <span class="text-danger">↑ Rising</span>
                                        </c:when>
                                        <c:when test="${status.index > 0 && entry.value < previousTemp}">
                                            <span class="text-primary">↓ Falling</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-secondary">→ Stable</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <c:set var="previousTemp" value="${entry.value}" />
                        </c:forEach>
                    </tbody>
                </table>
                
                <%-- Calculate average temperature using Java scriptlet --%>
                <% 
                    try {
                        java.util.Map<String, Double> trendMap = 
                            (java.util.Map<String, Double>)request.getAttribute("trendMap");
                        double totalTemp = 0;
                        if (trendMap != null && !trendMap.isEmpty()) {
                            for (Double temp : trendMap.values()) {
                                totalTemp += temp;
                            }
                            request.setAttribute("avgTemperature", totalTemp / trendMap.size());
                        } else {
                            request.setAttribute("avgTemperature", 0);
                        }
                    } catch (Exception e) {
                        request.setAttribute("avgTemperature", 0);
                    }
                %>
                <p class="mt-3">
                    <strong>Average temperature:</strong> 
                    <fmt:formatNumber value="${avgTemperature}" pattern="#.##"/>°C
                </p>
            </div>
        </div>
        
        <!-- 5 Day Forecast Preview -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">5-Day Forecast</h5>
                <a href="forcast.jsp?location=${location}" class="btn btn-sm btn-primary">View Full Forecast</a>
            </div>
            <div class="card-body p-0">
                <table class="table table-bordered mb-0">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Temperature</th>
                            <th>Condition</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${forecast}" var="day" begin="0" end="4">
                            <tr>
                                <td>${day.date}</td>
                                <td>${day.temperature}°C</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${day.condition == 'Sunny' || day.condition == 'Clear'}">
                                            <i class="fas fa-sun text-warning mr-2"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Cloudy' || day.condition == 'Partly Cloudy'}">
                                            <i class="fas fa-cloud text-secondary mr-2"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Rain' || day.condition == 'Showers'}">
                                            <i class="fas fa-cloud-rain text-primary mr-2"></i>
                                        </c:when>
                                        <c:when test="${day.condition == 'Thunderstorm'}">
                                            <i class="fas fa-bolt text-warning mr-2"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-cloud-sun text-info mr-2"></i>
                                        </c:otherwise>
                                    </c:choose>
                                    ${day.condition}
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <footer>
        <div class="container text-center">
            <p class="mb-0">&copy; <%= java.time.Year.now().getValue() %> Weatherly. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // Add location to server-side search history via Ajax
        document.addEventListener('DOMContentLoaded', function() {
            // Using fetch API to call the Java servlet for adding to search history
            fetch('addToHistory?location=${location}', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }).then(response => {
                if (!response.ok) {
                    console.log('Failed to add to history');
                }
            });
        });
    </script>
</body>
</html>