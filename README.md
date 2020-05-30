# ANS (Apache, NFS, Samba)
Bash script to execute basic setup of Apache, NFS, and Samba (ANS) on Linux.

## Getting Started
This is a simple install and setup for Apache, NFS, and Samba. It setups up Apache to allow user logins, configure NFS to allow network file sharing to specific IP, and enables Samba to be accessible using credentials. 

Each script can be ran individually, however using `setup.sh` is ideal as it can be used to install all 3 services and meant to be more user friendly with messages.

## Prerequisite
* Bash

## Usage
### Arguments
* `-a, --apache`
* `-n, --nfs`
* `-s, --samba`
* `-u, --user`
* `-p, --pass`
* `-i, --ip`
* `-m, --mount`

### Services
There 3 services that the script can install/configure:
* Apache
* NFS
* Samba

The 3 services can be setup individually, in tandem with others, or all at once. 

Each service has its own set of required arguments.

#### Apache (-a, --apache)
* `-u, --user`
* `-p, --pass`

#### NFS (-n, --nfs)
* `-u, --user`
* `-i, --ip`
* `-m, --mount`

#### Samba (-s, --samba)
* `-u, --user`
* `-p, --pass`
* `-m, --mount`

### Configuration
These argurments are required to properly setup each service.

#### Username (-u, --user)
The username for the system user that the user will use to login. If the user does not exist already, it will be created.

#### Password (-p, --pass)
The password for the system user that will be required for login.

#### Destination IP (-i, --ip)
The destination IP of the client that will be configured to allow access.

#### Mount Path (-m, --mount)
The mount path on the server that will be shared.

## Author

**Gabriel Lee** - [ScrawnySquirrel](https://github.com/ScrawnySquirrel)
