# Tmux Session Manager

Starts or attach to a TMUX session, the sessions' configuration are read from
`$HOME/.config/tmux-session.yml`

## Install

```
➜  git clone https://github.com/diacus/tmux-session.git
➜  cd tmux-session
tmux-session ➜  make install
```

## Configuration

```yaml
home: /home/user/Projects ## Contains the root of the sessions
sessions:
  work:                        ## The session name is free
    windows:                   ## List of session windows
      - name: EDITOR
        rc:                    ## Define a list of commands to run
          - vim
      - name: REPL
        rc:                    ## Each window has its own rc list
          - cd src/project
          - python -i prelude.py
      - name: SHELL
        rc:                    ## It is possible to invoke scripts
          - source ~/projects/setup-session.sh
          - nvm use --lts

  hacking:                     ## Add as many sessions as you want
      - name: EDITOR
        rc:
          - vim project/main.hs
```
  
## Usage
```
➜  ts work-1234
```

The command above will create a new `work` session with the ID `1234` with the
configuration specified at `$HOME/.config/tmux-session.yml`

