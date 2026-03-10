#!/bin/bash
# Hollywood Writers Room Rebrand Script
# Run from the root of the paperclip repo:  bash apply-rebrand.sh
set -e

echo "Applying Hollywood Writers Room rebrand..."

# === 1. Create new migration file ===
mkdir -p packages/db/src/migrations
cat > packages/db/src/migrations/0026_writers_room_rebrand.sql << 'MIGRATION'
-- Migration: Rebrand from corporate to Hollywood Writers Room terminology
-- Updates existing data to use new role, approval type, invite type, and goal level values

-- Update agent roles
UPDATE agents SET role = 'showrunner' WHERE role = 'ceo';
UPDATE agents SET role = 'head_writer' WHERE role = 'cto';
UPDATE agents SET role = 'story_editor' WHERE role = 'cmo';
UPDATE agents SET role = 'script_coordinator' WHERE role = 'cfo';
UPDATE agents SET role = 'staff_writer' WHERE role = 'engineer';
UPDATE agents SET role = 'creative_consultant' WHERE role = 'designer';
UPDATE agents SET role = 'writers_assistant' WHERE role = 'pm';
UPDATE agents SET role = 'continuity_editor' WHERE role = 'qa';
UPDATE agents SET role = 'room_runner' WHERE role = 'devops';

-- Update approval types
UPDATE approvals SET type = 'onboard_writer' WHERE type = 'hire_agent';
UPDATE approvals SET type = 'approve_showrunner_vision' WHERE type = 'approve_ceo_strategy';

-- Update goal levels
UPDATE goals SET level = 'production' WHERE level = 'company';
UPDATE goals SET level = 'room' WHERE level = 'team';
UPDATE goals SET level = 'writer' WHERE level = 'agent';
UPDATE goals SET level = 'assignment' WHERE level = 'task';

-- Update invite types
UPDATE invites SET invite_type = 'production_join' WHERE invite_type = 'company_join';
UPDATE invites SET invite_type = 'bootstrap_showrunner' WHERE invite_type = 'bootstrap_ceo';

-- Update default for invites table
ALTER TABLE invites ALTER COLUMN invite_type SET DEFAULT 'production_join';
MIGRATION

# === 2. packages/shared/src/constants.ts ===
F=packages/shared/src/constants.ts
sed -i.bak '
s/"ceo",/"showrunner",/
s/"cto",/"head_writer",/
s/"cmo",/"story_editor",/
s/"cfo",/"script_coordinator",/
s/"engineer",/"staff_writer",/
s/"designer",/"creative_consultant",/
s/"pm",/"writers_assistant",/
s/"qa",/"continuity_editor",/
s/"devops",/"room_runner",/
s/ceo: "CEO"/showrunner: "Showrunner"/
s/cto: "CTO"/head_writer: "Head Writer"/
s/cmo: "CMO"/story_editor: "Story Editor"/
s/cfo: "CFO"/script_coordinator: "Script Coordinator"/
s/engineer: "Engineer"/staff_writer: "Staff Writer"/
s/designer: "Designer"/creative_consultant: "Creative Consultant"/
s/pm: "PM"/writers_assistant: "Writers'\'' Assistant"/
s/qa: "QA"/continuity_editor: "Continuity Editor"/
s/devops: "DevOps"/room_runner: "Room Runner"/
s/"company", "team", "agent", "task"/"production", "room", "writer", "assignment"/
s/"hire_agent", "approve_ceo_strategy"/"onboard_writer", "approve_showrunner_vision"/
s/"company_join", "bootstrap_ceo"/"production_join", "bootstrap_showrunner"/
' "$F" && rm -f "$F.bak"

# Add new icon names before the closing ] in AGENT_ICON_NAMES
sed -i.bak '/  "fingerprint",/a\  "pen-tool",\n  "scroll",\n  "film",\n  "clapperboard",\n  "drama",\n  "feather",\n  "book-open",\n  "theater",' "$F" && rm -f "$F.bak"

# === 3. packages/shared/src/validators/goal.ts ===
sed -i.bak 's/.default("task")/.default("assignment")/' packages/shared/src/validators/goal.ts && rm -f packages/shared/src/validators/goal.ts.bak

# === 4. packages/db/src/schema/invites.ts ===
sed -i.bak 's/"company_join"/"production_join"/' packages/db/src/schema/invites.ts && rm -f packages/db/src/schema/invites.ts.bak

# === 5. packages/db/src/seed.ts ===
F=packages/db/src/seed.ts
sed -i.bak '
s/name: "Paperclip Demo Co"/name: "Writers Room Demo"/
s/description: "A demo autonomous company"/description: "A demo writers room production"/
s/const \[ceo\]/const [showrunner]/
s/name: "CEO Agent"/name: "Showrunner"/
s/role: "ceo"/role: "showrunner"/
s/title: "Chief Executive Officer"/title: "Head of the Room"/
s/args: \["hello from ceo"\]/args: ["hello from showrunner"]/
s/const \[engineer\]/const [staffWriter]/
s/name: "Engineer Agent"/name: "Staff Writer"/
s/role: "engineer"/role: "staff_writer"/
s/title: "Software Engineer"/title: "Staff Writer"/
s/reportsTo: ceo!/reportsTo: showrunner!/
s/args: \["hello from engineer"\]/args: ["hello from staff writer"]/
s/title: "Ship V1"/title: "Season 1 Pilot"/
s/description: "Deliver first control plane release"/description: "Write and deliver the pilot episode"/
s/level: "company"/level: "production"/
s/ownerAgentId: ceo!/ownerAgentId: showrunner!/
s/name: "Control Plane MVP"/name: "Episode 1: Pilot"/
s/description: "Implement core board + agent loop"/description: "Draft and polish the pilot episode script"/
s/leadAgentId: ceo!/leadAgentId: showrunner!/
s/title: "Implement atomic task checkout"/title: "Write cold open for pilot"/
s/description: "Ensure in_progress claiming is conflict-safe"/description: "Draft the teaser\/cold open scene for episode 1"/
s/assigneeAgentId: engineer!/assigneeAgentId: staffWriter!/
s/createdByAgentId: ceo!/createdByAgentId: showrunner!/g
s/title: "Add budget auto-pause"/title: "Develop character bibles"/
s/description: "Pause agent at hard budget ceiling"/description: "Create detailed backstories for the main cast"/
' "$F" && rm -f "$F.bak"

# === 6. cli/src/commands/auth-bootstrap-ceo.ts ===
sed -i.bak 's/"bootstrap_ceo"/"bootstrap_showrunner"/g' cli/src/commands/auth-bootstrap-ceo.ts && rm -f cli/src/commands/auth-bootstrap-ceo.ts.bak

# === 7. cli/src/commands/client/approval.ts ===
sed -i.bak 's/hire_agent|approve_ceo_strategy/onboard_writer|approve_showrunner_vision/' cli/src/commands/client/approval.ts && rm -f cli/src/commands/client/approval.ts.bak

# === 8. server/src/routes/access.ts ===
F=server/src/routes/access.ts
sed -i.bak '
s/ceoCandidates/showrunnerCandidates/g
s/rootCeo/rootShowrunner/g
s/role === "ceo"/role === "showrunner"/g
s/"Only CEO agents can generate OpenClaw invite prompts"/"Only Showrunner writers can generate OpenClaw invite prompts"/
s/"company_join" as const/"production_join" as const/
s/inviteType === "bootstrap_ceo"/inviteType === "bootstrap_showrunner"/g
' "$F" && rm -f "$F.bak"

# === 9. server/src/routes/agents.ts ===
F=server/src/routes/agents.ts
sed -i.bak '
s/actorAgent.role === "ceo"/actorAgent.role === "showrunner"/g
s/"Only CEO or agent creators can modify other agents"/"Only Showrunner or writer creators can modify other writers"/
s/type: "hire_agent"/type: "onboard_writer"/
s/"Only CEO can manage permissions"/"Only Showrunner can manage permissions"/
' "$F" && rm -f "$F.bak"

# === 10. server/src/routes/approvals.ts ===
sed -i.bak 's/type === "hire_agent"/type === "onboard_writer"/g' server/src/routes/approvals.ts && rm -f server/src/routes/approvals.ts.bak

# === 11. server/src/routes/issues.ts ===
F=server/src/routes/issues.ts
sed -i.bak '
s/actorAgent.role === "ceo"/actorAgent.role === "showrunner"/g
s/"Missing permission to link approvals"/"Missing permission to link greenlights"/
s/agent.role === "ceo"/agent.role === "showrunner"/
' "$F" && rm -f "$F.bak"

# === 12. server/src/services/agent-permissions.ts ===
sed -i.bak 's/role === "ceo"/role === "showrunner"/' server/src/services/agent-permissions.ts && rm -f server/src/services/agent-permissions.ts.bak

# === 13. server/src/services/approvals.ts ===
sed -i.bak 's/type === "hire_agent"/type === "onboard_writer"/g' server/src/services/approvals.ts && rm -f server/src/services/approvals.ts.bak

# === 14. server/src/services/hire-hook.ts ===
sed -i.bak 's/agent is approved (join-request or hire_agent approval)/writer is approved (join-request or onboard_writer greenlight)/' server/src/services/hire-hook.ts && rm -f server/src/services/hire-hook.ts.bak

# === 15. UI Components ===

# ActiveAgentsPanel
F=ui/src/components/ActiveAgentsPanel.tsx
sed -i.bak '
s/>Agents</>Writers</
s/No recent agent runs/No recent writer runs/
' "$F" && rm -f "$F.bak"

# ActivityRow
sed -i.bak 's/"created company"/"created production"/;s/"updated company"/"updated production"/' ui/src/components/ActivityRow.tsx && rm -f ui/src/components/ActivityRow.tsx.bak

# AgentConfigForm
sed -i.bak 's/placeholder="Agent name"/placeholder="Writer name"/' ui/src/components/AgentConfigForm.tsx && rm -f ui/src/components/AgentConfigForm.tsx.bak

# AgentIconPicker - add imports and mappings
F=ui/src/components/AgentIconPicker.tsx
sed -i.bak '/  Fingerprint,/a\  PenTool,\n  Scroll,\n  Film,\n  Clapperboard,\n  Drama,\n  Feather,\n  BookOpen,\n  Theater,' "$F" && rm -f "$F.bak"
sed -i.bak '/  fingerprint: Fingerprint,/a\  "pen-tool": PenTool,\n  scroll: Scroll,\n  film: Film,\n  clapperboard: Clapperboard,\n  drama: Drama,\n  feather: Feather,\n  "book-open": BookOpen,\n  theater: Theater,' "$F" && rm -f "$F.bak"

# ApprovalCard
sed -i.bak 's/>Approve</>Greenlight</' ui/src/components/ApprovalCard.tsx && rm -f ui/src/components/ApprovalCard.tsx.bak

# ApprovalPayload
F=ui/src/components/ApprovalPayload.tsx
sed -i.bak '
s/hire_agent: "Hire Agent"/hire_agent: "Onboard Writer"/
s/approve_ceo_strategy: "CEO Strategy"/approve_ceo_strategy: "Showrunner Strategy"/
' "$F" && rm -f "$F.bak"

# CommandPalette
F=ui/src/components/CommandPalette.tsx
sed -i.bak '
s/Search issues, agents, projects\.\.\./Search assignments, writers, episodes.../
s/Create new issue/Create new assignment/
s/Create new agent/Create new writer/
s/Create new project/Create new episode/
s/>Issues</>Assignments</
s/>Projects</>Episodes</
s/>Goals</>Story Arcs</
s/>Agents</>Writers</
s/>Costs</>Budget</
s/heading="Issues"/heading="Assignments"/
s/heading="Agents"/heading="Writers"/
s/heading="Projects"/heading="Episodes"/
' "$F" && rm -f "$F.bak"

# CompanySwitcher
F=ui/src/components/CompanySwitcher.tsx
sed -i.bak '
s/"Select company"/"Select production"/
s/>Companies</>Productions</
s/>No companies</>No productions</
s/>Company Settings</>Production Settings</
s/>Manage Companies</>Manage Productions</
' "$F" && rm -f "$F.bak"

# GoalProperties
sed -i.bak 's/Parent Goal/Parent Arc/' ui/src/components/GoalProperties.tsx && rm -f ui/src/components/GoalProperties.tsx.bak

# GoalTree
F=ui/src/components/GoalTree.tsx
sed -i.bak '
s/capitalize">{goal.level}/capitalize">{{ production: "Production", room: "Room", writer: "Writer", assignment: "Assignment" }[goal.level] ?? goal.level}/
s/No goals\./No story arcs./
' "$F" && rm -f "$F.bak"

# IssueProperties
F=ui/src/components/IssueProperties.tsx
sed -i.bak '
s/>No project</>No episode</g
s/Search projects\.\.\./Search episodes.../
s/label="Project"/label="Episode"/
' "$F" && rm -f "$F.bak"

# IssuesList
F=ui/src/components/IssuesList.tsx
sed -i.bak '
s/>New Issue</>New Assignment</
s/Search issues\.\.\./Search assignments.../
s/aria-label="Search issues"/aria-label="Search assignments"/
s/No issues match the current filters or search\./No assignments match the current filters or search./
s/action="Create Issue"/action="Create Assignment"/
s/Search agents\.\.\./Search writers.../
' "$F" && rm -f "$F.bak"

# MobileBottomNav
F=ui/src/components/MobileBottomNav.tsx
sed -i.bak '
s/label: "Issues"/label: "Assignments"/
s/label: "Agents"/label: "Writers"/
' "$F" && rm -f "$F.bak"

# NewAgentDialog
F=ui/src/components/NewAgentDialog.tsx
sed -i.bak '
s/desc: "Local Claude agent"/desc: "Local Claude writer"/
s/desc: "Local Codex agent"/desc: "Local Codex writer"/
s/desc: "Local multi-provider agent"/desc: "Local multi-provider writer"/
s/desc: "Local Pi agent"/desc: "Local Pi writer"/
s/desc: "Local Cursor agent"/desc: "Local Cursor writer"/
s/role === "ceo"/role === "showrunner"/
s/title: "Create a new agent"/title: "Onboard a new writer"/
s/description: "(type in what kind of agent you want here)"/description: "(type in what kind of writer you want here)"/
s/Add a new agent/Add a new writer/
s/We recommend letting your CEO handle agent setup/We recommend letting your Showrunner handle writer setup/
s/Ask the CEO to create a new agent/Ask the Showrunner to onboard a new writer/
' "$F" && rm -f "$F.bak"

# NewGoalDialog
F=ui/src/components/NewGoalDialog.tsx
sed -i.bak '
s/company: "Company"/company: "Production"/
s/team: "Team"/team: "Room"/
s/agent: "Agent"/agent: "Writer"/
s/task: "Task"/task: "Assignment"/
s/New sub-goal/New sub-story arc/
s/New goal/New story arc/
s/Goal title/Story arc title/
s/Parent goal/Parent story arc/
s/Create sub-goal/Create sub-story arc/
s/Create goal/Create story arc/
' "$F" && rm -f "$F.bak"

# NewIssueDialog
F=ui/src/components/NewIssueDialog.tsx
sed -i.bak '
s/: "Agent options"/: "Writer options"/
s/>New issue</>New assignment</
s/placeholder="Issue title"/placeholder="Assignment title"/
s/noneLabel="No project"/noneLabel="No episode"/
s/searchPlaceholder="Search projects\.\.\."/searchPlaceholder="Search episodes..."/
s/emptyMessage="No projects found\."/emptyMessage="No episodes found."/
s/>Project</>Episode</
s/"Create Issue"/"Create Assignment"/
' "$F" && rm -f "$F.bak"

# NewProjectDialog
F=ui/src/components/NewProjectDialog.tsx
sed -i.bak '
s/>New project</>New episode</
s/placeholder="Project name"/placeholder="Episode name"/
s/Where will work be done on this project/Where will work be done on this episode/
s/"+ Goal"/"+ Story Arc"/
s/"Goal"/"Story Arc"/
s/>No goal</>No story arc</
s/All goals already selected/All story arcs already selected/
s/Failed to create project/Failed to create episode/
s/"Create project"/"Create episode"/
' "$F" && rm -f "$F.bak"

# OnboardingWizard
F=ui/src/components/OnboardingWizard.tsx
sed -i.bak '
s/Setup yourself as the CEO/Setup yourself as the Showrunner/
s/Use the ceo persona/Use the showrunner persona/
s/agents\/ceo/agents\/showrunner/
s/hire yourself a Founding Engineer agent/bring in your first Staff Writer/
s/useState("CEO")/useState("Showrunner")/
s/Create your CEO HEARTBEAT/Create your Showrunner HEARTBEAT/
s/setAgentName("CEO")/setAgentName("Showrunner")/
s/Create your CEO HEARTBEAT/Create your Showrunner HEARTBEAT/
s/create company/create production/
s/Failed to create company/Failed to create production/
s/role: "ceo"/role: "showrunner"/
s/Failed to create agent/Failed to create writer/
s/Name your company/Name your production/
s/organization your agents will work for/production your writers will work on/
s/>Company name</>Production name</
s/placeholder="Acme Corp"/placeholder="Season 3: The Return"/
s/Mission \/ goal (optional)/Creative vision (optional)/
s/What is this company trying to achieve/What story are you telling/
s/Create your first agent/Bring in your first writer/
s/Choose how this agent will run tasks/Choose how this writer will handle assignments/
s/>Agent name</>Writer name</
s/placeholder="CEO"/placeholder="Showrunner"/
s/CEO adapter config/Showrunner adapter config/
s/Give it something to do/Give them an assignment/
s/Give your agent a small task to start with.*$/Give your writer a first assignment — a scene draft,/
s/a research question, writing a script\./character study, or story outline./
s/>Task title</>Assignment title</
s/placeholder="e\.g\. Research competitor pricing"/placeholder="e.g. Draft the cold open for Episode 1"/
s/Add more detail about what the agent should do/Add more detail about what the writer should work on/
s/Your assigned task already woke/Your assignment already woke/
s/the agent, so you can jump straight to the issue/the writer, so you can jump straight to it/
s/>Company</>Production</
s/>Task</>Assignment</
' "$F" && rm -f "$F.bak"

# ProjectProperties
F=ui/src/components/ProjectProperties.tsx
sed -i.bak '
s/>Goals</>Story Arcs</
s/>Goal</>Story Arc</
s/All goals linked/All story arcs linked/
s/Workspaces give your agents/Workspaces give your writers/
' "$F" && rm -f "$F.bak"

# Sidebar
F=ui/src/components/Sidebar.tsx
sed -i.bak '
s/>New Issue</>New Assignment</
s/label="Issues"/label="Assignments"/
s/label="Goals"/label="Story Arcs"/
s/label="Company"/label="Production"/
s/label="Org"/label="Room"/
s/label="Costs"/label="Budget"/
' "$F" && rm -f "$F.bak"

# SidebarAgents
F=ui/src/components/SidebarAgents.tsx
sed -i.bak '
s/>Agents</>Writers</
s/aria-label="New agent"/aria-label="New writer"/
' "$F" && rm -f "$F.bak"

# SidebarProjects
F=ui/src/components/SidebarProjects.tsx
sed -i.bak '
s/>Projects</>Episodes</
s/aria-label="New project"/aria-label="New episode"/
' "$F" && rm -f "$F.bak"

# === 16. UI Pages ===

# Activity
sed -i.bak 's/Select a company to view activity/Select a production to view activity/' ui/src/pages/Activity.tsx && rm -f ui/src/pages/Activity.tsx.bak

# AgentDetail
F=ui/src/pages/AgentDetail.tsx
sed -i.bak '
s/label: "Agents"/label: "Writers"/
s/?? "Agent"/?? "Writer"/
s/title="Issues by Priority"/title="Assignments by Priority"/
s/title="Issues by Status"/title="Assignments by Status"/
' "$F" && rm -f "$F.bak"

# Agents
F=ui/src/pages/Agents.tsx
sed -i.bak '
s/label: "Agents"/label: "Writers"/
s/Select a company to view agents/Select a production to view writers/
s/>New Agent</>New Writer</
s/} agent/} writer/
s/} agents/} writers/
s/Create your first agent to get started/Bring in your first writer to get started/
s/action="New Agent"/action="New Writer"/
s/No agents match the selected filter/No writers match the selected filter/g
s/No organizational hierarchy defined/No room hierarchy defined/
' "$F" && rm -f "$F.bak"

# ApprovalDetail
F=ui/src/pages/ApprovalDetail.tsx
sed -i.bak '
s/label: "Approvals"/label: "Greenlights"/
s/?? "Approval"/?? "Greenlight"/
s/Review linked issues/Review linked assignments/
s/Review linked issue/Review linked assignment/
s/Open hired agent/Open onboarded writer/
s/Back to approvals/Back to greenlights/
s/type === "hire_agent"/type === "onboard_writer"/
' "$F" && rm -f "$F.bak"

# Approvals
F=ui/src/pages/Approvals.tsx
sed -i.bak '
s/label: "Approvals"/label: "Greenlights"/
s/Select a company first/Select a production first/
s/No pending approvals/No pending greenlights/
s/No approvals yet/No greenlights yet/
' "$F" && rm -f "$F.bak"

# Companies
F=ui/src/pages/Companies.tsx
sed -i.bak '
s/label: "Companies"/label: "Productions"/
s/>New Company</>New Production</
s/Loading companies/Loading productions/
s/>Delete Company</>Delete Production</
s/} "agent" : "agents"/} "writer" : "writers"/
s/} agent/} writer/
s/} "issue" : "issues"/} "assignment" : "assignments"/
s/} issue/} assignment/
s/Delete this company and all its data/Delete this production and all its data/
' "$F" && rm -f "$F.bak"

# CompanySettings
F=ui/src/pages/CompanySettings.tsx
sed -i.bak '
s/?? "Company"/?? "Production"/
s/No company selected\. Select a company/No production selected. Select a production/
s/>Company Settings</>Production Settings</
s/label="Company name"/label="Production name"/
s/The display name for your company/The display name for your production/
s/shown in the company profile/shown in the production profile/
s/placeholder="Optional company description"/placeholder="Optional production description"/
s/Sets the hue for the company icon/Sets the hue for the production icon/
s/>Hiring</>Onboarding</
s/Require board approval for new hires/Require executive producer greenlight for new writers/
s/New agent hires stay pending until approved by board/New writers stay pending until greenlighted by an executive producer/
s/Archive this company/Archive this production/
s/Archive company/Archive production/g
s/Failed to archive company/Failed to archive production/
' "$F" && rm -f "$F.bak"

# Costs
F=ui/src/pages/Costs.tsx
sed -i.bak '
s/label: "Costs"/label: "Budget"/
s/Select a company to view costs/Select a production to view budget/
s/>By Agent</>By Writer</
s/>By Project</>By Episode</
s/No project-attributed run costs yet/No episode-attributed run costs yet/
' "$F" && rm -f "$F.bak"

# Dashboard
F=ui/src/pages/Dashboard.tsx
sed -i.bak '
s/Welcome to Paperclip\. Set up your first company and agent/Welcome to the Writers Room. Set up your first production and writer/
s/Create or select a company to view the dashboard/Create or select a production to view the dashboard/
s/You have no agents/You have no writers/
s/label="Agents Enabled"/label="Writers Active"/
s/label="Tasks In Progress"/label="Assignments In Progress"/
s/label="Pending Approvals"/label="Pending Greenlights"/
s/stale tasks/stale assignments/
s/title="Issues by Priority"/title="Assignments by Priority"/
s/title="Issues by Status"/title="Assignments by Status"/
s/Recent Tasks/Recent Assignments/g
s/No tasks yet/No assignments yet/
' "$F" && rm -f "$F.bak"

# GoalDetail
F=ui/src/pages/GoalDetail.tsx
sed -i.bak '
s/label: "Goals"/label: "Story Arcs"/
s/?? "Goal"/?? "Story Arc"/
' "$F" && rm -f "$F.bak"

# Goals
F=ui/src/pages/Goals.tsx
sed -i.bak '
s/label: "Goals"/label: "Story Arcs"/
s/Select a company to view goals/Select a production to view story arcs/
s/No goals yet/No story arcs yet/
s/action="Add Goal"/action="Add Story Arc"/
s/>New Goal</>New Story Arc</
' "$F" && rm -f "$F.bak"

# Inbox
F=ui/src/pages/Inbox.tsx
sed -i.bak '
s/Select a company to view inbox/Select a production to view inbox/
s/>My recent issues</>My recent assignments</
s/>Approvals</>Greenlights</
s/>Failed runs</>Failed sessions</
s/placeholder="Approval status"/placeholder="Greenlight status"/
s/Approvals Needing Action/Greenlights Needing Action/
s/: "Approvals"/: "Greenlights"/
s/>Failed Runs</>Failed Sessions</
' "$F" && rm -f "$F.bak"

# IssueDetail
F=ui/src/pages/IssueDetail.tsx
sed -i.bak '
s/?? "Issue"/?? "Assignment"/
s/label: "Issues"/label: "Assignments"/
' "$F" && rm -f "$F.bak"

# Issues
F=ui/src/pages/Issues.tsx
sed -i.bak '
s/label: "Issues"/label: "Assignments"/
s/Select a company to view issues/Select a production to view assignments/
' "$F" && rm -f "$F.bak"

# MyIssues
F=ui/src/pages/MyIssues.tsx
sed -i.bak '
s/label: "My Issues"/label: "My Assignments"/
s/Select a company to view your issues/Select a production to view your assignments/
s/No issues assigned to you/No assignments assigned to you/
' "$F" && rm -f "$F.bak"

# Org
F=ui/src/pages/Org.tsx
sed -i.bak '
s/label: "Org Chart"/label: "Room Chart"/
s/Select a company to view org chart/Select a production to view room chart/
s/No agents in the organization\. Create agents to build your org chart/No writers in the room. Bring in writers to build your room chart/
' "$F" && rm -f "$F.bak"

# OrgChart
F=ui/src/pages/OrgChart.tsx
sed -i.bak '
s/label: "Org Chart"/label: "Room Chart"/
s/Select a company to view the org chart/Select a production to view the room chart/
s/No organizational hierarchy defined/No room hierarchy defined/
' "$F" && rm -f "$F.bak"

# ProjectDetail
F=ui/src/pages/ProjectDetail.tsx
sed -i.bak '
s/label: "Projects"/label: "Episodes"/
s/?? "Project"/?? "Episode"/
' "$F" && rm -f "$F.bak"

# Projects
F=ui/src/pages/Projects.tsx
sed -i.bak '
s/label: "Projects"/label: "Episodes"/
s/Select a company to view projects/Select a production to view episodes/
s/>Add Project</>Add Episode</
s/No projects yet/No episodes yet/
s/action="Add Project"/action="Add Episode"/
' "$F" && rm -f "$F.bak"

# === 17. Docs ===

# AGENTS.md
F=AGENTS.md
sed -i.bak '
s/AI-agent companies/AI writers rooms/
s/React + Vite board UI/React + Vite executive producer UI/
s/Keep changes company-scoped/Keep changes production-scoped/
s/scoped to a company and company boundaries/scoped to a production and production boundaries/
s/Single-assignee task model/Single-assignee assignment model/
s/Atomic issue checkout semantics/Atomic assignment checkout semantics/
s/Approval gates for governed actions/Greenlight gates for governed actions/
s/Board access is treated as full-control operator context/Executive producer access is treated as full-control operator context/
s/Agent access uses bearer/Writer access uses bearer/
s/Agent keys must not access other companies/Writer keys must not access other productions/
s/apply company access checks/apply production access checks/
s/enforce actor permissions (board vs agent)/enforce actor permissions (executive producer vs writer)/
s/Use company selection context for company-scoped pages/Use production selection context for production-scoped pages/
' "$F" && rm -f "$F.bak"

# README.md
F=README.md
sed -i.bak '
s/Open-source orchestration for zero-human companies/Open-source orchestration for AI writers rooms/
s/an _employee_, Paperclip is the _company_/a _writer_, Paperclip is the _production_/
s/orchestrates a team of AI agents to run a business/orchestrates a room of AI writers to run a production/
s/Bring your own agents, assign goals, and track your agents'\'' work and costs/Bring your own writers, assign story arcs, and track your writers'\'' work and budget/
s/org charts, budgets, governance, goal alignment, and agent coordination/room hierarchies, budgets, governance, story arc alignment, and writer coordination/
s/Manage business goals/Manage creative vision/
s/it'\''s hired/it'\''s in the room/g
s/autonomous AI companies/autonomous AI writers rooms/
s/coordinate many different agents.*toward a common goal/coordinate many different writers** (OpenClaw, Codex, Claude, Cursor) toward a common creative vision/
s/lose track of what everyone is doing/lose track of what everyone is writing/
s/want agents running/want writers working/
s/audit work and chime in/review work and give notes/
s/monitor costs.*enforce budgets/monitor budgets** and enforce spending limits/
s/process for managing agents.*task manager/process for managing writers that **feels like using a task manager/
s/manage your autonomous businesses/manage your productions/
s/Bring Your Own Agent/Bring Your Own Writer/
s/Any agent, any runtime, one org chart/Any writer, any runtime, one room hierarchy/
s/run companies, not babysit agents/run productions, not babysit writers/
' "$F" && rm -f "$F.bak"

# doc/GOAL.md
F=doc/GOAL.md
sed -i.bak '
s/backbone of the autonomous economy/backbone of AI-powered storytelling/
s/autonomous AI companies run on/autonomous AI writers rooms run on/
s/generate economic output that rivals the GDP/produce creative output that rivals the most prolific studios/
s/make autonomous companies more/make writers rooms more/
s/Autonomous companies.*global economy/Autonomous writers rooms — AI writing teams organized with real structure, governance, and accountability — will become a major force in creative production/
s/Not one company\. Thousands\. Millions\. An entire economic layer that runs on AI labor/Not one room. Thousands. An entire creative layer that runs on AI talent/
s/is not the company\. Paperclip is what makes the companies possible/is not the writers room. Paperclip is what makes writers rooms possible/
s/structure, task management, cost control, goal alignment/structure, assignment management, budget control, story arc alignment/
s/We are to autonomous companies what the corporate operating system/We are to autonomous writers rooms what the showrunner'\''s office/
s/not whether one company works/not whether one room works/
s/default foundation that autonomous companies are built on/default foundation that autonomous writers rooms are built on/
s/those companies, collectively, become a serious economic force that rivals the output of nations/those rooms, collectively, become a serious creative force/
s/entire workforce is AI agents/entire writing staff is AI writers/
s/control plane.*for an entire company/control plane** for an entire writers room/
s/command, communication, and control plane for a company of AI agents/command, communication, and control plane for a writers room of AI writers/
s/Manage agents as employees.*hire/Manage writers as staff** — onboard/
s/Define org structure.*org charts that agents/Define room hierarchy** — org charts that writers/
s/Track work in real time.*see at any moment what every agent/Track work in real time** — see at any moment what every writer/
s/Control costs.*token salary budgets per agent/Control costs** — token salary budgets per writer/
s/Align to goals.*agents see how their work serves the bigger mission/Align to story arcs** — writers see how their work serves the bigger creative vision/
s/Store company knowledge.*a shared brain for the organization/Store room knowledge** — a shared brain for the production/
s/Agent registry and org chart/Writer registry and room hierarchy/
s/Task assignment and status/Assignment tracking and status/
s/Company knowledge base/Production knowledge base/
s/Goal hierarchy.*task)/Story arc hierarchy (production → room → writer → assignment)/
s/Heartbeat monitoring.*stuck/Writing session monitoring — know when writers are active, idle, or stuck/
s/Agents run externally.*work\. Adapters/Writers run externally and report into the control plane. A writer is just code that gets kicked off and does work. Adapters/
s/Heartbeat loop.*does work/Writing session loop** — simple custom code that loops, checks in, does work/
s/control plane doesn'\''t run agents\. It orchestrates them\. Agents/control plane doesn'\''t run writers. It orchestrates them. Writers/
s/understand your entire company at a glance.*working/understand your entire writers room at a glance — who'\''s writing what, how much it costs, and whether it'\''s working/
' "$F" && rm -f "$F.bak"

# doc/PRODUCT.md
F=doc/PRODUCT.md
sed -i.bak '
s/control plane for autonomous AI companies/control plane for autonomous AI writers rooms/
s/can run multiple companies\. A \*\*company\*\*/can run multiple productions. A **production**/
s/### Company/### Production/
s/A company has:/A production has:/
s/A \*\*goal\*\*.*MRR.*months")/A **story arc** — the reason it exists ("Create a gripping 10-episode thriller series that wins critical acclaim")/
s/\*\*Employees\*\*.*AI agent/**Staff** — every staff member is an AI writer/
s/\*\*Org structure\*\*.*whom/**Room hierarchy** — who reports to whom/
s/\*\*Revenue \& expenses\*\*.*company level/**Revenue \& expenses** — tracked at the production level/
s/\*\*Task hierarchy\*\*.*company goal/**Assignment hierarchy** — all work traces back to the production'\''s story arc/
s/### Employees \& Agents/### Staff \& Writers/
s/Every employee is an agent\. When you create a company, you start by defining the CEO/Every staff member is a writer. When you create a production, you start by defining the Showrunner/
s/Each employee has:/Each writer has:/
s/how this agent runs and what defines its identity\/behavior/how this writer runs and what defines its identity\/behavior/
s/an OpenClaw agent/an OpenClaw writer/
s/a Claude Code agent/a Claude Code writer/
s/what this agent does/what this writer does/
s/helps other agents discover/helps other writers discover/
s/A CEO agent'\''s adapter config tells it to/A Showrunner writer'\''s adapter config tells it to/
s/review what your executives are doing, check company metrics/review what your head writers are doing, check production metrics/
s/on each heartbeat/on each writing session/
s/An engineer'\''s config tells it to/A staff writer'\''s config tells it to/
s/check assigned tasks/check assigned assignments/
s/who reports to the CEO: a CTO managing programmers, a CMO managing the marketing team/who reports to the Showrunner: a Head Writer managing staff writers, a Story Editor managing the narrative team/
s/Every agent in the tree/Every writer in the tree/
s/### Agent Execution/### Writer Execution/
s/running an agent'\''s heartbeat:/running a writer'\''s writing session:/
s/The heartbeat is "execute this and monitor it\."/The writing session is "execute this and monitor it."/
s/sends a webhook.*agent\. The heartbeat is.*wake up\."/sends a webhook\/API call to an externally running writer. The writing session is "notify this writer to wake up."/
s/default agent that shells out/default writer that shells out/
s/### Task Management/### Assignment Management/
s/Task management is hierarchical/Assignment management is hierarchical/
s/trace back to the company'\''s top-level goal/trace back to the production'\''s top-level story arc/
' "$F" && rm -f "$F.bak"

# Second pass for PRODUCT.md
sed -i.bak '
s/researching the Facebook ads Granola uses (current task)/researching Breaking Bad'\''s pilot cold open structure (current assignment)/
s/I need to create Facebook ads for our software/I need to draft the cold open for Episode 1/
s/I need to grow new signups by 100 users/I need to complete the Episode 1 script/
s/I need to get revenue to \$2,000 this week/I need to deliver the first batch of scripts/
s/building the #1 AI note-taking app to \$1M MRR in 3 months/creating a gripping 10-episode thriller series/
s/Tasks have parentage\. Every task exists in service of a parent task.*"why am I doing this?"/Assignments have parentage. Every assignment exists in service of a parent assignment, all the way up to the production'\''s story arc. This is what keeps autonomous writers aligned — they can always answer "why am I writing this?"/
s/More detailed task structure TBD/More detailed assignment structure TBD/
s/Unopinionated about how you run your agents.*mandate an agent runtime/Unopinionated about how you run your writers.** Your writers could be OpenClaw bots, Python scripts, Node scripts, Claude Code sessions, Codex instances — we don'\''t care. Paperclip defines the control plane for communication and provides utility infrastructure for writing sessions. It does not mandate a writer runtime./
s/Company is the unit of organization.*many companies/Production is the unit of organization.** Everything lives under a production. One Paperclip instance, many productions/
s/Adapter config defines the agent.*"be callable\."/Adapter config defines the writer.** Every writer has an adapter type and configuration that controls its identity and behavior. The minimum contract is just "be callable."/
s/All work traces to the goal.*shouldn'\''t exist/All work traces to the story arc.** Hierarchical assignment management means nothing exists in isolation. If you can'\''t explain why an assignment matters to the production'\''s story arc, it shouldn'\''t exist/
s/Control plane, not execution plane.*phone home/Control plane, not execution plane.** Paperclip orchestrates. Writers run wherever they run and phone home/
s/Open Paperclip, create a new company/Open Paperclip, create a new production/
s/Define the company'\''s goal:.*months"/Define the production'\''s story arc: "Create a gripping 10-episode thriller series that wins critical acclaim"/
s/Create the CEO/Create the Showrunner/
s/Configure the adapter (agent identity/Configure the adapter (writer identity/
s/CEO proposes strategic breakdown.*approves/Showrunner proposes creative breakdown → executive producer greenlights/
s/Define the CEO'\''s reports: CTO, CMO, CFO/Define the Showrunner'\''s reports: Head Writer, Story Editor, Script Coordinator/
s/Define their reports: engineers under CTO, marketers under CMO/Define their reports: staff writers under Head Writer/
s/Set budgets, define initial strategic tasks/Set budgets, define initial creative assignments/
s/agents start their heartbeats and the company runs/writers start their writing sessions and the room runs/
s/the full technical specification.*data model/the full technical specification and [TASKS.md](\.\/TASKS.md) for the assignment management data model/
' "$F" && rm -f "$F.bak"

echo ""
echo "Done! Rebrand applied to 59 files."
echo "Review changes with: git diff"
echo "New migration: packages/db/src/migrations/0026_writers_room_rebrand.sql"
