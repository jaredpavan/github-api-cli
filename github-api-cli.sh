#!/bin/bash

# Define mode functions
# Defining function to grab issues with the most chatter
function getTopIssues {
  # Get the issues from a repo
  all_issues=$( curl -s $url )
  # Get count of issues
  all_issues_count=$( echo $all_issues | jq 'length - 1' )
  # Create list
  issue_comments_title=$(echo -e "Comments\tIssue Title\n\r")
  for idx in $(seq 0 $all_issues_count); do
    issue_comments_title="$issue_comments_title$( echo -e '\n\r' )"
    issue_comments_title="$issue_comments_title$( echo -e $( echo $all_issues | jq .[$idx].comments )'\t'$( echo $all_issues | jq .[$idx].title ))"
  done

  # Print the top $item_count items
  echo "$issue_comments_title" | sort -r | head -n $item_count | column -t -s $'\t'
}

# Defining function to grab pull requests with the most chatter
function getTopPulls {
  # Get the pull requests from a repo
  all_pulls=$( curl -s $url )
  # Get count of pull requests
  all_pulls_count=$( echo $all_pulls | jq 'length - 1' )
  # Create list
  pulls_comments_title=$(echo -e "Comments\tPR Title\n\r")
  for idx in $(seq 0 $all_pulls_count); do
    # Get comment count
    comments_url=$( echo $all_pulls | jq -r .[$idx].comments_url )
    comments=$( curl -s $comments_url )
    comments_count=$( echo $comments | jq length )

    # Assemble table
    pulls_comments_title="$pulls_comments_title$( echo -e '\n\r' )"
    pulls_comments_title="$pulls_comments_title$( echo -e $comments_count'\t'$( echo $all_pulls | jq .[$idx].title ))"
  done

  # Print the top $item_count items
  echo "$pulls_comments_title" | sort -r | head -n $item_count | column -t -s $'\t'
}

####################
### Start script ###
####################
# immutables
arguments_required=4

function helpText {
  echo -e "Usage: ./github-api-cli.sh [mode] [org] [repo] [output count]"
  echo "mode: there are two modes [issues|pulls]"
  echo "org: specify an org"
  echo "repo: specify a public repo"
  echo "output count: specify how many lines of output sans header"
}

[[ $# -ne $arguments_required ]] && { echo -e "\nERROR: FOUR OPTIONS ARE REQUIRED\n"; helpText; exit 1; } 

# Get options
mode=$1
org=$2
repo=$3
declare -i item_count # Declare $item_count as a number
item_count=$4+1 # Enable print of header + $item_count below

# Build url
url="https://api.github.com/repos/$org/$repo/$mode"

# Run the selected mode's function
case "$mode" in
  issues)
    getTopIssues
    ;;
  pulls)
    getTopPulls
    ;;
  *)
    echo -e "\nERROR: INVALID MODE\n"
    helpText
    ;;
esac
