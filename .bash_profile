# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

export PATH
export PATH=$PATH:/research_jude/rgs01_jude/applications/hpcf/apps/homer/install/4.5/bin
export PATH=/hpcf/authorized_apps/rhel7_apps/R/install/3.6.1/bin:$PATH
export LD_LIBRARY_PATH=/lib
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
