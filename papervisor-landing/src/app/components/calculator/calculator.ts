import { Component, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-calculator',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <section id="calculator" class="section-padding calculator-section">
      <div class="container-custom">
        
        <!-- Header -->
        <div class="text-center max-w-3xl mx-auto mb-16">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"/><path d="M12 18V6"/></svg>
            <span>Institutional Impact & Efficiency</span>
          </div>
          <h2 class="section-title mb-4">
            Calculate Your Department's <br>
            <span class="gradient-text-brand">Annual Hours & Cost Savings.</span>
          </h2>
          <p class="section-desc">
            See how much time and institutional budget your faculty reclaims when exam drafting is automated.
          </p>
        </div>

        <!-- Calculator Card -->
        <div class="calculator-box glass-panel">
          <div class="calc-grid">
            
            <!-- Left: Sliders -->
            <div class="calc-inputs">
              
              <!-- Slider 1: Faculty count -->
              <div class="input-card">
                <div class="flex justify-between items-center mb-2">
                  <label class="calc-label">Teachers / Faculty Members</label>
                  <span class="calc-value font-mono text-cyan">{{ teacherCount() }} Educators</span>
                </div>
                <input type="range" min="1" max="150" step="1" [ngModel]="teacherCount()" (ngModelChange)="teacherCount.set($event)" class="range-slider">
                <div class="flex justify-between text-xs text-muted">
                  <span>1 (Solo Tutor)</span>
                  <span>75 (Department)</span>
                  <span>150 (Campus)</span>
                </div>
              </div>

              <!-- Slider 2: Exams per year -->
              <div class="input-card mt-6">
                <div class="flex justify-between items-center mb-2">
                  <label class="calc-label">Exams / Assessments Per Year</label>
                  <span class="calc-value font-mono text-cyan">{{ examCount() }} Exams</span>
                </div>
                <input type="range" min="1" max="24" step="1" [ngModel]="examCount()" (ngModelChange)="examCount.set($event)" class="range-slider">
                <div class="flex justify-between text-xs text-muted">
                  <span>1 (Annual Final)</span>
                  <span>6 (Terminals & Mocks)</span>
                  <span>24 (Bi-Weekly Tests)</span>
                </div>
              </div>

              <!-- Slider 3: Average Salary Per Teacher Per Day (8 hours) -->
              <div class="input-card mt-6">
                <div class="flex justify-between items-center mb-2">
                  <label class="calc-label">Avg Salary Per Teacher Per Day (8 hrs)</label>
                  <span class="calc-value font-mono text-emerald">{{ currencySymbol() }}{{ formatNumber(dailySalary()) }} / Day</span>
                </div>
                <input type="range" 
                       [min]="minSalary()" 
                       [max]="maxSalary()" 
                       [step]="salaryStep()" 
                       [ngModel]="dailySalary()" 
                       (ngModelChange)="dailySalary.set($event)" 
                       class="range-slider range-slider-emerald">
                <div class="flex justify-between text-xs text-muted">
                  <span>{{ currencySymbol() }}{{ formatNumber(minSalary()) }} (Junior)</span>
                  <span>{{ currencySymbol() }}{{ formatNumber(midSalary()) }} (Standard)</span>
                  <span>{{ currencySymbol() }}{{ formatNumber(maxSalary()) }} (Senior / Lead)</span>
                </div>
              </div>

              <!-- Benchmark note: 8 hours assumption -->
              <div class="benchmark-note mt-6">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div class="text-xs text-muted">
                  Based on educator surveys: Traditional paper drafting & rubric preparation averages <strong>8.0 hours</strong> per exam. Papervisor reduces this to <strong>15 minutes</strong>.
                </div>
              </div>
            </div>

            <!-- Right: Results Panel -->
            <div class="calc-results">
              <div class="results-inner">
                <span class="results-badge">ANNUAL TIME & COST SAVINGS</span>
                
                <div class="result-metric">
                  <div class="metric-huge gradient-text">{{ currencySymbol() }}{{ formatNumber(costSaved()) }}</div>
                  <div class="metric-sub">Annual Department Budget Saved</div>
                </div>

                <div class="divider"></div>

                <div class="result-details-grid">
                  <div class="metric-mini">
                    <span class="mini-label">Annual Time Reclaimed:</span>
                    <strong class="text-cyan font-mono text-base">{{ formatNumber(hoursSaved()) }} Hours Saved</strong>
                  </div>
                  <div class="metric-mini">
                    <span class="mini-label">Faculty Labor Reclaimed (8h / Day):</span>
                    <strong class="text-emerald font-mono text-base">{{ formatNumber(daysSaved()) }} Full Working Days</strong>
                  </div>
                  <div class="metric-mini">
                    <span class="mini-label">Total Examinations Automated:</span>
                    <strong class="text-white font-mono text-base">{{ formatNumber(teacherCount() * examCount()) }} Exam Papers</strong>
                  </div>
                </div>

                <a href="https://app.100.60.191.242.sslip.io/" target="_blank" class="btn btn-primary w-full mt-6 shadow-brand">
                  <span>Start Creating Papers in App →</span>
                </a>
              </div>
            </div>

          </div>
        </div>

      </div>
    </section>
  `,
  styles: [`
    .calculator-section { position: relative; }
    .max-w-3xl { max-width: 780px; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-2 { margin-bottom: 8px; }
    .mb-4 { margin-bottom: 16px; }
    .mb-16 { margin-bottom: 64px; }
    .mt-6 { margin-top: 24px; }
    .text-center { text-align: center; }
    .flex { display: flex; }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .text-xs { font-size: 0.75rem; }
    .text-base { font-size: 1.05rem; }
    .text-muted { color: var(--text-muted); }
    .text-emerald { color: #10b981; }
    .text-cyan { color: #06b6d4; }
    .font-mono { font-family: var(--font-mono); }
    .w-full { width: 100%; }

    .section-title {
      font-size: clamp(2rem, 3.5vw, 3rem);
      line-height: 1.15;
    }
    .section-desc {
      font-size: 1.1rem;
      color: var(--text-secondary);
      line-height: 1.6;
    }

    .calculator-box {
      max-width: 1080px;
      margin: 0 auto;
      border: 1px solid var(--border-medium);
      overflow: hidden;
    }
    .calc-grid {
      display: grid;
      grid-template-columns: 1.25fr 1fr;
      @media (max-width: 860px) {
        grid-template-columns: 1fr;
      }
    }
    .calc-inputs {
      padding: 36px;
      border-right: 1px solid var(--border-subtle);
      @media (max-width: 860px) {
        border-right: none;
        border-bottom: 1px solid var(--border-subtle);
        padding: 24px;
      }
    }
    .input-card {
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      padding: 20px;
    }
    .calc-label {
      font-size: 0.95rem;
      font-weight: 600;
      color: #ffffff;
    }
    .calc-value {
      font-size: 1rem;
      font-weight: 700;
    }
    .currency-toggle-btn {
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.15);
      color: #94a3b8;
      font-size: 0.72rem;
      font-weight: 700;
      padding: 3px 8px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s ease;
      &:hover {
        background: rgba(99, 102, 241, 0.2);
        color: #ffffff;
        border-color: rgba(99, 102, 241, 0.4);
      }
    }
    .range-slider {
      width: 100%;
      height: 8px;
      border-radius: 4px;
      background: rgba(255, 255, 255, 0.1);
      outline: none;
      margin: 12px 0;
      accent-color: var(--color-brand-primary);
      cursor: pointer;
    }
    .range-slider-emerald {
      accent-color: #10b981;
    }
    .benchmark-note {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      background: rgba(99, 102, 241, 0.08);
      border: 1px solid rgba(99, 102, 241, 0.2);
      border-radius: 8px;
      padding: 14px 16px;
    }

    // Results Panel
    .calc-results {
      padding: 36px;
      background: linear-gradient(135deg, rgba(20, 28, 46, 0.9) 0%, rgba(12, 17, 29, 0.95) 100%);
      display: flex;
      flex-direction: column;
      justify-content: center;
      @media (max-width: 860px) { padding: 24px; }
    }
    .results-inner {
      text-align: center;
    }
    .results-badge {
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 0.08em;
      color: #818cf8;
      background: rgba(99, 102, 241, 0.15);
      border: 1px solid rgba(99, 102, 241, 0.3);
      padding: 4px 12px;
      border-radius: 99px;
      display: inline-block;
      margin-bottom: 20px;
    }
    .metric-huge {
      font-family: var(--font-display);
      font-size: clamp(3rem, 4.5vw, 4.2rem);
      font-weight: 800;
      line-height: 1;
      margin-bottom: 8px;
    }
    .metric-sub {
      font-size: 1rem;
      color: var(--text-secondary);
      font-weight: 500;
    }
    .divider {
      height: 1px;
      background: var(--border-subtle);
      margin: 24px 0;
    }
    .result-details-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 14px;
      text-align: left;
    }
    .metric-mini {
      background: rgba(0, 0, 0, 0.28);
      border: 1px solid var(--border-subtle);
      border-radius: 8px;
      padding: 12px 14px;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .mini-label {
      font-size: 0.75rem;
      color: var(--text-muted);
    }
  `]
})
export class CalculatorComponent {
  teacherCount = signal(25);
  examCount = signal(6);

  currency = signal<'USD' | 'INR'>('USD');
  currencySymbol = computed(() => this.currency() === 'USD' ? '$' : '₹');

  dailySalary = signal(5);

  minSalary = computed(() => this.currency() === 'USD' ? 5 : 500);
  maxSalary = computed(() => this.currency() === 'USD' ? 100 : 10000);
  midSalary = computed(() => this.currency() === 'USD' ? 25 : 2500);
  salaryStep = computed(() => this.currency() === 'USD' ? 1 : 100);

  toggleCurrency() {
    if (this.currency() === 'USD') {
      this.currency.set('INR');
      this.dailySalary.set(500);
    } else {
      this.currency.set('USD');
      this.dailySalary.set(5);
    }
  }

  // 8.0 hours average assumption per paper
  hoursSaved = computed(() => {
    return Math.round(this.teacherCount() * this.examCount() * 8);
  });

  // Based on an 8-hour workday (1 full day per paper)
  daysSaved = computed(() => {
    return Math.round(this.hoursSaved() / 8);
  });

  // Cost savings = Full Working Days * Daily Salary (8 hours)
  costSaved = computed(() => {
    return Math.round(this.daysSaved() * this.dailySalary());
  });

  formatNumber(val: number): string {
    return val.toLocaleString();
  }
}
