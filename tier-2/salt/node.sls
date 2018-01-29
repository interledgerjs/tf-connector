nodejs:
  pkgrepo.managed:
    - humanname: Node.js
    - name: deb https://deb.nodesource.com/node_8.x xenial main
    - dist: xenial
    - file: /etc/apt/sources.list.d/nodesource.list
    - require_in:
      - pkg: nodejs
    - gpgcheck: 1
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
  pkg.installed: []
