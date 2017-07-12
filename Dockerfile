FROM ubuntu:latest
MAINTAINER Harshit Prasad

# Update
RUN apt-get update
RUN apt-get upgrade -y

# add packages
RUN apt-get install -y git openjdk-8-jdk

#install gradle required for build
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-get update
RUN apt-get install -y wget
RUN wget https://services.gradle.org/distributions/gradle-3.4.1-bin.zip
RUN mkdir /opt/gradle
RUN apt-get install -y unzip
RUN unzip -d /opt/gradle gradle-3.4.1-bin.zip
RUN PATH=$PATH:/opt/gradle/gradle-3.4.1/bin
ENV GRADLE_HOME=/opt/gradle/gradle-3.4.1
ENV PATH=$PATH:$GRADLE_HOME/bin
RUN gradle -v
# install apache ftp server 1.1.0
RUN wget http://www-eu.apache.org/dist/mina/ftpserver/1.1.0/dist/apache-ftpserver-1.1.0.tar.gz
RUN tar xfz apache-ftpserver-1.1.0.tar.gz

# install RabbitMQ server
RUN wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.6/rabbitmq-server-generic-unix-3.6.6.tar.xz
RUN tar xf rabbitmq-server-generic-unix-3.6.6.tar.xz

# install erlang language for RabbitMQ
RUN apt-get install -y erlang



# clone the github repo
ADD . /yacy_grid_mcp
WORKDIR /yacy_grid_mcp

RUN cat config-ftp.properties > ../apache-ftpserver-1.1.0/res/conf/users.properties


# compile
RUN gradle build
RUN cp config-mcp.properties data/mcp-8100/conf/config.properties
RUN chmod +x ./start.sh
# Expose web interface ports
# 2121: ftp, a FTP server to be used for mass data / file storage
# 5672: rabbitmq, a rabbitmq message queue server to be used for global messages, queues and stacks
# 9300: elastic, an elasticsearch server or main cluster address for global database storage
EXPOSE 2121 5672 9300


# Define default command.
ENTRYPOINT ["/bin/bash", "./start.sh"]
