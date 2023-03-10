# Perimeterwalk
Perimeterwalk is a simple script that reads one or many root domains.  It checks crt.sh for subdomains, then the script proceeds to visit each domain and subdomain.  If the page renders, it takes a picture and submits the picture in the "/tmp/$root_domain" directory.

The intention is to check perimeter hygiene and to assess, potential opportunities for an adversary to break-in.  The script is simple and non-evasive.  It is an easy way to discover DNS names no longer pointing to a resource, subdomain hijacking opportunities, account take over opportunities, and servers that are outdated and forgotten about.

# Getting Started

## Pre-requisites
The script was developed and tested on WSL2 Ubuntu 20.04.5 LTS.  The script will check linux dependencies and python dependencies and exit if they are not met.  See the python requirements.txt file is included.

### Linux Dependencies
python >= 3.8.10  <br>
jq >= 1.6  <br>
pip >= 20.0.2  <br>
realpath >= 8.30  <br>
google-chrome >= 109.0.5414.74  <br>
chromedriver >= 109.0.5414.74 (https://chromedriver.chromium.org/downloads) - Must match version of Google Chrome installed  <br>

### Python Dependencies
fake-useragent >= 1.1.1  <br>
requests >= 2.28.2  <br>
selenium >= 4.7.2  <br>

# Usage
Instructions on how to use the project, including any command-line options or configuration settings.

Operating system tested on: WSL2 Ubuntu 20.04.5 LTS

## In linux command line, start in the parent directory perimeterwalk, copy and paste, leave out the "$" and don't copy and paste lines with "#"

```
# Install Linux Dependencies
$ sudo apt-get install python3.8
$ sudo apt-get install python3-pip
$ sudo apt-get install jq
$ realpath --version
$ sudo apt-get install unzip

# Install Google-Chrome
$ wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$ sudo apt install ./google-chrome-stable_current_amd64.deb
$ sudo apt install google-chrome-stable
# After installation remove the package
$ sudo rm ./google-chrome-stable_current_amd64.deb

# Check the version of Google-Chrome you have installed and take note for the drivers required
$ google-chrome --version

# Obtains the version of chrome webdriver required
$ webdriver_version=$(google-chrome --version | awk '{print $3}')
# Goes to the /tmp folder and tracks previous perimeter walk parent folder full path
$ pushd /tmp
# Downloads the driver
$ wget https://chromedriver.storage.googleapis.com/"$webdriver_version"/chromedriver_linux64.zip
# Unzips the driver
$ unzip chromedriver_linux64.zip
# Moves driver to an executable path
$ sudo mv chromedriver /usr/bin/chromedriver
# Checks to see what version of chromedriver was installed, it should match google-chrome --version
$ chromedriver --version
# Sends you back to the perimeter walk parent directory
$ popd
# Installs the python requirements
$ pip install -r requirements.txt
# Starts the program
$ bash perimeterwalk.sh
```

Add a root domain, for example: avertere.com
The files will be in /tmp/avertere.com when finished

You can use xdg-open to see the files even within the WSL environment.

### Watch the video on how to setup and run!
[![asciicast](https://asciinema.org/a/552670.png)](https://asciinema.org/a/552670)

```

# In the /tmp directory you can see all .com directories and open .png files within the directories. 
# It will timeout in 2 seconds. 
# To exit go to ctrl + C within the terminal.  
# If you want to autoloop while pictures are taken, just use a while true loop.
$ for i in /tmp/*.com; do timeout 2s xdg-open $i/*.png; done 

# To open a single file in /tmp folder
$ xdg-open /tmp/$directory/$filename.png
```

We recommend moving these files out of tmp for future reference and analysis. 

# Contributing
Thank you for your interest in contributing to our project! We welcome and appreciate any contributions, whether they are bug reports, bug fixes, feature requests, or code contributions.

## How to contribute
Here are some ways you can contribute to our project:

Report bugs or suggest new features by creating an issue on our GitHub repository.
Submit bug fixes or new features by creating a pull request.
Improve documentation by creating a pull request.
Test the project and provide feedback on its functionality and usability.

# Authors
bashguru [@bashguru(https://github.com/bashguru)]

# License
The MIT License (MIT)

Copyright (c) 2023 bashguru

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
