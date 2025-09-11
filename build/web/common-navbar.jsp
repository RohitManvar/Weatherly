<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container">
    <a class="navbar-brand" href="index.jsp">
      <i class="fas fa-cloud-sun mr-2"></i>Weatherly
    </a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav mr-auto">
        <li class="nav-item">
          <a class="nav-link" href="index.jsp">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="weather?location=Vadodara">Current Weather</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="forcast.jsp?location=${sessionScope.location}">5-Day Forecast</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="about.jsp">About</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
