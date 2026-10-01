import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-features',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section id="features" class="section-padding features-section border-t border-white/5 relative overflow-hidden">
      <div class="container-custom relative z-10">
        
        <!-- Section Header -->
        <div class="features-header max-w-3xl mx-auto text-center">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-brand-500/20 bg-brand-500/10 text-brand-300 text-xs font-semibold mb-4 tracking-wide uppercase">
            <span class="w-1.5 h-1.5 rounded-full bg-brand-400 animate-pulse"></span>
            Academic Assessment Architecture
          </div>
          <h2 class="section-title font-display font-extrabold tracking-tight text-white mb-4">
            Engineered with Deep <br/>
            <span class="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-indigo-300 to-cyan-300">
              Curriculum Grounding & Precision
            </span>
          </h2>
          <p class="section-desc">
            Papervisor combines semantic chapter summarization with intelligent blueprint mimicry to generate verified, board-standard question papers in minutes.
          </p>
        </div>

        <!-- 6 Uniform Square Feature Cards Grid (3x2 Desktop, 2x3 Tablet, 1x6 Mobile) -->
        <div class="features-grid">

          <!-- Card 1: Reference Paper Blueprint -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                    <line x1="10" y1="9" x2="8" y2="9"/>
                  </svg>
                </div>
                <span class="card-badge">BLUEPRINT MIMICRY</span>
              </div>

              <h3 class="card-title">Past Paper Blueprint & Pattern Mimicry</h3>
              <p class="card-desc">
                Upload past institutional or board question papers. The engine reverse-engineers the exact section cadence and style.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <div class="flex items-center gap-2">
                  <span class="status-dot dot-active"></span>
                  <span class="preview-filename font-mono">Board_Physics_2025.pdf</span>
                </div>
                <span class="preview-pill">PARSED</span>
              </div>
              <div class="preview-grid">
                <div class="preview-stat">
                  <span class="stat-label">Sec A</span>
                  <span class="stat-value font-mono">16 MCQs • 16M</span>
                </div>
                <div class="preview-stat">
                  <span class="stat-label">Sec B</span>
                  <span class="stat-value font-mono">5 Short • 10M</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Card 2: Section Balancing -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="20" x2="18" y2="10"/>
                    <line x1="12" y1="20" x2="12" y2="4"/>
                    <line x1="6" y1="20" x2="6" y2="14"/>
                  </svg>
                </div>
                <span class="card-badge">UNIFORM DIFFICULTY</span>
              </div>

              <h3 class="card-title">Per-Section Uniform Difficulty Balancing</h3>
              <p class="card-desc">
                Ensures difficulty percentages are distributed uniformly within <em>every single section</em>, avoiding uneven papers.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <span class="preview-filename">Difficulty Ratio: 30% E / 50% M / 20% H</span>
              </div>
              <div class="preview-bars">
                <div class="bar-row">
                  <span class="bar-label font-mono">MCQs</span>
                  <div class="bar-track">
                    <div class="segment-easy" style="width: 30%"></div>
                    <div class="segment-med" style="width: 50%"></div>
                    <div class="segment-hard" style="width: 20%"></div>
                  </div>
                </div>
                <div class="bar-row">
                  <span class="bar-label font-mono">Long</span>
                  <div class="bar-track">
                    <div class="segment-easy" style="width: 30%"></div>
                    <div class="segment-med" style="width: 50%"></div>
                    <div class="segment-hard" style="width: 20%"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Card 3: Semantic Chapter Indexing -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"/>
                    <path d="M6 6h10"/>
                    <path d="M6 10h10"/>
                    <path d="m14 14 2 2 4-4"/>
                  </svg>
                </div>
                <span class="card-badge">SUB-SECOND PIPELINE</span>
              </div>

              <h3 class="card-title">Fast Semantic Chapter Summarization</h3>
              <p class="card-desc">
                Upload multi-hundred page textbooks. Structured concept summaries and formulas are extracted without hallucination.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <div class="flex items-center gap-2">
                  <span class="status-dot dot-active"></span>
                  <span class="preview-filename font-mono">NCERT_Physics_Ch3.pdf</span>
                </div>
                <span class="preview-pill">INDEXED</span>
              </div>
              <div class="chips-wrap">
                <span class="chip-item">⚡ Kirchhoff's Laws</span>
                <span class="chip-item">🔋 Internal Resistance</span>
                <span class="chip-item">📐 Wheatstone Bridge</span>
              </div>
            </div>
          </div>

          <!-- Card 4: Visual Canvas & Branding -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 20h9"/>
                    <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
                  </svg>
                </div>
                <span class="card-badge">INSTITUTIONAL GRADE</span>
              </div>

              <h3 class="card-title">Visual Drag & Drop Designer & Crest Branding</h3>
              <p class="card-desc">
                Fine-tune question sheets on an interactive canvas. Position school crests, adjust margins, and insert anti-leak watermarks.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <div class="flex items-center gap-2">
                  <span class="status-dot dot-active"></span>
                  <span class="preview-filename">Live Layout Canvas Elements</span>
                </div>
              </div>
              <div class="chips-wrap">
                <span class="chip-item font-mono">🛡️ School Crest</span>
                <span class="chip-item font-mono">🔒 Watermark</span>
                <span class="chip-item font-mono">∫ LaTeX Math</span>
                <span class="chip-item font-mono">✍️ Invigilator Sign</span>
              </div>
            </div>
          </div>

          <!-- Card 5: In-Place Question Editor -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="23 4 23 10 17 10"/>
                    <polyline points="1 20 1 14 7 14"/>
                    <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
                  </svg>
                </div>
                <span class="card-badge">TOTAL CREATIVE CONTROL</span>
              </div>

              <h3 class="card-title">Full In-Place Question Editor & Reordering</h3>
              <p class="card-desc">
                Complete control. Drag questions to reorder, regenerate alternative phrasing with one click, and calibrate total marks.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <div class="flex items-center gap-2">
                  <span class="status-dot dot-active"></span>
                  <span class="preview-filename font-mono">Question 14 [3 Marks]</span>
                </div>
                <span class="preview-pill">TOTAL: 70M</span>
              </div>
              <div class="action-buttons-demo">
                <span class="demo-btn">↺ Regenerate Alternative</span>
                <span class="demo-btn">↕ Drag Reorder</span>
              </div>
            </div>
          </div>

          <!-- Card 6: Step-by-Step Marking Rubric -->
          <div class="feature-card">
            <div class="card-glow"></div>
            <div>
              <div class="card-top">
                <div class="feature-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 11l3 3L22 4"/>
                    <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                  </svg>
                </div>
                <span class="card-badge">EVALUATION COMPANION</span>
              </div>

              <h3 class="card-title">Automated Step-by-Step Marking Schemes</h3>
              <p class="card-desc">
                Every generated paper comes with a synchronized teacher rubric displaying point allocations and expected formula derivations.
              </p>
            </div>

            <!-- Mini Interactive Visual -->
            <div class="card-preview">
              <div class="preview-header">
                <div class="flex items-center gap-2">
                  <span class="status-dot dot-active"></span>
                  <span class="preview-filename font-mono">Grading Rubric Companion</span>
                </div>
                <span class="preview-pill">SYNCED</span>
              </div>
              <div class="rubric-rows">
                <div class="rubric-item">
                  <span class="mark-chip font-mono">+1M</span>
                  <span class="mark-desc">Correct formula & circuit diagram</span>
                </div>
                <div class="rubric-item">
                  <span class="mark-chip font-mono">+2M</span>
                  <span class="mark-desc">Step substitution with SI units</span>
                </div>
              </div>
            </div>
          </div>

        </div>

      </div>
    </section>
  `,
  styles: [`
    .features-section {
      background: transparent;
      position: relative;
    }

    .features-header {
      margin-bottom: 64px;
      @media (max-width: 768px) {
        margin-bottom: 40px;
      }
    }

    .section-title {
      font-size: clamp(2.1rem, 3.8vw, 3.2rem);
      line-height: 1.15;
    }
    .section-desc {
      font-size: 1.125rem;
      color: var(--text-secondary);
      line-height: 1.65;
    }

    /* ── Features Grid (Equal 3-Col Square Bento) ─────────────────────────── */
    .features-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      @media (max-width: 1080px) {
        grid-template-columns: repeat(2, 1fr);
      }
      @media (max-width: 680px) {
        grid-template-columns: 1fr;
      }
    }

    /* ── Feature Card (Square Shape & Uniform Styling) ────────────────────── */
    .feature-card {
      position: relative;
      box-sizing: border-box;
      aspect-ratio: 1 / 1;
      background: linear-gradient(180deg, rgba(20, 28, 46, 0.75) 0%, rgba(12, 18, 30, 0.9) 100%);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 16px;
      padding: 24px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      overflow: hidden;
      backdrop-filter: blur(16px);
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);

      @media (max-width: 680px) {
        aspect-ratio: auto;
        min-height: 320px;
        padding: 20px 18px;
      }

      &:hover {
        transform: translateY(-4px);
        border-color: rgba(99, 102, 241, 0.4);
        box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.6), 0 0 25px rgba(99, 102, 241, 0.15);
      }
    }

    .card-top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 12px;
    }

    .feature-icon {
      width: 40px;
      height: 40px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: transform 0.3s ease;
      background: rgba(99, 102, 241, 0.12);
      border: 1px solid rgba(99, 102, 241, 0.28);
      color: #818cf8;
    }
    .feature-card:hover .feature-icon {
      transform: scale(1.08);
    }

    .card-badge {
      font-size: 0.68rem;
      font-weight: 700;
      letter-spacing: 0.05em;
      padding: 3px 9px;
      border-radius: 9999px;
      text-transform: uppercase;
      background: rgba(99, 102, 241, 0.1);
      border: 1px solid rgba(99, 102, 241, 0.25);
      color: #a5b4fc;
    }

    .card-title {
      font-family: var(--font-display);
      font-size: 1.12rem;
      font-weight: 700;
      color: #ffffff;
      line-height: 1.3;
      margin-bottom: 6px;
      letter-spacing: -0.01em;
    }

    .card-desc {
      font-size: 0.825rem;
      color: #94a3b8;
      line-height: 1.45;
      margin-bottom: 12px;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    /* ── Mini Feature Previews (Uniform Brand Theme) ──────────────────────── */
    .card-preview {
      background: rgba(8, 12, 20, 0.7);
      border: 1px solid rgba(255, 255, 255, 0.06);
      border-radius: 10px;
      padding: 10px 12px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .preview-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }
    .preview-filename {
      font-size: 0.75rem;
      color: #cbd5e1;
      font-weight: 500;
    }
    .status-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
    }
    .dot-active {
      background: #38bdf8;
      box-shadow: 0 0 8px #38bdf8;
    }

    .preview-pill {
      font-size: 0.65rem;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      background: rgba(56, 189, 248, 0.15);
      border: 1px solid rgba(56, 189, 248, 0.25);
      color: #38bdf8;
    }

    /* Preview sub-elements */
    .preview-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 6px;
    }
    .preview-stat {
      background: rgba(255, 255, 255, 0.03);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 6px;
      padding: 5px 8px;
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .stat-label {
      font-size: 0.65rem;
      color: #64748b;
      font-weight: 600;
    }
    .stat-value {
      font-size: 0.735rem;
      color: #f1f5f9;
      font-weight: 600;
    }

    /* Difficulty Bars */
    .preview-bars {
      display: flex;
      flex-direction: column;
      gap: 5px;
    }
    .bar-row {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .bar-label {
      font-size: 0.685rem;
      color: #94a3b8;
      width: 32px;
    }
    .bar-track {
      flex-grow: 1;
      height: 6px;
      border-radius: 9999px;
      background: rgba(255, 255, 255, 0.08);
      display: flex;
      overflow: hidden;
    }
    .segment-easy { background: #34d399; }
    .segment-med { background: #6366f1; }
    .segment-hard { background: #38bdf8; }

    /* Chips wrap */
    .chips-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: 5px;
    }
    .chip-item {
      font-size: 0.7rem;
      color: #cbd5e1;
      background: rgba(255, 255, 255, 0.04);
      border: 1px solid rgba(255, 255, 255, 0.07);
      padding: 3px 7px;
      border-radius: 5px;
      white-space: nowrap;
    }

    /* Action buttons demo */
    .action-buttons-demo {
      display: flex;
      gap: 6px;
      flex-wrap: wrap;
    }
    .demo-btn {
      font-size: 0.685rem;
      font-weight: 600;
      color: #a5b4fc;
      background: rgba(99, 102, 241, 0.12);
      border: 1px solid rgba(99, 102, 241, 0.28);
      padding: 4px 8px;
      border-radius: 5px;
    }

    /* Rubric rows */
    .rubric-rows {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .rubric-item {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .mark-chip {
      font-size: 0.65rem;
      font-weight: 700;
      background: rgba(56, 189, 248, 0.15);
      color: #38bdf8;
      padding: 1px 5px;
      border-radius: 4px;
    }
    .mark-desc {
      font-size: 0.725rem;
      color: #cbd5e1;
    }
  `]
})
export class FeaturesComponent {}
