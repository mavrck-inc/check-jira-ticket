# Container image that runs your code
FROM alpine/git:v2.30.2

RUN chmod +x /entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]