import re
import os
import time
import BaseHTTPServer
import signal
import threading
from subprocess import Popen
from subprocess import PIPE
from urlparse import parse_qs
from Queue import Queue

base_dir = os.path.dirname(os.path.abspath(__file__))
host_name = ''
port_number = 9000
exit_hifile = '.exit_hifile'
monitor_script = ['result', 'realtime_monitor', 'monitor', 'df', 'iostat', 'netstat', 'top', 'vnstat', 'vnstat_hours']
deploy_script = 'deploy'
deploy_result='get_deploy_result'
exit_hifile_path = base_dir + os.sep + exit_hifile
action_q = Queue(maxsize=10)
bash_bin = '/bin/bash'
vnstat_time = 5
monitor_period = 120
monitor_result = ''

class manage_handle(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain;charset=utf-8')
        self.end_headers()
        path = self.path
        if path.startswith('/'):
            path = path[1:]
        output = ''
        r_path = path
        index_of = path.find('?')
        if index_of != -1:
            r_path = path[0:index_of]
        script = base_dir + os.sep + r_path + '.sh'; 
        if r_path in monitor_script:
            output = ''
            if r_path == 'monitor':
                output = monitor_result
            else:
                args = [bash_bin, script]
                output = Popen(args, stdout=PIPE, close_fds=True).communicate()[0]
            self.wfile.write(output)
        if r_path == deploy_result:
            uid, hosts, apps, actions, mode = get_parameter(path)
            verbose = get_verbose(path)
            args = [bash_bin, script, uid, hosts, apps, actions, verbose]
            output = Popen(args, stdout=PIPE, close_fds=True).communicate()[0]
            self.wfile.write(output)
        if r_path == deploy_script:
            try:
                action_q.put(path, True, 1)
                self.wfile.write('deploy action accept, doing...')
                self.wfile.write('__ms_deploy_sucess_flag__')
            except Exception as e:
                self.wfile.write('action_q is full')
                self.wfile.write('__ms_deploy_error_flag__')
                self.wfile.write(e)
                print e
        monitor_period_p = re.search('set_monitor_period/(\d+)', r_path)
        if monitor_period_p is not None:
            global monitor_period
            monitor_period = int(monitor_period_p.group(1))
            print monitor_period

def get_verbose(path):
    index_of = path.find('?')
    parameters = parse_qs(path[index_of+1:])
    verbose = 'false'
    if 'verbose' in parameters:
        verbose = parameters['verbose'][0]
    return verbose

def get_parameter(path):
    index_of = path.find('?')
    parameters = parse_qs(path[index_of+1:])
    uid = parameters['uid'][0]
    hosts = parameters['hosts'][0]
    apps = parameters['apps'][0]
    actions = parameters['actions'][0]
    mode = ''
    if 'mode' in parameters:
        mode = parameters['mode'][0]
    return (uid, hosts, apps, actions, mode)
    
class handel_action_Thread(threading.Thread):
    def run(self):
        while(True):
            try:
                path = action_q.get(True)
                uid, hosts, apps, actions, mode = get_parameter(path)
                for host in hosts.split(','):
                    for app in apps.split(','):
                        for action in actions.split(','):
                            try:
                                file_path = (base_dir + "/../temp/%s_%s_%s_%s") % (uid, host, app, action)
                                self.touch(file_path)
                                f = open(file_path, 'w')
                                script = base_dir + os.sep + deploy_script + '.sh';
                                args = [bash_bin, script, uid, host, app, action, mode]
                                p = Popen(args, stdout=f, stderr=f, close_fds=True)
                                p.wait()
                            finally:
                                f.close()
            except Exception as e:
                print e
                pass
            finally:
                action_q.task_done()

    def touch(self, file_path):
        try:
            # first touch result file to let get_deploy_file.sh know
            f_touch = open(file_path, 'w')
        finally:
            f_touch.close()

class monitor_period_Thread(threading.Thread):
    def run(self):
        while(True):
            args = [bash_bin, base_dir + '/monitor.sh']
            global monitor_result
            monitor_result = Popen(args, stdout=PIPE, close_fds=True).communicate()[0]
            time.sleep(monitor_period - vnstat_time - 5)
            
class manage_http_Thread(threading.Thread):
    def to_exit(self):
        if os.path.exists(exit_hifile_path):
            os.remove(exit_hifile_path)
            return True
        else:
            return False

    def run(self):
        manage_http = BaseHTTPServer.HTTPServer((host_name, port_number), manage_handle)
        manage_http.timeout = 5
        print time.asctime(), "Server Starts - %s:%s" % (host_name, port_number)
        try:
            while(not self.to_exit()):
                manage_http.handle_request()
        except Exception as e:
            print e
            pass
        finally:
            print 'manage_http.server_close'
            manage_http.server_close()
        print time.asctime(), "Server Stops - %s:%s" % (host_name, port_number)
    
if __name__ == "__main__":
    t = manage_http_Thread()
    t.start()

    t1 = handel_action_Thread()
    t1.daemon = True
    t1.start()

    t2 = monitor_period_Thread()
    t2.daemon = True
    t2.start()

    t.join()
