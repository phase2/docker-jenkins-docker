FROM jenkins:1.651.3

USER root

# Add the s6 overlay.
ENV S6_VERSION v1.17.2.0
RUN curl -L "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-amd64.tar.gz" | \
    tar xzvf - -C /
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 1

# Download confd.
ENV CONFD_VERSION 0.11.0
RUN curl -L "https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64" > /usr/bin/confd && \
    chmod +x /usr/bin/confd
ENV CONFD_OPTS '--backend=env --onetime'

# This contains the repo for docker
COPY root /

# Add docker binaries directly
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN curl -L http://ftp.us.debian.org/debian/pool/main/a/apt/apt-transport-https_1.0.9.8.3_amd64.deb > /tmp/apt-transport-https_1.0.9.8.3_amd64.deb && dpkg -i /tmp/apt-transport-https_1.0.9.8.3_amd64.deb
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get -y install docker-engine=1.11.2-0~jessie
RUN curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

# This is needed until the upgrade to Jenkins 2.x
COPY jenkins-support  /usr/local/bin/jenkins-support
COPY install-versioned-plugins.sh  /usr/local/bin/install-versioned-plugins.sh

RUN install-versioned-plugins.sh \
        analysis-collector:1.48 \
        ansicolor:0.4.2 \
        bitbucket:1.1.5 \
        bitbucket-build-status-notifier:1.3.0 \
        build-name-setter:1.6.5 \
        build-with-parameters:1.3 \
        checkstyle:3.46 \
        copyartifact:1.38 \
        description-setter:1.10 \
        disable-failed-job:1.15 \
        git:2.5.2 \
        git-client:1.19.7 \
        jenkins-flowdock-plugin:1.1.8 \
        mercurial:1.55 \
        multiple-scms:0.6 \
        parameterized-trigger:2.31 \
        performance:1.14 \
        pmd:3.45 \
        rebuild:1.25 \
        scm-api:1.2 \
        ssh-credentials:1.12 \
        tasks:4.49 \
        token-macro:1.12.1 \
        view-job-filters:1.27 \
        warnings:4.56

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]

# Start Jenkins by default
CMD [ "/usr/local/bin/jenkins.sh" ]
