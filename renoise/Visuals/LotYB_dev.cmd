@echo off

pushd %~dp0\AteBitVJ

start "." /MAX ".\AteBitVJ_release.exe" User/LotYB/LotYB.avinymproject

start "dbmon" /B "..\tools\dbmon.exe"

