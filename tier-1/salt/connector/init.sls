connector-dir:
  file.directory:
    - name: /srv/app
    - user: ubuntu

connector-data-dir:
  file.directory:
    - name: /var/lib/connector
    - user: ubuntu

connector-clone:
  git.latest:
    - name: https://github.com/interledgerjs/ilp-connector.git
    - user: ubuntu
    - target: /srv/app
    - rev: master
    - require:
      - pkg: build-essential
      - pkg: nodejs
      - pkg: git

connector-install:
  cmd.run:
    - name: npm install --json
    - runas: ubuntu
    - cwd: /srv/app
  # npm.bootstrap:
  #   - name: /srv/app

connector-install-plugins:
  cmd.run:
    - name: npm install ilp-plugin-xrp-paychan ilp-plugin-mini-accounts ilp-store-simpledb
    - runas: ubuntu
    - cwd: /srv/app

connector-launch-script:
  file.managed:
    - name: /srv/app/launch.config.js
    - user: ubuntu
    - source:
      - salt://connector/files/launch.config.js

connector-start:
  cmd.run:
    - name: pm2 start launch.config.js
    - runas: ubuntu
    - cwd: /srv/app
