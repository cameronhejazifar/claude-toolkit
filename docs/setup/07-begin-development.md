---
title: Begin Development
description: Get the development environment fully setup to start working.
tags:
  - setup
  - claude
  - environment
---

# Begin Development

### Features List (first pass)

We need to generate a list of features to work off of. You can either create this list yourself, or use a basic raw list and prompt Claude with the following:

```text
I have a rough list of features for my application. I'd like your help to:

1. **Review & expand** — For each feature I listed, suggest sub-features or details I may have missed.
2. **Research & suggest** — Based on the type of app this is, suggest features I haven't thought of that are common or high-value.
3. **Organize** — Group everything into logical categories (e.g., Core, Social, Commerce, Admin, etc.).

Here are my features:

- landing page
- auth (register, login, logout, forgot/reset password)
- dashboard
- shopping list
- wish list
- social aspect (friends, messaging, etc)
...
... more features here ...
...

Output the final organized list as a markdown document I can save to `docs/specs/features.md`. Use this format:

## Category Name
- **Feature name** (priority) — Brief description
  - Sub-feature 1
  - Sub-feature 2

Ask me clarifying questions about the app's purpose or audience before you start if anything is ambiguous.
```

Either way, you should now have a `features.md` file located here: `/docs/specs/features.md`

### Features Review

NOTE: If you have a refined features list that doesn't need any help, you can skip this step.

At this point, we need to refine, organize, and look for gaps in the feature list. You can give Claude this prompt:

```text
Review this feature list document section by section. For each category:

Consolidation — Identify features that overlap, duplicate, or could be merged. Flag any sub-features that belong better under a different category.

Gaps — Based on the category's scope, call out features that are commonly expected but missing. Be specific about what's absent and where it should go.

Accuracy — Flag any features that are described incorrectly, use wrong terminology, or make claims that don't match how the underlying technology actually works.

Structure — Note any categories that are too broad (should be split) or too narrow (should be absorbed into a parent).

Be direct and thorough. I'd like to analyze each group of features in depth.
```

And then you can ask Claude to re-review your document over and over until you're satisfied with the resulting feature list.

### Restructuring Feature List

It may be helpful at this point to prompt Claude:

```text
These features are all going to be planned and implemented by an AI (likely Claude) - can you review them and see if there are any ambiguities or areas that could be improved to make sure that Claude doesn't make assumptions where there are gaps in the features and requirements.
```

Repeat this as many times as you'd like as well. Re-reviewing can provide some extra results that you don't get the first time.

### Project Brief, Site Map, and Design System

We need to generate three more files now:

- `project-brief.md` - The strategic foundation document that defines what you're building, who it's for, what tech you're using, and what's in/out of scope for v1 — so every future decision has a single source of truth to reference.

- `sitemap.md` — A complete map of every page/route in the application organized by user role, turning the abstract feature list into a concrete navigational structure that tells you exactly what screens need to be built.

- `design-system.md` — The visual and interaction contract that defines how everything looks and feels — colors, typography, components, spacing, animation, accessibility — so the entire UI can be built consistently without ad-hoc design decisions on every page.

You can either do this manually, or have Claude walk you through the process with a prompt like this:

```text
I have a feature list for my project at docs/specs/features.md. I need you to help me create three additional spec documents by reading the feature list and then asking me targeted questions to fill in the gaps. Create these one at a time, in this order:

    1. docs/specs/project-brief.md — Project brief covering: vision/problem statement, target users (demographics, tech comfort, geography), success metrics for v1, tech stack decisions, timeline/resources, v1 feature scope (what's in, what's deferred, what's out of scope entirely), and pointers to key documents.

    2. docs/specs/sitemap.md — Complete site map with every route/URL for guest, authenticated, and admin users. Include route patterns, what each page does, shared components, and email-to-page mappings.

    3. docs/specs/design-system.md — Design system covering: brand identity/mood, color palette (dark and light mode), typography, spacing/layout system, every reusable component (cards, buttons, nav, modals, forms, toasts, empty states, etc.), iconography, motion/animation guidelines, and accessibility standards.

For each document, start by reading the feature list, doing some research about the subject, then ask me questions in focused batches (5-8 questions at a time) until you have enough context to write a comprehensive spec. Give suggestions, best practices, and other examples for each area as we go through them. Don't draft anything until you've gathered sufficient answers. Push back or ask follow-ups if my answers are vague — these docs need to be specific enough to build from.

Keep in mind that I'm planning on using a tool like GSD with Claude to plan and execute the implementation, so help construct these files in a way that makes sense for that tool. We need to avoid ambiguity and be very clear and concise in our verbiage so that Claude will not need to make any assumptions where there are gaps or unknowns.
```

### GSD Process

We're now ready to start planning and implementing with GSD. Use their [documentation](https://github.com/gsd-build/get-shit-done) to thoroughly go their process step by step.

A good example of how to get this kicked off:

```text
/gsd:new-project

I'm building MyAppName, a full-stack web application. All product specs 
are in docs/specs/ — read project-brief.md, features.md, sitemap.md, and 
design-system.md to understand the full scope. The CLAUDE.md file contains 
all stack decisions, API standards, and implementation guidelines.

Break this into milestones and phases based on the specs. The specs are the 
source of truth for what to build; CLAUDE.md is the source of truth for how 
to build it.
```

Subsequent commands include:

```text
/gsd:discuss-phase 1
/gsd:ui-phase 1
/gsd:plan-phase 1
/gsd:execute-phase 1
/gsd:verify-work 1
...
```
