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

# Add docker binaries directly
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN curl -L http://ftp.us.debian.org/debian/pool/main/a/apt/apt-transport-https_1.0.9.8.3_amd64.deb > /tmp/apt-transport-https_1.0.9.8.3_amd64.deb && dpkg -i /tmp/apt-transport-https_1.0.9.8.3_amd64.deb
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get -y install docker-engine=1.11.2-0~jessie
RUN curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

COPY root /

RUN install-plugins.sh \
        analysis-collector \
        ansicolor \
        ant \
        bitbucket \
        build-name-setter \
        build-with-parameters \
        checkstyle \
        description-setter \
        disable-failed-job \
        git \
        git-client \
        jenkins-flowdock-plugin \
        parameterized-trigger \
        performance \
        pmd \
        rebuild \
        scm-api \
        ssh-credentials \
        tasks \
        token-macro \
        view-job-filters \
        warnings

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]

# Start Jenkins by default
CMD [ "/usr/local/bin/jenkins.sh" ]
