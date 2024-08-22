#!/bin/bash

# Update and upgrade the system
sudo apt-get update && sudo apt-get upgrade -y

# Install Python 3 and pip if not already installed
sudo apt-get install -y python3 python3-pip

# Install virtualenv for creating isolated Python environments
sudo pip3 install virtualenv

# Optional: Install additional dependencies (e.g., SQLite)
sudo apt-get install -y sqlite3 libsqlite3-dev

echo "System-level dependencies installed successfully."
