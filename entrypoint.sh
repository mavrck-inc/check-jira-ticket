#!/bin/bash

shopt -s nocasematch

# Define the JIRA ticket pattern
JIRA_TICKET_PATTERN="(FRBI|CRI|IR|MREG|MVKPLTFRM|MVKENG|MAVRCK|RF)-[0-9]{3,6}"

# Get the PR number and repo information from the environment variables
PR_NUMBER=${PR_NUMBER}
REPO=${REPO}

# Use the GitHub API to get the latest title and body of the PR
PR_DATA=$(curl --request GET \
               --url "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER" \
               --header "Authorization: Bearer ${{ secrets.GH_API_TOKEN }}" \
               --header "Accept: application/vnd.github.v3+json" \
               --silent)

# Extract the title and body from the API response
PR_TITLE=$(echo "$PR_DATA" | jq --raw-output .title)
PR_BODY=$(echo "$PR_DATA" | jq --raw-output .body)

# Check for a JIRA ticket in the title or body
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

# Check if the JIRA ticket exists
response=$(curl --request GET \
              --url "${JIRA_SERVER}/rest/api/3/issue/${JIRA_TICKET}" \
              --user "${JIRA_SERVICE_USER}:${JIRA_SERVICE_API_TOKEN}" \
              --header "Accept: application/json" \
              --silent)

if [[ $(echo "$response" | jq -r '.key') == "$JIRA_TICKET" ]]; then
    echo "Valid JIRA ticket!"
else
    echo "The JIRA ticket does not exist."
    exit 1
fi
