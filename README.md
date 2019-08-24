# Inlets on AWS

This repository is a demonstration of using Terraform to create an
[Inlets](https://github.com/alexellis/inlets) exit node on an AWS.

Here we have two methods to setup an Inlets exit node on AWS, one using [AWS
Lightsail](https://aws.amazon.com/lightsail/) (a lower price VPS that competes
with DigitalOcean) and one using [AWS EC2](https://aws.amazon.com/ec2/) which is
more configurable but also more expensive.

We use Terraform to build this infrastructure, then run Inlets on the instance
acting as an exit node for your local application.

## What is Inlets?

Inlets is a fairly new project that allows you to setup reverse proxy, websocket
tunnels, or other endpoints to the public internet, it is similar to
[ngrok](https://ngrok.com/). The [video overview from Alex
Ellis](https://youtu.be/jrAqqe8N3q4) shows how simple it makes setting up the
environment.

In the [Inlets repository](https://github.com/alexellis/inlets/tree/master/hack)
there are 'hacks' to setup Inlets nodes using DigitalOcean and other cloud
platforms. This is intended to provision an Inlets node on AWS EC2 for you
quickly. I suppose this can also be called a hack.

## Inlets on AWS Lightsail

This is the most simplistic and inexpensive method to setup an Inlets exit node.
It requires a keypair which you will create in advance using our instructions.

To create this environment with Terraform, cd into the
[terraform/lightsail](terraform/lightsail) directory and follow the
[README](terraform/lightsail/README.md).

**Note**: Lightsail doesn't let us use unique high ports apparently, or at least
I can't figure out how to add an AWS security group as of now, so we'll use port
80 here, rather than the standard 8090 that Inlets uses. The only drawback of
this is if you intend to also run a webserver on your Lightsail instance, in
which case both Inlets and your webserver would be attempting to use port 80,
and the one that started up last would probably fail.

## Inlets on AWS EC2

This demo uses AWS EC2 which is more configurable but more expensive than AWS
Lightsail. In order to avoid any security concerns we expect that you use a
keypair previously generated or uploaded to your AWS account.

To create this environment with Terraform, cd into the
[terraform/ec2](terraform/ec2) directory and follow the instructions in the
[README](terraform/ec2/README.md).
