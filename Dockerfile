
# CircleCI docker image to run within
FROM cimg/base:stable
# Base image uses "circleci", to avoid using `sudo` run as root user
USER root

# install shellcheck
ARG SHELLCHECK_VERSION=0.7.1
ARG SHELLCHECK_SHA256SUM=64f17152d96d7ec261ad3086ed42d18232fcb65148b44571b564d688269d36c8
RUN set -ex && cd ~ \
    && curl -sSLO https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && [ $(sha256sum shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | cut -f1 -d' ') = ${SHELLCHECK_SHA256SUM} ] \
    && tar xvfa shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/local/bin \
    && chown root:root /usr/local/bin/shellcheck \
    && rm -vrf shellcheck-v${SHELLCHECK_VERSION} shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz

# install circleci cli
ARG CIRCLECI_CLI_VERSION=0.1.9321
ARG CIRCLECI_CLI_SHA256SUM=26a4b0c56c1e0ad32ee42368ee098dbe8e917006cbd45c36a5cfc079f6888d3b
RUN set -ex && cd ~ \
    && curl -sSLO https://github.com/CircleCI-Public/circleci-cli/releases/download/v${CIRCLECI_CLI_VERSION}/circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64.tar.gz \
    && [ $(sha256sum circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64.tar.gz | cut -f1 -d' ') = ${CIRCLECI_CLI_SHA256SUM} ] \
    && tar xzf circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64.tar.gz \
    && mv circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64/circleci /usr/local/bin \
    && chmod 755 /usr/local/bin/circleci \
    && chown root:root /usr/local/bin/circleci \
    && rm -vrf circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64 circleci-cli_${CIRCLECI_CLI_VERSION}_linux_amd64.tar.gz

# install awscliv2, disable default pager (less)
ENV AWS_PAGER=""
ARG AWSCLI_VERSION=2.0.37
COPY sigs/awscliv2_pgp.key /tmp/awscliv2_pgp.key
RUN gpg --import /tmp/awscliv2_pgp.key
RUN set -ex && cd ~ \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o awscliv2.zip \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip.sig" -o awscliv2.sig \
    && gpg --verify awscliv2.sig awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install --update \
    && aws --version \
    && rm -r awscliv2.zip awscliv2.sig aws

# import gh pgp key
COPY sigs/ghcli_pgp.key /tmp/ghcli_pgp.key
RUN gpg --import /tmp/ghcli_pgp.key
# add to apt keyring
RUN gpg --export --armor 23F3D4EA75716059 | apt-key add -
# install gh
RUN set -ex && \
    apt-add-repository https://cli.github.com/packages && \
    apt update && \
    apt install -y gh

# install openjdk 21 for maven
ARG OPENJDK_21_SHA256=a30c454a9bef8f46d5f1bf3122830014a8fbe7ac03b5f8729bc3add4b92a1d0a
RUN set -ex && cd ~ \
    && curl -sSLO https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz \
    && echo "${OPENJDK_SHA256} openjdk-21_linux-x64_bin.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/java \
    && tar xzf openjdk-21_linux-x64_bin.tar.gz -C /opt/java \
    && rm openjdk-21_linux-x64_bin.tar.gz

# set openjdk env variables
ENV JAVA_HOME /opt/java/jdk-21
ENV PATH $JAVA_HOME/bin:$PATH

# install maven
ARG MAVEN_VERSION=3.9.4
ARG MAVEN_SHA512SUM=deaa39e16b2cf20f8cd7d232a1306344f04020e1f0fb28d35492606f647a60fe729cc40d3cba33e093a17aed41bd161fe1240556d0f1b80e773abd408686217e
RUN set -ex && cd ~ \
    && curl -sSLO https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${MAVEN_SHA512SUM} apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum -c - \
    && tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && mv apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/ \
    && mv apache-maven-${MAVEN_VERSION}/lib /usr/local/lib/maven \
    && rm -vrf apache-maven-${MAVEN_VERSION} apache-maven-${MAVEN_VERSION}-bin.tar.gz

# apt-get all the things
# Notes:
# - Add all apt sources first
# - groff and less required by AWS CLI
ARG CACHE_APT
RUN set -ex && cd ~ \
    && apt-get update \
    && : Install apt packages \
    && apt-get -qq -y install --no-install-recommends apt-transport-https less groff lsb-release \
    && : Cleanup \
    && apt-get clean \
    && rm -vrf /var/lib/apt/lists/*

USER circleci