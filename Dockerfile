FROM geodata/gdal
MAINTAINER Peter Korduan <peter.korduan@gdi-service.de>
LABEL version="0.1.0"

ENV OS_USER="gisadmin"
ENV USER_DIR="/home/${OS_USER}"

USER root

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y \
  openssh-server \
  postgresql-client

RUN mkdir /var/run/sshd

RUN echo 'root:secret' | chpasswd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile && \
  useradd -ms /bin/bash $OS_USER && \
  echo ${OS_USER}:kvwmap | chpasswd && \
  mkdir -p $USER_DIR/.ssh && \
  chown -R $USER_DIR/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]