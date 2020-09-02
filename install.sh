#!/bin/bash
set -u

##Color Print Helpers
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"
shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

##Abort
abort() {
  printf "%s\n" "$1"
  exit 1
}

##PrettyPrint
ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

##CheckSudo
have_sudo_access() {
  if [[ $EUID -ne 0 ]]; then
    abort "Please re-run with sudo access!"
    exit 1
  fi
}

#################################### Script #########################################

#Must run with root
have_sudo_access;

qe_config_dir=$(eval echo "~$SUDO_USER")/.qe
qe_root_dir=$(eval echo "~$SUDO_USER")/qe
qe_bin_dir=$(eval echo "~$SUDO_USER")/qe/bin

ohai "This script will install:"
echo "- $qe_config_dir"
echo "- /usr/local/bin/qe"
echo "- $qe_bin_dir/git-import"

# if the OS is Linux.
if [[ "$(uname)" = "Linux" ]]; then
  QE_ON_LINUX=1
  if [[ "$(uname -m)" = "x86_64" ]]; then
    QE_ON_64_BIT=1
  fi
fi

#Check if the OS is MacOS (darwin).
if [[ "$(uname)" = "Darwin" ]]; then
  QE_ON_DARWIN=1
  if [[ $(getconf LONG_BIT) = "64" ]]; then
    QE_ON_64_BIT=1
  fi
fi

#Check if the bin folder is present.
if [[ ! -d "/usr/local/bin" ]] ; then
  mkdir -p /usr/local/bin
  chown $SUDO_USER:"$(id -g $SUDO_USER)" /usr/local/bin
fi

#Obtain QE Binary.
if [[ "${QE_ON_LINUX-}" ]]; then
  if [[ "${QE_ON_64_BIT-}" ]]; then
    curl -S -L "https://github.com/zapatacomputing/qe-cli/releases/latest/download/qe-linux-amd64" -o /usr/local/bin/qe
  else
    curl -S -L "https://github.com/zapatacomputing/qe-cli/releases/latest/download/qe-linux-386" -o /usr/local/bin/qe
  fi
elif [[ "${QE_ON_DARWIN-}" ]]; then
  if [[ "${QE_ON_64_BIT-}" ]]; then
    curl -S -L "https://github.com/zapatacomputing/qe-cli/releases/latest/download/qe-darwin-amd64" -o /usr/local/bin/qe
  else
    curl -S -L "https://github.com/zapatacomputing/qe-cli/releases/latest/download/qe-darwin-386" -o /usr/local/bin/qe
  fi
else
  abort "Only Linux and MacOS is supported with this installer. Please go to https://github.com/zapatacomputing/qe-cli for latest releases."
fi

#Ensure QE Binary is executable.
chmod +x /usr/local/bin/qe

#Make QE Config Dir
mkdir -p $qe_config_dir
chown $SUDO_USER:"$(id -g $SUDO_USER)" $qe_config_dir
#Make QE Bin Dir
mkdir -p $qe_bin_dir
chown $SUDO_USER:"$(id -g $SUDO_USER)" $qe_root_dir
chown $SUDO_USER:"$(id -g $SUDO_USER)" $qe_bin_dir

#Obtain git-import.
if [[ "${QE_ON_LINUX-}" ]]; then
  if [[ "${QE_ON_64_BIT-}" ]]; then
    curl -S -L "https://github.com/zapatacomputing/git-import/releases/latest/download/git-import-linux-amd64" -o $qe_bin_dir/git-import
  else
    curl -S -L "https://github.com/zapatacomputing/git-import/releases/latest/download/git-import-linux-386" -o $qe_bin_dir/git-import
  fi
elif [[ "${QE_ON_DARWIN-}" ]]; then
  if [[ "${QE_ON_64_BIT-}" ]]; then
    curl -S -L "https://github.com/zapatacomputing/git-import/releases/latest/download/git-import-darwin-amd64" -o $qe_bin_dir/git-import
  else
    curl -S -L "https://github.com/zapatacomputing/git-import/releases/latest/download/git-import-darwin-386" -o $qe_bin_dir/git-import
  fi
else
  abort "Only Linux and MacOS is supported with this installer. Please go to https://github.com/zapatacomputing/qe-cli for latest releases."
fi

chmod +x $qe_bin_dir/git-import

#Success.
ohai "Installation successful!"

#Ding!
if [[ -t 1 ]]; then
  printf "\a"
fi

ohai "Next steps:"
echo "- Run \`qe help\` to get started"
echo "- Further documentation: "
echo "    https://orquestra.io/docs"
exit 0
