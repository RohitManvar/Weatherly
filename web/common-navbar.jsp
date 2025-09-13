<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
      <i class="fas fa-cloud-sun mr-2"></i>Weatherly
    </a>

    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav mr-auto align-items-center">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">Home</a>
        </li>

        <li class="nav-item">
          <form action="${pageContext.request.contextPath}/weather" method="post" class="d-inline">
            <input type="hidden" name="location" value="Vadodara">
            <button type="submit" class="nav-link btn btn-link px-2 align-baseline">Current Weather</button>
          </form>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/about.jsp">About</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
