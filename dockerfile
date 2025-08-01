FROM tomcat:9.0-jdk17
COPY ./dist/WeatherApp.war /usr/local/tomcat/webapps/WeatherApp.war
EXPOSE 8080
