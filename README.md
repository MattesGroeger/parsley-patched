What is included in this patched version?
---------

- Fixed ant build files in order to make them working
- Proper FDT settings for classpath/prefs
- Advanced param binding for localization
 - Use {variable} instead of {0}
 - Bind variables to class fields with [ParamBinding] metadata tag
 - See also [parsley-param-binding](https://github.com/MattesGroeger/parsley-param-binding)
- Replaced sortOn with sort method to fix problem in certain browser/Flash Player combinations

Why is it patched in 2.4 Milestone 2?
---------

This is because we still use this version in our game. Feel free to cherry-pick the commits to whatever Parsley version you are using.