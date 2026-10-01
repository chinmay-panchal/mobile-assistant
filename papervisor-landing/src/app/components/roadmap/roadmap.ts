import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-roadmap',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section id="roadmap" class="section-padding roadmap-section">
      <div class="container-custom">
        

        <!-- Section Header -->
        <div class="text-center max-w-3xl mx-auto mb-16">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            <span>Product Roadmap & Vision</span>
          </div>
          <h2 class="section-title mb-4">
            From Exam Drafting to <br>
            <span class="gradient-text-brand">Complete Academic Assessment.</span>
          </h2>
          <p class="section-desc">
            We are building a unified assessment loop for modern schools and universities. Here is what is launching next.
          </p>
        </div>

        <!-- Roadmap Cards Grid -->
        <div class="roadmap-grid">
          
          <!-- Card 1: Online Exam Taking -->
          <div class="roadmap-card glass-panel glass-panel-hover">
            <div class="roadmap-status">
              <span class="status-tag live-tag">
                <span class="mini-pulse"></span> IN ACTIVE DEVELOPMENT
              </span>
              <span class="quarter-tag">Q4 2026</span>
            </div>
            
            <div class="roadmap-icon-box">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
            </div>

            <h3 class="roadmap-card-title">Live Digital Exam Taking & Auto-Proctoring</h3>
            <p class="roadmap-card-desc">
              Convert any generated paper into an interactive, timed online examination link with a single toggle. Students test in a secure focus-locked interface with automated MCQ grading and instant submission tracking.
            </p>

            <ul class="roadmap-feature-list">
              <li>• Secure student link distribution via email/LMS</li>
              <li>• Section-by-section countdown timers</li>
              <li>• Focus-lock & tab-switch anomaly detection</li>
              <li>• Instant automated objective scoring</li>
            </ul>
          </div>

          <!-- Card 2: AI Doubt Resolution -->
          <div class="roadmap-card glass-panel glass-panel-hover">
            <div class="roadmap-status">
              <span class="status-tag testing-tag">
                <span class="mini-pulse cyan"></span> CLOSED PREVIEW
              </span>
              <span class="quarter-tag">Q1 2027</span>
            </div>

            <div class="roadmap-icon-box cyan-box">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#06b6d4" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M9 10h.01"/><path d="M15 10h.01"/><path d="M12 10h.01"/></svg>
            </div>

            <h3 class="roadmap-card-title">AI Doubt Solving & Socratic Remediation</h3>
            <p class="roadmap-card-desc">
              When students get a question wrong, Papervisor launches an interactive tutor session grounded strictly in the chapter summary of their uploaded textbook to explain root misconceptions without giving away answers.
            </p>

            <ul class="roadmap-feature-list">
              <li>• Contextual explanation derived from textbook pages</li>
              <li>• Step-by-step Socratic hints instead of spoon-feeding</li>
              <li>• Similar practice problem generator for mastery</li>
              <li>• Student misconception logs reported to teachers</li>
            </ul>
          </div>

          <!-- Card 3: Departmental Item Analytics -->
          <div class="roadmap-card glass-panel glass-panel-hover">
            <div class="roadmap-status">
              <span class="status-tag future-tag">
                <span class="mini-pulse emerald"></span> PLANNED
              </span>
              <span class="quarter-tag">Q2 2027</span>
            </div>

            <div class="roadmap-icon-box emerald-box">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            </div>

            <h3 class="roadmap-card-title">Classroom Item Analysis & Weakness Heatmap</h3>
            <p class="roadmap-card-desc">
              Deep psychometric analysis of class performance: question discrimination index, chapter-wise learning gaps, and difficulty curve validation to help educators tailor remedial teaching sessions.
            </p>

            <ul class="roadmap-feature-list">
              <li>• Class-wide syllabus mastery heatmaps</li>
              <li>• Discrimination index flagging misleading questions</li>
              <li>• Automatic student grouping for remedial sessions</li>
              <li>• Longitudinal grade tracking across terms</li>
            </ul>
          </div>

        </div>

      </div>
    </section>
  `,
  styles: [`
    .roadmap-section { position: relative; }
    .max-w-3xl { max-width: 780px; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-4 { margin-bottom: 16px; }
    .mb-16 { margin-bottom: 64px; }
    .mb-20 { margin-bottom: 80px; }
    .mt-1 { margin-top: 4px; }
    .text-center { text-align: center; }
    .text-white { color: #ffffff; }
    .text-secondary { color: var(--text-secondary); }
    .text-sm { font-size: 0.875rem; }
    .text-xs { font-size: 0.75rem; }
    .flex { display: flex; }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .gap-2 { gap: 8px; }
    .gap-4 { gap: 16px; }
    .gap-6 { gap: 24px; }

    .section-title {
      font-size: clamp(2rem, 3.5vw, 3rem);
      line-height: 1.15;
    }
    .section-desc {
      font-size: 1.1rem;
      color: var(--text-secondary);
      line-height: 1.6;
    }


    // Grid
    .roadmap-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 24px;
      @media (max-width: 992px) {
        grid-template-columns: 1fr;
        max-width: 580px;
        margin: 0 auto;
      }
    }
    .roadmap-card {
      padding: 32px;
      display: flex;
      flex-direction: column;
      position: relative;
    }
    .roadmap-status {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
    }
    .status-tag {
      font-size: 0.7rem;
      font-weight: 800;
      letter-spacing: 0.06em;
      padding: 4px 10px;
      border-radius: 99px;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .live-tag {
      background: rgba(99, 102, 241, 0.15);
      color: #a5b4fc;
      border: 1px solid rgba(99, 102, 241, 0.3);
    }
    .testing-tag {
      background: rgba(6, 182, 212, 0.15);
      color: #67e8f9;
      border: 1px solid rgba(6, 182, 212, 0.3);
    }
    .future-tag {
      background: rgba(16, 185, 129, 0.15);
      color: #6ee7b7;
      border: 1px solid rgba(16, 185, 129, 0.3);
    }
    .mini-pulse {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: #818cf8;
      &.cyan { background: #06b6d4; }
      &.emerald { background: #10b981; }
    }
    .quarter-tag {
      font-size: 0.75rem;
      font-mono: var(--font-mono);
      font-weight: 600;
      color: var(--text-muted);
    }

    .roadmap-icon-box {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      background: var(--bg-surface-elevated);
      border: 1px solid var(--border-subtle);
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 20px;
      &.cyan-box { border-color: rgba(6, 182, 212, 0.3); }
      &.emerald-box { border-color: rgba(16, 185, 129, 0.3); }
    }
    .roadmap-card-title {
      font-size: 1.25rem;
      font-weight: 700;
      color: #ffffff;
      margin-bottom: 12px;
      line-height: 1.3;
    }
    .roadmap-card-desc {
      font-size: 0.925rem;
      color: var(--text-secondary);
      line-height: 1.6;
      margin-bottom: 20px;
      flex: 1;
    }
    .roadmap-feature-list {
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding-top: 16px;
      border-top: 1px solid var(--border-subtle);
      li {
        font-size: 0.8rem;
        color: #94a3b8;
      }
    }
  `]
})
export class RoadmapComponent {}
