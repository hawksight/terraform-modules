terramate {
  config {
    experiments = [
      "scripts",  # Enable Terramate Scripts
      "outputs-sharing"  # Enable sharing outputs between stacks
    ]
    # Using this locally only
    disable_safeguards = ["git-untracked", "git-uncommitted"]
  }
}

script "upgrade" {
  description = "Upgrade tofu dependencies"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "plan"
    description = "Upgrade tofu dependencies"
    commands = [
      [let.provisioner, "init", "-upgrade"]
    ]
  }
}

script "plan" {
  description = "Run a Tofu plan"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "plan"
    description = "Initialize, validate and plan Tofu stacks"
    commands = [
      [let.provisioner, "init"],
      [let.provisioner, "validate"],
      [let.provisioner, "plan", "-out=out.tfplan", "-refresh=true"]
    ]
  }
}

script "apply" {
  description = "Run a Tofu apply"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "apply"
    description = "Apply Tofu plan"
    commands = [
      [let.provisioner, "apply", "out.tfplan", ]
    ]
  }
}

script "outputs" {
  description = "Get Tofu outputs"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "outputs"
    description = "Get Tofu outputs"
    commands = [
      [let.provisioner, "output"]
    ]
  }
}

script "versions" {
  description = "Get Tofu versions"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "versions"
    description = "Get Tofu versions"
    commands = [
      [let.provisioner, "version"]
    ]
  }
}

script "nuke" {
  description = "Nuke Tofu resources"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "nuke"
    description = "Nuke Tofu resources"
    commands = [
      [let.provisioner, "destroy", "-auto-approve"]
    ]
  }
}
