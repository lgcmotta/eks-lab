# EKS Lab - Complete Kubernetes Infrastructure

An AWS EKS cluster deployment using `OpenTofu` and `Terragrunt` with modular architecture
and proper dependency management.

## 🔧 Environment

- [OpenTofu](https://opentofu.org/): `>= 1.10`
- [Terragrunt](https://terragrunt.gruntwork.io/): `>= 0.84`
- [AWS CLI](https://aws.amazon.com/cli/): `>= 2.27`
- [kubectl](https://kubernetes.io/docs/tasks/tools/): `>= 1.32`
- [helm](https://helm.sh/docs/intro/install/): `>= 3.18`

## 🏗️ Architecture

![Architecture](./docs/architecture.svg)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terragrunt plan`
5. Submit a pull request

## 📚 Additional Resources

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
