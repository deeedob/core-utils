# ---------------------------------------------------------------------------
# Shell options — all setopt calls centralized here.
# ---------------------------------------------------------------------------

# Directory navigation
setopt AUTO_CD              # 'dirname' → cd dirname
setopt AUTO_PUSHD           # cd pushes to dir stack
setopt PUSHD_IGNORE_DUPS    # no duplicate dirs in stack
setopt PUSHD_SILENT         # suppress pushd output

# Globbing
setopt EXTENDED_GLOB        # #, ~, ^ in patterns
setopt GLOB_DOTS            # leading dot not special in glob
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt NUMERIC_GLOB_SORT    # sort filenames numerically when applicable

# History
setopt EXTENDED_HISTORY     # save timestamp + duration
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS     # don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries
setopt HIST_FIND_NO_DUPS    # no dups in history search
setopt HIST_IGNORE_SPACE    # commands starting with space not saved
setopt HIST_REDUCE_BLANKS   # trim extra blanks from history
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY        # share history across sessions (atuin handles this too)
setopt INC_APPEND_HISTORY   # write to history immediately

# Completion
setopt ALWAYS_TO_END        # move cursor to end after completion
setopt COMPLETE_IN_WORD     # complete within word
setopt NO_LIST_BEEP

setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell
setopt NO_BEEP
setopt LONG_LIST_JOBS       # show PID in job notifications
setopt NOTIFY               # report job status immediately
setopt COMBINING_CHARS      # display combining characters correctly
