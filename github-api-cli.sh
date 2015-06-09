#!/bin/bash

repo="WhiteHouse"
item_count=4

function isDivisibleBy {
  # Get the issues from a repo
  all_issues=$( curl -s https://api.github.com/repos/$repo/petitions/issues )
  # Get count of issues
  all_issues_count=$( echo $all_issues | jq 'length - 1' )
  # Create list
  issue_comments_title="Comment Count'\t'Issue Title'\n\r'"
  for idx in $(seq 0 $all_issues_count); do
    issue_comments_title="$issue_comments_title$(echo -e '\n\r')"
    issue_comments_title="$issue_comments_title$( echo -e $( echo $all_issues | jq .[$idx].comments )'\t'$( echo $all_issues | jq .[$idx].title ))"
  done

  echo "$issue_comments_title" | sort -r | head -n $item_count
}

isDivisibleBy

all_pull_requests=$( curl -s https://api.github.com/repos/WhiteHouse/petitions/pulls )