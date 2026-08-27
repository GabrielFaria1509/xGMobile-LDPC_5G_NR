5G NR LDPC Receiver Module

Project: xGMobile - Instituto Nacional de Telecomunicações (Inatel)

This directory contains a streamlined MATLAB implementation of the 5G NR physical layer reception chain, strictly following the 3GPP TS 38.212 specification.

📡 Reception Flow

Received Signal -> QAM Demodulation (LLR Extraction) -> De-Rate Matching & HARQ Combining -> LDPC Decoding -> CB Desegmentation & CRC -> Message Recovery

🛠️ Core Functions Summary

ReceiverEntry.m
Acts as the RF/Baseband interface. Performs Soft-Decision QAM demodulation on the received noisy IQ symbols to extract Log-Likelihood Ratios (LLRs) for the LDPC decoder. Includes LLR clipping and NaN handling for mathematical stability.

codeBlockRateDematching.m
Performs Code Block de-concatenation by slicing the received LLR stream into individual code blocks using strict symbol-aligned boundaries.

derate_matching.m
Executes the De-Rate Matching algorithm. Responsible for de-interleaving, de-puncturing, and performing HARQ Soft-Combining (managing circular buffer states across multiple transmission attempts/RVs).

codeBlockDecoding.m
A robust wrapper for the LDPC Decoder. Iterates through all code blocks and extracts the systematic information bits. Includes Input/Output shielding to gracefully handle severely corrupted blocks without crashing the simulation.

sum_product_decoding.m
The core LDPC channel decoder. Executes the Message Passing Algorithm (e.g., Normalized Min-Sum) over the bipartite Tanner Graph to iteratively correct channel errors based on the received LLRs.

codeBlockDesegmentation.m
Reconstructs the original payload by concatenating the decoded blocks. Validates individual Code Block CRCs (CRC-24B) as an early defense mechanism, and precisely truncates the padding ( filler bits) to restore the exact Transport Block size.

BG_Zc_Identifier.m
A unified utility function used by the receiver to autonomously determine both the Base Graph (BG) index and the minimum Lifting Size (Zc) required for the received transport block.

📚 References

[1] 3GPP TS 38.212 - "NR; Multiplexing and channel coding"

[2] 3GPP TS 38.211 - "NR; Physical channels and modulation"

[3] 3GPP TS 38.214 - "NR; Physical layer procedures for data"
