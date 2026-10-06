# CRUD Layout Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the Categories management screen to use a full-width data table with separate Create and Update dialogs.

**Architecture:** We are splitting the current side-by-side Form + Table layout in `Categories.tsx` into a main Table view and two separate modal dialogs (`CreateCategoryDialog` and `UpdateCategoryDialog`).

**Tech Stack:** React, Tailwind CSS, shadcn/ui components (Table, Dialog, AlertDialog, Input, Button), lucide-react.

**Spec:** `docs/superpowers/specs/2026-10-06-crud-layout-refactoring-design.md`

## Global Constraints

- Must use existing `categoriesService` for API calls.
- Must use existing `toast` from `sonner` for notifications.
- Must use existing shadcn/ui components.

## Review Focus

- **Update dialog with empty data:** Ensure `UpdateCategoryDialog` handles cases where `category` prop is null gracefully.
- **API Error handling:** Ensure dialogs do not close automatically if the API call fails, allowing the user to retry or fix input.
- **Form state clearing:** Ensure `CreateCategoryDialog` clears its input fields after a successful submission.

---

### Task 1: Create `CreateCategoryDialog` Component

**Files:**
- Create: `frontend/src/components/features/categories/CreateCategoryDialog.tsx`
- Modify: `frontend/src/pages/Categories.tsx` (to remove the left-side Create form and use the new dialog)

**Interfaces:**
- Consumes: `categoriesService.createCategory({ maTL, tenTL })`
- Produces: `CreateCategoryDialog` component that accepts `onSuccess: () => void`.

- [ ] **Step 1: Write `CreateCategoryDialog.tsx`**
Implement the component returning a shadcn `Dialog` with a trigger button (Plus icon) or controlled open state. It should contain inputs for `maTl` and `tenTl`, and call `categoriesService.createCategory` on submit. Call `onSuccess()` and close the dialog on success.

- [ ] **Step 2: Update `Categories.tsx` to include `CreateCategoryDialog`**
Remove the `Card` containing the Add/Edit form. Add `CreateCategoryDialog` to the Top Toolbar area, passing `fetchCategories` as `onSuccess`.

- [ ] **Step 3: Verify Create Functionality**
Run: `cd frontend && npm run dev`
Expected: The "Thêm mới" button appears above the table. Clicking it opens a dialog. Submitting valid data creates a category, shows a success toast, closes the dialog, and refreshes the table.

### Task 2: Create `UpdateCategoryDialog` Component

**Files:**
- Create: `frontend/src/components/features/categories/UpdateCategoryDialog.tsx`
- Modify: `frontend/src/pages/Categories.tsx` (to wire up the Edit button)

**Interfaces:**
- Consumes: `categoriesService.updateCategory(maTL, data)`
- Produces: `UpdateCategoryDialog` component that accepts `category: Category | null`, `open: boolean`, `onOpenChange: (open: boolean) => void`, and `onSuccess: () => void`.

- [ ] **Step 1: Write `UpdateCategoryDialog.tsx`**
Implement a controlled shadcn `Dialog` that populates its fields based on the `category` prop. On submit, call `categoriesService.updateCategory`. Call `onSuccess()` and `onOpenChange(false)` on success.

- [ ] **Step 2: Update `Categories.tsx` to wire the Edit button**
Add state `selectedCategory` and `isUpdateOpen`. In the Table's Actions column, change the Edit button to set `selectedCategory` and open the dialog. Include `<UpdateCategoryDialog>` in the component tree.

- [ ] **Step 3: Verify Update Functionality**
Run: `cd frontend && npm run dev`
Expected: Clicking the Edit icon in a table row opens the dialog with pre-filled data. Modifying and submitting updates the category, closes the dialog, and refreshes the table.

### Task 3: Implement Delete Confirmation with AlertDialog

**Files:**
- Modify: `frontend/src/pages/Categories.tsx`

**Interfaces:**
- Consumes: shadcn `AlertDialog` component (import from `@/components/ui/alert-dialog`) and `categoriesService.deleteCategory(maTL)`.

- [ ] **Step 1: Ensure `AlertDialog` component exists**
Verify `frontend/src/components/ui/alert-dialog.tsx` exists.

- [ ] **Step 2: Update `Categories.tsx` to use `AlertDialog` for deletion**
Replace the `window.confirm` in `handleDelete` or wrap the Delete button in an `AlertDialog` trigger. On continue, call `categoriesService.deleteCategory`, show toast, and refresh table.

- [ ] **Step 3: Verify Delete Functionality**
Run: `cd frontend && npm run dev`
Expected: Clicking the Delete icon shows a styled alert dialog. Confirming the dialog deletes the row and refreshes the table.

### Task 4: Polish Layout and Commit

**Files:**
- Modify: `frontend/src/pages/Categories.tsx`

**Interfaces:**
- N/A

- [ ] **Step 1: Refactor `Categories.tsx` layout**
Ensure the Table now takes full width (`md:col-span-3` or remove grid). Add a Search Input to the Top Toolbar next to the Add button.

- [ ] **Step 2: Verify Final Layout**
Run: `cd frontend && npm run dev`
Expected: The page displays a full-width table with a clean toolbar above it.

- [ ] **Step 3: Commit changes**
Run: `git add . && git commit -m "feat: refactor categories page to use dialogs for CRUD"`
Expected: Commit succeeds.

