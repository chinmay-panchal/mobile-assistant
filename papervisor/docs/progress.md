# Progress & Questions Roadmap

## Integration Status (2026-08-18)

- [x] **API Mapping & Documentation**: Mapped backend endpoints against Papervisor UI screens (`docs/api_endpoints.md`).
- [ ] **Auth Integration**: Integration of Email/Password Register (`/api/v1/auth/register`), Login (`/api/v1/auth/login`), Token Refresh (`/api/v1/auth/refresh`), and Logout (`/api/v1/auth/logout`).
- [ ] **Workspace Management**: Integration of Workspace CRUD (`/api/v1/workspaces`).
- [ ] **Subject Management**: Integration of Subject CRUD (`/api/v1/workspaces/{workspace_id}/subjects` and `/api/v1/subjects/{subject_id}`).
- [ ] **Book Management**: Integration of Book CRUD (`/api/v1/subjects/{subject_id}/books` and `/api/v1/books/{book_id}`).
- [ ] **Chapter Management**: Integration of Chapter CRUD (`/api/v1/books/{book_id}/chapters` and `/api/v1/chapters/{chapter_id}`).
- [ ] **Document Processing**: Integration of Multipart Upload & Status check (`/api/v1/documents/upload`, `/api/v1/documents/{document_id}`).

---

## ❓ Questions & Confusions / Architectural Clarifications

1. **Question 1: Paper Generation API endpoint vs UI Paper Generation Wizard**
   - **Context**: The UI has a full Paper Creation Wizard step flow (`PaperWizardScreen`, `PaperWizardStepMarks`, `PaperWizardStepDifficulty`, `PaperWizardStepReference`, `GeneratingLoaderScreen`, `PaperResultScreen`) where the user configures marks, difficulty level, chapter selections, and reference paper uploads to generate an exam paper.
   - **Question**: The backend API guide provides RAG Educational Query (`POST /api/v1/ai/query`) and visual streaming (`GET /api/v1/ai/visuals/{visual_id}`) which are explicitly excluded from integration. Is there a separate endpoint planned for exam paper creation/generation (e.g., `POST /api/v1/papers/generate`), or should the wizard locally trigger mock generation while relying on Document Uploads (`POST /api/v1/documents/upload`) for background processing?

2. **Question 2: Workspace vs Subject / Book / Chapter Hierarchy mapping**
   - **Context**: In the UI, Workspaces represent grades/classes (e.g. "Class 8th", "Class 10th"). Each workspace holds multiple Subjects (e.g. "Mathematics", "Science"). Each Subject holds Books, and Books hold Chapters.
   - **Question**: When creating a Book via `POST /api/v1/subjects/{subject_id}/books`, should the active `workspace_id` also be stored/passed in local app state, or is the backend relational hierarchy strictly `Workspace -> Subject -> Book -> Chapter -> Document`?

3. **Question 3: Base URL & Auth Storage**
   - **Question**: Should we configure the base URL (e.g. `http://localhost:8000/api/v1` or `http://10.0.2.2:8000/api/v1` for Android emulator) via an environment config, and store the `access_token` and `refresh_token` using `flutter_secure_storage` or `shared_preferences`?
