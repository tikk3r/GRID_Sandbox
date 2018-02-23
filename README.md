# GRID_Sandbox
A 'Sandbox' containing a version-controlled copy of the scripts executed by LOFAR Jobs in a distributed environment

The base sandbox (master branch) is for testing purposes. It downloads the data attached to the PiCaS job token, and executes

```bash
ls $WORKDIR/Downloads 
```

to verify that the worker node interaction is sane. 
