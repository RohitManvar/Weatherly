document.addEventListener('DOMContentLoaded', function() {
    // Update the "last updated" time
    updateLastUpdatedTime();
    
    // Initialize temperature chart if it exists
    initTemperatureChart();
    
    // Event listeners for buttons
    setupButtonListeners();
    
    // Setup theme toggle
    setupThemeToggle();
});

function updateLastUpdatedTime() {
    const now = new Date();
    const options = { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric', 
        hour: '2-digit', 
        minute: '2-digit' 
    };
    document.getElementById('updateTime').textContent = now.toLocaleString(undefined, options);
}

function initTemperatureChart() {
    const chartCanvas = document.getElementById('temperatureChart');
    if (!chartCanvas) return;
    
    // Get temperature trend data from the page (passed from servlet)
    // This would need to be populated from your backend
    // For now, we'll use dummy data
    const labels = [];
    const tempData = [];
    
    // Attempt to get actual data from your application
    const chartDataElements = document.querySelectorAll('.forecast-day');
    chartDataElements.forEach(day => {
        const date = day.querySelector('.forecast-subdate').textContent.trim();
        const temp = parseFloat(day.querySelector('.forecast-temp').textContent);
        
        if (date && !isNaN(temp)) {
            labels.push(date);
            tempData.push(temp);
        }
    });
    
    // If no data found, use dummy data
    if (labels.length === 0) {
        const dummyDates = ['Tomorrow', 'Day 2', 'Day 3', 'Day 4', 'Day 5'];
        const dummyTemps = [28, 26, 29, 27, 25];
        
        labels.push(...dummyDates);
        tempData.push(...dummyTemps);
    }
    
    // Create the chart
    new Chart(chartCanvas, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Temperature (°C)',
                data: tempData,
                borderColor: 'rgba(255, 99, 132, 1)',
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
                borderWidth: 2,
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        color: '#555'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.7)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    displayColors: false
                }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    grid: {
                        color: 'rgba(200, 200, 200, 0.2)'
                    },
                    ticks: {
                        color: '#666'
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: '#666'
                    }
                }
            }
        }
    });
}

function setupButtonListeners() {
    // Refresh button
    const refreshBtn = document.getElementById('refreshBtn');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', function() {
            location.reload();
        });
    }
    
    // Change location button
    const locationBtn = document.getElementById('locationBtn');
    if (locationBtn) {
        locationBtn.addEventListener('click', function() {
            window.location.href = 'index.jsp';
        });
    }
    
    // ML Prediction button
    const predictionBtn = document.getElementById('predictionBtn');
    if (predictionBtn) {
        predictionBtn.addEventListener('click', function() {
            // Get current URL
            const url = new URL(window.location.href);
            // Add or update showML parameter
            url.searchParams.set('showML', 'true');
            // Navigate to the new URL
            window.location.href = url.toString();
        });
    }
}

function setupThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    const icon = themeToggle.querySelector('i');
    const body = document.body;
    
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('weatherTheme');
    if (savedTheme === 'dark') {
        body.classList.add('dark-theme');
        icon.classList.remove('fa-moon');
        icon.classList.add('fa-sun');
    }
    
    // Theme toggle event
    themeToggle.addEventListener('click', function() {
        body.classList.toggle('dark-theme');
        
        if (body.classList.contains('dark-theme')) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
            localStorage.setItem('weatherTheme', 'dark');
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
            localStorage.setItem('weatherTheme', 'light');
        }
    });
}