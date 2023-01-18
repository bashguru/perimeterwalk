#!/bin/bash

# Author: bashguru
# Date: 1/18/2023

# Linux dependencies.
linuxDependencies=("python3" "jq" "pip" "realpath" "google-chrome")
pythonDependencies=("selenium>=4.7.2" "fake-useragent>=1.1.1" "requests>=2.28.2")

# Checks if Python3 is installed, if not exit.
for linuxDependency in "${linuxDependencies[@]}"; do
    if [ ! "$(which "$linuxDependency")" ]; then
        printf "Linux Dependency %s is not installed.  Please install it then run this script again.\n" "$linuxDependency"
        exit 1
    else
        printf "Linux Dependency %s is installed.\n" "$linuxDependency"
    fi
done

for pythonDependency in "${pythonDependencies[@]}"; do
    module=$(echo "$pythonDependency" | sed 's/>.*//')
    version=$(echo "$pythonDependency" | sed 's/.*=//')
    
    if [ ! "$(pip3 list | grep -v "^Package *Version$" | grep -v "^-*$" | cut -d ' ' -f 1 | grep -xF "$module")" ] && [ "$(pip3 list | grep -v "^Package *Version$" | grep "$module" | awk '{print $2}')" -ge "$version"  ]; then
        printf "Python module '%s' greater than or equal to version %s is not installed.  Please install it then run this script again.\n" "$module" "$version"
        exit 1
    else
        printf "Python module '%s' version '%s' is installed.\n" "$module" "$version"
    fi
done

# Function to validate the root domain

validate_root_domain() {
    # Check fi the root domain is a valid domain name
    if [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        printf "The root domain %s is valid.\n" "$1"
        return 0 # valid domain name
    else
        return 1 # Invalid domain name
    fi
}

# Declare an empty array to store the root domains
root_domains=()

# Prompt the user for one or many root domains
while true; do
    printf "\n"
    read -p "Enter a root domain (leave blank to finish): " root_domain
    if [[ -z "$root_domain" ]]; then
        break # No more root domains
    fi
    # Validate the root domain
    if ! validate_root_domain "$root_domain"; then
        echo >&2 "Error: Invalid root domain. Only use the root domain, for example: google.com ."
        continue
    fi
    # Check if the root domain is already in the array
    if [[ " ${root_domains[*]} " == *" $root_domain "* ]]; then
        echo >&2 "Error: Root domain is not unique"
        continue
    fi
    # Add the root domain to the array
    root_domains+=("$root_domain")
done

#Create a array temporary filepaths
tempFilepaths=()
directorypaths=()

# Loop through the array and collect from crt.sh on each root domain, sotring the output in the temporary file
for domain in "${root_domains[@]}"; do
    temp_file=$(mktemp -t "$domain.XXXXXX")
    printf "\nAttempting to collect transparency logs of %s.\n" "$domain"
    curl -s "https://crt.sh/?q=${domain}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g; s/^www\.//g' | sort -u >>"$temp_file"
    if [[ -z "$temp_file" ]]; then
        echo "crt.sh website may be down.  Come back and try again later."
        exit 1
    fi
    path=$(realpath "${temp_file}")
    tempFilepaths+=("$path")
    printf "Adding the root domain to the file %s.\n" "$path"
    printf "%s" "$domain" >>"$temp_file"
    printf "Pausing for random number of seconds before the next request.\n"
    # Sleep for a random number of seconds between 1 and 10
    sleep $(((RANDOM % 10) + 1))
done

for tempFilepath in "${tempFilepaths[@]}"; do
    file_name=$(basename "$tempFilepath")
    directory=$(echo "/tmp/$file_name" | sed 's/\.[^.]*$//')
    printf "Directory %s\n" "$directory"
    directorypaths+=("$directory")

    if [ -d "$directory" ]; then
        # Directory exists, continue
        printf "\nThe directory %s exists." "$directory"
        mv "$tempFilepath" "$directory"
    else
        # Directory does not exist, create it and then move the file
        mkdir -p "$directory"
        mv "$tempFilepath" "$directory"
        printf "Created the directory %s.\n" "$directory"
        printf "Moved the file %s to directory %s.\n" "$tempFilepath" "$directory"
    fi
done

# Loops through all the new directorys, searches for the file, takes pictures, then deletes pictures that did not render value.
for directorypath in "${directorypaths[@]}"; do
    log_file=$directorypath/log_file.txt
    file=$(find "$directorypath" -type f)
    if [ ! -f "$file" ]; then
        printf "File in directory %s not found.  Exiting script.\n" "$directorypath"
        exit 1
    fi
    numberoflines=$(wc -l "$file")
    count=0
    while read -r url; do
        ((count++))
        full_url=$(printf "http://%s" "$url")
        printf "[+] %s - Processing %s out of %s urls.\n" "$(date +%F_%T)" "$count" "$numberoflines" | tee -a "$log_file"
        printf "[+] %s - Processing the following URL: %s\n" "$(date +%F_%T)" "$url" | tee -a "$log_file"
        image_name=$(printf "%s/%s.png" "$directorypath" "$url")
        printf "[+] %s - Saving image: %s\n" "$(date +%F_%T)" "$image_name" | tee -a "$log_file"
        python3 screenshot.py "$full_url" "$image_name" 2>&1 | tee -a "$log_file"
        printf "[+] %s - Processing of URL completed: %s\n" "$(date +%F_%T)" "$url" | tee -a "$log_file"
    done <"$file"
done
