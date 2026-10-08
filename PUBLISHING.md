# Publishing Guide for Terraform Registry

This guide explains how to publish this module on the Terraform Registry.

## Prerequisites

1. A GitHub account
2. A public GitHub repository
3. An account on the Terraform Registry (https://registry.terraform.io)

## Publishing Steps

### 1. Create the GitHub Repository

The repository **MUST** follow the naming convention:
```
terraform-<PROVIDER>-<NAME>
```

For this module, the name should be:
```
terraform-clevercloud-github-runner
```

### 2. Repository Structure

Your repository must contain:
- ✅ `main.tf` - Main resources
- ✅ `variables.tf` - Input variables
- ✅ `outputs.tf` - Module outputs
- ✅ `versions.tf` - Version constraints
- ✅ `README.md` - Documentation
- ✅ `LICENSE` - Module license
- ✅ `examples/` - Usage examples

### 3. Add a Repository Description

On GitHub, add a short description to the repository (used as the short description in the registry):
```
Terraform module to run self-hosted GitHub Actions runners on CleverCloud
```

### 4. Create a Version Tag

The registry requires at least one semantic version tag:

```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Initial commit
git commit -m "Initial module release"

# Create main branch
git branch -M main

# Add remote
git remote add origin git@github.com:CleverCloud/terraform-clevercloud-github-runner.git

# Push to GitHub
git push -u origin main

# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

### 5. Publish on the Terraform Registry

1. Go to https://registry.terraform.io
2. Sign in with your GitHub account
3. Click "Publish" → "Module"
4. Select your `terraform-clevercloud-github-runner` repository
5. Click "Publish Module"

The registry will:
- Verify the module structure
- Automatically generate documentation from the README
- Analyze variables and outputs
- Publish the module

### 6. Publishing New Versions

To publish a new version:

```bash
# Make your changes
git add .
git commit -m "Description of changes"
git push

# Create a new tag (increment version according to semantic versioning)
git tag v1.1.0
git push origin v1.1.0
```

The registry will automatically detect the new tag and publish the new version.

## Semantic Versioning

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** (1.0.0 → 2.0.0): Incompatible changes (breaking changes)
- **MINOR** (1.0.0 → 1.1.0): New compatible features
- **PATCH** (1.0.0 → 1.0.1): Bug fixes

## Module Usage

Once published, users can use the module like this:

```hcl
module "github_runner" {
  source  = "CleverCloud/github-runner/clevercloud"
  version = "1.0.0"

  github_url   = "https://github.com/my-org/my-repo"
  github_token = var.github_token
}
```

## Pre-Publication Checklist

- [ ] Repository name follows the format `terraform-clevercloud-github-runner`
- [ ] Repository is public
- [ ] Description is added to the GitHub repository
- [ ] All required files are present
- [ ] README is complete and well formatted
- [ ] Examples are functional
- [ ] At least one version tag exists (v1.0.0)
- [ ] LICENSE file is present

## Resources

- [Official Terraform Registry Documentation](https://developer.hashicorp.com/terraform/registry/modules/publish)
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [Semantic Versioning](https://semver.org/)
