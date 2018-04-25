# Terraform Connector
> Terraform files for the ILP connector

- [Overview](#overview)
  - [Selecting your setup](#selecting-your-setup)
- [Tier 1 with XRP and AWS](#tier-1-with-xrp-and-aws)
  - [Set up your domain](#set-up-your-domain)
  - [Acting as a server](#acting-as-a-server)
  - [Adding another peer](#adding-another-peer)
  - [Upgrading to SSL](#upgrading-to-ssl)
- [Tier 2 with XRP and AWS](#tier-2-with-xrp-and-aws)
- [Access your Connector](#access-your-connector)
  - [Use as Moneyd](#use-as-moneyd)
  - [Monitor with Moneyd-GUI](#monitor-with-moneyd-gui)
    - [Run Both](#run-both)

## Overview

This repo contains instructions for how to run an Interledger connector. As the
community creates more ways to deploy the connector, they'll be added to this
repository.

These instructions are intended for people who want to take part in the early
Interledger network as connectors. You'll have to find other members of the
community to peer with, and will have to maintain your connector in order to
stay on the network.

These instructions will not be perfect, so don't hesitate to ask for help in
our [Gitter](https://gitter.im/interledger/Lobby). If you find any mistakes,
please submit a PR to this repo to help future readers.

**If you want to try Interledger out as a regular user, look at
[moneyd](https://github.com/sharafian/moneyd)**. Moneyd is a piece of software
that runs a "home router" for the interledger. It exposes Interledger access to
applications on your machine, and will forward packets to an upstream provider.

### Selecting your setup

The instructions you'll want to follow depend on:

1. The ledger(s) you'll be peering over
2. Whether you'll have a parent connector
3. What hosting provider you want to use

**1**: Interledger currently has functioning integrations for both XRP and Ethereum.
Connectors on the live network are currently using XRP, but the first
connectors peering over Ethereum will be deployed soon. Instructions for a
connector over Ethereum will be added to this repository once this happens.

**2**: The only difference between "Tier 1" and "Tier 2" connectors is in the
routing topology. A Tier 1 connector acts like a Tier 1 ISP. It is a backbone
node in the network and requires more upkeep. You must also find other
connectors on the network willing to manually peer with you. If you're
interested in running a Tier 1 connector, you can find a peer on the
Interledger Gitter or mailing list, both accessible from
[interledger.org](https://interledger.org).

**3**: The terraform files currently in this repo are specific to Amazon AWS.
The salt files used to provision an already running instance are portable
across any hosting provider. If any community members want to add terraform
files and instructions for their hosting provider of choice, they can submit a
PR to this repo.

## Tier 1 with XRP and AWS

- Start out by cloning this repo. Then `cd` into the `tier-1` directory.

- Open `./terraform/terraform.tfvars` in your editor of choice. This contains
  some details that Terraform uses to create your server.

- Replace `~/.ssh/id_rsa.pub` (line 2) with the path of your public key. This should be
  whatever key you ordinarily use for SSH. When you deploy, terraform will
  upload it to your server so that you can SSH in.

- Replace `us-east-1` (line 3) with the AWS region you want to run your connector in.
  You can find the different options in `./terraform/variables.tf`.

- Replace `example.com` (line 4) with a domain that you own. Once you've
  deployed, follow the [set up your domain](#set-up-your-domain) instructions
  to point it at your connector.

- Open `./salt/connector/files/launch.config.js` in your editor of choice. This
  file contains the configuration for your connector. If you want to do any
  advanced configuration of this file, look at the [ILP connector
  README](https://github.com/interledgerjs/ilp-connector).

- Replace `YOUR_HOT_WALLET_RIPPLE_ADDRESS` (line 4) with your hot wallet ripple
  address. This should be an address with at least 35 XRP. Do not keep too much
  money on this address, in case your server is ever compromised.

- Replace `YOUR_HOT_WALLET_RIPPLE_SECRET` (line 5) with your hot wallet ripple secret.

- Ask your peer to add a peer plugin for your connector. They'll have to follow
  the [Adding another peer](#adding-another-peer) instructions, and then will
  be able to give you a URI to connect to their server. Replace
  `SERVER_URI_GIVEN_TO_YOU_BY_YOUR_PEER` (line 19) with this URI.

  - (If you want to run a websocket server for this peering relationship instead
    of using your peer's server, follow the [Acting as a
    server](#acting-as-a-server) instructions).

- Ask your peer for their ripple hot wallet address. Replace
  `RIPPLE_ADDRESS_OF_PEER` (line 23) with their ripple hot wallet address.

- Choose a unique global prefix for your connector, and put it in place of `MY
  ILP ADDRESS` (line 41). Some examples of prefixes that have already been used
  are `g.zero`, `g.africa`, and `g.pando`.

- Replace the "`us-east-1`" in `sdb.us-east-1.amazonaws.com` with your AWS region
  (the one you entered into `./terraform/variables.tf`).

- Go to your AWS management dashboard and open the IAM service. If you do not have
  an AWS account, create one and add your billing details.

- In IAM, go to "Manage Users" and add a new user. Use an existing policy, and select
  "AdministratorAccess". Set the user's name to "connector".

- Once the user is created, save the Access Key and Secret Key. Create a file called
  `~/terraform.sh` and copy in the following:

```
#!/bin/bash

AWS_ACCESS_KEY=XXXXXXX AWS_SECRET_KEY=XXXXXXXX terraform $*
```

- Replace the values in `~/terraform.sh` with the values you copied from IAM.

- Install [Terraform](https://www.terraform.io/) on your machine.

- Now it's time for you to deploy. Run:

```
cd terraform
bash ~/terraform.sh init
bash ~/terraform.sh apply
```

- Enter 'yes' when Terraform asks you to confirm. Wait for the deploy to
  finish.  It should end by printing your server's IP address. If there was an
  error, 

- If you did not encounter any errors, then your connector is running! Follow
  [Access your Connector](#access-your-connector) to start using it.

- If you encounter any issues, you can use the IP address that Terraform
  returned to SSH into the machine.  Once you're inside the machine, you can
  use `sudo pm2 logs` to see the connector's logs. You can fix the issue in the
  configuration files on your local machine, then [redeploy](#redeploy).

### Set up your domain

- Your connector must be deployed already. Complete the deploy instructions,
  then continue here.

- Go to your AWS management console and open the "Route 53" service.

- Under "Hosted Zones," you should see an entry for the domain that you
  configured on your connector. Click that entry.

- Select the nameservers on the hosted zone, and configure your domain to point
  at them. Give the change a little while to propagate.

- You're done! Your domain now can be used for your peering relationships.

### Acting as a server

- Open your `./salt/connector/files/launch.config.js`.

- On the peer that you want to be a server for, replace:

```
  server: ".....",
```

With

```
  listener: {
    port: 8080,
    secret: "GENERATE_A_SECURE_RANDOM_SECRET"
  },
```

- If you already have a `listener` with port 8080, you'll have to use a different port.
  If you're using port 8080, skip the following indented steps.

  - If you're using a port other than 8080, open `./terraform/main.tf`. For
    example, let's say you're using port 1080.

  - In `resource "aws_security_group" "elb"`, add the following block:

```
  ingress {
    from_port   = 1080
    to_port     = 1080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

  - In `resource "aws_security_group" "default"`, add the following block:

```
  ingress {
    from_port   = 1080
    to_port     = 1080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
```

  - In `resource "aws_elb" "web"`, add the following block:

```
  listener {
    instance_port     = 1080
    instance_protocol = "tcp"
    lb_port           = 1080
    lb_protocol       = "tcp"
  }
```

- Now the `server` you can give your peer is
  `btp+ws://:GENERATE_A_SECURE_RANDOM_SECRET@btp.example.com` (With `example.com`
  as your domain, `GENERATE_A_SECURE_RANDOM_SECRET` as your generated secret, and
  `8080` as your instance port (the load balancer will expose 80)). (Change to
  `wss` if you already completed [Upgrading to SSL](#upgrading-to-ssl))

- Make sure you [Set up your domain](#set-up-your-domain) once your connector
  is deployed, if it is not deployed already.

- [Redeploy](#redeploy) your connector if it is already deployed.

### Adding another peer

- Open `./salt/connector/files/launch.config.js` in your editor of choice.

- Add the following block, after the constants declared at the top of the file:

```
const secondPeerPlugin = {
  relation: 'peer',
  plugin: 'ilp-plugin-xrp-paychan',
  assetCode: 'XRP',
  assetScale: 9,
  balance: {
    maximum: '10000000',
    settleThreshold: '-5000000',
    settleTo: '0'
  },
  options: {
    assetScale: 9,
    server: 'SERVER_URI_GIVEN_TO_YOU_BY_YOUR_PEER',
    rippledServer: 'wss://s1.ripple.com',
    secret,
    address,
    peerAddress: 'RIPPLE_ADDRESS_OF_PEER'
  }
}
```

- Follow the instructions in [Tier 1 with XRP and
  AWS](#tier-1-with-xrp-and-aws) to fill in the placeholder fields.  If you are
  the websocket server in this relationship, you'll also have to follow [Acting
  as a Server](#acting-as-a-server).

- In the `CONNECTOR_ACCOUNTS` object, add another entry that says:

```
  secondPeer: secondPeerPlugin
```

- [Redeploy](#redeploy) your connector.

### Upgrading to SSL

- Go to your AWS management console. Select the "Certificate Manager" service.

- Select "Request a Certificate," and request `*.example.com`, where `example.com`
  is the domain you put in your `./terraform/terraform.tfvars`.

- Follow the instructions that AWS provides. If you've configured your domain
  via Route 53 (which Terraform should have done automatically), AWS will go
  through the process automatically.

- Open `./terraform/main.tf` in your editor of choice.

- Add the following block at the top of the file (replacing `example.com` with
  your domain):

```
data "aws_acm_certificate" "web-cert" {
  domain   = "*.example.com"
  statuses = ["ISSUED"]
}
```

- In the `resource "aws_security_group" "elb"` block, add the following block:

```
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

- In the `resource "aws_elb" "web"` block, change `lb_port` to `443` wherever
  it previously said `80`, in any `listener` block. Change `lb_protocol` to
  `ssl` on all `listener` blocks. In every `listener` block, add the following
  line at the end:

```
    ssl_certificate_id = "${data.aws_acm_certificate.web-cert.arn}"
```

- If you've already deployed, change directories into `./terraform` and run
  `bash ~/terraform.sh apply` to apply these changes. You don't need to taint
  anything; Terraform is smart enough to notice which blocks you've edited.

### Redeploy

In order to redeploy, you must be in your terraform directory. This will fail
if you aren't on the same machine that you initially deployed from.

```
bash ~/terraform.sh taint aws_instance.web
bash ~/terraform.sh apply
```

## Tier 2 with XRP and AWS

- Start out by cloning this repo. Then `cd` into the `tier-2` directory.

- Open `./terraform/terraform.tfvars` in your editor of choice. This contains
  some details that Terraform uses to create your server.

- Replace `~/.ssh/id_rsa.pub` (line 2) with the path of your public key. This should be
  whatever key you ordinarily use for SSH. When you deploy, terraform will
  upload it to your server so that you can SSH in.

- Replace `us-east-1` (line 3) with the AWS region you want to run your connector in.
  You can find the different options in `./terraform/variables.tf`.

- Replace `example.com` (line 4) with a domain that you own. Once you've
  deployed, follow the [set up your domain](#set-up-your-domain) instructions
  to point it at your connector.

- Open `./salt/connector/files/launch.config.js` in your editor of choice. This
  file contains the configuration for your connector. If you want to do any
  advanced configuration of this file, look at the [ILP connector
  README](https://github.com/interledgerjs/ilp-connector).

- Replace `YOUR_HOT_WALLET_RIPPLE_ADDRESS` (line 4) with your hot wallet ripple
  address. This should be an address with at least 35 XRP. Do not keep too much
  money on this address, in case your server is ever compromised.

- Replace `YOUR_HOT_WALLET_RIPPLE_SECRET` (line 5) with your hot wallet ripple secret.

- Find a parent BTP host on the current [Connector
  List](https://github.com/sharafian/moneyd#connector-list). You can also ask
  for a suitable parent on the [Gitter](https://gitter.im/interledger/Lobby).
  Replace `YOUR_PARENT_HOST` (line 13) with this host.

- Replace the "`us-east-1`" in `sdb.us-east-1.amazonaws.com` with your AWS region
  (the one you entered into `./terraform/variables.tf`).

- Go to your AWS management dashboard and open the IAM service. If you do not have
  an AWS account, create one and add your billing details.

- In IAM, go to "Manage Users" and add a new user. Use an existing policy, and select
  "AdministratorAccess". Set the user's name to "connector".

- Once the user is created, save the Access Key and Secret Key. Create a file called
  `~/terraform.sh`, and copy in the following:

```
#!/bin/bash

AWS_ACCESS_KEY=XXXXXXX AWS_SECRET_KEY=XXXXXXXX terraform $*
```

- Replace the values in `~/terraform.sh` with the values you copied from IAM.

- Install [Terraform](https://www.terraform.io/) on your machine.

- Now it's time for you to deploy. Run:

```
cd terraform
bash ~/terraform.sh init
bash ~/terraform.sh apply
```

- Enter 'yes' when Terraform asks you to confirm. Wait for the deploy to
  finish.  It should end by printing your server's IP address. If there was an
  error, 

- If you did not encounter any errors, then your connector is running! Follow
  [Access your Connector](#access-your-connector) to start using it.

- If you encounter any issues, you can use the IP address that Terraform
  returned to SSH into the machine.  Once you're inside the machine, you can
  use `sudo pm2 logs` to see the connector's logs. You can fix the issue in the
  configuration files on your local machine, then [redeploy](#redeploy).

## Access your Connector

### Use as your Moneyd

You can access your deployed connector by tunnelling its
`ilp-plugin-mini-accounts` instance to your local machine. Then any application
can access it via port 7768, just as though you were running moneyd.

You should have an IP address for your connector, once it's deployed.
To get access to your funds locally, just run the following command:

```
ssh -N -L 7768:localhost:7768 ubuntu@YOUR_IP_ADDRESS
```

Replace `YOUR_IP_ADDRESS` with your IP address. This command should produce no
output; just keep the command running to keep the port-forward running.

To test your ILP connection, try these [examples from moneyd's
README.](https://github.com/sharafian/moneyd#sending-payments)

### Monitor with Moneyd-GUI

The connector you deployed comes with a GUI to view routes, ping destinations,
and send test payments. This GUI runs as a webserver.

To access it, forward the GUI's port to your local machine. 

```
ssh -N -L 7770:localhost:7770 ubuntu@YOUR_IP_ADDRESS
```

You should have an IP address for your connector, once it's deployed. Replace
`YOUR_IP_ADDRESS` with this IP address. This command should produce no output;
just keep the command running to keep the port-forward running.

Open `http://localhsost:7770` to see your connector's control panel.

#### Run Both

If you want to forward both Moneyd and Moneyd GUI, the port-forward commands
can be combined

```
ssh -N -L 7770:localhost:7770 -L 7768:localhost:7768 ubuntu@YOUR_IP_ADDRESS
```
