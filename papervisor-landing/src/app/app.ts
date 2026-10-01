import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './components/navbar/navbar';
import { HeroComponent } from './components/hero/hero';
import { WizardDemoComponent } from './components/wizard-demo/wizard-demo';
import { FeaturesComponent } from './components/features/features';
import { ComparisonComponent } from './components/comparison/comparison';
import { CalculatorComponent } from './components/calculator/calculator';
import { TestimonialsComponent } from './components/testimonials/testimonials';
import { RoadmapComponent } from './components/roadmap/roadmap';
import { FaqComponent } from './components/faq/faq';
import { FooterComponent } from './components/footer/footer';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    NavbarComponent,
    HeroComponent,
    WizardDemoComponent,
    FeaturesComponent,
    ComparisonComponent,
    CalculatorComponent,
    TestimonialsComponent,
    RoadmapComponent,
    FaqComponent,
    FooterComponent
  ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {}
