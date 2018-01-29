FROM ubuntu:16.04

ENV SALT_VERSION=2017.7.1

RUN apt-get update \
  && apt-get install -y vim-nox curl \
  && curl -L https://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | apt-key add - \
  && echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/${SALT_VERSION} xenial main" > /etc/apt/sources.list.d/saltstack.list \
  && apt-get update \
  && apt-get install -y libdbus-1-3 libnih-dbus1 sudo software-properties-common iputils-ping apt-transport-https debian-archive-keyring \
  && apt-get install -y salt-minion=${SALT_VERSION}* \

  # fix for getty consume 100% cpu
  && systemctl disable getty@tty1.service \

  # fix missing resolvconf
  && cd /tmp \
  && apt-get download resolvconf \
  && dpkg --unpack resolvconf_*_all.deb \
  && rm /var/lib/dpkg/info/resolvconf.postinst \
  && dpkg --configure resolvconf \
  && apt-get install -yf \
  && apt-mark hold resolvconf \

  # cleanup
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -y autoremove \
  && apt-get clean

CMD ["salt-call","--local","state.apply"]
# CMD ["salt-call","--local","state.apply","-l","debug"]
