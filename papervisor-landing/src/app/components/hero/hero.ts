import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-hero',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section class="hero-section">
      <div class="container-custom">
        
        <!-- Top Pill Badge -->
        <div class="flex justify-center mb-6">
          <div class="badge-pill">
            <span class="badge-dot"></span>
            <span>Academic Exam Engineering Platform</span>
          </div>
        </div>

        <!-- Main Headline -->
        <div class="text-center max-w-4xl mx-auto mb-8">
          <h1 class="hero-title mb-6">
            Create Board-Ready Exam Papers in <br>
            <span class="gradient-text">Minutes, Not Weekends.</span>
          </h1>
          <p class="hero-subtitle">
            Powered by semantic chapter summarization, reference paper blueprint mimicry, and uniform section-by-section difficulty distribution. Visual drag-and-drop canvas with instant LaTeX math formatting.
          </p>
        </div>

        <!-- Action CTAs -->
        <div class="hero-actions mb-16">
          <a href="https://app.100.60.191.242.sslip.io/" target="_blank" class="btn btn-primary btn-lg shadow-lg">
            <span>Let's Start</span>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>
            </svg>
          </a>
          <a href="#preview" class="btn btn-secondary btn-lg">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polygon points="5 3 19 12 5 21 5 3"/>
            </svg>
            <span>Explore Preview ↓</span>
          </a>
        </div>

        <!-- Trust & Architecture Metrics Strip -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-number">50k+</div>
            <div class="stat-label">Exams Synthesized</div>
          </div>
          <div class="stat-card">
            <div class="stat-number gradient-text-brand">Uniform</div>
            <div class="stat-label">Section Difficulty Spread</div>
          </div>
          <div class="stat-card">
            <div class="stat-number">Sub-Sec</div>
            <div class="stat-label">Chapter Summaries</div>
          </div>
          <div class="stat-card">
            <div class="stat-number gradient-text-amber">100%</div>
            <div class="stat-label">Textbook Grounded</div>
          </div>
        </div>

      </div>
    </section>
  `,
  styles: [`
    .hero-section {
      padding-top: 140px;
      padding-bottom: 70px;
      position: relative;
    }
    .flex { display: flex; }
    .justify-center { justify-content: center; }
    .items-center { align-items: center; }
    .text-center { text-align: center; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-6 { margin-bottom: 24px; }
    .mb-8 { margin-bottom: 32px; }
    .mb-16 { margin-bottom: 56px; }

    .hero-title {
      font-size: clamp(2.4rem, 5vw, 4.4rem);
      line-height: 1.1;
      letter-spacing: -0.03em;
    }
    
    .hero-actions {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: center;
      gap: 24px;
    }
    .hero-subtitle {
      font-size: clamp(1.05rem, 1.8vw, 1.25rem);
      color: var(--text-secondary);
      line-height: 1.6;
      max-width: 760px;
      margin: 0 auto;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      max-width: 960px;
      margin: 0 auto;

      @media (max-width: 768px) {
        grid-template-columns: repeat(2, 1fr);
      }
    }
    .stat-card {
      background: var(--bg-card);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      padding: 24px 16px;
      text-align: center;
      backdrop-filter: blur(10px);
    }
    .stat-number {
      font-family: var(--font-display);
      font-size: 2rem;
      font-weight: 800;
      color: #ffffff;
      line-height: 1;
      margin-bottom: 6px;
    }
    .stat-label {
      font-size: 0.85rem;
      color: var(--text-muted);
      font-weight: 600;
    }
  `]
})
export class HeroComponent {}
