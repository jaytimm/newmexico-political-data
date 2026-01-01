#!/bin/bash
# ============================================================================
# Setup Docling Python Environment
# ============================================================================
# This script creates a Python environment (conda or venv) specifically for
# Docling PDF processing. It installs langchain-docling and required dependencies.
#
# Usage: bash scripts/setup_docling_env.sh
#        (run from project root directory)
# ============================================================================

set -e  # Exit on error

ENV_NAME="docling"
PYTHON_VERSION="3.11"
USE_VENV=false

# Get project root directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV_PATH="$PROJECT_ROOT/.venv_docling"

echo "============================================================================"
echo "Setting up Docling Python environment: $ENV_NAME"
echo "============================================================================"

# Check if conda is available
if command -v conda &> /dev/null; then
    echo "✓ Conda detected - will use conda environment"
    USE_VENV=false
else
    echo "⚠ Conda not found - will use Python venv instead"
    USE_VENV=true
    
    # Check if Python 3 is available
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is not installed or not in PATH"
        echo "Please install Python 3.10 or later"
        exit 1
    fi
    
    PYTHON3_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo "✓ Found Python $PYTHON3_VERSION"
fi

if [ "$USE_VENV" = false ]; then
    # ========================================================================
    # CONDA SETUP
    # ========================================================================
    
    # Check if environment already exists
    if conda env list | grep -q "^${ENV_NAME} "; then
        echo "Environment '$ENV_NAME' already exists."
        read -p "Do you want to remove and recreate it? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing existing environment..."
            conda env remove -n "$ENV_NAME" -y
        else
            echo "Exiting. Use 'conda activate $ENV_NAME' to use existing environment."
            exit 0
        fi
    fi

    # Create conda environment
    echo "Creating conda environment '$ENV_NAME' with Python $PYTHON_VERSION..."
    conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y

    # Activate environment and install packages
    echo "Installing langchain-docling and dependencies..."
    conda run -n "$ENV_NAME" pip install langchain-docling

    # Verify installation
    echo ""
    echo "============================================================================"
    echo "Verifying installation..."
    echo "============================================================================"
    conda run -n "$ENV_NAME" python -c "import langchain_docling; print('✓ langchain-docling imported successfully')"

    # Check transformers version (needs to be >= 4.55.0 for rt_detr_v2 support)
    TRANSFORMERS_VERSION=$(conda run -n "$ENV_NAME" python -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "not installed")
    if [ "$TRANSFORMERS_VERSION" != "not installed" ]; then
        echo "✓ transformers version: $TRANSFORMERS_VERSION"
        # Check if version is >= 4.55.0
        if python3 -c "from packaging import version; exit(0 if version.parse('$TRANSFORMERS_VERSION') >= version.parse('4.55.0') else 1)" 2>/dev/null; then
            echo "✓ transformers version is compatible"
        else
            echo "⚠ Warning: transformers version may be too old (< 4.55.0)"
            echo "  Run: conda activate $ENV_NAME && pip install --upgrade transformers"
        fi
    fi

    echo ""
    echo "============================================================================"
    echo "Setup complete!"
    echo "============================================================================"
    echo "To use this environment:"
    echo "  conda activate $ENV_NAME"
    echo ""
    echo "To get the Python path for R scripts:"
    echo "  conda activate $ENV_NAME"
    echo "  which python"
    echo ""
    echo "The Python path will typically be:"
    echo "  ~/miniconda3/envs/$ENV_NAME/bin/python"
    echo "  (or ~/anaconda3/envs/$ENV_NAME/bin/python if using Anaconda)"
    echo "============================================================================"
    
else
    # ========================================================================
    # VENV SETUP
    # ========================================================================
    
    # Check if venv already exists
    if [ -d "$VENV_PATH" ]; then
        echo "Virtual environment already exists at: $VENV_PATH"
        read -p "Do you want to remove and recreate it? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing existing virtual environment..."
            rm -rf "$VENV_PATH"
        else
            echo "Using existing virtual environment."
            echo ""
            echo "============================================================================"
            echo "Setup complete!"
            echo "============================================================================"
            echo "To use this environment:"
            echo "  source $VENV_PATH/bin/activate"
            echo ""
            echo "Python path for R scripts:"
            echo "  $VENV_PATH/bin/python"
            echo "============================================================================"
            exit 0
        fi
    fi

    # Create virtual environment
    echo "Creating Python virtual environment at: $VENV_PATH"
    python3 -m venv "$VENV_PATH"

    # Activate and install packages
    echo "Installing langchain-docling and dependencies..."
    "$VENV_PATH/bin/pip" install --upgrade pip
    "$VENV_PATH/bin/pip" install langchain-docling

    # Verify installation
    echo ""
    echo "============================================================================"
    echo "Verifying installation..."
    echo "============================================================================"
    "$VENV_PATH/bin/python" -c "import langchain_docling; print('✓ langchain-docling imported successfully')"

    # Check transformers version
    TRANSFORMERS_VERSION=$("$VENV_PATH/bin/python" -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "not installed")
    if [ "$TRANSFORMERS_VERSION" != "not installed" ]; then
        echo "✓ transformers version: $TRANSFORMERS_VERSION"
        # Check if version is >= 4.55.0
        if "$VENV_PATH/bin/python" -c "from packaging import version; exit(0 if version.parse('$TRANSFORMERS_VERSION') >= version.parse('4.55.0') else 1)" 2>/dev/null; then
            echo "✓ transformers version is compatible"
        else
            echo "⚠ Warning: transformers version may be too old (< 4.55.0)"
            echo "  Run: source $VENV_PATH/bin/activate && pip install --upgrade transformers"
        fi
    fi

    echo ""
    echo "============================================================================"
    echo "Setup complete!"
    echo "============================================================================"
    echo "To use this environment:"
    echo "  source $VENV_PATH/bin/activate"
    echo ""
    echo "Python path for R scripts:"
    echo "  $VENV_PATH/bin/python"
    echo "============================================================================"
fi

