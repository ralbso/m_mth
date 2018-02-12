'''
Adapted from Quique's visual_stimuli.py

@author: Raul
'''

from psychopy import visual, core, event
# from psychopy.visual import windowwarp
from gratings import drifting_gratings
from random import shuffle
from matlab import engine
import datetime
import numpy
import os

mouse = 'LF18'
date = '20180209'

imaging_session = '000'
data_set = '000'

# start up matlab engine for scanbox
# matlab = engine.start_matlab()

grating_type = 'sqr'

warping = False

imaging_session_directory = '/Users' + os.sep + 'Raul' + os.sep + 'img' + os.sep + str(date)

# gratings orientations in degrees
orientations = numpy.linspace(0, 45, 90, 135)

# gratings cycles per degree
spatial_frequencies = [0.05]

# cycles per second
temporal_frequencies = [1.0, 2.0, 4.0, 8.0, 16.0]

grating_repetitions = 10

idle_color = -1

if not os.path.isdir(imaging_session_directory):
    os.mkdir(imaging_session_directory)

imaging_session_directory += os.sep + mouse

if not os.path.isdir(imaging_session_directory):
    os.mkdir(imaging_session_directory)

file_name = imaging_session_directory + os.sep + mouse + '_' + imaging_session + '_' + data_set + ' gratings.txt'

# set a pseudo-random sequence to show the gratings
grating_order = [[o, s, t] for o in orientations for s in spatial_frequencies for t in temporal_frequencies]*grating_repetitions
shuffle(grating_order)
print('grating order: ' + str(grating_order))

# create a fullscreen window for display
main_window = visual.Window(monitor = 'NLW1', fullscr = True, color = [idle_color, idle_color, idle_color], useFBO = True, screen = 2)

if warping:

    # add a spherical warping
    main_warper = windowwarp.Warper(main_window, warp = 'spherical', warpGridsize = 300, eyepoint = [0.5, 0.5], flipHorizontal = False, flipVertical = False)

print('Ready...')

# initialize screen to black before imaging
while True:
    if event.getKeys(keyList = ['escape']):
        main_window.close()
        core.quit()
    if event.getKeys(keyList = ['space']):
        break

# matlab.scanboxUDP('G')

print('Initializing...')

main_window.color = [0, 0, 0]

clock = core.Clock()

# wait 10 secs to startup scanbox
start = clock.getTime()
end = clock.getTime()

while end - start <= 10.0:
    end = clock.getTime()

    if event.getKeys(keyList = ['escape']):
        # matlab.scanboxUDP('S')
        main_window.close()
        core.quit()
    if event.getKeys(keyList = ['space']):
        break

    main_window.flip()

grating_times = []

print('Presenting gratings')

for orientation, spatial_frequency, temporal_frequency in grating_order:
    temp = str(datetime.datetime.now().time())
    temp = temp.split(':')

    time = 0.0

    for i in range(len(temp)):
        time += float(temp[i])*(60.0**i)

    grating_times.append([orientation, spatial_frequency, temporal_frequency, time])

    command = drifting_gratings(grating_type, orientation, spatial_frequency, temporal_frequency, presentation_time = 2.0, blank_time = 3.0, windows = [main_window])

    temp = str(datetime.datetime.now().time())
    temp = temp.split(':')

    time = 0.0

    for i in range(len(temp)):
        time += float(temp[i])*(60.0**i)

    grating_times.append([orientation, spatial_frequency, temporal_frequency, time])

    if command == 'quit':
        # matlab.scanboxUDP('S')
        numpy.savetxt(file_name, grating_times)
        main_window.close()
        core.quit()

numpy.savetxt(file_name, grating_times)

print("That's it!")

main_window.close()
core.quit()
