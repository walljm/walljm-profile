FROM mcr.microsoft.com/dotnet/runtime:6.0-focal

RUN apt update
RUN apt install -y iproute2
RUN apt install -y tini

COPY network-faker-297-linux-x64 /root/network-faker
COPY docker-entrypoint.sh /root/docker-entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/bin/tini", "--", "/root/docker-entrypoint.sh"]
CMD ["/root/network-faker","--NetworkPath=/fake_network", "--Logging:LogLevel:Default=Information"]
