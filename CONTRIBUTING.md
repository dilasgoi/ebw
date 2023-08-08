# Contributing to EasyBuild Command-Line Wrapper

## Getting Started

First, you will need to fork the repository to your GitHub account. Click the "Fork" button at the top right corner of the repository page. Once forked, you can clone the project using the following command:

```bash
git clone https://github.com/your_username/ebw
```

Replace `your_username` with your GitHub username.

## Adding the Original Repository as a Remote

You should add the original repository as a remote to keep your fork synchronized with the latest changes:

```bash
git remote add upstream https://github.com/dilasgoi/ebw
```

## Creating a Feature Branch

When contributing, create a new branch for your feature to keep your changes separated from the main code base. You can create and switch to a new branch using the following command:

```bash
git checkout -b <branch_name>
```

Replace `<branch_name>` with a descriptive name for your feature branch.

## Making Your Changes

Once you're on your feature branch, you can start making your changes.

Stage and commit your changes using the following commands:

```bash
git add .
git commit -m "<commit_message>"
```

Replace `<commit_message>` with a short, descriptive message of what the commit includes.

## Synchronizing Your Fork

Before creating a pull request, it's a good idea to sync your fork with the original repository:

```bash
git checkout main
git pull upstream main
git push origin main
```

## Creating a Pull Request

After pushing your changes to your fork, you can create a pull request to the main repository. Go to your fork on GitHub, click the "New pull request" button, and follow the instructions to create the pull request.

## Thank you for contributing!

Please make sure to write clear commit messages and comment on your code as necessary. If there are any questions or issues, don't hesitate to reach out or open an issue on GitHub.

