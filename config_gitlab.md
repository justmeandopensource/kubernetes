====== GIT ======

[[https://gitlab.digimind.tech/|{{ :workspace:logo-gitlab.png?500 | Got to Digimind GitLab}}]]

===== Help & Presentation =====

  * [[https://drive.google.com/drive/folders/1u076KisukE9VxQyg04s0qryDfvr38ROD|Training]]
  * [[http://rogerdudler.github.io/git-guide/index.fr.html|Git for beginners]]
  * [[https://github.com/k88hudson/git-flight-rules|A guide for astronauts (now, programmers using Git) about what to do when things go wrong]]
  * [[https://medium.com/@Andreas_cmj/how-to-setup-a-nice-looking-terminal-with-wsl-in-windows-10-creators-update-2b468ed7c326 | How to setup a nice looking terminal with WSL in Windows 10 Creators Update]]

==== Installation ====

=== Linux ===
For Archlinux:<code>sudo pacman -S git</code> 
For Debian based distribution:<code>sudo apt-get install git-core</code>
For Centos/Redhat/Fedora: <code>sudo yum install git</code>

=== Windows ===
Download the [[http://gitforwindows.org/|Git installer]] and follow the procedure

==== Configure Git ====
The first thing to do after installing Git is to define your user name and email:

<code>
git config --global user.email "my.email@digimind.com"
git config --global user.name "My Name"
</code>

For additional git configuration edit ''~/.gitconfig'' file:

<file txt ~/.gitconfig>
[core]
    editor = vim
    excludesfile = ~/.config/git/ignore
    autocrlf = input
    compression = 9
    filemode = false

[http]
    sslVerify = false

[credential]
    helper = store

[alias]
    # Log aliases
    ls = "!git --no-pager log -10 --decorate --pretty=format:'%C(yellow)%h%C(magenta)%d %C(reset)%s%C(blue) [%cn]%Creset'; echo"
    ll = "!git --no-pager log -10 --decorate --pretty=format:'%C(yellow)%h%C(magenta)%d %C(reset)%s%C(blue) [%cn]%Creset' --numstat; echo"
    lds = log --pretty=format:"%C(yellow)%h\\ %ad%C(magenta)%d\\ %C(reset)%s%C(blue)\\ [%cn]" --decorate --date=short
    ld = log --pretty=format:"%C(yellow)%h\\ %ad%C(magenta)%d\\ %C(reset)%s%C(blue)\\ [%cn]" --decorate --date=relative
    le = log --oneline --decorate
    lg = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'
    fl = log -u
    dl = "!git ll -1"
    dlc = diff --cached HEAD^
    dr  = "!f() { git diff "$1"^.."$1"; }; f"
    lc  = "!f() { git ll "$1"^.."$1"; }; f"
    diffr  = "!f() { git diff "$1"^.."$1"; }; f"
    f = "!git ls-files | grep -i"
    grep = grep -Ii
    gr = grep -Ii
    gra = "!f() { A=$(pwd) && TOPLEVEL=$(git rev-parse --show-toplevel) && cd $TOPLEVEL && git grep --full-name -In $1 | xargs -I{} echo $TOPLEVEL/{} && cd $A; }; f"
    la = "!git config -l | grep alias | cut -c 7-"
    done = "!f() { git branch | grep "$1" | cut -c 3- | grep -v done | xargs -I{} git branch -m {} done-{}; }; f"
    cp = cherry-pick
    st = status
    cl = clone
    ci = commit
    co = checkout
    br = branch 
    diff = diff --word-diff
    dc = diff --cached
    r = reset
    r1 = reset HEAD^
    r2 = reset HEAD^^
    rh = reset --hard
    rh1 = reset HEAD^ --hard
    rh2 = reset HEAD^^ --hard
    svnr = svn rebase
    svnd = svn dcommit
    svnl = svn log --oneline --show-commit
    sl = stash list
    sa = stash apply
    ss = stash save
    gr = log --graph --decorate --oneline

[color]
    ui = true

[color "branch"]
    current = yellow reverse
    local = yellow
    remote = green

[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold

[color "status"]
    added = yellow
    changed = green
    untracked = red

[diff]
    tool = meld

[difftool]
    prompt = false

[difftool "meld"]
    cmd = /usr/bin/meld "$LOCAL" "$REMOTE"

[mergetool "meld"]
    cmd = /usr/bin/meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"

[merge]
    ff = no
    commit = no
    tool = meld
    log = true

[pull]
    rebase = true

[push]
    default = simple

[url "https://bitbucket.org/"]
    insteadOf = bb:

[url "https://gitlab.digimind.tech"]
    insteadOf = digi:
</file>


Create a config folder:
''mkdir -p ~/.config/git/''

The ''~/.config/git/ignore'' contains global file/folder to ignore:

<file txt ~/.config/git/ignore>
*~

# temporary files which can be created if a process still has a handle open of a deleted file
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder which might appear on any partition or disk
.Trash-*

# .nfs files are created when an open file is removed but is still being accessed
.nfs*

.metadata
tmp/
*.tmp
*.bak
*.swp
*~.nib
local.properties
.settings/
.loadpath
.recommenders

# IntelliJ IDEA IDE
.idea
*.iml

# Eclipse Core
.project

# External tool builders
.externalToolBuilders/

# Locally stored "Eclipse launch configurations"
*.launch

# PyDev specific (Python IDE for Eclipse)
*.pydevproject

# CDT-specific (C/C++ Development Tooling)
.cproject

# JDT-specific (Eclipse Java Development Tools)
.classpath

# Java annotation processor (APT)
.factorypath

# PDT-specific (PHP Development Tools)
.buildpath

# sbteclipse plugin
.target

# Tern plugin
.tern-project

# TeXlipse plugin
.texlipse

# STS (Spring Tool Suite)
.springBeans

# Code Recommenders
.recommenders/

# Scala IDE specific (Scala & Java development for Eclipse)
.cache-main
.scala_dependencies
.worksheet
# swap
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
[._]s[a-v][a-z]
[._]sw[a-p]
# session
Session.vim
# temporary
.netrwhist
*~
# auto-generated tag files
tags

# Maven 
.mvn

# python bytecode
__pycache__

# compiled python files
*.pyc

# pytest cache
.pytest_cache

</file>


Further configuration options can be found at:
  * [[https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config|https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config]]

  * [[http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/ | http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/ ]]

==== Configure Maven ====

As we'll see in the section [[#usage|usage]], we use the [[https://www.atlassian.com/blog/software-teams/maven-git-flow-plugin-for-better-releases|Maven Git Flow Plugin]] to release project in place of Maven release plugin. This plugin is based on JGit and requires a git login/password in its configuration... It cannot use the Git credential from your ''.git-credentials'' file :-( So you need to pass these information to Maven command line. You can change your global ''MAVEN_OPTS'' variable like bellow:

<code bash>
GIT_CREDENTIALS=$(cat ~/.git-credentials | grep 'gitlab.digimind.tech' | sed 's/https:\/\/\(.*\)\@gitlab.digimind.tech/\1/' | sed 's/%\([0-9a-f][0-9a-f]\)/\\x\1/g' | xargs -0 printf "%b")
GIT_USER=$(echo $GIT_CREDENTIALS | cut -d: -f1)
GIT_PASSWORD=$(echo $GIT_CREDENTIALS | cut -d: -f2)

export MAVEN_OPTS="-Xmx4g -Dfile.encoding=UTF-8 -Dgit.user=$GIT_USER -Dgit.password=$GIT_PASSWORD"
</code>

===== Workflows =====

It's important that we all respect a common Git workflow. The worflow must be work with the project life cycle. Applications like DS and DI use a classic Scrum cycle, then [[https://jeffkreeftmeijer.com/git-flow/|Gitflow]] is a goog candidate. On this other hand, all backend services and futur microservices must be delivered using a CD pipeline. A workflow like Gitflow is to complicated to handle CD, [[https://guides.github.com/introduction/flow/|Github flow]] is a better choise in this case. 

==== Gitflow ====

The Gitflow workflow defines a strict branching model designed around the project release. This provides a robust framework for managing larger projects.  

Gitflow is ideally suited for projects that have a scheduled release cycle. 

{{ :workspace:gitflow.png?800 |}}

<WRAP center round important 60%>
FIXME This workflow needs to be completed to integrate merges from ''develop'' to feature branches. 
</WRAP>

== Permanent Branches ==

  * **master**: We consider origin/master to be the main branch where the source code of HEAD always reflects a production-ready state.
  * **develop** We consider origin/develop to be the main branch where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. Some would call this the //"integration branch"//. This is where any automatic nightly builds are built from.

== Temporary Branches ==

  * **feature-xxx**: These branches are created from the develop branch for the isolated development of a particular task are used to develop new features for the upcoming or a distant future release.
  * **release-xxx**: Release branches support preparation of a new production release. They allow for last-minute dotting of i’s and crossing t’s. Furthermore, they allow for minor bug fixes and preparing meta-data for a release (version number, build dates, etc.). By doing all of this work on a release branch, the develop branch is cleared to receive features for the next big release.
  * **hotfix-xxx**: Hotfix branches are very much like release branches in that they are also meant to prepare for a new production release, albeit unplanned. They arise from the necessity to act immediately upon an undesired state of a live production version. When a critical bug in a production version must be resolved immediately, a hotfix branch may be branched off from the corresponding tag on the master branch that marks the production version.

Feature and hotfix branches must include the releated Jira story ID in lower case, plus a short description. For instance, let says you're working on this feature: //<fc #7e57c2>ORION-557 Supporter les mises à jours de mentions dans la chaîne de traitement</fc>//. The feature branch must be created with a name like ''orion-557-support-mention-updates'':

<code>
$ git co develop
$ git pull
$ git co -b feature-orion-557-support-mention-updates
</code>

Once the feature is done and ready to integrate other features of the next release, you have to merge the branch into develop:

<code>
$ git co develop
$ git pull
$ git merge feature-orion-557-support-mention-updates
</code>

And don't forget to delete the branch in your local repository and in the remote if you pushed this branch:

<code>
$ git branch -d feature-orion-557-support-mention-updates
$ git push origin :feature-orion-557-support-mention-updates
</code>

An important difference between "permanent" and "temporary" branches is that no changes can be made directly to a "permanent" branch, they may only be inherited via the merge of a "temporary" branch.

== Usage ==

All is well explained on these pages:
  * [[https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow|Altassian tutorial]]. 
  * [[http://nvie.com/posts/a-successful-git-branching-model/|A successful Git branching model]]

<WRAP center round alert 60%>
You must master all the git commands under the hood before using the gitflow extensions. In fact, it's not recommend using this tool set in a first place.
</WRAP>

== Maven ==
[[https://www.atlassian.com/blog/software-teams/maven-git-flow-plugin-for-better-releases|Maven Git Flow Plugin]] is used to release project in place of Maven release plugin. This plugin also gives all gitflow commands using ''mvn''.

See help [[https://bitbucket.org/atlassian/jgit-flow/wiki/goals.wiki|on the web site]].

==== Github flow tuned ====

FIXME Work in progress

Github flow handles well projects with a CD workflow. It just missing the notion of release. To fix this drawback, we have to add a ''develop'' branch, inspired from Gitflow.

{{ :workspace:git-workflow.png |}}

== Permanent Branches ==

  * **master**: We consider origin/master to be the main branch where the source code of HEAD always reflects a production-ready state.
  * **develop** Same role as Gitflow, but this branch can be deployed to production at any time. **It has to be always stable**!

== Temporary Branches ==

  * **feature-xxx**: These branches are created from the develop branch for the isolated development of a particular task are used to develop new features for the upcoming or a distant future release.
  * **hotfix-xxx**: When a critical bug in a production version must be resolved immediately, a hotfix branch may be branched off from the corresponding tag on the master branch that marks the production version.
  * **bugfix-xxx**: Same role as ''hotfix-xxx'' on master, but for the ''develop'' branch.


===== Common commands =====

{{ :workspace:git-commands.png |}}

==== Committing ====

Write your commit message in the imperative: //"Fix bug"// and not "//Fixed bug"// or //"Fixes bug."// This convention matches up with commit messages generated by commands like git merge and git revert.

Here's a model Git commit message:

<code>
Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary.  Wrap it to about 72
characters or so.  In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body.  The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here

- Use a hanging indent
</code>
==== Pushing ====
FIXME

==== Synchronizing with a remote ====
FIXME

==== Getting the status and log ====
FIXME

==== Reverting changes ====
[[https://www.atlassian.com/git/tutorials/undoing-changes|https://www.atlassian.com/git/tutorials/undoing-changes]]

==== Managing branches ====
https://git-scm.com/book/fr/v2/Les-branches-avec-Git-Rebaser-Rebasing

  * starting from a specific branch (here develop)
<code>
git checkout develop
</code>

If you have defined aliases in your //.gitconfig// like explained in the section [[#configure_git|Configure Git]], you can also use this command:
<code>
git co develop
</code>

  * creating your own branch
<code>
git co -b feature-orion-610-system-monitoring develop
</code>

  * Merging your work
<code>
git co develop
git merge feature-orion-610-system-monitoring 
</code>

  * Deleting your branch
<code>
git branch -d feature-orion-259-kafka-monitoring
git push origin :feature-orion-259-kafka-monitoring
</code>

==== Stashing ====

FIXME






===== Tools =====
  * gitk or gitg
  * [[https://www.sourcetreeapp.com/|SourceTree]] (Windows only)

===== Best practices =====
  - **Use the command line**, it's the only way to learn Git and mastering it :-)
  - Always commit with a nice message that explains the purpose of the commit
  - Before ''git commit'', please ''git status'' to double check what you're going to commit
  - Commit many time a day with atomic commits: local modifications may require multiple commits
  - Push once a day or more if other commiters are working on the same branch as you
  - Before ''git push'', please ''git log'' to double check what you're going to push to public repository are therefor to the team
  - Respect the worflow
  - Always do your work in a branch
  - Do not rewrite Git history


===== Common mistakes =====

==== Forgetting to push ====
When commiting on the Git repository, the changes will only be applied on your local repository. To share your changes, you'll need to //git push//.

==== Rebase a public branch ====
Never, never, never rebase a branch you already pushed to origin: https://git-scm.com/book/fr/v2/Les-branches-avec-Git-Rebaser-Rebasing

If you do, people will hate you, and you'll be scorned by friends and family.

When you rebase stuff, you're abandoning existing commits and creating new ones that are similar but different. If you push commits somewhere and others pull them down and base work on them, and then you rewrite those commits with git rebase and push them up again, your collaborators will have to re-merge their work and things will get messy when you try to pull their work back into yours.
