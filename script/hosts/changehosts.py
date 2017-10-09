#!/usr/bin/python
import re
import sys

def changehosts():
    hostsmap = {}
    envlist = []
    hosts = open('/etc/hosts', 'r')
    current_env = ''
    for line in hosts:
        line = line.strip()
        env_p = re.search('^###\s*(\S+)\s*###$', line)
        if env_p is not None:
            current_env = env_p.group(1)
            if current_env in envlist:
                raise 'duplicate defined host env name: %s' % current_env
            envlist.append(current_env)
            hostsmap[current_env] = [] 
            continue
        if current_env == '':
            continue
        hostsmap[current_env].append(line)
    hosts.close()

    iter_idx = 0
    for env_iter in envlist:
        print '(%s) %s' % (iter_idx, env_iter)
        iter_idx = iter_idx+1
    hostsmapCount = {}
    for env in hostsmap:
        for line in hostsmap[env]:
            if not line.startswith('#'):
                if env in hostsmapCount:
                    hostsmapCount[env] = hostsmapCount[env]+1
                else:
                    hostsmapCount[env] = 1
    current_env = None
    max_count = 0
    for env in hostsmapCount:
        if env != 'base' and hostsmapCount[env] > max_count:
            current_env = env 
            max_count = hostsmapCount[env]
    if max_count == 0:
        current_env = 'base'
    print 'current env: %s, chose your hosts env > ' % current_env
    env = envlist[int(sys.stdin.readline().strip())]
    writehosts(env, envlist, hostsmap)

def writehosts(env, envlist, hostsmap):
    hosts = open('/etc/hosts', 'w')
    for env_iter in envlist:
        hosts.write('### %s ###' % env_iter)
        hosts.write('\n')
        desc = (env == env_iter or env_iter == 'base')
        for item in hostsmap[env_iter]:
            while item.startswith('#'):
                item = item[1 : len(item)]
            if desc:
                hosts.write('%s' % item.strip())
            else:
                hosts.write('# %s' % item.strip())
            hosts.write('\n')
    hosts.close()

def print_example():
    example = """> cat /etc/hosts
### base ###
127.0.0.1           localhost
127.0.0.1           zxc-rMBP
255.255.255.255     broadcasthost
::1                 localhost
fe80::1%lo0         localhost
91.213.30.151       www.google.com
91.213.30.151       www.google.com.hk
91.213.30.151       accounts.google.com
91.213.30.151       accounts.google.com.hk
91.213.30.151       mail.google.com
91.213.30.151       mail.google.com.hk
91.213.30.151       plus.google.com
91.213.30.151       plus.google.com.hk
### server109 ###
192.168.0.109       web.msun.com
192.168.0.109       wap.msun.com
### localdev ###
127.0.0.1           web.msun.com
127.0.0.1           wap.msun.com
### run ###
"""
    print example

if __name__ == '__main__':
    if len(sys.argv) > 1 and (sys.argv[1] == '-h' or sys.argv[1] == '-help'):
        print 'usage: defined /etc/hosts and run changehosts.py, make sure /etc/hosts writeable, example:'
        print_example()
        sys.exit(1)
    changehosts()


