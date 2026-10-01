import { Component, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-wizard-demo',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <section id="preview" class="section-padding simulator-section">
      <div class="container-custom">
        
        <!-- Section Header -->
        <div class="text-center max-w-3xl mx-auto simulator-header">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
            <span>Interactive Preview</span>
          </div>
          <h2 class="section-title mb-4">
            Experience the <span class="gradient-text-brand">5-Step Paper Engine</span>
          </h2>
          <p class="section-desc">
            Test how chapter summaries, section marks, uniform difficulty spread, reference blueprint matching, and exam formatting unite into flawless question papers.
          </p>
        </div>

        <!-- Wizard Sandbox Container -->
        <div class="wizard-box glass-panel">
          
          <!-- Stepper Navigation (5 Distinct Steps) -->
          <div class="stepper-bar">
            <button class="step-btn" [class.active]="currentStep() === 1" (click)="setStep(1)">
              <span class="step-num">1</span>
              <span class="step-text">Chapters</span>
            </button>
            <div class="step-divider"></div>
            <button class="step-btn" [class.active]="currentStep() === 2" (click)="setStep(2)">
              <span class="step-num">2</span>
              <span class="step-text">Sections & Marks</span>
            </button>
            <div class="step-divider"></div>
            <button class="step-btn" [class.active]="currentStep() === 3" (click)="setStep(3)">
              <span class="step-num">3</span>
              <span class="step-text">Uniform Difficulty</span>
            </button>
            <div class="step-divider"></div>
            <button class="step-btn" [class.active]="currentStep() === 4" (click)="setStep(4)">
              <span class="step-num">4</span>
              <span class="step-text">Reference Blueprint</span>
            </button>
            <div class="step-divider"></div>
            <button class="step-btn" [class.active]="currentStep() === 5" (click)="setStep(5)">
              <span class="step-num">5</span>
              <span class="step-text">Format & Header</span>
            </button>
          </div>

          <!-- Wizard Body -->
          <div class="wizard-content">

            <!-- STEP 1: Chapters & Weightage Selection -->
            <div *ngIf="currentStep() === 1" class="step-pane fade-in">
              <div class="pane-header">
                <h3>Chapter Summarization Engine & Syllabus Weightage</h3>
                <p>The backend summarizes uploaded chapter PDFs in seconds. Select chapters and allocate custom syllabus weightage.</p>
              </div>

              <div class="chapters-grid">
                <div *ngFor="let chap of chapters" 
                     class="chapter-toggle-card" 
                     [class.selected]="chap.selected"
                     (click)="toggleChapter(chap)">
                  <div class="chap-checkbox">
                    <svg *ngIf="chap.selected" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                  </div>
                  <div class="chap-info">
                    <div class="chap-num">Chapter {{ chap.num }}</div>
                    <div class="chap-title">{{ chap.title }}</div>
                    <div class="chap-meta">{{ chap.pages }} • {{ chap.weightage }}</div>
                  </div>
                </div>
              </div>

              <div class="mt-5 p-3 rounded-lg bg-surface border border-white/10 flex items-center justify-between text-xs text-muted">
                <span>Selected: <strong class="text-white">{{ getSelectedChaptersCount() }} of {{ chapters.length }} Chapters</strong></span>
                <span class="text-cyan">✓ Semantic vector embeddings active for rapid synthesis</span>
              </div>
            </div>

            <!-- STEP 2: Marks & Sections Architecture -->
            <div *ngIf="currentStep() === 2" class="step-pane fade-in">
              <div class="pane-header">
                <h3>Section Architecture & Mark Allocation</h3>
                <p>Define question types and target points across standard examination sections.</p>
              </div>

              <div class="space-y-4">
                <!-- Section A -->
                <div class="section-config-row">
                  <div class="sec-left">
                    <span class="sec-badge">Section A</span>
                    <div>
                      <div class="font-semibold text-sm">Multiple Choice Questions (MCQ)</div>
                      <div class="text-xs text-muted">1 Mark each • Includes 2 Assertion-Reasoning</div>
                    </div>
                  </div>
                  <div class="sec-right">
                    <div class="counter-box">
                      <button (click)="decrementMcq()">−</button>
                      <span>{{ mcqCount() }} Questions</span>
                      <button (click)="incrementMcq()">+</button>
                    </div>
                    <div class="sec-subtotal">{{ mcqCount() * 1 }} M</div>
                  </div>
                </div>

                <!-- Section B -->
                <div class="section-config-row">
                  <div class="sec-left">
                    <span class="sec-badge">Section B</span>
                    <div>
                      <div class="font-semibold text-sm">Short Answer Questions (VSA)</div>
                      <div class="text-xs text-muted">2 Marks each • 2-3 step derivations & definitions</div>
                    </div>
                  </div>
                  <div class="sec-right">
                    <div class="counter-box">
                      <button (click)="decrementShort()">−</button>
                      <span>{{ shortCount() }} Questions</span>
                      <button (click)="incrementShort()">+</button>
                    </div>
                    <div class="sec-subtotal">{{ shortCount() * 2 }} M</div>
                  </div>
                </div>

                <!-- Section C -->
                <div class="section-config-row">
                  <div class="sec-left">
                    <span class="sec-badge">Section C</span>
                    <div>
                      <div class="font-semibold text-sm">Long Answer Questions (LA)</div>
                      <div class="text-xs text-muted">5 Marks each • Multi-part numericals & sub-questions</div>
                    </div>
                  </div>
                  <div class="sec-right">
                    <div class="counter-box">
                      <button (click)="decrementLong()">−</button>
                      <span>{{ longCount() }} Questions</span>
                      <button (click)="incrementLong()">+</button>
                    </div>
                    <div class="sec-subtotal">{{ longCount() * 5 }} M</div>
                  </div>
                </div>
              </div>

              <div class="mt-6 flex justify-between items-center p-4 bg-surface rounded-xl border border-white/10">
                <span class="text-sm font-medium">Computed Examination Paper Target:</span>
                <div class="total-marks-badge">
                  <span class="font-mono font-bold text-lg">{{ calculatedTotalMarks() }} Marks</span>
                </div>
              </div>
            </div>

            <!-- STEP 3: Uniform Section Difficulty Distribution -->
            <div *ngIf="currentStep() === 3" class="step-pane fade-in">
              <div class="pane-header">
                <h3>Unified Section-by-Section Difficulty Balancing</h3>
                <p>The Papervisor algorithm ensures this exact difficulty spread is uniformly maintained across <strong>every individual section</strong>, rather than lumping all hard questions together.</p>
              </div>

              <div class="difficulty-sliders">
                <!-- Easy Slider -->
                <div class="slider-group">
                  <div class="slider-header">
                    <span class="text-emerald font-semibold">Easy / Direct Recall (Bloom's Level 1 & 2)</span>
                    <span class="font-mono text-emerald font-bold">{{ easyPercent() }}%</span>
                  </div>
                  <input type="range" min="10" max="60" step="5" [ngModel]="easyPercent()" (ngModelChange)="updateEasy($event)" class="range-slider range-green">
                  <div class="text-xs text-muted mt-2">Formula recall, direct definitions, standard units</div>
                </div>

                <!-- Medium Slider -->
                <div class="slider-group">
                  <div class="slider-header">
                    <span class="text-indigo font-semibold">Medium / Conceptual Application (Bloom's Level 3 & 4)</span>
                    <span class="font-mono text-indigo font-bold">{{ medPercent() }}%</span>
                  </div>
                  <input type="range" min="20" max="70" step="5" [ngModel]="medPercent()" (ngModelChange)="updateMed($event)" class="range-slider range-indigo">
                  <div class="text-xs text-muted mt-2">Ensures steady multi-step problem solving in all sections</div>
                </div>

                <!-- Hard Slider -->
                <div class="slider-group">
                  <div class="slider-header">
                    <span class="text-red font-semibold">Hard / Critical Thinking & Synthesis (Bloom's Level 5 & 6)</span>
                    <span class="font-mono text-red font-bold">{{ hardPercent() }}%</span>
                  </div>
                  <input type="range" min="10" max="50" step="5" [ngModel]="hardPercent()" (ngModelChange)="updateHard($event)" class="range-slider range-red">
                  <div class="text-xs text-muted mt-2">Advanced numerical derivations and higher-order thinking (HOTS)</div>
                </div>
              </div>

              <div class="balance-indicator mt-6" [class.valid]="(easyPercent() + medPercent() + hardPercent()) === 100">
                <div class="flex items-center gap-2">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                  <span>Unified Section Distribution Sum: <strong>{{ easyPercent() + medPercent() + hardPercent() }}%</strong></span>
                </div>
                <span class="text-xs font-mono text-cyan">Uniform Section Balancing Active</span>
              </div>
            </div>

            <!-- STEP 4: Reference Paper & Blueprint Analysis -->
            <div *ngIf="currentStep() === 4" class="step-pane fade-in">
              <div class="pane-header">
                <h3>Reference Paper Blueprint (Optional)</h3>
                <p>Upload a past exam or model paper to clone its section structure, question styles, and marks distribution.</p>
              </div>

              <!-- Clean Reference Card -->
              <div class="blueprint-card">
                <div class="blueprint-card-top">
                  <div class="blueprint-file-info">
                    <div class="blueprint-icon">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    </div>
                    <div>
                      <div class="blueprint-name">Reference_Paper_Class12_Physics.pdf</div>
                      <div class="blueprint-sub">Past Board Exam • 5 Sections • 70 Marks Blueprint</div>
                    </div>
                  </div>
                  <span class="blueprint-status-pill">Blueprint Linked</span>
                </div>

                <div class="blueprint-specs-grid">
                  <div class="blueprint-spec-box">
                    <span class="spec-label">Section Format</span>
                    <strong class="spec-value">Sections A to E (CBSE Standard)</strong>
                  </div>
                  <div class="blueprint-spec-box">
                    <span class="spec-label">Question Types</span>
                    <strong class="spec-value">MCQ, Short, Long, HOTS</strong>
                  </div>
                  <div class="blueprint-spec-box">
                    <span class="spec-label">Formulas & Diagrams</span>
                    <strong class="spec-value">LaTeX Math & Vector Graphs</strong>
                  </div>
                </div>
              </div>

              <div class="blueprint-note">
                <span class="note-icon">💡</span>
                <span><strong>Optional:</strong> If no reference paper is uploaded, Papervisor synthesizes questions using standard national curriculum guidelines.</span>
              </div>
            </div>

            <!-- STEP 5: Format & Institutional Header -->
            <div *ngIf="currentStep() === 5" class="step-pane fade-in">
              <div class="pane-header">
                <h3>Institution Header & Examination Specifications</h3>
                <p>Configure official institutional branding, duration, layout style, and teacher guidelines.</p>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-group">
                  <label class="form-label">School / University / Academy Name</label>
                  <input type="text" [(ngModel)]="schoolName" class="form-input" placeholder="e.g. Oakridge International Academy">
                </div>
                <div class="form-group">
                  <label class="form-label">Examination Title</label>
                  <input type="text" [(ngModel)]="examType" class="form-input" placeholder="e.g. Mid-Term Assessment 2026-27">
                </div>
                <div class="form-group">
                  <label class="form-label">Subject & Grade</label>
                  <input type="text" [(ngModel)]="subjectGrade" class="form-input" placeholder="e.g. Class XII — Physics">
                </div>
                <div class="form-group">
                  <label class="form-label">Time Duration (Minutes)</label>
                  <input type="number" [(ngModel)]="examDuration" class="form-input" placeholder="180">
                </div>
              </div>

              <!-- Layout Pattern Picker -->
              <div class="mt-5">
                <label class="form-label mb-2 block">Paper Layout Pattern</label>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                  <div class="pattern-card" [class.active]="layoutPattern() === 'double'" (click)="layoutPattern.set('double')">
                    <div class="pattern-title">Standard Double Column</div>
                    <div class="pattern-desc">Optimal paper space utilization</div>
                  </div>
                  <div class="pattern-card" [class.active]="layoutPattern() === 'single'" (click)="layoutPattern.set('single')">
                    <div class="pattern-title">Clean Single Column</div>
                    <div class="pattern-desc">Spacious for heavy mathematical proofs</div>
                  </div>
                  <div class="pattern-card" [class.active]="layoutPattern() === 'strict'" (click)="layoutPattern.set('strict')">
                    <div class="pattern-title">Strict Board Format</div>
                    <div class="pattern-desc">Side-by-side marks & student checkboxes</div>
                  </div>
                </div>
              </div>

              <!-- Custom Teacher Directives -->
              <div class="mt-5 form-group">
                <label class="form-label">Custom Teacher Directives (Optional)</label>
                <input type="text" [(ngModel)]="teacherDirectives" class="form-input" placeholder="e.g. Focus on alternating current phasor diagrams and numericals on Gauss's law.">
              </div>
            </div>

          </div>

          <!-- Wizard Footer Controls -->
          <div class="wizard-footer">
            <button *ngIf="currentStep() > 1" (click)="prevStep()" class="btn btn-secondary">
              ← Previous Step
            </button>
            <div *ngIf="currentStep() === 1"></div>

            <div class="flex items-center gap-3">
              <button *ngIf="currentStep() < 5" (click)="nextStep()" class="btn btn-primary">
                Next: Step {{ currentStep() + 1 }} →
              </button>
              
              <!-- Updated "Create Paper" Button as requested -->
              <button *ngIf="currentStep() === 5" 
                      (click)="createPaper()" 
                      [disabled]="isGenerating()" 
                      class="btn btn-primary shadow-brand">
                <svg *ngIf="!isGenerating()" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                <span *ngIf="!isGenerating()">Create Paper</span>
                <span *ngIf="isGenerating()">Creating Paper...</span>
              </button>
            </div>
          </div>

        </div>

        <!-- Success Toast after clicking Create Paper -->
        <div *ngIf="generationDone()" class="paper-success-toast mt-6 fade-in">
          <div class="flex items-center gap-3">
            <span class="toast-check">✓</span>
            <div>
              <strong>Exam Paper Generated Dynamically!</strong>
              <span class="toast-sub">Formatted for {{ schoolName }} with {{ calculatedTotalMarks() }} Marks. Review the live examination sheet below.</span>
            </div>
          </div>
          <button class="toast-close" (click)="generationDone.set(false)">✕</button>
        </div>

        <!-- Examination Paper View (Static Initially, Dynamic on Parameter Changes / Create Paper) -->
        <div id="paper-canvas" class="mockup-wrapper mt-12">
          <div class="mockup-frame glass-panel">
            
            <!-- Window Titlebar with Mode Tabs & Action Buttons -->
            <div class="mockup-header">
              <div class="window-dots">
                <span class="dot dot-red"></span>
                <span class="dot dot-yellow"></span>
                <span class="dot dot-green"></span>
              </div>
              
              <div class="header-tab-bar">
                <button class="mockup-tab" 
                        [class.active]="activeTab() === 'paper'" 
                        (click)="activeTab.set('paper')">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                  <span>Student Question Paper</span>
                  <span class="pill-mini">{{ calculatedTotalMarks() }} Marks</span>
                </button>
                <button class="mockup-tab" 
                        [class.active]="activeTab() === 'rubric'" 
                        (click)="activeTab.set('rubric')">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                  <span>Teacher Marking Scheme & Rubrics</span>
                  <span class="pill-mini emerald">Step Points</span>
                </button>
              </div>

              <!-- Quick Export Actions -->
              <div class="paper-quick-actions flex items-center gap-2">
                <button (click)="simulateCopy()" class="btn-micro">
                  <span *ngIf="!copied()">📋 Copy LaTeX</span>
                  <span *ngIf="copied()" class="text-emerald">✓ Copied</span>
                </button>
                <button (click)="simulateDownload()" class="btn-micro">
                  <span *ngIf="!downloaded()">📥 PDF</span>
                  <span *ngIf="downloaded()" class="text-emerald">✓ Saved</span>
                </button>
                <a href="https://app.100.60.191.242.sslip.io/" target="_blank" class="btn-micro-brand">
                  <span>Let's Start in App →</span>
                </a>
              </div>
            </div>

            <!-- Paper Sheet Canvas Area with Exam Vibe -->
            <div class="mockup-body">
              <div class="paper-sheet">
                
                <!-- Official Examination Serial Header -->
                <div class="exam-serial-top">
                  <span class="serial-code">ROLL NO: [ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ]</span>
                  <span class="exam-stamp">CODE NO. 55/1/1 • SERIES {{ layoutPattern() === 'strict' ? 'CBSE-B' : 'A' }}</span>
                </div>

                <!-- Dynamic School Header Block -->
                <div class="exam-header-block mt-3">
                  <div class="school-logo">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                  </div>
                  <div class="text-center">
                    <h3 class="exam-school-name">{{ schoolName }}</h3>
                    <div class="exam-meta-title">{{ examType }}</div>
                    <div class="exam-meta-chips">
                      <span><strong>Subject:</strong> {{ subjectGrade }}</span>
                      <span>•</span>
                      <span><strong>Time Allowed:</strong> {{ examDuration }} Minutes</span>
                      <span>•</span>
                      <span><strong>Maximum Marks:</strong> {{ calculatedTotalMarks() }}</span>
                    </div>
                  </div>
                  <div class="school-seal">
                    <span class="seal-text">CURRICULUM VERIFIED</span>
                  </div>
                </div>

                <!-- Examination General Instructions -->
                <div class="exam-instructions-box">
                  <strong>General Instructions:</strong>
                  <ol>
                    <li>All questions are compulsory. Total paper marks: {{ calculatedTotalMarks() }} marks across {{ (mcqCount() > 0 ? 1 : 0) + (shortCount() > 0 ? 1 : 0) + (longCount() > 0 ? 1 : 0) }} sections.</li>
                    <li>Section A contains {{ mcqCount() }} questions (MCQs & Assertion-Reason) carrying 1 mark each.</li>
                    <li>Section B contains {{ shortCount() }} short-answer questions carrying 2 marks each.</li>
                    <li *ngIf="longCount() > 0">Section C contains {{ longCount() }} long-answer questions carrying 5 marks each.</li>
                    <li>Use of calculators is strictly prohibited. Standard log tables may be provided if required.</li>
                  </ol>
                </div>

                <!-- Dynamic Uniform Difficulty Distribution Indicator -->
                <div class="bloom-bar">
                  <div class="bloom-label">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="m4.93 4.93 4.24 4.24"/><path d="m14.83 9.17 4.24-4.24"/><path d="m14.83 14.83 4.24 4.24"/><path d="m9.17 14.83-4.24 4.24"/></svg>
                    Uniform Difficulty Spread:
                  </div>
                  <div class="bloom-tags">
                    <span class="tag-easy">Section A: {{ easyPercent() }}% Easy</span>
                    <span class="tag-med">Section B: {{ medPercent() }}% Conceptual</span>
                    <span class="tag-hard">Section C: {{ hardPercent() }}% HOTS Derivations</span>
                  </div>
                </div>

                <!-- Tab 1: Question Paper View -->
                <div *ngIf="activeTab() === 'paper'" class="questions-stream">
                  
                  <!-- Section A -->
                  <div class="section-badge flex items-center justify-between">
                    <span>SECTION A — OBJECTIVE & REASONING [{{ mcqCount() * 1 }} MARKS]</span>
                    <span class="text-2xs text-muted font-normal">Includes Assertion-Reason • {{ mcqCount() }} Questions</span>
                  </div>
                  
                  <div class="question-row editable-q">
                    <div class="q-num">Q1.</div>
                    <div class="q-content">
                      <p class="q-text">Two point charges +3μC and −3μC are placed at a distance of 20 cm in vacuum. What is the electric field at the midpoint of the line joining the two charges?</p>
                      <div class="q-options-grid">
                        <div class="option-pill correct-preview"><span class="opt-label">A</span> 5.4 × 10⁶ N/C towards −3μC</div>
                        <div class="option-pill"><span class="opt-label">B</span> 2.7 × 10⁶ N/C towards +3μC</div>
                        <div class="option-pill"><span class="opt-label">C</span> Zero</div>
                        <div class="option-pill"><span class="opt-label">D</span> 1.8 × 10⁶ N/C towards −3μC</div>
                      </div>
                    </div>
                    <div class="q-marks">[1 Mark]</div>
                  </div>

                  <div class="question-row editable-q mt-3">
                    <div class="q-num">Q2.</div>
                    <div class="q-content">
                      <p class="q-text">An electric dipole of moment \\vec&#123;p&#125; is placed in a uniform electric field \\vec&#123;E&#125;. The torque experienced by the dipole is maximum when the angle between \\vec&#123;p&#125; and \\vec&#123;E&#125; is:</p>
                      <div class="q-options-grid">
                        <div class="option-pill"><span class="opt-label">A</span> 0°</div>
                        <div class="option-pill correct-preview"><span class="opt-label">B</span> 90°</div>
                        <div class="option-pill"><span class="opt-label">C</span> 180°</div>
                        <div class="option-pill"><span class="opt-label">D</span> 45°</div>
                      </div>
                    </div>
                    <div class="q-marks">[1 Mark]</div>
                  </div>

                  <!-- Section B -->
                  <div class="section-badge mt-6 flex items-center justify-between">
                    <span>SECTION B — CONCEPTUAL & DERIVATIONS [{{ shortCount() * 2 }} MARKS]</span>
                    <span class="text-2xs text-muted font-normal">Grounded on {{ getSelectedChaptersSummary() }}</span>
                  </div>

                  <div class="question-row editable-q">
                    <div class="q-num">Q3.</div>
                    <div class="q-content">
                      <p class="q-text">State Gauss's Law in electrostatics. Using this law, derive an expression for the electric field intensity due to an infinitely long straight wire of linear charge density λ C/m.</p>
                      <div class="q-tag-row">
                        <span class="q-tag">NCERT Chapter 1 Summary</span>
                        <span class="q-tag">Mathematical Derivation</span>
                        <span class="q-tag bloom">Bloom: Understanding & Synthesis</span>
                      </div>
                    </div>
                    <div class="q-marks">[2 Marks]</div>
                  </div>

                  <div class="question-row editable-q mt-3">
                    <div class="q-num">Q4.</div>
                    <div class="q-content">
                      <p class="q-text">(a) State Kirchhoff’s loop rule and explain its connection to the conservation of energy. <br>
                      (b) In a Wheatstone bridge network, calculate the unknown resistance when the galvanometer displays null deflection.</p>
                      <div class="q-tag-row">
                        <span class="q-tag">NCERT Chapter 3 Summary</span>
                        <span class="q-tag">Circuit Analysis</span>
                      </div>
                    </div>
                    <div class="q-marks">[2 Marks]</div>
                  </div>

                  <!-- Section C -->
                  <div *ngIf="longCount() > 0" class="section-badge mt-6 flex items-center justify-between">
                    <span>SECTION C — EXTENDED PROOFS & NUMERICALS [{{ longCount() * 5 }} MARKS]</span>
                    <span class="text-2xs text-muted font-normal">Uniform Difficulty • Multi-Part Questions</span>
                  </div>

                  <div *ngIf="longCount() > 0" class="question-row editable-q">
                    <div class="q-num">Q5.</div>
                    <div class="q-content">
                      <p class="q-text">With the help of a labeled diagram, explain the principle, construction, and working of an AC generator. Derive the expression for the instantaneous induced electromotive force e = e₀ sin(ωt).</p>
                      <div class="q-tag-row">
                        <span class="q-tag">NCERT Chapter 6</span>
                        <span class="q-tag">Vector Phasor Diagram</span>
                        <span class="q-tag bloom">HOTS (Bloom Level 5)</span>
                      </div>
                    </div>
                    <div class="q-marks">[5 Marks]</div>
                  </div>

                </div>

                <!-- Tab 2: Marking Scheme View -->
                <div *ngIf="activeTab() === 'rubric'" class="questions-stream rubric-mode">
                  <div class="section-badge emerald-badge">TEACHER EVALUATION MATRIX — STEP-BY-STEP MARKING RUBRIC</div>
                  
                  <div class="rubric-box">
                    <div class="rubric-q-header">
                      <strong>Q1. Solution Key:</strong> Correct Option is <strong>(A)</strong>
                      <span class="rubric-mark">[1/1 Mark]</span>
                    </div>
                    <div class="rubric-steps">
                      <div class="step-line">• Electric field due to each charge at midpoint: E₁ = E₂ = q / (4πε₀r²) with r = 0.1 m</div>
                      <div class="step-line">• Resultant field E = E₁ + E₂ = 2 × (9 × 10⁹ × 3 × 10⁻⁶) / (0.1)² = 5.4 × 10⁶ N/C towards −3μC</div>
                    </div>
                  </div>

                  <div class="rubric-box mt-3">
                    <div class="rubric-q-header">
                      <strong>Q3. Step-by-Step Point Allocation:</strong>
                      <span class="rubric-mark">[Total 2 Marks]</span>
                    </div>
                    <div class="rubric-steps">
                      <div class="step-line"><strong>Step 1:</strong> Correct statement of Gauss's Law with mathematical formula ∮ E · dA = q / ε₀ <span class="step-point">(1 Mark)</span></div>
                      <div class="step-line"><strong>Step 2:</strong> Cylindrical Gaussian surface flux derivation leading to E = λ / (2πε₀r) <span class="step-point">(1 Mark)</span></div>
                    </div>
                  </div>

                  <div class="rubric-box mt-3">
                    <div class="rubric-q-header">
                      <strong>Q4. Loop Rule & Wheatstone Solution:</strong>
                      <span class="rubric-mark">[Total 2 Marks]</span>
                    </div>
                    <div class="rubric-steps">
                      <div class="step-line"><strong>Step 1:</strong> Statement of Kirchhoff's Loop Rule & conservation of electrostatic potential energy <span class="step-point">(1 Mark)</span></div>
                      <div class="step-line"><strong>Step 2:</strong> Balanced bridge ratio formula P/Q = R/S and calculation of unknown resistor <span class="step-point">(1 Mark)</span></div>
                    </div>
                  </div>
                </div>

              </div>
            </div>

          </div>
        </div>

      </div>
    </section>
  `,
  styles: [`
    .simulator-header { 
      margin-bottom: 56px; 
    }
    .simulator-section {
      background: transparent;
      position: relative;
    }

    .badge-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 18px;
      background: rgba(99, 102, 241, 0.12);
      border: 1px solid rgba(99, 102, 241, 0.28);
      border-radius: 9999px;
      color: #a5b4fc;
      font-size: 0.825rem;
      font-weight: 600;
      margin-bottom: 20px;
    }

    .section-title {
      font-size: clamp(2rem, 3.5vw, 3rem);
      line-height: 1.18;
      margin-bottom: 18px;
    }

    .section-desc {
      font-size: 1.1rem;
      color: var(--text-secondary);
      line-height: 1.6;
      max-width: 720px;
      margin-left: auto;
      margin-right: auto;
      margin-bottom: 0;
    }

    .wizard-box {
      border-radius: var(--radius-xl);
      overflow: hidden;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    }

    .stepper-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      background: #090e19;
      border-bottom: 1px solid var(--border-subtle);
      padding: 16px 28px;
      overflow-x: auto;
      gap: 10px;
    }
    .step-btn {
      display: flex;
      align-items: center;
      gap: 8px;
      background: transparent;
      border: none;
      color: var(--text-muted);
      cursor: pointer;
      padding: 8px 14px;
      border-radius: var(--radius-md);
      transition: all 0.2s ease;
      white-space: nowrap;
      &:hover { color: #ffffff; }
      &.active {
        color: #ffffff;
        background: rgba(99, 102, 241, 0.15);
        .step-num {
          background: var(--color-brand-primary);
          color: white;
        }
      }
    }
    .step-num {
      width: 26px;
      height: 26px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 0.8rem;
      font-weight: 700;
    }
    .step-text {
      font-size: 0.875rem;
      font-weight: 600;
    }
    .step-divider {
      flex: 1;
      height: 1px;
      background: var(--border-subtle);
      min-width: 12px;
      @media (max-width: 768px) { display: none; }
    }

    .wizard-content {
      padding: 32px;
      min-height: 400px;
      @media (max-width: 640px) { padding: 20px 16px; }
    }

    .pane-header {
      margin-bottom: 24px;
      h3 { font-size: 1.25rem; font-weight: 700; color: #ffffff; margin-bottom: 6px; }
      p { font-size: 0.875rem; color: var(--text-muted); }
    }

    .form-group {
      margin-bottom: 16px;
    }
    .form-label {
      display: block;
      font-size: 0.825rem;
      font-weight: 600;
      color: var(--text-secondary);
      margin-bottom: 8px;
    }
    .form-input {
      width: 100%;
      background: var(--bg-surface);
      border: 1px solid var(--border-medium);
      border-radius: var(--radius-sm);
      padding: 12px 16px;
      color: #ffffff;
      font-size: 0.925rem;
      outline: none;
      transition: border-color 0.2s;
      &:focus { border-color: var(--color-brand-primary); }
    }

    .pattern-card {
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      padding: 14px;
      cursor: pointer;
      transition: all 0.2s ease;
      &:hover { border-color: var(--border-medium); }
      &.active {
        border-color: var(--color-brand-primary);
        background: rgba(99, 102, 241, 0.1);
      }
    }
    .pattern-title {
      font-size: 0.875rem;
      font-weight: 700;
      color: #ffffff;
      margin-bottom: 4px;
    }
    .pattern-desc {
      font-size: 0.75rem;
      color: var(--text-muted);
    }

    .chapters-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 12px;
      @media (max-width: 768px) { grid-template-columns: 1fr; }
    }
    .chapter-toggle-card {
      display: flex;
      align-items: flex-start;
      gap: 14px;
      padding: 14px 18px;
      box-sizing: border-box;
      @media (max-width: 480px) {
        padding: 12px 14px;
        gap: 10px;
      }
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition: all 0.2s ease;
      &:hover { border-color: var(--border-medium); }
      &.selected {
        background: rgba(99, 102, 241, 0.08);
        border-color: rgba(99, 102, 241, 0.4);
        .chap-checkbox {
          background: var(--color-brand-primary);
          border-color: var(--color-brand-primary);
        }
      }
    }
    .chap-checkbox {
      width: 20px;
      height: 20px;
      border-radius: 6px;
      border: 1px solid var(--border-medium);
      display: flex;
      align-items: center;
      justify-content: center;
      margin-top: 2px;
      color: white;
    }
    .chap-num {
      font-size: 0.75rem;
      font-weight: 700;
      color: var(--color-brand-accent);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .chap-title {
      font-size: 0.925rem;
      font-weight: 600;
      color: #ffffff;
      margin: 2px 0 4px;
    }
    .chap-meta {
      font-size: 0.75rem;
      color: var(--text-muted);
    }

    .section-config-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 14px 20px;
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      gap: 16px;
      flex-wrap: wrap;
    }
    .sec-left {
      display: flex;
      align-items: center;
      gap: 14px;
    }
    .sec-badge {
      font-size: 0.75rem;
      font-weight: 800;
      background: rgba(255, 255, 255, 0.08);
      padding: 4px 10px;
      border-radius: 6px;
    }
    .sec-right {
      display: flex;
      align-items: center;
      gap: 20px;
    }
    .counter-box {
      display: flex;
      align-items: center;
      gap: 10px;
      background: rgba(0, 0, 0, 0.3);
      padding: 4px 8px;
      border-radius: 8px;
      border: 1px solid var(--border-subtle);
      button {
        width: 28px;
        height: 28px;
        background: rgba(255, 255, 255, 0.08);
        border: none;
        color: white;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        &:hover { background: rgba(255, 255, 255, 0.15); }
      }
      span {
        font-size: 0.85rem;
        font-weight: 600;
        min-width: 90px;
        text-align: center;
      }
    }
    .sec-subtotal {
      font-family: var(--font-mono);
      font-size: 0.95rem;
      font-weight: 700;
      color: var(--color-brand-accent);
      min-width: 45px;
      text-align: right;
    }
    .total-marks-badge {
      background: rgba(6, 182, 212, 0.12);
      border: 1px solid rgba(6, 182, 212, 0.3);
      color: #67e8f9;
      padding: 6px 16px;
      border-radius: 99px;
    }

    .difficulty-sliders {
      display: flex;
      flex-direction: column;
      gap: 18px;
    }
    .slider-group {
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      padding: 16px 20px;
    }
    .slider-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 10px;
      font-size: 0.9rem;
    }
    .range-slider {
      width: 100%;
      height: 6px;
      border-radius: 3px;
      background: rgba(255, 255, 255, 0.1);
      outline: none;
      -webkit-appearance: none;
      cursor: pointer;
    }
    .range-green::-webkit-slider-thumb { -webkit-appearance: none; width: 18px; height: 18px; border-radius: 50%; background: #10b981; cursor: pointer; }
    .range-indigo::-webkit-slider-thumb { -webkit-appearance: none; width: 18px; height: 18px; border-radius: 50%; background: #6366f1; cursor: pointer; }
    .range-red::-webkit-slider-thumb { -webkit-appearance: none; width: 18px; height: 18px; border-radius: 50%; background: #ef4444; cursor: pointer; }

    .balance-indicator {
      display: flex;
      align-items: center;
      justify-content: space-between;
      background: rgba(255, 255, 255, 0.04);
      padding: 12px 18px;
      border-radius: var(--radius-md);
      font-size: 0.85rem;
      border: 1px solid var(--border-subtle);
      &.valid {
        border-color: rgba(6, 182, 212, 0.3);
        background: rgba(6, 182, 212, 0.05);
      }
    }

    .wizard-footer {
      background: #0f1627;
      border-top: 1px solid var(--border-subtle);
      padding: 18px 36px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      @media (max-width: 640px) { padding: 14px 20px; }
    }

    .blueprint-card {
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      padding: 20px 24px;
    }
    .blueprint-card-top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--border-subtle);
      flex-wrap: wrap;
    }
    .blueprint-file-info {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .blueprint-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      background: rgba(99, 102, 241, 0.15);
      border: 1px solid rgba(99, 102, 241, 0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #818cf8;
    }
    .blueprint-name {
      font-size: 0.95rem;
      font-weight: 700;
      color: #ffffff;
    }
    .blueprint-sub {
      font-size: 0.775rem;
      color: var(--text-muted);
    }
    .blueprint-status-pill {
      font-size: 0.75rem;
      font-weight: 700;
      color: #67e8f9;
      background: rgba(6, 182, 212, 0.12);
      border: 1px solid rgba(6, 182, 212, 0.3);
      padding: 4px 10px;
      border-radius: 99px;
    }
    .blueprint-specs-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      margin-top: 16px;
      @media (max-width: 640px) { grid-template-columns: 1fr; }
    }
    .blueprint-spec-box {
      background: rgba(0, 0, 0, 0.2);
      padding: 10px 14px;
      border-radius: 8px;
      border: 1px solid var(--border-subtle);
    }
    .spec-label {
      display: block;
      font-size: 0.725rem;
      color: var(--text-muted);
      margin-bottom: 2px;
    }
    .spec-value {
      font-size: 0.85rem;
      color: #e2e8f0;
    }
    .blueprint-note {
      margin-top: 14px;
      padding: 12px 16px;
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid var(--border-subtle);
      border-radius: 8px;
      font-size: 0.825rem;
      color: var(--text-secondary);
      display: flex;
      align-items: center;
      gap: 8px;
    }

    // Success Toast
    .paper-success-toast {
      background: rgba(16, 185, 129, 0.1);
      border: 1px solid rgba(16, 185, 129, 0.3);
      border-radius: var(--radius-md);
      padding: 14px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      color: #f1f5f9;
      font-size: 0.9rem;
    }
    .toast-check {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      background: #10b981;
      color: white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      font-size: 0.8rem;
      flex-shrink: 0;
    }
    .toast-sub {
      display: block;
      font-size: 0.8rem;
      color: var(--text-secondary);
    }
    .toast-close {
      background: transparent;
      border: none;
      color: var(--text-muted);
      font-size: 1.1rem;
      cursor: pointer;
      &:hover { color: white; }
    }

    // Official Examination Paper Canvas Styles
    .mockup-wrapper {
      max-width: 1040px;
      margin-left: auto;
      margin-right: auto;
    }
    .mockup-frame {
      border: 1px solid var(--border-medium);
      overflow: hidden;
      box-shadow: 0 30px 80px rgba(0, 0, 0, 0.7), 0 0 50px rgba(99, 102, 241, 0.2);
    }
    .mockup-header {
      background: #0f1627;
      padding: 12px 20px;
      border-bottom: 1px solid var(--border-subtle);
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 12px;
    }
    .window-dots {
      display: flex;
      gap: 6px;
    }
    .dot {
      width: 11px;
      height: 11px;
      border-radius: 50%;
    }
    .dot-red { background: #ef4444; }
    .dot-yellow { background: #f59e0b; }
    .dot-green { background: #10b981; }

    .header-tab-bar {
      display: flex;
      gap: 8px;
      background: rgba(0, 0, 0, 0.35);
      padding: 4px;
      border-radius: var(--radius-sm);
    }
    .mockup-tab {
      background: transparent;
      border: none;
      color: var(--text-muted);
      font-size: 0.825rem;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s ease;
      &.active {
        background: var(--bg-surface);
        color: #ffffff;
        box-shadow: 0 2px 8px rgba(0,0,0,0.4);
      }
    }
    .pill-mini {
      font-size: 0.7rem;
      background: rgba(99, 102, 241, 0.2);
      color: #a5b4fc;
      padding: 2px 6px;
      border-radius: 4px;
      &.emerald {
        background: rgba(16, 185, 129, 0.2);
        color: #6ee7b7;
      }
    }

    .btn-micro {
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid var(--border-subtle);
      color: var(--text-secondary);
      font-size: 0.75rem;
      font-weight: 600;
      padding: 5px 10px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s;
      &:hover { color: white; background: rgba(255, 255, 255, 0.1); }
    }
    .btn-micro-brand {
      background: linear-gradient(135deg, #6366f1 0%, #06b6d4 100%);
      color: white;
      font-size: 0.75rem;
      font-weight: 700;
      padding: 5px 12px;
      border-radius: 6px;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      transition: transform 0.2s;
      &:hover { transform: translateY(-1px); }
    }

    .mockup-body {
      padding: 28px;
      background: #0b101c;
      @media (max-width: 640px) { padding: 14px; }
    }
    .paper-sheet {
      background: #ffffff;
      color: #1e293b;
      border-radius: var(--radius-md);
      padding: 36px 40px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.5);
      position: relative;
      @media (max-width: 640px) { padding: 20px 16px; }
    }

    .exam-serial-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px dashed #cbd5e1;
      padding-bottom: 8px;
      font-family: var(--font-mono);
      font-size: 0.75rem;
      color: #64748b;
      font-weight: 600;
    }
    .exam-header-block {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }
    .school-logo {
      width: 48px;
      height: 48px;
      border-radius: 10px;
      background: #e0e7ff;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .school-seal {
      border: 2px dashed #94a3b8;
      padding: 6px 10px;
      border-radius: 6px;
      font-size: 0.65rem;
      font-weight: 700;
      color: #64748b;
      letter-spacing: 0.05em;
      flex-shrink: 0;
      @media (max-width: 640px) { display: none; }
    }
    .exam-school-name {
      font-size: 1.25rem;
      font-weight: 800;
      letter-spacing: 0.03em;
      color: #0f172a;
    }
    .exam-meta-title {
      font-size: 0.85rem;
      font-weight: 700;
      color: #475569;
      margin: 2px 0 6px;
    }
    .exam-meta-chips {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      font-size: 0.785rem;
      color: #64748b;
      flex-wrap: wrap;
    }

    .exam-instructions-box {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 10px 14px;
      margin: 16px 0;
      font-size: 0.75rem;
      color: #475569;
      line-height: 1.5;
      ol {
        margin-left: 18px;
        margin-top: 4px;
      }
    }

    .bloom-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      background: #f1f5f9;
      padding: 8px 14px;
      border-radius: 6px;
      margin-bottom: 20px;
      font-size: 0.785rem;
      flex-wrap: wrap;
      gap: 8px;
    }
    .bloom-label {
      display: flex;
      align-items: center;
      gap: 6px;
      font-weight: 700;
      color: #334155;
    }
    .bloom-tags {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }
    .tag-easy { background: #dcfce7; color: #15803d; padding: 2px 8px; border-radius: 4px; font-weight: 600; font-size: 0.725rem; }
    .tag-med { background: #e0e7ff; color: #3730a3; padding: 2px 8px; border-radius: 4px; font-weight: 600; font-size: 0.725rem; }
    .tag-hard { background: #fee2e2; color: #b91c1c; padding: 2px 8px; border-radius: 4px; font-weight: 600; font-size: 0.725rem; }

    .section-badge {
      font-size: 0.785rem;
      font-weight: 800;
      letter-spacing: 0.04em;
      color: #1e293b;
      background: #e2e8f0;
      padding: 4px 10px;
      border-radius: 4px;
      margin-bottom: 12px;
      &.emerald-badge {
        background: #d1fae5;
        color: #065f46;
      }
    }
    .question-row {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      margin-bottom: 16px;
      padding: 8px;
      border-radius: 6px;
      transition: background 0.2s;
      &.editable-q:hover {
        background: #f8fafc;
      }
    }
    .q-num {
      font-weight: 800;
      font-size: 0.95rem;
      color: #0f172a;
      min-width: 28px;
    }
    .q-content { flex: 1; }
    .q-text {
      font-size: 0.925rem;
      line-height: 1.5;
      color: #1e293b;
      margin-bottom: 8px;
    }
    .q-options-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
      @media (max-width: 640px) { grid-template-columns: 1fr; }
    }
    .option-pill {
      background: #f8fafc;
      border: 1px solid #cbd5e1;
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 0.825rem;
      color: #334155;
      display: flex;
      align-items: center;
      gap: 8px;
      &.correct-preview {
        border-color: #6366f1;
        background: #eef2ff;
      }
    }
    .opt-label {
      width: 20px;
      height: 20px;
      border-radius: 4px;
      background: #e2e8f0;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.75rem;
      color: #0f172a;
    }
    .q-marks {
      font-weight: 700;
      font-size: 0.85rem;
      color: #0f172a;
      white-space: nowrap;
    }
    .q-tag-row {
      display: flex;
      gap: 8px;
      margin-top: 8px;
      flex-wrap: wrap;
    }
    .q-tag {
      background: #f1f5f9;
      color: #475569;
      font-size: 0.725rem;
      font-weight: 600;
      padding: 2px 8px;
      border-radius: 4px;
      &.bloom { background: #ede9fe; color: #5b21b6; }
    }

    // Rubric Styling
    .rubric-box {
      background: #f8fafc;
      border-left: 4px solid #10b981;
      border-radius: 6px;
      padding: 12px 16px;
    }
    .rubric-q-header {
      display: flex;
      justify-content: space-between;
      font-size: 0.875rem;
      margin-bottom: 6px;
      color: #0f172a;
    }
    .rubric-mark { font-weight: 700; color: #059669; }
    .rubric-steps { font-size: 0.825rem; color: #334155; line-height: 1.6; }
    .step-line { margin-bottom: 4px; }
    .step-point { color: #059669; font-weight: 700; }

    .fade-in {
      animation: fadeIn 0.3s ease-in-out;
    }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(6px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .text-emerald { color: #10b981; }
    .text-cyan { color: #06b6d4; }
    .text-indigo { color: #818cf8; }
    .text-red { color: #ef4444; }
  `]
})
export class WizardDemoComponent {
  currentStep = signal(1);
  schoolName = 'Oakridge International Academy';
  examType = 'Senior Secondary Mock Examination — 2026-27';
  subjectGrade = 'Class XII — Physics';
  examDuration = 180;
  layoutPattern = signal<'double' | 'single' | 'strict'>('double');
  teacherDirectives = 'Focus on alternating current phasor diagrams and numericals on Gauss\'s law.';

  activeTab = signal<'paper' | 'rubric'>('paper');

  mcqCount = signal(16);
  shortCount = signal(10);
  longCount = signal(4);

  calculatedTotalMarks = computed(() => {
    return (this.mcqCount() * 1) + (this.shortCount() * 2) + (this.longCount() * 5);
  });

  easyPercent = signal(30);
  medPercent = signal(50);
  hardPercent = signal(20);

  isGenerating = signal(false);
  generationDone = signal(false);
  copied = signal(false);
  downloaded = signal(false);

  chapters = [
    { num: 1, title: 'Electrostatics & Electric Charges', pages: 'Pages 1-38', weightage: '12 Marks Weightage', selected: true },
    { num: 2, title: 'Electrostatic Potential & Capacitance', pages: 'Pages 39-82', weightage: '10 Marks Weightage', selected: true },
    { num: 3, title: 'Current Electricity & Circuits', pages: 'Pages 83-130', weightage: '14 Marks Weightage', selected: true },
    { num: 4, title: 'Moving Charges & Magnetism', pages: 'Pages 131-178', weightage: '12 Marks Weightage', selected: false },
    { num: 5, title: 'Electromagnetic Induction', pages: 'Pages 179-214', weightage: '10 Marks Weightage', selected: false },
    { num: 6, title: 'Alternating Current & Power Factor', pages: 'Pages 215-256', weightage: '8 Marks Weightage', selected: true },
  ];

  setStep(s: number) {
    this.currentStep.set(s);
  }
  nextStep() {
    if (this.currentStep() < 5) this.currentStep.update(v => v + 1);
  }
  prevStep() {
    if (this.currentStep() > 1) this.currentStep.update(v => v - 1);
  }

  incrementMcq() { this.mcqCount.update(v => v + 1); }
  decrementMcq() { if (this.mcqCount() > 0) this.mcqCount.update(v => v - 1); }

  incrementShort() { this.shortCount.update(v => v + 1); }
  decrementShort() { if (this.shortCount() > 0) this.shortCount.update(v => v - 1); }

  incrementLong() { this.longCount.update(v => v + 1); }
  decrementLong() { if (this.longCount() > 0) this.longCount.update(v => v - 1); }

  updateEasy(val: number) {
    this.easyPercent.set(val);
    const rem = 100 - val;
    this.medPercent.set(Math.round(rem * 0.7));
    this.hardPercent.set(100 - val - this.medPercent());
  }
  updateMed(val: number) {
    this.medPercent.set(val);
    const rem = 100 - val;
    this.easyPercent.set(Math.round(rem * 0.6));
    this.hardPercent.set(100 - val - this.easyPercent());
  }
  updateHard(val: number) {
    this.hardPercent.set(val);
    const rem = 100 - val;
    this.easyPercent.set(Math.round(rem * 0.4));
    this.medPercent.set(100 - val - this.easyPercent());
  }

  toggleChapter(chap: any) {
    chap.selected = !chap.selected;
  }

  getSelectedChaptersCount(): number {
    return this.chapters.filter(c => c.selected).length;
  }

  getSelectedChaptersSummary(): string {
    const selected = this.chapters.filter(c => c.selected).map(c => `Ch ${c.num}`);
    return selected.length > 0 ? selected.join(', ') : 'All Chapters';
  }

  createPaper() {
    this.isGenerating.set(true);
    setTimeout(() => {
      this.isGenerating.set(false);
      this.generationDone.set(true);
      // Smoothly scroll down to the updated paper canvas
      const canvasEl = document.getElementById('paper-canvas');
      if (canvasEl) {
        canvasEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }, 700);
  }

  simulateCopy() {
    this.copied.set(true);
    setTimeout(() => this.copied.set(false), 2000);
  }

  simulateDownload() {
    this.downloaded.set(true);
    setTimeout(() => this.downloaded.set(false), 2500);
  }
}
