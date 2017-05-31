FROM ruby:2.4.1-alpine
MAINTAINER Martin Guenthner <github@grusy.de>

#========================================
# Add normal user with passwordless sudo
#========================================
RUN  adduser -S -h /home/jenkins jenkins && \
	mkdir -p /home/jenkins
#========================================
# Install java and jenkins slave
#========================================
# Java Version and other ENV
# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo; \
    echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
  } > /usr/local/bin/docker-java-home \
  && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u111
ENV JAVA_ALPINE_VERSION 8.111.14-r0

RUN set -x \
  && apk add --no-cache \
    curl \
    bash \
    git \
    openjdk8-jre="$JAVA_ALPINE_VERSION" \
  && [ "$JAVA_HOME" = "$(docker-java-home)" ]
	
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3.9/remoting-3.9.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar
COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
VOLUME /home/jenkins
VOLUME /home/jenkins/.composer
VOLUME /home/jenkins/.cache
WORKDIR /home/jenkins
USER jenkins
ENTRYPOINT ["jenkins-slave.sh"]