#https://repo.powerdns.com
FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y dist-upgrade \
  && apt-get install -y ca-certificates \
  && apt-get install -y --no-install-recommends \
  && apt-get install -y locales libsystemd-dev curl openssl apt-transport-https libssl-dev git gnupg \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && echo "Package: dnsdist*" > /etc/apt/preferences.d/dnsdist \
  && echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/dnsdist \
  && echo "Pin-Priority: 600" >> /etc/apt/preferences.d/dnsdist

  RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='amd64';; \
    arm64) ARCH='arm64';; \
    #armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && if [ "$ARCH" = "amd64" ]; then \
    echo "deb [arch=amd64] http://repo.powerdns.com/debian buster-dnsdist-15 main" > /etc/apt/sources.list.d/pdns.list ; fi \
  && if [ "$ARCH" = "arm64" ]; then \
    echo "deb http://repo.powerdns.com/raspbian buster-dnsdist-15 main" > /etc/apt/sources.list.d/pdns.list ; fi
  #&& if [ "$ARCH" = "armv7l" ]; then \
  #  echo "deb http://repo.powerdns.com/raspbian buster-dnsdist-master main" > /etc/apt/sources.list.d/pdns.list ; fi

  RUN curl https://repo.powerdns.com/CBC8B383-pub.asc | apt-key add - \
  && curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - \
  && apt-get update \
  && apt-get install -y dnsdist \
  && rm -rf /var/lib/apt/lists/* 


EXPOSE 53/udp 53/tcp 
CMD ["/usr/bin/dnsdist", "-u","_dnsdist", "-g", "_dnsdist" ,"--supervised"]
