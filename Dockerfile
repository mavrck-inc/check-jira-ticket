FROM ubuntu:latest

RUN apt-get update && apt-get install -y jq curl
COPY check-jira-ticket.yml /action/check-jira-ticket.yml
CMD ["/action/entrypoint.sh"]
