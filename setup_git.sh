#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get current branch name
get_current_branch() {
    git branch --show-current
}

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
    # Create initial commit if empty repo
    if [ -z "$(git branch --list)" ]; then
        git commit --allow-empty -m "Initial commit"
    fi
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
git remote add origin "$REMOTE_URL"

# Get current branch name
CURRENT_BRANCH=$(get_current_branch)
if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="main"
    git checkout -b "$CURRENT_BRANCH" 2>/dev/null || true
fi

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
                # Try pushing with the current branch name
                if git push -u origin "$CURRENT_BRANCH"; then
                    echo -e "${GREEN}Push completed successfully to ${CURRENT_BRANCH}!${NC}"
                else
                    echo -e "${RED}Failed to push to ${CURRENT_BRANCH}. Trying with 'main'...${NC}"
                    if git push -u origin main; then
                        echo -e "${GREEN}Push completed successfully to main!${NC}"
                    else
                        echo -e "${RED}Failed to push. Please check your remote repository.${NC}"
                    fi
                fi
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
        git pull origin "$CURRENT_BRANCH" || git pull origin main
    fi
fi

echo -e "${GREEN}Git remote setup complete!${NC}"
echo -e "Current branch: ${YELLOW}$(get_current_branch)${NC}"