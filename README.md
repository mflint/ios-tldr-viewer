iOS TLDR-pages viewer
=====================

An iOS client for "TLDR-pages".

Changelog
---------

* 1.9.3: Adds mardown support to "See also" box (Thank-you Danny Mösch), and other small changes
* 1.9.2: Do not add commands to "See also" box multiple times (Thank-you Danny Mösch)
* 1.9.1: Crash-fix for iOS 11 users. Sorry about that :-(
* 1.9.0: Update to support iOS 13 and "dark mode"; change of internal Markdown parser
* 1.8.2: Update for Swift 5; fix alignment problem with "Copied to pasteboard" message; filter out duplicate commands when they exist in multiple languages with different names
* 1.8.1: Minor update to support a future change in the main 'tldr-pages' project
* 1.8.0: Tap code examples to copy to pasteboard; removes Fabric
* 1.7.0: Adds some Fabric analytics; Cancel search button now really cancels search
* 1.6.0: Updates for iPhone X and Swift 4.0.3
* 1.5.0: Updates for iOS 11 and Swift 4
* 1.4.0: Switches source URL, to avoid a 301 redirect to http :-/
* 1.3.0: Adds "See also" to detail pages when other relevant commands are found
* 1.2.0: Favourite commands with iCloud sync; adds "no search results" message
* 1.1.0: Added 3D Touch shortcuts to recently-viewed pages
* 1.0.2: Improved formatting and style of the tldr pages; upgraded to Swift 3
* 1.0.1: Added spotlight search
* 1.0.0: First release

Requirements
------------

* Xcode 12
* Swift 5.3

Acknowledgements
----------------

Thanks to:

* Romain Prieto and all other contributors to the [TLDR-pages project][TLDR-pages]
* Rob Phillips for [Down, a Markdown renderer][Down] built upon [cmark][cmark]
* Roy Marmelstein for the [Swift Zip framework][Zip]
* 'Arabidopsis' for the gorgeous teal-deer artwork. Found on [DeviantArt][TealDeerArtworkDeviantArt], currently used without permission.
  * if you're reading this, Arabidopsis, please get in touch!
* Anyone who has submitted bug reports or other feedback

Notes
-----

Arabidopsis' teal-deer artwork can be bought on a shirt at [Redbubble][TealDeerArtworkRedbubble].

Pull requests
-------------

Yup. Welcome!


[Zip]: https://github.com/marmelroy/Zip
[TLDR-pages]: https://github.com/tldr-pages/tldr
[Down]: https://github.com/iwasrobbed/Down
[cmark]: https://github.com/commonmark/cmark
[TealDeerArtworkDeviantArt]: http://arabidopsis.deviantart.com/art/Teal-Deer-II-158802763
[TealDeerArtworkRedbubble]: http://www.redbubble.com/people/arabidopsis/works/5386340-1-teal-deer-too-long-didnt-read
