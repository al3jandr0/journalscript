Source config.tape
# sets journalscript demo configuration

# run journalscript command
Type "journal"
Enter
Sleep 2s

# Answer new journal dialog
Type y
Enter

# User interaction
Sleep 0.25
Type G
Type o
Enter
Type "Helo. I'm journaling"

# show user input
Sleep 2s

# exit
Escape
Type ":wq"
Enter

# Freeze last frame
Sleep 4s

