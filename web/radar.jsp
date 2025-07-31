<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather Radar - Weatherly</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
    <link rel="stylesheet" href="index.css" type="text/css">
    <style>
        #map {
            height: 500px;
            width: 100%;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .controls {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="common-navbar.jsp" />

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Weather Radar</li>
                    </ol>
                </nav>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h3><i class="fas fa-satellite-dish mr-2"></i>Live Weather Radar</h3>
            </div>
            <div class="card-body">
                <div class="controls">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">Location</span>
                                </div>
                                <input type="text" id="location-input" class="form-control" placeholder="Enter location">
                                <div class="input-group-append">
                                    <button class="btn btn-outline-secondary" type="button" id="search-btn">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">Layer</span>
                                </div>
                                <select id="layer-select" class="form-control">
                                    <option value="precipitation_new">Precipitation</option>
                                    <option value="clouds_new">Clouds</option>
                                    <option value="temp_new">Temperature</option>
                                    <option value="wind_new">Wind</option>
                                    <option value="pressure_new">Pressure</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <button id="use-location-btn" class="btn btn-primary btn-block">
                                <i class="fas fa-map-marker-alt mr-2"></i>Use My Location
                            </button>
                        </div>
                    </div>
                </div>
                
                <div id="map"></div>
                
                <div class="mt-3">
                    <p class="text-muted"><i class="fas fa-info-circle mr-2"></i>Map data is powered by OpenWeatherMap API. Refresh the page to update the radar data.</p>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Weatherly. All rights reserved.</p>
        </div>
    </footer>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
    <script>
        $(document).ready(function() {
            // Default coordinates (center of the map)
            let lat = 22.3072;  // Default to Vadodara, India
            let lon = 73.1812;
            let mapZoom = 8;
            
            // OpenWeatherMap API key (same as used in your servlet)
            const apiKey = 'c971764fb766f7bba0bbccd5e4a182ab';
            
            // Initialize the map
            const map = L.map('map').setView([lat, lon], mapZoom);
            
            // Add base map layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
            
            // Add weather radar layer
            let weatherLayer;
            
            function addWeatherLayer(layer) {
                if (weatherLayer) {
                    map.removeLayer(weatherLayer);
                }
                
                weatherLayer = L.tileLayer(`https://tile.openweathermap.org/map/${layer}/{z}/{x}/{y}.png?appid=${apiKey}`, {
                    attribution: '&copy; <a href="https://openweathermap.org">OpenWeatherMap</a>',
                    maxZoom: 18
                }).addTo(map);
            }
            
            // Default to precipitation layer
            addWeatherLayer('precipitation_new');
            
            // Handle layer selection change
            $('#layer-select').change(function() {
                addWeatherLayer($(this).val());
            });
            
            // Handle location search
            $('#search-btn').click(function() {
                searchLocation();
            });
            
            $('#location-input').keypress(function(e) {
                if (e.which === 13) {
                    searchLocation();
                }
            });
            
            function searchLocation() {
                const location = $('#location-input').val().trim();
                if (location) {
                    // Geocode the location
                    $.ajax({
                        url: `https://api.openweathermap.org/geo/1.0/direct?q=${encodeURIComponent(location)}&limit=1&appid=${apiKey}`,
                        method: 'GET',
                        success: function(data) {
                            if (data && data.length > 0) {
                                lat = data[0].lat;
                                lon = data[0].lon;
                                map.setView([lat, lon], mapZoom);
                            } else {
                                alert('Location not found. Please try again.');
                            }
                        },
                        error: function() {
                            alert('Error searching for location. Please try again.');
                        }
                    });
                }
            }
            
            // Handle "Use My Location" button
            $('#use-location-btn').click(function() {
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(function(position) {
                        lat = position.coords.latitude;
                        lon = position.coords.longitude;
                        map.setView([lat, lon], mapZoom);
                    }, function() {
                        alert('Unable to get your location. Please allow location access or enter a location manually.');
                    });
                } else {
                    alert('Geolocation is not supported by your browser.');
                }
            });
        });
    </script>
</body>
</html>