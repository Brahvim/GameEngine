 # Fisica for 2D Physics.
 ...or simply wrapping JBox2D, perhaps, but that would be TOO HARD.
 LiquidFun is more focused on Android, so I won't really use it!
 Fisica works fine on Android, too! Processing users definitely have
 experience with it, and "BoxWrap2d" is incompatible with newer
 vesions of Processing.


 # LibBulletJME for 3D Physics.
 LBJME is pretty nicely put together, includes V-HACD
 (3D mesh to Convex Hull Decomposition tool), and is also super easy
 to use with Processing! ..or any Java applicaton, really.

 Daniel Koehler from lab-eds made the "bRigid" library for Processing,
 which is also good for compatibility for Processing users, but it wraps
 "JBullet" an old, pretty much deprecated port. bRigid does not wrap as
 much of Bullet, and so, it becomes alsmost inevitable to avoid jumping
 into JBullet's code, which, by the way, is also incomplete! It is not
 only stuck at version 2.72, which is too old as of today, 18 August 2022.

 Since we will have to dive into Bullet's docs and code with either option,
 the following is only and only nice news:

 LBJME is easy to use!
 LBJME uses the JNI to port Bullet's direct source into Java, and the JNI
 is *wayyyyy* too fast. Faster than `C#` and Microsoft's CLR!
 It stays very updated! The latest release came *6* days ago!
 The owner of the project, Stephen Gold, is almost completely dedicated
 it. This is all good news for us!

 # """ECS""" is ready!
 This Engine uses a homemade ECS for making it easy for Processing users.
 Remember:

 **THE AIM OF THIS ENGINE, IS TO MAKE IT EASY FOR PROCESSING USERS TO MAKE
 [(mostly just... game)] APPLICATIONS, AND NOT ACT LIKE AN ACTUAL GAME ENGINE.**

 You better remember that! 😂
