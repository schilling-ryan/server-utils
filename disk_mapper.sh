#!/bin/bash

printable="Disk|Model|Version|Capacity|Serial Number\n"
for d in $(ls -1 /dev/ | grep -P "sd\S$"); 
    do full_output=$(smartctl -a /dev/$d);
        filtered_output=$(echo "$full_output" | grep -E "Serial Number|User Capacity|Device Model|SATA Version");
        serial=$(echo "$filtered_output" | grep Serial | cut -d ':' -f 2 | sed -E "s/^\s+//g"); 
        capacity=$(echo "$filtered_output" | grep Capaci | cut -d ':' -f 2 | sed -E "s/^\s+//g"); 
        model=$(echo "$filtered_output" | grep Model | cut -d ':' -f 2 | sed -E "s/^\s+//g");
        version=$(echo "$filtered_output" | grep Version | cut -d ':' -f 2 | sed -E "s/^\s+//g");
        if echo "$full_output" | grep -q "Unknown USB bridge"; then
            printable="$printable$d|USB device\n";
            continue
        fi
        printable="$printable$d|$model|$version|$capacity|$serial\n";
    done
echo -e "$printable"