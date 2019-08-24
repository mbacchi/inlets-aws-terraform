# Inlets on AWS Lightsail

Lightsail is the more simplistic method to setup an Inlets exit node. It
requires a keypair which you can create in advance.

**Note**: Lightsail doesn't let us use unique high ports apparently, or at least
I can't figure out how to add an AWS security group as of now, so we'll use port
80 here, rather than the standard 8090 that Inlets uses. The only drawback of
this is if you intend to also run a webserver on your Lightsail instance, in
which case both Inlets and your webserver would be attempting to use port 80,
and the one that started up last would probably fail.

### Prerequisites

* Terraform
* An AWS account
* An AWS Keypair

To create your own AWS keypair, execute the command:

```
ssh-keygen -t rsa -b 4096 -N '' -f lightsail_keypair
```

You will then import the keypair wit Terraform.

### Prepare to run terraform

These steps include:

* Install terraform
* Clone this repository
* Run `terraform init` in the cloned directory
* Exporting environment variable for your AWS_PROFILE and AWS_REGION. This looks
  something like:

    `export AWS_PROFILE=blah && export AWS_REGION=us-east-2`

**Note**: You will need to change the `key_pair_name` in `main.tf` to the name
of your own keypair.

### Create the terraform plan

Run the command:

```
token=$(head -c 16 /dev/urandom | sha256sum | cut -d" " -f1); terraform plan -out=terraform_plan.$(date +%F.%H.%M.%S).out  -var "token=$token"
```

This will output a file with a name such as: `terraform_plan.2019-08-24.12.33.12.out`

**Note**: You might not have `sha256sum` on your system, it can be replaced
with `shasum`.

### Apply the terraform plan

Apply the plan that you created in the previous step after reviewing the plan output.

```
terraform apply terraform_plan.2019-08-24.12.33.12.out

aws_lightsail_key_pair.lightsail_keypair: Creating...
aws_lightsail_instance.inlets: Creating...
aws_lightsail_key_pair.lightsail_keypair: Creation complete after 6s [id=lightsail_keypair]
aws_lightsail_instance.inlets: Still creating... [10s elapsed]
aws_lightsail_instance.inlets: Still creating... [20s elapsed]
aws_lightsail_instance.inlets: Creation complete after 28s [id=inlets]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

inlets_token = 377e8e489e9ef023459e37e88bc4163ffe9fc241d4d9dee7b812287d46990f6z
public_ip_address = 13.58.186.168
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
export TOKEN="377e8e489e9ef023459e37e88bc4163ffe9fc241d4d9dee7b812287d46990f6z"

export REMOTE="13.58.186.168:80"

inlets client  --remote=$REMOTE --upstream=http://127.0.0.1:4000 --token $TOKEN
```

In a web browser, now you can open the url `13.58.186.168:80` and see your
application that was just now only running locally.

Hope you enjoy!
