FROM tomcat:9.0
RUN rm -rf /usr/local/tomcat/webapps/*
COPY weather.war /usr/local/tomcat/webapps/weather.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
