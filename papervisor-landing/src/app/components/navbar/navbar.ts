import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule],
  template: `
    <header class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 backdrop-blur-md bg-opacity-80 border-b border-white/10">
      <div class="container-custom">
        <div class="flex items-center justify-between h-20">
          
          <!-- Brand Logo with Academic Stamp -->
          <a href="#" class="brand-link">
            <div class="logo-mark">
              <img src="icon-192.png" alt="Papervisor Logo" class="w-full h-full object-cover" />
            </div>
            <div class="brand-text">
              <span class="text-xl font-bold tracking-tight text-white font-display">Papervisor</span>
            </div>
          </a>

          <!-- Desktop Navigation -->
          <nav class="hidden md:flex items-center gap-8">
            <a href="#features" class="nav-item">Features</a>
            <a href="#preview" class="nav-item">Preview</a>
            <a href="#comparison" class="nav-item">Why Us</a>
            <a href="#calculator" class="nav-item">Savings Calculator</a>
            <a href="#roadmap" class="nav-item">Roadmap</a>
            <a href="#faq" class="nav-item">FAQ</a>
          </nav>

          <!-- Desktop Right CTAs: Navigates to Flutter app -->
          <div class="hidden md:flex items-center gap-3">
            <a href="https://app.100.60.191.242.sslip.io/" target="_blank" class="btn btn-primary text-sm shadow-brand">
              <span>Let's Start</span>
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>
              </svg>
            </a>
          </div>

          <!-- Mobile Hamburger Button -->
          <button class="md:hidden mobile-toggle" (click)="toggleMobileMenu()" aria-label="Toggle Navigation">
            <svg *ngIf="!mobileMenuOpen()" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="18" y2="18"/>
            </svg>
            <svg *ngIf="mobileMenuOpen()" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
            </svg>
          </button>

        </div>
      </div>

      <!-- Mobile Dropdown Menu -->
      <div *ngIf="mobileMenuOpen()" class="md:hidden mobile-menu-overlay">
        <div class="container-custom py-6 flex flex-col gap-4">
          <a href="#features" (click)="closeMobileMenu()" class="mobile-nav-link">Features</a>
          <a href="#preview" (click)="closeMobileMenu()" class="mobile-nav-link">Preview</a>
          <a href="#comparison" (click)="closeMobileMenu()" class="mobile-nav-link">Why Us</a>
          <a href="#calculator" (click)="closeMobileMenu()" class="mobile-nav-link">Savings Calculator</a>
          <a href="#roadmap" (click)="closeMobileMenu()" class="mobile-nav-link">Roadmap</a>
          <a href="#faq" (click)="closeMobileMenu()" class="mobile-nav-link">FAQ</a>
          <div class="pt-4 border-t border-white/10 flex flex-col gap-3">
            <a href="https://app.100.60.191.242.sslip.io/" target="_blank" (click)="closeMobileMenu()" class="btn btn-primary w-full">Let's Start →</a>
          </div>
        </div>
      </div>
    </header>
  `,
  styles: [`
    header {
      background: rgba(8, 12, 20, 0.85);
    }
    .flex { display: flex; }
    .hidden { display: none; }
    @media (min-width: 768px) {
      .md\\:flex { display: flex; }
      .md\\:hidden { display: none; }
    }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .h-20 { height: 80px; }
    .fixed { position: fixed; }
    .top-0 { top: 0; }
    .left-0 { left: 0; }
    .right-0 { right: 0; }
    .z-50 { z-index: 50; }
    .gap-3 { gap: 12px; }
    .gap-4 { gap: 16px; }
    .gap-8 { gap: 32px; }
    .w-full { width: 100%; }

    .brand-link {
      display: flex;
      align-items: center;
      gap: 12px;
      text-decoration: none;
    }
    .logo-mark {
      width: 40px;
      height: 40px;
      border-radius: 12px;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 14px rgba(56, 189, 248, 0.35);
      border: 1px solid rgba(255, 255, 255, 0.12);
    }
    .brand-text {
      display: flex;
      align-items: baseline;
      gap: 6px;
    }
    .font-display { font-family: var(--font-display); }
    .text-xl { font-size: 1.35rem; }
    .font-bold { font-weight: 700; }
    .tracking-tight { letter-spacing: -0.03em; }
    .brand-badge {
      font-size: 0.65rem;
      font-weight: 700;
      letter-spacing: 0.08em;
      padding: 2px 6px;
      border-radius: 6px;
      background: rgba(6, 182, 212, 0.15);
      border: 1px solid rgba(6, 182, 212, 0.3);
      color: #67e8f9;
    }
    .nav-item {
      color: var(--text-secondary);
      font-size: 0.925rem;
      font-weight: 500;
      text-decoration: none;
      transition: color 0.2s ease;
      &:hover {
        color: #ffffff;
      }
    }
    .mobile-toggle {
      background: transparent;
      border: none;
      color: var(--text-primary);
      cursor: pointer;
      padding: 8px;
    }
    .mobile-menu-overlay {
      background: rgba(12, 17, 29, 0.98);
      border-bottom: 1px solid var(--border-medium);
      backdrop-filter: blur(24px);
    }
    .mobile-nav-link {
      color: var(--text-secondary);
      font-size: 1.05rem;
      font-weight: 600;
      text-decoration: none;
      padding: 10px 0;
      &:hover { color: #ffffff; }
    }
    .shadow-brand {
      box-shadow: 0 4px 16px rgba(99, 102, 241, 0.4);
    }
  `]
})
export class NavbarComponent {
  mobileMenuOpen = signal(false);

  toggleMobileMenu() {
    this.mobileMenuOpen.update(v => !v);
  }

  closeMobileMenu() {
    this.mobileMenuOpen.set(false);
  }
}
