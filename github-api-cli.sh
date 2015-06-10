#!/bin/bash

# immutables
arguments_required=4

function helpText {
  echo -e "\nERROR: Four options are required\n"
  echo -e "Usage: ./github-api-cli.sh [mode] [org] [repo] [output count]"
  echo "mode: there are two modes, issues or pulls"
  echo "org: specify an org"
  echo "repo: specify a public repo"
  echo "output count: specify how many lines of output sans header"
}

[[ $# -ne $arguments_required ]] && { helpText; exit 1; } 

# Get options
mode=$1
org=$2
repo=$3
declare -i item_count # Declare $item_count as a number
item_count=$4+1 # Enable print of header + $item_count below

# Build url
url="https://api.github.com/repos/$org/$repo/$mode"

function getTopIssues {
  # Get the issues from a repo
  all_issues=$( curl -s $url )
  # Get count of issues
  all_issues_count=$( echo $all_issues | jq 'length - 1' )
  # Create list
  issue_comments_title=$(echo -e "Comments\tIssue Title\n\r")
  for idx in $(seq 0 $all_issues_count); do
    issue_comments_title="$issue_comments_title$(echo -e '\n\r')"
    issue_comments_title="$issue_comments_title$( echo -e $( echo $all_issues | jq .[$idx].comments )'\t'$( echo $all_issues | jq .[$idx].title ))"
  done

  # Print the top $item_count items
  echo "$issue_comments_title" | sort -r | head -n $item_count | column -t -s $'\t'
}

getTopIssues

all_pull_requests=$( curl -s https://api.github.com/repos/WhiteHouse/petitions/pulls )
