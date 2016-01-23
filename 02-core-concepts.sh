
# Let's see what our "remote" repositories are (after you've checked out a repo):
git remote -v

# this should display:
#   origin  https://git-wip-us.apache.org/repos/asf/lucene-solr.git (fetch)
#   origin  https://git-wip-us.apache.org/repos/asf/lucene-solr.git (push)
# so the 'origin' is the repository you can "fetch" any new commits from
# and "push" your own stuff to.
#
# It is now important to understand the difference between "local" and "remote"
# branches. Let's see which branch we're on:

git branch

# This should display "master". This branch is *yours*, any commit you make to it
# will stay on your machine. But it is also a bit special because it "tracks" another
# branch -- this one is a remote branch pointing at commits that have happened
# on the origin server. You can see this when you say:

git status

# which prints:

On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean

# So the "remote" branch your master is attached on is called "origin/master". 
# The relationship between these two is best explained if you run a graphical
# depiction of the commit tree, try this:

gitk master origin/master

# you should see two "labels" attached to the same commit (unless you have changed
# something already). These "labels" are always pointing at some commit -- either
# one you have made or one somebody has made. You can also ask a reference which commit
# it points to:

git log -1 master
git log -1 origin/master

# Should display the same commit. What's important is you can "diff" the state of the
# tree between any two references -- this is extremely helpful in many situations. For
# example:

git diff master..origin/master

# will display nothing because these two are currently identical.

# Now, let's say we wish to change something:

echo "foo" >> README.txt

# Let's see the difference between our current checkout and master:

git diff master

# should display something like this:

diff --git a/README.txt b/README.txt
index 3599b5b..e149880 100644
--- a/README.txt
+++ b/README.txt
@@ -11,3 +11,4 @@ For Maven info, see dev-tools/maven/README.maven
 For more information on how to contribute see:
 http://wiki.apache.org/lucene-java/HowToContribute
 http://wiki.apache.org/solr/HowToContribute
+"foo" 

# This makes sense. If you wish to see just the overview of which files have been changed, you
# would type:

git status

# which would print:

On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   README.txt

no changes added to commit (use "git add" and/or "git commit -a")

# What does it mean? Well, coming from SVN you may be tempted to do this:

git commit -m "My commit"

# which will print:

On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
        modified:   README.txt

no changes added to commit

# What does "not staged for commit mean"? Git has something called a "staging" area -- 
# this is where all the changes that should become part of the commit are saved
# before they are actually commited. So you need to explicitly "add" or "remove" any
# files that should be part of the next commit. In our example, it'd be:

git add README.txt

# if you type:

git status

# you'll see what will be commited:

On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.txt

# Now comes the counterintuitive part. Unlike in SVN, the staging area is *not* the
# working copy. So if you do this:

echo "bar" >> README.txt

# the "bar" wouldn't be commited because you added README.txt to the staging area 
# before you modified README.txt. You can see these are distinct areas if you type:

git status

# which prints:

On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.txt

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   README.txt

# When is this thing helpful? In my personal experience I find it quite useful to 
# separate a modified local state into multiple commits, but it's also a convenient
# scratch area before you actually commit anything. There's more to staging than this
# -- you can look it up on the web.

# Let's say we do want "bar" to be part of the next commit, we'd just add it again:

git add README.txt

# or you can do:

git add -A .

# which recursively adds (and also records any deletions) of all modified files in your 
# current folder. Afterward you'd check what is to be committed:

git status

On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.txt

# and commit:

git commit -m "My commit."

[master 0ab5e39] My commit.
 1 file changed, 2 insertions(+)

# Now recall local and remote branches. You added one commit node to your local master branch. 
# visualize what the commit tree looks like and confirm your intuition with:

gitk master origin/master

# so your "master" is one commit ahead than origin/master. git actually says so if you type:

git status

On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)
nothing to commit, working directory clean

# What happens if you "git push"? Well, it depends -- if there are any new commits on the
# remote branch master (at origin) then such a push will be rejected. You need to somehow
# decide what to do -- either you need to create a new commit node that "merges" remote
# commits with your own commit or you need to "rebase" -- in simple terms repeat your local
# unique commits on top of the ones that appeared on the remote while you were working.
#
# If there were no new commits at origin then the remote repository can simple accept your 
# commits and advance its own "master" reference to point to your master's latest commit.

# We will end this with something else, though. If git references are just lightweight
# labels pointing at commits then can we simply move our local "master" label to some other
# commit? Sure we can. Let's move it to origin/master, effectively "forgetting" the commit 
# we made (note this is not the same as reverting because you can point your branch at *any*
# commit in git repo).

git reset --hard origin/master

# which prints something like:

HEAD is now at [commit hash] [log message]

# What do you think gitk master origin/master will show now? What will "git status" display?






