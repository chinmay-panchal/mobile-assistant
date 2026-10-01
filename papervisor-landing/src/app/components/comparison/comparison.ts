import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-comparison',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section id="comparison" class="section-padding comparison-section">
      <div class="container-custom">
        
        <!-- Header -->
        <div class="text-center max-w-3xl mx-auto mb-16">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/><line x1="4" y1="4" x2="9" y2="9"/></svg>
            <span>The Competitive Edge</span>
          </div>
          <h2 class="section-title mb-4">
            Why Generic AI Fails for <br>
            <span class="gradient-text">Real Academic Examinations.</span>
          </h2>
          <p class="section-desc">
            Standard chatbots don't know your school's curriculum boundaries and produce hallucinated, unformatted text. See the difference.
          </p>
        </div>

        <!-- Comparison Table Container -->
        <div class="table-wrapper glass-panel">
          <table class="comparison-table">
            <thead>
              <tr>
                <th class="col-feature">Assessment Capability</th>
                <th class="col-manual">Manual Drafting (Word)</th>
                <th class="col-generic">Generic AI (ChatGPT)</th>
                <th class="col-papervisor highlight-col">
                  <div class="papervisor-header">
                    <span>Papervisor</span>
                    <span class="pill-badge">Specialized</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="feature-title">
                  <strong>Textbook Syllabus Grounding</strong>
                  <div class="text-xs text-muted">Ensures 0% out-of-syllabus questions</div>
                </td>
                <td class="text-neutral">Manual cross-reference with books</td>
                <td class="text-fail">❌ Hallucinates unstudied topics</td>
                <td class="text-success highlight-col">✓ 100% Grounded to Uploaded PDFs</td>
              </tr>

              <tr>
                <td class="feature-title">
                  <strong>Automated Step-by-Step Rubrics</strong>
                  <div class="text-xs text-muted">Detailed solution keys with point allocation</div>
                </td>
                <td class="text-neutral">Takes 4+ hours per exam</td>
                <td class="text-fail">❌ Surface level answers only</td>
                <td class="text-success highlight-col">✓ Full Point-by-Point Marking Keys</td>
              </tr>

              <tr>
                <td class="feature-title">
                  <strong>Bloom's Taxonomy Calibration</strong>
                  <div class="text-xs text-muted">Controlled Easy / Medium / HOTS balance</div>
                </td>
                <td class="text-neutral">Rough intuition & guesswork</td>
                <td class="text-fail">❌ Uncontrollable difficulty mix</td>
                <td class="text-success highlight-col">✓ Granular Percentage Calibration</td>
              </tr>

              <tr>
                <td class="feature-title">
                  <strong>LaTeX Math & Chemical Formatting</strong>
                  <div class="text-xs text-muted">Fractions, matrices, radicals, arrows</div>
                </td>
                <td class="text-fail">❌ Equation editor constantly breaks</td>
                <td class="text-fail">❌ Raw LaTeX code strings</td>
                <td class="text-success highlight-col">✓ Native Vector Typesetting</td>
              </tr>

              <tr>
                <td class="feature-title">
                  <strong>Multi-Section Blueprint Engine</strong>
                  <div class="text-xs text-muted">Section weights, "Attempt any 4 of 5"</div>
                </td>
                <td class="text-neutral">Prone to mark tally mistakes</td>
                <td class="text-fail">❌ Loses count of total marks</td>
                <td class="text-success highlight-col">✓ Automated Total Mark Integrity</td>
              </tr>

              <tr>
                <td class="feature-title">
                  <strong>Print-Ready Institutional PDF Export</strong>
                  <div class="text-xs text-muted">Watermarks, school crest, signature blocks</div>
                </td>
                <td class="text-neutral">Hours tweaking Word margins</td>
                <td class="text-fail">❌ Requires manual formatting</td>
                <td class="text-success highlight-col">✓ 1-Click Board-Standard Export</td>
              </tr>
            </tbody>
          </table>
        </div>

      </div>
    </section>
  `,
  styles: [`
    .comparison-section { position: relative; }
    .max-w-3xl { max-width: 780px; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-4 { margin-bottom: 16px; }
    .mb-16 { margin-bottom: 64px; }
    .text-center { text-align: center; }
    .text-xs { font-size: 0.75rem; }
    .text-muted { color: var(--text-muted); }

    .section-title {
      font-size: clamp(2rem, 3.5vw, 3rem);
      line-height: 1.15;
    }
    .section-desc {
      font-size: 1.1rem;
      color: var(--text-secondary);
      line-height: 1.6;
    }

    .table-wrapper {
      max-width: 1080px;
      margin: 0 auto;
      overflow-x: auto;
      border: 1px solid var(--border-medium);
    }
    .comparison-table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
      font-size: 0.925rem;

      th, td {
        padding: 20px 24px;
        border-bottom: 1px solid var(--border-subtle);
      }

      th {
        background: #0f1627;
        font-family: var(--font-display);
        font-size: 1rem;
        font-weight: 700;
        color: #ffffff;
      }
    }
    .col-feature { width: 34%; }
    .col-manual { width: 22%; color: var(--text-muted); }
    .col-generic { width: 22%; color: var(--text-muted); }
    .col-papervisor { width: 22%; }

    .highlight-col {
      background: rgba(99, 102, 241, 0.06);
      border-left: 1px solid rgba(99, 102, 241, 0.2);
      border-right: 1px solid rgba(99, 102, 241, 0.2);
    }

    .papervisor-header {
      display: flex;
      align-items: center;
      gap: 8px;
      color: #818cf8;
      font-size: 1.1rem;
    }
    .pill-badge {
      background: rgba(99, 102, 241, 0.25);
      border: 1px solid rgba(99, 102, 241, 0.4);
      color: #a5b4fc;
      font-size: 0.7rem;
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 99px;
    }

    .feature-title strong {
      color: #ffffff;
      display: block;
      margin-bottom: 4px;
      font-size: 0.95rem;
    }
    .text-neutral { color: #94a3b8; }
    .text-fail { color: #f87171; font-weight: 500; }
    .text-success { color: #34d399; font-weight: 600; }
  `]
})
export class ComparisonComponent {}
