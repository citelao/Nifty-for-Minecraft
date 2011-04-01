#!/bin/sh
cd -P -- "$(dirname -- "$0")" && pwd -P
clear
echo "\033[1m###########################################"
echo "# CraftBukkit Server Starter v 1.1"
echo "# by acolite246"
echo "#"
echo "# featuring TimberJaw's Crafty"
echo "# with auto-update, backup, and Essentials"
echo "###########################################"
echo ""
echo "\033[0m"

#intial setup if needed
if [ ! -f craftbukkit.jar ]; then  #setup, because if craftbukkit doesn't exist, the world's about to end.
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
	#config file
	    touch settings.cfg
	#plugins file TODO
	    #touch plugins.cfg
	#ops, banned-players, banned-ips, white-list ( server.props autogenned and sedded if needed )
	    touch ops.txt
	    touch banned-players.txt
	    touch banned-ips.txt
	    touch white-list.txt
    
    #write to
	#config
	    echo "#This file stores settings changeable through Launcher.command. You can edit here if you want, but be careful." > settings.cfg
	    echo "gui=crafty" >> settings.cfg
	    echo "servType=bukkit" >> settings.cfg
    
    #download
	#craftbukkit.jar
	    curl -O --progress-bar http://ci.bukkit.org/job/dev-CraftBukkit/lastSuccessfulBuild/artifact/target/craftbukkit-0.0.1-SNAPSHOT.jar
	    mv craftbukkit-0.0.1-SNAPSHOT.jar craftbukkit.jar
	#minecraft_server.jar
	    curl -O --progress-bar http://www.minecraft.net/download/minecraft_server.jar
	#crafty (because it's awesome)
	    curl -O --progress-bar http://dl.dropbox.com/u/17925907/Minecraft/Crafty/Crafty-v0.7.zip
	    unzip -qq Crafty-v0.7.zip
	    rm crafty.bat
	    rm Crafty-v0.7.zip	    
	#plugins
	    #essentials
		curl -O --progress-bar http://earth2me.net:8002/guestAuth/repository/download/bt3/.lastSuccessful/Essentials.zip
		unzip -j -qq Essentials.zip -d plugins
		rm Essentials.zip
	    #worldEdit
		curl -O --progress-bar https://github.com/downloads/sk89q/worldedit/worldedit-4.1
		unzip -j -qq worldedit-4.1.zip -d plugins
		rm plugins/CHANGELOG.txt
		rm plugins/LICENSE.txt
		rm plugins/NOTICE.txt
		rm plugins/README.txt
		#rm worldedit-4.2.zip
	    #any others in plugins
    
    echo ""
    echo ""
    echo ""
    
fi

#load any config files
if [ -f settings.cfg ]; then #load settings.cfg
    . settings.cfg
else
    gui=crafty
    servType=bukkit
fi

#if [ -f plugins.cfg ]; then #load plugins.cfg TODO
#    . plugins.cfg
#fi
    
#display menu
echo "Welcome! To use, type in the number of the action you want, then press return."
echo "Actions marked by a ... take you to a submenu; other actions work immediately."
echo ""
echo "\033[1mDo what?\033[0m"
echo " 1  Start"				#implemented
echo " 2  Restore..."				#custom saves TODO
echo " 3  Update"				#plugins.cfg  TODO
echo " 4  Backup"				#done
echo " 5  Options..."				#plugins TODO
echo "[6] Quit"
echo ""

read -p "What do you want to do? " action
    
    if [ $action == 1 ]; then #start
	echo ""
	#don't actually do anything here, launching is handled at the end.
    
    elif [ $action == 2 ]; then #restore
	echo ""
	echo ""
	echo "Restoring..."
	
	echo ""
	echo ""
	echo "\033[1mWhat would you like to restore?\033[0m"
	echo " 1  Autosave"
	#echo " 2  Custom save" TODO
	echo " 2  Backend"
	echo "[3] Nothing"
	echo ""
	
	read -p "What do you want to restore? " restore
	
	if [ $restore == 1 ]; then #restore autosave
	    #this will switch autosave with current world.
	    
	    #move autosave to temp folder
	    mkdir world-temp
	    mv -f world-$servType-autosave/* world-temp
	    
	    #move current world to backup of current servertype
	    mv -f world-$servType/* world-$servType-autosave
	    
	    #move temp folder to real world
	    mv -f world-temp/* world-$servType
	    rm -R world-temp
	    
	    #done!
	    echo ""
	    echo ""
	    echo "Restore completed."
	
	#elif [ $restore == 2 ]; then #restore customsave
	#    echo ""
	#    echo ""
	#    
	#    if [ "$(ls -A world-backups)" ]; then #not empty
	#	echo "Choose a file:"
	#	ls -@ -1 backups
	#	
	#	echo "\033[1mTODO:\033[0m Sorry, pallies"
	#    else
	#	echo "\033[1mNo backups in backups/ directory.\033[0m"
	#    fi
	
	elif [ $restore == 2 ]; then #restore backend
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
	    
	    #CRAFTY DOES NOT LIVE UPDATE SO NO NEED
	
	#else just launch server
	fi
    
    elif [ $action == 3 ]; then #update
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
	
	#download
	    #craftbukkit.jar
		curl -O --progress-bar http://ci.bukkit.org/job/dev-CraftBukkit/promotion/latest/Recommended/artifact/target/craftbukkit-0.0.1-SNAPSHOT.jar
		mv craftbukkit-0.0.1-SNAPSHOT.jar craftbukkit.jar
	    #minecraft_server.jar
		curl -O --progress-bar http://www.minecraft.net/download/minecraft_server.jar
   	    #CRAFT DOES NOT LIVE UPDATE SO NO NEED	    
	    #plugins
		#essentials
		    curl -O --progress-bar http://earth2me.net/bukkit/Essentials.zip
		    unzip -j -qq Essentials.zip -d plugins
		    rm Essentials.zip
		#worldEdit
		    curl -O --progress-bar https://github.com/downloads/sk89q/worldedit/worldedit-4.1.zip
		    unzip -j -qq worldedit-4.1.zip -d plugins
		    rm plugins/CHANGELOG.txt
		    rm plugins/LICENSE.txt
		    rm plugins/NOTICE.txt
		    rm plugins/README.txt
		    rm worldedit-4.1.zip
		#any others in plugins TODO     
    
    elif [ $action == 4 ]; then #backup
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
	cp -r world-bukkit-autosave world-backups/$year/$month/$day/$clock
	cp -r world-vanilla world-ackups/$year/$month/$day/$clock
	cp -r world-vanilla-autosave world-backups/$year/$month/$day/$clock
    
	echo ""
	echo ""
	echo "Backed up."
    
    elif [ $action == 5 ]; then #options
	echo ""
	echo ""
	echo "Options..."
	
	echo ""
	echo ""
	echo "\033[1mWhat option would you like to change?\033[0m"
	echo " 1  Launcher"
#	echo " 2  Plugins" #TODO
	echo " 2  Regenerate settings.cfg"
	echo "[3] None"
	echo ""
	read -p "What option would you like to change? " option

	if [ $option == 1 ]; then #change launcher
	    echo ""
	    echo ""
	    echo "\033[1mWhich launcher would you like to use?\033[0m"
	    echo " 1  Vanilla"
	    echo " 2  Bukkit"
	    echo " 3  Crafty"
	    echo "[4] Don't change"
	    
	    echo ""
	    read -p "Which launcher would you like to use? " launcher
	    
	    echo ""
	    
	    if [ $launcher == 1 ]; then #vanilla
		echo ""
		echo "Using vanilla server."
		
		#change local
		gui=vanilla
		servType=vanilla
	    
		#change saved	
		sed -i '' -e 's/gui=bukkit/gui=vanilla/g' settings.cfg
		sed -i '' -e 's/gui=crafty/gui=vanilla/g' settings.cfg
		
		sed -i '' -e 's/servType=bukkit/servType=vanilla/g' settings.cfg
		
	    elif [ $launcher == 2 ]; then #bukkit
		echo ""
		echo "Using Bukkit server."
		
		#change local
		gui=bukkit
		servType=bukkit
		
		#change saved
		sed -i '' -e 's/gui=vanilla/gui=bukkit/g' settings.cfg
		sed -i '' -e 's/gui=crafty/gui=bukkit/g' settings.cfg
		
		sed -i '' -e 's/servType=vanilla/servType=bukkit/g' settings.cfg
	    
	    elif [ $launcher == 3 ]; then #crafty
		echo ""
		echo "Using Crafty."
		
		#change local
		gui=crafty
		servType=bukkit
		
		#change saved
		sed -i '' -e 's/gui=vanilla/gui=crafty/g' settings.cfg
		sed -i '' -e 's/gui=bukkit/gui=crafty/g' settings.cfg
		
		sed -i '' -e 's/servType=vanilla/servType=bukkit/g' settings.cfg
	    
	    else #quit
		echo ""
	    
	    fi
	
	#elif [ $action == 2 ]; then #plugins
	    #TODO
	
	elif [ $option == 2 ]; then #regenerate
	
	    #this is exactly what happens during setup
	    echo "#This file stores settings changeable through Launcher.command. You can edit here if you want, but be careful." > settings.cfg
	    echo "gui=crafty" >> settings.cfg
	    echo "servType=bukkit" >> settings.cfg

	else
	    exit
	    
	fi
	
	#TODO tweak server.properties, etc
    
    else #quit
	exit
    
    fi
    
    #launch server
    
    echo ""
    echo ""
    echo "Starting server..."
    
    if [ $gui == "crafty" ]; then #use crafty
    	
	java -Xmx1024M -Xms1024M -jar crafty.jar -w world-bukkit
	
    elif [ $gui == "bukkit" ]; then #use terminal bukkit
    
	java -Xmx1024M -Xms1024M -jar craftbukkit.jar -w world-bukkit
    
    elif [ $gui == "vanilla" ]; then #use minecraft_server
	
	#the -w command changes server.properties so we just manually change it here.
	sed -i '' -e 's/level-name=world-bukkit/level-name=world-vanilla/g' server.properties
	sed -i '' -e 's/level-name=(world(?=\b))/level-name=world-vanilla/g' server.properties
	
	java -Xmx1024M -Xms1024M -jar minecraft_server.jar
    
    else #there's an error with them theayre settings
	
	echo ""  
	echo ""
	echo "\033[1mERROR:\033[0m There seems to be something wrong with your settings.cfg. Please regenerate it in the \033[1mOptions\033[0m menu."
    
    fi
    
