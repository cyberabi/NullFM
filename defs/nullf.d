
NULLF.D       SET       1

********************************************************************
* NULLF.d - Null File Manager Definitions
*
* $Id$
*
* NULLF stands for 'Null Filemanager' and is a package of subroutines
* that define the logical structure of a generic device that controls
* a shared resource such as a SPI bus or a Flash memory bank.
*
* The data structures in this file give NULLF its 'personality' and are
* used by NullFM itself, as well as by other drivers that share the
* associated device resources.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2019/10/23  Chris Burke
* Coded using SCF.d as a strarting point.

               NAM       NULLF.d
               TTL       Null File Manager Definitions

               PAG       
*******************************
* Things that should be in os9defs
*
DT.NULL        SET       5                   Null Manager device type

               ORG       FMCLOSE
               RMB       3
FMDRCT         RMB       3                   Entry point in NullFM to make direct call to device driver

               ORG       D$TERM
               RMB       3
D$DRCT         RMB       3                   Entry point in device driver for direct calls

               ORG       E$IllArg
E$Param        RMB       1                   Alias for OSK error code used in DAVID NullFM docs


               PAG       
*******************************
* NullFM device classes
*
NDC.SPI        SET       0                   Serial Peripheral Interface (SPI) device class
NDC.FLASH      SET       0                   Flash device class


               PAG       
*******************************
* NullFM Device Descriptor Offsets
*
* These definitions are for NullFM device descriptors.
*
               ORG       M$DTyp
IT.NDVT        RMB       1                   Device type (DT.NULL)
IT.NDVC        RMB       1                   Device class (NDC.SPI, NDC.FLASH)
IT.ACMD        RMB       1                   Access mode (READ., WRITE., SHARE.)
IT.MPAK        RMB       1                   MultiPak slot number
IT.CCNT        RMB       1                   (SPI) Number of config blocks to allocate (0..127)
IT.SCTN        RMB       2                   (FLASH) Number of Flash Sectors
IT.SCTSZ       RMB       2                   (FLASH) Size of a Flash Sector (e.g. 4096)
IT.BLKSZ       RMB       2                   (FLASH) Size of a Flash programmable block (e.g. 256)


               PAG       
********************
* NULLF Device Static Storage
*
* NULLF devices must reserve this space for NULLF
*
               ORG       V.USER
V.NCLASS       RMB       1                   Device class
V.MAXSLV       RMB       1                   Max # slaves (allocates this + 1 config blocks; extra is us as slave) (SPI)
V.NMEM         RMB       2                   Pointer to memory allocated for device's config blocks (SPI)
V.NMSZ         RMB       2                   Size of memory allocated for device's config blocks (SPI)
V.NFREE        RMB       2                   Pointer to free list of device config blocks (SPI)
V.NRSV         RMB       8                   Reserve bytes for future expansion
V.NULLF        EQU       .                   Total Null manager static overhead


               PAG       
*********************************************
* Null Path Descriptor Format
*
* A path descriptor is created for every new path that is open
* via the I$Open system call (processed by IOMan).  Process
* descriptors track state iNULLFormation of a path.
*
               ORG       PD.FST
PD.PBLK        RMB       NPB.SIZ             Space for a driver parameter block (20 bytes)
               ORG       PD.OPT
               RMB       1                   Device type
PD.ACMD        RMB       1                   Access mode (READ., WRITE., SHARE.)
PD.CLKM        RMB       1                   SPI Clock Mode (0..3)
PD.SCSN        RMB       1                   SPI Select Number (1..255)
PD.SCTN        RMB       2                   Number of Flash Sectors
PD.SCTSZ       RMB       2                   Size of a Flash Sector (e.g. 4096)
PB.BLKSZ       RMB       2                   Size of a Flash programmable block (e.g. 256)
NOPTCNT        EQU       .-PD.OPT            Total user readable options
PD.ERR         RMB       1                   Most recent I/O error status
PD.TBL         RMB       2                   Device table addr (copy)
PD.PLP         RMB       2                   Path Descriptor List Pointer


               PAG       
*********************************************
* Null Driver Parameter Block format
*
* Direct calls to a NullFM device vector through
* NullFM and use a Parameter Block instead of a
* Path Descriptor.
*
* The Parameter Block resembles a Path Descriptor
* but can be distinguished from it by the PB.MAGIC
* value, which is a combination of PD.PD and PD.MOD
* (values at the same spot in a Path Descriptor)
* that can never occur.
*
* Parameter Blocks can be stored in a linked list
* of pending operations to resolve bus contention,
* and include callback pointers, parameters, etc.
*
* Generally, NPB.RGV+R$B will contain a function code
* and the rest of the buffer will contain parameters
*

V$NMAGIC       SET       $FFFF

               ORG       0
NPB.DEV        RMB       2                   Device Table Entry Address
NPB.RGV        RMB       (R$Size-2)          Register / Parameter package (no PC) e.g. NPB.RGV+R$X for X
NPB.PARM0      RMB       2                   Additional 16-bit parameter, typically a pointer
NPB.PARM1      RMB       2                   Additional 16-bit parameter, typically a pointer
NPB.FMST       RMB       2                   FM / Driver use: Pointer to registered configuration
NPB.PBP        RMB       2                   Pointer to next parameter block in wait list, or $0000
NPB.SIZ        EQU       .

NPB.ERR        EQU       (NBP.RGV+R$CC)      CC is not stored; instead, result of the call; 0 = OK, non-zero = error code
NBP.FUNC       EQU       (NBP.RGV+R$DP)      DP is not stored; instead, store the function code (e.g. SPI.TDT) here
NBP.HNDL       EQU       (NBP.RGV+R$A)       SPI specific: A is the "handle" for a registered confifuration

NBP.D          EQU       (NBP.RGV+R$D)       "D" register parameter block contents
NBP.B          EQU       (NBP.RGV+R$B)       "B" register parameter block contents
NBP.U          EQU       (NBP.RGV+R$U)       "U" register parameter block contents


               PAG        
*********************************************
* Device class function codes
*
               ORG       $00
* Common function codes

               ORG       $10
* SPI class function codes
SPI.DD         RMB       1                   Deregister a Device
SPI.ESM        RMB       1                   Enter Slave Mode
SPI.XSM        RMB       1                   Exit Slave Mode
SPI.RDTC       RMB       1                   Register Data Transfer Configuration
SPI.TDT        RMB       1                   Transfer Data to and from the Target

               ORG       $20
* FLASH class codes

FLA.DSIZE      RMB       1                   Retrieve Number of Sectors and Current Sector SizeFLA.GSPOS      RMB       1                   Retrieve the Current Path PositionFLA.SSPOS      RMB       1                   Establish the Current Path Position


               PAG        
*********************************************
* Registered configuration data structure
* NOTE: NullFM assumes this is exactly 16 bytes
* NOTE: Keep CLKR and CLKA together in this order
* NOTE: Keep DATR and SEL together in this order
*
               ORG       $00
NRC.HNDL       RMB       1                   Handle for this config block
NRC.CLKR       RMB       1                   Clock rate for slave device (1=High, 0=Low)NRC.CLKA       RMB       1                   +Clock attributes for slave device (Mode 0..3)
NRC.DATR       RMB       1                   Attributes for slave device data transfer (RW)NRC.SEL        RMB       1                   +SPI select number (0..127) (6809 specific)
NRC.PRIO       RMB       1                   Priority for slave device data transfer (Unused, queuing)
NRC.ENAF       RMB       2                   Pointer to slave_enable() callback function in the higher-level driver.NRC.DISF       RMB       2                   Pointer to slave_disable() callback function in the higher-level driver.NRC.ENAP       RMB       2                   Pointer parameter to be passed to slave_enable() callback function.NRC.DISP       RMB       2                   Pointer parameter to be passed to slave_disable() callback function.NRC.LINK       RMB       2                   Linked list pointer for free list of configs.NRC.SIZ        EQU       .

NRC$INVAL      EQU       $80                 Set this bit to mark a config data structure as invalid