Source config.tape

# sets journalscript demo configuration

# run journalscript command
Type "journal write my-other-journal"
Sleep 2s
Enter

# User interaction
Sleep 0.25
Type G
Type o
Enter
Type "This is another journal."

# show user input
Sleep 2s

# exit
Escape
Type ":wq"
Enter

# Freeze last frame
Sleep 4s

