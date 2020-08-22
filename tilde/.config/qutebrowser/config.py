# Autogenerated config.py
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

import os

# Uncomment this to still load settings configured via autoconfig.yml
# config.load_autoconfig()

# Enable JavaScript.  Type: Bool
config.set('content.javascript.enabled', True, 'file://*')
# Enable JavaScript.  Type: Bool
config.set('content.javascript.enabled', True, 'chrome://*/*')
# Enable JavaScript.  Type: Bool
config.set('content.javascript.enabled', True, 'qute://*/*')

config.set('fonts.default_family', "xos4 Terminus") # works for archlinux
config.set('auto_save.interval', 5000)
config.set('auto_save.session', True)
config.set('content.pdfjs', False)
config.set('downloads.location.directory', "~/")
config.set('messages.timeout', 30000)
config.set('spellcheck.languages', ["en-US"]) # ..?
config.set('tabs.position', "top")
config.set('content.plugins', True)
config.set('url.default_page', "file:///"+os.environ["HOME"]+"/.config/qutebrowser/void.html")
config.set('url.start_pages', "file:///"+os.environ["HOME"]+"/.config/qutebrowser/void.html")
config.set('editor.command', ["/usr/bin/vim", "-f", "{file}", "-c", "normal {line}G{column0}l"])
config.set('zoom.default', 120)
# Change 'd' to 'dd', so I won't close it unpurposely while scrolling down with <Ctrl-d>. It's also more Vim-like!
config.bind('dd', "tab-close")
config.unbind('d')

# Unbind C-q to prevent acc. closing qb.
config.unbind('<Ctrl-q>')

# Vim-like experince
config.bind('o',"set-cmd-text -s :open -t" ) ## Open and switch focus to a new tab; by default this is done by 'O'.
config.bind('O',"set-cmd-text -s :open -b") ## Open a new tab; by default this is done by 'xo'.
config.bind('xo',"set-cmd-text -s :open") ## Open a new tab replacing the current one; by default this is done by 'o'.

# Clear History
##config.bind('ch',"history-clear")
config.bind('clear',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/backup_and_clear_history")

# User Scripts!
config.bind(';m',"hint links spawn mpv {hint-url}")
config.bind(';M',"spawn mpv {url}") 
config.bind('aa',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/save_for_yta")
config.bind('av',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/save_for_ytv")
config.bind(';aa',"hint links userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/save_for_yta")
config.bind(';av',"hint links userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/save_for_ytv")
config.bind('aw',"spawn bash -c 'vocab -a {primary}' ")
config.bind('wo',"open -b https://www.macmillandictionary.com/dictionary/british/{primary}")
config.bind('track',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/tracker")
config.bind('sw', 'spawn --userscript '+os.environ["HOME"]+'/.scripts/qutebrowser-userscripts/search_word')
config.bind('ac', 'spawn --userscript '+os.environ["HOME"]+'/.scripts/qutebrowser-userscripts/add_clip')

# Qute-capture (integrated with org-mode and dmenu)
config.unbind('M')
config.unbind('m')
config.bind('M+',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/qute-capture write")
config.bind('M=',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/qute-capture read")
config.bind('M-',"spawn --userscript "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/qute-capture rm")

# Issue 5178
## https://github.com/qutebrowser/qutebrowser/issues/5178
c.qt.force_software_rendering = 'software-opengl'

# org-roam protocol without javascript
config.bind("<Ctrl-r>", "spawn python "+os.environ["HOME"]+"/.scripts/qutebrowser-userscripts/org-protocol-handler.py \"{url:pretty}\" \"{title}\"")

# colors
c.fonts.default_size = '15pt'

myColor0      = '#282828'; myColor8      = '#928374'; # black
myColor1      = '#cc241d'; myColor9      = '#fb4934'; # red
myColor2      = '#98971a'; myColorA      = '#b8bb26'; # green
myColor3      = '#d79921'; myColorB      = '#fabd2f'; # yellow
myColor4      = '#458588'; myColorC      = '#83a598'; # blue
myColor5      = '#b16286'; myColorD      = '#d3869b'; # magenta
myColor6      = '#689d6a'; myColorE      = '#83c07c'; # cyan
myColor7      = '#ffffff'; myColorF      = '#ffffff'; # white

def myTransparent(color, alpha):
    color = color.lstrip('#')
    r = int(color[0:2], 16)
    g = int(color[2:4], 16)
    b = int(color[4:6], 16)
    return 'rgba({r}, {g}, {b}, {alpha})'.format(r=r, g=g, b=b, alpha=alpha)

c.colors.hints.bg = myTransparent(myColorB, 0.8)
c.colors.hints.fg = myColor0
c.colors.hints.match.fg = myColor9
c.colors.keyhint.bg = myTransparent(myColorC, 0.9)
c.colors.keyhint.fg = myColor0
c.colors.keyhint.suffix.fg = myColor1

c.colors.messages.error.bg = myTransparent(myColor9, 0.8)
c.colors.messages.error.border = myTransparent(myColor1, 0.9)
c.colors.messages.error.fg = myColor0
c.colors.messages.info.bg = myTransparent(myColorC, 0.8)
c.colors.messages.info.border = myTransparent(myColor4, 0.9)
c.colors.messages.info.fg = myColor0
c.colors.messages.warning.bg = myTransparent(myColorB, 0.8)
c.colors.messages.warning.border = myTransparent(myColor3, 0.9)
c.colors.messages.warning.fg = myColor0
