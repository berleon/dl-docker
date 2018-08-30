#!/usr/bin/env python
# adapted from https://github.com/bethgelab/docker-deeplearning/blob/master/agmb-docker

import os
import socket
import argparse
import random
import string
from subprocess import call, check_output
import crypt
import fcntl
import struct

# set requested GPUs
try:
    os.environ['NV_GPU'] = os.environ['GPU']
    GPU = os.environ['GPU']
except KeyError:
    GPU = ''
if GPU == '':
    GPU = 'cpu'

# find IP address of network interface
def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

# find an open port for SSH connections
def get_open_port():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('', 0))
    port = s.getsockname()[1]
    s.close()
    return port


# get correct password encoding for jupyter notebook
# without relying on Ipython.lib.passwd (which is often not available on nodes)
def cast_bytes(s, encoding=None):
    if not isinstance(s, bytes):
        return encode(s, encoding)
    return s

def str_to_bytes(u, encoding=None):
    encoding = encoding or DEFAULT_ENCODING
    return u.encode(encoding, "replace")

def jupyter_crypt(passphrase=None, algorithm='sha1'):
    import hashlib
    salt_len = 12
    h = hashlib.new(algorithm)
    salt = ('%0' + str(salt_len) + 'x') % random.getrandbits(4 * salt_len)
    h.update(cast_bytes(passphrase, 'utf-8') + str_to_bytes(salt, 'ascii'))

    return ':'.join((algorithm, salt, h.hexdigest()))

# parse custom arguments
parser = argparse.ArgumentParser()

parser.add_argument('-u', '--user', metavar='USER_NAME', type=str,
                    default=os.environ['USER'],
					help='Specify an alternate user name (default: $USER)')

parser.add_argument('--uid', metavar='USER_ID', type=int,
                    default=os.getuid(),
					help='Specify an alternative user ID (default: $UID)')

parser.add_argument('--usergroups', metavar='USER_GROUPS', type=str,
                    default='sudo',
					help='Specify user groups (default: sudo)')

parser.add_argument('--userhome', metavar='USER_HOME', type=str,
                    default=os.environ.get('HOME', '/home/' + os.environ['USER']),
					help='Specify an alternative home directory (default: /home/$USER_NAME)')

parser.add_argument('--shell', metavar='USER_SHELL', type=str,
                    default=os.environ['SHELL'],
					help='Specify an alternate default shell (default: $SHELL)')

parser.add_argument('--pw', metavar='SUDO_PASSWORD', type=str,
                    default='pw',
					help='Specify a password for sudo rights (default: pw)')

parser.add_argument('--sshport', metavar='SSH_PORT', type=int,
                    default=get_open_port(),
					help='Specify an SSH port (default: randomly chosen in port range)')

parser.add_argument('--jupyterport', metavar='JUPYTER_PORT', type=int,
                    default=random.randint(8000,10000),
					help='Specify a jupyter port (default: randomly chosen in port range [600, 800])')

parser.add_argument('--jupyterpass', metavar='JUPYTER_PASSWORD', type=str,
                    default=''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(30)),
					help='Specify a jupyter password (default: randomly created)')

parser.add_argument('--name', metavar='CONTAINER_NAME', type=str,
                    default="",
		    help='Name of container (default: $USER-[CPU/$GPU])')

(args, extras) = parser.parse_known_args()


# container name
gpu_name = GPU.translate(None, ',') if GPU != "cpu" else 'CPU'
container_name = os.environ['USER'] + gpu_name
if args.name != "":
    container_name = args.name

# encrypt passwords
args.pw = crypt.crypt(args.pw, 'aa')
args.jupyterpass = jupyter_crypt(args.jupyterpass)

# put together the nvidia-docker command
command = ['docker',                            # the environmental variable NV_GPU is set and does not need to be called here
           'run',
           '--runtime=nvidia',
           ]                                  # docker command

if args.sshport:
    command.extend(['-p', str(args.sshport) + ':22'])  # set SSH port
if args.jupyterport:
    command.extend(['-p', str(args.jupyterport) + ':8888'])  # set JUPYTER port

command += [
		   '-e', 'USER_GROUPS=' + args.usergroups,     # set user-group
		   '-e', 'USER=' + args.user,                  # set user-name
		   '-e', 'OWNER=' + args.user,                 # set owner-name (used by dockerps)
		   '-e', 'USER_SHELL=' + args.shell,           # set user-shell
		   '-e', 'USER_ID=' + str(args.uid),           # set user-ID
		   '-e', 'USER_HOME=' + args.userhome,         # set home directory
		   '-e', 'USER_ENCRYPTED_PASSWORD=' + args.pw, # set password
		   '-e', 'GPU=' + GPU,                         # set GPU
		   '-e', 'JUPYTERPASS=' + args.jupyterpass,    # set jupyter password
		   '-v', args.userhome + ':' + args.userhome,  # mount home directory
		   '--name', container_name                    # set container name
		   ] + extras

# get IP address
try:
    ip = get_ip_address('eno1')
except:
    ip = 'unknown'

# print directions
print("Setting Notebook port binding to: {0} (to set manually add --jupyterport {0} as flag)".format(args.jupyterport))
print("Setting Notebook password to: {0} (to set manually add --jupyterpass {0} as flag)".format(args.jupyterpass))
print("")
print("You can now open the notebook on the host machine by directing your browser to")
print("")
print("    http://localhost:%i" % args.jupyterport)
print("")
print("or, from a remote system, to")
print("")
print("    http://%s:%i" % (ip, args.jupyterport))
print("")
print("In the latter case make sure that your local machine can see the server! Otherwise you might have to configure an SSH tunnel first.")
print("")

print(" ".join(command))
call(command)
