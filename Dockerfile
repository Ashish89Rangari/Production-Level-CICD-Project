# Create a base image

FROM eclipse-temurin:17-jdk-alpine

# Exposing the port
    
EXPOSE 8080

# ENV provides default values for variables that can be accessed within the container
# Sets environment variables. We can have multiple variables in a single dockerfile
 
ENV APP_HOME /usr/src/app

# Copies files and directories to the container.

COPY target/*.jar $APP_HOME/app.jar

# Sets the working directory for the instructions that follow.

WORKDIR $APP_HOME

# CMD provides a command and arguments for an executing container. There can be only one CMD.

CMD ["java", "-jar", "app.jar"]