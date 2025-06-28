# Austin FC Stuff

A collection of Austin FC themes for oh-my-posh along with tools to track 
and display Austin FC match schedules and information.

## Overview

This project provides utilities to:
- Austin FC theme for oh-my-posh
- Fetch and parse the current Austin FC MLS schedule
- Track countdown to matchs for oh-my-posh theme

## Example Display

![Austin FC CLI display](images/austin_fc_example_theme.png)


## Components

### Schedule Parser

`austinfc_days_til.py` - A Python script that:
- Scrapes Austin FC schedule data from plaintextsports.com
- Parses match information (dates, opponents, locations)
- Outputs formatted schedule data to a markdown file

### Next Game Finder

`next_austin_fc_match.sh` - A shell script that:
- Check if schedule markdown file is present
- If not, copy the latest schedule from the repository
- Reads the schedule markdown file
- Determines the next upcoming match
- Calculates days until the next match
- Displays formatted match information

### How to use
To ways to have this script as part of the oh-my-posh theme:
1. Use the script directly in the theme by updating the path to the script in the theme file.
2. Create a symlink to the script in your PATH and call it from the theme.

```zsh
mkdir  $HOME/.austin_fc
ln -s /path/to/next_austin_fc_match.sh $Home/.austin_fc/austinfc_days_til
```

### Terminal Integration

`austinfc.omp.yml` - An Oh My Posh theme configuration for terminal customization with:
- Green Austin FC branded colors
- Git status information
- Countdown timer integration

## Usage

## Set Oh My Posh Theme
1. Install [Oh My Posh](https://ohmyposh.dev/docs/installation)
2. Install nerd fonts. 
   ```bash
   brew tap homebrew/cask
   brew install --cask font-hack-nerd-font
   ```
2. Install the theme using the command:
   ```bash
   oh-my-posh init --shell zsh --config austinfc.omp.yml >> ~/.zshrc
   ```

### Running the Schedule Parser

  ```bash
  python austinfc_days_til.py
  ```
