
# It is assumed you have git (command line version, GUI tools will have 
# their buttons/ switches to do similar operations) installed.

# The first thing you probably want to do is to clone the Lucene-Solr repository.
# Cloning does this:
#   - it copies all of the revision history (branches, tags)
#   - it saves them under .git/ 
#   - it checks out the master branch (SVN's trunk) by default.
#   - it "remembers" the fact that you cloned the repository from somewhere. 
#     This "somewhere" is called "origin" (by default).

git clone https://git-wip-us.apache.org/repos/asf/lucene-solr.git
cd lucene-solr

# Before you start working you may wish to set up your name and e-mail so that they
# show up properly in commit logs.

git config user.name "My Name"
git config user.email myname@apache.org

