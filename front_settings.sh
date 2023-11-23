#!/bin/bash

# Global variables for settings files
FRONT_USERDIR=$HOME/TheFront/data
FRONT_SERVERDIR=$HOME/TheFront/server
SETTINGS_FILE="server_settings.conf"
DESCRIPTION_FILE="server_settings.help"
USE_EPIC_SOCKET=0

# Function to display the main menu and get user's choice
show_main_menu() {
  CHOICE=$(whiptail --title "Settings Editor" --menu "Choose an option:" 12 60 3 \
    "1" "Edit Server Settings" \
    "2" "Generate FrontServer Bash File" \
    "3" "Exit" 3>&1 1>&2 2>&3)
}

# Function to edit settings in the file
edit_settings() {
  while true; do
    if [ ! -e "$SETTINGS_FILE" ] || [ ! -e "$DESCRIPTION_FILE" ]; then
      whiptail --title "Error" --msgbox "Settings or description file not found!" 10 40
      return
    fi

    # Convert settings file into a format suitable for whiptail
    SETTINGS_ARRAY=()
    while IFS="=" read -r ITEM VALUE; do
      DESCRIPTION=$(grep "^$ITEM=" "$DESCRIPTION_FILE" | cut -d "=" -f 2)
      SETTINGS_ARRAY+=("$ITEM" "$DESCRIPTION")
    done < "$SETTINGS_FILE"

    # Prompt user to select items to edit
    SELECTED_ITEM=$(whiptail --title "Edit Settings" --menu "Select an item to edit:" 20 140 10 --cancel-button "Back" "${SETTINGS_ARRAY[@]}" 3>&1 1>&2 2>&3)

    # Check if cancel button is pressed
    if [ $? -ne 0 ]; then
      break
    fi

    OLD_VALUE=$(grep "^$SELECTED_ITEM=" "$SETTINGS_FILE" | cut -d "=" -f 2)
    NEW_VALUE=$(whiptail --title "Edit Settings" --inputbox "$SELECTED_ITEM - ${SETTINGS_ARRAY[1]}" 10 40 "$OLD_VALUE" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
      sed -i "s/^$SELECTED_ITEM=.*/$SELECTED_ITEM=$NEW_VALUE/" "$SETTINGS_FILE"
      whiptail --title "Success" --msgbox "Settings updated successfully!" 10 40
    else
      whiptail --title "Warning" --msgbox "No changes made." 10 40
