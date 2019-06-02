@echo off
set KX_VERIFY_SERVER=NO
set SSL_VERIFY_SERVER=NO
set qhome=%~dp0q
start "5033_ts_huobi"  %~dp0q\w32\q.exe ts_huobi.q -p 5033 -U %~dp0q/qusers
