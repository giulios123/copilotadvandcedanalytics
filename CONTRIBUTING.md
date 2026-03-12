# Contributing to Copilot Studio Advanced Analytics

Thank you for your interest in contributing! This project welcomes contributions from the community.

## 🎯 Ways to Contribute

- **KQL Queries**: Add new queries for additional monitoring scenarios
- **Dashboards**: Create or improve Azure Data Explorer dashboards
- **Documentation**: Enhance guides, add examples, fix typos
- **Bug Fixes**: Report or fix issues with existing queries
- **Feature Requests**: Suggest new capabilities or improvements

## 🚀 Getting Started

1. **Fork the repository**
   - Click the 'Fork' button on GitHub
   - Clone your fork locally

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards below
   - Test your queries against real data when possible

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: descriptive commit message"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to the original repository
   - Click 'New Pull Request'
   - Provide a clear description of your changes

## 📝 Coding Standards

### KQL Queries

- **Comments**: Add clear comments explaining the query purpose
- **Formatting**: Use consistent indentation (4 spaces)
- **Filtering**: Always filter out test data: `where isDesignMode == "False"`
- **Performance**: Optimize queries for large datasets
- **Time Ranges**: Use parameterized time ranges when possible

Example format:
```kql
// Query Purpose: Brief description of what this query does
// Expected Use: When and why to use this query
// Performance: Notes on query performance if applicable

customEvents
| where timestamp > ago(7d)
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"
// Additional logic here
| summarize Count = count() by bin(timestamp, 1h)
| render timechart
```

### Documentation

- Use clear, concise language
- Include examples where helpful
- Update README.md if adding new sections
- Follow existing markdown formatting

### Dashboards

- Provide JSON export with clear naming
- Include a screenshot of the dashboard
- Document required parameters and data sources
- Add setup instructions

## 🧪 Testing

Before submitting:

1. **Verify queries run** against Application Insights data
2. **Check for errors** - ensure no syntax issues
3. **Test edge cases** - null values, empty datasets, etc.
4. **Validate results** - ensure output makes sense

## 📋 Pull Request Guidelines

### PR Title Format
- Add: [description] - for new features
- Fix: [description] - for bug fixes
- Docs: [description] - for documentation
- Update: [description] - for improvements

### PR Description Should Include
- Clear explanation of changes
- Reason for the change
- Testing performed
- Screenshots (for dashboards or visual changes)
- Related issues (if applicable)

### Example PR Description
```markdown
## Description
Added new KQL query to analyze conversation abandonment rates.

## Motivation
Helps teams identify where users drop off in conversations.

## Changes
- Added conversation-abandonment.kql to 03-Quality-Metrics/
- Updated README.md with new metric description
- Added usage example in QUICK-REFERENCE.md

## Testing
- Tested against production Application Insights data
- Verified results match expected abandonment patterns
- Performance tested with 30-day time range
```

## 🐛 Reporting Issues

When reporting bugs or issues:

1. **Search existing issues** first
2. **Provide details**:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Application Insights schema version (if known)
   - Error messages or screenshots

## 💡 Feature Requests

For feature suggestions:

1. Check if already requested
2. Explain the use case
3. Describe expected behavior
4. Provide examples if possible

## 📄 Licensing

By contributing, you agree that your contributions will be licensed under the MIT License.

## ❓ Questions

If you have questions:
- Open a GitHub issue with the question label
- Check existing documentation in CopilotStudio-KQL/Docs/
- Review troubleshooting guides

## 🙏 Thank You!

Your contributions make this project better for everyone in the Copilot Studio community!

---

**Remember**: All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).
