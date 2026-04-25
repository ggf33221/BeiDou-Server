@echo off
@title BeiDou
chcp 65001
cd /d "%~dp0"

.\jdk-21.0.10+7-jre\bin\java.exe -jar BeiDou.jar
pause