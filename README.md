# Real-Time Streaming Media Server

This server takes standard video packets from any mp4 source - e.g. camera,
screencap or input video - that are simply POSTed to a single REST URL
like http://www.example.com/streams/yourstream/upload/,
and makes it available via livestreaming right in your browswer at a URL like
http://www.example.com/streams/yourstream/.

What the server does is segment the incoming video, converts it to HTTP
Live Streaming format, buffers it, and sends it to a simple frontend.
The advantage is this makes it easy for apps to take whatever
video they have and make it live streamable on a server that anyone with
node can run.

# Technology

* Node 0.4.9
* HTTP Live Streaming (HLS)
* iOS demo app
* segment.c
* ffMPEG

# Running it

Get node and npm installed, then

    git clone https://github.com/andrewschaaf/media-server
    cd media-server
    npm install -g coffeescript
    npm install
    cake dev
    node lib/server.js

# You also need...

We also have a server that does the segmenting for you, but only runs on
ubuntu.  You can either run the node server also on ubuntu, or run the
segment service on ubuntu on a VM.

The project is [node-mpegts-segmenting](https://github.com/andrewschaaf/node-mpegts-segmenting).

# Authors

Andrew Schaaf <andrew@andrewschaaf.com>
Derek Dahmer <derekdahmer@gmail.com>
