# GRID_Sandbox
[![alt text](http://apmechev.com/img/git_repos/GRID_Sandbox_clones.svg "github clones")](https://github.com/apmechev/github_clones_badge)

A 'Sandbox' containing a version-controlled copy of the scripts executed by LOFAR Jobs in a distributed environment

The base sandbox (master branch) is for testing purposes. It downloads the data attached to the PiCaS job token, and executes

```bash
ls $WORKDIR/Input
```

to verify that the worker node interaction is sane. 
