/*
 * Patched copy of SSDT1 ("DptfTabl", OEM revision 0x1000) from the MSI Vector 16 HX A14VHG,
 * BIOS E15M1IMS.915 / EC 15M1IMS2.112, decompiled with iasl 20260930.
 *
 * MSI bug: _QC2 creates DBA8 at byte 8 of the 6-byte buffer DBAW. That fails with
 * AE_AML_BUFFER_LIMIT, aborting _QC2 before it updates \_SB.NPCF, so the GPU stays
 * at its 60 W base limit. See https://github.com/BeardOverflow/msi-ec/issues/352
 *
 * Changes from the original (nothing else):
 *   - DBAW is 9 bytes instead of 6 (DBA8 is never read; the padding value is irrelevant)
 *   - OEM revision 0x1000 -> 0x1001, so the kernel accepts the override
 */
/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260930 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of SSDT1
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00004668 (18024)
 *     Revision         0x02
 *     Checksum         0xDF
 *     OEM ID           "DptfTb"
 *     OEM Table ID     "DptfTabl"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200717 (538969879)
 */
DefinitionBlock ("", "SSDT", 2, "DptfTb", "DptfTabl", 0x00001001)
{
    External (_SB_.AAC0, FieldUnitObj)
    External (_SB_.ACRT, FieldUnitObj)
    External (_SB_.APSV, FieldUnitObj)
    External (_SB_.CBMI, FieldUnitObj)
    External (_SB_.CFGD, FieldUnitObj)
    External (_SB_.CLVL, FieldUnitObj)
    External (_SB_.CPID, UnknownObj)
    External (_SB_.CPPC, FieldUnitObj)
    External (_SB_.CTC0, FieldUnitObj)
    External (_SB_.CTC1, FieldUnitObj)
    External (_SB_.CTC2, FieldUnitObj)
    External (_SB_.NPCF, DeviceObj)
    External (_SB_.NPCF.ACBT, IntObj)
    External (_SB_.NPCF.AMAT, IntObj)
    External (_SB_.NPCF.AMIT, IntObj)
    External (_SB_.NPCF.ATPP, IntObj)
    External (_SB_.NPCF.DBAC, IntObj)
    External (_SB_.OSCP, IntObj)
    External (_SB_.PAGD, DeviceObj)
    External (_SB_.PAGD._PUR, PkgObj)
    External (_SB_.PAGD._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00, DeviceObj)
    External (_SB_.PC00.LPCB.EC__, DeviceObj)
    External (_SB_.PC00.LPCB.EC__.CMD1, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.DAT1, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.DTDR, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.DTOK, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.MYEC, IntObj)
    External (_SB_.PC00.LPCB.EC__.PATM, UnknownObj)
    External (_SB_.PC00.LPCB.EC__.SCIC, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.SEN2, DeviceObj)
    External (_SB_.PC00.LPCB.EC__.SEN3, DeviceObj)
    External (_SB_.PC00.LPCB.EC__.SEN4, DeviceObj)
    External (_SB_.PC00.LPCB.EC__.SILE, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.SYSM, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.SYST, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TSIT, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TSL2, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TST2, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TSTL, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TSTU, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.TSU2, FieldUnitObj)
    External (_SB_.PC00.LPCB.EC__.WATO, MethodObj)    // 0 Arguments
    External (_SB_.PC00.LPCB.EC__.WCEC, MethodObj)    // 1 Arguments
    External (_SB_.PC00.MC__.MHBR, FieldUnitObj)
    External (_SB_.PC00.PEG1.PEGP, UnknownObj)
    External (_SB_.PC00.PEG1.PEGP.NLIM, UnknownObj)
    External (_SB_.PC00.PEG1.PEGP.STGU, UnknownObj)
    External (_SB_.PC00.TCPU, DeviceObj)
    External (_SB_.PL10, FieldUnitObj)
    External (_SB_.PL11, FieldUnitObj)
    External (_SB_.PL12, FieldUnitObj)
    External (_SB_.PL20, FieldUnitObj)
    External (_SB_.PL21, FieldUnitObj)
    External (_SB_.PL22, FieldUnitObj)
    External (_SB_.PLW0, FieldUnitObj)
    External (_SB_.PLW1, FieldUnitObj)
    External (_SB_.PLW2, FieldUnitObj)
    External (_SB_.PR00, ProcessorObj)
    External (_SB_.PR00._PSS, MethodObj)    // 0 Arguments
    External (_SB_.PR00._TPC, IntObj)
    External (_SB_.PR00._TSD, MethodObj)    // 0 Arguments
    External (_SB_.PR00._TSS, MethodObj)    // 0 Arguments
    External (_SB_.PR00.LPSS, PkgObj)
    External (_SB_.PR00.TPSS, PkgObj)
    External (_SB_.PR00.TSMC, PkgObj)
    External (_SB_.PR00.TSMF, PkgObj)
    External (_SB_.PR01, ProcessorObj)
    External (_SB_.PR02, ProcessorObj)
    External (_SB_.PR03, ProcessorObj)
    External (_SB_.PR04, ProcessorObj)
    External (_SB_.PR05, ProcessorObj)
    External (_SB_.PR06, ProcessorObj)
    External (_SB_.PR07, ProcessorObj)
    External (_SB_.PR08, ProcessorObj)
    External (_SB_.PR09, ProcessorObj)
    External (_SB_.PR10, ProcessorObj)
    External (_SB_.PR11, ProcessorObj)
    External (_SB_.PR12, ProcessorObj)
    External (_SB_.PR13, ProcessorObj)
    External (_SB_.PR14, ProcessorObj)
    External (_SB_.PR15, ProcessorObj)
    External (_SB_.PR16, ProcessorObj)
    External (_SB_.PR17, ProcessorObj)
    External (_SB_.PR18, ProcessorObj)
    External (_SB_.PR19, ProcessorObj)
    External (_SB_.PR20, ProcessorObj)
    External (_SB_.PR21, ProcessorObj)
    External (_SB_.PR22, ProcessorObj)
    External (_SB_.PR23, ProcessorObj)
    External (_SB_.PR24, ProcessorObj)
    External (_SB_.PR25, ProcessorObj)
    External (_SB_.PR26, ProcessorObj)
    External (_SB_.PR27, ProcessorObj)
    External (_SB_.PR28, ProcessorObj)
    External (_SB_.PR29, ProcessorObj)
    External (_SB_.PR30, ProcessorObj)
    External (_SB_.PR31, ProcessorObj)
    External (_SB_.SLPB, DeviceObj)
    External (_SB_.TAR0, FieldUnitObj)
    External (_SB_.TAR1, FieldUnitObj)
    External (_SB_.TAR2, FieldUnitObj)
    External (_TZ_.ETMD, IntObj)
    External (_TZ_.TZ00, ThermalZoneObj)
    External (ACTT, IntObj)
    External (ATPC, IntObj)
    External (BATR, IntObj)
    External (CHGE, IntObj)
    External (CRTT, IntObj)
    External (DAT1, IntObj)
    External (DCFE, IntObj)
    External (DPTF, IntObj)
    External (ECON, IntObj)
    External (FND1, IntObj)
    External (FND2, IntObj)
    External (FND3, IntObj)
    External (GPUD, UnknownObj)
    External (HIDW, MethodObj)    // 4 Arguments
    External (HIWC, MethodObj)    // 1 Arguments
    External (IN34, IntObj)
    External (IPCS, MethodObj)    // 7 Arguments
    External (ODV0, IntObj)
    External (ODV1, IntObj)
    External (ODV2, IntObj)
    External (ODV3, IntObj)
    External (ODV4, IntObj)
    External (ODV5, IntObj)
    External (P8XH, MethodObj)    // 2 Arguments
    External (PCHE, FieldUnitObj)
    External (PF00, IntObj)
    External (PLID, IntObj)
    External (PNHM, IntObj)
    External (PPPR, IntObj)
    External (PPSZ, IntObj)
    External (PSVT, IntObj)
    External (PTPC, IntObj)
    External (PWRE, IntObj)
    External (PWRS, IntObj)
    External (S1DE, IntObj)
    External (S2DE, IntObj)
    External (S3DE, IntObj)
    External (S4DE, IntObj)
    External (S5DE, IntObj)
    External (S6DE, IntObj)
    External (S6P2, IntObj)
    External (SADE, IntObj)
    External (SSP1, IntObj)
    External (SSP2, IntObj)
    External (SSP3, IntObj)
    External (SSP4, IntObj)
    External (SSP5, IntObj)
    External (TCNT, IntObj)
    External (TSOD, IntObj)

    Scope (\_SB)
    {
        Device (IETM)
        {
            Method (GCID, 0, Serialized)
            {
                Switch ((\_SB.CPID & 0x0FFF0FF0))
                {
                    Case (0x000B0670)
                    {
                        Return (Zero)
                    }
                    Case (0x000B06A0)
                    {
                        Return (Zero)
                    }
                    Case (0x000B06F0)
                    {
                        Return (Zero)
                    }
                    Default
                    {
                        Return (One)
                    }

                }
            }

            Method (GHID, 1, Serialized)
            {
                Local0 = \_SB.IETM.GCID ()
                If ((Zero == Local0))
                {
                    If ((Arg0 == "IETM"))
                    {
                        Return ("INTC10A0")
                    }

                    If ((Arg0 == "SEN1"))
                    {
                        Return ("INTC10A1")
                    }

                    If ((Arg0 == "SEN2"))
                    {
                        Return ("INTC10A1")
                    }

                    If ((Arg0 == "SEN3"))
                    {
                        Return ("INTC10A1")
                    }

                    If ((Arg0 == "SEN4"))
                    {
                        Return ("INTC10A1")
                    }

                    If ((Arg0 == "SEN5"))
                    {
                        Return ("INTC10A1")
                    }

                    If ((Arg0 == "TPCH"))
                    {
                        Return ("INTC10A3")
                    }

                    If ((Arg0 == "TFN1"))
                    {
                        Return ("INTC10A2")
                    }

                    If ((Arg0 == "TFN2"))
                    {
                        Return ("INTC10A2")
                    }

                    If ((Arg0 == "TFN3"))
                    {
                        Return ("INTC10A2")
                    }

                    If ((Arg0 == "TPWR"))
                    {
                        Return ("INTC10A4")
                    }

                    If ((Arg0 == "1"))
                    {
                        Return ("INTC10A5")
                    }

                    If ((Arg0 == "CHRG"))
                    {
                        Return ("INTC10A1")
                    }

                    Return ("XXXX9999")
                }
                Else
                {
                    If ((Arg0 == "IETM"))
                    {
                        Return ("INTC1041")
                    }

                    If ((Arg0 == "SEN1"))
                    {
                        Return ("INTC1046")
                    }

                    If ((Arg0 == "SEN2"))
                    {
                        Return ("INTC1046")
                    }

                    If ((Arg0 == "SEN3"))
                    {
                        Return ("INTC1046")
                    }

                    If ((Arg0 == "SEN4"))
                    {
                        Return ("INTC1046")
                    }

                    If ((Arg0 == "SEN5"))
                    {
                        Return ("INTC1046")
                    }

                    If ((Arg0 == "TPCH"))
                    {
                        Return ("INTC1049")
                    }

                    If ((Arg0 == "TFN1"))
                    {
                        Return ("INTC1048")
                    }

                    If ((Arg0 == "TFN2"))
                    {
                        Return ("INTC1048")
                    }

                    If ((Arg0 == "TFN3"))
                    {
                        Return ("INTC1048")
                    }

                    If ((Arg0 == "TPWR"))
                    {
                        Return ("INTC1060")
                    }

                    If ((Arg0 == "1"))
                    {
                        Return ("INTC1061")
                    }

                    If ((Arg0 == "CHRG"))
                    {
                        Return ("INTC1046")
                    }

                    Return ("XXXX9999")
                }
            }

            Name (_UID, "IETM")  // _UID: Unique ID
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return (\_SB.IETM.GHID (_UID))
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If (CondRefOf (HIWC))
                {
                    If (HIWC (Arg0))
                    {
                        If (CondRefOf (HIDW))
                        {
                            Return (HIDW (Arg0, Arg1, Arg2, Arg3))
                        }
                    }
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((\DPTF == One) && (\IN34 == One)))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Name (PTRP, Zero)
            Name (PSEM, Zero)
            Name (ATRP, Zero)
            Name (ASEM, Zero)
            Name (YTRP, Zero)
            Name (YSEM, Zero)
            Method (_OSC, 4, Serialized)  // _OSC: Operating System Capabilities
            {
                CreateDWordField (Arg3, Zero, STS1)
                CreateDWordField (Arg3, 0x04, CAP1)
                If ((Arg1 != One))
                {
                    STS1 &= 0xFFFFFF00
                    STS1 |= 0x0A
                    Return (Arg3)
                }

                If ((Arg2 != 0x02))
                {
                    STS1 &= 0xFFFFFF00
                    STS1 |= 0x02
                    Return (Arg3)
                }

                If (CondRefOf (\_SB.APSV))
                {
                    If ((PSEM == Zero))
                    {
                        PSEM = One
                        PTRP = \_SB.APSV /* External reference */
                    }
                }

                If (CondRefOf (\_SB.AAC0))
                {
                    If ((ASEM == Zero))
                    {
                        ASEM = One
                        ATRP = \_SB.AAC0 /* External reference */
                    }
                }

                If (CondRefOf (\_SB.ACRT))
                {
                    If ((YSEM == Zero))
                    {
                        YSEM = One
                        YTRP = \_SB.ACRT /* External reference */
                    }
                }

                If ((Arg0 == ToUUID ("b23ba85d-c8b7-3542-88de-8de2ffcfd698") /* Unknown UUID */))
                {
                    If (~(STS1 & One))
                    {
                        If (\_SB.PC00.LPCB.EC.MYEC)
                        {
                            \_SB.PC00.LPCB.EC.DTDR = One
                            \_SB.PC00.LPCB.EC.DTOK = One
                        }

                        If ((CAP1 & One))
                        {
                            If ((CAP1 & 0x02))
                            {
                                \_SB.AAC0 = 0x6E
                                \_TZ.ETMD = Zero
                            }
                            Else
                            {
                                \_SB.AAC0 = ATRP /* \_SB_.IETM.ATRP */
                                \_TZ.ETMD = One
                            }

                            If ((CAP1 & 0x04))
                            {
                                \_SB.APSV = 0x6E
                            }
                            Else
                            {
                                \_SB.APSV = PTRP /* \_SB_.IETM.PTRP */
                            }

                            If ((CAP1 & 0x08))
                            {
                                \_SB.ACRT = 0xD2
                            }
                            Else
                            {
                                \_SB.ACRT = YTRP /* \_SB_.IETM.YTRP */
                            }

                            If (CondRefOf (\_TZ.TZ00))
                            {
                                Notify (\_TZ.TZ00, 0x81) // Information Change
                            }
                        }
                        Else
                        {
                            \_SB.ACRT = YTRP /* \_SB_.IETM.YTRP */
                            \_SB.APSV = PTRP /* \_SB_.IETM.PTRP */
                            \_SB.AAC0 = ATRP /* \_SB_.IETM.ATRP */
                            \_TZ.ETMD = One
                        }

                        If (CondRefOf (\_TZ.TZ00))
                        {
                            Notify (\_TZ.TZ00, 0x81) // Information Change
                        }
                    }

                    Return (Arg3)
                }

                Return (Arg3)
            }

            Method (DCFG, 0, NotSerialized)
            {
                Return (\DCFE) /* External reference */
            }

            Name (ODVX, Package (0x06)
            {
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero
            })
            Method (ODVP, 0, Serialized)
            {
                ODVX [Zero] = \ODV0 /* External reference */
                ODVX [One] = \ODV1 /* External reference */
                ODVX [0x02] = \ODV2 /* External reference */
                ODVX [0x03] = \ODV3 /* External reference */
                ODVX [0x04] = \ODV4 /* External reference */
                ODVX [0x05] = \ODV5 /* External reference */
                Return (ODVX) /* \_SB_.IETM.ODVX */
            }
        }
    }

    Scope (\_SB.IETM)
    {
        Method (KTOC, 1, Serialized)
        {
            If ((Arg0 > 0x0AAC))
            {
                Return (((Arg0 - 0x0AAC) / 0x0A))
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (CTOK, 1, Serialized)
        {
            Return (((Arg0 * 0x0A) + 0x0AAC))
        }

        Method (C10K, 1, Serialized)
        {
            Name (TMP1, Buffer (0x10)
            {
                 0x00                                             // .
            })
            CreateByteField (TMP1, Zero, TMPL)
            CreateByteField (TMP1, One, TMPH)
            Local0 = (Arg0 + 0x0AAC)
            TMPL = (Local0 & 0xFF)
            TMPH = ((Local0 & 0xFF00) >> 0x08)
            ToInteger (TMP1, Local1)
            Return (Local1)
        }

        Method (K10C, 1, Serialized)
        {
            If ((Arg0 > 0x0AAC))
            {
                Return ((Arg0 - 0x0AAC))
            }
            Else
            {
                Return (Zero)
            }
        }
    }

    Scope (\_SB.PC00.TCPU)
    {
        Name (PFLG, Zero)
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((\SADE == One))
            {
                Return (0x0F)
            }
            Else
            {
                Return (Zero)
            }
        }

        OperationRegion (CPWR, SystemMemory, ((\_SB.PC00.MC.MHBR << 0x0F) + 0x5000), 0x1000)
        Field (CPWR, ByteAcc, NoLock, Preserve)
        {
            Offset (0x930), 
            PTDP,   15, 
            Offset (0x932), 
            PMIN,   15, 
            Offset (0x934), 
            PMAX,   15, 
            Offset (0x936), 
            TMAX,   7, 
            Offset (0x938), 
            PWRU,   4, 
            Offset (0x939), 
            EGYU,   5, 
            Offset (0x93A), 
            TIMU,   4, 
            Offset (0x958), 
            Offset (0x95C), 
            LPMS,   1, 
            CTNL,   2, 
            Offset (0x978), 
            PCTP,   8, 
            Offset (0x998), 
            RP0C,   8, 
            RP1C,   8, 
            RPNC,   8, 
            Offset (0xF3C), 
            TRAT,   8, 
            Offset (0xF40), 
            PTD1,   15, 
            Offset (0xF42), 
            TRA1,   8, 
            Offset (0xF44), 
            PMX1,   15, 
            Offset (0xF46), 
            PMN1,   15, 
            Offset (0xF48), 
            PTD2,   15, 
            Offset (0xF4A), 
            TRA2,   8, 
            Offset (0xF4C), 
            PMX2,   15, 
            Offset (0xF4E), 
            PMN2,   15, 
            Offset (0xF50), 
            CTCL,   2, 
                ,   29, 
            CLCK,   1, 
            MNTR,   8
        }

        Name (XPCC, Zero)
        Method (PPCC, 0, Serialized)
        {
            If (((XPCC == Zero) && CondRefOf (\_SB.CBMI)))
            {
                Switch (ToInteger (\_SB.CBMI))
                {
                    Case (Zero)
                    {
                        If (((\_SB.CLVL >= One) && (\_SB.CLVL <= 0x03)))
                        {
                            CPL0 ()
                            XPCC = One
                        }
                    }
                    Case (One)
                    {
                        If (((\_SB.CLVL == 0x02) || (\_SB.CLVL == 0x03)))
                        {
                            CPL1 ()
                            XPCC = One
                        }
                    }
                    Case (0x02)
                    {
                        If ((\_SB.CLVL == 0x03))
                        {
                            CPL2 ()
                            XPCC = One
                        }
                    }

                }
            }

            Return (NPCC) /* \_SB_.PC00.TCPU.NPCC */
        }

        Name (NPCC, Package (0x03)
        {
            0x02, 
            Package (0x06)
            {
                Zero, 
                0x88B8, 
                0xAFC8, 
                0x6D60, 
                0x7D00, 
                0x03E8
            }, 

            Package (0x06)
            {
                One, 
                0xDBBA, 
                0xDBBA, 
                Zero, 
                Zero, 
                0x03E8
            }
        })
        Method (CPNU, 2, Serialized)
        {
            Name (CNVT, Zero)
            Name (PPUU, Zero)
            Name (RMDR, Zero)
            If ((PWRU == Zero))
            {
                PPUU = One
            }
            Else
            {
                PPUU = (PWRU-- << 0x02)
            }

            Divide (Arg0, PPUU, RMDR, CNVT) /* \_SB_.PC00.TCPU.CPNU.CNVT */
            If ((Arg1 == Zero))
            {
                Return (CNVT) /* \_SB_.PC00.TCPU.CPNU.CNVT */
            }
            Else
            {
                CNVT *= 0x03E8
                RMDR *= 0x03E8
                RMDR /= PPUU
                CNVT += RMDR /* \_SB_.PC00.TCPU.CPNU.RMDR */
                Return (CNVT) /* \_SB_.PC00.TCPU.CPNU.CNVT */
            }
        }

        Method (CPL0, 0, NotSerialized)
        {
            \_SB.PC00.TCPU.NPCC [Zero] = 0x02
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [Zero] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [One] = 0x7D
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x02] = CPNU (\_SB.PL10, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x03] = (\_SB.PLW0 * 0x03E8)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x04] = ((\_SB.PLW0 * 0x03E8
                ) + 0x0FA0)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x05] = PPSZ /* External reference */
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [Zero] = One
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [One] = CPNU (\_SB.PL20, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x02] = CPNU (\_SB.PL20, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x03] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x04] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x05] = PPSZ /* External reference */
        }

        Method (CPL1, 0, NotSerialized)
        {
            \_SB.PC00.TCPU.NPCC [Zero] = 0x02
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [Zero] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [One] = 0x7D
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x02] = CPNU (\_SB.PL11, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x03] = (\_SB.PLW1 * 0x03E8)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x04] = ((\_SB.PLW1 * 0x03E8
                ) + 0x0FA0)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x05] = PPSZ /* External reference */
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [Zero] = One
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [One] = CPNU (\_SB.PL21, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x02] = CPNU (\_SB.PL21, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x03] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x04] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x05] = PPSZ /* External reference */
        }

        Method (CPL2, 0, NotSerialized)
        {
            \_SB.PC00.TCPU.NPCC [Zero] = 0x02
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [Zero] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [One] = 0x7D
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x02] = CPNU (\_SB.PL12, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x03] = (\_SB.PLW2 * 0x03E8)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x04] = ((\_SB.PLW2 * 0x03E8
                ) + 0x0FA0)
            DerefOf (\_SB.PC00.TCPU.NPCC [One]) [0x05] = PPSZ /* External reference */
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [Zero] = One
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [One] = CPNU (\_SB.PL22, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x02] = CPNU (\_SB.PL22, One)
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x03] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x04] = Zero
            DerefOf (\_SB.PC00.TCPU.NPCC [0x02]) [0x05] = PPSZ /* External reference */
        }

        Name (LSTM, Zero)
        Name (_PPC, Zero)  // _PPC: Performance Present Capabilities
        Method (SPPC, 1, Serialized)
        {
            If (CondRefOf (\_SB.CPPC))
            {
                \_SB.CPPC = Arg0
            }

            If ((ToInteger (\TCNT) > Zero))
            {
                Notify (\_SB.PR00, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > One))
            {
                Notify (\_SB.PR01, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x02))
            {
                Notify (\_SB.PR02, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x03))
            {
                Notify (\_SB.PR03, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x04))
            {
                Notify (\_SB.PR04, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x05))
            {
                Notify (\_SB.PR05, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x06))
            {
                Notify (\_SB.PR06, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x07))
            {
                Notify (\_SB.PR07, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x08))
            {
                Notify (\_SB.PR08, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x09))
            {
                Notify (\_SB.PR09, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0A))
            {
                Notify (\_SB.PR10, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0B))
            {
                Notify (\_SB.PR11, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0C))
            {
                Notify (\_SB.PR12, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0D))
            {
                Notify (\_SB.PR13, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0E))
            {
                Notify (\_SB.PR14, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x0F))
            {
                Notify (\_SB.PR15, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x10))
            {
                Notify (\_SB.PR16, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x11))
            {
                Notify (\_SB.PR17, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x12))
            {
                Notify (\_SB.PR18, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x13))
            {
                Notify (\_SB.PR19, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x14))
            {
                Notify (\_SB.PR20, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x15))
            {
                Notify (\_SB.PR21, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x16))
            {
                Notify (\_SB.PR22, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x17))
            {
                Notify (\_SB.PR23, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x18))
            {
                Notify (\_SB.PR24, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x19))
            {
                Notify (\_SB.PR25, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1A))
            {
                Notify (\_SB.PR26, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1B))
            {
                Notify (\_SB.PR27, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1C))
            {
                Notify (\_SB.PR28, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1D))
            {
                Notify (\_SB.PR29, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1E))
            {
                Notify (\_SB.PR30, 0x80) // Status Change
            }

            If ((ToInteger (\TCNT) > 0x1F))
            {
                Notify (\_SB.PR31, 0x80) // Status Change
            }
        }

        Method (SPUR, 1, NotSerialized)
        {
            If ((Arg0 <= \TCNT))
            {
                If ((\_SB.PAGD._STA () == 0x0F))
                {
                    \_SB.PAGD._PUR [One] = Arg0
                    Notify (\_SB.PAGD, 0x80) // Status Change
                }
            }
        }

        Method (PCCC, 0, Serialized)
        {
            PCCX [Zero] = One
            Switch (ToInteger (CPNU (PTDP, Zero)))
            {
                Case (0x39)
                {
                    DerefOf (PCCX [One]) [Zero] = 0xA7F8
                    DerefOf (PCCX [One]) [One] = 0x00017318
                }
                Case (0x2F)
                {
                    DerefOf (PCCX [One]) [Zero] = 0x9858
                    DerefOf (PCCX [One]) [One] = 0x00014C08
                }
                Case (0x25)
                {
                    DerefOf (PCCX [One]) [Zero] = 0x7148
                    DerefOf (PCCX [One]) [One] = 0xD6D8
                }
                Case (0x19)
                {
                    DerefOf (PCCX [One]) [Zero] = 0x3E80
                    DerefOf (PCCX [One]) [One] = 0x7D00
                }
                Case (0x0F)
                {
                    DerefOf (PCCX [One]) [Zero] = 0x36B0
                    DerefOf (PCCX [One]) [One] = 0x7D00
                }
                Case (0x0B)
                {
                    DerefOf (PCCX [One]) [Zero] = 0x36B0
                    DerefOf (PCCX [One]) [One] = 0x61A8
                }
                Default
                {
                    DerefOf (PCCX [One]) [Zero] = 0xFF
                    DerefOf (PCCX [One]) [One] = 0xFF
                }

            }

            Return (PCCX) /* \_SB_.PC00.TCPU.PCCX */
        }

        Name (PCCX, Package (0x02)
        {
            0x80000000, 
            Package (0x02)
            {
                0x80000000, 
                0x80000000
            }
        })
        Name (KEFF, Package (0x1E)
        {
            Package (0x02)
            {
                0x01BC, 
                Zero
            }, 

            Package (0x02)
            {
                0x01CF, 
                0x27
            }, 

            Package (0x02)
            {
                0x01E1, 
                0x4B
            }, 

            Package (0x02)
            {
                0x01F3, 
                0x6C
            }, 

            Package (0x02)
            {
                0x0206, 
                0x8B
            }, 

            Package (0x02)
            {
                0x0218, 
                0xA8
            }, 

            Package (0x02)
            {
                0x022A, 
                0xC3
            }, 

            Package (0x02)
            {
                0x023D, 
                0xDD
            }, 

            Package (0x02)
            {
                0x024F, 
                0xF4
            }, 

            Package (0x02)
            {
                0x0261, 
                0x010B
            }, 

            Package (0x02)
            {
                0x0274, 
                0x011F
            }, 

            Package (0x02)
            {
                0x032C, 
                0x01BD
            }, 

            Package (0x02)
            {
                0x03D7, 
                0x0227
            }, 

            Package (0x02)
            {
                0x048B, 
                0x026D
            }, 

            Package (0x02)
            {
                0x053E, 
                0x02A1
            }, 

            Package (0x02)
            {
                0x05F7, 
                0x02C6
            }, 

            Package (0x02)
            {
                0x06A8, 
                0x02E6
            }, 

            Package (0x02)
            {
                0x075D, 
                0x02FF
            }, 

            Package (0x02)
            {
                0x0818, 
                0x0311
            }, 

            Package (0x02)
            {
                0x08CF, 
                0x0322
            }, 

            Package (0x02)
            {
                0x179C, 
                0x0381
            }, 

            Package (0x02)
            {
                0x2DDC, 
                0x039C
            }, 

            Package (0x02)
            {
                0x44A8, 
                0x039E
            }, 

            Package (0x02)
            {
                0x5C35, 
                0x0397
            }, 

            Package (0x02)
            {
                0x747D, 
                0x038D
            }, 

            Package (0x02)
            {
                0x8D7F, 
                0x0382
            }, 

            Package (0x02)
            {
                0xA768, 
                0x0376
            }, 

            Package (0x02)
            {
                0xC23B, 
                0x0369
            }, 

            Package (0x02)
            {
                0xDE26, 
                0x035A
            }, 

            Package (0x02)
            {
                0xFB7C, 
                0x034A
            }
        })
        Name (CEUP, Package (0x06)
        {
            0x80000000, 
            0x80000000, 
            0x80000000, 
            0x80000000, 
            0x80000000, 
            0x80000000
        })
        Method (TMPX, 0, Serialized)
        {
            Return (\_SB.IETM.CTOK (PCTP))
        }

        Method (_DTI, 1, NotSerialized)  // _DTI: Device Temperature Indication
        {
            LSTM = Arg0
            Notify (\_SB.PC00.TCPU, 0x91) // Device-Specific
        }

        Method (_NTT, 0, NotSerialized)  // _NTT: Notification Temperature Threshold
        {
            Return (0x0ADE)
        }

        Name (PTYP, Zero)
        Method (_PSS, 0, NotSerialized)  // _PSS: Performance Supported States
        {
            If (CondRefOf (\_SB.PR00._PSS))
            {
                Return (\_SB.PR00._PSS ())
            }
            Else
            {
                Return (Package (0x02)
                {
                    Package (0x06)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }, 

                    Package (0x06)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                })
            }
        }

        Method (_TSS, 0, NotSerialized)  // _TSS: Throttling Supported States
        {
            If (CondRefOf (\_SB.PR00._TSS))
            {
                Return (\_SB.PR00._TSS ())
            }
            Else
            {
                Return (Package (0x01)
                {
                    Package (0x05)
                    {
                        One, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                })
            }
        }

        Method (_TPC, 0, NotSerialized)  // _TPC: Throttling Present Capabilities
        {
            If (CondRefOf (\_SB.PR00._TPC))
            {
                Return (\_SB.PR00._TPC) /* External reference */
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (_PTC, 0, NotSerialized)  // _PTC: Processor Throttling Control
        {
            If ((CondRefOf (\PF00) && (\PF00 != 0x80000000)))
            {
                If ((\PF00 & 0x04))
                {
                    Return (Package (0x02)
                    {
                        ResourceTemplate ()
                        {
                            Register (FFixedHW, 
                                0x00,               // Bit Width
                                0x00,               // Bit Offset
                                0x0000000000000000, // Address
                                ,)
                        }, 

                        ResourceTemplate ()
                        {
                            Register (FFixedHW, 
                                0x00,               // Bit Width
                                0x00,               // Bit Offset
                                0x0000000000000000, // Address
                                ,)
                        }
                    })
                }
                Else
                {
                    Return (Package (0x02)
                    {
                        ResourceTemplate ()
                        {
                            Register (SystemIO, 
                                0x05,               // Bit Width
                                0x00,               // Bit Offset
                                0x0000000000001810, // Address
                                ,)
                        }, 

                        ResourceTemplate ()
                        {
                            Register (SystemIO, 
                                0x05,               // Bit Width
                                0x00,               // Bit Offset
                                0x0000000000001810, // Address
                                ,)
                        }
                    })
                }
            }
            Else
            {
                Return (Package (0x02)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x00,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }, 

                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x00,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }
                })
            }
        }

        Method (_TSD, 0, NotSerialized)  // _TSD: Throttling State Dependencies
        {
            If (CondRefOf (\_SB.PR00._TSD))
            {
                Return (\_SB.PR00._TSD ())
            }
            Else
            {
                Return (Package (0x01)
                {
                    Package (0x05)
                    {
                        0x05, 
                        Zero, 
                        Zero, 
                        0xFC, 
                        Zero
                    }
                })
            }
        }

        Method (_TDL, 0, NotSerialized)  // _TDL: T-State Depth Limit
        {
            If ((CondRefOf (\_SB.PR00._TSS) && CondRefOf (\_SB.CFGD)))
            {
                If ((\_SB.CFGD & 0x2000))
                {
                    Return ((SizeOf (\_SB.PR00.TSMF) - One))
                }
                Else
                {
                    Return ((SizeOf (\_SB.PR00.TSMC) - One))
                }
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (_PDL, 0, NotSerialized)  // _PDL: P-state Depth Limit
        {
            If (CondRefOf (\_SB.PR00._PSS))
            {
                If ((\_SB.OSCP & 0x0400))
                {
                    Return ((SizeOf (\_SB.PR00.TPSS) - One))
                }
                Else
                {
                    Return ((SizeOf (\_SB.PR00.LPSS) - One))
                }
            }
            Else
            {
                Return (Zero)
            }
        }

        Name (TJMX, 0x6E)
        Method (_TSP, 0, Serialized)  // _TSP: Thermal Sampling Period
        {
            Return (Zero)
        }

        Method (_AC0, 0, Serialized)  // _ACx: Active Cooling, x=0-9
        {
            Local1 = \_SB.IETM.CTOK (TJMX)
            Local1 -= 0x0A
            If ((LSTM >= Local1))
            {
                Return ((Local1 - 0x14))
            }
            Else
            {
                Return (Local1)
            }
        }

        Method (_AC1, 0, Serialized)  // _ACx: Active Cooling, x=0-9
        {
            Local1 = \_SB.IETM.CTOK (TJMX)
            Local1 -= 0x1E
            If ((LSTM >= Local1))
            {
                Return ((Local1 - 0x14))
            }
            Else
            {
                Return (Local1)
            }
        }

        Method (_AC2, 0, Serialized)  // _ACx: Active Cooling, x=0-9
        {
            Local1 = \_SB.IETM.CTOK (TJMX)
            Local1 -= 0x28
            If ((LSTM >= Local1))
            {
                Return ((Local1 - 0x14))
            }
            Else
            {
                Return (Local1)
            }
        }

        Method (_AC3, 0, Serialized)  // _ACx: Active Cooling, x=0-9
        {
            Local1 = \_SB.IETM.CTOK (TJMX)
            Local1 -= 0x37
            If ((LSTM >= Local1))
            {
                Return ((Local1 - 0x14))
            }
            Else
            {
                Return (Local1)
            }
        }

        Method (_AC4, 0, Serialized)  // _ACx: Active Cooling, x=0-9
        {
            Local1 = \_SB.IETM.CTOK (TJMX)
            Local1 -= 0x46
            If ((LSTM >= Local1))
            {
                Return ((Local1 - 0x14))
            }
            Else
            {
                Return (Local1)
            }
        }

        Method (_PSV, 0, Serialized)  // _PSV: Passive Temperature
        {
            Return (\_SB.IETM.CTOK (TJMX))
        }

        Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
        {
            Return (\_SB.IETM.CTOK (TJMX))
        }

        Method (_CR3, 0, Serialized)  // _CR3: Warm/Standby Temperature
        {
            Return (\_SB.IETM.CTOK (TJMX))
        }

        Method (_HOT, 0, Serialized)  // _HOT: Hot Temperature
        {
            Return (\_SB.IETM.CTOK (TJMX))
        }

        Method (UVTH, 1, Serialized)
        {
        }
    }

    Scope (\_SB.IETM)
    {
        Name (CTSP, Package (0x01)
        {
            ToUUID ("e145970a-e4c1-4d73-900e-c9c5a69dd067") /* Unknown UUID */
        })
    }

    Scope (\_SB.PC00.TCPU)
    {
        Method (TDPL, 0, Serialized)
        {
            Name (AAAA, Zero)
            Name (BBBB, Zero)
            Name (CCCC, Zero)
            Local0 = CTNL /* \_SB_.PC00.TCPU.CTNL */
            If (((Local0 == One) || (Local0 == 0x02)))
            {
                Local0 = \_SB.CLVL /* External reference */
            }
            Else
            {
                Return (Package (0x01)
                {
                    Zero
                })
            }

            If ((CLCK == One))
            {
                Local0 = One
            }

            AAAA = CPNU (\_SB.PL10, One)
            BBBB = CPNU (\_SB.PL11, One)
            CCCC = CPNU (\_SB.PL12, One)
            Name (TMP1, Package (0x01)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            Name (TMP2, Package (0x02)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            Name (TMP3, Package (0x03)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            If ((Local0 == 0x03))
            {
                If ((AAAA > BBBB))
                {
                    If ((AAAA > CCCC))
                    {
                        If ((BBBB > CCCC))
                        {
                            Local3 = Zero
                            LEV0 = Zero
                            Local4 = One
                            LEV1 = One
                            Local5 = 0x02
                            LEV2 = 0x02
                        }
                        Else
                        {
                            Local3 = Zero
                            LEV0 = Zero
                            Local5 = One
                            LEV1 = 0x02
                            Local4 = 0x02
                            LEV2 = One
                        }
                    }
                    Else
                    {
                        Local5 = Zero
                        LEV0 = 0x02
                        Local3 = One
                        LEV1 = Zero
                        Local4 = 0x02
                        LEV2 = One
                    }
                }
                ElseIf ((BBBB > CCCC))
                {
                    If ((AAAA > CCCC))
                    {
                        Local4 = Zero
                        LEV0 = One
                        Local3 = One
                        LEV1 = Zero
                        Local5 = 0x02
                        LEV2 = 0x02
                    }
                    Else
                    {
                        Local4 = Zero
                        LEV0 = One
                        Local5 = One
                        LEV1 = 0x02
                        Local3 = 0x02
                        LEV2 = Zero
                    }
                }
                Else
                {
                    Local5 = Zero
                    LEV0 = 0x02
                    Local4 = One
                    LEV1 = One
                    Local3 = 0x02
                    LEV2 = Zero
                }

                Local1 = (\_SB.TAR0 + One)
                Local2 = (Local1 * 0x64)
                DerefOf (TMP3 [Local3]) [Zero] = AAAA /* \_SB_.PC00.TCPU.TDPL.AAAA */
                DerefOf (TMP3 [Local3]) [One] = Local2
                DerefOf (TMP3 [Local3]) [0x02] = \_SB.CTC0 /* External reference */
                DerefOf (TMP3 [Local3]) [0x03] = Local1
                DerefOf (TMP3 [Local3]) [0x04] = Zero
                Local1 = (\_SB.TAR1 + One)
                Local2 = (Local1 * 0x64)
                DerefOf (TMP3 [Local4]) [Zero] = BBBB /* \_SB_.PC00.TCPU.TDPL.BBBB */
                DerefOf (TMP3 [Local4]) [One] = Local2
                DerefOf (TMP3 [Local4]) [0x02] = \_SB.CTC1 /* External reference */
                DerefOf (TMP3 [Local4]) [0x03] = Local1
                DerefOf (TMP3 [Local4]) [0x04] = Zero
                Local1 = (\_SB.TAR2 + One)
                Local2 = (Local1 * 0x64)
                DerefOf (TMP3 [Local5]) [Zero] = CCCC /* \_SB_.PC00.TCPU.TDPL.CCCC */
                DerefOf (TMP3 [Local5]) [One] = Local2
                DerefOf (TMP3 [Local5]) [0x02] = \_SB.CTC2 /* External reference */
                DerefOf (TMP3 [Local5]) [0x03] = Local1
                DerefOf (TMP3 [Local5]) [0x04] = Zero
                Return (TMP3) /* \_SB_.PC00.TCPU.TDPL.TMP3 */
            }

            If ((Local0 == 0x02))
            {
                If ((AAAA > BBBB))
                {
                    Local3 = Zero
                    Local4 = One
                    LEV0 = Zero
                    LEV1 = One
                    LEV2 = Zero
                }
                Else
                {
                    Local4 = Zero
                    Local3 = One
                    LEV0 = One
                    LEV1 = Zero
                    LEV2 = Zero
                }

                Local1 = (\_SB.TAR0 + One)
                Local2 = (Local1 * 0x64)
                DerefOf (TMP2 [Local3]) [Zero] = AAAA /* \_SB_.PC00.TCPU.TDPL.AAAA */
                DerefOf (TMP2 [Local3]) [One] = Local2
                DerefOf (TMP2 [Local3]) [0x02] = \_SB.CTC0 /* External reference */
                DerefOf (TMP2 [Local3]) [0x03] = Local1
                DerefOf (TMP2 [Local3]) [0x04] = Zero
                Local1 = (\_SB.TAR1 + One)
                Local2 = (Local1 * 0x64)
                DerefOf (TMP2 [Local4]) [Zero] = BBBB /* \_SB_.PC00.TCPU.TDPL.BBBB */
                DerefOf (TMP2 [Local4]) [One] = Local2
                DerefOf (TMP2 [Local4]) [0x02] = \_SB.CTC1 /* External reference */
                DerefOf (TMP2 [Local4]) [0x03] = Local1
                DerefOf (TMP2 [Local4]) [0x04] = Zero
                Return (TMP2) /* \_SB_.PC00.TCPU.TDPL.TMP2 */
            }

            If ((Local0 == One))
            {
                Switch (ToInteger (\_SB.CBMI))
                {
                    Case (Zero)
                    {
                        Local1 = (\_SB.TAR0 + One)
                        Local2 = (Local1 * 0x64)
                        DerefOf (TMP1 [Zero]) [Zero] = AAAA /* \_SB_.PC00.TCPU.TDPL.AAAA */
                        DerefOf (TMP1 [Zero]) [One] = Local2
                        DerefOf (TMP1 [Zero]) [0x02] = \_SB.CTC0 /* External reference */
                        DerefOf (TMP1 [Zero]) [0x03] = Local1
                        DerefOf (TMP1 [Zero]) [0x04] = Zero
                        LEV0 = Zero
                        LEV1 = Zero
                        LEV2 = Zero
                    }
                    Case (One)
                    {
                        Local1 = (\_SB.TAR1 + One)
                        Local2 = (Local1 * 0x64)
                        DerefOf (TMP1 [Zero]) [Zero] = BBBB /* \_SB_.PC00.TCPU.TDPL.BBBB */
                        DerefOf (TMP1 [Zero]) [One] = Local2
                        DerefOf (TMP1 [Zero]) [0x02] = \_SB.CTC1 /* External reference */
                        DerefOf (TMP1 [Zero]) [0x03] = Local1
                        DerefOf (TMP1 [Zero]) [0x04] = Zero
                        LEV0 = One
                        LEV1 = One
                        LEV2 = One
                    }
                    Case (0x02)
                    {
                        Local1 = (\_SB.TAR2 + One)
                        Local2 = (Local1 * 0x64)
                        DerefOf (TMP1 [Zero]) [Zero] = CCCC /* \_SB_.PC00.TCPU.TDPL.CCCC */
                        DerefOf (TMP1 [Zero]) [One] = Local2
                        DerefOf (TMP1 [Zero]) [0x02] = \_SB.CTC2 /* External reference */
                        DerefOf (TMP1 [Zero]) [0x03] = Local1
                        DerefOf (TMP1 [Zero]) [0x04] = Zero
                        LEV0 = 0x02
                        LEV1 = 0x02
                        LEV2 = 0x02
                    }

                }

                Return (TMP1) /* \_SB_.PC00.TCPU.TDPL.TMP1 */
            }

            Return (Zero)
        }

        Name (MAXT, Zero)
        Method (TDPC, 0, NotSerialized)
        {
            Return (MAXT) /* \_SB_.PC00.TCPU.MAXT */
        }

        Name (LEV0, Zero)
        Name (LEV1, Zero)
        Name (LEV2, Zero)
        Method (STDP, 1, Serialized)
        {
            If ((Arg0 >= \_SB.CLVL))
            {
                Return (Zero)
            }

            Switch (ToInteger (Arg0))
            {
                Case (Zero)
                {
                    Local0 = LEV0 /* \_SB_.PC00.TCPU.LEV0 */
                }
                Case (One)
                {
                    Local0 = LEV1 /* \_SB_.PC00.TCPU.LEV1 */
                }
                Case (0x02)
                {
                    Local0 = LEV2 /* \_SB_.PC00.TCPU.LEV2 */
                }

            }

            Switch (ToInteger (Local0))
            {
                Case (Zero)
                {
                    CPL0 ()
                }
                Case (One)
                {
                    CPL1 ()
                }
                Case (0x02)
                {
                    CPL2 ()
                }

            }

            Notify (\_SB.PC00.TCPU, 0x83) // Device-Specific Change
        }
    }

    Scope (\_SB)
    {
        Device (TPCH)
        {
            Name (_UID, "TPCH")  // _UID: Unique ID
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return (\_SB.IETM.GHID (_UID))
            }

            Name (_STR, Unicode ("Intel PCH FIVR Participant"))  // _STR: Description String
            Name (PTYP, 0x05)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((\PCHE == One))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RFC0, 1, Serialized)
            {
                IPCS (0xA3, One, 0x08, Zero, Arg0, Zero, Zero)
                Return (Package (0x01)
                {
                    Zero
                })
            }

            Method (RFC1, 1, Serialized)
            {
                IPCS (0xA3, One, 0x08, One, Arg0, Zero, Zero)
                Return (Package (0x01)
                {
                    Zero
                })
            }

            Method (SEMI, 1, Serialized)
            {
                IPCS (0xA3, One, 0x08, 0x02, Arg0, Zero, Zero)
                Return (Package (0x01)
                {
                    Zero
                })
            }

            Method (PKGC, 1, Serialized)
            {
                Name (PPKG, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PPKG [Zero] = DerefOf (Arg0 [Zero])
                PPKG [One] = DerefOf (Arg0 [One])
                Return (PPKG) /* \_SB_.TPCH.PKGC.PPKG */
            }

            Method (GFC0, 0, Serialized)
            {
                Local0 = IPCS (0xA3, Zero, 0x08, Zero, Zero, Zero, Zero)
                Local1 = \_SB.TPCH.PKGC (Local0)
                Return (Local1)
            }

            Method (GFC1, 0, Serialized)
            {
                Local0 = IPCS (0xA3, Zero, 0x08, One, Zero, Zero, Zero)
                Local1 = \_SB.TPCH.PKGC (Local0)
                Return (Local1)
            }

            Method (GEMI, 0, Serialized)
            {
                Local0 = IPCS (0xA3, Zero, 0x08, 0x02, Zero, Zero, Zero)
                Local1 = \_SB.TPCH.PKGC (Local0)
                Return (Local1)
            }

            Method (GFFS, 0, Serialized)
            {
                Local0 = IPCS (0xA3, Zero, 0x08, 0x03, Zero, Zero, Zero)
                Local1 = \_SB.TPCH.PKGC (Local0)
                Return (Local1)
            }

            Method (GFCS, 0, Serialized)
            {
                Local0 = IPCS (0xA3, Zero, 0x08, 0x04, Zero, Zero, Zero)
                Local1 = \_SB.TPCH.PKGC (Local0)
                Return (Local1)
            }
        }
    }

    Scope (\_SB.IETM)
    {
        Name (DP2P, Package (0x01)
        {
            ToUUID ("9e04115a-ae87-4d1c-9500-0f3e340bfe75") /* Unknown UUID */
        })
        Name (DPSP, Package (0x01)
        {
            ToUUID ("42a441d6-ae6a-462b-a84b-4a8ce79027d3") /* Unknown UUID */
        })
        Name (DASP, Package (0x01)
        {
            ToUUID ("3a95c389-e4b8-4629-a526-c52c88626bae") /* Unknown UUID */
        })
        Name (DA2P, Package (0x01)
        {
            ToUUID ("0e56fab6-bdfc-4e8c-8246-40ecfd4d74ea") /* Unknown UUID */
        })
        Name (DCSP, Package (0x01)
        {
            ToUUID ("97c68ae7-15fa-499c-b8c9-5da81d606e0a") /* Unknown UUID */
        })
        Name (RFIP, Package (0x01)
        {
            ToUUID ("c4ce1849-243a-49f3-b8d5-f97002f38e6a") /* Unknown UUID */
        })
        Name (POBP, Package (0x01)
        {
            ToUUID ("f5a35014-c209-46a4-993a-eb56de7530a1") /* Unknown UUID */
        })
        Name (DAPP, Package (0x01)
        {
            ToUUID ("63be270f-1c11-48fd-a6f7-3af253ff3e2d") /* Unknown UUID */
        })
        Name (DVSP, Package (0x01)
        {
            ToUUID ("6ed722a7-9240-48a5-b479-31eef723d7cf") /* Unknown UUID */
        })
        Name (DPID, Package (0x01)
        {
            ToUUID ("42496e14-bc1b-46e8-a798-ca915464426f") /* Unknown UUID */
        })
    }

    Scope (\_SB.PC00.LPCB.EC)
    {
        Mutex (PATM, 0x00)
        Method (_QC1, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
            If ((Local0 == Zero))
            {
                SCIC = 0xC1
                P8XH (Zero, 0xC1)
                Release (\_SB.PC00.LPCB.EC.PATM)
            }

            Notify (\_SB.PC00.LPCB.EC.SEN2, 0x90) // Device-Specific
        }

        Method (_QC2, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
            If ((Local0 == Zero))
            {
                If ((\_SB.PC00.LPCB.EC.DTDR == One))
                {
                    SCIC = 0xC2
                    P8XH (Zero, 0xC2)
                    WCEC (0xC2)
                    If (WATO ())
                    {
                        Local1 = Zero
                        Local0 = DAT1 /* External reference */
                        If ((Local0 == 0xFA))
                        {
                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV0 = Local0
                            }

                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV1 = Local0
                            }

                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV2 = Local0
                            }

                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV3 = Local0
                            }

                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV4 = Local0
                            }

                            If (WATO ())
                            {
                                Local1 += One
                                Local0 = DAT1 /* External reference */
                                \ODV5 = Local0
                            }

                            If ((0x06 == Local1))
                            {
                                \_SB.IETM.ODVP ()
                                Notify (\_SB.IETM, 0x88) // Device-Specific
                            }
                        }
                    }
                }

                Name (DBAW, Buffer (0x09)
                {
                     0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
                })
                CreateByteField (DBAW, Zero, DBA0)
                CreateByteField (DBAW, One, DBA1)
                CreateByteField (DBAW, 0x02, DBA2)
                CreateByteField (DBAW, 0x03, DBA3)
                CreateByteField (DBAW, 0x04, DBA4)
                CreateByteField (DBAW, 0x05, DBA5)
                CreateByteField (DBAW, 0x08, DBA8)
                Switch (ToInteger (\ODV1))
                {
                    Case (Zero)
                    {
                        \_SB.NPCF.DBAC = DBA0 /* \_SB_.PC00.LPCB.EC__._QC2.DBA0 */
                        \_SB.NPCF.AMAT = 0xC8
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x02D0
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0230
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x02D0
                        }
                    }
                    Case (One)
                    {
                        \_SB.NPCF.DBAC = DBA1 /* \_SB_.PC00.LPCB.EC__._QC2.DBA1 */
                        \_SB.NPCF.AMAT = 0x78
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x0230
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0118
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x0168
                        }
                    }
                    Case (0x02)
                    {
                        \_SB.NPCF.DBAC = DBA2 /* \_SB_.PC00.LPCB.EC__._QC2.DBA2 */
                        \_SB.NPCF.AMAT = 0x28
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x78
                        \_SB.NPCF.ACBT = Zero
                    }
                    Case (0x03)
                    {
                        \_SB.NPCF.DBAC = DBA3 /* \_SB_.PC00.LPCB.EC__._QC2.DBA3 */
                        \_SB.NPCF.AMAT = 0x78
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x0230
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0118
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x0168
                        }
                    }
                    Case (0x04)
                    {
                        \_SB.NPCF.DBAC = DBA4 /* \_SB_.PC00.LPCB.EC__._QC2.DBA4 */
                        \_SB.NPCF.AMAT = 0xC8
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x02D0
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0230
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x02D0
                        }
                    }
                    Case (0x05)
                    {
                        \_SB.NPCF.DBAC = DBA5 /* \_SB_.PC00.LPCB.EC__._QC2.DBA5 */
                        \_SB.NPCF.AMAT = 0x28
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0xF0
                        \_SB.NPCF.ACBT = Zero
                    }
                    Case (0x08)
                    {
                        \_SB.NPCF.DBAC = DBA0 /* \_SB_.PC00.LPCB.EC__._QC2.DBA0 */
                        \_SB.NPCF.AMAT = 0xC8
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x02D0
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0230
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x02D0
                        }
                    }
                    Default
                    {
                        \_SB.NPCF.DBAC = DBA1 /* \_SB_.PC00.LPCB.EC__._QC2.DBA1 */
                        \_SB.NPCF.AMAT = 0x78
                        \_SB.NPCF.AMIT = 0xFFD8
                        \_SB.NPCF.ATPP = 0x0230
                        If ((GPUD == 0x2717))
                        {
                            \_SB.NPCF.ACBT = 0x0118
                        }
                        Else
                        {
                            \_SB.NPCF.ACBT = 0x0168
                        }
                    }

                }

                Debug = "QC2 end,"
                Debug = \_SB.NPCF.DBAC /* External reference */
                Notify (\_SB.NPCF, 0xC0) // Hardware-Specific
                Release (\_SB.PC00.LPCB.EC.PATM)
            }

            If ((\_SB.PC00.LPCB.EC.SYSM == Zero))
            {
                \_SB.PC00.PEG1.PEGP.NLIM = One
                \_SB.PC00.PEG1.PEGP.STGU = 0x57
                Notify (\_SB.PC00.PEG1.PEGP, 0xC0) // Hardware-Specific
            }
            ElseIf ((\_SB.PC00.LPCB.EC.SYSM == One))
            {
                If ((\_SB.PC00.LPCB.EC.SILE == One))
                {
                    \_SB.PC00.PEG1.PEGP.NLIM = One
                    \_SB.PC00.PEG1.PEGP.STGU = 0x4B
                    Notify (\_SB.PC00.PEG1.PEGP, 0xC0) // Hardware-Specific
                }
                Else
                {
                    \_SB.PC00.PEG1.PEGP.NLIM = One
                    \_SB.PC00.PEG1.PEGP.STGU = 0x57
                    Notify (\_SB.PC00.PEG1.PEGP, 0xC0) // Hardware-Specific
                }
            }
            Else
            {
                \_SB.PC00.PEG1.PEGP.NLIM = One
                \_SB.PC00.PEG1.PEGP.STGU = 0x57
                Notify (\_SB.PC00.PEG1.PEGP, 0xC0) // Hardware-Specific
            }
        }

        Method (_QC3, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
            If ((Local0 == Zero))
            {
                SCIC = 0xC3
                Release (\_SB.PC00.LPCB.EC.PATM)
            }

            Notify (\_SB.IETM, 0xA0) // Device-Specific
        }

        Method (_QC4, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
            If ((Local0 == Zero))
            {
                SCIC = 0xC4
                Release (\_SB.PC00.LPCB.EC.PATM)
            }

            Notify (\_SB.PC00.LPCB.EC.SEN3, 0x90) // Device-Specific
        }
    }

    Scope (\_SB.PC00.LPCB.EC)
    {
        Device (SEN2)
        {
            Name (_UID, "SEN2")  // _UID: Unique ID
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return (\_SB.IETM.GHID (_UID))
            }

            Name (_STR, Unicode ("Thermistor GT VR"))  // _STR: Description String
            Name (PTYP, 0x03)
            Name (CTYP, Zero)
            Name (PFLG, Zero)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((\S2DE == One))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = (\_SB.PC00.LPCB.EC.TSIT * 0x0A)
                    Return (\_SB.IETM.C10K (Local0))
                }
                Else
                {
                    Return (0x0BB8)
                }
            }

            Name (PATC, 0x02)
            Method (PAT0, 1, Serialized)
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
                    If ((Local0 == Zero))
                    {
                        Local1 = \_SB.IETM.K10C (Arg0)
                        Divide (Local1, 0x0A, Local2, Local3)
                        \_SB.PC00.LPCB.EC.TSTL = Local3
                        Release (\_SB.PC00.LPCB.EC.PATM)
                    }
                }
            }

            Method (PAT1, 1, Serialized)
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
                    If ((Local0 == Zero))
                    {
                        Local1 = \_SB.IETM.K10C (Arg0)
                        Divide (Local1, 0x0A, Local2, Local3)
                        If ((Local3 > 0x7F))
                        {
                            Local3 = 0x7F
                        }

                        \_SB.PC00.LPCB.EC.TSTU = Local3
                        Release (\_SB.PC00.LPCB.EC.PATM)
                    }
                }
            }

            Name (GTSH, 0x14)
            Name (LSTM, Zero)
            Method (_DTI, 1, NotSerialized)  // _DTI: Device Temperature Indication
            {
                LSTM = Arg0
                Notify (\_SB.PC00.LPCB.EC.SEN2, 0x91) // Device-Specific
            }

            Method (_NTT, 0, NotSerialized)  // _NTT: Notification Temperature Threshold
            {
                Return (0x0ADE)
            }

            Name (S2AC, 0x3C)
            Name (S2A1, 0x32)
            Name (S2A2, 0x28)
            Name (S2PV, 0x41)
            Name (S2CC, 0x50)
            Name (S2C3, 0x46)
            Name (S2HP, 0x4B)
            Name (SSP2, Zero)
            Method (_TSP, 0, Serialized)  // _TSP: Thermal Sampling Period
            {
                Return (SSP2) /* \_SB_.PC00.LPCB.EC__.SEN2.SSP2 */
            }

            Method (_PSV, 0, Serialized)  // _PSV: Passive Temperature
            {
                Return (\_SB.IETM.CTOK (S2PV))
            }

            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (\_SB.IETM.CTOK (S2CC))
            }

            Method (_CR3, 0, Serialized)  // _CR3: Warm/Standby Temperature
            {
                Return (\_SB.IETM.CTOK (S2C3))
            }

            Method (_HOT, 0, Serialized)  // _HOT: Hot Temperature
            {
                Return (\_SB.IETM.CTOK (S2HP))
            }
        }
    }

    Scope (\_SB.IETM)
    {
        Name (PTTL, 0x14)
        Name (PSVT, Package (0x01)
        {
            0x02
        })
    }

    Scope (\_SB.PC00.LPCB.EC)
    {
        Device (SEN4)
        {
            Name (_UID, "SEN4")  // _UID: Unique ID
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return (\_SB.IETM.GHID (_UID))
            }

            Name (_STR, Unicode ("Thermistor Battery Charger"))  // _STR: Description String
            Name (PTYP, 0x03)
            Name (CTYP, Zero)
            Name (PFLG, Zero)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((\S4DE == One))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = (\_SB.PC00.LPCB.EC.SYST * 0x0A)
                    Return (\_SB.IETM.C10K (Local0))
                }
                Else
                {
                    Return (0x0BB8)
                }
            }

            Name (PATC, 0x02)
            Method (PAT0, 1, Serialized)
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
                    If ((Local0 == Zero))
                    {
                        Local1 = \_SB.IETM.K10C (Arg0)
                        Divide (Local1, 0x0A, Local2, Local3)
                        Release (\_SB.PC00.LPCB.EC.PATM)
                    }
                }
            }

            Method (PAT1, 1, Serialized)
            {
                If (\_SB.PC00.LPCB.EC.MYEC)
                {
                    Local0 = Acquire (\_SB.PC00.LPCB.EC.PATM, 0x0064)
                    If ((Local0 == Zero))
                    {
                        Local1 = \_SB.IETM.K10C (Arg0)
                        Divide (Local1, 0x0A, Local2, Local3)
                        If ((Local3 > 0x7F))
                        {
                            Local3 = 0x7F
                        }

                        Release (\_SB.PC00.LPCB.EC.PATM)
                    }
                }
            }

            Name (GTSH, 0x14)
            Name (LSTM, Zero)
            Method (_DTI, 1, NotSerialized)  // _DTI: Device Temperature Indication
            {
                LSTM = Arg0
                Notify (\_SB.PC00.LPCB.EC.SEN4, 0x91) // Device-Specific
            }

            Method (_NTT, 0, NotSerialized)  // _NTT: Notification Temperature Threshold
            {
                Return (0x0ADE)
            }

            Name (S4AC, 0x3C)
            Name (S4A1, 0x32)
            Name (S4A2, 0x28)
            Name (S4PV, 0x41)
            Name (S4CC, 0x50)
            Name (S4C3, 0x46)
            Name (S4HP, 0x4B)
            Name (SSP4, Zero)
            Method (_TSP, 0, Serialized)  // _TSP: Thermal Sampling Period
            {
                Return (SSP4) /* \_SB_.PC00.LPCB.EC__.SEN4.SSP4 */
            }

            Method (_PSV, 0, Serialized)  // _PSV: Passive Temperature
            {
                Return (\_SB.IETM.CTOK (S4PV))
            }

            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (\_SB.IETM.CTOK (S4CC))
            }

            Method (_CR3, 0, Serialized)  // _CR3: Warm/Standby Temperature
            {
                Return (\_SB.IETM.CTOK (S4C3))
            }

            Method (_HOT, 0, Serialized)  // _HOT: Hot Temperature
            {
                Return (\_SB.IETM.CTOK (S4HP))
            }
        }
    }

    Scope (\_SB.IETM)
    {
        Method (GDDV, 0, Serialized)
        {
            Switch (ToInteger (PLID))
            {
                Case (Package (0x01)
                    {
                        0x1B
                    }

)
                {
                    Return (Package (0x01)
                    {
                        Buffer (0x044B)
                        {
                            /* 0000 */  0xE5, 0x1F, 0x94, 0x00, 0x00, 0x00, 0x00, 0x02,  // ........
                            /* 0008 */  0x00, 0x00, 0x00, 0x40, 0x67, 0x64, 0x64, 0x76,  // ...@gddv
                            /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x4F, 0x45, 0x4D, 0x20,  // ....OEM 
                            /* 0030 */  0x45, 0x78, 0x70, 0x6F, 0x72, 0x74, 0x65, 0x64,  // Exported
                            /* 0038 */  0x20, 0x44, 0x61, 0x74, 0x61, 0x56, 0x61, 0x75,  //  DataVau
                            /* 0040 */  0x6C, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // lt......
                            /* 0048 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0050 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0058 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x80, 0x4B, 0xF8, 0xA1,  // .....K..
                            /* 0070 */  0xDB, 0x42, 0xBD, 0x7D, 0xCF, 0x35, 0x88, 0x3A,  // .B.}.5.:
                            /* 0078 */  0xB5, 0x36, 0x0E, 0x52, 0xE1, 0x1D, 0x9C, 0x57,  // .6.R...W
                            /* 0080 */  0x8C, 0xD6, 0x5D, 0xFE, 0xBD, 0x33, 0x77, 0x1D,  // ..]..3w.
                            /* 0088 */  0x06, 0x96, 0x98, 0xE8, 0xB7, 0x03, 0x00, 0x00,  // ........
                            /* 0090 */  0x52, 0x45, 0x50, 0x4F, 0x5D, 0x00, 0x00, 0x00,  // REPO]...
                            /* 0098 */  0x01, 0x55, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00,  // .UM.....
                            /* 00A0 */  0x00, 0x00, 0x72, 0x87, 0xCD, 0xFF, 0x6D, 0x24,  // ..r...m$
                            /* 00A8 */  0x47, 0xDB, 0x3D, 0x24, 0x92, 0xB4, 0x16, 0x6F,  // G.=$...o
                            /* 00B0 */  0x45, 0xD8, 0xC3, 0xF5, 0x66, 0x14, 0x9F, 0x22,  // E...f.."
                            /* 00B8 */  0xD7, 0xF7, 0xDE, 0x67, 0x90, 0x9A, 0xA2, 0x0D,  // ...g....
                            /* 00C0 */  0x39, 0x25, 0xAD, 0xC3, 0x1A, 0xAD, 0x52, 0x0B,  // 9%....R.
                            /* 00C8 */  0x75, 0x38, 0xE1, 0xA4, 0x14, 0x44, 0x0F, 0xD3,  // u8...D..
                            /* 00D0 */  0x8E, 0xF2, 0xC3, 0x2A, 0xAE, 0xE5, 0x63, 0x97,  // ...*..c.
                            /* 00D8 */  0x9F, 0x3E, 0x8A, 0x8F, 0x8F, 0x5D, 0xFD, 0x8E,  // .>...]..
                            /* 00E0 */  0x1F, 0x7A, 0x9A, 0xE6, 0x99, 0x3C, 0xD4, 0xDE,  // .z...<..
                            /* 00E8 */  0x94, 0xC9, 0x7C, 0xAF, 0x73, 0xD4, 0x50, 0xA9,  // ..|.s.P.
                            /* 00F0 */  0x57, 0x95, 0x12, 0xD5, 0x5E, 0x96, 0x0D, 0x5A,  // W...^..Z
                            /* 00F8 */  0xD5, 0x6B, 0xAE, 0x06, 0x48, 0x5D, 0x6D, 0x66,  // .k..H]mf
                            /* 0100 */  0x89, 0x37, 0x9D, 0x50, 0xA4, 0x2C, 0xD0, 0x17,  // .7.P.,..
                            /* 0108 */  0x20, 0x5D, 0x3B, 0x32, 0x85, 0xF2, 0x56, 0xD4,  //  ];2..V.
                            /* 0110 */  0x7D, 0xDE, 0x14, 0x62, 0x32, 0xED, 0xB7, 0x4E,  // }..b2..N
                            /* 0118 */  0x8D, 0x3A, 0xC5, 0x46, 0x57, 0xAC, 0xDF, 0x56,  // .:.FW..V
                            /* 0120 */  0xE7, 0xDF, 0x79, 0xA9, 0x28, 0x8B, 0x60, 0x7B,  // ..y.(.`{
                            /* 0128 */  0x4B, 0xD6, 0x10, 0x98, 0x82, 0x99, 0x7C, 0xDA,  // K.....|.
                            /* 0130 */  0x79, 0x9D, 0xCC, 0x02, 0xEB, 0xF9, 0x9E, 0x60,  // y......`
                            /* 0138 */  0x25, 0x9D, 0x76, 0x60, 0xD8, 0xFC, 0x35, 0x6D,  // %.v`..5m
                            /* 0140 */  0x06, 0x99, 0x04, 0x80, 0xD5, 0x80, 0xAD, 0x42,  // .......B
                            /* 0148 */  0xDB, 0x95, 0x47, 0xD4, 0x0B, 0xE9, 0x47, 0x21,  // ..G...G!
                            /* 0150 */  0x17, 0xFE, 0xD5, 0x3D, 0x80, 0x12, 0x29, 0x3A,  // ...=..):
                            /* 0158 */  0x19, 0xFF, 0x8D, 0xE0, 0x11, 0x15, 0x20, 0xE7,  // ...... .
                            /* 0160 */  0x72, 0x01, 0x4F, 0xC3, 0xE7, 0x82, 0xF5, 0xEA,  // r.O.....
                            /* 0168 */  0x9A, 0xCB, 0xC6, 0x82, 0x64, 0x24, 0x46, 0x78,  // ....d$Fx
                            /* 0170 */  0xA1, 0xBC, 0xDB, 0x69, 0xCA, 0x72, 0xC8, 0x70,  // ...i.r.p
                            /* 0178 */  0x07, 0x44, 0x5A, 0x38, 0x20, 0xF6, 0x46, 0x68,  // .DZ8 .Fh
                            /* 0180 */  0x1B, 0x41, 0x95, 0x8D, 0x77, 0x35, 0x24, 0x28,  // .A..w5$(
                            /* 0188 */  0x0F, 0xF8, 0xA9, 0x92, 0xBF, 0x4C, 0x83, 0xED,  // .....L..
                            /* 0190 */  0xAB, 0x07, 0xF0, 0x72, 0xCC, 0x03, 0x8B, 0xE3,  // ...r....
                            /* 0198 */  0xAE, 0x22, 0xE8, 0x53, 0x25, 0x5D, 0xF7, 0x4C,  // .".S%].L
                            /* 01A0 */  0xFF, 0xAF, 0x9C, 0x79, 0x94, 0xE3, 0x48, 0xC2,  // ...y..H.
                            /* 01A8 */  0xFB, 0x46, 0x03, 0x67, 0xCA, 0xAA, 0xB2, 0x86,  // .F.g....
                            /* 01B0 */  0xF0, 0x1D, 0x7B, 0x51, 0x90, 0xE8, 0x89, 0x4D,  // ..{Q...M
                            /* 01B8 */  0xB7, 0x73, 0x63, 0xA9, 0x9A, 0x46, 0xE0, 0x9F,  // .sc..F..
                            /* 01C0 */  0xB7, 0x1A, 0x86, 0xD0, 0x17, 0x4F, 0x83, 0x9A,  // .....O..
                            /* 01C8 */  0x72, 0x18, 0x1D, 0x0E, 0xFC, 0x05, 0xE9, 0x81,  // r.......
                            /* 01D0 */  0x57, 0xA8, 0xB2, 0xE7, 0xF7, 0x0E, 0x81, 0x13,  // W.......
                            /* 01D8 */  0xE8, 0xC1, 0x02, 0x1A, 0xD8, 0x4B, 0x67, 0x9D,  // .....Kg.
                            /* 01E0 */  0x46, 0x2D, 0xFC, 0xF5, 0xDC, 0x42, 0x31, 0xE1,  // F-...B1.
                            /* 01E8 */  0x79, 0xDB, 0x3F, 0x8A, 0x38, 0x9D, 0xB7, 0x0C,  // y.?.8...
                            /* 01F0 */  0xC8, 0x5C, 0x7C, 0x0D, 0xED, 0xA9, 0xB0, 0x7D,  // .\|....}
                            /* 01F8 */  0x28, 0xF7, 0xB7, 0x7A, 0x96, 0x41, 0xEA, 0x9D,  // (..z.A..
                            /* 0200 */  0x20, 0x6E, 0x6E, 0xA2, 0xBB, 0x32, 0x98, 0xCD,  //  nn..2..
                            /* 0208 */  0x3F, 0x79, 0x6F, 0x5C, 0x12, 0xAD, 0x67, 0xA7,  // ?yo\..g.
                            /* 0210 */  0xE9, 0xC6, 0x50, 0x57, 0x09, 0x16, 0x05, 0x65,  // ..PW...e
                            /* 0218 */  0x02, 0x2A, 0xDE, 0x84, 0xE6, 0xCC, 0x90, 0xD8,  // .*......
                            /* 0220 */  0x61, 0x84, 0x14, 0xB0, 0x07, 0xC8, 0xE3, 0x45,  // a......E
                            /* 0228 */  0x04, 0xA8, 0xE0, 0x47, 0x0D, 0xFC, 0x5D, 0xE7,  // ...G..].
                            /* 0230 */  0x44, 0x38, 0xB9, 0x34, 0xF8, 0x67, 0xC0, 0x70,  // D8.4.g.p
                            /* 0238 */  0xE8, 0xD3, 0x37, 0xAD, 0x01, 0x9A, 0x2D, 0xEF,  // ..7...-.
                            /* 0240 */  0xD4, 0x61, 0x67, 0x7A, 0x89, 0x60, 0xE9, 0x6A,  // .agz.`.j
                            /* 0248 */  0x18, 0x56, 0x6F, 0x0B, 0x47, 0xB8, 0xA5, 0x1A,  // .Vo.G...
                            /* 0250 */  0xA5, 0xC6, 0x6C, 0x44, 0xF7, 0xC2, 0x75, 0x77,  // ..lD..uw
                            /* 0258 */  0x69, 0x8B, 0xC5, 0xD1, 0x4E, 0xEF, 0x08, 0x1F,  // i...N...
                            /* 0260 */  0x2C, 0xE6, 0xF0, 0x46, 0x65, 0x81, 0xD0, 0xB7,  // ,..Fe...
                            /* 0268 */  0x69, 0x60, 0x9A, 0xF7, 0xE4, 0xCE, 0xCC, 0x04,  // i`......
                            /* 0270 */  0x4F, 0x4B, 0xA3, 0x1C, 0xF3, 0x1F, 0x82, 0x03,  // OK......
                            /* 0278 */  0x5F, 0x47, 0xCF, 0x58, 0xD5, 0xA9, 0x00, 0x27,  // _G.X...'
                            /* 0280 */  0xAD, 0x38, 0x7F, 0xB9, 0x0A, 0xEC, 0xD6, 0xFA,  // .8......
                            /* 0288 */  0xF1, 0xAB, 0x36, 0x1F, 0xF7, 0x90, 0x48, 0xDB,  // ..6...H.
                            /* 0290 */  0x07, 0x3A, 0x50, 0xAB, 0x1D, 0x83, 0x28, 0x51,  // .:P...(Q
                            /* 0298 */  0xC7, 0x8E, 0x97, 0x77, 0x66, 0x52, 0x68, 0x56,  // ...wfRhV
                            /* 02A0 */  0x2F, 0x04, 0xEA, 0xB1, 0xDF, 0x49, 0xDF, 0x9F,  // /....I..
                            /* 02A8 */  0xC2, 0x2D, 0x05, 0x9B, 0x1C, 0xC3, 0x11, 0x16,  // .-......
                            /* 02B0 */  0xD3, 0xB0, 0xA2, 0x6B, 0x6B, 0xCC, 0xEF, 0x3A,  // ...kk..:
                            /* 02B8 */  0x5F, 0xEA, 0x97, 0x3A, 0xB1, 0x0A, 0x10, 0xC7,  // _..:....
                            /* 02C0 */  0x86, 0x83, 0xA9, 0x85, 0x31, 0x2F, 0xBA, 0x71,  // ....1/.q
                            /* 02C8 */  0xD6, 0x85, 0xC2, 0xC3, 0x07, 0x94, 0xF0, 0x6C,  // .......l
                            /* 02D0 */  0x2C, 0xE5, 0xAF, 0x3E, 0x74, 0x0E, 0x60, 0xEB,  // ,..>t.`.
                            /* 02D8 */  0xCB, 0x50, 0x94, 0x75, 0x72, 0x85, 0xDA, 0x8C,  // .P.ur...
                            /* 02E0 */  0x25, 0x29, 0x58, 0xE4, 0x51, 0x3C, 0x80, 0x36,  // %)X.Q<.6
                            /* 02E8 */  0x37, 0x45, 0x1C, 0xBF, 0x8D, 0x13, 0x03, 0xB8,  // 7E......
                            /* 02F0 */  0x2B, 0xF0, 0xD6, 0x92, 0x97, 0xDC, 0xFA, 0x5F,  // +......_
                            /* 02F8 */  0x85, 0x98, 0xD5, 0xBB, 0x86, 0x02, 0x47, 0xDC,  // ......G.
                            /* 0300 */  0xFE, 0xC5, 0x19, 0xE5, 0x1C, 0x7C, 0x56, 0x91,  // .....|V.
                            /* 0308 */  0x7F, 0x11, 0xFC, 0xFF, 0x32, 0x9F, 0x50, 0x83,  // ....2.P.
                            /* 0310 */  0x28, 0x77, 0xAA, 0x31, 0xAA, 0x6A, 0x25, 0xA8,  // (w.1.j%.
                            /* 0318 */  0xCB, 0x16, 0x84, 0x33, 0x9E, 0x55, 0x70, 0x83,  // ...3.Up.
                            /* 0320 */  0x98, 0x50, 0x6E, 0xAD, 0xEA, 0xB8, 0x4B, 0x2A,  // .Pn...K*
                            /* 0328 */  0xF2, 0x27, 0xD7, 0x17, 0xC4, 0xD7, 0x45, 0xBF,  // .'....E.
                            /* 0330 */  0x5D, 0xDE, 0x81, 0x5E, 0xD3, 0x59, 0x60, 0x90,  // ]..^.Y`.
                            /* 0338 */  0x00, 0xE3, 0xA4, 0xB0, 0xF0, 0x0A, 0x6D, 0x20,  // ......m 
                            /* 0340 */  0xD7, 0xFF, 0x60, 0xD0, 0xCE, 0x78, 0x18, 0x61,  // ..`..x.a
                            /* 0348 */  0x38, 0x17, 0x2A, 0x7A, 0x57, 0x4A, 0x4A, 0x42,  // 8.*zWJJB
                            /* 0350 */  0xF6, 0x14, 0x16, 0x63, 0xD2, 0x35, 0x4A, 0xCE,  // ...c.5J.
                            /* 0358 */  0x52, 0x3D, 0xF4, 0x74, 0xDE, 0x6B, 0x44, 0xAB,  // R=.t.kD.
                            /* 0360 */  0x28, 0x75, 0x31, 0x0B, 0x25, 0xC5, 0xC5, 0x86,  // (u1.%...
                            /* 0368 */  0xFA, 0x74, 0xC8, 0xE0, 0xB0, 0x79, 0xD8, 0x6C,  // .t...y.l
                            /* 0370 */  0x58, 0xDB, 0x91, 0x55, 0x81, 0xDB, 0xB4, 0x71,  // X..U...q
                            /* 0378 */  0x84, 0x30, 0x2A, 0x4F, 0x67, 0x8A, 0xE3, 0x68,  // .0*Og..h
                            /* 0380 */  0x7F, 0x5D, 0xF8, 0x38, 0x99, 0x67, 0xBF, 0x8C,  // .].8.g..
                            /* 0388 */  0x5D, 0x3E, 0x7B, 0x2E, 0x72, 0x49, 0x71, 0xB9,  // ]>{.rIq.
                            /* 0390 */  0xD5, 0xA3, 0x3A, 0x4B, 0x8C, 0x5F, 0x81, 0xAA,  // ..:K._..
                            /* 0398 */  0xE3, 0x88, 0x12, 0x97, 0x1B, 0x1F, 0x81, 0x4C,  // .......L
                            /* 03A0 */  0x3D, 0x62, 0xB8, 0x1D, 0x87, 0x75, 0x55, 0x05,  // =b...uU.
                            /* 03A8 */  0xAD, 0x99, 0xA5, 0x87, 0x36, 0x42, 0xE4, 0xD3,  // ....6B..
                            /* 03B0 */  0x55, 0xD6, 0x17, 0x2C, 0x03, 0xA0, 0xB2, 0xB3,  // U..,....
                            /* 03B8 */  0x26, 0x63, 0xEA, 0x77, 0xAF, 0x25, 0xF3, 0xA9,  // &c.w.%..
                            /* 03C0 */  0xA5, 0x84, 0x06, 0xD1, 0xB1, 0xD9, 0xDD, 0xCB,  // ........
                            /* 03C8 */  0x41, 0xE2, 0xE4, 0x06, 0xE1, 0xE3, 0x58, 0xD5,  // A.....X.
                            /* 03D0 */  0xCE, 0xE4, 0x1B, 0x51, 0xED, 0xF3, 0x38, 0x5B,  // ...Q..8[
                            /* 03D8 */  0xCA, 0x8C, 0x8F, 0x6B, 0x5D, 0x04, 0xE4, 0x9D,  // ...k]...
                            /* 03E0 */  0xA5, 0x3E, 0xA9, 0x9F, 0x3B, 0xF7, 0xDA, 0xBA,  // .>..;...
                            /* 03E8 */  0xC0, 0x4A, 0xC5, 0xEC, 0x39, 0xFF, 0x43, 0xBC,  // .J..9.C.
                            /* 03F0 */  0x97, 0x80, 0x11, 0xE0, 0x52, 0xC6, 0x1F, 0xFA,  // ....R...
                            /* 03F8 */  0x57, 0xFB, 0x2F, 0xC9, 0x9B, 0x87, 0xB2, 0xDD,  // W./.....
                            /* 0400 */  0x38, 0xA9, 0xE5, 0xDB, 0x37, 0x44, 0xF6, 0x24,  // 8...7D.$
                            /* 0408 */  0x73, 0x39, 0xB1, 0xDB, 0x52, 0xA6, 0x08, 0x3F,  // s9..R..?
                            /* 0410 */  0x99, 0x9E, 0x02, 0x25, 0x3F, 0x5F, 0x6E, 0xE2,  // ...%?_n.
                            /* 0418 */  0xAC, 0x14, 0x48, 0x0F, 0xED, 0x9A, 0xC3, 0xCF,  // ..H.....
                            /* 0420 */  0xB9, 0x48, 0xEB, 0xD0, 0x55, 0xAC, 0x65, 0xF2,  // .H..U.e.
                            /* 0428 */  0x55, 0xDF, 0x6B, 0x73, 0x01, 0x37, 0x4D, 0x1E,  // U.ks.7M.
                            /* 0430 */  0x00, 0x06, 0xE4, 0xD1, 0xC6, 0xE5, 0xB8, 0x8E,  // ........
                            /* 0438 */  0xDF, 0x1E, 0xFB, 0x4E, 0x4D, 0xFC, 0x60, 0x59,  // ...NM.`Y
                            /* 0440 */  0x01, 0x5A, 0xD2, 0xCB, 0xD7, 0x26, 0x76, 0xE3,  // .Z...&v.
                            /* 0448 */  0xA6, 0x5B, 0x5E                                 // .[^
                        }
                    })
                }
                Default
                {
                    Return (Package (0x01)
                    {
                        Buffer (0x06A8)
                        {
                            /* 0000 */  0xE5, 0x1F, 0x94, 0x00, 0x00, 0x00, 0x00, 0x02,  // ........
                            /* 0008 */  0x00, 0x00, 0x00, 0x40, 0x67, 0x64, 0x64, 0x76,  // ...@gddv
                            /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x4F, 0x45, 0x4D, 0x20,  // ....OEM 
                            /* 0030 */  0x45, 0x78, 0x70, 0x6F, 0x72, 0x74, 0x65, 0x64,  // Exported
                            /* 0038 */  0x20, 0x44, 0x61, 0x74, 0x61, 0x56, 0x61, 0x75,  //  DataVau
                            /* 0040 */  0x6C, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // lt......
                            /* 0048 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0050 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0058 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x3A, 0xD1, 0x59, 0x80,  // ....:.Y.
                            /* 0070 */  0xE4, 0xEF, 0x95, 0x3D, 0xC6, 0xD2, 0xEF, 0x3C,  // ...=...<
                            /* 0078 */  0xFA, 0x5B, 0x47, 0x1D, 0xCE, 0xE1, 0xD7, 0x86,  // .[G.....
                            /* 0080 */  0xA3, 0x5F, 0x8C, 0x6D, 0x7A, 0x88, 0x5E, 0x3D,  // ._.mz.^=
                            /* 0088 */  0x48, 0x6C, 0x2E, 0xF7, 0x14, 0x06, 0x00, 0x00,  // Hl......
                            /* 0090 */  0x52, 0x45, 0x50, 0x4F, 0x5D, 0x00, 0x00, 0x00,  // REPO]...
                            /* 0098 */  0x01, 0xA4, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,  // ..a.....
                            /* 00A0 */  0x00, 0x00, 0x72, 0x87, 0xCD, 0xFF, 0x6D, 0x24,  // ..r...m$
                            /* 00A8 */  0x47, 0xDB, 0x3D, 0x24, 0x92, 0xB4, 0x16, 0x6F,  // G.=$...o
                            /* 00B0 */  0x45, 0xD8, 0xC3, 0xF5, 0x66, 0x14, 0x9F, 0x22,  // E...f.."
                            /* 00B8 */  0xD7, 0xF7, 0xDE, 0x67, 0x90, 0x9A, 0xA2, 0x0D,  // ...g....
                            /* 00C0 */  0x39, 0x25, 0xAD, 0xC3, 0x1A, 0xAD, 0x52, 0x0B,  // 9%....R.
                            /* 00C8 */  0x75, 0x38, 0xE1, 0xA4, 0x14, 0x44, 0xB7, 0xAF,  // u8...D..
                            /* 00D0 */  0x52, 0x31, 0xF5, 0x64, 0x83, 0x94, 0x02, 0x6E,  // R1.d...n
                            /* 00D8 */  0xDC, 0xF8, 0x6A, 0x9E, 0x02, 0x93, 0x91, 0x8D,  // ..j.....
                            /* 00E0 */  0x75, 0x0A, 0xFD, 0xC4, 0x0A, 0x58, 0xFE, 0xCE,  // u....X..
                            /* 00E8 */  0xD2, 0xAB, 0x62, 0x9B, 0x4D, 0xD0, 0x72, 0xCC,  // ..b.M.r.
                            /* 00F0 */  0x62, 0x8F, 0xCA, 0x59, 0x9F, 0xCA, 0x95, 0x7D,  // b..Y...}
                            /* 00F8 */  0x48, 0x82, 0x1A, 0xCF, 0x8B, 0x55, 0x2F, 0x92,  // H....U/.
                            /* 0100 */  0x41, 0xBE, 0xE7, 0xFE, 0x36, 0x4C, 0x7C, 0xCF,  // A...6L|.
                            /* 0108 */  0xC8, 0x34, 0xB7, 0x43, 0xE7, 0x6C, 0xB3, 0x1D,  // .4.C.l..
                            /* 0110 */  0x30, 0xDA, 0xBC, 0xC2, 0xB5, 0x37, 0xF6, 0x51,  // 0....7.Q
                            /* 0118 */  0x65, 0x9D, 0x6D, 0x78, 0x81, 0xFE, 0x06, 0x73,  // e.mx...s
                            /* 0120 */  0xE3, 0xD8, 0x8E, 0xAD, 0xEA, 0x18, 0x73, 0x3A,  // ......s:
                            /* 0128 */  0xB7, 0xF4, 0x4F, 0xFC, 0x5D, 0x55, 0xDC, 0x38,  // ..O.]U.8
                            /* 0130 */  0xD6, 0x98, 0xC8, 0x00, 0x47, 0x35, 0x75, 0x93,  // ....G5u.
                            /* 0138 */  0x9C, 0xD7, 0x83, 0x75, 0xBF, 0x2D, 0xDF, 0x61,  // ...u.-.a
                            /* 0140 */  0xA8, 0xBB, 0x73, 0xFB, 0xF4, 0xB1, 0xD4, 0xB3,  // ..s.....
                            /* 0148 */  0xBE, 0xAC, 0x61, 0xAB, 0x96, 0x28, 0xA9, 0x52,  // ..a..(.R
                            /* 0150 */  0x50, 0xF6, 0x9D, 0xDF, 0xB4, 0x92, 0x68, 0x60,  // P.....h`
                            /* 0158 */  0x99, 0x2B, 0x1C, 0xB6, 0x97, 0x75, 0xD7, 0xD5,  // .+...u..
                            /* 0160 */  0xD3, 0xE5, 0x84, 0xE2, 0xD0, 0xFF, 0x20, 0x2F,  // ...... /
                            /* 0168 */  0xEA, 0x0C, 0x07, 0x06, 0xB3, 0x5D, 0x91, 0xCF,  // .....]..
                            /* 0170 */  0x7A, 0x8C, 0xDC, 0x61, 0x96, 0x3F, 0x06, 0x20,  // z..a.?. 
                            /* 0178 */  0xF1, 0x3D, 0x62, 0xB3, 0x26, 0x73, 0xC0, 0x98,  // .=b.&s..
                            /* 0180 */  0xBF, 0x6D, 0xA2, 0xFF, 0x26, 0x30, 0x10, 0xAF,  // .m..&0..
                            /* 0188 */  0x9A, 0xAD, 0xC6, 0x6A, 0xB1, 0x07, 0xDF, 0xCF,  // ...j....
                            /* 0190 */  0x9E, 0x51, 0x34, 0xCB, 0x66, 0xC5, 0x9E, 0xF4,  // .Q4.f...
                            /* 0198 */  0xC0, 0x32, 0x41, 0xF2, 0xAC, 0x7A, 0x71, 0xB9,  // .2A..zq.
                            /* 01A0 */  0xB1, 0x93, 0xC6, 0x5B, 0x71, 0x14, 0x1E, 0xEB,  // ...[q...
                            /* 01A8 */  0x4C, 0xCC, 0x65, 0x12, 0x41, 0x60, 0x61, 0x29,  // L.e.A`a)
                            /* 01B0 */  0x6E, 0x50, 0x0A, 0x93, 0xF5, 0x5F, 0x72, 0xE6,  // nP..._r.
                            /* 01B8 */  0x5E, 0xFE, 0xE0, 0x83, 0xBD, 0xD4, 0x32, 0x2D,  // ^.....2-
                            /* 01C0 */  0x16, 0x8A, 0xB8, 0xE8, 0x23, 0x7B, 0xAD, 0x36,  // ....#{.6
                            /* 01C8 */  0x7D, 0x94, 0x43, 0x8C, 0xF1, 0x3C, 0x97, 0x77,  // }.C..<.w
                            /* 01D0 */  0x42, 0xA7, 0xBE, 0xE2, 0x04, 0x1F, 0x1C, 0x98,  // B.......
                            /* 01D8 */  0x70, 0x02, 0x1C, 0xCE, 0x08, 0x13, 0x07, 0xB4,  // p.......
                            /* 01E0 */  0x46, 0xB5, 0x35, 0xEC, 0x37, 0xFD, 0x4F, 0x56,  // F.5.7.OV
                            /* 01E8 */  0xFF, 0x63, 0x1E, 0x8D, 0x9D, 0x75, 0x0F, 0x16,  // .c...u..
                            /* 01F0 */  0x3C, 0x7A, 0xE5, 0x33, 0xAE, 0x92, 0x60, 0xD5,  // <z.3..`.
                            /* 01F8 */  0xC2, 0x02, 0xE4, 0xA6, 0x0A, 0xCA, 0x2B, 0x79,  // ......+y
                            /* 0200 */  0xAE, 0xDB, 0xA1, 0xD2, 0x88, 0x39, 0x9C, 0x80,  // .....9..
                            /* 0208 */  0xC7, 0x7D, 0xA5, 0x58, 0x98, 0xB1, 0x9C, 0x48,  // .}.X...H
                            /* 0210 */  0xB3, 0xD2, 0x89, 0x07, 0x36, 0x1A, 0xA3, 0xF3,  // ....6...
                            /* 0218 */  0xB5, 0xCE, 0x75, 0x50, 0x77, 0x97, 0xC9, 0xC5,  // ..uPw...
                            /* 0220 */  0x20, 0xD4, 0x8B, 0xCD, 0xB0, 0x2D, 0x50, 0xCD,  //  ....-P.
                            /* 0228 */  0x68, 0x81, 0xE7, 0x95, 0x40, 0xD5, 0xD2, 0x32,  // h...@..2
                            /* 0230 */  0x3D, 0x00, 0x73, 0x9E, 0x44, 0x69, 0xBA, 0xD9,  // =.s.Di..
                            /* 0238 */  0x19, 0x30, 0xA1, 0x09, 0xD4, 0x6A, 0xD8, 0x60,  // .0...j.`
                            /* 0240 */  0x7D, 0x27, 0x48, 0x3B, 0x75, 0x6F, 0x89, 0x1D,  // }'H;uo..
                            /* 0248 */  0x47, 0xB7, 0x6B, 0xF9, 0xB7, 0x16, 0x9E, 0x77,  // G.k....w
                            /* 0250 */  0xEE, 0xEE, 0xD4, 0x0F, 0xEB, 0xC6, 0x87, 0x09,  // ........
                            /* 0258 */  0xFD, 0xD0, 0xFD, 0x22, 0xDA, 0x3E, 0xA1, 0x4B,  // ...".>.K
                            /* 0260 */  0xD1, 0x38, 0xC2, 0x89, 0x31, 0x4C, 0xE0, 0x46,  // .8..1L.F
                            /* 0268 */  0xFF, 0xFC, 0x01, 0xD5, 0x87, 0xB9, 0xB0, 0xA8,  // ........
                            /* 0270 */  0x9C, 0x04, 0xEB, 0x24, 0x06, 0x4B, 0x77, 0x46,  // ...$.KwF
                            /* 0278 */  0x01, 0x2E, 0x22, 0x24, 0xE7, 0x66, 0x3D, 0xB0,  // .."$.f=.
                            /* 0280 */  0xD1, 0x89, 0x1E, 0x87, 0x3D, 0xBD, 0x23, 0x0A,  // ....=.#.
                            /* 0288 */  0x28, 0xF4, 0x2A, 0xF9, 0x1B, 0x8F, 0x48, 0x57,  // (.*...HW
                            /* 0290 */  0xA9, 0x75, 0xB5, 0xC4, 0x9E, 0xC6, 0x34, 0xB8,  // .u....4.
                            /* 0298 */  0x26, 0x29, 0xFE, 0x7F, 0x76, 0x12, 0xC5, 0xDC,  // &)..v...
                            /* 02A0 */  0x24, 0x70, 0xCA, 0x18, 0xB5, 0xD4, 0x3D, 0x0B,  // $p....=.
                            /* 02A8 */  0xCF, 0xFD, 0x2C, 0x5C, 0x1C, 0x97, 0x7B, 0x60,  // ..,\..{`
                            /* 02B0 */  0x85, 0x44, 0xA6, 0x6B, 0x20, 0x11, 0x86, 0x28,  // .D.k ..(
                            /* 02B8 */  0xB2, 0x6D, 0xC0, 0x3C, 0x82, 0x53, 0xF6, 0x1A,  // .m.<.S..
                            /* 02C0 */  0x65, 0x89, 0x4E, 0x83, 0xEB, 0x5E, 0x06, 0x24,  // e.N..^.$
                            /* 02C8 */  0x4F, 0x6D, 0x22, 0x13, 0x37, 0x59, 0x35, 0x3F,  // Om".7Y5?
                            /* 02D0 */  0x85, 0x41, 0xCE, 0xEB, 0xF1, 0x4F, 0x14, 0x0C,  // .A...O..
                            /* 02D8 */  0x90, 0x56, 0x82, 0x6E, 0x56, 0xCD, 0x61, 0x0A,  // .V.nV.a.
                            /* 02E0 */  0xD1, 0x13, 0xFD, 0x00, 0xDF, 0xA0, 0x91, 0x07,  // ........
                            /* 02E8 */  0x27, 0x8F, 0x4E, 0x9E, 0xF6, 0xEC, 0xCC, 0x24,  // '.N....$
                            /* 02F0 */  0x6B, 0x2D, 0xFA, 0x74, 0xCB, 0xE3, 0xBE, 0x18,  // k-.t....
                            /* 02F8 */  0x5C, 0x74, 0x41, 0x31, 0xB0, 0xDB, 0xAE, 0xA4,  // \tA1....
                            /* 0300 */  0x2B, 0x0E, 0x64, 0x3A, 0x25, 0x91, 0x19, 0x54,  // +.d:%..T
                            /* 0308 */  0x08, 0xAC, 0xA4, 0xDD, 0x4D, 0x84, 0x0D, 0x89,  // ....M...
                            /* 0310 */  0x47, 0x48, 0xEA, 0x60, 0x91, 0xC3, 0x17, 0x63,  // GH.`...c
                            /* 0318 */  0x3E, 0x3C, 0x32, 0xBF, 0xC4, 0xEC, 0x81, 0x69,  // ><2....i
                            /* 0320 */  0x10, 0xF5, 0xAE, 0x36, 0x11, 0x1A, 0x5D, 0xAB,  // ...6..].
                            /* 0328 */  0x08, 0x5F, 0x94, 0x17, 0x7A, 0x1E, 0xD2, 0xB7,  // ._..z...
                            /* 0330 */  0xAB, 0x1C, 0x7F, 0x53, 0xD9, 0x70, 0x5C, 0xF5,  // ...S.p\.
                            /* 0338 */  0x13, 0x21, 0xC0, 0x19, 0xFA, 0x7D, 0xE7, 0x7A,  // .!...}.z
                            /* 0340 */  0xC1, 0xE8, 0x1A, 0xBB, 0xF8, 0x6A, 0x3C, 0x2E,  // .....j<.
                            /* 0348 */  0x70, 0xEE, 0xCD, 0xDE, 0xC5, 0xED, 0x34, 0x1C,  // p.....4.
                            /* 0350 */  0x8A, 0x73, 0x47, 0xE1, 0x2D, 0xB3, 0xA9, 0x61,  // .sG.-..a
                            /* 0358 */  0xA6, 0x8C, 0x02, 0xAB, 0x17, 0x66, 0x83, 0x19,  // .....f..
                            /* 0360 */  0x79, 0x58, 0x1B, 0xB2, 0x7A, 0x92, 0xFB, 0xB7,  // yX..z...
                            /* 0368 */  0xA9, 0x36, 0x25, 0xC1, 0x57, 0xB8, 0x94, 0x28,  // .6%.W..(
                            /* 0370 */  0xC7, 0x1D, 0x6E, 0x61, 0xB4, 0x43, 0x8F, 0x1C,  // ..na.C..
                            /* 0378 */  0x6B, 0xB3, 0xB8, 0x5F, 0xD4, 0x02, 0x7A, 0x77,  // k.._..zw
                            /* 0380 */  0xE7, 0xFA, 0xFD, 0x8D, 0x95, 0xA4, 0x1C, 0xD3,  // ........
                            /* 0388 */  0x8F, 0x8F, 0x25, 0x3E, 0xA8, 0xA3, 0xA5, 0x07,  // ..%>....
                            /* 0390 */  0xF7, 0x7E, 0xE1, 0x22, 0xCB, 0x31, 0xB0, 0x65,  // .~.".1.e
                            /* 0398 */  0x9A, 0xCC, 0x29, 0xAB, 0x05, 0xB8, 0x61, 0x86,  // ..)...a.
                            /* 03A0 */  0x8D, 0xDF, 0xD6, 0xE9, 0x52, 0xFD, 0x19, 0xE8,  // ....R...
                            /* 03A8 */  0xDB, 0xC0, 0x48, 0x48, 0x10, 0xA0, 0x99, 0xCD,  // ..HH....
                            /* 03B0 */  0x70, 0x5C, 0x6A, 0x90, 0x47, 0x27, 0xA9, 0xBD,  // p\j.G'..
                            /* 03B8 */  0x4D, 0x8A, 0xDB, 0x14, 0x08, 0x72, 0x61, 0x56,  // M....raV
                            /* 03C0 */  0xC4, 0x01, 0xDB, 0xCF, 0x6F, 0x96, 0xBD, 0x6D,  // ....o..m
                            /* 03C8 */  0x73, 0x92, 0xB9, 0x01, 0x30, 0xA2, 0x2D, 0xF2,  // s...0.-.
                            /* 03D0 */  0xB3, 0xB7, 0x28, 0xDD, 0xFC, 0xCA, 0x18, 0x9B,  // ..(.....
                            /* 03D8 */  0xDC, 0xA4, 0x90, 0x25, 0xA5, 0x81, 0x32, 0xFA,  // ...%..2.
                            /* 03E0 */  0x72, 0x95, 0x6C, 0xB8, 0x2C, 0x94, 0xCA, 0x7A,  // r.l.,..z
                            /* 03E8 */  0xE8, 0x8A, 0x6E, 0xEB, 0x8B, 0xFD, 0x68, 0xCE,  // ..n...h.
                            /* 03F0 */  0xA8, 0xED, 0x78, 0xE0, 0x6F, 0x73, 0xD6, 0x7F,  // ..x.os..
                            /* 03F8 */  0x67, 0x53, 0xE2, 0x43, 0xBF, 0x66, 0x27, 0x98,  // gS.C.f'.
                            /* 0400 */  0x24, 0x0F, 0x5B, 0x37, 0x50, 0x9C, 0xFD, 0x2B,  // $.[7P..+
                            /* 0408 */  0x58, 0xE6, 0x3F, 0xF8, 0x28, 0x16, 0x7A, 0x32,  // X.?.(.z2
                            /* 0410 */  0x1A, 0xA2, 0x84, 0xBC, 0xB2, 0x81, 0x6F, 0xE2,  // ......o.
                            /* 0418 */  0x01, 0x6F, 0x43, 0x94, 0x3F, 0x6D, 0x5F, 0x06,  // .oC.?m_.
                            /* 0420 */  0x0B, 0x38, 0xF3, 0x65, 0xAC, 0x7F, 0x2F, 0x13,  // .8.e../.
                            /* 0428 */  0xBD, 0xFB, 0x64, 0x1A, 0x44, 0x2A, 0x05, 0x80,  // ..d.D*..
                            /* 0430 */  0x13, 0x61, 0x7C, 0x5B, 0x85, 0x56, 0x9B, 0x97,  // .a|[.V..
                            /* 0438 */  0x37, 0x34, 0xFF, 0x78, 0xF1, 0x85, 0x6C, 0x17,  // 74.x..l.
                            /* 0440 */  0xC1, 0xB9, 0x25, 0xF1, 0x0B, 0x37, 0x57, 0x9F,  // ..%..7W.
                            /* 0448 */  0x49, 0x92, 0x49, 0x04, 0xE9, 0x51, 0x3C, 0xD2,  // I.I..Q<.
                            /* 0450 */  0x3A, 0x14, 0x46, 0x38, 0xD1, 0x57, 0x53, 0x9C,  // :.F8.WS.
                            /* 0458 */  0xD3, 0xE2, 0xF5, 0x70, 0xBB, 0x6D, 0x62, 0x04,  // ...p.mb.
                            /* 0460 */  0xA6, 0xF7, 0x12, 0x34, 0x78, 0xF8, 0x51, 0x93,  // ...4x.Q.
                            /* 0468 */  0x2A, 0x84, 0xC7, 0x79, 0x3D, 0x61, 0x55, 0x6C,  // *..y=aUl
                            /* 0470 */  0x39, 0x27, 0x86, 0xCC, 0xAD, 0x64, 0x5D, 0x93,  // 9'...d].
                            /* 0478 */  0x4B, 0x8F, 0x2B, 0xA2, 0x23, 0xDC, 0xC8, 0x34,  // K.+.#..4
                            /* 0480 */  0x9B, 0xEA, 0x20, 0x7F, 0x87, 0x73, 0xC2, 0x7E,  // .. ..s.~
                            /* 0488 */  0x81, 0xCE, 0xD3, 0x80, 0x0C, 0xB6, 0xC4, 0x19,  // ........
                            /* 0490 */  0xF9, 0x67, 0x58, 0xB5, 0x30, 0xCA, 0x52, 0x85,  // .gX.0.R.
                            /* 0498 */  0xBE, 0x1E, 0x55, 0xD4, 0xAC, 0x6B, 0x7B, 0x6E,  // ..U..k{n
                            /* 04A0 */  0xE0, 0x48, 0xB5, 0x5A, 0x91, 0xD7, 0x89, 0x6E,  // .H.Z...n
                            /* 04A8 */  0xD1, 0x50, 0x08, 0xDF, 0xED, 0xEB, 0x4D, 0xF3,  // .P....M.
                            /* 04B0 */  0x31, 0x6E, 0x03, 0x7D, 0x46, 0x57, 0xFF, 0x80,  // 1n.}FW..
                            /* 04B8 */  0x6A, 0x34, 0x6E, 0x4A, 0x81, 0x35, 0x4D, 0x9F,  // j4nJ.5M.
                            /* 04C0 */  0x4D, 0x1B, 0x2F, 0xC1, 0x76, 0x36, 0xB3, 0x01,  // M./.v6..
                            /* 04C8 */  0x0A, 0xD7, 0x16, 0x26, 0x30, 0x86, 0x11, 0x15,  // ...&0...
                            /* 04D0 */  0x14, 0x5E, 0x39, 0x3E, 0x6D, 0xB6, 0xE3, 0xF2,  // .^9>m...
                            /* 04D8 */  0x50, 0xC2, 0x9C, 0x5F, 0xCE, 0xE2, 0x36, 0x98,  // P.._..6.
                            /* 04E0 */  0xAC, 0x24, 0xBA, 0x20, 0x76, 0x7F, 0x0E, 0x4D,  // .$. v..M
                            /* 04E8 */  0x1E, 0x74, 0x11, 0x7D, 0xC3, 0x6B, 0x02, 0x79,  // .t.}.k.y
                            /* 04F0 */  0x1D, 0xD0, 0x52, 0x44, 0x1D, 0xAD, 0x83, 0x32,  // ..RD...2
                            /* 04F8 */  0x1B, 0x3B, 0xCF, 0x1B, 0xC6, 0xBF, 0xE2, 0x77,  // .;.....w
                            /* 0500 */  0x3A, 0x4A, 0x29, 0x31, 0xDD, 0xA3, 0xED, 0xD4,  // :J)1....
                            /* 0508 */  0x31, 0xB9, 0xD6, 0xC0, 0xD7, 0xAE, 0x85, 0x08,  // 1.......
                            /* 0510 */  0x17, 0xA7, 0x05, 0x12, 0xF4, 0xF5, 0x38, 0xF9,  // ......8.
                            /* 0518 */  0xB2, 0x71, 0xB5, 0xFB, 0xE5, 0xF1, 0xE1, 0xF8,  // .q......
                            /* 0520 */  0x6C, 0x04, 0x35, 0xD4, 0x62, 0x53, 0xE9, 0x46,  // l.5.bS.F
                            /* 0528 */  0x6C, 0x6F, 0xE7, 0x15, 0x49, 0x03, 0x69, 0xE7,  // lo..I.i.
                            /* 0530 */  0xBD, 0x74, 0x49, 0xBE, 0xBB, 0x75, 0x4C, 0x26,  // .tI..uL&
                            /* 0538 */  0x6D, 0xDC, 0x31, 0x82, 0xC8, 0x2C, 0x2A, 0x42,  // m.1..,*B
                            /* 0540 */  0xEA, 0xAE, 0xF3, 0x0A, 0xDA, 0x4F, 0xD7, 0xA3,  // .....O..
                            /* 0548 */  0x22, 0x24, 0x11, 0x83, 0x99, 0x2F, 0xC5, 0x4A,  // "$.../.J
                            /* 0550 */  0xED, 0x6B, 0x77, 0x2F, 0x25, 0xDD, 0xA5, 0x2D,  // .kw/%..-
                            /* 0558 */  0x52, 0xAB, 0xB2, 0xBD, 0x0E, 0xE2, 0xC8, 0x8D,  // R.......
                            /* 0560 */  0x39, 0x13, 0x44, 0x98, 0xBE, 0x7C, 0x8D, 0x3D,  // 9.D..|.=
                            /* 0568 */  0x36, 0x98, 0x87, 0x8B, 0x3F, 0x4F, 0x08, 0xF7,  // 6...?O..
                            /* 0570 */  0x72, 0x4F, 0x84, 0x3E, 0xFA, 0x0E, 0xC0, 0x90,  // rO.>....
                            /* 0578 */  0xC3, 0x96, 0x13, 0xB9, 0x72, 0x25, 0xBA, 0xD2,  // ....r%..
                            /* 0580 */  0xCE, 0x03, 0xC5, 0xC9, 0x42, 0xBE, 0x07, 0x03,  // ....B...
                            /* 0588 */  0x13, 0x6F, 0xFB, 0x17, 0x2B, 0xAC, 0x2D, 0x71,  // .o..+.-q
                            /* 0590 */  0x3B, 0xF1, 0x54, 0xF7, 0xE0, 0x2A, 0xE7, 0x2C,  // ;.T..*.,
                            /* 0598 */  0xD8, 0x40, 0xA5, 0xB1, 0xC2, 0xE7, 0x2C, 0x05,  // .@....,.
                            /* 05A0 */  0xB1, 0x36, 0x97, 0x92, 0xDD, 0xB1, 0xE3, 0xB0,  // .6......
                            /* 05A8 */  0xB2, 0x4C, 0x3E, 0xE8, 0x83, 0x19, 0xDC, 0x0F,  // .L>.....
                            /* 05B0 */  0x31, 0x1C, 0xB6, 0x2D, 0x9A, 0x43, 0x89, 0x83,  // 1..-.C..
                            /* 05B8 */  0x96, 0xA8, 0xD1, 0xE7, 0x4B, 0x6B, 0x33, 0x7D,  // ....Kk3}
                            /* 05C0 */  0x6A, 0x8D, 0xB6, 0xED, 0x8E, 0x3D, 0x76, 0x2B,  // j....=v+
                            /* 05C8 */  0xE7, 0xF3, 0x49, 0x07, 0x87, 0x47, 0x1A, 0x0F,  // ..I..G..
                            /* 05D0 */  0xC5, 0xE6, 0x3D, 0x70, 0xDC, 0x34, 0x85, 0x9B,  // ..=p.4..
                            /* 05D8 */  0xA9, 0xC2, 0xAC, 0x60, 0x98, 0x32, 0x91, 0xBE,  // ...`.2..
                            /* 05E0 */  0x9E, 0x2C, 0x8A, 0x3A, 0x98, 0xEB, 0x50, 0x45,  // .,.:..PE
                            /* 05E8 */  0x16, 0x45, 0xAB, 0x4F, 0x16, 0x90, 0x1A, 0x28,  // .E.O...(
                            /* 05F0 */  0xE4, 0x01, 0x04, 0xD4, 0xA4, 0x53, 0x73, 0xCD,  // .....Ss.
                            /* 05F8 */  0x67, 0x1B, 0xE3, 0xCE, 0xA4, 0xF1, 0x73, 0xD5,  // g.....s.
                            /* 0600 */  0x0C, 0xD0, 0x3B, 0x20, 0x29, 0x44, 0x76, 0xF1,  // ..; )Dv.
                            /* 0608 */  0xC1, 0xE0, 0x70, 0x2E, 0x2B, 0xBE, 0x53, 0xF5,  // ..p.+.S.
                            /* 0610 */  0xA8, 0x1A, 0xBB, 0x3A, 0xCA, 0xD6, 0x9A, 0x2E,  // ...:....
                            /* 0618 */  0xC6, 0x3A, 0x14, 0x73, 0x32, 0xDD, 0xDF, 0x6C,  // .:.s2..l
                            /* 0620 */  0xDD, 0xB8, 0x12, 0xBD, 0x64, 0x69, 0xFE, 0xD3,  // ....di..
                            /* 0628 */  0x5C, 0xB3, 0x39, 0x86, 0x7A, 0x83, 0xAC, 0x29,  // \.9.z..)
                            /* 0630 */  0x30, 0xEE, 0xBB, 0x22, 0x98, 0x4F, 0xEB, 0x9C,  // 0..".O..
                            /* 0638 */  0x4F, 0x9B, 0xC4, 0x4D, 0x77, 0x70, 0xB9, 0x97,  // O..Mwp..
                            /* 0640 */  0xC4, 0x0E, 0x8F, 0x77, 0x22, 0xB5, 0x42, 0x1A,  // ...w".B.
                            /* 0648 */  0x24, 0x24, 0xFA, 0x25, 0xD0, 0x90, 0x06, 0x65,  // $$.%...e
                            /* 0650 */  0x0E, 0x3B, 0x28, 0x9D, 0x7F, 0xA8, 0x08, 0x3A,  // .;(....:
                            /* 0658 */  0x0C, 0xF7, 0xED, 0xE1, 0x46, 0x8A, 0xC3, 0x13,  // ....F...
                            /* 0660 */  0xBA, 0x73, 0x83, 0x4D, 0xC6, 0x94, 0x21, 0x0F,  // .s.M..!.
                            /* 0668 */  0x42, 0xAD, 0x73, 0x69, 0x63, 0x41, 0xCC, 0xC0,  // B.sicA..
                            /* 0670 */  0xF4, 0x5E, 0x77, 0xCD, 0x34, 0xF0, 0x00, 0x19,  // .^w.4...
                            /* 0678 */  0x2D, 0xD6, 0x6C, 0xA8, 0xEC, 0xDD, 0xBA, 0xEF,  // -.l.....
                            /* 0680 */  0xC1, 0xCA, 0xFB, 0xA8, 0xE6, 0x36, 0xED, 0x11,  // .....6..
                            /* 0688 */  0x86, 0x83, 0xA2, 0xE3, 0xE1, 0x79, 0xF7, 0x64,  // .....y.d
                            /* 0690 */  0x84, 0x21, 0xA3, 0x30, 0x35, 0x7D, 0x42, 0xEE,  // .!.05}B.
                            /* 0698 */  0xA1, 0xF0, 0xEA, 0x37, 0xBD, 0x15, 0x2E, 0xDF,  // ...7....
                            /* 06A0 */  0xC8, 0x9A, 0x76, 0xDC, 0x0F, 0xAE, 0x00, 0x00   // ..v.....
                        }
                    })
                }

            }
        }

        Method (IMOK, 1, NotSerialized)
        {
            If (\_SB.PC00.LPCB.EC.MYEC)
            {
                \_SB.PC00.LPCB.EC.DTDR = One
                \_SB.PC00.LPCB.EC.DTOK = One
            }

            Return (Arg0)
        }
    }
}

