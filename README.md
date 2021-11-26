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
Describe your session settings in a YAML document and save it to
`$HOME/.config/tmux-session.yml`.

```yaml
home: /home/user/Projects ## Contains the root of the sessions
sessions:
  work:                        ## The session name is free
    rc:                        ## Run commands before creating windows
      - test -d src/some-repo || gh clone some-repo src/some-repo
    windows:                   ## List of session windows
      - name: EDITOR
        rc:                    ## Define a list of commands to run
          - vim

      - name: REPL
        layout: even-vertical  ## Select your tmux layout
        rc:
          - cd src
        panes:                 ## Support pane definition
          - rc:                ## Each window has its own rc list
            - source /home/user/Projects/python-project-rc.sh
            - test -d .venv || pipenv install
            - python -i prelude.py
          - spare: true        ## Add panes without rc list

      - name: SHELL
        rc:                    ## It is possible to invoke scripts
          - source /home/user/Projects/node-project-rc.sh
          - nvm use --lts
          - test -d node_modules || yarn install

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
configuration specified at the configuration file.

