<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About | Weatherly</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="index.css" type="text/css">
</head>
<body>
    <!-- Navigation -->
    <jsp:include page="common-navbar.jsp" />

    <div class="hero-section">
        <div class="container">
            <h1>About Weatherly</h1>
            <p class="lead">Smart weather forecasting powered by real-time APIs and machine learning models</p>
        </div>
    </div>

    <main class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">🚀 Features</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item">Live Weather Data: Instantly fetch current weather information such as temperature, humidity, wind speed, and weather conditions using OpenWeatherMap API.</li>
                            <li class="list-group-item">Hourly Forecasts: View temperature trends throughout the day in a clean and interactive UI.</li>
                            <li class="list-group-item">5-Day Predictions: Our ML models predict future weather conditions using past weather data for more accurate and localized forecasts.</li>
                            <li class="list-group-item">Weather Classification: Determine weather conditions (like sunny, rainy, or cloudy) using classification models.</li>
                            <li class="list-group-item">Location-Based Redirect: Automatically redirects based on user location for personalized forecasts.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">🔧 Technologies Used</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item">Java (Servlets & JSP) for backend and frontend integration.</li>
                            <li class="list-group-item">Machine Learning for weather prediction and classification.</li>
                            <li class="list-group-item">HTML, CSS & JavaScript for interactive UI and dynamic elements.</li>
                            <li class="list-group-item">OpenWeatherMap API for current weather data.</li>
                            <li class="list-group-item">Chart.js for displaying forecast charts.</li>
                            <li class="list-group-item">NetBeans IDE for development and deployment.</li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">🧠 How It Works</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item">User Input or Location → Fetches city name or geolocation.</li>
                            <li class="list-group-item">API Request → Fetches current weather details using OpenWeatherMap.</li>
                            <li class="list-group-item">ML Prediction → Loads local models to predict future weather patterns.</li>
                            <li class="list-group-item">Visualization → Data is displayed in a clean, user-friendly interface.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">👨‍💻 Developers</h5>
                    </div>
                    <div class="card-body">
                        <p class="mb-0">This project was developed as part of a practical learning experience to integrate real-time data APIs with machine learning using Java-based web technologies.</p>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <div class="container text-center">
            <p class="mb-0">&copy; <%= java.time.Year.now().getValue() %> Weatherly. All rights reserved.</p>
        </div>
    </footer>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>