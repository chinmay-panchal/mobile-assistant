import { Component, signal } from "@angular/core";
import { CommonModule } from "@angular/common";

@Component({
  selector: "app-faq",
  standalone: true,
  imports: [CommonModule],
  template: `
    <section id="faq" class="section-padding faq-section">
      <div class="container-custom">
        
        <!-- Header -->
        <div class="text-center max-w-3xl mx-auto mb-16">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <span>Clarity for Academic Leaders & Faculty</span>
          </div>
          <h2 class="section-title mb-4">
            Frequently Asked <span class="gradient-text">Questions.</span>
          </h2>
          <p class="section-desc">
            Common questions about curriculum alignment, custom blueprints, institutional branding, and paper generation.
          </p>
        </div>

        <!-- FAQ Accordion -->
        <div class="faq-list max-w-3xl mx-auto">
          <div *ngFor="let item of faqs; let i = index" 
               class="faq-card glass-panel"
               [class.open]="openIndex() === i">
            <button class="faq-trigger" (click)="toggle(i)">
              <span class="faq-question">{{ item.q }}</span>
              <span class="faq-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
              </span>
            </button>
            <div *ngIf="openIndex() === i" class="faq-content">
              <p>{{ item.a }}</p>
            </div>
          </div>
        </div>

      </div>
    </section>
  `,
  styles: [`
    .faq-section { position: relative; }
    .max-w-3xl { max-width: 780px; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-4 { margin-bottom: 16px; }
    .mb-16 { margin-bottom: 64px; }
    .text-center { text-align: center; }

    .section-title {
      font-size: clamp(2rem, 3.5vw, 3rem);
      line-height: 1.15;
    }
    .section-desc {
      font-size: 1.1rem;
      color: var(--text-secondary);
      line-height: 1.6;
    }

    .faq-list {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .faq-card {
      border: 1px solid var(--border-subtle);
      border-radius: var(--radius-md);
      overflow: hidden;
      transition: all 0.2s ease;
      &.open {
        border-color: var(--color-brand-primary);
        background: var(--bg-card-hover);
        .faq-icon {
          transform: rotate(45deg);
          color: var(--color-brand-primary);
        }
      }
    }
    .faq-trigger {
      width: 100%;
      background: transparent;
      border: none;
      padding: 22px 26px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      text-align: left;
      cursor: pointer;
      color: #ffffff;
    }
    .faq-question {
      font-size: 1.05rem;
      font-weight: 600;
      line-height: 1.4;
    }
    .faq-icon {
      color: var(--text-muted);
      transition: transform 0.25s ease;
      flex-shrink: 0;
    }
    .faq-content {
      padding: 0 26px 22px;
      p {
        font-size: 0.95rem;
        line-height: 1.65;
        color: var(--text-secondary);
      }
    }
  `]
})
export class FaqComponent {
  openIndex = signal<number | null>(0);

  faqs = [
    {
      q: "What educational boards and curriculums are supported?",
      a: "Papervisor is curriculum-agnostic. Whether you teach CBSE, ICSE, State Boards, Cambridge IGCSE, IB, or collegiate courses, you have complete flexibility to configure your exact section headers, question categories, and marking rules."
    },
    {
      q: "How does Papervisor ensure questions strictly match our textbook?",
      a: "You can upload your official textbooks, study material, or chapter notes directly into your subject workspace. Generated questions are strictly grounded in your provided material, preventing out-of-syllabus questions and inaccurate references."
    },
    {
      q: "Can I replicate our school's existing exam structure and past papers?",
      a: "Yes. You can upload a past exam or blueprint reference paper. Papervisor automatically maps the section layout, question categories, and marks distribution so your newly generated papers match your institution's established standard."
    },
    {
      q: "Can I edit, reorder, or regenerate individual questions?",
      a: "Absolutely. You have complete editorial control. You can edit question wording, drag and drop questions to reorder them within or across sections, swap questions with alternative choices, and customize mark allocations anytime."
    },
    {
      q: "Can I add our school logo, instructions, and watermarks?",
      a: "Yes. With the built-in Visual Designer, you can place your institution's crest, school name, examination instructions, teacher signature blocks, and security watermarks directly onto the canvas before exporting."
    },
    {
      q: "Are mathematical formulas, equations, and diagrams supported?",
      a: "Yes. All mathematical equations, scientific formulas, and symbols are formatted with native LaTeX typesetting, ensuring clean, high-resolution rendering suitable for physics, mathematics, and chemistry papers."
    },
    {
      q: "Can I export separate student question papers and teacher answer keys?",
      a: "Yes. In one click, you can export two synchronized, print-ready PDFs: an official Student Question Paper formatted to examination standards, and a comprehensive Teacher Marking Scheme with step-by-step scoring guidance."
    }
  ];

  toggle(index: number) {
    if (this.openIndex() === index) {
      this.openIndex.set(null);
    } else {
      this.openIndex.set(index);
    }
  }
}
