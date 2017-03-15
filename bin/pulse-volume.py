import sys
from pulsectl import Pulse

[_,diff_str] = sys.argv
diff = float(diff_str)

with Pulse('volume-increaser') as pulse:
    for sink in pulse.sink_list():
        pulse.volume_change_all_chans(sink, diff)
