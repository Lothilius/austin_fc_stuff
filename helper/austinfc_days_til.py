import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime
import os
import pandas as pd


def extract_match_entries(text):
    # This pattern matches a G followed by 1-2 digits, then captures everything up to
    # (but not including) the next G followed by 1-2 digits
    pattern = r'(G\d{1,2}.*?)(?=G\d{1,2}|$)'

    matches = re.findall(pattern, text, re.DOTALL)
    return [match.strip() for match in matches]


def parse_match_entry(entry):
    # Extract match number
    match = re.search(r'G(\d+):', entry)

    match_number = match.group(1)

    # Extract date (Format: Sa M/D)
    date_match = re.search(r'(?:Sa|Su|Mo|Tu|We|Th|Fr)\s+(\d+)/(\d+)', entry)
    if date_match:
        month = date_match.group(1).zfill(2)
        day = date_match.group(2).zfill(2)
        date = f"{month}-{day}-2025"
    else:
        date = "Unknown"

    # Determine if home or away
    location = "Home" if " v " in entry else "Away" if " @ " in entry else "Unknown"

    # Extract opponent name - this gets more complex due to varying formats
    # Split by spaces and find position after time indicator (p)
    parts = re.split(r'\s+', entry)
    opponent_parts = []
    for i, part in enumerate(parts):
        if part.endswith('p') and i+1 < len(parts):
            for j in range(i+1, len(parts)):
                if parts[j] in ['W', 'L', 'D', '@']:
                    opponent_parts = parts[i+1:j]
                    break

    # Extract opponent - will be followed by W/L/D for result
    if opponent_parts[-1] not in ['W', 'L', 'D', '@']:
        opponent = ' '.join(opponent_parts)
    else:
        opponent = opponent_parts[0]

    # Extract result
    result = "tbd"
    result_match = re.search(r'\s+([WLD])\s+', entry)
    if result_match:
        result_code = result_match.group(1)
        if result_code == 'W':
            result = "Win"
        elif result_code == 'L':
            result = "Loss"
        elif result_code == 'D':
            result = "Draw"

    return {
        'match': match_number,
        'date': date,
        'opponent': opponent,
        'location': location,
        'result': result
    }


def fetch_austin_fc_schedule():
    """Fetch the Austin FC schedule from plaintextsports.com and parse into markdown format"""

    url = "https://plaintextsports.com/mls/2025/teams/austin-fc"

    try:
        # Make HTTP request to get the page content
        response = requests.get(url)
        response.raise_for_status()  # Raise exception for 4XX/5XX responses

        # Parse the HTML content
        soup = BeautifulSoup(response.text, 'html.parser')

        # Get full text from the page
        full_text = soup.text

        # Split the text by newlines and find schedule information
        lines = full_text.split('\n')

        # Drop elements from lines that do not start with G
        lines = [line for line in lines if line.startswith('G')]
        
        # Find the schedule block in the text
        match_entries = []
        for line in lines:
            # Extract match entries from schedule block
            schedule = extract_match_entries(line)
            for match in schedule:
                match_entries.append(match)

        # Parse each match entry and collect data for DataFrame
        matchs_data = []
        for entry in match_entries:
            match_data = parse_match_entry(entry)
            if match_data:
                matchs_data.append(match_data)

        # Create DataFrame from parsed data
        df = pd.DataFrame(matchs_data)
        
        # Sort the DataFrame by match number
        df['match'] = df['match'].astype(int)
        df = df.sort_values(by='match')
        df['match'] = df['match'].astype(str)
        
        # Create markdown table from DataFrame
        markdown = "# Austin FC 2025 Schedule\n\n"
        
        # Generate markdown table header
        markdown += "| Game | Date | Opponent | Location | Result |\n"
        markdown += "|------|------|----------|----------|--------|\n"
        
        # Add each row from the DataFrame
        for _, row in df.iterrows():
            markdown += f"|{row['match']}|{row['date']}|{row['opponent']}|{row['location']}|{row['result']}|\n"

        # Save to markdown file
        home_dir = os.path.expanduser("~")
        austin_fc_dir = os.path.join(home_dir, ".austin_fc")

        # Create directory if it doesn't exist
        os.makedirs(austin_fc_dir, exist_ok=True)

        output_file = os.path.join(austin_fc_dir, "austin_fc_schedule.md")
        with open(output_file, 'w') as f:
            f.write(markdown)

        print(f"Schedule saved to {output_file}")
        return markdown

    except Exception as e:
        print(f"Error fetching Austin FC schedule: {e}")
        return None


if __name__ == "__main__":
    print(fetch_austin_fc_schedule())
    print("Run Complete")