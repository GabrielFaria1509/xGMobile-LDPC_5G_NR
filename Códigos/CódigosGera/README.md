5G NR LDPC Transmitter Module

Project: xGMobile - Instituto Nacional de Telecomunicações (Inatel)

This directory contains a streamlined MATLAB implementation of the 5G NR physical layer transmission chain, strictly following the 3GPP TS 38.212 specification.

📡 Transmission Flow

Message -> CRC Attachment -> CB Segmentation -> LDPC Encoding -> Rate Matching & Interleaving -> QAM Modulation -> AWGN Channel

🛠️ Core Functions Summary

transmitterfull.m
The main pipeline wrapper. Receives the raw message, target code rate (R), allocated resources (E), modulation order (Q_m), and channel SNR. It orchestrates the entire flow and outputs the modulated signals for the 4 HARQ Redundancy Versions (RV0, RV2, RV3, RV1).

crc_generator.m
Generates and attaches the required Cyclic Redundancy Check parity bits. Uses CRC-24A or CRC-16 for Transport Blocks, and CRC-24B for segmented Code Blocks.

Base_Graph_selector.m
Automatically selects the appropriate LDPC Base Graph (BG1 for eMBB/high rates, BG2 for URLLC/low rates) based on the payload size and target code rate.

codeBlockSegmentation.m
Splits large transport blocks into smaller, manageable code blocks if they exceed the maximum sizes supported by the Base Graph (8448 bits for BG1; 3840 bits for BG2).

codeBlockEncoding.m
Performs the core LDPC channel coding using the dynamically expanded Generator Matrix over Galois Field GF(2).

RateMatching.m
Adjusts the LDPC-encoded block to fit the exact physical resources available (E). It performs bit selection, puncturing, HARQ redundancy version extraction, and bit interleaving to mitigate burst errors over the wireless channel.

ModulatorProcess.m
Transforms the binary sequence into complex symbols (e.g., QPSK, 16-QAM) and applies the AWGN (Additive White Gaussian Noise) channel simulation based on the given SNR.

📚 References

[1] 3GPP TS 38.212 - "NR; Multiplexing and channel coding"

[2] 3GPP TS 38.211 - "NR; Physical channels and modulation"

[3] 3GPP TS 38.214 - "NR; Physical layer procedures for data"
