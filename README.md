# tunatron

Tunatron is simple and (hopefully) fast application to control iTunes from
keyboard. Actually, not completely control, but just search for/change a track,
that's all it intends to do. Set a global hotkey, and you're good.

Some notes:

 - The interface is not exceptionally pretty, just useful - if you want to fix
   that, please contribute (either with ideas what to do or with code).
 - I'm not an experienced Cocoa developer, so if you see ways to improve code,
   they are very welcome (in case of better idiomas or better separation of
   code).

I'm not sure if I forgot anything? Whatever, just try it, if you despise iTunes
slow and inefficient search, or if you like how Foobar2000 search works, or if
you like Textmate/emacs' ido-mode/vim's command-T scatter matching for searching
for files.

Here's how it looks like:

![tunatron](http://i.imgur.com/ctclr.png)

## TODO

 - improve searching (use smarter index/dictionaries, etc)
 - use persistent id: track number to search for a song instead of current
   iteration
 - album cover images in separate column
 - playing queue maybe?
