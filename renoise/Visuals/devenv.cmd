@echo off

pushd %~dp0
cd AteBitVJ

start "." /MAX ".\AteBitVJ_release.exe"

start "dbmon" /B "..\tools\dbmon.exe"


