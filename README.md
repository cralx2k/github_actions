# GitHub Actions Training

Welcome to the GitHub Actions Training repository! This repository contains examples and demonstrations of various GitHub Actions features and workflows.

## 📚 Overview

This repository is designed to help you learn and understand GitHub Actions through practical examples. It includes:

- A simple Python calculator application
- Multiple workflow examples demonstrating different GitHub Actions features
- Best practices for CI/CD pipelines

## 🚀 Workflows Included

### 1. CI - Continuous Integration (`ci.yml`)
- **Triggers**: Push and Pull Request to main/master branches
- **Purpose**: Runs tests and validates code on every push
- **Features**:
  - Automated testing with pytest
  - Python environment setup
  - Dependency installation

### 2. Manual Workflow (`manual.yml`)
- **Triggers**: Manual dispatch (workflow_dispatch)
- **Purpose**: Demonstrates manually triggered workflows with input parameters
- **Features**:
  - Custom input parameters (environment, log level)
  - Choice-based inputs
  - Dynamic workflow execution based on inputs

### 3. Matrix Build (`matrix.yml`)
- **Triggers**: Push and Pull Request to main/master branches
- **Purpose**: Tests code across multiple environments
- **Features**:
  - Multi-OS testing (Ubuntu, Windows, macOS)
  - Multiple Python versions (3.9, 3.10, 3.11, 3.12)
  - Parallel execution
  - Fail-fast disabled for complete test coverage

### 4. Scheduled Workflow (`scheduled.yml`)
- **Triggers**: Cron schedule (daily at 00:00 UTC) and manual dispatch
- **Purpose**: Demonstrates scheduled workflows for periodic tasks
- **Features**:
  - Daily health checks
  - Automated testing on schedule
  - Status reporting

### 5. Event Triggers Demo (`events.yml`)
- **Triggers**: Multiple event types (push, pull_request, issues, release, workflow_dispatch)
- **Purpose**: Shows various GitHub event triggers
- **Features**:
  - Path filtering
  - Branch filtering
  - Event type detection
  - Conditional execution

### 6. Deploy Simulation (`deploy.yml`)
- **Triggers**: Push to main/master and manual dispatch
- **Purpose**: Demonstrates a complete CI/CD pipeline
- **Features**:
  - Build artifacts
  - Multi-stage deployment (staging → production)
  - Environment protection
  - Artifact upload/download
  - Conditional deployment based on branch

## 🛠️ Application

The repository includes a simple Python calculator application (`app.py`) with:
- Basic arithmetic operations (add, subtract, multiply, divide)
- Comprehensive test suite (`test_app.py`)
- Error handling

## 📦 Requirements

- Python 3.9+
- pytest

Install dependencies:
```bash
pip install -r requirements.txt
```

## 🧪 Running Tests Locally

```bash
# Run tests
pytest test_app.py -v

# Run the application
python app.py
```

## 📖 Learning Resources

### Key Concepts Demonstrated:

1. **Workflow Syntax**: Basic YAML structure for GitHub Actions
2. **Event Triggers**: Different ways to trigger workflows
3. **Jobs and Steps**: Organizing workflow execution
4. **Matrix Strategy**: Testing across multiple configurations
5. **Artifacts**: Sharing data between jobs
6. **Environments**: Deployment protection and approval gates
7. **Conditional Execution**: Running jobs based on conditions
8. **Scheduled Workflows**: Using cron syntax for periodic execution
9. **Manual Triggers**: Interactive workflow execution
10. **Context Variables**: Using GitHub context information

### Workflow Components:

- `on`: Defines when the workflow runs
- `jobs`: Defines the work to be done
- `runs-on`: Specifies the runner (Ubuntu, Windows, macOS)
- `steps`: Individual tasks within a job
- `uses`: References external actions
- `run`: Executes shell commands
- `with`: Provides inputs to actions
- `if`: Conditional execution
- `needs`: Job dependencies

## 🎯 How to Use This Repository

1. **Fork or clone** this repository
2. **Explore** the `.github/workflows/` directory
3. **Modify** the workflows to experiment
4. **Push changes** to trigger the workflows
5. **Monitor** the "Actions" tab in GitHub to see workflows in action
6. **Review** workflow logs to understand execution

## 💡 Tips

- Start with the simple `ci.yml` workflow
- Progress to more complex examples like matrix builds and deployment
- Use the Actions tab to manually trigger workflows with `workflow_dispatch`
- Check workflow logs for detailed execution information
- Experiment with modifying triggers and conditions

## 📝 Next Steps

To deepen your understanding:
1. Modify existing workflows
2. Add new workflows for different scenarios
3. Integrate with external services
4. Add secrets and environment variables
5. Implement approval gates for deployments
6. Create reusable workflows
7. Build custom actions

## 🤝 Contributing

Feel free to contribute additional workflow examples or improvements!

## 📄 License

This is a training repository - use freely for learning purposes.

---

Happy Learning! 🎉