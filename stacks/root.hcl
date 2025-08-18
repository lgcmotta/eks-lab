remote_state {
  backend = "s3"
  config = {
    bucket       = "motta-iac"
    key          = "iac/dev/eks-lab/${path_relative_to_include()}/tofu.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
