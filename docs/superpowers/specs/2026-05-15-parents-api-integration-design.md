# Parents Page API Integration Design

**Date:** 2026-05-15  
**Author:** Claude Code  
**Status:** Design Review

---

## Overview

Convert the parents management page from demo/dummy data mode to real production mode by integrating with backend API. Implement full CRUD operations (Create, Read, Update, Delete) while maintaining clean architecture principles and Flutter best practices.

**Scope:** Parents feature only (list, create, edit, delete)  
**Out of Scope:** Search and pagination logic (backend-implemented)

---

## Current State

- **Data Source:** Hardcoded `parentsDummyRows` in `lib/features/parents/data/datasources/parents_dummy_data.dart`
- **State Management:** Local widget state (`_ParentsScreenState`)
- **API Infrastructure:** Exists (Dio client, auth interceptors, endpoints defined)
- **Modals:** Create, Edit, Delete, Detail modals already implemented

---

## Target Architecture (Clean Architecture)

### Layer 1: Domain Layer
**Location:** `lib/features/parents/domain/`

**Entities:**
- `parent_entity.dart` — Core `ParentEntity` class representing a parent (ID, name, email, phone, children count, timestamps)

**Repositories (Abstract):**
- `parents_repository.dart` — Interface defining:
  - `Future<List<ParentEntity>> getParents(int page, String? query)`
  - `Future<ParentEntity> createParent(Map<String, dynamic> data)`
  - `Future<ParentEntity> updateParent(String id, Map<String, dynamic> data)`
  - `Future<void> deleteParent(String id)`

---

### Layer 2: Data Layer
**Location:** `lib/features/parents/data/`

**Models:**
- `parent_model.dart` — `ParentModel` extends `ParentEntity`
  - JSON serialization via `fromJson()` / `toJson()`
  - Maps backend response to domain entity

**Remote Data Source:**
- `parents_remote_data_source.dart` — `ParentsRemoteDataSource` class
  - Low-level Dio calls
  - Methods: `getParents()`, `createParent()`, `updateParent()`, `deleteParent()`
  - Handles HTTP errors, throws `ApiException`

**Repository Implementation:**
- `parents_repository_impl.dart` — `ParentsRepositoryImpl` implements `ParentsRepository`
  - Depends on `ParentsRemoteDataSource`
  - Converts models to entities
  - Error handling and transformation

---

### Layer 3: Presentation Layer
**Location:** `lib/features/parents/presentation/`

**State Management:**
- `providers/parents_provider.dart` — Riverpod providers:
  - `parentsProvider(int page)` — FutureProvider<List<ParentEntity>> for fetching parents with pagination
  - `createParentProvider` — FutureProvider for creating a parent
  - `updateParentProvider` — FutureProvider for updating a parent
  - `deleteParentProvider` — FutureProvider for deleting a parent
  - Optional: `selectedPageProvider` — StateProvider for tracking current page

**UI Updates:**
- `screens/parents_screen.dart` — Updated to:
  - Consume `parentsProvider(page)` instead of dummy data
  - Show loading spinner while fetching
  - Show error message with retry button on failure
  - Pass page/search params to provider
  - Trigger refresh on CRUD operations

- `widgets/parent_create_modal.dart` — Updated to:
  - Call `createParentProvider`
  - Show loading state in submit button
  - Show success/error toast on completion

- `widgets/parent_edit_modal.dart` — Updated to:
  - Call `updateParentProvider`
  - Show loading state in submit button

- `widgets/parent_delete_modal.dart` — Updated to:
  - Call `deleteParentProvider`
  - Show loading state in confirm button

---

## Data Flow

### Fetch Parents (List)
```
ParentsScreen
  ↓ reads
parentsProvider(page: 1)
  ↓ triggers
ParentsRepositoryImpl.getParents(page: 1, query: null)
  ↓ calls
ParentsRemoteDataSource.getParents()
  ↓ performs
Dio.get('/parents?page=1')
  ↓ returns
List<ParentModel>
  ↓ converts to
List<ParentEntity>
  ↓ displays in
ParentsScreen with FutureBuilder/ConsumerWidget
```

### Create Parent
```
ParentCreateModal (user submits form)
  ↓ triggers
createParentProvider(parentData)
  ↓ calls
ParentsRepositoryImpl.createParent(data)
  ↓ calls
ParentsRemoteDataSource.createParent(data)
  ↓ performs
Dio.post('/parents', data: {...})
  ↓ returns
ParentEntity
  ↓ modal shows
Success toast + closes
  ↓ parent screen
Refreshes list (invalidate parentsProvider)
```

Similar flow for Update and Delete.

---

## Error Handling & UX

### Loading States
- **List Fetch:** Show `CircularProgressIndicator` centered on screen
- **CRUD Operations:** Show loading state in submit button, disable form inputs

### Error States
- **Network Error:** Display error message with "Retry" button
- **Validation Error:** Show field-specific error messages
- **Server Error:** Display user-friendly error message (avoid raw HTTP errors)

### Success Feedback
- **CRUD Success:** Show `SnackBar` with success message
- **Auto-refresh:** Invalidate `parentsProvider` to fetch updated list

---

## Pagination

- ParentsScreen maintains `_currentPage` as local state
- `parentsProvider` depends on `_currentPage` — regenerates when page changes
- Pagination controls (Next/Previous buttons) increment/decrement `_currentPage`
- Backend handles limit, offset, total count calculation

---

## File Structure (After Implementation)

```
lib/features/parents/
├── domain/
│   ├── entities/
│   │   └── parent_entity.dart
│   └── repositories/
│       └── parents_repository.dart
├── data/
│   ├── datasources/
│   │   ├── parents_remote_data_source.dart
│   │   └── parents_dummy_data.dart (DELETE after migration)
│   ├── models/
│   │   └── parent_model.dart
│   └── repositories/
│       └── parents_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── parents_provider.dart
    ├── screens/
    │   └── parents_screen.dart (updated)
    ├── widgets/
    │   ├── parent_create_modal.dart (updated)
    │   ├── parent_edit_modal.dart (updated)
    │   ├── parent_delete_modal.dart (updated)
    │   └── parent_detail_modal.dart (unchanged)
    └── constants/
        └── parents_screen_constants.dart (unchanged)
```

---

## Implementation Order

1. Create domain layer (entities + repository interface)
2. Create data layer (model, remote data source, repository impl)
3. Create Riverpod providers
4. Update ParentsScreen to consume providers
5. Update modals (create, edit, delete)
6. Test and delete dummy data file
7. Verify pagination and search integration with backend

---

## API Endpoints (Already Defined)

- **GET** `/parents?page=X&search=QUERY` — Fetch paginated parents
- **GET** `/parents/{id}` — Fetch single parent (optional, for detail view)
- **POST** `/parents` — Create parent
- **PUT/PATCH** `/parents/{id}` — Update parent
- **DELETE** `/parents/{id}` — Delete parent

---

## Dependencies

- **Existing:** Riverpod, Dio, Flutter
- **No new packages required**

---

## Success Criteria

- ✅ Parents list fetches from `/parents` API endpoint
- ✅ Pagination works with backend parameters
- ✅ Create/Update/Delete operations update the backend
- ✅ Loading and error states display correctly
- ✅ Code follows clean architecture (Domain → Data → Presentation)
- ✅ No dummy data hardcoded in production code
- ✅ User receives success/error feedback on all operations

---

## Notes

- Backend search/pagination implementation is handled by your friend
- Frontend only passes parameters; backend handles filtering
- All CRUD operations trigger automatic list refresh via provider invalidation
