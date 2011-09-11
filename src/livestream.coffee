# DB of id:<livestream object>
livestreams = {}

# Fetches or ecreats a livestream by that id
getLivestream = @getLivestream = (id) ->
  if livestreams[id]?
    return livestreams[id]
  else
    ls = new LiveStream(id)
    livestreams[id] = ls
    return ls


# Return all the current livestreams in the database
allLivestreams = @allLivestreams = ->
  return livestreams

# Represents a live streaming room
class LiveStream
  constructor: (@id) ->
    @ts_urls = []

  playlistText: ->
    newline = "\r\n"
    text = ""

    # Necessary header
    text += "#EXTM3U#{newline}"

    # The appromixate duration of the next TS to be added
    text += "#EXT-X-TARGETDURATION:5#{newline}"

    for ts_url in @ts_urls
      # Approximate duration of this TS
      text += "#EXTINF:5#{newline}"
      text += "#{ts_url}#{newline}"

    return text

  addTs: (url) ->
    @ts_urls.push(url)

  getTss: ->
    return @ts_urls



# Debug livestream already added
stream = getLivestream 'fixture'

stream.addTs '/chunk-1.ts'
stream.addTs '/chunk-2.ts'
stream.addTs '/chunk-3.ts'

