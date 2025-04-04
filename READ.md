# Quantum random based prediction

## 1) Propagate exchange price live to electric signal (python)

Python script to read exchange price via Pocket Option API (WebSockets update callback on change). Use exchange rate data from Pocket Option API callback
  - normalize the value for DAC (0-1023)
  - send the value via USB to Arduino
  - Extract prediction from historical data for previous time interval - up/down - for learning of NN

 ## 2) Converting number to signal (Arduino)
  via DAC to output pin => the signal is injected into environment in various forms 
  
  a) DC - pure electric signal (DC voltage between 0-5 volts)
  
  b1) value pulses -> each 50ms pulse with the value 0-5V, between pulses 0V
  
  b2) diff pulses -> each 50ms differences between actual and previous value (going up/down by X volts) 0-2.5 Down, 2.5-5V Up, between pulses 2.5V

  c) AC sinusoid - frequency modulation - the value is encoded into frequency of sinusoid
  
  d) the b1/2/c) converted to light wave - via led/infra red/laser led
  
  e) the b1/2/c) converted ts magnetic wave - through coil
  
  f) the b1/2/c) converted to acoustic wave - through waterproof repro

 ## 3) Collect multiple water response signals during and send via USB (Arduino)
 - same timeframe as input for prediction
 - selected timeframe ex 5s or 10mins
 
 a] Electric wave through simple wire
 
 b] Magnetic wave through coil
 
 c] Light wave through light detector
 
 d] Acoustic wave through waterproof microphone

 ## 4) Collect independent environment responses  and send via USB (Arduino)
 
 a] Randomly generated number from Zenner diode (Quantum based)
 
 b] Randomly generated number from Avalanche effect - Two transistors (Quantum based)
 
 c] Randomly generated number from photon arrival times (Quantum based)

 ## 5) Process all digitalized signals from 1), 3), 4) (Python)

 a] When is reached the number of samples for the collected data then start learning
 
 b] Use prediction of model and compare with real data

# Console dashboard:
Timestamp started: 30.12.2024 10:24:43
Number of collected samples: 102434343
Run time: 25 mins
Number of samples included in learning: 14200 / (5% of total)
Total prediction probability:         79%
Prediction probability for last 1min: 89%

## Signal contribution:
1.a 3.a 3.b ...
0%  5%  56% ...

# Commands:

c - continuous learning - it will extend data for learning with last snapshot (most actual number of samples)

l - last shot learning  - it will reset the NN, learn from scratch on the last data (most actual number of samples)

n [number] - set number of samples for next learning


Exchange price signal

1.a) 100 - 120 - 125 - 118 - 101 - 85 - 60 - 2 - 84 - 95 - ..
1.c)     -     -     -     -     - D  - D  - D - U  - U  -

Collected input signals

3.a]  104 - 126 - 456 - ..
3.b]  23  - 45 -  4   - ..
..
..
4.c]  438 - 432 - 26 - ..

## Starting vue3 frontend
cd frontend-vue3
npm run dev

## Starting quasar2 frontend
cd frontend-quasar2
quasar dev # or: yarn quasar dev # or: npx quasar dev

## Starting backend
cd backend
python fastapi_backend.py



