FROM ubuntu:bionic
 
ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'America/Los_Angeles' > /etc/timezone

RUN apt-get update -y

# Requirements for SILC
RUN apt-get install -y gcc libglib2.0-0 libglib2.0-dev libncurses5-dev libperl-dev make

# For gathering the packages
RUN apt-get install -y wget

RUN apt-get install -y strace

RUN wget https://sourceforge.net/projects/silc/files/silc/client/sources/silc-client-1.1.11.tar.bz2

# Verify the  SHA512 sum from when this Dockerfile was created
RUN echo "400222ea681cd36976ca58ab8f71e09ddaa249e85f5f5f6398a861e18315b10a53abee27967300a5e9736b1e248750d9f9d482538068fc8f263393c3332e9fc6  silc-client-1.1.11.tar.bz2" | sha512sum -c -

# Double check with the server version. There is no reason for these to not match
RUN wget https://downloads.sourceforge.net/project/silc/silc/client/sources/silc-client-1.1.11.tar.bz2.sum
RUN cat silc-client-1.1.11.tar.bz2.sum | sha512sum -c -

RUN tar xjvf silc-client-1.1.11.tar.bz2


RUN cd silc-client-1.1.11 && ls -l && ./configure --enable-debug && make && make install
RUN mv /silc-client-1.1.11/apps/irssi/src/fe-text/silc /usr/local/bin/
RUN chmod a+x /usr/local/bin/silc

RUN adduser --system -q silc

RUN mkdir /var/silc
RUN chown silc /var/silc
RUN chmod og-r /var/silc


USER "silc"
VOLUME [ "/var/silc" ]

ENV LD_LIBRARY_PATH /usr/local/lib/:$LD_LIBRARY_PATH
ENTRYPOINT [ "/usr/local/bin/silc", "--config=/var/silc",  "--home=/var/silc", "$@"]
