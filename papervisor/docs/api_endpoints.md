# API Endpoints Integration Reference

| Module | Endpoint Name | Method | URL | UI Location / Screen | Integration Status | Notes / Questions |
|---|---|---|---|---|---|---|
| **Health** | Health Check | GET | `/api/v1/health` | App Startup / Splash | ⏳ Pending | Backend health status |
| **Health** | DB Health Check | GET | `/api/v1/health/db` | App Startup / Settings | ⏳ Pending | DB status |
| **Auth** | Register | POST | `/api/v1/auth/register` | `SignupScreen` | ⏳ Pending | Register user with name, email, password |
| **Auth** | Login | POST | `/api/v1/auth/login` | `LoginScreen` | ⏳ Pending | Login user with email, password |
| **Auth** | Refresh Token | POST | `/api/v1/auth/refresh` | Auth Interceptor / ApiClient | ⏳ Pending | Automatic access token rotation |
| **Auth** | Logout | POST | `/api/v1/auth/logout` | Settings / Profile | ⏳ Pending | Token revocation on logout |
| **Auth** | Google Login | POST | `/api/v1/auth/google` | `LoginScreen` / `SignupScreen` | 🚫 Skipped | *User requested: Exclude Google & Apple login* |
| **Workspace** | Create Workspace | POST | `/api/v1/workspaces` | `HomeScreen` (Add Workspace) | ⏳ Pending | Create workspace (e.g. Class 10th) |
| **Workspace** | List Workspaces | GET | `/api/v1/workspaces` | `HomeScreen` | ⏳ Pending | Fetch user workspaces |
| **Workspace** | Get Workspace | GET | `/api/v1/workspaces/{workspace_id}` | Workspace Details | ⏳ Pending | Fetch single workspace details |
| **Workspace** | Update Workspace | PUT | `/api/v1/workspaces/{workspace_id}` | `HomeScreen` (Edit) | ⏳ Pending | Rename workspace |
| **Workspace** | Delete Workspace | DELETE | `/api/v1/workspaces/{workspace_id}` | `HomeScreen` (Delete) | ⏳ Pending | Delete workspace |
| **Subject** | Create Subject | POST | `/api/v1/workspaces/{workspace_id}/subjects` | `SubjectGridScreen` (Add) | ⏳ Pending | Add subject under workspace |
| **Subject** | List Subjects | GET | `/api/v1/workspaces/{workspace_id}/subjects` | `SubjectGridScreen` | ⏳ Pending | List subjects in a workspace |
| **Subject** | Get Subject | GET | `/api/v1/subjects/{subject_id}` | `SubjectDetailScreen` | ⏳ Pending | Get subject details |
| **Subject** | Update Subject | PUT | `/api/v1/subjects/{subject_id}` | `SubjectDetailScreen` (Edit) | ⏳ Pending | Edit subject details |
| **Subject** | Delete Subject | DELETE | `/api/v1/subjects/{subject_id}` | `SubjectGridScreen` (Delete) | ⏳ Pending | Delete subject |
| **Book** | Create Book | POST | `/api/v1/subjects/{subject_id}/books` | `SubjectDetailScreen` (Add Book) | ⏳ Pending | Add book under subject |
| **Book** | List Books | GET | `/api/v1/subjects/{subject_id}/books` | `SubjectDetailScreen` | ⏳ Pending | List books for subject |
| **Book** | Get Book | GET | `/api/v1/books/{book_id}` | `BookChaptersScreen` | ⏳ Pending | Get book details |
| **Book** | Update Book | PUT | `/api/v1/books/{book_id}` | `SubjectDetailScreen` (Edit Book) | ⏳ Pending | Update book details |
| **Book** | Delete Book | DELETE | `/api/v1/books/{book_id}` | `SubjectDetailScreen` (Delete Book) | ⏳ Pending | Delete book |
| **Chapter** | Create Chapter | POST | `/api/v1/books/{book_id}/chapters` | `BookChaptersScreen` (Add) | ⏳ Pending | Create chapter in book |
| **Chapter** | List Chapters | GET | `/api/v1/books/{book_id}/chapters` | `BookChaptersScreen` / `PaperWizardScreen` | ⏳ Pending | List chapters for book |
| **Chapter** | Get Chapter | GET | `/api/v1/chapters/{chapter_id}` | Chapter Details | ⏳ Pending | Get chapter info |
| **Chapter** | Update Chapter | PUT | `/api/v1/chapters/{chapter_id}` | `BookChaptersScreen` (Edit) | ⏳ Pending | Update chapter title/number |
| **Chapter** | Delete Chapter | DELETE | `/api/v1/chapters/{chapter_id}` | `BookChaptersScreen` (Delete) | ⏳ Pending | Delete chapter |
| **Document** | Upload Document | POST | `/api/v1/documents/upload` | `BookChaptersScreen` (Upload PDF) | ⏳ Pending | Upload PDF/PPTX for chapter/book |
| **Document** | Get Document | GET | `/api/v1/documents/{document_id}` | `BookChaptersScreen` (Status) | ⏳ Pending | Check parsing/embedding status |
| **Document** | Delete Document | DELETE | `/api/v1/documents/{document_id}` | `BookChaptersScreen` (Delete PDF) | ⏳ Pending | Remove document & vector chunks |
| **AI Tutor** | AI Query RAG | POST | `/api/v1/ai/query` | `PaperResultScreen` / `GeneratingLoaderScreen` | 🚫 Skipped | *User requested: Do not integrate this API* |
| **AI Visuals** | Stream Visual | GET | `/api/v1/ai/visuals/{visual_id}` | `PaperResultScreen` | 🚫 Skipped | *User requested: Do not integrate this API* |
