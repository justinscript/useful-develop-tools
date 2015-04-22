select * from dba_directories;

drop directory exp_dir;

create or replace directory UTL_FILE_DIR as '/opt/oracle/utl_file';

grant read, write on directory exp_dir to eygle;
 
ps axu|grep ora_|grep -v grep|awk '{print $2}'|xargs kill -9
 
 select estimated_flashback_size from v$flashback_database_log;
 
 select current_scn from v$database;
 
 alter table inventory enable row movement;
 alter table inventory_in enable row movement;
 alter table inventory_out enable row movement;
 
 --动态注册监听器
 SQL> alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.50)(PORT=1521))' sid='msun';
 

#ubuntu 设置系统时间
#date -s 07/26/2005

--替换sysdate
--正则表达式 to_timestamp\([^)]+?\)

--查看日志模式
select log_mode from v$database;

--查看数据库的启动状态
select open_mode from v$database;

select process,status from v$managed_standby;

--查看连接数
select username, count(username) from v$session where username is not null group by username;
--查看并发连接数
select count(*) from v$session where status = 'ACTIVE'

--最后来解决oracle中文字符集的问题。不出意外的话，启动oracle会发现所有的中文都是“？”，
--要么就是乱码，这其实是服务器端字符集和客户端字符集不一致造成的，
--解决方法为：DBA身份进入sqlplus，做查询select userenv('language') from dual;
--将查询结果复制，在/etc/bash.bashrc文件中再加一行：export NLS_LANG=”查询结果”，
--重新登录问题解决。例如：我的查询结果为SIMPLIFIED CHINESE_CHINA.AL32UTF8，
--则新加一行为export NLS_LANG=”SIMPLIFIED CHINESE_CHINA.AL32UTF8”。

--查看语言
SELECT USERENV('LANGUAGE')FROM DUAL;

--查看语言参数
select * from v$nls_parameters;

--启动监听器
lsnrctl start

--停止监听器
lsnrctl stop

--查看监听器状态
lsnrctl stat

--动态注册监听器
alter system register;

--启动数据库
--sqlplus /nolog
--conn /as sysdba
--conn sys/sys1234@test as sysdba;
--startup

--查询当前用户所有的表
select table_name from user_tables;

--#使用服务器参数文件spfile创建文本参数文件pfile：
--1,SQL> create pfile='/u01/oracle/dbs/test_pfile_ora' from spfile;
--#使用参数文件pfile创建服务器参数文件spfile：
--1,SQL> create spfile from pfile='/u01/app/oracle/admin/db_name/pfile/init$ORACLE_SID.ora';
--2,SQL> create spfile='/u01/oracle/dbs/test_spfile.ora' from pfile;
--综上所述，如果数据库中没有使用服务器参数文件，则不能使用服务器参数文件创建文本参数文件，因为服务器中可能使用文本参数文件。
--startup pfile='/opt/oracle_11/app/product/11.2.0/dbhome_1/dbs/initmsun.ora'


--#看下归档状态：
select group#,thread#,members,archived,status from v$log;

--#将FRA设置为备份目标之一
alter system set log_archive_dest_10='LOCATION=USE_DB_RECOVERY_FILE_DEST';
--#将/usr/oradata_bak/msun/设置为备份目的地
alter system set log_archive_dest_1='location=/usr/oradata_bak/msun/';

--通过导出方式备份数据库
--创建备份目录
create or replace directory dump_dir as '/opt/orabak/';
--授予读写权限给dev用户
grant read, write on directory dump_dir to dev;

--导出全数据库
--192.168.1.183 数据库备份账户为sysback/sysbak
oracle@server183 /]$ expdp dev/dev1234 directory=dump_dir dumpfile=full.dmp full=y;

--查看Oracle详细错误信息
oracle@server183 /]$ oerr ora 39006

--使用RMAN完整备份数据库
[root@server190 usr]# rman target=sys/s****4
RMAN> shutdown;

--创建备份用户
create user backup_admin identified by b******n;
--授权
GRANT connect, resource to backup_admin;
--授权
GRANT IMP_FULL_DATABASE, EXP_FULL_DATABASE, DBA, RECOVERY_CATALOG_OWNER to backup_admin;

--出库日志模式
select name,log_mode from v$database;

--在mount模式下将数据库改为ArchiveLog mode
alter database archivelog;

--查看日志
archive log list

--查看数据库是否启用闪回
select flashback_on from v$database;

--启动闪回--open状态下修改
alter database flashback on;

--修改retention_target大小(需要在mount状态下修改)
alter system set db_flashback_retention_target=3600 scope=spfile;

--联机备份
rman target=backup_admin/backup_admin

--备份数据库+归档日志文件
backup database plus archivelog;

--备份控制文件
backup as copy current controlfile format '/home/oracle/backup/ctl/msun_controlfilecopy.ctl';

--查看是否激活了块更改跟踪文件
select status from v$block_change_tracking;

--启用块更改跟踪文件
alter database enable block change tracking using file '/opt/oracle_11/app/block_change/msun_block_change.fil';

--[oracle@server190 ctl]$ rman target=backup_admin/backup_admin

--Recovery Manager: Release 11.2.0.1.0 - Production on Wed Nov 16 21:10:57 2011

--Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.

--connected to target database: YUEJI (DBID=2772872802)

--RMAN> configure controlfile autobackup on;

--using target database control file instead of recovery catalog
--new RMAN configuration parameters:
--CONFIGURE CONTROLFILE AUTOBACKUP ON;
--new RMAN configuration parameters are successfully stored

--INSERT INTO inventory VALUES (inventory_seq.nextval, sysdate, 20);
--SELECT inventory_seq.currval FROM DUAL; 

--###########  创建恢复目录  ###########--
create tablespace reco_cat datafile '/opt/oracle_11/app/oradata/emrep/reco_cat1.dbf' size 100m;

--创建用户
create user rman identified by pwd default tablespace reco_cat quota unlimited on reco_cat;

--授权
grant connect,resource,recovery_catalog_owner to rman;

SQL> conn rman/rman
Connected.

oracle@wtl:~$ echo $PATH
/usr/msun/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/oracle/bin:/opt/oracle_11/app/product/11.2.0/dbhome_1/bin
oracle@wtl:~$ rman catalog rman/rman@msun

Recovery Manager: Release 11.2.0.1.0 - Production on Mon Nov 21 20:35:13 2011

Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.

connected to recovery catalog database

RMAN> create catalog;
recovery catalog created

---
select   'grant   all   on   ' ||   table_name| | ' to   test '   from   user_tables;

--关闭防火墙
service iptables stop


--startup database:
startup nomount pfile='/opt/oracle_11/app/product/11.2.0/dbhome_1/dbs/initstdby.ora'


--创建密码create password: orapw+SID
orapwd file=$ORACLE_HOME/dbs/orapworcl entries=5 ignorecase=n force=y

--在standby库执行如下命令，同步数据
alter database recover managed standby database using current logfile disconnect from session;

--打开redo apply
alter database recover managed standby database using current logfile;

--
SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;

--查看状态
select open_mode from v$database;

同步primary/standby数据库
ALTER SESSION SYNC WITH PRIMARY;

查看Db的保护模式等
select protection_mode, protection_level, database_role role, switchover_status from v$database;

SELECT FS_FAILOVER_STATUS "FSFO STATUS",
   FS_FAILOVER_CURRENT_TARGET TARGET, 
   FS_FAILOVER_THRESHOLD THRESHOLD,
   FS_FAILOVER_OBSERVER_PRESENT "OBSERVER PRESENT"
   FROM V$DATABASE;


To start Redo Apply in the background, include the DISCONNECT keyword on the
SQL statement. For example:
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

To stop Redo Apply, issue the following SQL statement:
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

$ps -ef|grep dmon|grep -v grep


--查看表锁定
SELECT /*+ rule*/
a.sid, b.owner, object_name, object_type
FROM v$lock a, all_objects b
WHERE TYPE = 'TM'
and a.id1 = b.object_id; 

SELECT sid,serial# FROM v$session WHERE sid = &sid; 

alter system kill session 'sid,serial#';
alter system kill session '&sid,&serial#';

若不小心执行了以上命令,系统开始运行备份,但这个备份过程在前台找不到,是在后台处理的,因在上班期间,备份影响系统性能,想将正在运行的备份终止,此时方法是以sys用户登陆,在toad中使用命令:

select * from v$session where module like 'backup%'查找相关的备份会话,

然后用以下命令将其会话杀掉.

alter system kill session '671,1533'

将所有用户密码初始化为123456
update users set password='OVFAY09VPzZXOz8rVj9CWD1nP0lQZz09';

select count, actual_count from inventory where actual_count is null and count is not null ;

select count(*) from inventory where actual_count is null;

update inventory set actual_count = count where actual_count is null;

select label||color||sizes, count,actual_count from inventory where actual_count<> count;

--修改密码过期时间
select * from dba_profiles where profile='DEFAULT' and resource_name='PASSWORD_LIFE_TIME';
alter profile default  limit password_life_time unlimited;
alter user dev identified by dev1234 account unlock;