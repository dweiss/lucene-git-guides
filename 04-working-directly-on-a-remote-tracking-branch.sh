
# 
# In the SVN world one typically works "directly" on a branch that is 
# first checked out, and then committed back to the repository. If any
# other committer added something in between, SVN would request
# an "update" which would fetch new stuff from the server and either
# merge it automatically or create so-called conflicts, which need
# to be resolved by the developer.
#
# In the git world it is typically preferable to postpone this "update"
# until one either:
#   - decides he or she is ready to fold in the changes back
#     to a public branch (from a series of commits on a local or feature 
#     branch) or consolidate, or
#   - decides he or she is is not ready yet, but would like to merge in
#     (and possibly resolve conflicts) of anything that happened 
#     in between.
#
# But if one so desires (or if the patch is really tiny) the SVN-like
# workflow can be very closely simulated by committing "directly" to
# a local branch that tracks a remote branch and then pushing those
# changes back.
#
# The crucial element is to understand what happens if somebody has made
# changes on the remote side and how to resolve this situation. 
#
# The example below attempts to show how to work directly on a remote 
# branch and what can happen if somebody committed something in between.
#

# Let's fetch our repository that will mimick "Apache" first:

git clone --bare https://git-wip-us.apache.org/repos/asf/lucene-solr.git

# Note the 'bare' option. This tells git to clone the repositor as if it
# were a server-side thing (no checkout of any branches). This was we won't
# screw up and accidentally push our changes to actual Apache server...

# Now we can consider this "lucene-solr" to be the "origin" for two users:
# doug and adam. Ideally, open up two terminals and type in each, 
# correspondingly:

git clone lucene-solr.git douglas
git clone lucene-solr.git adam

# This leaves two "checkouts" of the master branch -- one for adam, one for 
# douglas, both pointing at our lucene-solr as the "origin". Verify this by
# typing:

cd adam
git remote -v

# In my case (Windows) this shows:
#
# c:\_tmp\guide\adam>git remote -v
# origin  C:/_tmp/guide/lucene-solr.git (fetch)
# origin  C:/_tmp/guide/lucene-solr.git (push)
#
# This will be our testbed for further experiments.

# ===========
# SCENARIO 1. modify-and-push succeeds
# ===========
#
# Let's assume adam needs to modify master and push the changes there. 

cd adam
echo "adam changed readme.txt" >> README.txt
git add -A .
git commit -m "Added foo."

# If we now do a "push" Adam's changes will be saved to the origin:

git push

# which shows:

Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 319 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
To C:/_tmp/guide/lucene-solr.git
   3a88930..bb65c37  master -> master

# In the easy scenario (if nothing changes on the remote) this is the 
# simplest workflow one can imagine. Obviously, things get a bit more
# complicated if there have been changes on the remote. Let's simulate
# this with douglas.

# ===========
# SCENARIO 2. push fails. 
# ===========

cd douglas
echo "douglas changed readme.txt" >> README.txt
git add -A .
git commit -m "Added foo."

# when douglas tries to push his changes this will happen:

To C:/_tmp/guide/lucene-solr.git
 ! [rejected]        master -> master (fetch first)
error: failed to push some refs to 'C:/_tmp/guide/lucene-solr.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

# the help here pretty much explains what happened, but it suggests to use 'pull',
# which is (in my opinion) one step too far. Let's first see what's changed on the
# remote. This is SAFE, it won't affect the current local set of changes.

git fetch origin

# which shows:

remote: Counting objects: 3, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
From C:/_tmp/guide/lucene-solr
   3a88930..bb65c37  master     -> origin/master

# we fetched all the remote commits (and labels) from origin. Let's see how the tips
# (HEAD references) of our master and remote master differ:

gitk master origin/master

# once you issue the above command it's clear that we can't simply push our commit 
# because it's not "on top" of the latest commit on the remote master. We have a few
# options now:
# 1) we can take whatever commit(s) we've made to the local branch and re-apply them
# on top of the latest commit on the remote branch. This is called a "rebase" in git.
# 2) we can MERGE changes from the remote master into our local master. A merge (assuming
# it succeeds) will create a new commit (on our local branch) which we can then push to
# the remote.
# 3) we can discard local changes and RESET the local master branch to the remote's HEAD.
# sometimes this isn't as bad as it seems (for example when somebody committed exactly
# the stuff we wanted to commit).
#
# Which of the above is 'git pull' then? Well, it's essentially two commands: a fetch and a merge,
# so in this example it'd be:

git fetch origin
git merge origin/master

# The downside of an automatic merge (or autoatic rebase) is that should a conflict occur, 
# the resolution must happen immediately which can be a bit frustrating, especially for those new
# to git.
#
# Let's go back to douglas and try all of the above options so that we can see their 
# consequences. Note that in order to try all the options we will "revert" the state 
# of the (local) master branch after each attempt. For this, we will need a hash of
# the commit master is currently pointing to:

git log -1

# which in my case shows:

commit 13b9bf1b5a25279256b41381ebaa9a0e9428df84
Author: Dawid Weiss <dawid.weiss@carrotsearch.com>
Date:   Wed Feb 3 17:32:53 2016 +0100

    Added foo.

# so the "revert" hash will be "13b9bf1" (a sensibly long prefix of the full checksum).

#
# OPTION 3: resetting to remote master.
#
# Let's start with option 3 as it's the simplest one. We just discard local work.

git reset --hard origin/master

# now, look at the commit graph:

gitk master origin/master

# douglas's local changes are gone. He can start over. :)

# git tries hard not to remove any committed stuff from history. If it's not directly
# referenced it will not *show it*, but it's still there. Since we know our commit's hash
# we can see it's still there, look:

gitk master origin/master 13b9bf1

# So reverting to the previous state (and saving douglas's work) would be as simple as:

git reset --hard 13b9bf1

# confirm it with:

gitk master origin/master

#
# OPTION 2: merge with master
#
# This is what git pull will try to do, but let's do it manually:

git merge origin/master

# which results in:

Auto-merging README.txt
CONFLICT (content): Merge conflict in README.txt
Automatic merge failed; fix conflicts and then commit the result.

# we have a conflict, let's see which files needs to be resolved:

git status

# which results in:

On branch master
Your branch and 'origin/master' have diverged,
and have 1 and 1 different commit each, respectively.
  (use "git pull" to merge the remote branch into yours)
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   README.txt

no changes added to commit (use "git add" and/or "git commit -a")

# the "unmerged paths" are the files in which conflicts occur. Conflict markers are typical (and similar to 
# what you should be familiar from the SVN world), but git diff will show them to you:

git diff

# which displays:

diff --cc README.txt
index ab13e8b,cae6c64..0000000
--- a/README.txt
+++ b/README.txt
@@@ -11,4 -11,4 +11,8 @@@ For Maven info, see dev-tools/maven/REA
  For more information on how to contribute see:
  http://wiki.apache.org/lucene-java/HowToContribute
  http://wiki.apache.org/solr/HowToContribute
++<<<<<<< HEAD
 +"douglas changed readme.txt"
++=======
+ "adam changed readme.txt"
++>>>>>>> origin/master

# How to resolve the conflict? Edit the readme.txt file and delete or consolidate the
# changes (obviously) and then add the (resolved) conflicts to staging are. In our case:

git add readme.txt	

# now issue a commit:

git commit

# and observe what the default comment is. It should read something like:

Merge remote-tracking branch 'origin/master'

# Look at what happened to the commit graph now:

gitk master origin/master

# this "bump" in the linear history will be preserved (you did commit a merge after all!) and 
# many people think it's really a useless noise that should not be pushed to a public repository.
# A better option would be to take your (local) commit and simply re-apply it on top of the
# remote. This is the third option -- the infameous rebase.

# Like previously, let's revert the state of the local master branch to our saved hash first (note
# we can still do it safely -- we have not pushed anything yet to the remote!).

git reset --hard 13b9bf1

#
# OPTION 3: rebase changes from a local to remote tracking branch before pushing.
#
#
# Without further comments, we reapply whatever we've done to origin/master by:

git rebase origin/master

# which unfortunately results in a conflict and a lengthy log:

First, rewinding head to replay your work on top of it...
Applying: Added foo.
Using index info to reconstruct a base tree...
M       README.txt
<stdin>:10: trailing whitespace.
"douglas changed readme.txt"
warning: 1 line adds whitespace errors.
Falling back to patching base and 3-way merge...
Auto-merging README.txt
CONFLICT (content): Merge conflict in README.txt
Failed to merge in the changes.
Patch failed at 0001 Added foo.
The copy of the patch that failed is found in:
   C:/_tmp/guide/douglas/.git/rebase-apply/patch

When you have resolved this problem, run "git rebase --continue".
If you prefer to skip this patch, run "git rebase --skip" instead.
To check out the original branch and stop rebasing, run "git rebase --abort".

# let's see what the status of our files is:

git status

# displays:

rebase in progress; onto bb65c37
You are currently rebasing branch 'master' on 'bb65c37'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)

Unmerged paths:
  (use "git reset HEAD <file>..." to unstage)
  (use "git add <file>..." to mark resolution)

        both modified:   README.txt

no changes added to commit (use "git add" and/or "git commit -a")

# Ha! So it's essentially the same as with merge. *However* note the last
# step of how you resolve the conflict is not a commit!

git add README.txt
git status

# this time shows:

rebase in progress; onto bb65c37
You are currently rebasing branch 'master' on 'bb65c37'.
  (all conflicts fixed: run "git rebase --continue")

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.txt

# so, let's continue rebasing:

git rebase --continue

# which displays:

Applying: Added foo.

# and silently ends. Observe the commit tree again, ideally display the "previous" state of the
# master, before the rebase:

gitk master origin/master 13b9bf1

# Note how the "local" commit was replanted on top of origin/master and how your current master
# now points at it, preserving linear history? Well, that's all there is to it. Douglas can now
# push (and hope nothing has changed in between).

git push

# which shows:

Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 375 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
To C:/_tmp/guide/lucene-solr.git
   bb65c37..7f0da5a  master -> master

# Done.

# ===========
# FINAL NOTE. fast forwards.
# ===========

# Now recall a 'git pull' was a combined 'fetch and merge'. Does it always create those little
# bubbles in commit history? Let's see what's going to happen to adam if he fetches changes from
# the remote now:

cd adam
git fetch

# observe the commit tree:

gitk master origin/master

# There are no commits that would be "in between" adam's current local master and the 
# remote master. We could simply reset the local master reference to origin/master and
# be done with it. In short, this is exactly what a "fast forward" merge is. 
#
# Let's see what a "git pull" will do to adam:

git pull

# which displays:

Updating bb65c37..7f0da5a
Fast-forward
 README.txt | 4 ++++
 1 file changed, 4 insertions(+)

# See the "fast-forward" bit? There was no merge at all, the reference of master was just 
# moved to origin/master.

