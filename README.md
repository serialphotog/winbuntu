# Winbuntu - The Ubuntu Linux Environment for Windows 10

Recent insider builds of Microsft's Windows 10 includes a system that they call The Windows Subsystem for Linux (WSL). This is a really cool system that allows you to run linux binaries on Windows 10, without using virtual machines or emulators. The Winbuntu project (Windows + Ubuntu = Winbuntu) aims to help blur the lines between Linux and Windows by making it super easy to set up an awesome Linux system on your Windows 10 install.

# How it works

To use Winbuntu, you will first need to [set up WSL](http://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/). You will then be able to launch Winbuntu by running the *linux.bat* batch script. Doing so will launch a local X server (needed for the graphical environment) and then pass control over to *environment.sh*, which will configure everything and launch our Linux GUI.

## Setting things up

To get started, you will need to [download and run the Winbuntu Cygwin Installer](http://www.hackeradam17.com/download-winbuntu/). This is just a simple Windows installer that sets up the minimum Cygwin configuration required to run our GUI. You can find the source for the Installer [here](https://github.com/serialphotog/winbuntu-cygwin-installer).

For this to be at all useful, you will need a git repository with your dotfiles and install scripts. You can [use mine](https://github.com/serialphotog/winbuntu-config) to help get you started. There are 3 things this is used for:

1. **The PACKAGES file:** This is a simple text file containing a list of packages that should be present on your system. If they aren't present, Winbuntu will install them for you. Each package name goes on a new line. The file also supports comments:
```
# This is a comment in the PACKAGES file
```

2. **The dotfiles Directory:** Any files located in this directory will be copied to your home directory. This makes importing and keeping your dotfiles up to date easy.

3. **The scripts Directory:** Any scripts located in this directory will be ran by Winbuntu. This is useful for setting up more complicated things. For example, I have a script to install Oh-My-ZSH.

It's also worth noting that Winbuntu will copy your dotfile before running scripts. This means you can have scripts to do fancy things with your dotfiles, if you so desire.

### environment.sh Settings

The *environment.sh* file contians the following structure towardst the top of the file:
```
#####
# The environment configuration
#####
typeset -A config # init array
config=( # set default values in config array
    [gitRepo]="https://github.com/serialphotog/winbuntu-config.git"
    [workingDir]="/tmp/winbuntu/"
    [guiCommand]="i3"
)
```

You will want to configure these settings to match your needs. The settings are:

* **gitRepo** The git repository containing your PACKAGES file, scripts, and dotfiles
* **workingDir** You probably won't need to change this, but this is where Winbuntu clones your git repository to
* **guiCommand** This is the command Winbuntu uses to start the Linux GUI on our X server.