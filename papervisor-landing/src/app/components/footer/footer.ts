import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [CommonModule],
  template: `
    <!-- High-Impact Closing CTA -->
    <section class="cta-section">
      <div class="container-custom">
        <div class="cta-banner rounded-3xl">
          <div class="cta-glow-blob"></div>
          
          <div class="cta-content">
            <div class="badge-pill mb-5">
              <span class="badge-dot"></span>
              <span>Academic Assessment Suite for Modern Educators</span>
            </div>
            <h2 class="cta-title mb-4">
              Ready to Craft Your Next Exam Paper in <br>
              <span class="gradient-text">Minutes with Zero Hallucination?</span>
            </h2>
            <p class="cta-desc mb-8">
              Join thousands of educators saving 12+ hours every exam cycle with chapter-grounded question synthesis.
            </p>
            <div class="flex items-center justify-center gap-4 flex-wrap">
              <a href="https://app.100.60.191.242.sslip.io/" target="_blank" class="btn btn-primary btn-lg shadow-brand">
                <span>Let's Start</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
              </a>
              <a href="#preview" class="btn btn-secondary btn-lg">
                <span>Explore Preview ↓</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Sleek Minimal Footer -->
    <footer class="footer">
      <div class="container-custom">
        <div class="footer-minimal">
          
          <!-- Brand & Tagline -->
          <div class="footer-brand">
            <div class="flex items-center gap-3">
              <div class="footer-logo-mark">
                <img src="icon-192.png" alt="Papervisor Logo" class="w-full h-full object-cover" />
              </div>
              <span class="text-xl font-bold tracking-tight text-white font-display">Papervisor</span>
            </div>
            <p class="footer-tagline">
              AI exam engineering platform with chapter summarization and uniform section balancing.
            </p>
          </div>

          <!-- Minimal Navigation Links -->
          <nav class="footer-links-row">
            <a href="#features">Features</a>
            <a href="#preview">Preview</a>
            <a href="#comparison">Why Us</a>
            <a href="#calculator">Savings Calculator</a>
            <a href="#roadmap">Roadmap</a>
            <a href="#faq">FAQ</a>
          </nav>

        </div>

        <!-- Footer Bottom Bar -->
        <div class="footer-bottom">
          <div class="text-xs text-muted">
            © 2026 Papervisor. All rights reserved.
          </div>
          <div class="footer-status">
            <span class="badge-dot"></span>
            <span>Platform Operational</span>
          </div>
        </div>

      </div>
    </footer>
  `,
  styles: [`
    .cta-section {
      padding-top: 40px;
      padding-bottom: 80px;
      position: relative;
    }
    .cta-banner {
      border: 1px solid var(--border-medium);
      padding: 64px 32px;
      text-align: center;
      position: relative;
      overflow: hidden;
      border-radius: var(--radius-xl);
      background: linear-gradient(180deg, rgba(26, 36, 60, 0.8) 0%, rgba(14, 20, 34, 0.95) 100%);
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6), 0 0 80px rgba(99, 102, 241, 0.15);
      @media (max-width: 640px) { padding: 40px 20px; }
    }
    .cta-glow-blob {
      position: absolute;
      top: -50%;
      left: 50%;
      transform: translateX(-50%);
      width: 600px;
      height: 300px;
      background: radial-gradient(circle, rgba(99, 102, 241, 0.25) 0%, transparent 70%);
      pointer-events: none;
    }
    .cta-content {
      position: relative;
      z-index: 2;
      max-width: 820px;
      margin: 0 auto;
    }
    .cta-title {
      font-size: clamp(2rem, 3.8vw, 3.2rem);
      line-height: 1.15;
      margin-bottom: 18px;
    }
    .cta-desc {
      font-size: 1.15rem;
      color: var(--text-secondary);
      max-width: 640px;
      margin-left: auto;
      margin-right: auto;
      line-height: 1.6;
      margin-bottom: 32px;
    }

    .badge-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 7px 18px;
      border-radius: 9999px;
      font-size: 0.825rem;
      font-weight: 600;
      letter-spacing: 0.02em;
      background: rgba(99, 102, 241, 0.12);
      border: 1px solid rgba(99, 102, 241, 0.28);
      color: #a5b4fc;
      margin-bottom: 20px;
    }

    /* Minimal Sleek Footer */
    .footer {
      border-top: 1px solid var(--border-subtle);
      background: #070b13;
      padding-top: 56px;
      padding-bottom: 40px;
    }
    .footer-minimal {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 32px;
      padding-bottom: 40px;
      border-bottom: 1px solid var(--border-subtle);
    }
    .footer-brand {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .footer-logo-mark {
      width: 36px;
      height: 36px;
      border-radius: 10px;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 12px rgba(56, 189, 248, 0.25);
      border: 1px solid rgba(255, 255, 255, 0.1);
    }
    .footer-tagline {
      font-size: 0.875rem;
      color: var(--text-muted);
      max-width: 380px;
      line-height: 1.5;
    }
    .footer-links-row {
      display: flex;
      align-items: center;
      gap: 28px;
      flex-wrap: wrap;
      a {
        color: var(--text-secondary);
        font-size: 0.9rem;
        font-weight: 500;
        text-decoration: none;
        transition: color 0.2s ease;
        &:hover { color: #ffffff; }
      }
    }
    .footer-bottom {
      padding-top: 28px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
    }
    .footer-status {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 0.775rem;
      color: var(--text-secondary);
    }

    .flex { display: flex; }
    .items-center { align-items: center; }
    .justify-center { justify-content: center; }
    .gap-3 { gap: 12px; }
    .gap-4 { gap: 16px; }
    .mb-4 { margin-bottom: 18px; }
    .mb-5 { margin-bottom: 20px; }
    .mb-8 { margin-bottom: 32px; }
    .text-xs { font-size: 0.75rem; }
    .text-muted { color: var(--text-muted); }
  `]
})
export class FooterComponent {}
