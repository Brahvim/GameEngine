This 'lib' folder exists purely for development purposes.
It only contains cross-platform `.dll`s for the use of the LibBulletJME library.

When a Processing 3.5.4 sketch is exported, it generates with a file structure like so:

```
application.os-name__arch-name
 Ldata
 Llib
 Lsource
 Lsketch.exe
```

This folder exists to make sure the path of the `.dll`s does not change when the application is exported.