# The IP/port of this server, used for callbacks to the segmenter
@THIS_HOSTNAME = '192.168.201.196'
@THIS_PORT = 3000

# The host and ip of the machine the segmenter is on (e.g. if its
# in a VM)
@SEGMENTER_HOSTNAME = 'vbox'
@SEGMENTER_PORT = 15437

@SEGMENT_LOCALLY = false

if @SEGMENT_LOCALLY
  @THIS_HOSTNAME = 'localhost'
  @SEGMENTER_HOSTNAME = 'localhost'
  @SEGMENTER_PORT = @THIS_PORT
