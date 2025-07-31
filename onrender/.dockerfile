FROM tomcat:9.0-jdk11-openjdk

# Remove default webapps (optional but clean)
RUN rm -rf /usr/local/tomcat/webapps/*

# Add your WAR file and deploy as ROOT.war
COPY weather.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat's default port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
