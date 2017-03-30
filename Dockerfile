FROM jenkins:1.651.3

USER root

RUN apt-get -y update

# Add the s6 overlay.
ENV S6_VERSION v1.19.1.1
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

# Add Docker binaries directly
RUN apt-get -y install \
        apt-transport-https \
        software-properties-common
RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
RUN add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-jessie \
       main"
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get -y install docker-engine=17.03.1~ce-0~debian-jessie
RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

# This is needed until the upgrade to Jenkins 2.x
COPY jenkins-support  /usr/local/bin/jenkins-support
COPY install-versioned-plugins.sh  /usr/local/bin/install-versioned-plugins.sh

RUN install-versioned-plugins.sh \
        analysis-collector:1.49 \
        ansicolor:0.4.3 \
        bitbucket:1.1.5 \
        bitbucket-build-status-notifier:1.3.0 \
        build-name-setter:1.6.5 \
        build-with-parameters:1.3 \
        checkstyle:3.47 \
        copyartifact:1.38.1 \
        description-setter:1.10 \
        disable-failed-job:1.15 \
        envinject:1.93.1 \
        git:3.0.5 \
        git-client:2.2.1 \
        jenkins-flowdock-plugin:1.1.8 \
        mercurial:1.59 \
        multiple-scms:0.6 \
        parameterized-trigger:2.32 \
        performance:2.0 \
        pmd:3.46 \
        rebuild:1.25 \
        scm-api:2.0.7 \
        ssh-credentials:1.13 \
        tasks:4.50 \
        token-macro:1.12.1 \
        view-job-filters:1.27 \
        warnings:4.59

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]

# Start Jenkins by default
CMD [ "/usr/local/bin/jenkins.sh" ]
