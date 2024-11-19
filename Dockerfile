# Taking Base Image Java  this specifies the base image that the build will extend.

FROM eclipse-temurin:17-jdk-alpine
    
# Exose the Port Number   This instruction sets configuration on the image that indicates a port the image would like to expose.

EXPOSE 8080
 
#This instruction sets an environment variable that a running container will use.

ENV APP_HOME /usr/src/app

# This instruction tells the builder to copy files from the host and put them into the container image.

COPY target/*.jar $APP_HOME/app.jar

#This instruction specifies the "working directory" or the path in the image where files will be copied and commands will be executed.

WORKDIR $APP_HOME

#This instruction sets the default command a container using this image will run.

CMD ["java", "-jar", "app.jar"]
