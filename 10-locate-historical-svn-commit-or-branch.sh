
# For Lucene and Solr committers it may be occasionally
# handy to locate a historical SVN commit or branch (or a tag).
#
# All the branches ported from SVN are tagged and follow
# a naming convention of:
#
# history/branches/...
#
# so, for example:

git tag | grep "history/branches/"

# will display all the branches active at the time of migration.

# To locate a particular SVN commit you can grep through all
# commit logs as SVN commits have an amended log line in the
# format shown below:
#
# git-svn-id: https://svn.apache.org/repos/asf/lucene/dev/branches/LUCENE-2878@1411748 13f79535-47bb-0310-9956-ffa450edef68
#
# A git command that scans through all logs and retrieves SVN commit 1411748 would be therefore:

git log --grep="@1411748" --all

# which displays:

commit 6158e58e89a718ce5442331ea9a34394e8914ed6
Author: Alan Woodward <romseygeek@apache.org>
Date:   Tue Nov 20 17:03:33 2012 +0000

    LUCENE-2878: Add more tests for Brouwerian Query + fixes

    git-svn-id: https://svn.apache.org/repos/asf/lucene/dev/branches/LUCENE-2878@1411748 13f79535-47bb-0310-9956-ffa450edef68
