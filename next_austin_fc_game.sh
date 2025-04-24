#!/bin/bash

# Path to the markdown file
SCHEDULE_FILE="$HOME/.austin_fc/austin_fc_schedule.md"

# Check if the file exists
if [ ! -f "$SCHEDULE_FILE" ]; then
    echo "Error: Schedule file not found at $SCHEDULE_FILE"
    exit 1
fi

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)
CURRENT_YEAR=$(date +%Y)

# Initialize variables to track the next game
NEXT_GAME_DATE=""
NEXT_GAME_OPPONENT=""
NEXT_GAME_LOCATION=""
DAYS_UNTIL_NEXT_GAME=999999  # Start with a large number

# Read the markdown file line by line
while IFS= read -r line; do
    # Skip lines that don't contain game data
    if [[ ! "$line" =~ ^\|[0-9]+ ]]; then
        continue
    fi
    
    # Extract game information using awk
    GAME_NUM=$(echo "$line" | awk -F'|' '{print $2}' | tr -d ' ')
    DATE_STR=$(echo "$line" | awk -F'|' '{print $3}' | tr -d ' ')
    OPPONENT=$(echo "$line" | awk -F'|' '{print $4}' | tr -d ' ')
    LOCATION=$(echo "$line" | awk -F'|' '{print $5}' | tr -d ' ')
    RESULT=$(echo "$line" | awk -F'|' '{print $6}' | tr -d ' ')
    
    # Skip if this is not a valid game entry or if the game already has a result
    if [[ -z "$DATE_STR" || "$RESULT" != "tbd" ]]; then
        continue
    fi
    
    # Convert date format to YYYY-MM-DD
    # Assuming DATE_STR is in MM-DD-YYYY format
    GAME_DATE=$(echo "$DATE_STR" | awk -F'-' '{print $3"-"$1"-"$2}')
    
    # Compare with today's date
    if [[ "$GAME_DATE" > "$TODAY" || "$GAME_DATE" == "$TODAY" ]]; then
        # Calculate days until this game
        SECONDS_UNTIL_GAME=$(( $(date -j -f "%Y-%m-%d" "$GAME_DATE" +%s) - $(date -j -f "%Y-%m-%d" "$TODAY" +%s) ))
        DAYS_UNTIL_THIS_GAME=$(( $SECONDS_UNTIL_GAME / 86400 ))
        
        # Check if this game is sooner than the current next game
        if [[ $DAYS_UNTIL_THIS_GAME -lt $DAYS_UNTIL_NEXT_GAME ]]; then
            NEXT_GAME_DATE="$GAME_DATE"
            NEXT_GAME_OPPONENT="$OPPONENT"
            NEXT_GAME_LOCATION="$LOCATION"
            DAYS_UNTIL_NEXT_GAME=$DAYS_UNTIL_THIS_GAME
        fi
    fi
done < "$SCHEDULE_FILE"

# Format the date for display (Month Day, Year)
FORMATTED_DATE=$(date -j -f "%Y-%m-%d" "$NEXT_GAME_DATE" "+%B %d, %Y")

# Output the result
if [[ -n "$NEXT_GAME_DATE" ]]; then
    # Create the location text
    if [[ "$NEXT_GAME_LOCATION" == "Home" ]]; then
        LOCATION_TEXT="at home"
    else
        LOCATION_TEXT="away"
    fi
    
    # Handle the special case for today
    if [[ $DAYS_UNTIL_NEXT_GAME -eq 0 ]]; then
        echo "Austin FC plays today ($FORMATTED_DATE) against $NEXT_GAME_OPPONENT $LOCATION_TEXT!"
    else
        # Plural or singular for "day"
        if [[ $DAYS_UNTIL_NEXT_GAME -eq 1 ]]; then
            echo "Austin FC plays tomorrow ($FORMATTED_DATE) against $NEXT_GAME_OPPONENT $LOCATION_TEXT!"
        else
            echo "Austin FC plays in $DAYS_UNTIL_NEXT_GAME days ($FORMATTED_DATE) against $NEXT_GAME_OPPONENT $LOCATION_TEXT!"
        fi
    fi
else
    echo "No upcoming games found in the schedule."
fi
