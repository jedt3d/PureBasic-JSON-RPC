**PRD: SevenSegmentClock Gadget**

**Purpose**
สร้าง custom gadget บน PureBasic ที่แสดงเวลาจริงของเครื่องในรูปแบบ digital seven-segment clock โดยใช้ `CanvasGadget()` และฟอนต์ DSEG7 แบบ bundled มากับโปรเจกต์

**Scope**
- สร้าง gadget ใช้งานได้จริงบน PureBasic 6.40
- Cross-platform เท่าที่ `CanvasGadget()` และ font rendering ของ PureBasic รองรับ
- ยังไม่ผูกกับ JSON-RPC, MCP, หรือโปรเจกต์อื่น
- เป็น gadget ตัวแรกเพื่อพิสูจน์ pattern สำหรับ custom gadget toolkit ในอนาคต

**Core Behavior**
- แสดงเวลา local machine เป็น `HH:MM:SS`
- อัปเดตทุก `1000 ms`
- ใช้ฟอนต์ DSEG7 Classic และ DSEG7 Modern
- Colon ระหว่าง `HH:MM` แสดงคงที่
- Colon ระหว่าง `MM:SS` กระพริบทุกวินาที
- คลิกที่ gadget เพื่อสลับ theme ระหว่าง light/dark
- สี foreground, background, และ border invert อัตโนมัติเมื่อคลิก

**Visual Requirements**
- ใช้ฟอนต์ DSEG7 series แบบ bundled `.ttf`
- รองรับ font family:
  - `DSEG7Classic`
  - `DSEG7Modern`
- รองรับ font weight อย่างน้อย:
  - `Regular`
  - `Bold`
- ขนาด font คำนวณอัตโนมัติจากพื้นที่ว่าง ไม่ให้ user ตั้ง font size ตรง ๆ
- มี border thickness เท่ากันทุกด้าน
- มี padding เท่ากันทุกด้าน
- พื้นที่วาด clock คำนวณจาก:

```text
contentW = gadgetW - (borderThickness * 2) - (padding * 2)
contentH = gadgetH - (borderThickness * 2) - (padding * 2)
```

- ใช้ข้อความวัดขนาดเป็น `"88:88:88"` เพื่อหา font size ที่ใหญ่ที่สุดที่พอดี
- ถ้าพื้นที่ไม่พอ ต้องไม่ crash และควรวาด background/border เป็น fallback

**Default Configuration**
```text
font family: DSEG7Classic
font weight: Regular
foreground: white
background: black
border: gray
border thickness: 1 px
padding: 8 px
inverted: false
update interval: 1000 ms
```

**Public API Draft**
```purebasic
SevenSegmentClock::Create(Gadget, Window, x, y, width, height)
SevenSegmentClock::Free(Gadget)

SevenSegmentClock::SetFontFamily(Gadget, FontFamily)
SevenSegmentClock::GetFontFamily(Gadget)

SevenSegmentClock::SetFontWeight(Gadget, FontWeight)
SevenSegmentClock::GetFontWeight(Gadget)

SevenSegmentClock::SetBorder(Gadget, Color, Thickness)
SevenSegmentClock::SetPadding(Gadget, Padding)

SevenSegmentClock::SetColors(Gadget, Foreground, Background, Border)

SevenSegmentClock::SetInverted(Gadget, State)
SevenSegmentClock::GetInverted(Gadget)

SevenSegmentClock::Resize(Gadget, x, y, width, height)
SevenSegmentClock::Redraw(Gadget)
```

**State Model**
```purebasic
Structure SevenSegmentClockState
  GadgetID.i
  WindowID.i
  TimerID.i
  Width.i
  Height.i

  FontFamily.i
  FontWeight.i
  FontID.i
  FontSize.i

  ForegroundColor.i
  BackgroundColor.i
  BorderColor.i
  BorderThickness.i
  Padding.i

  Inverted.b
  BlinkOn.b
  LastText.s
EndStructure
```

**Event Model**
- `#PB_Event_Timer`
  - อ่านเวลาปัจจุบัน
  - toggle `BlinkOn`
  - redraw
- `#PB_EventType_LeftButtonDown` หรือ `#PB_EventType_LeftClick`
  - toggle `Inverted`
  - redraw
  - optionally `PostEvent(#PB_Event_Gadget, ..., #PB_EventType_Change)`
- Resize ผ่าน API `Resize()`
  - resize canvas
  - recalculate font size
  - redraw

**Font And License Requirements**
- Bundle DSEG `.ttf` ในโปรเจกต์
- Bundle license file ของ DSEG
- เพิ่ม attribution ให้ชัดเจนว่า DSEG สร้างโดย keshikan
- ใช้ตาม SIL Open Font License 1.1
- Reference: [DSEG GitHub](https://github.com/keshikan/DSEG)

**Development Phases**

**Phase 1: Minimal Working Gadget**
- สร้าง `SevenSegmentClock` module
- สร้าง `Create()`, `Free()`, `Redraw()`
- ใช้ `CanvasGadget()`
- แสดงเวลาจริง `HH:MM:SS`
- update ทุก 1000 ms
- ใช้สี default white-on-black
- ยังไม่ต้องมี font switching

**Phase 2: Bundled DSEG Font Support**
- เพิ่ม folder fonts และ license
- register/load DSEG7 Classic Regular
- render clock ด้วย DSEG font
- คำนวณ font size อัตโนมัติจาก gadget size
- ใช้ `"88:88:88"` เป็น measurement baseline

**Phase 3: Layout Controls**
- เพิ่ม border thickness
- เพิ่ม padding
- เพิ่ม `SetBorder()`
- เพิ่ม `SetPadding()`
- ทำ fallback เมื่อ content area เล็กเกินไป
- ทดสอบหลายขนาด gadget

**Phase 4: Interaction And Blink**
- เพิ่ม click-to-invert theme
- invert foreground/background/border อัตโนมัติ
- เพิ่ม colon กระพริบเฉพาะระหว่าง `MM` กับ `SS`
- ทำให้ colon blink ไม่ทำให้ layout ขยับ โดยแทน `:` ด้วย space

**Phase 5: Font Options**
- เพิ่ม DSEG7 Classic/Modern
- เพิ่ม Regular/Bold
- เพิ่ม `SetFontFamily()` และ `SetFontWeight()`
- recalculate font size หลังเปลี่ยน font
- redraw ทันทีหลังเปลี่ยนค่า

**Phase 6: Hardening And Example App**
- เพิ่ม example app สำหรับลอง gadget
- ทดสอบ create/free หลาย instance
- ทดสอบ resize
- ตรวจ memory lifecycle
- ตรวจ font load fallback
- สรุป API และ usage documentation

**Acceptance Criteria**
- เปิด app แล้วเห็นนาฬิกา seven-segment ชัดเจน
- เวลาเดินตามเวลาของเครื่อง
- วินาทีเปลี่ยนทุก 1000 ms
- colon ระหว่างนาทีกับวินาทีกระพริบ
- colon ระหว่างชั่วโมงกับนาทีไม่กระพริบ
- คลิกแล้วสี foreground/background/border invert
- เปลี่ยน Classic/Modern ได้
- เปลี่ยน Regular/Bold ได้
- border และ padding มีผลต่อพื้นที่วาดจริง
- resize แล้ว font scale ตามพื้นที่อย่างเหมาะสม
- มี font license และ attribution ครบถ้วน
- ไม่พึ่ง C/C++ หรือ native OS API โดยตรง