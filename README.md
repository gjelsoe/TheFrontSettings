# TheFrontSettings

**Work In Progress.!**\
A Linux CLI build on Bash & Whiptail to make it easier, makeing a BASH file for The Front Linux Dedicated Server.<br>For use with The Front Dedicated Linux Server **v1.0.22**
* Easy Access to settings
* Can autofill Local/Public IP of the Server (req. curl)
* Generate Start script for The Front Dedicated Linux Server  
> [!TIP]
> In order to take full advance of this script, it's need to have Whiptail and curl installed. If your are running Debian/Ubuntu, then you can use the following command to install them.<br> `sudo apt-get install curl whiptail -y`<br>

> [!CAUTION]
> I wrote this script to help my self out and it works for me on Ubuntu 22.04 LTS.<br>
> Use it with caution and always double check the result before using it.<br>

### TODO
- [x] Update README<br>
- [x] Force STEAM update before start<br>
- [x] Manual STEAM update from menu<br>
- [x] Description of Configuration Options within the script.<br>
- [x] Other handy stuff.<br>
- [x] Update Menu Images.<br>
- [x] Settings Filter added.<br>

---

### Configuration Variables in front_settings.sh

**FRONT_USERDIR=**<br>
Path to your Save Game files.

**FRONT_SERVERDIR=**<br>
Path where Server files are stored.

**SETTINGS_FILE=**<br>
Read settings from this file. (Shouldn't need be to changed)

**DESCRIPTION_FILE=**<br>
Help file for settings. (Shouldn't need be to changed)

**USE_EPIC_SOCKET=**<br>
Use EPIC and not STEAM.

**FIND_EXTERNAL_IP=**<br>
Lets the script find your IP Address. (0 - No, 1 - Yes)

**USE_IP=**<br>
Enter your IP Address or let the script find it.

**UPDATE_BEFORE_START=**<br>
Do a STEAM update of The Front before starting the Server.

**CUSTOM_CMD=**<br>
Add an extra command to The Front Server.<br>

**Notes :**<br>
If UseSteamSocket=1, then it will insert your Public IP otherwise Local IP. if FIND_EXTERNAL_IP it set to 1.<br>
USE_EPIC_SOCKET might not be needed as there are no official EPIC Client for Linux but I've included it anyway.<br>

---

### Wiki Page.

I've added [Wiki page](https://github.com/gjelsoe/TheFrontSettings/wiki/Server-Settings) with all the settings found in the TheFrontManager along with<br>
Default settings and where they are found in the Manager as of version **1.0.22**.<br> Also added Min, Max and Increment values as well.<br>

More [Wiki pages](https://github.com/gjelsoe/TheFrontSettings/wiki) added.

---

### Other Sources.

Lots of good information. https://github.com/pharrisee/TheFrontLinuxServerInfo<br><br>

From SurvivalServers.com :<br>
https://survivalservers.com/wiki/index.php?title=The_Front_Admin_Commands<br>
https://survivalservers.com/wiki/index.php?title=The_Front_Advanced_Configuration<br>

Good source of information. https://www.4netplayers.com/en/wiki/the-front/

---

### People made it possible.

**pharrisee** on [Github](https://github.com/pharrisee/TheFrontLinuxServerInfo) for creating bash scripts and other good information on running The Front Server on Linux.

**SurvivalServers** with their Admin Commands and Advanced Configuration Pages.

---

### Menus

<p align="center">
 <img src="https://github.com/gjelsoe/TheFrontSettings/blob/main/images/main.jpg">
</p><br>
<p align="center">
 <img src="https://github.com/gjelsoe/TheFrontSettings/blob/main/images/edit.jpg">
</p><br>
<p align="center">
 <img src="https://github.com/gjelsoe/TheFrontSettings/blob/main/images/filter.jpg">
</p><br>
<p align="center">
 <img src="https://github.com/gjelsoe/TheFrontSettings/blob/main/images/save.jpg">
</p><br>
