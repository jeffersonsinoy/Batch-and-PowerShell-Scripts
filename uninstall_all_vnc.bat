@echo off
setlocal enableDelayedExpansion
for %%a in ("" "\Wow6432Node") do (
    for /f "delims=" %%b in ('
        reg query HKLM\SOFTWARE%%~a\Microsoft\Windows\CurrentVersion\Uninstall ^
            /s /d /f "VNC" ^| findstr "HKEY_ DisplayName"
    ') do (
        set "line=%%b"
        if "!line:~0,4!"=="HKEY" (
            set "key=!line!"
        ) else (
            set Uninstall=
            rem Sort /r makes QuietUninstallString the last line
            for /f "tokens=2*" %%c in ('
                reg query "!key!" ^| find "UninstallString" ^| sort /r
            ') do if not "%%d"=="" set "Uninstall=%%d"

            if defined Uninstall (

                for /f "tokens=2*" %%c in ("!line!") do (
                    set product=%%d
                    if NOT "x!product:TightVNC=!"=="x!product!" (
                        for /f "tokens=2 delims={}" %%A in ("!Uninstall!") do (
                        echo Found !product!
                        CALL msiExec.exe /qn /x{%%A}
                        echo.
                        )
                    ) else (
                        if NOT "x!product:UltraVNC=!"=="x!product!" (
                            for /f "tokens=1 delims=." %%A in ("!Uninstall!") do (
                                echo Found !product!
                                CALL %%A.exe" /VERYSILENT /NORESTART
                                echo.
                            )
                            ) else (
                                if NOT "x!Uninstall:RealVNC=!"=="x!Uninstall!" (
                                            for /f "tokens=1 delims=." %%A in ("!Uninstall!") do (
                                            echo Found !product!
                                            CALL %%A.exe" /VERYSILENT
                                            echo.
                                        )
                                    ) else (
                                        echo Found %%d
                                        CALL !Uninstall!
                                        echo.
                                )
                            )
                        )
                    )
                )
           )
        )
    )