# terramate test

An example terramate implementation.

## bucket state

```sh
export UNIQUE_NAME="super-awesomely-long-example-bucket-name-for-storing-terraform-state"
gcloud storage buckets create gs://$UNIQUE_NAME --default-storage-class=STANDARD --location=EUROPE-WEST2 --uniform-bucket-level-access --public-access-prevention
```

## stacks

### EU

Focusing on the EU region configuration. 
Stacks broken down similarly to [this example](../examples/gke-tlspc-provider/).

### AU

## TLSPC

### Regions Tested

Note to myself on the regions / tenants I've fully tested:

- demons-eu
- demons-au
- demons-uk
- jetstack-us
- demons-ca
- demons-sg

Problems found with:

- demons-sg
- demons-uk

Currently investigating why application cannot be delted due to deleye svc account.
