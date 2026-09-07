# PaperCraft — Figma Design Prompt
> AI-Powered Exam Paper Generator for Teachers  
> All screens derived from the actual Flutter codebase.

---

## App Overview

**App Name:** PaperCraft  
**Platform:** Mobile (iOS & Android) — Flutter  
**Primary Users:** Teachers / Educators  
**Core Feature:** AI generates exam papers from a teacher's books & chapters

---

## Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| Primary | `#534BDE` | Buttons, active states, icons |
| Primary Light | `#818CF8` | Tints, hover states |
| Primary Dark | `#3730A3` | Gradients |
| Success | `#10B981` | Confirmations, generated status |
| Success Light | `#D1FAE5` | Success bg tints |
| Error | `#EF4444` | Errors, delete actions |
| Error Light | `#FEE2E2` | Error bg tints |
| Warning | `#F59E0B` | Weightage warnings |
| Background | `#F7F8FC` | App background |
| White | `#FFFFFF` | Cards |
| Text Primary | `#1A1A2A` | Headlines, body |
| Text Secondary | `#6B7280` | Labels, subtitles |
| Text Tertiary | `#9CA3AF` | Hints, placeholders |
| Divider | `#E5E7EB` | Borders, separators |

### Typography — Inter Font

| Size | Weight | Usage |
|---|---|---|
| 11pt | SemiBold | Section labels (uppercase, letter-spaced) |
| 12pt | Regular | Captions, helper text |
| 13pt | Medium | Chip labels |
| 14pt | Regular | Body text, subtitles |
| 16pt | Bold | Card titles, list items |
| 18pt | Bold | AppBar titles, question text |
| 20pt | Bold | Dialog titles |
| 22pt | Bold | Screen headlines |
| 28pt | Bold | Home screen heading |

### Border Radius
- Cards: `20pt`
- Buttons: `14pt`
- Input fields: `14pt`
- Dialogs: `24pt`
- Bottom sheets top: `24pt`
- Pills/chips: `100pt` (full pill)
- Small chips: `8–12pt`

### Reusable Component Library

Create these as Figma components with variants:

- **PrimaryButton** — states: `Default` / `Loading (spinner)` / `Disabled (grey)`
- **CustomTextField** — states: `Default` / `Focused (primary border)` / `Error (red border)`
- **WorkspaceCard** — variants: `Normal` / `Add New (dashed border)`
- **SubjectCard** — grid format, variants: `Normal` / `Add New (dashed border)`
- **PaperCard** — with difficulty badge: `Easy (green)` / `Medium (orange)` / `Hard (red)`
- **BottomSheetBase** — drag pill + rounded top corners
- **SectionHeader** — grey uppercase, letter-spaced label
- **StatPill** — colored pill chip (primary / green / purple variants)
- **ProgressBar5Step** — 5 equal segments, filled segments in primary
- **WizardStepCard** — book or chapter row, states: `Selected` / `Unselected`
- **DeleteConfirmSheet** — red warning, cancel + delete buttons

---

## Screen Frames

Design all screens at **390×844pt** (iPhone 14). Use Auto Layout throughout. Group each screen in its own named Figma frame.

---

## SCREEN 01 — Login Screen

**Frame name:** `01 / Login`

### Layout (top to bottom):
1. **App Icon Area** (top-center, 40pt top padding):
   - Rounded rectangle `200×150pt`, bg: Primary `#534BDE` at 10% opacity, radius 20
   - Centered: `edit_document` icon, `64pt`, Primary color `#534BDE`

2. **App Name Row** (center-aligned):
   - `description` icon (primary, 24pt) + "PaperCraft" bold 28pt dark text
   - Below: "AI exam papers for teachers" — 14pt, Text Secondary

3. **Tab Switcher** (below headline, 40pt margin-top):
   - White rounded container, radius 16, internal padding 4pt
   - Tab 1 "Log In" → **Active**: solid Primary bg, white bold text, radius 12
   - Tab 2 "Sign Up" → **Inactive**: transparent, Text Secondary bold text
   - Full width, two tabs equal width

4. **Form Section** (32pt margin-top):
   - **EMAIL field**: label "EMAIL" uppercase 11pt grey, white bg field with `email_outlined` prefix icon, placeholder "teacher@school.edu"
   - **PASSWORD field**: label "PASSWORD", `lock_outline` prefix icon, placeholder "••••••••", eye-toggle suffix icon
   - Fields: white bg, radius 14, 1pt Divider border, focused state: 2pt Primary border

5. **"Forgot password?"** — right-aligned TextButton, Primary color, bold

6. **"Log In" CTA Button** (24pt margin-top):
   - Full width, Primary bg `#534BDE`, white bold text "Log In", radius 14, 56pt height
   - Loading state: "Logging in..." with small spinner

---

## SCREEN 02 — Sign Up Screen

**Frame name:** `02 / Sign Up`

Same layout as Login. Tab switcher: "Sign Up" tab is Active.

### Form fields:
- **NAME** — `person_outline` icon, placeholder "Your full name"
- **EMAIL** — `email_outlined` icon, placeholder "teacher@school.edu"
- **PASSWORD** — `lock_outline` icon + eye toggle

**CTA Button:** "Create Account" (same primary style)

---

## SCREEN 03 — Forgot Password Screen

**Frame name:** `03 / Forgot Password` (show all 3 steps as separate sub-frames or states)

### Step 1 — Send Code:
- Back arrow at top-left
- "Forgot Password" — 22pt bold
- Subtitle: "Enter your email and we'll send a reset code" — grey 14pt
- EMAIL field (same style as login)
- "Send Code" primary button

### Step 2 — Enter OTP:
- "Enter OTP" — 22pt bold
- Subtitle: "We sent a 6-digit code to your email" — grey
- **6 OTP boxes** in a horizontal row:
  - Each box: `44×56pt`, white bg, radius 10, 1pt Divider border
  - Focused box: 2pt Primary border + light Primary bg tint (`#534BDE` at 5%)
  - Bold 20pt centered text inside each
- "Resend Code" text link (primary, centered, below boxes)
- "Verify" primary button

### Step 3 — New Password:
- "Set New Password" — 22pt bold
- "NEW PASSWORD" field + "CONFIRM PASSWORD" field (password style, eye toggle)
- "Reset Password" primary button

---

## SCREEN 04 — Home Screen (My Workspaces)

**Frame name:** `04 / Home`

### Custom Header (no AppBar chrome):
- Left column:
  - "Good morning 👋" — 14pt bold, Text Secondary
  - "My Workspaces" — 28pt bold, Text Primary
- Right: Two circular icon buttons (side by side, 8pt gap):
  1. **AI Explore** button: `40×40pt` circle, Primary at 10% bg
     - Stacked icons: `search_rounded` (20pt, primary, bottom-center) + `auto_awesome` (10pt, primary, top-right corner)
  2. **Logout** button: `40×40pt` circle, Error `#EF4444` at 10% bg
     - `logout` icon (20pt, Error red)

### Workspace List (scrollable, 32pt margin-top):

Each **WorkspaceCard** (white bg, radius 20, subtle shadow):
- Height: ~88pt
- Left: `48×48pt` circle avatar — color cycles: Indigo / Green / Purple / Amber / Pink (backgrounds)
  - Icon inside: `folder_outlined` or `class_outlined` in matching accent color
- Center:
  - Workspace name — 16pt bold, Text Primary
  - "X subjects" — 13pt, Text Secondary
- Right: `more_vert` icon (3-dot vertical menu)
- Bottom stat chips row (inside card): "X Subjects" (indigo pill) + "0 Papers" (grey pill)
- 12pt vertical gap between cards

**"Add Workspace" card** (last item, dashed-border card):
- `_DashedBorderBox` style: grey dashed rounded border, transparent bg
- Row inside: `+` circle avatar (primary) + "New Workspace" (16pt bold, primary) + "Create a class or course" (grey)

### FAB:
- Bottom-right, standard size, Primary bg, white `+` icon

---

## SCREEN 05 — Subject Grid Screen

**Frame name:** `05 / Subjects Grid`

### AppBar:
- Back arrow (`arrow_back`) — left
- Two-line title (left-aligned):
  - "Workspace" — 12pt, Text Secondary
  - "[Workspace Name]" — 18pt bold, e.g. "Class 10 Science"

### 2-Column Grid (24pt padding, 16pt gap):

Each **SubjectCard** (white bg, radius 20, shadow, aspect ratio ~1.15):
- Subject icon circle (top area, colored: Indigo / Green / Purple / Amber / Red)
- Subject name — 15pt bold
- "X Books" — 12pt, Text Secondary
- Bottom-right corner: `more_vert` 3-dot menu

**"Add Subject" card** (dashed border, last item):
- Center: `+` icon (primary, 24pt) + "Add Subject" text (primary bold)

---

## SCREEN 06 — Subject Detail Screen

**Frame name:** `06 / Subject Detail`

### AppBar:
- Back arrow + Subject name as title

### Tab Bar (below AppBar):
- Tab 1: "Books" | Tab 2: "Papers"
- Material-style: underline indicator in Primary color, selected tab text is Primary, unselected is Text Secondary

---

### Tab 1 — Books:

List of book rows (white bg, rounded 16, 1pt Divider border, 12pt vertical gap):
- Left: `menu_book` icon circle (orange/amber, `48×48`)
- Center: Book name (16pt bold) + "X chapters" (13pt grey)
- Right: `more_vert` 3-dot (edit/delete)

**"Add Book" dashed card** at bottom — same dashed style, centered `+` + "Add Book" text

---

### Tab 2 — Papers:

Two sections stacked:

**Section: AI Generated**
- Section label: "AI GENERATED" — 11pt grey uppercase, letter-spaced

Each Paper card (white, radius 16, shadow):
- Paper title — 16pt bold
- Row of chips: difficulty badge (`Easy` green / `Medium` orange / `Hard` red pill) + marks chip (primary pill "80 marks") + date (grey, 12pt)
- Right: `more_vert` (Regenerate / Delete)

**Section: Reference Papers**
- Section label: "REFERENCE PAPERS" — same style

Each Reference card:
- Left: PDF icon (red, `40×40` circle bg)
- Center: title (16pt bold) + year + exam type tag
- Right: `more_vert` (Delete)

**FAB:** Bottom-right, "✨ Create Paper" (primary, `auto_awesome` icon + "+" icon)

---

## SCREEN 07 — Book Chapters Screen

**Frame name:** `07 / Book Chapters`

### AppBar:
- Back arrow
- Book name title + subject name subtitle

### Upload Document Card (white, radius 16, Primary border at 40%):
- Left: `upload_file` icon (primary, circle bg)
- Center: "Upload Textbook PDF" (bold) + "AI will extract and index chapters automatically" (grey, 12pt)
- Right: "Pick File" outlined button (primary border, primary text)
- Document status row (below, conditional):
  - "Processing..." amber pill with spinner
  - "Ready" green pill with check icon
  - "Failed" red pill with error icon

### Chapters List (scrollable):

Each chapter row (white, radius 12, 1pt Divider border):
- Left: numbered circle (primary, small, e.g. "1")
- Chapter name — 15pt medium
- Right: `edit` icon (grey) + `delete_outline` icon (red)
- Drag handle (`drag_handle`) on far right

**"+ Add Chapter"** row at bottom (primary color, 14pt)

---

## SCREEN 08 — Paper Wizard · Step 1 of 5 — Book & Chapters

**Frame name:** `08 / Wizard Step 1 - Book & Chapters`

### AppBar:
- Back arrow
- Two-line title (left):
  - "Step 1 of 5" — 12pt, Text Secondary
  - "Book & Chapters" — 18pt bold

### Progress Bar (below AppBar, 24pt horizontal padding):
- 5 equal segments, 4pt height, radius 2
- Segment 1: filled Primary `#534BDE`
- Segments 2–5: Divider grey `#E5E7EB`
- 8pt gap between segments

### Content (scrollable, 24pt padding):

**"CHOOSE BOOK" label** — 12pt grey uppercase, 1.2 letter-spacing

Book selection cards (stacked vertically, 12pt gap):
- **Unselected:** white bg, radius 16, 1pt Divider border
  - Left: circle avatar (grey bg, `menu_book` grey icon)
  - Center: book name (16pt, Text Primary)
  - Right: (no icon)
- **Selected:** 2pt Primary border, light Primary bg tint
  - Left: circle avatar (Primary tint bg, `menu_book` primary icon)
  - Center: book name (16pt, Primary color)
  - Right: `check_circle_outline` (primary)

**After book selected → "CHOOSE CHAPTERS" section appears:**

Header row: "CHOOSE CHAPTERS" label + "Select All" / "Deselect All" text button (Primary, right-aligned)

**Chapter Weightage Toggle Card** (white, radius 16, 1pt Divider border):
- Row: pie chart icon box (grey bg → Primary bg when active) + "Chapter Weightage" (14pt bold) + subtitle + Toggle switch (Primary when on)
- **Expanded (when ON):**
  - Divider
  - Status row: check/warning icon + "Total: X%" text (green if 100%, orange otherwise)
  - "Adjust All" text button + "Equalize" text button (right side)

Chapter rows (12pt gap):
- **Unselected:** `check_circle_outline` grey icon + chapter name (grey)
- **Selected:** `check_circle` primary icon + chapter name (Text Primary bold)
- **Selected + weightage on:** right-side pill badge: "X% ⚙" (primary tinted bg, primary border, primary text, 12–13pt)

### Bottom Sticky Area:
- Error hint (red, 12pt, bold): "Total weightage must equal 100% to continue" — shows only when needed
- **"Continue →"** primary button (full width, disabled/grey when invalid)

---

## SCREEN 09 — Paper Wizard · Step 2 of 5 — Marks

**Frame name:** `09 / Wizard Step 2 - Marks`

### AppBar: "Step 2 of 5" / "Marks"

### Progress Bar: 2 of 5 filled

### Content:

**"TOTAL MARKS"** — 12pt grey uppercase label

Large number input field:
- White bg, radius 14, Divider border
- 18pt bold text, placeholder "e.g. 80"
- Keyboard: numeric

Helper text: "The total marks of the paper. AI will distribute marks across sections and questions." — 12pt grey

**"QUICK PRESETS"** — 12pt grey uppercase label (32pt margin-top)

Horizontal wrap of pill chips: `20` / `40` / `50` / `60` / `80` / `100`
- **Selected:** Primary bg + white bold text
- **Unselected:** white bg + Divider border + Text Primary

### Bottom: "Continue →" primary button (disabled if field empty or invalid)

---

## SCREEN 10 — Paper Wizard · Step 3 of 5 — Reference Papers

**Frame name:** `10 / Wizard Step 3 - Reference Papers`

### AppBar: "Step 3 of 5" / "Reference Papers"

### Progress Bar: 3 of 5 filled

### Two tabs: "Existing Papers" | "Upload New"

---

**Tab: Existing Papers**

Sub-segmented: "Reference Papers" | "AI Generated" (inner smaller tab row)

Paper cards (selectable, white, radius 16):
- **Unselected:** 1pt Divider border, radio circle outline (grey)
- **Selected:** 2pt Primary border, `check_circle` (primary), light Primary bg tint

**"Skip" dashed card** (last item):
- Dashed grey border, centered: `skip_next` icon + "No reference paper (skip)" grey text

---

**Tab: Upload New**

Form fields:
- "Paper Title" — text field
- "Year" — numeric field (placeholder "2024")
- "Exam Type" — text field (placeholder "e.g. Final Term, Mid-Term")

**"Pick PDF"** outlined button (primary border, `picture_as_pdf` icon, primary text)

### Bottom: "Continue →" button

---

## SCREEN 11 — Paper Wizard · Step 4 of 5 — Difficulty

**Frame name:** `11 / Wizard Step 4 - Difficulty`

### AppBar: "Step 4 of 5" / "Difficulty"

### Progress Bar: 4 of 5 filled

### Content: "DIFFICULTY LEVEL" label

Three selectable cards (stacked, 12pt gap, white, radius 20):

| Card | Icon | Accent Color | Title | Subtitle |
|---|---|---|---|---|
| 1 | `sentiment_satisfied` | `#10B981` Green | Easy | Suitable for basic understanding |
| 2 | `sentiment_neutral` | `#F59E0B` Amber | Medium | Balanced challenge for students |
| 3 | `sentiment_dissatisfied` | `#EF4444` Red | Hard | Advanced and exam-level rigor |

**Unselected card:** 1pt Divider border, white bg, icon in grey circle
**Selected card:** 2pt colored border, light colored bg tint, `check_circle_outline` (matching color, top-right)

### Bottom: "Continue →" button (disabled if no difficulty selected)

---

## SCREEN 12 — Paper Wizard · Step 5 of 5 — Format

**Frame name:** `12 / Wizard Step 5 - Format`

### AppBar: "Step 5 of 5" / "Format"

### Progress Bar: all 5 segments filled (Primary)

### Content: "PAPER STRUCTURE" label

Three expandable format cards:

---

**Card 1 — MCQ Only**
- Icon: `grid_view`, Primary `#534BDE`
- Title: "MCQ Only", Subtitle: "Multiple choice with 4 options"
- Right: `expand_more` (collapsed) or `check_circle_outline` Primary (selected)

**Expanded state:**
- Divider
- "QUESTIONS" count display (auto-calculated, large bold) — left
- "MARKS EACH" stepper (`–` / value / `+`) — right
- Red warning text if marks not divisible: "Total marks (X) not divisible by Y"
- Extra options (see below)

---

**Card 2 — Questions Only**
- Icon: `format_list_bulleted`, Success green `#10B981`
- Title: "Questions Only", Subtitle: "Short and long answer questions"

**Expanded state:**
- Divider
- Three question-type rows (Very Short / Short / Long):
  - Row layout: label (14pt) | Marks stepper (`–`/value/`+`) | Count stepper (`–`/value/`+`)
- Total Marks Used chip:
  - Green bg if `used == total`
  - Red bg if mismatch
  - Shows "X / Y" value in matching color
- "+X more marks" or "Remove X marks" error hint (red, 12pt) if mismatch
- Extra options (see below)

---

**Card 3 — Hybrid Mix**
- Icon: `dashboard_customize`, Purple `#9333EA`
- Title: "Hybrid Mix", Subtitle: "MCQ combined with written questions"

**Expanded state:**
- Same row pattern for: MCQ / Very Short / Short / Long
- Same Total Marks chip + error hint
- Extra options (see below)

---

**Extra Format Options** (inside each expanded card, below the main config):

Toggle row 1 — "Alternative Questions":
- `shuffle` icon + "Alternative Questions" (14pt bold) + "Include OR choices per question" (12pt grey) + Toggle switch

Toggle row 2 — "Numerical Questions":
- `calculate` icon + "Numerical Questions" (14pt bold) + "Include numerical/calculation-based questions" + Toggle switch
- When ON: Slider `0–100%` appears below (primary thumb, shows "X% numerical")

### Bottom CTA: "Generate Paper ✨" full-width primary button with `auto_awesome` icon (disabled if format not valid)

---

## SCREEN 13 — Generate Paper Dialog

**Frame name:** `13 / Generate Paper Dialog`

Full-screen with blurred/dimmed scrim behind a centered dialog.

**Dialog** (white bg, radius 24, 24pt padding):
- Icon: circle container (Primary at 15% bg) with `edit_document` icon (32pt, primary)
- Title: "Name your paper" — 20pt bold, centered
- Subtitle: "Give your new exam paper a title." — 14pt grey, centered

**Fields:**
- Paper Title: large text field (white bg, radius 16, no border — filled style), bold 16pt, placeholder "e.g. Mid-Term Exam 2025", centered text
- Two-column row:
  - "Academic Level" field (60% width): border style, placeholder "e.g. Class 8", floating label
  - "Minutes" field (40% width): numeric, placeholder "180", floating label

**Button row:**
- "Cancel" — text button (grey, left)
- "Generate" — primary filled button (right)

---

## SCREEN 14 — Generating Loader Screen

**Frame name:** `14 / Generating Loader`

Full-screen, white/light background.

- **Center animation:** Pulsing concentric rings around a sparkle `auto_awesome` icon (Primary color, 48pt), rings animate opacity 0→1 repeatedly
- "Generating your paper..." — 18pt bold, 24pt below animation
- "Our AI is crafting your exam — this may take a moment" — 14pt grey, centered
- Paper title shown as a Primary color pill badge (e.g. "Mid-Term Exam 2025")

---

## SCREEN 15 — Paper Result Screen ("Paper Ready! 🎉")

**Frame name:** `15 / Paper Result`

### Custom Top Bar (no AppBar chrome):
- Left: `arrow_back` icon button (24pt, Text Primary)
- Center-left:
  - Subject name — 12pt, Text Secondary
  - "Paper Ready! 🎉" — 22pt bold
- Right: "✓ Generated" success pill (Success green `#10B981`, white text, `check` icon left, pill shape)

### Paper Preview Card (white, radius 24, soft shadow):
- **Gradient accent bar at top:** 6pt height, full width, `LinearGradient`: Primary Dark → Primary Light → Cyan `#06B6D4`
- Inside (24pt padding, center-aligned):
  - Subject name — 11pt, Text Tertiary, uppercase, letter-spaced
  - Paper title — 18pt bold
  - "Subject: X" — 14pt grey
  - **3-stat row** (equal columns, vertical dividers):
    - `QUESTIONS` / count
    - `MAX. MARKS` / count
    - `DIFFICULTY` / level text (capitalized)
  - Divider
  - **Section breakdown rows** (left-aligned):
    - Colored initial circle (e.g. "A" for Section A) + section name (bold) + marks count chip (right) + "X Qs" count chip

### Stats Pills Row (3 chips):
- "X Questions" — Primary bg
- "X Chapters" — Success green bg
- "X Total Marks" — Purple `#9333EA` bg
- All chips: white text, 8pt padding horizontal

### Action Buttons (2 tappable cards, equal width, 12pt gap):

**Card 1 — Preview PDF:**
- White bg, radius 20, 1pt Divider border
- `picture_as_pdf` icon (primary, circle bg)
- "Preview PDF" — 14pt bold
- "View full paper" — 12pt grey

**Card 2 — Regenerate:**
- White bg, radius 20, 1pt Divider border
- `autorenew` icon (purple `#9333EA`, circle bg)
- "Regenerate" — 14pt bold
- "Generate again" — 12pt grey

### "Edit Paper" full-width outlined button:
- White bg, Primary border, Primary text, `edit` icon left, radius 14

---

## SCREEN 16 — PDF Preview Screen

**Frame name:** `16 / PDF Preview`

### AppBar:
- "Paper Preview" — 18pt bold
- Right actions:
  - `edit` icon button (edit questions — grey)
  - "Save PDF" text button — Primary color
    - Loading state: small spinner + "Saving..."
    - Saved state: "✓ Saved" in Success green

### Body:
- White paper render (full width, left/right 16pt padding), subtle shadow
- Paper shows formatted exam: header (school name, subject, class, time, marks), questions by section
- Scroll vertically for multi-page
- Light grey canvas background `#F3F4F6`

### Bottom Action Bar:
- White bar pinned to bottom (16pt padding):
  - "Edit Paper" button (full width, outlined, pencil icon)
  - Tapping opens bottom sheet

### Bottom Sheet — Edit Paper:
- Drag pill (40×4pt, grey, centered)
- "Edit Paper" — 20pt bold + "Customize your exam paper appearance" — 13pt grey

**Logo Section Card** (grey bg `#F9FAFB`, radius 16, 1pt grey border):
- Left: `64×64pt` logo preview box (white, radius 12):
  - Empty: `image_outlined` grey icon inside
  - Filled: cropped logo image
  - Border: Primary 2pt if logo present, grey 1pt if empty
- Right:
  - "Institution Logo" — 14pt bold
  - "Will appear in top-right corner of PDF" — 12pt (grey when empty, green when logo uploaded)
  - Button row: "Upload" / "Change" gradient button (Primary Dark → Primary Light, radius 8) + "Remove" grey text button

**"Edit Questions"** list tile (row, `edit` icon, primary text, right arrow)

**"Visual Designer"** list tile (row, `palette` icon, primary text, right arrow)

---

## SCREEN 17 — Paper Editor Screen

**Frame name:** `17 / Paper Editor`

### AppBar:
- "Edit Paper" — 18pt bold
- Right: "Save" text button — Primary color, bold

### Body (scrollable):

**"General Info" section header** — grey uppercase label

- **Paper Title** text field (white, radius 12)
- **Two-column row:**
  - "Academic Level (e.g. Class 8)" field (60%)
  - "Time (mins)" numeric field (40%)
- **Total Marks (Auto-calculated) info row:**
  - Light Primary tint bg (`#534BDE` at 10%), rounded 8, Primary border
  - Left: "Total Marks (Auto-calculated)" — 13pt medium
  - Right: calculated number — bold Primary color

**Question Cards** (white bg, radius 12, 1pt Divider border, soft shadow, 12pt vertical gap):

Each card structure:
- **Card header row:** "Q1" or "Q2" (small grey label) + question type badge (pill: "MCQ" indigo / "Short Answer" green / "Long Answer" purple)
- **Question text:** multi-line editable TextField (no border inside card)
- **If MCQ:** 4 option rows:
  - Radio circle + "Option A:" label + text field
  - Selected/correct option radio filled Primary
- **Marks row:** "MARKS" label + stepper (`–` / value / `+`)
- **If "OR" alternative:** Divider + "OR" badge + second block of same structure
- **Delete button:** `delete_outline` (red, 20pt) top-right corner of card

**"+ Add Question"** row at bottom (primary text, `add_circle_outline` icon)

---

## SCREEN 18 — Visual Designer Screen

**Frame name:** `18 / Visual Designer`

### AppBar:
- "Visual Designer" — 18pt bold
- Right: "Done" — Primary text button

### Body — Canvas:
- Light grey canvas background
- PDF page rendered as full-width white image layer with shadow
- **Draggable elements** overlaid on canvas:
  - Logo element: image with selection border (2pt Primary blue dashed border) + corner resize handles when selected
  - Text stamp: rounded text box, draggable, selection border when active
- Pinch-to-zoom gesture on selected element

### Bottom Toolbar (pinned, white bg, top border):
- 4 icon buttons (equal spacing):
  - `text_fields` — Add Text (label below: "Text", grey 11pt)
  - `add_photo_alternate` — Add Logo (label: "Logo")
  - `image` — Add Image (label: "Image")
  - `delete_outline` — Remove (label: "Remove", red color — disabled grey when nothing selected)

---

## SCREEN 19 — Explore PYQs Screen (AI Search)

**Frame name:** `19 / Explore PYQs` _(Dark Mode)_

> This screen uses a unique dark purple color palette.

### Dark Palette (this screen only):
- Background: `#090912`
- Surface: `#12121F`
- Card: `#1A1A2E`
- Input bg: `#1E1E30`
- Border: `#2E2E50`
- Purple accent: `#9B5CFF`
- Text: `#EEEEFF`
- Text Sub: `#8888AA`
- Error: `#FF5C7A`

### AppBar (dark bg):
- Left: `arrow_back_ios_new` icon (white, 20pt)
- Title row: sparkle-search icon (purple, 18pt) + "Explore PYQs" (white, 17pt bold)
- Right: history icon button with **download count badge**:
  - `history` icon (white)
  - Count badge: purple pill (`#9B5CFF` bg, white bold text), positioned top-right of icon

### Body — AI Prompt Interface:

**Hero area (center of screen):**
- Animated pulsing glow circle (purple `#9B5CFF` at 20–40% opacity, radial gradient) — animate radius pulse
- Inside: `auto_awesome` or custom search-stars icon (purple, 32pt)
- "Ask AI for Past Papers" — 22pt bold white, centered, 20pt below glow
- "Type what you need — board, subject, year, class" — 14pt text sub, centered

**States (conditional display):**

- **Loading state:** pulsing animation continues + "Searching AI resources..." (14pt, purple) below
- **Result card** (surface dark `#1A1A2E`, radius 16, border `#2E2E50`):
  - AI response text (white, 14pt)
  - "Download PDF" filled button (purple bg, white text) — if PDF available
  - "Open File" outlined button (purple border) — after download
- **Error card** (error bg `#22FF5C7A`, radius 12):
  - `error_outline` icon (red) + error message (red `#FF5C7A`)

### Bottom Input Bar (fixed to bottom):
- Background: `#1E1E30`, radius 20, 1pt border `#2E2E50`
- Multi-line text field: "e.g. CBSE Class 10 Maths 2023 papers..." — grey placeholder
- **Send button** (right-side, circle, purple bg `#9B5CFF`):
  - `arrow_upward` icon (white, 20pt)
  - Disabled/transparent when text empty
  - Activated/purple when text present

---

## SCREEN 20 — Download History Bottom Sheet

**Frame name:** `20 / Download History Sheet` _(attaches to Explore screen)_

**Dark-themed bottom sheet** (bg `#12121F`, radius top 28, drag pill `#2E2E50`):

- Drag pill (40×4pt, `#2E2E50`, top center)
- "Download History" — 18pt bold white
- "X downloads" — 13pt, Text Sub grey

**PDF list rows** (12pt vertical gap):
- Left: PDF icon circle (purple tint bg, `picture_as_pdf` purple icon)
- Center: filename (white, 14pt bold) + relative time (grey, 12pt, e.g. "2h ago", "Just now")
- Right: "Open" text button (purple `#9B5CFF`, 13pt bold)

**Empty state:**
- Centered: `download_done` icon (grey, 40pt) + "No downloads yet" grey text

---

## BOTTOM SHEETS (Reusable)

All bottom sheets: white bg, radius-top 24, drag pill (40×4pt grey, centered at top), max-height 85% screen.

---

### Add Workspace Sheet
- Title: "New Workspace" — 18pt bold
- "Workspace Name" text field + "Description" multi-line field (optional)
- "Create Workspace" — primary button (full width)

### Edit Workspace Sheet
- Title: "Edit Workspace" — 18pt bold
- Pre-filled fields (same as Add)
- "Save Changes" — primary button

### Add Subject Sheet
- Title: "Add Subject" — 18pt bold
- "Subject Name" field + "Description" field
- "Add Subject" — primary button

### Edit Subject Sheet
- Pre-filled Subject fields
- "Save Changes" — primary button

### Add Book Sheet
- "Book Title" field + "Author" field (optional)
- "Add Book" — primary button

### Edit Book Sheet
- Pre-filled Book fields
- "Save Changes" — primary button

### Delete Confirmation Sheet
- Drag pill + centered warning icon (red circle, `warning_amber_rounded` icon, 32pt)
- Title: e.g. "Delete Workspace?" — 20pt bold
- Description: "Are you sure you want to delete '[name]'? All subjects and papers inside will be permanently deleted." — 14pt grey
- Button row:
  - "Cancel" — outlined grey button (50%)
  - "Delete" — error red filled button (50%)

### Chapter Weightage Bottom Sheet
- Drag pill
- Header: "Chapter Weightage" — 18pt bold + "Adjust percentages to total 100%" — 12pt grey
- **Total weightage status banner** (rounded 12, colored bg):
  - Green (success tint) if total == 100%: `check_circle` green icon + "Total Weightage: 100%" green bold
  - Orange (warning tint) if not 100%: `warning_amber_rounded` amber icon + "Total Weightage: X%" amber bold
  - Right: "Equalize" text button (primary, `restart_alt` icon)
- **Segmented color bar** (10pt height, radius 6, full width):
  - Each chapter gets proportional colored segment based on its weightage %
  - Colors cycle: Indigo / Sky / Emerald / Amber / Purple / Pink / Teal / Orange
- **Chapter slider rows** (scrollable list):
  - Row 1: colored dot (10pt circle) + chapter name (14pt bold) + "X%" pill badge (right, colored)
  - Row 2: `remove_circle_outline` icon | Slider (colored thumb + active track) | `add_circle_outline` icon
  - 5% step increments; focused chapter gets subtle colored bg
- "Done" — primary full-width button (pinned bottom)

---

## PROTOTYPE FLOW

Connect frames with interaction arrows in the Figma prototype panel:

```
Login ──[Tab: Sign Up]──▶ Sign Up
Login ──[Forgot password?]──▶ Forgot Password
Login ──[Log In]──▶ Home
Sign Up ──[Tab: Log In]──▶ Login
Sign Up ──[Create Account]──▶ Home

Home ──[tap workspace card]──▶ Subjects Grid
Home ──[tap AI Explore button]──▶ Explore PYQs
Home ──[tap + FAB]──▶ Add Workspace Sheet (overlay)
Home ──[3-dot ▶ Edit]──▶ Edit Workspace Sheet
Home ──[3-dot ▶ Delete]──▶ Delete Confirm Sheet

Subjects Grid ──[tap subject card]──▶ Subject Detail
Subjects Grid ──[tap Add Subject card]──▶ Add Subject Sheet

Subject Detail Books Tab ──[tap book card]──▶ Book Chapters
Subject Detail Books Tab ──[3-dot ▶ Edit]──▶ Edit Book Sheet
Subject Detail Papers Tab ──[tap AI paper]──▶ PDF Preview
Subject Detail Papers Tab ──[tap Create Paper FAB]──▶ Wizard Step 1

Wizard Step 1 ──[Continue]──▶ Wizard Step 2
Wizard Step 2 ──[Continue]──▶ Wizard Step 3
Wizard Step 3 ──[Continue]──▶ Wizard Step 4
Wizard Step 4 ──[Continue]──▶ Wizard Step 5
Wizard Step 5 ──[Generate Paper ✨]──▶ Generate Paper Dialog
Generate Paper Dialog ──[Generate]──▶ Generating Loader
Generating Loader ──[auto]──▶ Paper Result

Paper Result ──[Preview PDF]──▶ PDF Preview
Paper Result ──[Edit Paper]──▶ Paper Editor
PDF Preview ──[Edit Questions]──▶ Paper Editor
PDF Preview ──[Visual Designer]──▶ Visual Designer

Explore PYQs ──[history icon]──▶ Download History Sheet (overlay)
```

---

## Additional Notes for Figma AI

- Use **8pt grid** for all spacing
- All interactive elements must have **hover** and **pressed** states
- Use **Auto Layout** with proper padding/gap on every frame
- Group assets into a `🎨 Styles` page with color styles and text styles
- Group all components into a `🧩 Components` page
- Name all layers descriptively (no "Frame 123")
- Set prototype device to **iPhone 14** in presentation mode
