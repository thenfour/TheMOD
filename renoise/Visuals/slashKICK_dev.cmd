@echo off

pushd %~dp0
cd AteBitVJ

start "." /MAX ".\AteBitVJ_release.exe" User/SlashKICK/slashKICK.avinymproject

start "dbmon" /B "..\tools\dbmon.exe"


