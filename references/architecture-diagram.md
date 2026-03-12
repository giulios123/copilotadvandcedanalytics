# Architecture Diagram Skill

## Description
Specialized skill for creating, analyzing, and maintaining architecture diagrams for cloud and agent-based systems using draw.io and excalidraw formats.

## Triggers
- User asks to create/update architecture diagrams
- User mentions system design, architecture review, or technical documentation
- User needs to visualize cloud infrastructure, agent workflows, or integration patterns
- User works with Dynamics 365, Copilot Studio, or multi-agent systems

## Capabilities

### 1. Diagram Creation & Analysis
- Generate draw.io (.drawio) files for formal architecture documentation
- Create excalidraw (.excalidraw) files for brainstorming and rapid prototyping
- Parse existing diagram files to understand current architecture
- Suggest improvements based on best practices

### 2. Specialized Architecture Patterns

#### Cloud Architecture
- Multi-tier application architectures (presentation, business, data layers)
- Microservices and containerized deployments (Kubernetes, Docker)
- Serverless architectures (Azure Functions, AWS Lambda)
- Cloud-native patterns (CQRS, Event Sourcing, API Gateway)
- Hybrid cloud and multi-cloud topologies
- Infrastructure as Code (IaC) visualizations

#### Agent Architectures
- Single-agent systems with reasoning loops
- Multi-agent orchestration patterns
- Agent communication protocols and message flows
- Tool/function calling architectures
- Memory and context management systems
- Agent-to-agent collaboration patterns
- Human-in-the-loop workflows

#### Microsoft Dynamics 365 & Copilot Studio
- Dynamics 365 customization architecture
- Power Platform integration flows
- Copilot Studio conversation flows
- Plugin and custom connector architectures
- Dataverse entity relationships
- Security and permission models

### 3. Diagram Types

#### High-Level Diagrams
- **System Context Diagrams**: Show system boundaries and external actors
- **Container Diagrams**: High-level technical building blocks
- **Deployment Diagrams**: Infrastructure and hosting arrangements

#### Detailed Diagrams
- **Component Diagrams**: Internal structure and dependencies
- **Sequence Diagrams**: Message flows and interactions over time
- **Data Flow Diagrams**: Information movement through the system
- **Network Diagrams**: Cloud networking and connectivity

#### Process Diagrams
- **Business Process Flows**: End-to-end business scenarios
- **Agent Workflow Diagrams**: Decision trees and action sequences
- **Integration Patterns**: API flows, event-driven architectures

### 4. Best Practices

#### Visual Design
- Use consistent color coding (e.g., blue for services, green for data stores, orange for external systems)
- Apply layering for complex diagrams (infrastructure, application, security)
- Include legends and annotations for clarity
- Maintain proper spacing and alignment
- Use standard iconography (Azure icons, AWS icons, generic cloud symbols)

#### Technical Documentation
- **Title and Version**: Every diagram should have clear title and version number
- **Date and Author**: Track when and who created/modified
- **Purpose Statement**: Brief description of what the diagram shows
- **Assumptions and Constraints**: Document key decisions and limitations
- **Links to Related Docs**: Connect diagrams to specifications, ADRs, code repos

#### Maintenance
- Keep diagrams in version control with code
- Update diagrams during architecture reviews
- Archive outdated versions with clear notes
- Generate multiple export formats (PNG, SVG, PDF)

### 5. Workflow

When creating architecture diagrams:

1. **Understand Requirements**
   - Identify the target audience (developers, stakeholders, operations)
   - Determine the level of detail needed
   - Clarify the specific architecture aspect to visualize

2. **Choose the Right Format**
   - **draw.io**: For formal documentation, detailed technical diagrams, final deliverables
   - **excalidraw**: For brainstorming, collaborative sessions, rapid iteration

3. **Design the Diagram**
   - Start with high-level components and relationships
   - Add details progressively (top-down approach)
   - Use appropriate symbols and notation (C4, UML, ArchiMate)
   - Apply consistent styling throughout

4. **Generate/Modify Files**
   - Create XML structure for .drawio files
   - Create JSON structure for .excalidraw files
   - Ensure proper formatting and readability
   - Validate that all connections and relationships are correct

5. **Document and Export**
   - Add metadata and descriptions
   - Export to image formats for presentations
   - Link to related architecture decision records (ADRs)
   - Share with stakeholders for review

### 6. Common Architecture Scenarios

#### Cloud-Based Agent System
```
Components to visualize:
- Agent orchestrator/controller
- Individual agent instances (reasoning, planning, execution)
- Tool/function registry
- Memory stores (short-term, long-term)
- External APIs and services
- Message queues for agent communication
- Monitoring and observability layer
```

#### Dynamics 365 Integration
```
Components to visualize:
- Dynamics 365 modules (Sales, Service, Marketing)
- Power Platform components (Power Apps, Power Automate)
- Copilot Studio bots and topics
- Custom plugins and workflows
- External system integrations
- Authentication flows (OAuth, Azure AD)
- Data synchronization patterns
```

#### Hybrid Cloud Architecture
```
Components to visualize:
- On-premises systems and databases
- Cloud services (Azure, AWS, GCP)
- Network connectivity (VPN, ExpressRoute, Direct Connect)
- Identity and access management
- Data residency and compliance boundaries
- Disaster recovery and backup strategies
```

## Output Format

When generating diagrams:
1. Create the diagram file in the appropriate format
2. Provide a written explanation of:
   - Architecture overview
   - Key components and their responsibilities
   - Critical relationships and data flows
   - Design decisions and trade-offs
   - Security and scalability considerations
3. Suggest next steps or alternative views if needed

## Example Usage

**User**: "Create an architecture diagram for a multi-agent system that processes customer inquiries using Copilot Studio"

**Response**:
1. Create excalidraw file for initial design discussion
2. Identify components: intake agent, routing logic, specialized agents (billing, technical support, sales)
3. Show agent communication patterns and shared context
4. Include Copilot Studio integration points
5. Document decision rationale
6. Offer to create formal draw.io version once design is approved

## Notes
- Always explain the diagram's purpose and audience
- Balance detail with clarity - avoid overcomplicating
- Use industry-standard patterns and notations when applicable
- Consider security, privacy, and compliance in architecture designs
- Suggest improvements based on cloud-native and agent architecture best practices
