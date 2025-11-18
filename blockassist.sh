#!/usr/bin/env bash
set -euo pipefail

#########################################
#           EVMPAPA PYENV SETUP         #
#########################################

# ============ COLORS ============
CYAN='\033[0;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'
BOLD='\033[1m'

# ============ LOGGING ============
info()    { printf "${CYAN}[INFO]${RESET} %s\n" "$*"; }
success() { printf "${GREEN}[✓]${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}[!]${RESET} %s\n" "$*"; }
error()   { printf "${RED}[✗]${RESET} %s\n" "$*"; }

# ============ BANNER ============
clear
echo -e "${PURPLE}${BOLD}"
cat <<'EOF'
  _____   ___ __ ___  _ __   __ _ _ __   __ _ 
 / _ \ \ / / '_ ` _ \| '_ \ / _` | '_ \ / _` |
|  __/\ V /| | | | | | |_) | (_| | |_) | (_| |
 \___| \_/ |_| |_| |_| .__/ \__,_| .__/ \__,_|
                     | |         | |          
                     |_|         |_|          

EOF
echo -e "${YELLOW}                 :: Powered by evmpapa ::${RESET}\n"

# ============ ENVIRONMENT ============
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash || true)"

# ============ CHECK & INSTALL COMMANDS ============
check_or_install() {
    local cmd="$1"
    local install_cmd="$2"
    if ! command -v "$cmd" &>/dev/null; then
        info "Installing $cmd..."
        eval "$install_cmd"
    else
        success "$cmd is already installed."
    fi
}

# npm / yarn / localtunnel
check_or_install npm "sudo apt update && sudo apt install -y npm"
check_or_install yarn "sudo npm install -g yarn"
check_or_install lt "sudo npm install -g localtunnel"

# ============ RUN SETUP.SH ============
if [[ -f setup.sh ]]; then
    info "Running setup.sh..."
    chmod +x setup.sh
    ./setup.sh
else
    warn "setup.sh not found, skipping..."
fi

# ============ BUILD DEPENDENCIES FOR PYENV ============
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    info "Installing build dependencies for pyenv..."
    sudo apt install -y \
        build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev \
        libxmlsec1-dev libffi-dev liblzma-dev zip
fi

# ============ INSTALL PYENV ============
if ! command -v pyenv &>/dev/null; then
    info "Installing pyenv..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pyenv
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl https://pyenv.run | bash
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init - bash)"
    fi
else
    success "pyenv is already installed."
fi

# ============ INSTALL PYTHON 3.10 ============
if ! pyenv versions --bare | grep -q "^3.10"; then
    info "Installing Python 3.10..."
    pyenv install 3.10
fi
pyenv local 3.10
success "Python 3.10 set as local version."

# ============ PIP PACKAGES ============
info "Upgrading pip and installing required packages..."
pip install --upgrade pip
pip install psutil readchar
success "Python packages installed."

# ============ SCREEN INSTALLATION ============
check_or_install screen "sudo apt install -y screen"

# ============ FINAL MESSAGE ============
success "✅ Setup complete!"
echo -e "\nScreen Commands:"
echo -e "  Create session:  ${BOLD}screen -S blockassist${RESET}"
echo -e "  Detach session:  ${BOLD}Ctrl+A, D${RESET}"
echo -e "  Stop session:    ${BOLD}screen -S blockassist -X quit${RESET}\n"
