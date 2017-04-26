FROM jenkins:2.32.3

USER root

RUN apt-get update

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

RUN apt-get -y install \
      apt-transport-https \
      software-properties-common
RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
RUN add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-jessie \
       main"
RUN apt-get update && \
      apt-cache policy docker-engine && \
      apt-get -y install docker-engine=1.13.1-0~debian-jessie && \
      rm -rf /var/lib/apt/lists/*
RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && \
      chmod +x /usr/bin/docker-compose

RUN install-plugins.sh \
         analysis-collector:1.50 \
         ansicolor:0.5.0 \
         ant:1.4 \
         bitbucket:1.1.5 \
         bitbucket-approve:1.0.3 \
         bitbucket-oauth:0.5 \
         blueocean:1.0.0-rc1 \
         build-env-propagator:1.0 \
         build-name-setter:1.6.5 \
         build-with-parameters:1.3 \
         checkstyle:3.47 \
         cloudbees-bitbucket-branch-source:2.1.2 \
         cloudbees-folder:6.0.3 \
         copyartifact:1.38.1 \
         crowd2:1.8 \
         description-setter:1.10 \
         disable-failed-job:1.15 \
         docker-workflow:1.10 \
         environment-script:1.2.5 \
         git:3.1.0 \
         github:1.26.1 \
         github-branch-source:2.0.4 \
         github-organization-folder:1.6 \
         http-post:1.2 \
         jenkins-flowdock-plugin:1.1.8 \
         jenkins-jira-issue-updater:1.18 \
         jira:2.3 \
         matrix-auth:1.4 \
         multi-slave-config-plugin:1.2.0 \
         naginator:1.17.2 \
         pam-auth:1.3 \
         parameterized-trigger:2.33 \
         performance:2.1 \
         pmd:3.46 \
         rebuild:1.25 \
         run-condition:1.0 \
         ssh-credentials:1.13 \
         tasks:4.50 \
         timestamper:1.8.8 \
         token-macro:2.0 \
         view-job-filters:1.27 \
         warnings:4.60 \
         workflow-aggregator:2.5 \
         workflow-multibranch:2.14 \
         ws-cleanup:0.32

# Designate the default domains to limit strict key checking.
ENV OUTRIGGER_STRICT_HOST_CHECKING_DISABLED 'github.com bitbucket.org'

# Run the s6-based init.
ENTRYPOINT ["/init"]

# Set up a standard volume for logs.
VOLUME ["/var/log/services"]
