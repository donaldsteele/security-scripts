@ECHO OFF

:: Marketing, ya know?
type liamdev.txt

:: Because I'm a "hacker"... or not
COLOR 0A

CLS

:: Check For Admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success!  You have admin rights!
    goto :admin
) else (
    echo Error!  You must run the script with admin rights!
    pause>nul
)

:admin
:: Account Policies
echo Setting up account password policies...
net accounts /FORCELOGOFF:30 /MINPWLEN:8 /MAXPWAGE:90 /MINPWAGE:10 /UNIQUEPW:5
echo Password policies set!  Moving on...

:: Disable Guest Acct
net user Guest | findstr Active | findstr Yes
if %errorlevel%==0 echo Guest account is active, deactivating
if %errorlevel%==1 echo Guest account is not active, so not deactivating
net user Guest /active:NO