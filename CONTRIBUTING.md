# Contributing to EasyBuild Command-Line Wrapper

Here's a guide on how you can contribute to the project.

## Getting Started

First, ensure that you have the latest version of the project. You can clone the project using the following command:

```bash
git clone <repository_url>
```

You should replace `<repository_url>` with the URL of the project's repository.

## Creating a Feature Branch

When contributing, you should create a new branch for your feature. This helps to keep your changes separated from the main code base and allows you to work without affecting the main code. You can create and switch to a new branch using the following command:

```bash
git checkout -b <branch_name>
```

Replace `<branch_name>` with a descriptive name for your feature branch.

## Making Your Changes

Once you are on your feature branch, you can start making your changes. Remember to commit your changes frequently. This helps to keep track of your changes and makes it easier to identify any issues that might occur.

You can stage and commit your changes using the following commands:

```bash
git add .
git commit -m "<commit_message>"
```

Replace `<commit_message>` with a short, descriptive message of what the commit includes.

## Merging Your Changes

Once you're satisfied with your changes, you can merge them into the main branch. Since all the contributors have admin permissions on the project, you can merge your feature branch directly into the main branch. Before you do that, it's a good practice to switch back to the main branch and pull the latest changes. This helps to reduce any merge conflicts.

Switch to the main branch and pull the latest changes with these commands:

```bash
git checkout main
git pull
```

Now, you can merge your feature branch into the main branch:

```bash
git merge <branch_name>
```

Replace `<branch_name>` with the name of your feature branch.

## Pushing Your Changes

After merging your changes, you can push them to the remote repository using the following command:

```bash
git push
```
