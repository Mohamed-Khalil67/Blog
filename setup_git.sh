#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt yes/no
prompt_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Initialize Git if not already
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Initializing new Git repository...${NC}"
    git init
else
    echo -e "${GREEN}Existing Git repository found.${NC}"
fi

# Check for existing remotes
REMOTE_EXISTS=$(git remote -v)
if [ -n "$REMOTE_EXISTS" ]; then
    echo -e "${YELLOW}Current remotes:${NC}"
    git remote -v
    if prompt_yes_no "Do you want to remove existing remotes?"; then
        git remote remove origin
    fi
fi

# Set up remote
echo -e "${YELLOW}Setting up remote repository...${NC}"
read -p "Enter remote repository URL (e.g., git@github.com:user/repo.git): " REMOTE_URL
git remote add origin $REMOTE_URL

# Check for changes
CHANGES_EXIST=$(git status --porcelain)
if [ -n "$CHANGES_EXIST" ]; then
    echo -e "${YELLOW}The following changes were detected:${NC}"
    git status -s
    
    if prompt_yes_no "Do you want to stage all changes?"; then
        git add .
        
        echo -e "${YELLOW}Staged changes:${NC}"
        git status -s
        
        if prompt_yes_no "Do you want to commit these changes?"; then
            read -p "Enter commit message: " COMMIT_MSG
            git commit -m "$COMMIT_MSG"
            
            if prompt_yes_no "Do you want to push to remote?"; then
                echo -e "${YELLOW}Pushing to remote repository...${NC}"
                git push -u origin master
                echo -e "${GREEN}Push completed!${NC}"
            else
                echo -e "${YELLOW}Changes committed but not pushed.${NC}"
            fi
        else
            echo -e "${YELLOW}Changes staged but not committed.${NC}"
        fi
    else
        echo -e "${RED}Changes not staged.${NC}"
    fi
else
    echo -e "${GREEN}No changes detected.${NC}"
    
    if prompt_yes_no "Do you want to pull from remote?"; then
        git pull origin master
    fi
fi

echo -e "${GREEN}Git remote setup complete!${NC}"