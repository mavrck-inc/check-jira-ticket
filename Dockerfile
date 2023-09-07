# Container image that runs your code
FROM ubuntu:latest
RUN apt-get update && apt-get install -y jq curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]