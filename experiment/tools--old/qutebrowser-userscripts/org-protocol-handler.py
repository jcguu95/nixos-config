import os
import sys
import urllib.parse

# Expect called by qutebrowser
# First argument should be the qb expansion of {url:pretty}.
# Second argument should be the qb extension of  {title}.

# The main point of this script is to escape "&" to "%26" by using
# "urllib.parse.quote".

url   = urllib.parse.quote(sys.argv[1])
title = urllib.parse.quote(sys.argv[2])

command = "emacsclient \"org-protocol://roam-ref?template=r&ref="+url+"&title="+title+"\""
os.system(command)
