gui-dir:
  file.directory:
    - name: /srv/gui
    - user: ubuntu

gui-clone:
  git.latest:
    - name: https://github.com/sharafian/moneyd-gui.git
    - target: /srv/gui
    - rev: master
    - user: ubuntu
    - require:
      - pkg: build-essential
      - pkg: nodejs
      - pkg: git

gui-install:
  cmd.run:
    - name: npm install --unsafe-perm --json --production
    - runas: ubuntu
    - cwd: /srv/gui

gui-start:
  cmd.run:
    - name: pm2 start index.js
    - runas: ubuntu
    - cwd: /srv/gui
