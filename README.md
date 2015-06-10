# Theme Juice CLI
[![Gem Version](http://img.shields.io/gem/v/theme-juice.svg?style=flat-square)](https://rubygems.org/gems/theme-juice)
[![Travis](https://img.shields.io/travis/ezekg/theme-juice-cli.svg?style=flat-square)](https://travis-ci.org/ezekg/theme-juice-cli)
[![Code Climate](https://img.shields.io/codeclimate/github/ezekg/theme-juice-cli.svg?style=flat-square)](https://codeclimate.com/github/ezekg/theme-juice-cli)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/ezekg/theme-juice-cli.svg?style=flat-square)](https://codeclimate.com/github/ezekg/theme-juice-cli)
[![GitHub license](https://img.shields.io/github/license/ezekg/theme-juice-cli.svg?style=flat-square)](https://github.com/ezekg/theme-juice-cli/blob/master/LICENSE)

_This project is currently under active development and will not be completely 'stable' per-say until we hit `1.0`. Everything here is subject to change without notice. (We will of course semantically version all of our releases, with the minor version being incremented with new features/breaking changes.) Feel free to contribute to the development with new features, ideas or bug fixes._

[View our contributing guidelines to get started!](#contributing)

## What is it?
**Theme Juice** is a WordPress development command line utility that allows you to scaffold out entire Vagrant development environments in seconds (using an Apache fork of [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV) called [VVV-Apache](https://github.com/ericmann/vvv-apache.git) as the VM). It also helps you manage dependencies and build tools, and can even handle your deployments.

## Requirements
**`tj` requires [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to be able to create virtual machines for local development. Please download and install both of these before getting started.**

I test against the latest versions of Ruby MRI (2.2, 2.1, 2.0). `tj` requires at least MRI 1.9.3. For the full report, check out the [Travis CI build status](https://travis-ci.org/ezekg/theme-juice-cli), where I test against an array of Ruby interpreters.

## Installation
```
gem install theme-juice
```

## Getting Started

#### Create a new project
This will lead you through a series of prompts to set up required project information, such as name, location, theme, database info, etc. Using the specified information, it will run the installation process and set up a local development environment, if it hasn't already been set up. It will sync your local project location with the project
location within the VM, so you can run this from anywhere on your local system.

```
tj create
```

#### Set up an existing project
This sets up an existing local project within the development environment. You will go through a series of prompts to create the necessary files. This command is essentially an alias for `tj create --bare`.

```
tj setup
```

#### Removing a project
This will remove a project from your development environment. This will only remove files that were generated by `tj` i.e. the database setup, DNS setup, and the project's shared directories.

It will not touch your local folders that were synced to the VM.

```
tj delete
```

#### Want More?
Want to check out all of the various flags and features `tj` offers? Just ask `tj` for help, and you'll be greeted with a nice `man` page full of information about how to use just about everything.

```
tj help
```

## FAQ

#### Is Windows supported?
Yes! But, since Windows doesn't support UTF-8 characters inside of the terminal, and is picky about ASCII colors, you'll probably have to run `tj` with a couple flags. What has worked for me on one of my Windows machines is to run all commands through [git-scm](http://git-scm.com/downloads) with the `--boring --no-landrush` flags.

This will disable all unicode characters and colors from being output, and will also disable [Landrush](https://github.com/phinze/landrush), which isn't fully supported on Windows. To set these globally via the `ENV`, set these environment variables or run the following commands in your terminal:

```bash
export TJ_BORING=true
export TJ_NO_LANDRUSH=true
```

In addition to that, `tj` uses the [OS gem](https://github.com/rdp/os) to sniff out your OS and adjusts a few things accordingly to make sure things don't break. _I don't regularly develop on Windows, so if you encounter any bugs, please let me know through a **well-documented** issue and I'll try my best to get it resolved._

#### Can I use the original VVV instead of VVV-Apache?
Definitely. If you want to use `tj` with Nginx and the [original VVV](https://github.com/Varying-Vagrant-Vagrants/VVV), it's as simple as running `tj` with a few flags:

```bash
tj new --vm-box git@github.com:Varying-Vagrant-Vagrants/VVV.git --nginx
```

To use these permanently, set the appropriate `ENV` variables through your `.bashrc` or similar, i.e. `export TJ_VM_BOX=git@github.com:Varying-Vagrant-Vagrants/VVV.git` and `export TJ_NGINX=true`.

_Note: Before running this, you might want to either choose a new `vm-path`, or destroy any existing VMs inside of your `~/vagrant` directory. If `tj` detects a VM already installed, it will skip installing the new box._

#### So, does that mean I can use any Vagrant box?
Yes and no; in order for `tj` to properly create a project, the Vagrant box needs to follow the same directory structure as VVV, and include a `Customfile`. Here is the required structure that `tj` needs in order to be able to create new projects:

```
├── config/
|  |
|  ├── {apache,nginx}-config/
|  |  |
|  |  ├── site-1.conf
|  |  ├── site-2.conf
|  |  ..
|  ..
├── www/
|  |
|  ├── site-1/
|  |  |
|  |  ├── index.php
|  |  ..
|  ├── site-2/
|  |  |
|  |  ├── index.php
|  |  ..
|  ..
├── Customfile
...
```

#### What is a `Customfile`?
[It's a file that contains custom rules to add into the main `Vagrantfile`, without actually having to modify it](https://github.com/Varying-Vagrant-Vagrants/VVV/blob/develop/Vagrantfile#L208-L218). This allows us to easily modify the Vagrant box without causing merge conflicts if you were to update the VM source via `git pull`.

#### What is a `Juicefile`?
A YAML configuration file (`Juicefile`) can be used to store commonly-used build scripts. Each command block sequence can be mapped to an individual project's build tool, allowing a streamlined set of commands to be used across multiple projects that utilize different tools. In the near-future, this will also house your deployment configuration.

Below is the config that comes baked into [our starter theme](https://github.com/ezekg/theme-juice-starter):

```yml
commands:
  install:
    - composer install
    - npm install
    - bower install
    - grunt build
  watch:
    - grunt %args%
  vendor:
    - composer %args%
  wp:
    - wp ssh --host=vagrant %args%
  backup:
    - mkdir -p backup
    - wp ssh --host=vagrant db export backup/$(date +'%Y-%m-%d-%H-%M-%S').sql
  dist:
    - tar -zcvf dist.tar.gz .
```

Each command sequence is run within a single execution, with all `%args%`/`%argN%` being replaced by the passed command. Here's a few example scenarios:
```bash
# Will contain all arguments stitched together by a space
cmd1 %args%
# Will contain each argument mapped to its respective index
cmd2 '%arg1% %arg2% %arg3%'
# Will only map argument 4, while ignoring 1-3
cmd3 "%arg4%"
```

You can specify an unlimited number of commands with an unlimited number of arguments; however, you should be careful with how this is used. Don't go including `sudo rm -rf %arg1%` in a command, while passing `/` as an argument. Keep it simple. These are meant to make your life easier by helping you manage build tools, not to do fancy scripting.

#### Does `tj` handle deployments?
Eventually, yes. It's not currently production-ready, but as soon as it is, we'll have detailed instructions on how to configure and deploy applications using `tj`. Right now, I'm leaning towards integrating an automated Capistrano workflow, but am open to other options. [Have an idea and want to contribute?](#contributing)

#### Can I test a project with my mobile device?
Yes! By default, `tj` sets up all project's to support [xip.io](http://xip.io/). To test a project from another device on the same network, do `<project-name>.<your-hosts-ip-address>.xip.io` e.g. `themejuice.192.168.1.1.xip.io`.

#### Help! It won't let me `git clone` anything!
You most likely don't have [SSH-keys for GitHub set up correctly (if even at all)](https://help.github.com/articles/error-permission-denied-publickey/). Either set that up, or manually run `tj` with the appropriate flags corresponding to the problem-repository, swapping out `git@github.com:` for `https://github.com/`:

```
tj create --theme https://github.com/theme/repository.git --vm-box https://github.com/vm-box/repository.git
```

#### Can I add my starter theme, ________?
Yes! Just update the `THEMES` constant inside [commands/create.rb](https://github.com/ezekg/theme-juice-cli/blob/master/lib/theme-juice/commands/create.rb#L7-L11) and make a pull request. I'll verify that the theme includes a `Juicefile` (not required, but preferred to automate build steps), and that everything looks solid. Until then (or if your theme is private), just run `tj create --theme https://your.repo/link/goes.here` to clone your theme.

## Contributing
1. First, create a _well documented_ [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature/bug fix
1. After getting approval for the new feature, [fork the repository](https://github.com/ezekg/theme-juice-cli/fork)
1. Create a new feature branch (`git checkout -b my-new-feature`)
1. Write tests before pushing your changes, then run Rspec (`rake`)
1. Commit your changes (`git commit -am 'add some feature'`)
1. Push to the new branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## License
Please see [LICENSE](https://github.com/ezekg/theme-juice-cli/blob/master/LICENSE) for licensing details.

## Author
Ezekiel Gabrielse, [@ezekkkg](https://twitter.com/ezekkkg), [http://ezekielg.com](http://ezekielg.com)
