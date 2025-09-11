// Use My Location
document.getElementById('getLocationBtn').addEventListener('click', function () {
    const errorDiv = document.getElementById('locationError');
    errorDiv.textContent = '';

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (position) {
                const lat = position.coords.latitude;
                const lon = position.coords.longitude;
                window.location.href = 'weather?lat=' + lat + '&lon=' + lon;
            },
            function (error) {
                errorDiv.textContent = "Error getting location. Please try again or enter city manually.";
            }
        );
    } else {
        errorDiv.textContent = "Geolocation is not supported by this browser.";
    }
});
