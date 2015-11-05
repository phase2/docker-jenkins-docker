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

# Add symlink for libdevmapper to fix docker-compose from host
RUN ln -s /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1 /lib/x86_64-linux-gnu/libdevmapper.so.1.02

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]

# Start Jenkins by default
CMD [ "/usr/local/bin/jenkins.sh" ]
