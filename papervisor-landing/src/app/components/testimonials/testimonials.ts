import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-testimonials',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section class="section-padding testimonials-section">
      <div class="container-custom">
        
        <!-- Header -->
        <div class="text-center max-w-3xl mx-auto mb-16">
          <div class="badge-pill mb-4">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            <span>Verified Educator Testimonials</span>
          </div>
          <h2 class="section-title mb-4">
            Loved by 12,000+ Educators in <br>
            <span class="gradient-text">Top Schools & Universities.</span>
          </h2>
          <p class="section-desc">
            Discover how departments reduce exam preparation burnout and elevate assessment quality.
          </p>
        </div>

        <!-- Testimonials Cards Grid -->
        <div class="testimonials-grid">
          
          <div *ngFor="let item of testimonials" class="testimonial-card glass-panel glass-panel-hover">
            <!-- Rating Stars -->
            <div class="stars-row mb-4">
              <span *ngFor="let s of [1,2,3,4,5]" class="star-icon">★</span>
            </div>

            <!-- Quote -->
            <blockquote class="quote-text mb-6">
              "{{ item.quote }}"
            </blockquote>

            <!-- Author Info -->
            <div class="author-block">
              <div class="author-avatar" [style.background]="item.avatarBg">
                {{ item.initials }}
              </div>
              <div class="author-meta">
                <div class="author-name">{{ item.name }}</div>
                <div class="author-role">{{ item.role }}</div>
                <div class="author-school">{{ item.institution }}</div>
              </div>
            </div>
          </div>

        </div>

      </div>
    </section>
  `,
  styles: [`
    .testimonials-section { position: relative; }
    .max-w-3xl { max-width: 780px; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .mb-4 { margin-bottom: 16px; }
    .mb-6 { margin-bottom: 24px; }
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

    .testimonials-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 24px;
      @media (max-width: 992px) {
        grid-template-columns: repeat(2, 1fr);
      }
      @media (max-width: 640px) {
        grid-template-columns: 1fr;
      }
    }
    .testimonial-card {
      padding: 32px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    .stars-row {
      display: flex;
      gap: 4px;
      color: #f59e0b;
      font-size: 1.1rem;
    }
    .quote-text {
      font-size: 0.975rem;
      line-height: 1.65;
      color: #e2e8f0;
      flex: 1;
    }
    .author-block {
      display: flex;
      align-items: center;
      gap: 14px;
      padding-top: 18px;
      border-top: 1px solid var(--border-subtle);
    }
    .author-avatar {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.95rem;
      color: #ffffff;
      flex-shrink: 0;
    }
    .author-name {
      font-size: 0.95rem;
      font-weight: 700;
      color: #ffffff;
    }
    .author-role {
      font-size: 0.8rem;
      color: var(--text-secondary);
    }
    .author-school {
      font-size: 0.75rem;
      color: #818cf8;
      font-weight: 600;
    }
  `]
})
export class TestimonialsComponent {
  testimonials = [
    {
      name: 'Dr. Aris Thorne',
      role: 'Head of Department (Physics)',
      institution: "St. Xavier's International School",
      initials: 'AT',
      avatarBg: 'linear-gradient(135deg, #6366f1, #06b6d4)',
      quote: 'Before Papervisor, our science department lost entire weekends cross-verifying questions against board weightages. Now, we create balanced, multi-tier exam papers with step rubrics in under 15 minutes.'
    },
    {
      name: 'Prof. Meera Raghavan',
      role: 'Senior Academic Dean',
      institution: 'Apex Collegiate Network',
      initials: 'MR',
      avatarBg: 'linear-gradient(135deg, #10b981, #059669)',
      quote: 'The zero-hallucination textbook grounding is a game-changer. Uploading our prescribed textbook PDFs ensures 100% curriculum compliance. Our teachers love the in-place question regenerator.'
    },
    {
      name: 'Marcus Vance',
      role: 'AP Chemistry Lead & Curriculum Chair',
      institution: 'Oakridge Global Academy',
      initials: 'MV',
      avatarBg: 'linear-gradient(135deg, #ec4899, #8b5cf6)',
      quote: "The Bloom's taxonomy distribution sliders alone make this worth ten times the price. We can guarantee exactly 30% recall, 50% application, and 20% HOTS questions without manual mark math."
    }
  ];
}
