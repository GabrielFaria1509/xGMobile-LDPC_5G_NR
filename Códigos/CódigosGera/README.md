5G NR LDPC Transmitter Module

xGMobile Project - Inatel

Overview

This directory contains the 5G NR LDPC Transmitter implementation developed as part of the xGMobile research project at Inatel.

The main objective of this module is to implement the physical layer transmission chain defined by the 3GPP TS 38.212 specification, including:

Transport Block preparation;

CRC attachment;

Code Block Segmentation;

LDPC Base Graph selection;

LDPC encoding;

Rate Matching and Bit Interleaving;

HARQ Redundancy Version generation;

QAM modulation;

AWGN channel simulation.

The generated signals are forwarded to the Receiver module, where demodulation, rate dematching, LDPC decoding, HARQ soft combining and CRC verification are performed.

Transmitter Processing Flow

The implemented transmission chain follows the sequence:

Input Message
      |
      v
CRC Attachment
      |
      v
Code Block Segmentation
      |
      v
LDPC Base Graph Selection
      |
      v
LDPC Encoding
      |
      v
Rate Matching & Bit Interleaving
      |
      v
HARQ RV Generation
      |
      v
QAM Modulation
      |
      v
AWGN Channel
      |
      v
Received Signal


Main Transmitter Parameters

The transmitter functions receive parameters based on the 5G NR physical layer specifications.

Message Parameters

Variable

Description

A

Original transport block size (TBS), in bits

B

Transport block size after CRC attachment

C

Number of code blocks after segmentation

Coding Parameters

Variable

Description

R

Target code rate

BG

LDPC Base Graph number

Zc

Lifting size used by the LDPC matrix

H

LDPC parity-check matrix

K

Number of information bits per code block

LDPC Base Graph

The transmitter automatically selects between:

Base Graph

Usage

BG1

Larger transport blocks and higher code rates

BG2

Smaller transport blocks or lower code rates

The selection follows the rules defined in 3GPP TS 38.212.

Modulation Parameters

Variable

Description

Q_m

Number of bits per modulation symbol

SNR_dB

Signal-to-noise ratio used in channel simulation

Supported modulation examples:

Modulation

Q_m

BPSK

1

QPSK

2

16-QAM

4

64-QAM

6

256-QAM

8

HARQ Parameters

The transmitter generates the four possible redundancy versions (RV):

RV sequence:

RV0 → RV2 → RV3 → RV1


Each redundancy version contains a different portion of the circular buffer defined by the rate matching procedure.

The generated outputs are:

rx_1 → RV0
rx_2 → RV2
rx_3 → RV3
rx_4 → RV1


These signals are later combined by the receiver using HARQ soft combining.

Main Functions

transmitterfull()

Purpose: Main transmitter pipeline.

This function integrates all transmitter stages:

CRC generation;

Code Block Segmentation;

LDPC encoding;

Rate Matching;

Modulation;

Noise addition.

Inputs:

Parameter

Description

message

Original binary information

R

Target coding rate

E

Rate matching output length

Q_m

Modulation order

SNR

Channel SNR

Outputs:

Output

Description

rx_1

Received signal with RV0

rx_2

Received signal with RV2

rx_3

Received signal with RV3

rx_4

Received signal with RV1

C

Number of code blocks

BG

Selected LDPC Base Graph

Zc

Lifting size

B

Message size after CRC

H

LDPC parity-check matrix

codeBlockSegmentation()

Responsible for dividing the transport block into smaller blocks compatible with LDPC encoding.

Main concepts:

Transport Block (TB)

Code Block (CB)

Code Block CRC (CRC-24B)

Filler bits

When the message exceeds the maximum LDPC block size, segmentation is required.

ldpc_encoder()

Generates parity bits according to the selected Base Graph and lifting size.

The encoder uses:

H matrix

Zc lifting factor

Input information bits

to produce the encoded code block.

RateMatching()

Implements the circular buffer procedure and bit interleaving defined by 3GPP TS 38.212.

Responsibilities:

Bit selection;

Puncturing;

Repetition;

HARQ redundancy extraction;

Bit Interleaving (mitigates burst errors over the wireless channel).

The output length is controlled by the available resources E.

ModulatorProcess()

Transforms binary coded information into complex symbols.

Current supported modulation:

QPSK

16-QAM (and others based on Q_m)

The process consists of:

Bits
 |
 v
Symbol Mapping
 |
 v
Complex QAM Symbols


Channel Model

The transmitter includes an AWGN channel simulation.

Noise generation:

$$\sigma=\sqrt{\frac{1}{2 \cdot Q_m \cdot 10^{SNR/10}}}$$

The generated noise is added to the modulated signal:

Received Signal = Transmitted Signal + Noise


Development Notes

Coding Standards

When modifying this module:

Maintain compatibility with 3GPP TS 38.212;

Avoid changing variable meanings;

Document new parameters;

Preserve compatibility with the Receiver module;

Validate modifications using CRC verification.

References

[1] 3GPP TS 38.212 "NR; Multiplexing and channel coding"

[2] 3GPP TS 38.211 "NR; Physical channels and modulation"

[3] 3GPP TS 38.214 "NR; Physical layer procedures for data"

Project Information

Project: xGMobile

Institution: Instituto Nacional de Telecomunicações (Inatel)

Research Area: 5G NR Physical Layer / LDPC Channel Coding

This module is part of an academic research project developed within the Inatel research environment, aiming to contribute to advanced wireless communication studies and future-generation mobile networks.
