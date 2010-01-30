Powered in various ways by the Flash Camouflage display framework created by Jesse Freeman, http://flashcamo.flashartofwar.com/ , SG Camo Collections is a personal suite branch of display classes, UI, behaviours and interfaces developed specifically for AS3/Flash development.

Here's the current run-down of what you'll find in the repository:

////////////////////////////////////////
camo.core
////////////////////////////////////////
Jesse Freeman's core set of Flash-Camouflage classes (mainly the download package from Flash Camouflage's SVN repository on Google Code). 
http://code.google.com/p/flash-camouflage

Contains some minor modifications/additions to Jesse's code-base and also shares the various interface signatures used under the core SG-Camo package.

////////////////////////////////////////
sg.camo
////////////////////////////////////////
The core SG-Camo package. Contains all interface signatures, events and behaviours which the rest of the packages in the respository tend to rely on.

THe key to this core lies in it's set of behaviours and interface signatures. These can easily be composed into other display-based classes (from other packages or directly onto native Flash display classes) to immediately hook up these display classes with a necessary set of basic interactive behaviours for your application.

A common set of interface signatures within sg.camo.interfaces allows light-weight cross-platform compatability and access across different application domains from external .swfs as long as the interfaces are already loaded into the parent domain at the beginning of the application.

Interfaces are kept as simple & minimalistic as possible so that they can be implemented (or extended) by other classes or packages outside of SG-Camo. Unlike the regular Camo Core, there are absolutely no concrete display-based implementations in this package.

////////////////////////////////////////
sg.camolite
////////////////////////////////////////
SG-CamoLite, a display-based UI implementation normally used under Flash as skinned library symbols in Flash authoring environment. By default, all these display classes extend from native Flash display classes (SimpleButton, Sprite, MovieClip, etc.) or Jesse Freeman's basic AbstractDisplay class. Absolutely no CSS-like/BoxModel/CamoDisplay implementations are used here since Sg-CamoLite is purely designed for Flash-skinned library assets. If you're looking for Flash-skinnable UI components for stuff like scrollbars, menus, (or just base classes to work with your own custom Flash display implementations). this package can come in useful.

////////////////////////////////////////
sg.camoextras
////////////////////////////////////////
All other miscelleanous stuffs, utilities and bonuses go here.

////////////////////////////////////////
sg.camogaia
////////////////////////////////////////
Any misc. Camo/SG-Camo mplementation for the Gaia Flash Framework goes here.


IN DEVELOPMENT:

////////////////////////////////////////
sg.camogxml
////////////////////////////////////////
Currently, the GXML (sG-XML markup) rendering/factory standard is being reworked to allow more versatility in allowing one to render and layout all sorts of Flash display objects through basic XML markup with the ability to compose and inject various behaviours (layout, skin and user-interaction) into each display entity in a non-prescriptive (and cross-platform) way. The basic sg.camogxml.render package allows cross-platform integration with other frameworks, including your own application, if you somehow need a comprehensive XML markup renderer (and SEO content injector) to display Flash content directly.

Generally, this framework tends to work better towards the more advanced CamoDisplay/BoxModel classes developed by Jesse Freeman which involves manually skinning displays via CSS-like properties (in which a document-based markup language and accompanying stylesheet could help), but GXML can also include your basic native Flash display classes, classes from SG-CamoLite, and even your own display-based classes from your own local Flash libraries.

Generally, the code in this GXML package is geared more towards dynamically creating instances and supplying user-defined dependencies via XML markup with the help of Camo's property injection system (and some of SG-CamoGXML's in-house dependency injection utilities).

////////////////////////////////////////
sg.camogxmlgaia
////////////////////////////////////////
Codenamed the "CGG Framework", this is basically GXML running on top of the Gaia Flash Framework, and obviously powered by SG-Camo/Camo-Core, in general. The plan? An extendable site that you can develop completely with just a markup language alone, with the ability to introduce new reusable modules, packages, assets and skins across different page .swf domains coupled with seamless Gaia SEO integration, dependency injection, and lifecycle management of instances per page. The objective? Basic site developmenent is even possible with just a CGG pre-compiled shell, Gaia's site.xml, and your assets consisting of custom GXML markup, Flash library assets, or any other accompanying behaviour classes or additional modules you may intend to load later within your site tree and unload once you're done. 