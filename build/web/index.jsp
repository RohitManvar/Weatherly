<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weatherly - Smart Weather Forecasting</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="index.css" type="text/css">
</head>
<body>
    <jsp:include page="common-navbar.jsp" />

    <div class="hero-section">
        <div class="container">
            <h1>Weatherly</h1>
            <p class="lead">Accurate weather forecasts powered by machine learning</p>
        </div>
    </div>

    <main class="container mt-4">
        <!-- Search Form -->
        <div class="row justify-content-center">
            <div class="col-md-8">
                <form action="${pageContext.request.contextPath}/weather" method="post">
                    <div class="input-group mb-3">
                        <input type="text" name="location" class="form-control" placeholder="Enter city name..." required>
                        <div class="input-group-append">
                            <button class="btn btn-primary" type="submit">
                                <i class="fas fa-search mr-2"></i>Get Weather
                            </button>
                        </div>
                    </div>
                </form>

                <!-- Use My Location -->
                <button id="getLocationBtn" class="btn btn-secondary btn-block mb-3">
                    <i class="fas fa-map-marker-alt mr-2"></i>Use My Location
                </button>
                <div class="text-danger" id="locationError"></div>

                <!-- Error message display -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger mt-3">${error}</div>
                </c:if>
            </div>
        </div>

        <!-- Recent Searches and Radar Map Sections -->
        <div class="row mt-4">
            <!-- Recent Searches Section -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Recent Searches</h5>
                    </div>
                    <div class="card-body">
                        <div id="recentSearches">
                            <c:choose>
                                <c:when test="${empty recentSearches}">
                                    <p class="text-muted">No recent searches</p>
                                </c:when>
                                <c:otherwise>
                                    <ul class="list-group">
                                        <c:forEach items="${recentSearches}" var="search">
                                            <li class="list-group-item">
                                                <form action="${pageContext.request.contextPath}/weather" method="post" class="mb-0">
                                                    <input type="hidden" name="location" value="${search}">
                                                    <button type="submit" class="btn btn-link p-0">
                                                        <i class="fas fa-history mr-2 text-secondary"></i>${search}
                                                    </button>
                                                </form>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Radar Map Section -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Weather Radar</h5>
                    </div>
                    <div class="card-body text-center">
                        <a href="radar.jsp" class="radar-link">
                            <div class="radar-preview">
                                <i class="fas fa-radar fa-4x mb-3 text-primary"></i>
                                <h4>View Live Radar Map</h4>
                                <p class="text-muted">Click to see real-time precipitation and weather patterns</p>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Weatherly. All rights reserved.</p>
        </div>
    </footer>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="index.js"></script>
    <script>
        // Add click event for radar link
        $(document).ready(function() {
            $('.radar-link').click(function(e) {
                e.preventDefault();
                window.location.href = 'radar.jsp';
            });
        });
    </script>
</body>
</html>
