#!/bin/bash

# Usage:
# $ sh mac-address-changer.sh home	=> Changes your wifi and ethernet MAC address to their original ones
# $ sh mac-address-changer.sh random	=> Changes your wifi and ethernet MAC address to hopefully random addresses



################################  BEGIN CONFIG AREA  ################################

# Change wifiInterface to the name of your wireless interface
wifiInterface="en0"

# Change wifiDefaultMAC to your wifiInterface device MAC
wifiDefaultMAC="b8:e8:56:41:30:62"

# Change ethInterface to the name of your ethernet interface
ethInterface="en4"

# Change ethDefaultMAC to your ethInterface device MAC
ethDefaultMAC="68:5b:35:91:7e:6b"

#################################  END CONFIG AREA  #################################



if [ $# != 1 ]
then
	echo "Usage: sh mac-address-changer.sh [home|random]"
else
	if `networksetup -getairportpower "$wifiInterface" | grep -q On`
	then
		if [ "$1" == "home" ]
		then
			sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
			sudo ifconfig "$wifiInterface" ether "$wifiDefaultMAC"
			echo "Wireless MAC address of interface $wifiInterface changed to: $wifiDefaultMAC (home)"
		elif [ "$1" == "random" ]
		then
			randomMAC=""
		
			for ((i = 0; i <= 5; i++)); do
        			randomMAC="$randomMAC$((hexdump -n 1 -v -e '/1 "%02X"' /dev/urandom) | tr '[:upper:]' '[:lower:]'):"
			done

			randomMAC="${randomMAC%?}"

			sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
                	sudo ifconfig "$wifiInterface" ether "$randomMAC"

			until `ifconfig "$wifiInterface" | grep -q "$randomMAC"` ; do
				randomMAC=""

				for ((i = 0; i <= 5; i++)); do
                                	randomMAC="$randomMAC$((hexdump -n 1 -v -e '/1 "%02X"' /dev/urandom) | tr '[:upper:]' '[:lower:]'):"
                        	done

                        	randomMAC="${randomMAC%?}"

              			sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
                        	sudo ifconfig "$wifiInterface" ether "$randomMAC"
			done
			
			echo "Wireless MAC address of interface $wifiInterface changed to: $randomMAC (random)"	
		else
			echo "Wrong syntax. Type 'sh mac-address-changer.sh' for more information."
		fi
	else
		echo "Your WiFi is turned off ($wifiInterface has no power)."
	fi
	
	if `ifconfig | grep -q "$ethInterface"`
	then
		if [ "$1" == "home" ]
                then
                        sudo ifconfig "$ethInterface" ether "$ethDefaultMAC"
                        echo "Ethernet MAC address of interface $ethInterface changed to: $ethDefaultMAC (home)"
                elif [ "$1" == "random" ]
                then
                        randomMAC=""
                
                        for ((i = 0; i <= 5; i++)); do
                                randomMAC="$randomMAC$((hexdump -n 1 -v -e '/1 "%02X"' /dev/urandom) | tr '[:upper:]' '[:lower:]'):"
                        done

                        randomMAC="${randomMAC%?}"

                        sudo ifconfig "$ethInterface" ether "$randomMAC"
                        echo "Ethernet MAC address of interface $ethInterface changed to: $randomMAC (random)"
		fi
	else
		echo "Your ethernet interface is not available. This might be because you're using a thunderbolt to ethernet adapter. ($ethInterface is not available)."
	fi
fi
