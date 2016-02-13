FROM jenkins

USER root

# Add the s6 overlay.
ENV S6_VERSION v1.16.0.0
RUN curl -L "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-amd64.tar.gz" | \
    tar xzvf - -C /
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 1

# Download confd.
ENV CONFD_VERSION 0.10.0
RUN curl -L "https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64" > /usr/bin/confd && \
    chmod +x /usr/bin/confd
ENV CONFD_OPTS '--backend=env --onetime'

COPY root /
COPY plugins.txt /usr/share/jenkins/plugins.txt

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# Add docker binaries directly
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN curl -L http://ftp.us.debian.org/debian/pool/main/a/apt/apt-transport-https_1.0.9.8.2_amd64.deb > /tmp/apt-transport-https_1.0.9.8.2_amd64.deb && dpkg -i /tmp/apt-transport-https_1.0.9.8.2_amd64.deb
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get -y install docker-engine=1.9.1-0~jessie
RUN curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]

# Start Jenkins by default
CMD [ "/usr/local/bin/jenkins.sh" ]
