#!/bin/bash -x

shopt -s nocasematch
JIRA_TICKET_PATTERN="(FRBI|CRI|IR|MREG|MVKPLTFRM|MVKENG|MAVRCK|RF)-[0-9]{3,6}"
PR_TITLE=$(jq --raw-output .pull_request.title "$GITHUB_EVENT_PATH")
PR_BODY=$(jq --raw-output .pull_request.body "$GITHUB_EVENT_PATH")

if [[ $PR_TITLE =~ $JIRA_TICKET_PATTERN ]]; then
    JIRA_TICKET=${BASH_REMATCH[0]^^}
    echo "JIRA Ticket found in PR title: $JIRA_TICKET"
elif [[ $PR_BODY =~ $JIRA_TICKET_PATTERN ]]; then
    JIRA_TICKET=${BASH_REMATCH[0]^^}
    echo "JIRA Ticket found in PR body: $JIRA_TICKET"
else
    echo "No match found."
    exit 1
fi

shopt -u nocasematch


urls=("${JIRA_SERVER}" "https://${JIRA_SERVER}")

for url in "${urls[@]}"
do
  status_code=$(curl -I -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$status_code" -eq 200 ]; then
    echo "$url: OK"
  else
    echo "$url: Failed with status $status_code"
  fi
done

response=$(curl --request GET \
              --url "${JIRA_SERVER}rest/api/3/issue/${JIRA_TICKET}" \
              --user "${JIRA_SERVICE_USER}:${JIRA_SERVICE_API_TOKEN}" \
              --header "Accept: application/json" \
              --silent)

response1=$(curl --request GET \
              --url "https://${JIRA_SERVER}rest/api/3/issue/${JIRA_TICKET}" \
              --user "${JIRA_SERVICE_USER}:${JIRA_SERVICE_API_TOKEN}" \
              --header "Accept: application/json" \
              --silent)

echo "response: $response"
echo "response1: $response1"

if [[ $(echo "$response" | jq -r '.key') == "$JIRA_TICKET" ]]; then
echo "Valid JIRA ticket!"
else
    echo "The JIRA ticket does not exist."
    exit 1
fi