# Container image that runs your code
FROM alpine/git:v2.30.2
RUN apk --no-cache add jq curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]