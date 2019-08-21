# Create an Inlets Exit Node on AWS with Terraform

This is a demonstration using Terraform to create an
[Inlets](https://github.com/alexellis/inlets) exit node on an AWS EC2 instance.

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

## How?

**Note**: We don't create an AWS keypair in Terraform, I consider that bad form.
In order to avoid any security concerns we expect that you use a keypair
previously generated or uploaded to your AWS account.

### Prerequisites

* Terraform
* An AWS account
* An AWS Keypair
* That's about it...

### Prepare to run terraform

These steps include:

* Installing terraform
* Cloning this repository
* Running `terraform init` in the cloned directory
* Exporting environment variable for your AWS_PROFILE and AWS_REGION. This looks
  something like:

    `export AWS_PROFILE=blah && export AWS_REGION=us-east-2`

**Note**: You will need to change the `key_name` on line 64 of `main.tf` to the
name of your own keypair.

### Create the terraform plan

Run the command:

```
token=$(head -c 16 /dev/urandom | sha256sum | cut -d" " -f1); terraform plan -out=terraform_plan.$(date +%F.%H.%M.%S).out  -var "token=$token"
```

This will output a file with a name such as: `terraform_plan.2019-08-20.23.04.54.out`

**Note**: You might not have `sha256sum` on your system, it can be replaced
with `shasum`.

### Apply the terraform plan

Apply the plan that you created in the previous step after reviewing the plan output.

```
terraform apply terraform_plan.2019-08-20.23.04.54.out
...
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

inlets_token = 2395590c8b333cb2cb9f54ac152aac03e0365c1c69ce20348a3124b84c98ec62
public_ip_address = 3.19.218.92
```

The terraform output provides the Inlets token required by the client to
authenticate with the server, and the public IP address of the EC2 instance. Use
this info in the below steps.

### Remove your Inlets node

When you want to remove this infrastructure, run `terraform destroy`.

## Connecting to Inlets

This is documented in the [Inlets
README](https://github.com/alexellis/inlets#install-the-cli), but basically on
your client (laptop?) you need an application such as a webserver running:

```
cd blog
make serve 
JEKYLL_ENV=development jekyll serve
Configuration file: _config.yml
            Source: .
       Destination: _site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 1.149 seconds.
 Auto-regeneration: enabled for 'myblog'
    Server address: http://127.0.0.1:4000
  Server running... press ctrl-c to stop.
```

Then in another terminal session start the client:

```
export TOKEN="2395590c8b333cb2cb9f54ac152aac03e0365c1c69ce20348a3124b84c98ec62"

export REMOTE="3.19.218.92:8090"

inlets client  --remote=$REMOTE --upstream=http://127.0.0.1:4000 --token $TOKEN
```

In a web browser, now you can open the url `3.19.218.92:8090` and see your
application that was just now only running locally.

Hope you enjoy!