# Outrigger Jenkins Docker

> Spin up a Jenkins container that can run Docker commands for the host.

[![](https://images.microbadger.com/badges/version/outrigger/jenkins-docker.svg)](https://microbadger.com/images/outrigger/jenkins-docker "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/outrigger/jenkins-docker.svg)](https://microbadger.com/images/outrigger/jenkins-docker "Get your own image badge on microbadger.com")

This image provides a Jenkins container meant to be used to run local jobs
including executing Docker commands on behalf of the host Docker system.
This allows Jenkins jobs to spin up and manage other Docker containers.

Additionally, it has a range of commonly useful Jenkins plugins which are tested
as working together and with the current Jenkins version.

For more documentation on how Outrigger images are constructed and how to work
with them, please [see the documentation](http://docs.outrigger.sh/en/latest/).

## Usage Example

For consistency your Jenkins image should be defined in a docker-compose manifest
within the project structure. By convention we call this file `jenkins.yml`.
The entry might look like this:

```
# Container for running Jenkins with a local jobs volume
# Run this image via
#   - `docker-compose -f jenkins.yml run jenkins`
jenkins:
  image: outrigger/jenkins-docker
  volumes:
    # Primary jenkins configuration. Direct file mount prevents writing updates
    # from running instance.
    - ./env/jenkins/config.xml:/var/jenkins_home/config.xml
    # Mount the local project jobs into Jenkins
    - ./env/jenkins/jobs:/var/jenkins_home/jobs
    # Mount the docker socket so we can execute from within this container
    - /var/run/docker.sock:/var/run/docker.sock
    # Mount a stable location for the Jenkins workspace
    - /opt/development/example/jenkins/env/workspace:/opt/development/example/jenkins/env/workspace
    # Volume mount the private key
    - ~/.ssh/id_rsa:/root/.ssh/outrigger.key
```

## Features

### Private Key Import

When CI jobs have to deal with private repositories, Jenkins will need an
SSH key to connect to GitHub and BitBucket. Since our images are meant to be
public, we cannot build a private key into the image and we must import a key
into the running container.

### Exported Job Configuration

The Jenkins container is customized mostly through volume mounts. Each project
repo should have their Jenkins CI jobs somewhere in the codebase. Typically
those get stored in `env/jenkins/jobs` and are mounted into the container into
the Jenkins Jobs directory with the following Volume specification

`- ./env/jobs:/var/jenkins_home/jobs`

Each time the Jenkins container is started up the job configuration will reset
back to what has been exported to the code. This creates stronger developer
ownership of job behavior, but can sometimes be confusing if deliberate changes
are made via the UI but not pulled back to code.

The XML configuration of any job can be viewed in the Jenkins UI via the config.xml
resource associated with each job, for example: `http://jenkins.example.vm/job/ship-it/config.xml`

### Managing Docker Containers

In order for Jenkins to manage Docker containers, we volume mount the Docker
client tools and the Docker Socket from the host. This allows Jenkins to spawn
other peer containers outside of it's own container.

```
- /var/run/docker.sock:/var/run/docker.sock
```

The Jenkins image has the Docker engine and docker-compose installed, so you can
have a version mismatch between the Jenkins container and the version of Docker
running on the host.

## Environment Variables

Outrigger images use Environment Variables and [confd](https://github.com/kelseyhightower/confd)
to "templatize" a number of Docker environment configurations. These templates are
processed on startup with environment variables passed in via the docker run
command-line or via your docker-compose manifest file. Here are the "tunable"
configurations offered by this image.

Jenkins Docker has no templatized configuration at this time.

## Customization

The most common need for customizing the Jenkins Docker container is to add
your own selection of Jenkins plugins. This will require your own customized
Dockerfile.

```
FROM outrigger/jenkins-docker

RUN install-versioned-plugins.sh \
        fun-plugin-one \
        funner-plugin-two:1.22 \
        the-funnest-plugin-of-all
```

If this is custom to a specific project, this might be placed in the
`./env/jenkins` directory from the usage example.

Once done, update your `docker run` or docker-compose `jenkins.yml` file as
follows:

```diff
jenkins:
-  image: outrigger/jenkins-docker
+  build: env/jenkins
```

## Security Reports

Please email outrigger@phase2technology.com with security concerns.

## Maintainers

[![Phase2 Logo](https://www.phase2technology.com/wp-content/uploads/2015/06/logo-retina.png)](https://www.phase2technology.com)
