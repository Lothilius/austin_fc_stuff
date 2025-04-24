#!/bin/bash

# Path to the markdown file
SCHEDULE_FILE="$HOME/.austin_fc/austin_fc_schedule.md"

# Check if the file exists
  if [ ! -f "$SCHEDULE_FILE" ]; then
      echo "Schedule file not found at $SCHEDULE_FILE. Attempting to download..."
      curl -o "$SCHEDULE_FILE" "https://raw.githubusercontent.com/Lothilius/austin_fc_stuff/refs/heads/main/austin_fc_schedule.md"
      if [ ! -f "$SCHEDULE_FILE" ]; then
          echo "Error: Failed to download the schedule file."
          exit 1
      fi
  fi

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)
CURRENT_YEAR=$(date +%Y)

# Initialize variables to track the next match
NEXT_MATCH_DATE=""
NEXT_MATCH_OPPONENT=""
NEXT_MATCH_LOCATION=""
DAYS_UNTIL_NEXT_MATCH=999999  # Start with a large number

# Read the markdown file line by line
while IFS= read -r line; do
    # Skip lines that don't contain match data
    if [[ ! "$line" =~ ^\|[0-9]+ ]]; then
        continue
    fi
    
    # Extract match information using awk
    MATCH_NUM=$(echo "$line" | awk -F'|' '{print $2}' | tr -d ' ')
    DATE_STR=$(echo "$line" | awk -F'|' '{print $3}' | tr -d ' ')
    OPPONENT=$(echo "$line" | awk -F'|' '{print $4}' | tr -d ' ')
    LOCATION=$(echo "$line" | awk -F'|' '{print $5}' | tr -d ' ')
    RESULT=$(echo "$line" | awk -F'|' '{print $6}' | tr -d ' ')
    
    # Skip if this is not a valid match entry or if the match already has a result
    if [[ -z "$DATE_STR" || "$RESULT" != "tbd" ]]; then
        continue
    fi
    
    # Convert date format to YYYY-MM-DD
    # Assuming DATE_STR is in MM-DD-YYYY format
    MATCH_DATE=$(echo "$DATE_STR" | awk -F'-' '{print $3"-"$1"-"$2}')
    
    # Compare with today's date
    if [[ "$MATCH_DATE" > "$TODAY" || "$MATCH_DATE" == "$TODAY" ]]; then
        # Calculate days until this match
        SECONDS_UNTIL_MATCH=$(( $(date -j -f "%Y-%m-%d" "$MATCH_DATE" +%s) - $(date -j -f "%Y-%m-%d" "$TODAY" +%s) ))
        DAYS_UNTIL_THIS_MATCH=$(( $SECONDS_UNTIL_MATCH / 86400 ))
        
        # Check if this match is sooner than the current next match
        if [[ $DAYS_UNTIL_THIS_MATCH -lt $DAYS_UNTIL_NEXT_MATCH ]]; then
            NEXT_MATCH_DATE="$MATCH_DATE"
            NEXT_MATCH_OPPONENT="$OPPONENT"
            NEXT_MATCH_LOCATION="$LOCATION"
            DAYS_UNTIL_NEXT_MATCH=$DAYS_UNTIL_THIS_MATCH
        fi
    fi
done < "$SCHEDULE_FILE"

# Format the date for display (Month Day, Year)
FORMATTED_DATE=$(date -j -f "%Y-%m-%d" "$NEXT_MATCH_DATE" "+%B %d, %Y")

# Output the result
if [[ -n "$NEXT_MATCH_DATE" ]]; then
    # Create the location text
    if [[ "$NEXT_MATCH_LOCATION" == "Home" ]]; then
        LOCATION_TEXT="at home"
    else
        LOCATION_TEXT="away"
    fi
    
    # Handle the special case for today
    if [[ $DAYS_UNTIL_NEXT_MATCH -eq 0 ]]; then
        echo "Austin FC plays today ($FORMATTED_DATE) against $NEXT_MATCH_OPPONENT $LOCATION_TEXT!"
    else
        # Plural or singular for "day"
        if [[ $DAYS_UNTIL_NEXT_MATCH -eq 1 ]]; then
            echo "Austin FC plays tomorrow ($FORMATTED_DATE) against $NEXT_MATCH_OPPONENT $LOCATION_TEXT!"
        else
            echo "Austin FC plays in $DAYS_UNTIL_NEXT_MATCH days ($FORMATTED_DATE) against $NEXT_MATCH_OPPONENT $LOCATION_TEXT!"
        fi
    fi
else
    echo "No upcoming matches found in the schedule."
fi
