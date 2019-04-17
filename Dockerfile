FROM debian:stretch

LABEL maintainer "j.zelger@techdivision.com"

# copy all filesystem relevant files
COPY fs /tmp/

# start install routine
RUN \

    # install base tools
    apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            vim less tar wget curl apt-transport-https ca-certificates apt-utils net-tools htop \
            python-setuptools python-wheel python-pip pv software-properties-common dirmngr gnupg && \

    # copy repository files
    cp -r /tmp/etc/apt /etc && \

    # add repository keys
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 5072E1F5 && \

    # update repositories
    apt-get update && \

    # define deb selection configurations

    # prepare compatibilities for docker

    # install supervisor
    pip install supervisor && \
    pip install supervisor-stdout && \

    # add our user and group first to make sure their IDs get assigned consistently,
    # regardless of whatever dependencies get added
    groupadd -r mysql && useradd -r -g mysql mysql && \

    # install packages
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \

    # mysql 5.7
    { \
        echo mysql-community-server mysql-community-server/data-dir select ''; \
        echo mysql-community-server mysql-community-server/root-pass password ''; \
        echo mysql-community-server mysql-community-server/re-root-pass password ''; \
        echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections && \
    apt-get install -y mysql-community-client mysql-community-server && \
    mysql_ssl_rsa_setup && \

    # install elasticsearch plugins

    # copy provided fs files
    cp -r /tmp/usr / && \
    cp -r /tmp/etc / && \

    # setup filesystem
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld && \
    chmod a+x /usr/local/bin/docker-entrypoint.sh && \

    # cleanup
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# define entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# define cmd
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
