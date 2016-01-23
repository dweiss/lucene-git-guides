
# In this scenario we simply checkout branch X from origin,
# create some changes on a local branch Y, modify something and
# create a diff for Jira.
#
# We will use a branch Y that is "non-tracking", that is "safe" --
# even if you try hard to mess up, you won't be able to push your
# changes to the origin (because git won't know which remote branch
# to push them to).
#
# It is assumed you cloned the repository and you're on master branch.

# Let's create a local branch for our changes. We will branch off from
# the current state of origin's branch_5x, but first fetch any commits
# from origin to sync it up. Note this is always safe as it just imports 
# remote commits and moves remove references, it doesn't do anything to your
# local branches or their state:

git fetch origin

# Now we can create our own local branch:
git checkout origin/branch_5x -b foobar --no-track

# as always, it helps to "see" where we are:
gitk .

# Now, let's make some changes:

echo "foo" >> README.txt
git add -A .
git commit -m "Added foo."

echo "bar" >> README.txt
git add -A .
git commit -m "Added foo."

# You have two commits "on top" of the commit you branched from. Again, it's helpful to:

gitk .

# Note you can't "push" (or rather: nothing will happen) because branch foobar isn't
# tracking any remote branch. It's just your local changes. We can, however, create
# a perfectly usable diff/patch from it:

git diff origin/branch_5x..foobar > foobar.patch

# That's it, for simple changes and non-committers, this is just fine.
