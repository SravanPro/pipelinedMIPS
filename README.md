# pipelinedMIPS
A 5 Stage pipelined MIPS processor

https://github.com/user-attachments/assets/5010b731-8679-4c53-bac9-5797e32f0df7

https://github.com/user-attachments/assets/cd37cc58-f96e-4342-ad5c-a0552c70de12


# MIPS Pipeline Processor — FPGA Pixel Painter

A 5-stage pipelined MIPS processor implemented in Verilog, running a handwritten machine code painter application on an FPGA. 

The processor drives a 128×64 OLED display over SPI, with a potentiometer joystick for cursor movement and pushbuttons for draw/erase/reset.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Hardware Interface](#hardware-interface)
3. [Clock & Timing](#clock--timing)
4. [Pipeline Architecture](#pipeline-architecture)
5. [Hazard Handling & Forwarding](#hazard-handling--forwarding)
6. [The Painter Program (Instruction Memory)](#the-painter-program-instruction-memory)
7. [Memory & Framebuffer](#memory--framebuffer)
8. [Peripheral & Helper Modules](#peripheral--helper-modules)
   - [analogTranslator](#analogtranslator)
   - [movementDivider](#movementdivider)
   - [crosshair](#crosshair)
   - [SPI Driver](#spi-driver)
   - [segmentDisplayDecoder](#segmentdisplaydecoder)
9. [Top-Level Integration (parent.v)](#top-level-integration-parentv)
10. [File Index](#file-index)

---

## System Overview

The system runs a pixel-painting application entirely in MIPS machine code. The processor reads joystick and button states through memory-mapped I/O, updates a bit-packed 128×64 framebuffer stored in data memory, and the SPI driver continuously scans that framebuffer out to an SSD1306-compatible OLED display. A combinational crosshair overlay is OR'd with the pixel framebuffer before display so the user always sees their cursor position.

```
Joystick (2-axis pot)
   └─ 4 comparators (2 per axis) ──► analogTranslator ──► movementDivider
                                                                 │
Pushbuttons (draw / erase / gameRst)                             │
   └──────────────────────────────────────────────────► memMappedIO bus
                                                                 │
                                                         ┌───────▼────────┐
                                                         │  MIPS Pipeline  │
                                                         │  (5-stage, 62.5 │
                                                         │   MHz eff.)     │
                                                         └──────┬─────────┘
                                                                │
                                                    ┌───────────▼──────────┐
                                                    │  Data Memory (DMEM)   │
                                                    │  0x000–0x1FF: general │
                                                    │  0x200–0x5FF: FB      │
                                                    └───────────┬──────────┘
                                                                │
                                              framebuffer[8192] │
                                                                │
                                              crosshairFB[8192] │
                                                     (OR'd) ◄───┘
                                                                │
                                                         ┌──────▼──────┐
                                                         │  SPI Driver  │
                                                         │  (SSD1306)   │
                                                         └──────┬───────┘
                                                                │
                                                           OLED Display
```

---

## Hardware Interface

### Joystick Input — Custom Flash ADC

The joystick is a **2-axis potentiometer**. Rather than a standard multi-comparator flash ADC, each axis uses only **2 comparators**, producing a 2-bit thermometer code per axis (4 comparators total). The four resulting signals are named `white`, `black` (horizontal axis) and `brown`, `red` (vertical axis).

The `analogTranslator` module decodes these thermometer codes into clean directional signals:

| white, black | left, right |   | brown, red | up, down |
|:---:|:---:|---|:---:|:---:|
| 01 | 00  |   | 01 | 00  |
| 11 | 10 |   | 00 | 10  |
| 00 | 01 |   | 10 | 01 |

```verilog
assign left  = white;
assign down  = brown;
assign right = ~black;
assign up    = ~red;
```

This is a deliberate combinational decode — the comparator output patterns directly map to direction signals with simple inversion.

### Pushbuttons

Three active-high pushbuttons with pull-ups connect directly to the FPGA:

| Signal    | Function                              |
|-----------|---------------------------------------|
| `draw`    | Set the pixel at cursor position      |
| `erase`   | Clear the pixel at cursor position    |
| `gameRst` | Reset entire framebuffer and position |

### Output — SPI OLED

The SPI pins (`sck`, `sda`, `res`, `dc`, `cs`) connect directly to an **SSD1306-compatible 128×64 OLED** display. The SPI driver handles the full initialization sequence and continuous page-by-page refresh.

---

## Clock & Timing

The FPGA is clocked at **125 MHz**. A **T flip-flop (`tff`)** divides this by 2, giving the processor and most peripherals an effective clock of **62.5 MHz**.

- **Timing closure**: all setup, hold, and pulse-width constraints are met at 125 MHz (WNS = 2.794 ns, WHS = 0.137 ns, zero failing endpoints across 16,409 checked).
- The `crosshair` module runs on the **full 125 MHz** clock directly to complete its 18-cycle sequential render within the same effective pipeline cycle budget.
- The SPI driver also runs on `t_ff_clk` (62.5 MHz). Its internal clock divider (`CLK_DIV = 4`) produces an SPI clock of ~7.8 MHz, well within the SSD1306's maximum.

---

## Pipeline Architecture

The processor implements a classic **5-stage MIPS pipeline**:

```
IF  →  ID  →  EX  →  MEM  →  WB
```

### Stages & Pipeline Registers

| Register | File | Function |
|----------|------|----------|
| IF/ID | `if_id.v` | Holds fetched instruction and PC+4; supports stall and flush |
| ID/EX | `id_ex.v` | Holds decoded operands, register numbers, and all control signals; supports stall (inserts NOP bubble) and flush |
| EX/MEM | `ex_mem.v` | Holds ALU result, branch target, zero flag, and memory control signals; flushes on taken branch |
| MEM/WB | `mem_wb.v` | Holds memory read data, ALU result, and writeback control |

### Supported Instructions

**R-type:** `add`, `sub`, `and`, `or`, `nor`, `xor`, `slt`, `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`, `nand`, `jr`

**I-type:** `addi`, `andi`, `ori`, `xori`, `slti`, `lui`, `lw`, `sw`, `beq`, `bne`

**J-type:** `j`, `jal`

### ALU

`alu6.v` implements 16 operations selected by a 4-bit opcode generated by `aluControl.v`. Notable extensions beyond standard MIPS include `NAND`, `NOR`, `XOR`, `EQ` (equality check returning 0/1), increment, decrement, and variable-shift operations (`sllv`, `srlv`, `srav`).

### Immediate Extension

`sext_or_zext_control.v` selects between sign-extension (`signExtend.v`) and zero-extension (`zeroExtend.v`) based on `aluOp`. Instructions `andi`, `ori`, `xori`, and `lui` use zero-extension; all others use sign-extension.

### Jump & Branch

- **J-type** addresses are assembled by `jTypeAddressProcessor.v`: `{NPC[31:28], IR[25:0], 2'b00}`.
- **`jr`** is detected combinationally by `jrControl.v` and immediately muxes `rd1` into `pc_next` in the ID stage, bypassing the pipeline register.
- **Branches** are resolved in the MEM stage. A taken branch (`mem_PCSrc`) flushes IF/ID and ID/EX.

---

## Hazard Handling & Forwarding

### Data Forwarding (`forwardingUnit.v`)

The forwarding unit monitors the EX/MEM and MEM/WB destination registers against the ID/EX source registers and drives two 2-bit mux selects (`forwardA`, `forwardB`):

| Select | Source |
|--------|--------|
| `00`   | Register file output (no hazard) |
| `01`   | MEM/WB writeback data |
| `10`   | EX/MEM ALU result |

### Load-Use Stall (`hazardDetectionUnit.v`)

When the instruction in ID/EX is a `lw` and its destination register (`id_ex_RT`) matches either source register of the instruction in IF/ID, the HDU:
- Freezes the PC (`PCWrite = 0`)
- Freezes IF/ID (`IF_IDWrite = 0`)
- Inserts a NOP bubble into ID/EX (`ID_EXStall = 1`)

### Known Limitations & NOP Requirements

The forwarding and hazard logic does not cover all corner cases. To guarantee correct execution, the programmer must manually insert **3 NOPs** before any `jr` or branch instruction, and **3 NOPs** between any instruction that writes a register and a subsequent branch that reads it. This is the convention used throughout the painter program.

```mips
# Example: safe branch pattern
addi r11, r1, -127   # writes r11
nop                  # \
nop                  #  > 3 NOPs
nop                  # /
beq  r11, r0, label  # branch reading r11
nop
nop
nop
```

---

## The Painter Program (Instruction Memory)

`instructionMem.v` contains the entire painter application baked in as a hardcoded MIPS machine-code program, loaded at synthesis time and reloaded on every reset. It is not a general-purpose memory — it is a fixed ROM that runs the painter.

### Register Map

| Register | Role |
|----------|------|
| r1 | X coordinate (0–127) |
| r2 | Y coordinate (0–63) |
| r3 | Flat pixel index (`Y*128 + X`) |
| r4 | Word index into framebuffer (`flat >> 5`) |
| r5 | Bit index within word (`flat & 31`) |
| r6 | Byte address of target word in DMEM |
| r7 | Current word loaded from DMEM |
| r8 | Bitmask (`1 << bit_idx`) |
| r9 | Scratch result for OR/AND |
| r10 | MMIO base address (`0xFFFFFF00`) |
| r11 | Scratch / bounds-check result |
| r12–r15 | right, left, up, down (latched from MMIO) |
| r16–r18 | draw, erase, game_reset (latched from MMIO) |
| r19 | Framebuffer base address (`0x200`) |
| r20 | Shift amount scratch |

### Program Flow

```
INIT:
  r10 ← 0xFFFFFF00   (MMIO base via lui+ori)
  r1  ← 64           (start X = center)
  r2  ← 32           (start Y = center)
  r19 ← 0x200        (FB base)

LOOP:
  Latch r12–r18 from MMIO (lw from r10+0..+6)

  if game_reset: j INIT

  RIGHT:  if r12≠0 and r1<127: r1++
  LEFT:   if r13≠0 and r1>0:   r1--
  UP:     if r14≠0 and r2<63:  r2++
  DOWN:   if r15≠0 and r2>0:   r2--

  Compute FB address:
    flat     = (r2 << 7) | r1        (sllv + add)
    word_idx = flat >> 5             (srlv)
    bit_idx  = flat & 0x1F          (andi)
    word_addr= r19 + word_idx*4     (sllv + add)

  lw r7, 0(word_addr)               (load current word)
  r8 = 1 << bit_idx                 (sllv)

  DRAW:  if r16≠0: r9 = r7 | r8;  sw r9
  ERASE: if r17≠0: r8 = ~r8 (via nor); r9 = r7 & r8; sw r9

  j LOOP
```

The shift-multiply `Y*128` is implemented as `sllv r3, r2, 7` — a pure shift, no multiplier needed.

Bounds checking uses `slti` (set-less-than-immediate) before increment, and `beq rX, r0` for zero-check before decrement, each preceded by 3 NOPs per the hazard convention.

---

## Memory & Framebuffer

`memory.v` is a byte-addressed 1 KB data memory with two distinct regions:

### Memory Map

| Address Range | Contents |
|---------------|----------|
| `0x000–0x1FF` | General data (512 B) |
| `0x200–0x5FF` | Bit-packed pixel framebuffer (1024 B = 8192 bits = 128×64 pixels) |

### Pixel Addressing

```
flat     = Y * 128 + X          (Y in [0,63], X in [0,127])
word_addr = 0x200 + (flat >> 5) * 4
bit       = flat & 31           (LSB = pixel with lowest flat index)
```

### MMIO

Addresses with `address[31:8] == 24'hFFFFFF` are MMIO. A read returns `{32{memMappedIO[address[7:0]]}}` — a single bit from the IO bus, sign/zero-extended to 32 bits. This allows the processor to use `lw` instructions to read button and joystick state as 0 or 0xFFFFFFFF (which is non-zero for branch comparison).

### Framebuffer Output

A combinational `always @(*)` block assembles the 8192-bit `framebuffer` output wire by concatenating packed words from the byte array, starting at word 0 (address 0x000), covering all 256 words. The SPI driver reads from this flat wire continuously.

> **Note:** The framebuffer region starts at `0x200` in DMEM, but the `framebuffer` output wire maps from word 0. The painter program accounts for this by using `r19 = 0x200` as the base address for all framebuffer word accesses.

---

## Peripheral & Helper Modules

### analogTranslator

`analogTranslator.v` is a pure combinational decoder. It takes the 4 raw comparator outputs from the potentiometer joystick and maps them to `right`, `left`, `up`, `down` direction signals using simple wire assignments and inversions. There is no state; it is purely structural glue between the analog front-end and the movement pipeline.

### movementDivider

`movementDivider.v` solves a critical problem: the processor loop runs at ~62.5 MHz, completing one scan in roughly 1.5 µs. Without throttling, the cursor would move at ~666,000 pixels/second — unusable.

The module applies **PWM-style rate limiting**: it asserts the direction outputs only during the first `PULSE_WIDTH = 100` clock cycles of every `divider`-cycle window, where `divider` is looked up from a 15-entry table based on a `speed` register (1–15). At the default fastest speed (`speed = 15`), `divider = 666,666`, giving approximately 4–10 cursor pixels per second.

Speed is adjustable at runtime via two debounced pushbuttons (`speedInc`, `speedDec`). A 20-bit debounce counter filters each button. The current speed level is output as a 4-bit value (`speedOut`) intended to drive the FPGA's onboard LEDs for visual feedback.

The module takes a `SIM_MODE` parameter that scales all divider and debounce constants down by 100× for fast simulation without waiting millions of cycles.

### crosshair

`crosshair.v` generates a separate 8192-bit framebuffer containing only the cursor graphic, which is OR'd with the pixel framebuffer in `parent.v` before being sent to the SPI driver.

The cursor is a **5×5 square crosshair** with three layers:
- Center: 1 solid pixel at `(X, Y)`
- Middle ring: 1-pixel-thick blank border
- Outer ring: 1-pixel-thick solid border

This produces a total of 17 pixels to set (the 5×5 grid minus the 4 interior non-center pixels, minus the blank ring). Rather than using a combinational multiplier to compute `flat = py*128 + px`, the module uses a sequential FSM: it clears the entire 8192-bit register in step 0, then sets one pixel per clock cycle for steps 1–17, using pre-computed `(ox, oy)` offsets decoded by a pure case-mux. The multiplication `py*128` is implemented as `{py, 7'b0}` — zero-cost wiring. Total latency: 18 clock cycles at 125 MHz = 144 ns.

The FSM restarts automatically whenever `X` or `Y` changes, ensuring the crosshair always tracks the current cursor position with negligible lag.

### SPI Driver

`spi.v` implements a full SSD1306 OLED controller with two concurrent processes:

**SPI Shift Engine:** A dedicated always block clocks out 8-bit bytes MSB-first at `CLK_DIV`-divided rate (~7.8 MHz SPI clock from 62.5 MHz input). It signals `spi_busy` while transmitting and pulses `spi_done` on completion.

**Control FSM:** An 8-state FSM drives `cs`, `dc`, and `res`, and feeds bytes to the shift engine:

| State | Action |
|-------|--------|
| `S_RESET` | Assert reset low, wait `RESET_TICKS` |
| `S_RESET_WAIT` | De-assert reset, wait `RESET_TICKS` |
| `S_INIT` | Send 23-byte init sequence (display on, contrast, scan direction, etc.) |
| `S_PAGE_CMD0/1/2` | Send page address set commands (`0xB0|page`, `0x00`, `0x10`) |
| `S_DATA` | Stream 128 data bytes for the current page |
| `S_PAGE_END` | Deassert CS, advance to next page (0–7), loop |

The `page_byte` function assembles one display byte by collecting 8 vertical pixels from the flat framebuffer: for page `p`, column `c`, it reads `fb[p*1024 + row*128 + c]` for rows 0–7. This is purely combinational bit-indexing into the 8192-bit wire.

The FSM and shift engine are intentionally decoupled: the FSM never touches `sck`/`sda`, and the shift engine never touches `cs`/`dc`/`res`. The FSM sets `dc` before asserting `spi_load` to guarantee dc is stable at the first SCK edge.

### segmentDisplayDecoder

`segmentDisplayDecoder.v` drives two 7-segment display digits to show either the X coordinate (0–127) or Y coordinate (0–63) of the current cursor position, selected by a switch (`sw`). A third output `half_digit` goes high when displaying X ≥ 100 to indicate the hundreds digit (always 1). BCD decomposition is done with integer divide and modulo in a combinational block; a `bcd_to_seg` function maps each digit to the standard 7-segment encoding.

---

## Top-Level Integration (parent.v)

`parent.v` wires all subsystems together:

```
clock (125 MHz)
   └─► TFF ──► t_ff_clk (62.5 MHz)
                  ├─► movementDivider
                  ├─► pipeline (MIPS processor)
                  └─► SPI driver

clock (125 MHz)
   └─► crosshair (runs at full rate for fast FB update)

analogTranslator ──► movementDivider ──► memMappedIO[6:0]
pushbuttons ──────────────────────────► memMappedIO[6:4]

pipeline.framebuffer [8191:0]  ──┐
crosshair.crosshairFB [8191:0] ──┴─ OR ──► spi.fb

pipeline.r1, r2 ──► segmentDisplayDecoder
pipeline.r1, r2 ──► crosshair (X, Y)
```

The `memMappedIO` bus is assembled as:
```verilog
{249'b0, gameRst, erase, draw, down, up, left, right}
//        [6]     [5]   [4]  [3]  [2]  [1]   [0]
```
mapped to MMIO addresses 0–6, read by the painter program via `lw r1x, N(r10)`.

`parent1_d.v` is a variant without the TFF (direct clock) and with the SPI driver commented out, used for display-less simulation and debugging.

---

## File Index

| File | Description |
|------|-------------|
| `parent.v` | Top-level: integrates all subsystems, TFF clock divider |
| `parent1_d.v` | Debug variant: no TFF, no SPI |
| `pipeline.v` | Full 5-stage MIPS pipeline datapath |
| `instructionMem.v` | Instruction ROM with hardcoded painter program |
| `memory.v` | Data memory with MMIO and framebuffer output |
| `pc.v` | Program counter with stall support |
| `if_id.v` | IF/ID pipeline register |
| `id_ex.v` | ID/EX pipeline register with stall/flush |
| `ex_mem.v` | EX/MEM pipeline register with flush |
| `mem_wb.v` | MEM/WB pipeline register |
| `mainControl.v` | Main control unit (opcode → control signals) |
| `aluControl.v` | ALU control (aluOp + funct → 4-bit op) |
| `alu6.v` | 16-operation ALU |
| `regFile.v` | 32×32 register file with forwarding read port |
| `forwardingUnit.v` | Data forwarding mux selects |
| `hazardDetectionUnit.v` | Load-use hazard detection and stall |
| `signExtend.v` | 16→32 sign extension |
| `zeroExtend.v` | 16→32 zero extension |
| `sext_or_zext_control.v` | Selects sign vs zero extension by aluOp |
| `shiftLeft2.v` | Left-shift-by-2 for branch target |
| `adder.v` | Parameterized adder |
| `mux2.v` | Parameterized 2:1 mux |
| `mux4.v` | Parameterized 4:1 mux |
| `jTypeAddressProcessor.v` | J-type jump address assembly |
| `jrControl.v` | JR instruction detection |
| `analogTranslator.v` | Joystick comparator → direction signals |
| `movementDivider.v` | Cursor speed control with debounce |
| `crosshair.v` | Sequential crosshair framebuffer renderer |
| `spi.v` | SSD1306 SPI driver with FSM |
| `segmentDisplayDecoder.v` | X/Y coordinate 7-segment display |
| `tff.v` | T flip-flop (÷2 clock divider) |