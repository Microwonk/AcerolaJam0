from scipy.io import wavfile
import numpy as np

sample_rate, data = wavfile.read('flash_light.wav')
data_8bit = np.uint8((data + 32768) / 256)
wavfile.write('flash_light_8bit.wav', sample_rate, data_8bit)