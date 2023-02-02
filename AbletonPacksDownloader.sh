#!/bin/bash
while [ 1 ]
do
    clear
    echo -e "AbletonPacksDownloader: \n"
    echo "  Select an option by typping a number"
    echo "      1 - Remove down URLs from URLs file"
    echo "      2 - View URLs file content"
    echo "      3 - Download every Ableton packs from links in URLs file"
    echo -e "      4 - Exit \n"
    read -p "Enter your choice: " choise
    case $choise in
      1)    echo -e "\nWorking...\n"
            wget --spider -nv -i URLs-list.txt -o tempurllist.txt 
            cat tempurllist.txt | grep "OK" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > URLs-list.txt
            rm ./tempurllist.txt
            echo -e "Done! URLs list file updated.\n"
            sleep 1s
            read -n 1 -s -p "Press any key to continue..."
            ;;
      2)    echo ""
            cat URLs-list.txt
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      3)    wget -nv -i URLs-list.txt
            echo -e "\nDone! \n"
            sleep 1s
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      4)    echo -e "\nUser requested exit\n"
            exit 0
            ;;
      *)    echo "This is not a possible choice"
            sleep 1s
            ;;
    esac
done