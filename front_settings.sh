#!/bin/bash
#
# Global variables for settings files
#
FRONT_USERDIR=$HOME/TheFront/data               # Path to Save Files.
FRONT_SERVERDIR=$HOME/TheFront/server           # Path to Dedicated Server.
SETTINGS_FILE="server_settings.conf"            # Read settings from this file.
DESCRIPTION_FILE="server_settings.help"         # Help file for settings.
USE_EPIC_SOCKET=0                               # Set to 1 if using EPIC and not STEAM.
FIND_EXTERNAL_IP=1                              # Lets the script find your IP Address. (0 - No, 1 - Yes)
                                                # If UseSteamSocket=1, then it will insert your Public IP otherwise Local IP.
USE_IP=127.0.0.1                           	# Enter your IP Address or let the script find it.
UPDATE_BEFORE_START=0				# Do a STEAM update of The Front before starting the Server.
#
# STEAM update command, do not edit unless your know what your are doing.
UPDATE_CMD="steamcmd +force_install_dir $FRONT_SERVERDIR +login anonymous +app_update 1007 +app_update 2334200 +validate +quit"
#
# Check if whiptail is installed
#
if ! command -v whiptail &> /dev/null; then
  echo "Error: 'whiptail' is not installed. Please install it before running this script.\nUse 'sudo apt install whiptail' on Debian/Ubuntu to install"
  exit 1
fi

#
# Check if curl is installed
#
if [ $FIND_EXTERNAL_IP -eq 1 ]; then
  if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed. Please install it before running this script.\nUse 'sudo apt install curl' on Debian/Ubuntu to install"
    exit 1
  fi
fi

#
# Function to get the Local/Public IP address of the server
#
get_ip() {
  if [ "$USE_STEAM_SOCKET" -eq 1 ]; then
    USE_IP=$(hostname -I | awk '{print $1}')
  else
    USE_IP=$(curl -s ifconfig.me)
  fi
}

#
# Force update of The Front
#
force_steam_update() {
  {$UPDATE_CMD}
  if [ $? -ne 0 ]; then
    whiptail --title "Success" --msgbox "The Front update failed!" 10 40
  else
    whiptail --title "Success" --msgbox "The Font updated successfully!" 10 40
  fi
}

#
# Function to display the main menu and get user's choice
#
show_main_menu() {
  CHOICE=$(whiptail --title "Settings Editor" --menu "Choose an option:" 12 60 4 \
    "1" "Edit Server Settings" \
    "2" "Generate FrontServer Bash File" \
    "3" "Force STEAM update" \
    "4" "Exit." 3>&1 1>&2 2>&3)
}
#
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

    #
    # Check STEAM update is gorin to run before start
    if [ "$UPDATE_BEFORE_START" -eq 0 ]; then
      UPDATE_CMD="#"
    fi

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
    get_ip

    cat <<EOL >"$FILENAME.sh"

#!/bin/bash
#
# Enters The Front Server Dir.
cd $FRONT_SERVERDIR
${UPDATE_CMD}
#
# Execute FrontServer with arguments
$FRONT_SERVER -ServerName="$SERVER_NAME" -ServerPassword="$SERVER_PASSWORD" -UserDir="$FRONT_USERDIR" -OutIPAddress=$USE_IP ${SERVER_SETTINGS[@]}
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
    "3") force_steam_update ;;
    "4") exit ;;
  esac
done
