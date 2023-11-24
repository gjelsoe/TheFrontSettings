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
    SELECTED_ITEM=$(whiptail --title "Edit Settings" --menu "Select an item to edit:" 20 155 10 --cancel-button "Back" "${SETTINGS_ARRAY[@]}" 3>&1 1>&2 2>&3)

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
    fi
  done
}

# Function to generate a bash file for FrontServer
generate_frontserver_bash_file() {
  FILENAME=$(whiptail --title "Generate FrontServer Bash File" --inputbox "Enter the filename:" 10 40 3>&1 1>&2 2>&3)

  if [ $? -eq 0 ]; then
    SERVER_SETTINGS=()
    SERVER_NAME=""
    SERVER_PASSWORD=""
    USE_STEAM_SOCKET=""
    MAX_PLAYERS=""

    while IFS="=" read -r ITEM VALUE; do
      case "$ITEM" in
        "ServerName") SERVER_NAME="$VALUE" ;;
        "ServerPassword") SERVER_PASSWORD="$VALUE" ;;
        "UseSteamSocket") USE_STEAM_SOCKET="$VALUE" ;;
        "QueueThreshold") MAX_PLAYERS="$VALUE" ;;
        *) SERVER_SETTINGS+=("-$ITEM=$VALUE") ;;
      esac
    done < "$SETTINGS_FILE"

    # Determine the FRONT_SERVER value based on UseSteamSocket and USE_EPIC
    if [ "$USE_STEAM_SOCKET" -eq 1 ]; then
        if [ "$USE_EPIC" -eq 1 ]; then
            FRONT_SERVER="./FrontServer ProjectWar_Start?DedicatedServer?MaxPlayers=$MAX_PLAYERS?udrs=eos"
        else
            FRONT_SERVER="./FrontServer ProjectWar_Start?DedicatedServer?MaxPlayers=$MAX_PLAYERS?udrs=steam"
        fi
    else
        FRONT_SERVER="./FrontServer ProjectWar_Start?DedicatedServer?MaxPlayers=$MAX_PLAYERS"
    fi

    cat <<EOL >"$FILENAME.sh"

#!/bin/bash
#
# Enters The Front Server Dir.
cd $FRONT_SERVERDIR
#
# Execute FrontServer with arguments
$FRONT_SERVER -ServerName="$SERVER_NAME" -ServerPassword="$SERVER_PASSWORD" -UserDir="$FRONT_USERDIR" ${SERVER_SETTINGS[@]}
EOL

    # Make the script executable
    chmod +x "$FILENAME.sh"

    whiptail --title "Success" --msgbox "Bash file '$FILENAME.sh' created successfully!" 10 40
  else
    whiptail --title "Warning" --msgbox "No file created." 10 40
  fi
}

# Main loop
while true; do
  show_main_menu

  case $CHOICE in
    "1") edit_settings ;;
    "2") generate_frontserver_bash_file ;;
    "3") exit ;;
  esac
done
