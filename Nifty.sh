#!/bin/sh

#	Nifty, a command-line launcher for CraftBukkit Minecraft Server
#	Copyright © 2011-2012 Ben Stolovitz. Some Rights Reserved.

#	This software is freely available (free as in speech and beer) at nifty.stolovitz.com
#	It is a github repository. Links available from the site.

#	All modification, redistribution, and access is allowed so long as these three rules are followed:
#		1. Credit for initial program stays with me, in source code.
#		2. No mention of me is removed from the source code.
#		3. You share alike. No resale or changing up the license.


#go to the correct directory.
cd -P -- "$(dirname -- "$0")" && pwd -P
mkdir server
cd server

clear
echo "\033[1m###########################################"
echo "# Nifty v 1.1.8"
echo "# by Citelao"
echo "#"
echo "# with auto-update, backup, and Essentials"
echo "###########################################"
echo ""
echo "\033[0m"

# Table of Contents
# 	i. Wish List
# 	1. Initial setup
# 	2. Load config.cfg
# 	3. Actions init
# 	4. Server init
# 	5. Main menu exec
# 	6. Server exec

# i. Wish List
	#TODO implement custom-save backup
	#TODO plugin disabling
	#More configurable settings, e.g. RAM

# 1. Initial setup
if [ ! -f craftbukkit.jar ]; then	#setup, because if craftbukkit doesn't exist, the world's about to end.
	#notify
	echo "Performing initial setup..."
	echo ""
	echo ""
	#create
	#plugins folder
		mkdir plugins
		mkdir plugins-backup
	#world-bukkit folder
		mkdir world-bukkit
		mkdir world-bukkit-autosave
	#world-vanilla folder
		mkdir world-vanilla
		mkdir world-vanilla-autosave
	#world-backups folder
		mkdir world-backups
	#config.cfg
		touch config.cfg
	#plugins.cfg
		touch plugins.cfg
	#ops, banned-players, banned-ips, white-list ( server.props autogenned and sedded if needed )
		touch ops.txt
		touch banned-players.txt
		touch banned-ips.txt
		touch white-list.txt
	
	nf_generate() {
		#write to
		#config.cfg
			echo "#This file stores settings changeable through Launcher.command. You can edit here if you want, but be careful." > 	config.cfg
			echo "gui=bukkit" >> config.cfg
		#plugins.cfg
			echo "#This file is executed during initial setup and updates to tell Nifty what actions to do to what plugins." > plugins.cfg
			echo "#You can edit here if you want, but be careful. I suggest a familiarity with shell. Look to the following lines for guidance" >> plugins.cfg
			echo "" >> plugins.cfg
			echo "" >> plugins.cfg
			echo "#ESSENTIALS by Earth2Me <earth2me.com/>" >> plugins.cfg
			echo "	curl -O --progress-bar http://cloud.github.com/downloads/essentials/Essentials/Essentials-2.7.2.zip" >> plugins.cfg
			echo "	unzip -j -qq Essentials-2.7.2.zip -d plugins" >> plugins.cfg
			echo "	rm Essentials-2.7.2.zip" >> plugins.cfg
			echo "" >> plugins.cfg
			echo "" >> plugins.cfg
			echo "#WORLDEDIT by sk89q <sk89q.com/>" >> plugins.cfg
			echo "	curl -O --progress-bar http://cloud.github.com/downloads/sk89q/worldedit/worldedit-5.0.zip" >> plugins.cfg
			echo "	unzip -j -qq worldedit-5.0.zip -d plugins" >> plugins.cfg
			echo "	rm worldedit-5.0.zip" >> plugins.cfg
			echo "	rm plugins/CHANGELOG.txt" >> plugins.cfg
			echo "	rm plugins/LICENSE.txt" >> plugins.cfg
			echo "	rm plugins/NOTICE.txt" >> plugins.cfg
			echo "	rm plugins/README.txt" >> plugins.cfg
			echo "	rm plugins/SUBMITTING.txt" >> plugins.cfg
		}

	#write to files
	nf_generate
	
	nf_download() {
		#craftbukkit.jar
			curl -O --progress-bar http://ci.bukkit.org/job/dev-CraftBukkit/Recommended/artifact/target/*zip*/target.zip
			unzip -j -qq target.zip
			rm target.zip
			
			for f in craftbukkit*.jar; do
				mv $f craftbukkit.jar
			done
		#minecraft_server.jar
			curl -O --progress-bar https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
			mv minecraft_server.jar minecraft_server.jar
		#plugins
			. plugins.cfg #just executes plugins.cfg. Dandy, eh?	
	}
	
	nf_download
	
	echo ""
	echo ""
fi

# 2. Load config.cfg
	if [ -f config.cfg ]; then
		. config.cfg
	else
		gui=bukkit
	fi
	
# 3. Actions init
	# CONTENTS
	# 1. Start
	# 2. Restore
	# 3. Update
	# 4. Backup
	# 5. Options
	
	nf_start() {
		echo ""
		#don't actually do anything here, launching is handled in steps 4 and 6
	}
	
	nf_restore() {
		echo ""
		echo ""
		echo "Restoring..."
		
		echo ""
		echo ""
		echo "\033[1mWhat would you like to restore?\033[0m"
		echo " 1	Autosave"
	#	echo " 2	Custom save" TODO
		echo " 2	Backend"
		echo "[3] 	Nothing"
		echo ""
		
		read -p "What do you want to restore? " restore
		
		if [ $restore == 1 ]; then #restore autosave
			nf_restore_autosave
	#	elif [ $restore == 2 ]; then #restore customsave
	#		nf_restore_save
		elif [ $restore == 2 ]; then #restore backend
			nf_restore_backend
		fi
	}
	
		nf_restore_autosave() {
		#move autosave to temp folder
			mkdir world-temp
			mv -f world-$servType-autosave/* world-temp
		
		#move current world to backup of current servertype
			mv -f world-$servType/* world-$servType-autosave
		
		#move temp folder to real world
			mv -f world-temp/* world-$servType
			rm -R world-temp
		
		echo ""
		echo ""
		echo "Restore completed."
		}
		
	#	nf_restore_save() { #TODO
	#		echo ""
	#		echo ""
	#		
	#		if [ "$(ls -A world-backups)" ]; then #not empty
	#			echo "Choose a file:"
	#			ls -@ -1 backups
	#		
	#			echo "\033[1mTODO:\033[0m Sorry, pallies"
	#		else
	#			echo "\033[1mNo backups in backups/ directory.\033[0m"
	#		fi
	#	}
		
		nf_restore_backend() {
		#swap plugins
			mkdir plugins-temp
			mv -f plugins-backup/* plugins-temp
			
			mv -f plugins/* plugins-backup
			
			mv -f plugins-temp/* plugins
			rm -R plugins-temp	
		#swap craftbukkit
			mv craftbukkit.jar craftbukkit.jar.temp
			mv craftbukkit.jar.backup craftbukkit.jar
			mv craftbukkit.jar.temp craftbukkit.jar.backup	
		#swap mineserv
			mv minecraft_server.jar minecraft_server.jar.temp
			mv minecraft_server.jar.backup minecraft_server.jar
			mv minecraft_server.jar.temp minecraft_server.jar.backup
		}
	
	nf_update() {
		echo ""
		echo ""
		echo "Updating server..."
		
		#backup
		rm -f craftbukkit.jar.backup
		mv craftbukkit.jar craftbukkit.jar.backup
		
		rm -f minecraft_server.jar.backup
		mv minecraft_server.jar minecraft_server.jar.backup
		
		rm -f -d plugins-backup/*
		mv -f plugins/* plugins-backup
		
		nf_download
	}
	
	nf_backup() {
		echo ""
		echo ""
		echo "Backing up server..."
		
		#time
		year=$(date +%Y)
		month=$(date +%b)
		day=$(date +%d)
		clock=$(date +%T) 
		#duplicate world file
		mkdir -p world-backups/$year/$month/$day/$clock
		
		cp -r world-bukkit world-backups/$year/$month/$day/$clock
		cp -r world-bukkit_nether world-backups/$year/$month/$day/$clock
		cp -r world-bukkit_the_end world-backups/$year/$month/$day/$clock
		cp -r world-bukkit-autosave world-backups/$year/$month/$day/$clock
		cp -r world-vanilla world-backups/$year/$month/$day/$clock
		cp -r world-vanilla-autosave world-backups/$year/$month/$day/$clock
	
		echo ""
		echo ""
		echo "Backed up."
	}
	
	nf_options() {
		echo ""
		echo ""
		echo "Options..."
		
		echo ""
		echo ""
		echo "\033[1mWhat option would you like to change?\033[0m"
		echo " 1	Launcher"
	#	echo " 2	Plugins" #TODO
		echo " 2	Regenerate config.cfg"
		echo "[3] 	None"
		echo ""
		
		read -p "What option would you like to change? " option
		
		if [ $option == 1 ]; then #change launcher
			nf_options_launcher
	#	elif [ $action == 2 ]; then #plugins
	#		nf_options_plugins
		elif [ $option == 2 ]; then #regenerate
			nf_generate
		fi

	}
	
		nf_options_launcher() {
		echo ""
		echo ""
		echo "\033[1mWhich launcher would you like to use?\033[0m"
		echo " 1	Vanilla"
		echo " 2	Bukkit"
		echo "[3] 	Don't change"
		echo ""
		
		read -p "Which launcher would you like to use? " launcher
		
		if [ $launcher == 1 ]; then #vanilla
			nf_options_launcher_vanilla
		elif [ $launcher == 2 ]; then #bukkit
			nf_options_launcher_bukkit
		fi
		}
		
		nf_options_launcher_vanilla() {
			echo ""
			echo "Using vanilla server."
			
			#change local
			gui=vanilla
			#change saved	
			sed -i '' -e 's/gui=bukkit/gui=vanilla/g' config.cfg
		}
		
		nf_options_launcher_bukkit() {
			echo ""
			echo "Using Bukkit server."
			
			#change local
			gui=bukkit
			#change saved
			sed -i '' -e 's/gui=vanilla/gui=bukkit/g' config.cfg
		}
		
	#	nf_options_plugins() {
	#	TODO
	#	}

# 4. Server init
	nf_launch_server() {
	if [ $gui == "bukkit" ]; then #use terminal bukkit
		java -Xmx1024M -Xms1024M -jar craftbukkit.jar -w world-bukkit -nojline
	elif [ $gui == "vanilla" ]; then #use minecraft_server	
		#the -w command for bukkit changes server.properties so we just manually change it here.
		sed -i '' -e 's/level-name=world-bukkit/level-name=world-vanilla/g' server.properties
		sed -i '' -e 's/level-name=(world(?=\b))/level-name=world-vanilla/g' server.properties	
		java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui
	else #there's an error with them theayre settings	
		echo ""	
		echo ""
		echo "\033[1mERROR:\033[0m There seems to be something wrong with your config.cfg."
		echo "Please regenerate it in the \033[1mOptions\033[0m menu."
	fi
	}
	
# 5. Main menu exec
	echo "Welcome! To use, type in the number of the action you want, then press return."
	echo "Actions marked by a ... take you to a submenu; other actions work immediately."
	echo ""
	echo "\033[1mDo what?\033[0m"
	echo " 1	Start"			#implemented
	echo " 2	Restore..."		#custom saves TODO
	echo " 3	Update"			#plugins.cfg	TODO
	echo " 4	Backup"			#done
	echo " 5	Options..."		#plugins TODO
	echo "[6] 	Quit"
	echo ""
	
	read -p "What do you want to do? " action
	
	if [ $action == 1 ]; then #start
		nf_start
	elif [ $action == 2 ]; then #restore
		nf_restore
	elif [ $action == 3 ]; then #update
		nf_update
	elif [ $action == 4 ]; then #backup
		nf_backup
	elif [ $action == 5 ]; then #options
		nf_options
	else
		exit
	fi
	
# 6. Server exec
	nf_launch_server
	